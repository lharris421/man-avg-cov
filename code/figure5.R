if (interactive()) {
  source("scripts/setup.R")
  results <- readRDS("rds/highcorr.rds")
} else {
  source("code/scripts/setup.R")
  results <- readRDS("code/rds/highcorr.rds")
}

results <- results %>%
  mutate(estimate = ifelse(method == "relaxed_lasso_posterior", coef, estimate))

plots <- list()
methods <- c("relaxed_lasso_posterior", "ridge")
set.seed(1234)
selected_example <- sample(1:1000, 1)
for (i in 1:length(methods)) {
  curr_method <- methods[i]

  tmp_results <- results %>%
    filter(method == curr_method) %>%
    mutate(
      variable = ifelse(variable == "A1", "A", variable),
      variable = ifelse(variable == "B1", "B", variable),
    )

  example_res <- tmp_results %>%
    filter(iteration == selected_example) %>%
    filter(variable %in% c("A", "B", glue::glue("N{1:18}")))

  pdat <- tmp_results %>%
    filter(variable %in% c("A", "B", "N1")) %>%
    mutate(covered = lower <= truth & truth <= upper)

  pdat$variable <- factor(pdat$variable, levels = c("N1", "B", "A"))

  coverage_labels <- pdat %>%
    group_by(variable) %>%
    summarise(coverage = mean(covered)) %>%
    mutate(label = glue::glue("{round(coverage, 3)*100}%"))

  plots[[1 + 2*(i-1)]] <- pdat %>%
    mutate(midpoint = (lower + upper) / 2) %>%
    group_by(variable) %>%
    arrange(midpoint) %>%
    mutate(xorder = row_number()) %>%
    ungroup() %>%
    ggplot() +
    geom_errorbar(aes(x = xorder, ymin = lower, ymax = upper, color = covered, width = 0)) +
    scale_color_manual(values = c("TRUE" = "black", "FALSE" = "red")) +
    geom_hline(aes(yintercept = truth), color = "gold", linetype = "dashed") +
    theme_minimal() +
    xlab("") +
    theme(axis.text.x = element_blank(), axis.ticks.x = element_blank()) +
    coord_cartesian(ylim = c(-2, 2)) +
    theme(
      legend.position = "none"
    ) +
    ylab(NULL) +
    xlab(NULL) +
    ggtitle(method_labels[as.character(curr_method)]) +
    facet_grid(~ variable) +
    geom_text(
      data = coverage_labels,
      aes(x = -Inf, y = Inf, label = label),
      hjust = -0.5, vjust = 1,
      inherit.aes = FALSE,
      size = 4
    )

  plots[[2 + 2*(i-1)]] <- example_res %>%
    mutate(variable = factor(variable, levels = rev(c("A", "B", glue::glue("N{1:18}"))))) %>%
    ggplot() +
    geom_errorbar(aes(xmin = lower, xmax = upper, y = variable)) +
    geom_point(aes(x = estimate, y = variable)) +
    theme_minimal() +
    coord_cartesian(xlim = c(-2, 2)) +
    ylab(NULL) +
    xlab(NULL)

}


left_label <- textGrob("Variable", gp = gpar(fontsize = 12), rot = 90)
bottom_label <- textGrob("Interval Endpoint", gp = gpar(fontsize = 12))

if (interactive()) {
  pdf("out/figure5.pdf", height = 6)
} else {
  pdf("code/out/figure5.pdf", height = 6)
}
(plots[[1]] + ylab("Variable") + plots[[2]]) /
  (plots[[3]] + xlab(expression(beta)) + ylab("Variable") + plots[[4]] + xlab(expression(beta)) + patchwork::plot_layout(axes = "collect"))
dev.off()

