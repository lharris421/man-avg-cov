if (interactive()) {
  source("scripts/setup.R")
} else {
  source("code/scripts/setup.R")
}

iterations <- 1000
set.seed(1234)

pb <- progress_bar$new(
  format = "  [:bar] :percent (:current/:total) | eta: :eta",
  total  = iterations, clear = FALSE, width = 60
)

rlp   <- list()
ridge <- list()
for (i in 1:iterations) {

  data <- gen_data_highcorr()
  truth <- data.frame(variable = names(data$beta), truth = data$beta)

  t <- system.time({
    rlp[[i]] <- pipe_ncvreg(data$X, data$y, penalty = "lasso", level = 0.8, relaxed = TRUE)
  })
  rlp[[i]] <- rlp[[i]] %>%
    left_join(truth, by = join_by(variable)) %>%
    mutate(time = as.numeric(t)[3], iteration = i, method = "relaxed_lasso_posterior")

  ## Ridge
  t <- system.time({
    ridge[[i]] <- ridge_fit(data$X, data$y, alpha = 0.2)
  })
  ridge[[i]] <- ridge[[i]] %>%
    left_join(truth, by = join_by(variable)) %>%
    mutate(time = as.numeric(t)[3], iteration = i, method = "ridge")

  pb$tick()
}
res <- bind_rows(rlp, ridge) %>%
  mutate(distribution = "highcorr")

if (interactive()) {
  saveRDS(res, "rds/highcorr.rds")
} else {
  saveRDS(res, "code/rds/highcorr.rds")
}

