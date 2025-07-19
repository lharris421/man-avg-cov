if (interactive()) {
  source("scripts/setup.R")
} else {
  source("code/scripts/setup.R")
}

set.seed(1234)

data <- read_data("whoari")
data$X <- std(data$X)

lambda <- cv.ncvreg(data$X, data$y, penalty = "lasso")$lambda.min

suppressMessages({
  run_time <- system.time({
    res <- lp(data$X, data$y, alpha = 0.2, original = FALSE, lambda = lambda)
  })
})

res <- res %>%
  mutate(time = as.numeric(run_time)[3],
         method = "desparsified_lasso")

if (interactive()) {
  saveRDS(res, "rds/whoari_desparsified_lasso.rds")
} else {
  saveRDS(res, "code/rds/whoari_desparsified_lasso.rds")
}

