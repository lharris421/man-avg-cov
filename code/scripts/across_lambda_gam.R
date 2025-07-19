if (interactive()) {
  source("scripts/setup.R")
  res_list <- readRDS("rds/across_lambda_coverage.rds")
} else {
  source("code/scripts/setup.R")
  res_list <- readRDS("code/rds/across_lambda_coverage.rds")
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
  saveRDS(model_cov, "rds/across_lambda_gam.rds")
} else {
  saveRDS(model_cov, "code/rds/across_lambda_gam.rds")
}
