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
    data <- gen_data_distribution(n = ns[j], p = 101, distribution = "sparse 1", sigma = 10)
    truth <- data.frame(variable = names(data$beta), truth = data$beta)
    t <- system.time({
      cv_fit <- cv.ncvreg(data$X, data$y, penalty = "MCP")
      intermediate_res[[i]] <- confidence_intervals(cv_fit, level = 0.8, relaxed = TRUE)
    })
    intermediate_res[[i]] <- intermediate_res[[i]] %>%
      left_join(truth, by = join_by(variable)) %>%
      mutate(time = t, iteration = i)
    rolling_cov <- bind_rows(intermediate_res) %>%
      mutate(covered = lower <= truth & truth <= upper) %>%
      pull(covered) %>% mean()
    pb$tick(tokens = list(coverage = sprintf("%.3f", rolling_cov)))
  }
  res[[j]] <- bind_rows(intermediate_res) %>%
    mutate(n = ns[j], distribution = "sparse 1", method = "relaxed_MCP_posterior")
}

if (interactive()) {
  saveRDS(bind_rows(res), glue("rds/{iterations}/sparse1_relaxed_MCP_posterior.rds"))
} else {
  saveRDS(bind_rows(res), glue("code/rds/{iterations}/sparse1_relaxed_MCP_posterior.rds"))
}

