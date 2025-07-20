if (interactive()) {
  source("scripts/setup.R")
} else {
  source("code/scripts/setup.R")
}

option_list <- list(
  make_option(c("--iterations"), type="integer", default=1000)
)
opt <- parse_args(OptionParser(option_list=option_list))
iterations <- opt$iterations

if (interactive()) {
  res_list <- readRDS(glue("rds/{iterations}/across_lambda_coverage.rds"))
} else {
  res_list <- readRDS(glue("code/rds/{iterations}/across_lambda_coverage.rds"))
}

lambdas <- res_list$lambdas
res <- res_list$res
lambda_maxs <- res %>% group_by(group) %>% filter(row_number() == 1) %>% pull(lambda_max)

pdat <- res %>%
  dplyr::mutate(covered = truth >= lower & truth <= upper,
                group = as.factor(group),
                lambda = round(lambda / lambda_max, 3),
                truth = abs(truth))

lambda_cov <- pdat %>%
  group_by(group, lambda) %>%
  summarise(off_coverage = abs(mean(covered) - .8)) %>%
  arrange(off_coverage) %>%
  summarise(lambda = first(lambda)) %>%
  pull(lambda) %>%
  median()

# Fit a binomial model with the transformed lambda
model_cov <- gam(covered ~ te(lambda, truth), data = pdat, family = binomial)

if (interactive()) {
  saveRDS(model_cov, glue("rds/{iterations}/across_lambda_gam.rds"))
} else {
  saveRDS(model_cov, glue("code/rds/{iterations}/across_lambda_gam.rds"))
}
