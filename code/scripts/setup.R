# Clear enviornment
rm(list=ls())

packages <- c(
  "ncvreg", "hdrm", "hdi", "dplyr", "tidyr", "ggplot2", "gridExtra", "scales",
  "kableExtra", "grid", "glue", "patchwork", "knitr", "mgcv", "purrr", "stringr",
  "selectiveInference", "glmnet", "progress", "loo"
)
quietlyLoadPackage <- function(package) {
  suppressPackageStartupMessages(library(package, character.only = TRUE))
}
lapply(packages, quietlyLoadPackage)

if (interactive()) {
  devtools::load_all(quiet = TRUE)
} else {
  devtools::load_all(path = "code", quiet = TRUE)
}

colors <- palette()[c(2, 4, 3, 6, 7, 5)]
sec_colors <- c("black", "grey62")
background_colors <- c("#E2E2E2", "#F5F5F5")

method_labels <- c(
  "selective_inference"         = "Selective Inference",
  "desparsified_lasso"          = "Desparsified Lasso",
  "desparsified_lasso_original" = "Desparsified Lasso (original)",
  "ridge"                       = "Ridge Posterior",
  "ridge_boot"                  = "Ridge Bootstrap",
  "relaxed_lasso_posterior"     = "Relaxed Lasso Posterior",
  "relaxed_mcp_posterior"       = "Relaxed MCP Posterior",
  "traditional_bootstrap"       = "Traditional Bootstrap"
)
