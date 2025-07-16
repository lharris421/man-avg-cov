# Clear enviornment
rm(list=ls())

devtools::load_all(quiet = TRUE)

packages <- c(
  "dplyr", "tidyr", "ggplot2", "gridExtra", "scales", "kableExtra",
  "grid", "glue", "patchwork", "knitr", "mgcv", "gt", "purrr", "stringr",
  "selectiveInference", "glmnet", "progress", "loo",
  "ncvreg", "hdi", "hdrm"
)
quietlyLoadPackage <- function(package) {
  suppressPackageStartupMessages(library(package, character.only = TRUE))
}
lapply(packages, quietlyLoadPackage)

colors <- palette()[c(2, 4, 3, 6, 7, 5)]
sec_colors <- c("black", "grey62")
background_colors <- c("#E2E2E2", "#F5F5F5")

methods <- list(
  "selective_inference" = list(method = "selective_inference", method_arguments = list()),
  "lasso_proj" = list(method = "lp", method_arguments = list()),
  "lasso_proj_original" = list(method = "lp", method_arguments = list(original = TRUE)),
  "ridge" = list(method = "ridge_fit", method_arguments = list()),
  "ridge_boot" = list(method = "ridge_bootstrap_ci", method_arguments = list()),
  "relaxed_lasso_posterior"  = list(method = "pipe_ncvreg", method_arguments = list(relaxed = TRUE, penalty = "lasso")),
  "relaxed_mcp_posterior"  = list(method = "pipe_ncvreg", method_arguments = list(relaxed = TRUE, penalty = "MCP"))
)
method_labels <- c(
  "selective_inference" = "Selective Inference",
  "lasso_proj" = "Desparsified Lasso",
  "lasso_proj_original" = "Desparsified Lasso (original)",
  "ridge" = "Ridge Posterior",
  "ridge_boot" = "Ridge Bootstrap",
  "relaxed_lasso_posterior"  = "Relaxed Lasso Posterior",
  "relaxed_mcp_posterior"  = "Relaxed MCP Posterior"
)
for (i in 1:length(methods)) {
  methods[[i]]$method_arguments["level"] <- 0.8
}
