## Setup
#!/usr/bin/env Rscript
suppressPackageStartupMessages({
  library(optparse)
  source("./scripts/setup.R")    # sets up `methods`, etc.
})


## ------------------ Command‑line interface ------------------
opt_list <- list(
  make_option(c("-s", "--seed"),       type = "integer", default = 1234),
  make_option(c("-i", "--iterations"), type = "integer", default = 100),
  make_option(c("--true_lambda"),      action = "store_true", default = FALSE),
  make_option(c("--true_sigma"),       action = "store_true", default = FALSE),
  make_option(c("--same_lambda"),      action = "store_true", default = FALSE),
  make_option(c("-d", "--distribution"), default = "laplace"),
  make_option(c("-n", "--n"),          type = "integer", default = 100),
  make_option(c("-p", "--p"),          type = "integer", default = 101),
  make_option(c("--sigma"),            type = "double",  default = 10),
  make_option(c("--snr"),              type = "double",  default = 1),
  make_option(c("--fixed"),            action = "store_true", default = TRUE),
  make_option(c("--rho"),              type = "double",  default = 0),
  make_option(c("--corr"),             type = "character",  default = "exchangeable"),
  make_option(c("--method"),           default = "relaxed_lasso_posterior")
)

params <- parse_args(OptionParser(option_list = opt_list))

## ------------------ Convenience objects ------------------
simulation_function  <- "gen_data_distribution"
method_key           <- params$method
method_function      <- methods[[method_key]]$method
method_arguments     <- methods[[method_key]]$method_arguments

simulation_arguments <- list(
  distribution = params$distribution,
  n   = params$n,
  p   = params$p,
  sigma = params$sigma,
  SNR   = params$snr,
  fixed = params$fixed,
  rho   = params$rho,
  corr  = params$corr
)

## ------------------ Main routine ------------------
## ------------------ Main routine ------------------
run_sim <- function() {

  # initialize counters
  covered_count <- 0
  total_count   <- 0

  # add a :coverage token to the format
  pb <- progress_bar$new(
    format = "  [:bar] :percent (:current/:total) | cov: :coverage | eta: :eta",
    total  = params$iterations, clear = FALSE, width = 60
  )

  set.seed(params$seed)
  seeds <- sample.int(.Machine$integer.max, params$iterations)

  res <- vector("list", params$iterations)

  for (i in seq_len(params$iterations)) {
    set.seed(seeds[i])
    data <- do.call(simulation_function, simulation_arguments)

    ## choose lambda / sigma according to flags -----------------
    lambda <- NULL; sigma <- NULL
    if (params$same_lambda) {
      lambda <- cv.ncvreg(data$X, data$y, penalty = "lasso")$lambda.min
    } else if (params$true_lambda) {
      lambda <- params$sigma * sqrt(2 * params$p) / params$n
    }
    if (params$true_sigma) sigma <- params$sigma

    ## run method ----------------------------------------------
    base_args <- list(X = data$X, y = data$y)
    if (!is.null(lambda)) base_args$lambda <- lambda
    if (!is.null(sigma))  base_args$sigma  <- sigma

    t <- system.time({
      results <- do.call(method_function, c(base_args, method_arguments))
    })

    ## post‑processing -----------------------------------------
    res[[i]] <- results |>
      mutate(iteration = i,
             method    = method_key,
             time      = t["elapsed"])

    if (!is.null(data$beta)) {
      truth_df <- tibble(
        variable = names(data$beta),
        truth    = data$beta
      )

      this_res <- left_join(res[[i]], truth_df, by = "variable") %>%
        mutate(covered = lower <= truth & truth <= upper)

      # update counters
      covered_count <- covered_count + sum(this_res$covered, na.rm = TRUE)
      total_count   <- total_count   + nrow(this_res)

      # compute rolling coverage
      rolling_cov <- covered_count / total_count

      res[[i]] <- this_res
    } else {
      rolling_cov <- NA_real_
    }

    # tick with the new token
    pb$tick(tokens = list(coverage = sprintf("%.3f", rolling_cov)))
  }

  bind_rows(res)
}


## ------------------ Execute & persist ------------------
results <- run_sim()

parameter_list <- list(
  seed        = params$seed,
  iterations  = params$iterations,
  true_lambda = params$true_lambda,
  true_sigma  = params$true_sigma,
  same_lambda = params$same_lambda,
  simulation_function = simulation_function,
  simulation_arguments = simulation_arguments,
  method_function      = method_function,
  method_arguments     = method_arguments
)

# Create dir if absent
if (!dir.exists("rds")) dir.create("rds", recursive = TRUE)
indexr::save_objects("./rds", results, parameters_list = parameter_list,
                     overwrite = TRUE)

quit(save = "no", status = 0)
