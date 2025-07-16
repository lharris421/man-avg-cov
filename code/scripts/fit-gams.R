#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(optparse)
  source("./scripts/setup.R")    # defines `methods`, `calculate_model_results()`, `predict_covered()`, etc.
})

option_list <- list(
  make_option(c("-s","--seed"),               type="integer", default=1234),
  make_option(c("-i","--iterations"),         type="integer", default=1000),
  make_option(c("--p"),                       type="integer", default=101),
  make_option(c("--SNR"),                     type="double",  default=1),
  make_option(c("--sigma"),                   type="double",  default=10),
  make_option(c("--fixed"),                   action="store_true", default=TRUE),
  make_option(c("--simulation_function"),     type="character", default="gen_data_distribution"),
  make_option(c("--script_name"),             type="character", default="distributions"),
  make_option(c("--methods"),                 type="character", default="lasso_adj",
              help="Comma‑sep’d names of methods (must exist in `methods`)"),
  make_option(c("--ns"),                      type="character", default="50,100,400",
              help="Comma‑sep’d vector of sample sizes"),
  make_option(c("--distributions"),           type="character", default="laplace",
              help="Comma‑sep’d vector of distribution names")
)

opt <- parse_args(OptionParser(option_list=option_list))

# parse comma‑sep’d args into vectors
methods_vec       <- strsplit(opt$methods, ",")[[1]]
ns_vec            <- as.integer(strsplit(opt$ns, ",")[[1]])
dist_vec          <- strsplit(opt$distributions, ",")[[1]]

# build the initial simulation_info list
simulation_info <- list(
  seed                = opt$seed,
  iterations          = opt$iterations,
  simulation_function = opt$simulation_function,
  simulation_arguments= list(
    p     = opt$p,
    SNR   = opt$SNR,
    sigma = opt$sigma,
    fixed = opt$fixed
  ),
  script_name = opt$script_name
)

# subset the global `methods` object
methods <- methods[methods_vec]

# build all (method, n, distribution) combos
files <- expand.grid(
  method       = names(methods),
  n            = ns_vec,
  distribution = dist_vec,
  stringsAsFactors = FALSE
)

for (i in seq_len(nrow(files))) {
  this_method <- files$method[i]
  this_n      <- files$n[i]
  this_dist   <- files$distribution[i]

  # update sim args
  sim_info <- simulation_info
  sim_info$simulation_arguments$n            <- this_n
  sim_info$simulation_arguments$distribution <- this_dist

  # read in the previously saved simulation results
  results <- indexr::read_objects(
    "rds",
    c(methods[[this_method]], sim_info),
    print_hash = TRUE
  ) %>%
    mutate(
      method       = this_method,
      distribution = this_dist,
      n            = this_n
    )

  # compute coverage curve
  model_res     <- calculate_model_results(results)
  cutoff        <- max(model_res$truth)
  xs            <- seq(-cutoff, cutoff, by = 0.01)
  line_data     <- predict_covered(model_res, xs, this_method)
  line_data_avg <- mean(model_res$covered, na.rm = TRUE)

  # save under the new script_name
  save_info <- sim_info

  indexr::save_objects(
    "rds",
    list(line_data = line_data, line_data_avg = line_data_avg),
    parameters_list = c(methods[[this_method]], save_info),
    overwrite = TRUE
  )
}
