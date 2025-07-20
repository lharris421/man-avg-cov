if (interactive()) {
  source("scripts/setup.R")
} else {
  source("code/scripts/setup.R")
}

lookup <- data.frame(
  p = c(20, 100, 200),
  SNR = c(0.188649, 1.15345, 2.387699)
)

option_list <- list(
  make_option(c("--iterations"), type="integer", default=1000)
)
opt <- parse_args(OptionParser(option_list=option_list))
iterations <- opt$iterations

if (interactive()) {
  res <- readRDS("rds/{iterations}/ridge_posterior_converge.rds")
} else {
  res <- readRDS("code/rds/{iterations}/ridge_posterior_converge.rds")
}

ridge <- list()
ridge_boot <- list()
for (j in 1:nrow(lookup)) {

  results <- res %>%
    filter(p == lookup[j,"p"], method == "ridge")

  model_res     <- calculate_model_results(results)
  cutoff        <- max(model_res$truth)
  xs            <- seq(-cutoff, cutoff, by = 0.01)
  line_data     <- predict_covered(model_res, xs) %>%
    mutate(method = "ridge")
  line_data_avg <- data.frame(avg = mean(model_res$covered, na.rm = TRUE), method = "ridge")

  ridge[[as.character(lookup[j,"p"])]] <- list(line_data = line_data, line_data_avg = line_data_avg)

  results <- res %>%
    filter(p == lookup[j,"p"], method == "ridge_boot")

  model_res     <- calculate_model_results(results)
  cutoff        <- max(model_res$truth)
  xs            <- seq(-cutoff, cutoff, by = 0.01)
  line_data     <- predict_covered(model_res, xs) %>%
    mutate(method = "ridge_boot")
  line_data_avg <- data.frame(avg = mean(model_res$covered, na.rm = TRUE), method = "ridge_boot")

  ridge_boot[[as.character(lookup[j,"p"])]] <- list(line_data = line_data, line_data_avg = line_data_avg)

}

gam_fits <- list("ridge" = ridge, "ridge_boot" = ridge_boot)

if (interactive()) {
  saveRDS(gam_fits, "rds/{iterations}/ridge_gam_fits.rds")
} else {
  saveRDS(gam_fits, "code/rds/{iterations}/ridge_gam_fits.rds")
}
