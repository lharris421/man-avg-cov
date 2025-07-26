if (interactive()) {
  source("scripts/setup.R")
} else {
  source("code/scripts/setup.R")
}

option_list <- list(
  make_option(c("--iterations"), type="integer", default=1000),
  make_option(c("--seed"), type="double", default=1234),
  make_option(c("--n"), type="integer", default=50),
  make_option(c("--p"), type="integer", default=101),
  make_option(c("--sigma"), type="integer", default=10),
  make_option(c("--snr"), type="integer", default=100),
  make_option(c("--distribution"), type="character", default="laplace"),
  make_option(c("--method"), type="character", default="rlp"),
  make_option(c("--corr"), type="character", default="exchangeable"),
  make_option(c("--rho"), type="double", default=0),
  make_option(c("--loc"), type="character", default="")
)
opt <- parse_args(OptionParser(option_list=option_list))
iterations <- opt$iterations
set.seed(opt$seed)
method_name <- opt$method

res <- readRDS(glue("{opt$loc}rds/{iterations}/original/{opt$distribution}_{opt$corr}_{opt$rho}_{opt$n}_{opt$p}_{opt$sigma}_{opt$snr}_{method_name}.rds"))

model_res     <- calculate_model_results(res)
cutoff        <- max(model_res$truth)
xs            <- seq(-cutoff, cutoff, by = 0.01)
res           <- predict_covered(model_res, xs) %>%
                    mutate(
                      average_coverage = mean(model_res$covered, na.rm = TRUE),
                      n = opt$n, distribution = opt$distribution, p = opt$p,
                      corr = opt$corr, rho = opt$rho, sigma = opt$sigma,
                      snr = opt$snr, method = method_name
                    )

saveRDS(res, glue("{opt$loc}rds/{iterations}/gam/{opt$distribution}_{opt$corr}_{opt$rho}_{opt$n}_{opt$p}_{opt$sigma}_{opt$snr}_{method_name}.rds"))

