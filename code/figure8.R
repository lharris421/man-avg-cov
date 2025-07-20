if (interactive()) {
  source("scripts/setup.R")
} else {
  source("code/scripts/setup.R")
}

option_list <- list(
  make_option(c("-d", "--desparsified"), action="store_true", default=FALSE)
)
opt <- parse_args(OptionParser(option_list=option_list))
desparsified <- opt$desparsified

if (interactive()) {
  results_rlp <- readRDS(glue("rds/whoari_relaxed_lasso_posterior.rds"))
  results_si  <- readRDS(glue("rds/whoari_selective_inference.rds"))
  if (desparsified) results_dl  <- readRDS(glue("rds/whoari_desparsified_lasso.rds"))
} else {
  results_rlp <- readRDS(glue("code/rds/whoari_relaxed_lasso_posterior.rds"))
  results_si  <- readRDS(glue("code/rds/whoari_selective_inference.rds"))
  if (desparsified) results_dl  <- readRDS(glue("code/rds/whoari_desparsified_lasso.rds"))
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
  pdf("out/figure8.pdf", height = 6.5, width = 8)
} else {
  pdf("code/out/figure8.pdf", height = 6.5, width = 8)
}
plot_ci_comparison(results, nvars = 66, ref = "Relaxed Lasso Posterior")
dev.off()
