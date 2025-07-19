if (interactive()) {
  source("scripts/setup.R")
} else {
  source("code/scripts/setup.R")
}

set.seed(1234)

data <- read_data("Scheetz2006")

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
  saveRDS(res, "rds/Scheetz2006_desparsified_lasso.rds")
} else {
  saveRDS(res, "code/rds/Scheetz2006_desparsified_lasso.rds")
}

