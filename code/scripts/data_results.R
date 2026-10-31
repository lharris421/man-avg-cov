library(optparse)
option_list <- list(
  make_option(c("--seed"), type="double", default=1234),
  make_option(c("--alpha"), type="integer", default=5),
  make_option(c("--method"), type="character", default="rlp"),
  make_option(c("--dataset"), type="character", default="whoari")
)

opt <- parse_args(OptionParser(option_list=option_list))
alpha <- opt$alpha

if (interactive()) {
  source("scripts/setup.R")
} else {
  source("./code/scripts/setup.R")
}

for (i in 1:length(methods)) {
  methods[[i]]$method_arguments["alpha"] <- alpha / 100
}

method_name <- opt$method
method <- methods[[method_name]]

set.seed(opt$seed)
seeds <- round(runif(1) * 1e9)
if (opt$dataset == "whoari") {
  data <- read_data("whoari")
  data$X <- ncvreg::std(data$X)
} else if (opt$dataset == "Scheetz2006") {
  data <- read_data("Scheetz2006")
} else if (opt$dataset %in% c("brca1", "brca1_small")) {
  brca1 <- readRDS(glue("{data_dir}/{opt$dataset}.rds"))
  data <- list()
  data$y <- as.numeric(brca1[,"BRCA1"])
  data$X <- brca1[, colnames(brca1) != "BRCA1"]
} else if (opt$dataset == "Golub1999") {
  data <- read_data("Golub1999")
  colnames(data$X) <- make.unique(colnames(data$X))
  data$y <- as.numeric(data$y == "AML")
} else if (opt$dataset == "Singh2002") {
  data <- read_data("Singh2002")
  colnames(data$X) <- make.unique(colnames(data$X))
  data$y <- as.numeric(data$y != "normal")
} else if (opt$dataset == "Scherzer2007") {
  data <- readRDS(glue("{data_dir}/Scherzer2007.rds"))
  data$y <- as.numeric(data$y)
  colnames(data$X) <- make.unique(colnames(data$X))
}

set.seed(seeds[1])
if (method_name %in% c("rlp", "rl", "selectiveinference", "selectiveinferenceS", "desparsified", "pipep", "lqap")) {
  lambda <- cv.ncvreg(data$X, data$y)$lambda.min
} else if (method_name %in% c("rlbinom", "selectiveinferencebinom", "desparsifiedbinom", "pipepbinom", "lqapbinom")) {
  lambda <- cv.ncvreg(data$X, data$y, family = "binomial", penalty = "lasso")$lambda.min
} else {
  lambda <- NULL
}

suppressMessages({
  run_time <- system.time({
    if (!is.null(lambda)) {
      res <- do.call(method$method, c(list(X = data$X, y = data$y, lambda = lambda), method$method_arguments))
    } else {
      res <- do.call(method$method, c(list(X = data$X, y = data$y), method$method_arguments))
    }
  })
})

res <- res %>%
  mutate(
    time = as.numeric(run_time)[3],
    data = opt$data,
    method = method_name
  )

saveRDS(bind_rows(res), glue("{rds_dir}/{alpha}/{opt$data}_{method_name}.rds"))


