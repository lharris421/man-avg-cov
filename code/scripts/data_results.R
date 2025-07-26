if (interactive()) {
  source("scripts/setup.R")
} else {
  source("code/scripts/setup.R")
}

option_list <- list(
  make_option(c("--seed"), type="double", default=1234),
  make_option(c("--method"), type="character", default="rlp"),
  make_option(c("--dataset"), type="character", default="whoari"),
  make_option(c("--loc"), type="character", default="")
)

opt <- parse_args(OptionParser(option_list=option_list))

method_name <- opt$method
method <- methods[[method_name]]

set.seed(opt$seed)
if (opt$dataset == "whoari") {
  data <- read_data("whoari")
  data$X <- ncvreg::std(data$X)
} else if (opt$dataset == "Scheetz2006") {
  data <- read_data("Scheetz2006")
}

lambda <- cv.ncvreg(data$X, data$y, penalty = "lasso")$lambda.min

suppressMessages({
  run_time <- system.time({
    res <- do.call(method$method, c(list(X = data$X, y = data$y, lambda = lambda), method$method_arguments))
  })
})

res <- res %>%
  mutate(
    time = as.numeric(run_time)[3],
    data = opt$data,
    method = method_name
  )


saveRDS(bind_rows(res), glue("{opt$loc}rds/{opt$data}_{method_name}.rds"))


