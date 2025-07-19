if (interactive()) {
  source("scripts/setup.R")
} else {
  source("code/scripts/setup.R")
}

set.seed(1234)

data <- read_data("whoari")
data$X <- std(data$X)


lambda <- cv.ncvreg(data$X, data$y, penalty = "lasso")$lambda.min

run_time <- system.time({
  res <- pipe_ncvreg(
    data$X, data$y, penalty = "lasso", level = 0.8,
    relaxed = TRUE, lambda = lambda
  )
})
res <- res %>%
  mutate(time = as.numeric(run_time)[3],
         method = "relaxed_lasso_posterior")

if (interactive()) {
  saveRDS(res, "rds/whoari_relaxed_lasso_posterior.rds")
} else {
  saveRDS(res, "code/rds/whoari_relaxed_lasso_posterior.rds")
}

