if (interactive()) {
  source("scripts/setup.R")
} else {
  source("code/scripts/setup.R")
}

option_list <- list(
  make_option(c("--iterations"), type="integer", default=100)
)
opt <- parse_args(OptionParser(option_list=option_list))
iterations <- opt$iterations

if (interactive()) {
  results <- readRDS(glue("rds/{iterations}/gam/laplace_autoregressive_0_100_101_10_100_traditional.rds"))
} else {
  results <- readRDS(glue("code/rds/{iterations}/gam/laplace_autoregressive_0_100_101_10_100_traditional.rds"))
}

line_data <- results %>%
  mutate(method = method_labels[method])

cutoff <- max(line_data$x)
xvals <- seq(from = -cutoff, to = cutoff, length.out = cutoff * 100 + 1)
density_data <- data.frame(x = xvals, density = 2 * dlaplace(xvals, rate = 1.414))

p1 <- ggplot() +
  geom_line(data = line_data, aes(x = x, y = y, color = method)) +
  geom_hline(data = line_data, aes(yintercept = average_coverage, color = method), linetype = 2) +
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
