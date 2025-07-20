if (interactive()) {
  source("scripts/setup.R")
  results <- readRDS("rds/laplace_gam_fits_traditional_bootstrap.rds")[["100"]]
} else {
  source("code/scripts/setup.R")
  results <- readRDS("code/rds/laplace_gam_fits_traditional_bootstrap.rds")[["100"]]
}

line_data_avg <- data.frame(avg = results$line_data_avg, method = method_labels["traditional_bootstrap"])
line_data <- results$line_data %>%
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
  scale_color_manual(name = "Method", values = colors) +
  theme(legend.position = "none")

if (interactive()) {
  pdf("out/figureA1.pdf", height = 5, width = 7)
} else {
  pdf("code/out/figureA1.pdf", height = 5, width = 7)
}
p1
dev.off()
