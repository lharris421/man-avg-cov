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
  method = c("rlp", "selectiveinference"),
  n = c(50, 100, 400)
)

results <- list()
for (i in 1:nrow(results_lookup)) {
  if (interactive()) {
    results[[i]] <- readRDS(glue("rds/{iterations}/original/laplace_autoregressive_0_{results_lookup[i,'n']}_101_10_100_{results_lookup[i,'method']}.rds"))
  } else {
    results[[i]] <- readRDS(glue("code/rds/{iterations}/original/laplace_autoregressive_0_{results_lookup[i,'n']}_101_10_100_{results_lookup[i,'method']}.rds"))
  }
}
results <- bind_rows(results) %>%
  mutate(
    method = method_labels[method]
  )

results_per_sim <- results %>%
  group_by(method, n, iteration) %>%
  mutate(index = 1:n()) %>%
  ungroup() %>%
  filter(index == 1) %>%
  dplyr::select(method, n, time)

results <- results %>%
  mutate(n = factor(n, levels = c(50, 100, 400)))

results_per_sim <- results_per_sim %>%
  mutate(n = factor(n, levels = c(50, 100, 400)))

colors <- colors[1:3]

fill_scale <- scale_fill_manual(
  values = colors,
  name = "Sample Size",
  labels = c("50", "100", "400")
)

color_scale <- scale_color_manual(
  values = colors,
  name = "Sample Size",
  labels = c("50", "100", "400")
)

## Coverage
p1 <- results %>%
  filter(!is.na(estimate)) %>%
  mutate(covered = lower <= truth & upper >= truth) %>%
  group_by(method, iteration, n) %>%
  summarise(coverage = mean(covered, na.rm = TRUE)) %>%
  ungroup() %>%
  ggplot(aes(x = method, y = coverage, fill = n)) +
  geom_violin(color = NA) +
  geom_hline(yintercept = 0.8) +
  fill_scale +
  ylab("Coverage") +
  xlab("Method") +
  theme_minimal()

p2 <- results_per_sim %>%
  group_by(method, n) %>%
  summarise(avg_runtime = mean(time)) %>%
  ggplot(aes(x = method, y = avg_runtime, fill = n, color = n)) +
  geom_col(position = "dodge") +
  fill_scale + color_scale +
  ylab("Avg Runtime (sec)") +
  xlab("Method") +
  theme_minimal() +
  guides(color = "none")

p3 <- results %>%
  mutate(width = upper - lower) %>%
  group_by(method, n) %>%
  summarise(width = median(width, na.rm = TRUE)) %>%
  ungroup() %>%
  ggplot(aes(x = method, y = width, fill = n)) +
  geom_col(position = "dodge") +
  fill_scale +
  ylab(expression(`Median Width`)) +
  xlab("Method") +
  theme_minimal() +
  coord_cartesian(ylim = c(0, 20))


if (interactive()) {
  pdf("out/figure7.pdf", height = 5, width = 7)
} else {
  pdf("code/out/figure7.pdf", height = 5, width = 7)
}
(p1 / p3 / p2) + plot_layout(guides = "collect", axes = "collect")
dev.off()
