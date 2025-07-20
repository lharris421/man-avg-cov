if (interactive()) {
  source("scripts/setup.R")
} else {
  source("code/scripts/setup.R")
}

option_list <- list(
  make_option(c("--seed"), type="double", default=1234)
)
opt <- parse_args(OptionParser(option_list=option_list))
set.seed(opt$seed)

data <- read_data("Scheetz2006")

cv_fit <- cv.ncvreg(data$X, data$y, penalty = "lasso")

run_time <- system.time({
  res <- confidence_intervals(cv_fit, level = 0.8, relaxed = TRUE)
})
res <- res %>%
  mutate(time = as.numeric(run_time)[3],
         method = "relaxed_lasso_posterior")

if (interactive()) {
  saveRDS(res, "rds/Scheetz2006_relaxed_lasso_posterior.rds")
} else {
  saveRDS(res, "code/rds/Scheetz2006_relaxed_lasso_posterior.rds")
}


