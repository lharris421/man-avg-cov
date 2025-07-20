library(optparse)
option_list <- list(
  make_option(c("--iterations"), type="integer", default=1000),
  make_option(c("-d", "--desparsified"), action="store_true", default=FALSE)
)
opt <- parse_args(OptionParser(option_list=option_list))
iterations <- opt$iterations
desparsified <- opt$desparsified

if (interactive()) {
  source("scripts/setup.R")
  results_rlp <- readRDS("rds/{iterations}/Scheetz2006_relaxed_lasso_posterior.rds")
  results_si  <- readRDS("rds/{iterations}/Scheetz2006_selective_inference.rds")
  if (desparsified) results_dl  <- readRDS("rds/{iterations}/Scheetz2006_desparsified_lasso.rds")
} else {
  source("code/scripts/setup.R")
  results_rlp <- readRDS("code/rds/{iterations}/Scheetz2006_relaxed_lasso_posterior.rds")
  results_si  <- readRDS("code/rds/{iterations}/Scheetz2006_selective_inference.rds")
  if (desparsified) results_dl  <- readRDS("code/rds/{iterations}/Scheetz2006_desparsified_lasso.rds")
}

results <- bind_rows(
  results_rlp,
  results_si
)

if (desparsified) results <- results %>% bind_rows(results_dl)

results <- results %>%
  mutate(method = method_labels[method],
         estimate = ifelse(method == "Relaxed Lasso Posterior", coef, estimate))

if (interactive()) {
  pdf("out/figure9.pdf", height = 4, width = 8)
} else {
  pdf("code/out/figure9.pdf", height = 4, width = 8)
}
plot_ci_comparison(results, nvars = 30, ref = "Relaxed Lasso Posterior")
dev.off()
