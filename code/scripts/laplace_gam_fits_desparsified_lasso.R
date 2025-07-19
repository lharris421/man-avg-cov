if (interactive()) {
  source("scripts/setup.R")
  res <- readRDS("rds/laplace_desparsified_lasso.rds")
} else {
  source("code/scripts/setup.R")
  res <- readRDS("code/rds/laplace_desparsified_lasso.rds")
}

ns <- c(100)

gam_fits <- list()
for (j in 1:length(ns)) {
  results <- res %>%
    filter(n == ns[j])

  model_res     <- calculate_model_results(results)
  cutoff        <- max(model_res$truth)
  xs            <- seq(-cutoff, cutoff, by = 0.01)
  line_data     <- predict_covered(model_res, xs) %>%
    mutate(method = "desparsfied_lasso")
  line_data_avg <- mean(model_res$covered, na.rm = TRUE)

  gam_fits[[as.character(ns[j])]] <- list(line_data = line_data, line_data_avg = line_data_avg)

}

if (interactive()) {
  saveRDS(gam_fits, "rds/laplace_gam_fits_desparsified_lasso.rds")
} else {
  saveRDS(gam_fits, "code/rds/laplace_gam_fits_desparsified_lasso.rds")
}
