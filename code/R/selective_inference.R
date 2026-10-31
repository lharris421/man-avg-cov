#' Title
#'
#' @param dat
#' @param alpha
#' @param estimate_sigma
#' @param sigma
#' @param lambda
#'
#' @return
#' @export
#'
#' @examples
selective_inference <- function(X, y, alpha = .2, estimate_sigma = FALSE, sigma = NULL, lambda = NULL, family = "gaussian") {

  X <- ncvreg::std(X)

  family <- match.arg(family, c("gaussian","binomial"))

  if (is.null(lambda)) {
    if (family == "gaussian") {
      cv_res <- glmnet::cv.glmnet(X, y, standardize = FALSE, family = "gaussian")
    } else {
      cv_res <- glmnet::cv.glmnet(X, y, standardize = FALSE, family = "binomial")
    }
    lam <- cv_res$lambda.min
    fit <- cv_res$glmnet.fit
  } else {
    if (family == "gaussian") {
      fit <- glmnet::glmnet(X, y, standardize = FALSE, family = "gaussian")
    } else {
      fit <- glmnet::glmnet(X, y, standardize = FALSE, family = "binomial")
    }
    lam <- lambda
  }

  if (family == "binomial") {
    b <- coef(fit, x = X, y = y, s = lam, exact = TRUE)
  } else {
    b <- coef(fit, x = X, y = y, s = lam, exact = TRUE)[-1]
  }
  tryCatch({
    if (estimate_sigma & is.null(sigma)) {
      sigma <- estimateSigma(X, y, standardize = FALSE)$sigmahat
    }
    res <- selectiveInference::fixedLassoInf(X, y, b, lam*length(y), alpha = alpha, sigma = sigma, family = family, bits = 200)
    B <- data.frame(res$ci)
    colnames(B) <- c("lower", "upper")
    B$variable <- names(res$vars)

    if (family == "binomial") {
      b <- b[-1]
    }
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
