library(optparse)
option_list <- list(
  make_option(c("--iterations"), type="integer", default=1000),
  make_option(c("--alpha"), type="integer", default=5)
)
opt <- parse_args(OptionParser(option_list=option_list))
iterations <- opt$iterations
alpha <- opt$alpha

if (interactive()) {
  source("scripts/setup.R")
} else {
  source("./code/scripts/setup.R")
}

for (i in 1:length(methods)) {
  methods[[i]]$method_arguments["alpha"] <- alpha / 100
}

res_list <- readRDS(glue("{rds_dir}/{alpha}/{iterations}/across_lambda_coverage.rds"))

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

saveRDS(model_cov, glue("{rds_dir}/{alpha}/{iterations}/across_lambda_gam.rds"))
