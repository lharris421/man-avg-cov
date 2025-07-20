if (interactive()) {
  source("scripts/setup.R")
} else {
  source("code/scripts/setup.R")
}

lookup <- data.frame(
  p = c(20, 100, 200),
  SNR = c(0.188649, 1.15345, 2.387699)
)

option_list <- list(
  make_option(c("--iterations"), type="integer", default=1000),
  make_option(c("--seed"), type="double", default=1234)
)
opt <- parse_args(OptionParser(option_list=option_list))
iterations <- opt$iterations
set.seed(opt$seed)

ridge      <- list()
ridge_boot <- list()
for (j in 1:nrow(lookup)) {
  print(glue("Starting results for p = {lookup[j,'p']}"))
  pb <- progress_bar$new(
    format = "  [:bar] :percent (:current/:total) | cov: :coverage | eta: :eta",
    total  = iterations, clear = FALSE, width = 60
  )
  intermediate_res_ridge      <- list()
  intermediate_res_ridge_boot <- list()
  print("Starting results for ridge")
  for (i in 1:iterations) {
    data <- gen_data_distribution(n = 200, p = lookup[j,"p"], distribution = "normal", sigma = 10, SNR = lookup[j,"SNR"])
    truth <- data.frame(variable = names(data$beta), truth = data$beta)
    t <- system.time({
      intermediate_res_ridge[[i]] <- ridge_fit(data$X, data$y, alpha = 0.2, lambda = 0.4)
    })
    intermediate_res_ridge[[i]] <- intermediate_res_ridge[[i]] %>%
      left_join(truth, by = join_by(variable)) %>%
      mutate(time = as.numeric(t)[3], iteration = i, method = "ridge", n = 200, p = lookup[j,"p"], SNR = lookup[j,"SNR"])
    rolling_cov <- bind_rows(intermediate_res_ridge) %>%
      mutate(covered = lower <= truth & truth <= upper) %>%
      pull(covered) %>% mean()
    pb$tick(tokens = list(coverage = sprintf("%.3f", rolling_cov)))
  }
  ridge[[j]] <- bind_rows(intermediate_res_ridge)

  pb <- progress_bar$new(
    format = "  [:bar] :percent (:current/:total) | cov: :coverage | eta: :eta",
    total  = iterations, clear = FALSE, width = 60
  )
  print("Starting results for ridge bootstrap")
  for (i in 1:iterations) {
    data <- gen_data_distribution(n = 200, p = lookup[j,"p"], distribution = "normal", sigma = 10, SNR = lookup[j,"SNR"])
    truth <- data.frame(variable = names(data$beta), truth = data$beta)
    t <- system.time({
      intermediate_res_ridge_boot[[i]] <- ridge_bootstrap_ci(data$X, data$y, alpha = 0.2, lambda = 0.4, B = 100)
    })
    intermediate_res_ridge_boot[[i]] <- intermediate_res_ridge_boot[[i]] %>%
      left_join(truth, by = join_by(variable)) %>%
      mutate(time = as.numeric(t)[3], iteration = i, method = "ridge_boot", n = 200, p = lookup[j,"p"], SNR = lookup[j,"SNR"])
    rolling_cov <- bind_rows(intermediate_res_ridge_boot) %>%
      mutate(covered = lower <= truth & truth <= upper) %>%
      pull(covered) %>% mean()
    pb$tick(tokens = list(coverage = sprintf("%.3f", rolling_cov)))
  }
  ridge_boot[[j]] <- bind_rows(intermediate_res_ridge_boot)

}

if (interactive()) {
  saveRDS(bind_rows(ridge, ridge_boot), "rds/{iterations}/ridge_posterior_converge.rds")
} else {
  saveRDS(bind_rows(ridge, ridge_boot), "code/rds/{iterations}/ridge_posterior_converge.rds")
}

