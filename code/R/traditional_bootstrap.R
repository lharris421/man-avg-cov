traditional_bootstrap <- function(X, y, b = 1000, penalty = "lasso", level = 0.8) {


  lambda <- cv.ncvreg(X, y, penalty = penalty)$lambda.min

  samples <- matrix(nrow = b, ncol = ncol(X))
  for (i in 1:b) {
    idx <- sample.int(nrow(X), replace = TRUE)
    fit <- ncvreg(X[idx,], y[idx], penalty = penalty)
    if (lambda >= max(fit$lambda)) {
      lambda <- max(fit$lambda) * 0.999
    } else if (lambda <= min(fit$lambda)) {
      lambda <- min(fit$lambda) * 1.001
    }

    samples[i,] <- coef(fit, lambda = lambda)[-1]
  }

  lowers <- apply(samples, 2, function(x) quantile(x, (1 - level) / 2))
  uppers <- apply(samples, 2, function(x) quantile(x, 0.5 + level / 2))

  data.frame(variable = colnames(X), lower = lowers, upper = uppers)


}
