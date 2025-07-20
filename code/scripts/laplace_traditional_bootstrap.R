if (interactive()) {
  source("scripts/setup.R")
} else {
  source("code/scripts/setup.R")
}

ns <- c(100)
option_list <- list(
  make_option(c("--iterations"), type="integer", default=1000),
  make_option(c("--seed"), type="double", default=1234)
)
opt <- parse_args(OptionParser(option_list=option_list))
iterations <- opt$iterations
set.seed(opt$seed)

res <- list()
for (j in 1:length(ns)) {
  print(glue("Starting results for sample size = {ns[j]}"))
  pb <- progress_bar$new(
    format = "  [:bar] :percent (:current/:total) | cov: :coverage | eta: :eta",
    total  = iterations, clear = FALSE, width = 60
  )
  intermediate_res <- list()
  for (i in 1:iterations) {
    data <- gen_data_distribution(n = ns[j], p = 101, distribution = "laplace", sigma = 10)
    truth <- data.frame(variable = names(data$beta), truth = data$beta)
    run_time <- system.time({
      intermediate_res[[i]] <- traditional_bootstrap(data$X, data$y, penalty = "lasso", level = 0.8)
    })
    intermediate_res[[i]] <- intermediate_res[[i]] %>%
      left_join(truth, by = join_by(variable)) %>%
      mutate(time = as.numeric(run_time)[3], iteration = i)
    rolling_cov <- bind_rows(intermediate_res) %>%
      mutate(covered = lower <= truth & truth <= upper) %>%
      pull(covered) %>% mean()
    pb$tick(tokens = list(coverage = sprintf("%.3f", rolling_cov)))
  }
  res[[j]] <- bind_rows(intermediate_res) %>%
    mutate(n = ns[j], distribution = "laplace", method = "traditional_bootstrap")
}

if (interactive()) {
  saveRDS(bind_rows(res), glue("rds/{iterations}/laplace_traditional_bootstrap.rds"))
} else {
  saveRDS(bind_rows(res), glue("code/rds/{iterations}/laplace_traditional_bootstrap.rds"))
}

