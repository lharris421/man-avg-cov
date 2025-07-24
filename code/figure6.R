if (interactive()) {
  source("scripts/setup.R")
} else {
  source("code/scripts/setup.R")
}

option_list <- list(
  make_option(c("--iterations"), type="integer", default=1000),
  make_option(c("-d", "--desparsified"), action="store_true", default=FALSE)
)
opt <- parse_args(OptionParser(option_list=option_list))
iterations <- opt$iterations
desparsified <- opt$desparsified

results_lookup <- expand.grid(
  method = c("rlp", "selectiveinference")
)

results <- list()
for (i in 1:nrow(results_lookup)) {
  if (interactive()) {
    results[[i]] <- readRDS(glue("rds/{iterations}/gam/laplace_autoregressive_0_100_101_10_100_{results_lookup[i,'method']}.rds"))
  } else {
    results[[i]] <- readRDS(glue("code/rds/{iterations}/gam/laplace_autoregressive_0_100_101_10_100_{results_lookup[i,'method']}.rds"))
  }
}
line_data <- bind_rows(results) %>%
  mutate(
    method = method_labels[method]
  )

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
  scale_color_manual(name = "Method", values = colors)

if (interactive()) {
  pdf("out/figure6.pdf", height = 4, width = 5)
} else {
  pdf("code/out/figure6.pdf", height = 4, width = 5)
}
p1
dev.off()
