if (interactive()) {
  source("setup.R")
} else {
  source("code/setup.R")
}

option_list <- list(
  make_option(c("--iterations"), type="integer", default=100),
  make_option(c("--loc"), type="character", default="")
)
opt <- parse_args(OptionParser(option_list=option_list))
iterations <- opt$iterations

results_lookup <- expand.grid(
  n = c(50, 100, 400, 1000),
  rho = c(0, 50, 80)
) %>%
  mutate(method = "rlp")

results <- list()
for (i in 1:nrow(results_lookup)) {
  results[[i]] <- readRDS(glue("{opt$loc}rds/{iterations}/original/laplace_autoregressive_{results_lookup[i,'rho']}_{results_lookup[i,'n']}_101_10_100_{results_lookup[i,'method']}.rds"))
}
res <- bind_rows(results) %>%
  mutate(method = method_labels[method])

# Transform and summarize data
coverage_data <- res %>%
  mutate(covered = lower <= truth & upper >= truth, n = as.factor(n), rho = factor(rho)) %>%
  group_by(iteration, method, rho, n) %>%
  summarise(coverage = mean(covered, na.rm = TRUE), .groups = 'drop')

# Create a single plot with facets for each rho
rhos <- c(0, 0.5, 0.8)
final_plot <- coverage_data %>%
  ggplot(aes(x = n, y = coverage, fill = n)) +
  geom_violin() +
  facet_wrap(method~rho, as.table = FALSE, labeller = label_bquote(rho == .(rhos[rho]))) +
  labs(x = "Sample Size", y = "Coverage Rate") +
  theme_minimal() +
  theme(legend.position = "none") +
  geom_hline(yintercept = 0.8) +
  coord_cartesian(ylim = c(0, 1))

# Print the plot
if (interactive()) {
  pdf("out/figure3.pdf", height = 4, width = 8)
} else {
  pdf("code/out/figure3.pdf", height = 4, width = 8)
}
final_plot
dev.off()
