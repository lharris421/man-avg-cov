rlaplace <- function(n, rate = 1) {
  rexp(n, rate) * sample(c(-1, 1), n, replace = TRUE)
}
dlaplace <- function(x, rate = 1) {
  # dexp(abs(x), rate) / 2
  exp(-abs(x) * rate)
}
qlaplace <- function(p, rate = 1) {
  suppressWarnings(
    ifelse(p < 0.5, -qexp(1 - 2*p, rate), qexp((p - 0.5) * 2, rate))
  )
}
