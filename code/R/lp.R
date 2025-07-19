lp <- function(X, y, alpha = 0.05, lambda = NULL, original = FALSE) {

  if (is.null(lambda) & !original) {
    cv_fit <- cv.glmnet(X, y)
    lambda <- cv_fit$lambda.min
  }

  if (!is.null(lambda) & original) {
    warning("overwriting specified lambda value and using lambda selected by lasso.proj")
    lambda <- NULL
  }

  tryCatch({
    fit.lasso.allinfo <- lasso.proj(
      X, y, lambda = lambda,
      suppress.grouptesting = TRUE
    )
    ci_hdi <- confint(fit.lasso.allinfo, level = 1 - alpha)

    ci <- ci_hdi %>%
      data.frame(variable = rownames(ci_hdi)) %>%
      mutate(estimate = fit.lasso.allinfo$bhat) %>%
      dplyr::select(variable, estimate, lower, upper) %>%
      mutate(
        lambda = fit.lasso.allinfo$lambda,
        lambda = fit.lasso.allinfo$sigmahat
      )

    res <- ci
    return(res)
  }, error = function(e) {
    print(e);
    res <- NULL
    return(res)
  })
}
