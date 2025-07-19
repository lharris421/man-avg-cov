if (interactive()) {
  source("scripts/setup.R")
  res <- list()
  res[[1]] <- readRDS("rds/laplace_relaxed_lasso_posterior.rds") %>%
    mutate(rho = 0, method = "relaxed_lasso_posterior")
  res[[2]] <- readRDS("rds/laplace_corr_relaxed_lasso_posterior.rds") %>%
    mutate(method = "relaxed_lasso_posterior")
} else {
  source("code/scripts/setup.R")
  res <- list()
  res[[1]] <- readRDS("code/rds/laplace_relaxed_lasso_posterior.rds") %>%
    mutate(rho = 0, method = "relaxed_lasso_posterior")
  res[[2]] <- readRDS("code/rds/laplace_corr_relaxed_lasso_posterior.rds") %>%
    mutate(method = "relaxed_lasso_posterior")
}

res <- bind_rows(res) %>%
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
