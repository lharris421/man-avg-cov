source("scripts/setup.R")

ns <- c(50, 100, 400, 1000)

res <- readRDS("rds/laplace_relaxed_lasso_posterior.rds")

gam_fits <- list()
for (j in 1:length(ns)) {
  results <- res %>%
    filter(n == ns[j])

  model_res     <- calculate_model_results(results)
  cutoff        <- max(model_res$truth)
  xs            <- seq(-cutoff, cutoff, by = 0.01)
  line_data     <- predict_covered(model_res, xs) %>%
    mutate(method = "relaxed_lasso_posterior")
  line_data_avg <- mean(model_res$covered, na.rm = TRUE)

  gam_fits[[as.character(ns[j])]] <- list(line_data = line_data, line_data_avg = line_data_avg)

}

saveRDS(gam_fits, "rds/laplace_gam_fits.R")
