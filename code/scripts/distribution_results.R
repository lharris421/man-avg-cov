if (interactive()) {
  source("scripts/setup.R")
} else {
  source("code/scripts/setup.R")
}

option_list <- list(
  make_option(c("--iterations"), type="integer", default=1000),
  make_option(c("--seed"), type="double", default=1234),
  make_option(c("--n"), type="integer", default=50),
  make_option(c("--p"), type="integer", default=101),
  make_option(c("--sigma"), type="integer", default=10),
  make_option(c("--snr"), type="integer", default=100),
  make_option(c("--distribution"), type="character", default="laplace"),
  make_option(c("--method"), type="character", default="rlp"),
  make_option(c("--corr"), type="character", default="exchangeable"),
  make_option(c("--rho"), type="integer", default=0),
  make_option(c("--loc"), type="character", default="")
)

opt <- parse_args(OptionParser(option_list=option_list))
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
  data <- gen_data_distribution(
    n = opt$n, p = opt$p, distribution = opt$distribution, corr = opt$corr,
    sigma = 10, rho = opt$rho / 100, SNR = opt$snr / 100
  )
  truth <- data.frame(variable = names(data$beta), truth = data$beta)

  suppressMessages({
    run_time <- system.time({
      res[[i]] <- do.call(method$method, c(list(X = data$X, y = data$y), method$method_arguments))
    })
  })
  res[[i]] <- res[[i]] %>%
    left_join(truth, by = join_by(variable)) %>%
    mutate(time = as.numeric(run_time)[3], iteration = i)
  rolling_cov <- bind_rows(res) %>%
    mutate(covered = lower <= truth & truth <= upper) %>%
    pull(covered) %>% mean(na.rm = TRUE)
  pb$tick(tokens = list(coverage = sprintf("%.3f", rolling_cov)))
}
res <- bind_rows(res) %>%
  mutate(n = opt$n, distribution = opt$distribution, p = opt$p, corr = opt$corr, rho = opt$rho, sigma = opt$sigma, snr = opt$snr, method = method_name)

saveRDS(bind_rows(res), glue("{opt$loc}rds/{iterations}/original/{opt$distribution}_{opt$corr}_{opt$rho}_{opt$n}_{opt$p}_{opt$sigma}_{opt$snr}_{method_name}.rds"))

