if (interactive()) {
  source("scripts/setup.R")
  results_rlp <- readRDS("rds/Scheetz2006_relaxed_lasso_posterior.rds")
  results_si  <- readRDS("rds/Scheetz2006_selective_inference.rds")
  results_dl  <- readRDS("rds/Scheetz2006_desparsified_lasso.rds")
} else {
  source("code/scripts/setup.R")
  results_rlp <- readRDS("code/rds/Scheetz2006_relaxed_lasso_posterior.rds")
  results_si  <- readRDS("code/rds/Scheetz2006_selective_inference.rds")
  results_dl  <- readRDS("code/rds/Scheetz2006_desparsified_lasso.rds")
}

results <- bind_rows(
  results_rlp,
  results_si,
  results_dl
) %>%
  mutate(method = method_labels[method],
         estimate = ifelse(method == "Relaxed Lasso Posterior", coef, estimate))

if (interactive()) {
  pdf("out/figure9.pdf", height = 4, width = 8)
} else {
  pdf("code/out/figure9.pdf", height = 4, width = 8)
}
plot_ci_comparison(results, nvars = 30, ref = "Relaxed Lasso Posterior")
dev.off()
