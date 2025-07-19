if (interactive()) {
  source("scripts/setup.R")
} else {
  source("code/scripts/setup.R")
}

ns <- c(50, 100, 400, 1000)
iterations <- 100
set.seed(1234)

res <- list()
for (j in 1:length(ns)) {
  print(glue("Starting results for sample size = {ns[j]}"))
  pb <- progress_bar$new(
    format = "  [:bar] :percent (:current/:total) | cov: :coverage | eta: :eta",
    total  = iterations, clear = FALSE, width = 60
  )
  intermediate_res <- list()
  for (i in 1:iterations) {
    data <- gen_data_distribution(n = ns[j], p = 101, distribution = "beta", sigma = 10)
    truth <- data.frame(variable = names(data$beta), truth = data$beta)
    t <- system.time({
      intermediate_res[[i]] <- pipe_ncvreg(data$X, data$y, penalty = "lasso", level = 0.8, relaxed = TRUE)
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
    mutate(n = ns[j], distribution = "beta")
}

if (interactive()) {
  saveRDS(bind_rows(res), "rds/beta_relaxed_lasso_posterior.rds")
} else {
  saveRDS(bind_rows(res), "code/rds/beta_relaxed_lasso_posterior.rds")
}

