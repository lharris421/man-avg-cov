## Packages. Listed as literal library() calls so renv::dependencies() can see
## them; renv.lock is generated from this list.
suppressPackageStartupMessages({
  library(ncvreg)
  library(hdrm)
  library(hdi)
  library(selectiveInference)
  library(glmnet)
  library(dplyr)
  library(tidyr)
  library(purrr)
  library(stringr)
  library(ggplot2)
  library(glue)
  library(kableExtra)
  library(patchwork)
  library(mgcv)
  library(progress)
  library(optparse)
  library(grid)
  library(scales)
  library(ggstance)
})

## Rmpfr is optional for selectiveInference::fixedLassoInf (high-precision
## p-values). It is loaded, not attached, so that renv records it in the lockfile.
invisible(requireNamespace("Rmpfr", quietly = TRUE))

## Keep dplyr from narrating summarise() regrouping.
options(dplyr.summarise.inform = FALSE)

## Quiet mode (AVGCOV_QUIET is set by the Snakefile for `quiet: true` or -q):
## drop messages and warnings so that only progress bars print. Errors still
## stop the script as usual. Progress bars are signalled as messages too, so
## the simulation scripts tag theirs with message_class = "avgcov_progress"
## and the handler lets that class through.
if (nzchar(Sys.getenv("AVGCOV_QUIET"))) {
  globalCallingHandlers(
    message = function(m) if (!inherits(m, "avgcov_progress")) invokeRestart("muffleMessage"),
    warning = function(w) invokeRestart("muffleWarning")
  )
}

## Directory locations. Interactive sessions are run from code/; Snakemake runs
## from the repository root.
if (interactive()) {
  pkg_dir  <- "."
  rds_dir  <- "./rds"
  data_dir <- "../data"
} else {
  pkg_dir  <- "./code"
  rds_dir  <- "./code/rds"
  data_dir <- "./data"
}

## Load the package functions in code/R (gen_data_*, posterior_intervals, dlaplace, ...)
pkgload::load_all(pkg_dir, quiet = TRUE)

method_labels <- c(
  "selectiveinferenceS" = "Selective Inference",
  "desparsified"       = "Desparsified Lasso",
  "ridge"              = "Ridge Posterior",
  "pipep"              = "PIPE Posterior",
  "pipepmcp"           = "PIPE Posterior (MCP)"
)
methods <- list(
  "ridge"              = list(method = "ridge_fit", method_arguments = list()),
  "selectiveinferenceS" = list(method = "selective_inference", method_arguments = list(estimate_sigma = TRUE)),
  "desparsified"       = list(method = "lp", method_arguments = list()),
  "pipep"              = list(method = "posterior_intervals", method_arguments = list(penalty = "lasso")),
  "pipepmcp"           = list(method = "posterior_intervals", method_arguments = list(penalty = "MCP"))
)

## Plot colors
colors <- palette()[c(2, 4, 3, 6, 7, 5)]
sec_colors <- c("black", "grey62")
background_colors <- c("#E2E2E2", "#F5F5F5")
