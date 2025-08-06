selective_inference <- function(X, y, alpha = .2, estimate_sigma = FALSE, sigma = NULL, lambda = NULL) {

  X <- ncvreg::std(X)

  if (is.null(lambda)) {
    cv_res <- cv.glmnet(X, y, standardize = FALSE)
    lam <- cv_res$lambda.min
    fit <- cv_res$glmnet.fit
  } else {
    fit <- glmnet(X, y, standardize = FALSE)
    lam <- lambda
  }

  b <- coef(fit, x = X, y = y, s = lam, exact = TRUE)[-1]
  tryCatch({
    if (estimate_sigma & is.null(sigma)) {
      sigma <- estimateSigma(X, y)$sigmahat
    }
    res <- fixedLassoInf(X, y, b, lam*length(y), alpha = alpha, sigma = sigma)
    B <- data.frame(res$ci)
    colnames(B) <- c("lower", "upper")
    B$variable <- names(res$vars)

    estimates <- data.frame(variable = colnames(X), estimate = b, scale = attr(X, "scale"))
    si_ci <- B %>%
      left_join(estimates, by = join_by(variable)) %>%
      mutate(
        estimate = estimate / scale,
        lower = lower / scale,
        upper = upper / scale,
        lambda = lam,
        sigma = res$sigma
      ) %>%
      full_join(data.frame(variable = colnames(X)), by = join_by(variable)) %>%
      dplyr::select(-scale)
    res <- si_ci
    return(res)
  }, error = function(e) {
    res <- data.frame(variable = colnames(X), estimate = NA, lower = NA, upper = NA, lambda = NA, sigma = NA, error = as.character(e))
    return(res)
  }
  )
}
