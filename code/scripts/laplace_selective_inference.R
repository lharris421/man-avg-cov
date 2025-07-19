if (interactive()) {
  source("scripts/setup.R")
} else {
  source("code/scripts/setup.R")
}

ns <- c(50, 100, 400)
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
    data <- gen_data_distribution(n = ns[j], p = 101, distribution = "laplace", sigma = 10)
    truth <- data.frame(variable = names(data$beta), truth = data$beta)
    t <- system.time({
      intermediate_res[[i]] <- selective_inference(data$X, data$y, alpha = 0.2)
    })
    intermediate_res[[i]] <- intermediate_res[[i]] %>%
      left_join(truth, by = join_by(variable)) %>%
      mutate(time = as.numeric(t)[3], iteration = i)
    rolling_cov <- bind_rows(intermediate_res) %>%
      mutate(covered = lower <= truth & truth <= upper) %>%
      pull(covered) %>% mean(na.rm = TRUE)
    pb$tick(tokens = list(coverage = sprintf("%.3f", rolling_cov)))
  }
  res[[j]] <- bind_rows(intermediate_res) %>%
    mutate(n = ns[j], distribution = "laplace", method = "selective_inference")
}

if (interactive()) {
  saveRDS(bind_rows(res), "rds/laplace_selective_inference.rds")
} else {
  saveRDS(bind_rows(res), "code/rds/laplace_selective_inference.rds")
}

