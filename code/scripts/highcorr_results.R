if (interactive()) {
  source("scripts/setup.R")
} else {
  source("code/scripts/setup.R")
}

option_list <- list(
  make_option(c("--iterations"), type="integer", default=1000),
  make_option(c("--seed"), type="double", default=1234),
  make_option(c("--method"), type="character", default="rlp")
)

opt <- parse_args(OptionParser(option_list=option_list))
print(opt)
iterations <- opt$iterations
set.seed(opt$seed)
seeds <- round(runif(iterations) * 1e9)
method_name <- opt$method
method <- methods[[method_name]]

pb <- progress_bar$new(
  format = "  [:bar] :percent (:current/:total) | cov: :coverage | eta: :eta",
  total  = iterations, clear = FALSE, width = 60
)

res <- list()
for (i in 1:iterations) {
  set.seed(seeds[i])
  data <- gen_data_highcorr()
  truth <- data.frame(variable = names(data$beta), truth = data$beta)

  suppressMessages({
    t <- system.time({
      res[[i]] <- do.call(method$method, c(list(X = data$X, y = data$y), method$method_arguments))
    })
  })
  res[[i]] <- res[[i]] %>%
    left_join(truth, by = join_by(variable)) %>%
    mutate(time = as.numeric(t)[3], iteration = i)
  rolling_cov <- bind_rows(res) %>%
    mutate(covered = lower <= truth & truth <= upper) %>%
    pull(covered) %>% mean(na.rm = TRUE)
  pb$tick(tokens = list(coverage = sprintf("%.3f", rolling_cov)))
}
res <- bind_rows(res) %>%
  mutate(method = method_name)

if (interactive()) {
  saveRDS(bind_rows(res), glue("rds/{iterations}/original/highcorr_{method_name}.rds"))
} else {
  saveRDS(bind_rows(res), glue("code/rds/{iterations}/original/highcorr_{method_name}.rds"))
}

