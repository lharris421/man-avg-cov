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

res_dir <- "code/"
devtools::load_all(res_dir, quiet = TRUE)

method_labels <- c(
  "selectiveinference" = "Selective Inference",
  "desparsified"       = "Desparsified Lasso",
  "desparsified0"      = "Desparsified Lasso",
  "ridge"              = "Ridge Posterior",
  "ridgeT"             = "Ridge Posterior",
  "ridgeboot"          = "Ridge Bootstrap",
  "ridgebootT"         = "Ridge Bootstrap",
  "rlp"                = "Relaxed Lasso Posterior",
  "rmp"                = "Relaxed MCP Posterior",
  "traditional"        = "Traditional Bootstrap",
  "pipep"              = "PIPE Posterior",
  "lqap"               = "LQA Posterior",
  "rl"                 = "Relaxed Lasso"
)
methods <- list(
  "rlp"                = list(method = "posterior_intervals", method_arguments = list(relaxed = TRUE, penalty = "lasso")),
  "rmp"                = list(method = "posterior_intervals", method_arguments = list(relaxed = TRUE, penalty = "MCP")),
  "ridgeT"             = list(method = "ridge_fit", method_arguments = list(lambda = 0.4)),
  "ridge"              = list(method = "ridge_fit", method_arguments = list()),
  "ridgebootT"         = list(method = "ridge_bootstrap_ci", method_arguments = list(lambda = 0.4, B = 1000)),
  "ridgewlbT"          = list(method = "ridge_bayes_boot", method_arguments = list(lambda = 0.4, B = 1000)),
  "selectiveinference" = list(method = "selective_inference", method_arguments = list()),
  "desparsified"       = list(method = "lp", method_arguments = list()),
  "desparsified0"      = list(method = "lp", method_arguments = list(original = TRUE)),
  "traditional"        = list(method = "traditional_bootstrap", method_arguments = list()),
  "pipep"              = list(method = "posterior_intervals", method_arguments = list(penalty = "lasso")),
  "pipepscad"          = list(method = "posterior_intervals", method_arguments = list(penalty = "SCAD")),
  "pipepmcp"           = list(method = "posterior_intervals", method_arguments = list(penalty = "MCP")),
  "pipepbinom"         = list(method = "posterior_intervals", method_arguments = list(penalty = "lasso", family = "binomial")),
  "pipeppois"          = list(method = "posterior_intervals", method_arguments = list(penalty = "lasso", family = "poisson")),
  "pipepenet"          = list(method = "posterior_intervals", method_arguments = list(penalty = "lasso", enet_alpha = 0.8)),
  "lqap"               = list(method = "posterior_intervals", method_arguments = list(adjust_projection = TRUE, penalty = "lasso")),
  "lqapscad"           = list(method = "posterior_intervals", method_arguments = list(adjust_projection = TRUE, penalty = "SCAD")),
  "lqapmcp"            = list(method = "posterior_intervals", method_arguments = list(adjust_projection = TRUE, penalty = "MCP")),
  "lqapbinom"          = list(method = "posterior_intervals", method_arguments = list(adjust_projection = TRUE, penalty = "lasso", family = "binomial")),
  "lqappois"           = list(method = "posterior_intervals", method_arguments = list(adjust_projection = TRUE, penalty = "lasso", family = "poisson")),
  "lqapenet"           = list(method = "posterior_intervals", method_arguments = list(adjust_projection = TRUE, penalty = "lasso", enet_alpha = 0.8)),
  "rl"                 = list(method = "relaxed_lasso_trad", method_arguments = list())
)
for (i in 1:length(methods)) {
  methods[[i]]$method_arguments["alpha"] <- 0.2
}

## Plot colors
colors <- palette()[c(2, 4, 3, 6, 7, 5)]
sec_colors <- c("black", "grey62")
background_colors <- c("#E2E2E2", "#F5F5F5")
