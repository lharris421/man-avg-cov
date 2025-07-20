if (interactive()) {
  source("scripts/setup.R")
} else {
  source("code/scripts/setup.R")
}

ns <- c(100)
option_list <- list(
  make_option(c("--iterations"), type="integer", default=1000)
)
opt <- parse_args(OptionParser(option_list=option_list))
iterations <- opt$iterations

if (interactive()) {
  res <- readRDS(glue("rds/{iterations}/laplace_selective_inference.rds"))
} else {
  res <- readRDS(glue("code/rds/{iterations}/laplace_selective_inference.rds"))
}

gam_fits <- list()
for (j in 1:length(ns)) {
  results <- res %>%
    filter(n == ns[j])

  model_res     <- calculate_model_results(results)
  cutoff        <- max(model_res$truth)
  xs            <- seq(-cutoff, cutoff, by = 0.01)
  line_data     <- predict_covered(model_res, xs) %>%
    mutate(method = "selective_inference")
  line_data_avg <- mean(model_res$covered, na.rm = TRUE)

  gam_fits[[as.character(ns[j])]] <- list(line_data = line_data, line_data_avg = line_data_avg)

}

if (interactive()) {
  saveRDS(gam_fits, glue("rds/{iterations}/laplace_gam_fits_selective_inference.rds"))
} else {
  saveRDS(gam_fits, glue("code/rds/{iterations}/laplace_gam_fits_selective_inference.rds"))
}
