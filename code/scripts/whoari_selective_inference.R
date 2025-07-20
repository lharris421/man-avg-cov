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

data <- read_data("whoari")
data$X <- std(data$X)


lambda <- cv.ncvreg(data$X, data$y, penalty = "lasso")$lambda.min

run_time <- system.time({
  res <- selective_inference(data$X, data$y, alpha = 0.2, lambda = lambda)
})
res <- res %>%
  mutate(time = as.numeric(run_time)[3],
         method = "selective_inference")

if (interactive()) {
  saveRDS(res, "rds/whoari_selective_inference.rds")
} else {
  saveRDS(res, "code/rds/whoari_selective_inference.rds")
}

