if (interactive()) {
  source("scripts/setup.R")
} else {
  source("code/scripts/setup.R")
}

option_list <- list(
  make_option(c("--iterations"), type="integer", default=1000),
  make_option(c("--seed"), type="double", default=1234)
)
opt <- parse_args(OptionParser(option_list=option_list))
iterations <- opt$iterations
set.seed(opt$seed)

lambda_mins <- numeric(iterations)
nres <- list()
pb <- progress_bar$new(
  format = "  [:bar] :percent (:current/:total) | eta: :eta",
  total  = iterations, clear = FALSE, width = 60
)
for (k in 1:iterations) {

  current_seed <- seed + k
  set.seed(current_seed)

  data <- gen_data_distribution(n = 100, p = 101, distribution = "laplace", sigma = 10)

  cv_fit <- cv.ncvreg(data$X, data$y, penalty = "lasso", lambda.min = 0.05, max.iter = 1e7)
  which_lambdas <- ceiling(((1:100)[1:100 %% 4 == 0 | 1:100 == 1] / 100) * 100)
  lambda_seq <- cv_fit$lambda[which_lambdas]
  lambda_max <- max(cv_fit$lambda)
  lambda_mins[k] <- cv_fit$lambda.min / lambda_max

  ## sigma2 est (so all remain consistent)
  yhat <- cv_fit$fit$linear.predictors[,cv_fit$min]
  reid_coefs <- coef(cv_fit$fit, lambda = cv_fit$lambda.min)[-1]
  sh_lh <- sum(reid_coefs != 0)
  sigma2 <- (length(data$y) - sh_lh)^(-1) * sum((data$y - yhat)^2)

  pre_lambda_res <- list()
  for (i in 1:length(lambda_seq)) {

    if (!is.na(lambda_seq[i])) {
      set.seed(current_seed)
      pre_lambda_res[[i]] <- pipe_ncvreg(data$X, data$y, penalty = "lasso", level = 0.8, relaxed = TRUE, sigma = sqrt(sigma2), lambda = lambda_seq[i]) %>%
        dplyr::mutate(lambda_ind = i, n = 100, group = k, lambda = lambda_seq[i], lambda_max = lambda_max)
    } else {
      print("Shortened lambda sequence!!")
      pre_lambda_res[[i]] <- data.frame(
        "estimate" = NA, "variable" = NA, "lower" = NA, "upper" = NA, "method" = NA, "lambda" = NA,
        "sigma" = NA, "lambda_ind" = NA, "group" = NA, "lambda_max" = NA
      )
    }


  }

  truth <- data.frame(variable = names(data$beta), truth = as.numeric(data$beta))
  plot_data <-  bind_rows(pre_lambda_res) %>%
    filter(!is.na(lambda)) %>%
    left_join(truth, by = join_by(variable))

  nres[[k]] <- plot_data
  pb$tick()

}

res_list <- list("res" = bind_rows(nres), "lambdas" = lambda_mins)

if (interactive()) {
  saveRDS(res_list, "rds/{iterations}/across_lambda_coverage.rds")
} else {
  saveRDS(res_list, "code/rds/{iterations}/across_lambda_coverage.rds")
}

