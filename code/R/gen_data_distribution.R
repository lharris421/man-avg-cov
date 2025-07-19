gen_data_distribution <- function(n = 100, p = 100,
                                  distribution = NULL,
                                  corr = c("exchangeable", "autoregressive"),
                                  family = c("gaussian", "binomial", "poisson"),
                                  rho = 0, SNR = 1, sigma = 1) {

  corr <- match.arg(corr)
  family <- match.arg(family)

  if (distribution == "laplace") {
    betas <- qlaplace((1:p) / (p + 1), rate = 1)
  } else if (distribution == "normal") {
    betas <- qnorm((1:p) / (p + 1), sd = 1)
  } else if (distribution == "t") {
    betas <- qt((1:p) / (p + 1), df = 4)
  } else if (distribution == "uniform") {
    betas <- qunif((1:p) / (p + 1), -1, 1)
  } else if (distribution == "beta") {
    betas <- qbeta((1:p) / (p + 1),  .1, .1) - .5
  } else if (distribution == "sparse 1") {
    betas <- c(rep(c(rep(0.5, 3), 1, 2), 2) * c(rep(1, 5), rep(-1, 5)), rep(0, 91))
  } else if (distribution == "sparse 2") {
    betas <- c(qnorm((1:31) / 32, sd = 1), rep(0, 70))
  } else if (distribution == "sparse 3") {
    betas <- c(qnorm((1:51) / 52, sd = 1), rep(0, 50))
  }

  gen_data_sigma(
    n = n, p = p, beta = betas, family = family,
    SNR = SNR, sigma = sigma, corr = corr, rho = rho
  )

}

