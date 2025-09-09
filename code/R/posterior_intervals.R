posterior_intervals <- function(
    X, y, fit, lambda, sigma,
    family = "gaussian",
    penalty = "lasso",
    gamma = switch(penalty, SCAD = 3.7, 3),
    enet_alpha = 1, alpha = 0.05,
    posterior = TRUE, relaxed = FALSE,
    adjust_projection = FALSE
) {

  if (missing(fit)) {
    fit <- cv.ncvreg(X = X, y = y, family = family, penalty = penalty,
                     gamma = gamma, alpha = enet_alpha)
  }
  res <- ncvreg::intervals(
    fit, lambda = lambda, sigma = sigma,
    level = 1 - alpha,
    posterior = posterior, relaxed = relaxed,
    adjust_projection = adjust_projection
  )

  return(res)

}
