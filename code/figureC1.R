if (interactive()) {
  source("scripts/setup.R")
  results50 <- readRDS("rds/laplace_gam_fits.rds")[["50"]]
  results100 <- readRDS("rds/laplace_gam_fits.rds")[["100"]]
  results400 <- readRDS("rds/laplace_gam_fits.rds")[["400"]]
} else {
  source("code/scripts/setup.R")
  results50 <- readRDS("code/rds/laplace_gam_fits.rds")[["50"]]
  results100 <- readRDS("code/rds/laplace_gam_fits.rds")[["100"]]
  results400 <- readRDS("code/rds/laplace_gam_fits.rds")[["400"]]
}

line_data_avg <- data.frame(
  avg = c(results50$line_data_avg, results100$line_data_avg, results400$line_data_avg),
  n = c(50, 100, 400)
) %>%
  mutate(n = factor(n, levels = c(50, 100, 400)))
line_data <- bind_rows(
  results50$line_data %>% mutate(n = 50),
  results100$line_data %>% mutate(n = 100),
  results400$line_data %>% mutate(n = 400)
  ) %>%
  mutate(method = method_labels[method],
         n = factor(n, levels = c(50, 100, 400)))

cutoff <- max(line_data$x)
xvals <- seq(from = -cutoff, to = cutoff, length.out = cutoff * 100 + 1)
density_data <- data.frame(x = xvals, density = 2 * dlaplace(xvals, rate = 1.414))

p1 <- ggplot() +
  geom_line(data = line_data, aes(x = x, y = y, color = n)) +
  geom_hline(data = line_data_avg, aes(yintercept = avg, color = n), linetype = 2) +
  geom_hline(aes(yintercept = 0.8), linetype = 1, alpha = .5) +
  geom_area(data = density_data, aes(x = x, y = density / max(density)), fill = "grey", alpha = 0.5) +
  theme_minimal() +
  xlab(expression(beta)) +
  ylab("Estimated Coverage") +
  coord_cartesian(ylim = c(0, 1)) +
  scale_color_manual(name = "Sample Size", values = colors)

if (interactive()) {
  pdf("out/figureC1.pdf", height = 5, width = 7)
} else {
  pdf("code/out/figureC1.pdf", height = 5, width = 7)
}
p1
dev.off()
