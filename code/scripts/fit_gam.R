library(optparse)
option_list <- list(
  make_option(c("--alpha"), type="integer", default=5),
  make_option(c("--iterations"), type="integer", default=1000),
  make_option(c("--seed"), type="double", default=1234),
  make_option(c("--n"), type="integer", default=50),
  make_option(c("--p"), type="integer", default=101),
  make_option(c("--family"), type="character", default="gaussian"),
  make_option(c("--snr"), type="integer", default=100),
  make_option(c("--distribution"), type="character", default="laplace"),
  make_option(c("--method"), type="character", default="rlp"),
  make_option(c("--corr"), type="character", default="exchangeable"),
  make_option(c("--rho"), type="double", default=0)
)
opt <- parse_args(OptionParser(option_list=option_list))
iterations <- opt$iterations
alpha <- opt$alpha
set.seed(opt$seed)
method_name <- opt$method

if (interactive()) {
  source("scripts/setup.R")
} else {
  source("./code/scripts/setup.R")
}

for (i in 1:length(methods)) {
  methods[[i]]$method_arguments["alpha"] <- alpha / 100
}

res <- readRDS(glue("{rds_dir}/{alpha}/{iterations}/original/{opt$distribution}_{opt$corr}_{opt$rho}_{opt$n}_{opt$p}_{opt$family}_{opt$snr}_{method_name}.rds"))

model_res     <- calculate_model_results(res)
cutoff        <- max(model_res$truth)
xs            <- seq(-cutoff, cutoff, by = 0.01)
res           <- predict_covered(model_res, xs) %>%
                    mutate(
                      average_coverage = mean(model_res$covered, na.rm = TRUE),
                      n = opt$n, distribution = opt$distribution, p = opt$p,
                      corr = opt$corr, rho = opt$rho, family = opt$family,
                      snr = opt$snr, method = method_name
                    )

saveRDS(res, glue("{rds_dir}/{alpha}/{iterations}/gam/{opt$distribution}_{opt$corr}_{opt$rho}_{opt$n}_{opt$p}_{opt$family}_{opt$snr}_{method_name}.rds"))

