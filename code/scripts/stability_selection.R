if (interactive()) {
  source("scripts/setup.R")
} else {
  source("code/scripts/setup.R")
}

option_list <- list(
  make_option(c("--iterations"), type="integer", default=1000),
  make_option(c("--seed"), type="double", default=1234),
  make_option(c("--loc"), type="character", default="")
)
opt <- parse_args(OptionParser(option_list=option_list))
iterations <- opt$iterations
set.seed(opt$seed)

pb <- progress_bar$new(
  format = "  [:bar] :percent (:current/:total) | eta: :eta",
  total  = iterations, clear = FALSE, width = 60
)

orig_sel <- matrix(nrow = iterations, ncol = 4)
boot_sel <- matrix(nrow = iterations, ncol = 4)
for (i in 1:iterations) {

  dat <- gen_data(n = 50, p = 500, beta = c(0.25, 0.5, 1, 2, rep(0, 496)))

  lasso_cv <- cv.ncvreg(dat$X, dat$y, penalty = "lasso")
  lasso_lambda <- lasso_cv$lambda.min
  orig_sel[i,] <- coef(lasso_cv)[2:5] != 0

  boot_sel_tmp <- matrix(nrow = iterations, ncol = 4)
  for (j in 1:iterations) {
    b <- sample.int(nrow(dat$X), replace = TRUE)
    Xb <- dat$X[b,,drop=FALSE]
    yb <- dat$y[b]
    init <- ncvreg(Xb, yb, lambda = lasso_cv$lambda, penalty = "lasso")
    boot_sel_tmp[j,] <- coef(init, lambda = lasso_lambda)[2:5] != 0
  }
  boot_sel[i,] <- colMeans(boot_sel_tmp)

  pb$tick()


}

saveRDS(list("orig" = orig_sel, "boot" = boot_sel), glue("{opt$loc}rds/{iterations}/stability_selection.rds"))
