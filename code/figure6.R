if (interactive()) {
  source("scripts/setup.R")
  results_rlp <- readRDS("rds/laplace_gam_fits.rds")[["100"]]
  results_si  <- readRDS("rds/laplace_gam_fits_selective_inference.rds")[["100"]]
  results_dl  <- readRDS("rds/laplace_gam_fits_desparsified_lasso.rds")[["100"]]
} else {
  source("code/scripts/setup.R")
  results_rlp <- readRDS("code/rds/laplace_gam_fits.rds")[["100"]]
  results_si  <- readRDS("code/rds/laplace_gam_fits_selective_inference.rds")[["100"]]
  results_dl  <- readRDS("code/rds/laplace_gam_fits_desparsified_lasso.rds")[["100"]]
}

line_data_avg <- bind_rows(
  data.frame(avg = results_rlp$line_data_avg, method = method_labels["relaxed_lasso_posterior"]),
  data.frame(avg = results_si$line_data_avg, method = method_labels["selective_inference"]),
  data.frame(avg = results_dl$line_data_avg, method = method_labels["desparsified_lasso"])
)
line_data <- bind_rows(
  results_rlp$line_data,
  results_si$line_data,
  results_dl$line_data
  ) %>%
  mutate(method = method_labels[method])

cutoff <- max(line_data$x)
xvals <- seq(from = -cutoff, to = cutoff, length.out = cutoff * 100 + 1)
density_data <- data.frame(x = xvals, density = 2 * dlaplace(xvals, rate = 1.414))

p1 <- ggplot() +
  geom_line(data = line_data, aes(x = x, y = y, color = method)) +
  geom_hline(data = line_data_avg, aes(yintercept = avg, color = method), linetype = 2) +
  geom_hline(aes(yintercept = 0.8), linetype = 1, alpha = .5) +
  geom_area(data = density_data, aes(x = x, y = density / max(density)), fill = "grey", alpha = 0.5) +
  theme_minimal() +
  xlab(expression(beta)) +
  ylab("Estimated Coverage") +
  coord_cartesian(ylim = c(0, 1)) +
  scale_color_manual(name = "Method", values = colors)

if (interactive()) {
  pdf("out/figure6.pdf", height = 4, width = 5)
} else {
  pdf("code/out/figure6.pdf", height = 4, width = 5)
}
p1
dev.off()
