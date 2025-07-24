# Clear enviornment
rm(list=ls())

packages <- c(
  "ncvreg", "hdrm", "hdi", "selectiveInference", "glmnet",
  "dplyr", "tidyr", "purrr", "stringr", "ggplot2", "glue",
  "kableExtra", "patchwork", "mgcv", "progress", "optparse",
  "grid"
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
  "selectiveinference"         = "Selective Inference",
  "desparsified_lasso"          = "Desparsified Lasso",
  "desparsified_lasso_original" = "Desparsified Lasso (original)",
  "ridge"                       = "Ridge Posterior",
  "ridgeT"                      = "Ridge Posterior",
  "ridgeboot"                   = "Ridge Bootstrap",
  "ridgebootT"                  = "Ridge Bootstrap",
  "rlp"                         = "Relaxed Lasso Posterior",
  "relaxed_MCP_posterior"       = "Relaxed MCP Posterior",
  "traditional_bootstrap"       = "Traditional Bootstrap"
)
methods <- list(
  "rlp" = list(method = "posterior_intervals", method_arguments = list(relaxed = TRUE, penalty = "lasso")),
  "ridgeT" = list(method = "ridge_fit", method_arguments = list(lambda = 0.4)),
  "ridge" = list(method = "ridge_fit", method_arguments = list()),
  "ridgebootT" = list(method = "ridge_bootstrap_ci", method_arguments = list(lambda = 0.4, B = 100)),
  "selectiveinference" = list(method = "selective_inference", method_arguments = list())
)
for (i in 1:length(methods)) {
  methods[[i]]$method_arguments["alpha"] <- 0.2
}
