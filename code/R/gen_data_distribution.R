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
  } else if (distribution == "sparse1") {
    betas <- c(rep(c(rep(0.5, 3), 1, 2), 2) * c(rep(1, 5), rep(-1, 5)), rep(0, 91))
  } else if (distribution == "sparse2") {
    betas <- c(qnorm((1:31) / 32, sd = 1), rep(0, 70))
  } else if (distribution == "sparse3") {
    betas <- c(qnorm((1:51) / 52, sd = 1), rep(0, 50))
  }

  gen_data_sigma(
    n = n, p = p, beta = betas, family = family,
    SNR = SNR, sigma = sigma, corr = corr, rho = rho
  )

}
gen_data_sigma <- function(n, p, beta,
                           family=c("gaussian","binomial","poisson"),
                           SNR=1, sigma = 1,
                           corr=c("exchangeable", "autoregressive"), rho = 0) {

  family <- match.arg(family)
  corr <- match.arg(corr)

  # Gen X
  X <- gen_x(n, p, rho, corr)

  if (family == "gaussian") {
    beta <- (beta / sqrt(drop(crossprod(beta)))) * sqrt(SNR) * sigma
  } else {
    beta <- scale_beta_fixed(beta, SNR, family = family)
  }

  # Gen y
  y <- gen_y(X%*%beta, family=family, sigma=sigma)

  # Label and return
  w <- 1 + floor(log10(p))
  vlab <- paste0('V', formatC(1:p, format='d', width=w, flag='0'))
  colnames(X) <- names(beta) <- vlab
  list(X=X, y=y, beta=beta, family=family)
}
gen_x <- function(n, p, rho, corr=c('exchangeable', 'autoregressive')) {
  corr <- match.arg(corr)
  if (corr == 'exchangeable') {
    z <- rnorm(n)
    sqrt(rho)*z + sqrt(1-rho) * matrix(rnorm(n*p), n, p)
  } else if (corr == 'autoregressive') {
    Z <- cbind(rnorm(n), matrix(rnorm(n*(p-1), sd=sqrt(1-rho^2)), n, p-1))
    apply(Z, 1, stats::filter, filter=rho, method='recursive') |> t()
  }
}
calc_bsb <- function(b, rho, corr) {
  if (corr == 'exchangeable') {
    sum(rho*tcrossprod(b)) + (1-rho)*crossprod(b) |> drop()
  } else if (corr == 'autoregressive') {
    out <- crossprod(b)
    bb <- tcrossprod(b)
    for (j in 1:min(10, length(b)-1)) {
      out <- out + 2 * rho^j * sum(Matrix::band(bb, j, j))
    }
    drop(out)
  }
}
gen_y <- function(eta, family = c("gaussian", "binomial", "poisson"), sigma = 1) {
  family <- match.arg(family)
  n <- length(eta)
  if (family == "gaussian") {
    rnorm(n, mean = eta, sd = sigma)
  } else if (family == "binomial") {
    pi. <- 1 / (1 + exp(-eta))
    pi.[eta > log(.9999 / .0001)] <- 1
    pi.[eta < log(.0001 / .9999)] <- 0
    rbinom(n, 1, pi.)
  } else if (family == "poisson") {
    mu <- exp(eta)
    rpois(n, lambda = mu)
  }
}
scale_beta_fixed <- function(beta0,
                             snr_target,
                             family = c("binomial", "poisson")) {
  family <- match.arg(family)
  stopifnot(snr_target > 0, is.numeric(beta0))

  sigma2_latent <- if (family == "binomial") pi^2 / 3 else 1
  target_var    <- snr_target * sigma2_latent
  k             <- sqrt(target_var / sum(beta0^2))

  k * beta0                          # scaled β to keep forever
}


