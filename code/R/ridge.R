cv_ridge <- function(X, y, nfolds = 10) {

  ridge_fit <- hdrm::ridge(X, y)
  n <- length(y)
  E <- Y <- matrix(NA, nrow=n, ncol=length(ridge_fit$lambda))

  fold <- sample(1:n %% nfolds)
  fold[fold==0] <- nfolds

  cv.args <- list()
  cv.args$lambda <- ridge_fit$lambda

  for (i in 1:nfolds) {
    res <- cvf(i, X, y, fold, cv.args)
    E[fold==i, 1:res$nl] <- res$loss
    Y[fold==i, 1:res$nl] <- res$yhat
  }

  ## Eliminate saturated lambda values, if any
  ind <- which(apply(is.finite(E), 2, all))
  E <- E[, ind, drop=FALSE]
  Y <- Y[, ind]
  lambda <- ridge_fit$lambda[ind]

  ## Return
  cve <- apply(E, 2, mean)
  cvse <- apply(E, 2, stats::sd) / sqrt(n)
  min <- which.min(cve)

  val <- list(cve=cve, cvse=cvse, fold=fold, lambda=lambda, fit=ridge_fit, min=min, lambda.min=lambda[min],
              null.dev=mean(ncvreg:::loss.ncvreg(y, rep(mean(y), n), "gaussian")))
  return(val)

}
cvf <- function(i, X, y, fold, cv.args) {
  XX <- X[fold!=i, , drop=FALSE]
  yy <- y[fold!=i]
  fit.i <- hdrm::ridge(XX, yy)

  X2 <- X[fold==i, , drop=FALSE]
  y2 <- y[fold==i]
  yhat <- matrix(predict(fit.i, X2, type="response"), length(y2))
  loss <- ncvreg:::loss.ncvreg(y2, yhat, "gaussian")
  list(loss=loss, nl=length(fit.i$lambda), yhat=yhat)
}
ridge_fit <- function(X, y, alpha, lambda = NULL) {
  if (is.null(lambda)) {
    ridge_cv <- cv_ridge(X, y)
    ridge_fit <- ridge_cv$fit
    lambda <- ridge_cv$lambda.min
    sigma <- sqrt(ridge_cv$cve[ridge_cv$min])
  } else {
    ridge_fit <- hdrm::ridge(X, y)
    sigma <- 10
  }
  conf_ints <- confint(ridge_fit, level = 1 - alpha, lambda = lambda)
  cis <- bind_cols(conf_ints, "Estimate" = coef(ridge_fit, lambda = lambda))[-1,] %>%
    data.frame() %>%
    mutate(variable = colnames(X))
  colnames(cis) <- c("lower", "upper", "estimate", "variable")
  return(
    cis %>%
      dplyr::select(variable, estimate, lower, upper) %>%
      mutate(
        lambda = lambda,
        sigma = sigma
      )
  )
}
ridge_bootstrap <- function(X, y,
                            lambda      = NULL,
                            rerun_cv    = FALSE,
                            type        = c("pairs","residual"),
                            B           = 1000,
                            nfolds      = 10) {
  type <- match.arg(type)
  n    <- nrow(X)
  p    <- ncol(X)

  # 1) select λ via CV (if NULL) or keep provided λ,
  #    and save initial fit for coef()
  if (is.null(lambda)) {
    cv0        <- cv_ridge(X, y, nfolds = nfolds)
    lambda_min <- cv0$lambda.min
    fit0       <- cv0$fit
  } else {
    lambda_min <- lambda
    if (type == "residual") {
      fit0 <- hdrm::ridge(X, y)
    } else {
      # for pairs + rerun_cv=FALSE, we only need lambda_min
      fit0 <- NULL
    }
  }

  # 2) for residual bootstrap, prep residuals
  if (type == "residual") {
    beta0   <- as.vector(coef(fit0, lambda = lambda_min))[-1]
    fitted0 <- as.vector(X %*% beta0)
    res0    <- y - fitted0
    res0    <- res0 - mean(res0)
  }

  # 3) bootstrap
  boot_mat <- matrix(NA, nrow = B, ncol = p)
  for (b in seq_len(B)) {
    if (type == "pairs") {
      ii <- sample.int(n, replace = TRUE)
      Xb <- X[ii, , drop = FALSE];  yb <- y[ii]
    } else {
      Xb <- X
      yb <- fitted0 + sample(res0, size = n, replace = TRUE)
    }

    if (rerun_cv) {
      cvb    <- cv_ridge(Xb, yb, nfolds = nfolds)
      lam_b  <- cvb$lambda.min
      fitb   <- cvb$fit
    } else {
      fitb   <- hdrm::ridge(Xb, yb)
      lam_b  <- lambda_min
    }

    boot_mat[b, ] <- as.vector(coef(fitb, lambda = lam_b))[-1]
  }

  boot_mat
}
ridge_bootstrap_ci <- function(X, y,
                               lambda      = NULL,
                               rerun_cv    = FALSE,
                               type        = c("pairs","residual"),
                               B           = 1000,
                               nfolds      = 10,
                               alpha       = 0.05) {
  type <- match.arg(type)

  # scale X (and remember original scales)
  X   <- ncvreg::std(X)
  xsc <- attr(X, "scale")

  # compute original fit & coef b0
  if (is.null(lambda)) {
    cv0        <- cv_ridge(X, y, nfolds = nfolds)
    lambda0    <- cv0$lambda.min
    fit0       <- cv0$fit
  } else {
    lambda0    <- lambda
    fit0       <- hdrm::ridge(X, y)
  }
  b0 <- as.vector(coef(fit0, lambda = lambda0))[-1]

  # get all bootstrap draws
  samps <- ridge_bootstrap(X, y, lambda0, rerun_cv, type, B, nfolds)

  # if (any(is.na(samps))) { print()}
  q_lo     <- apply(samps, 2, quantile, probs = alpha/2)
  q_hi     <- apply(samps, 2, quantile, probs = 1 - alpha/2)

  ci_lower <- q_lo / xsc
  ci_upper <- q_hi / xsc

  data.frame(
    variable = colnames(X),
    lower    = ci_lower,
    upper    = ci_upper,
    lambda = lambda0,
    row.names = NULL
  )
}
