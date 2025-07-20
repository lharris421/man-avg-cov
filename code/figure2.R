library(optparse)
option_list <- list(
  make_option(c("--iterations"), type="integer", default=1000)
)
opt <- parse_args(OptionParser(option_list=option_list))
iterations <- opt$iterations

if (interactive()) {
  source("scripts/setup.R")
  results <- readRDS("rds/{iterations}/ridge_gam_fits.rds")
} else {
  source("code/scripts/setup.R")
  results <- readRDS("code/rds/{iterations}/ridge_gam_fits.rds")
}

lookup <- data.frame(
  p = c(20, 100, 200),
  SNR = c(0.188649, 1.15345, 2.387699)
)

plots <- list()
for (j in 1:nrow(lookup)) {

  which_p <- as.character(lookup[j,"p"])
  ridge <- results$ridge[[which_p]]
  ridge_boot <- results$ridge_boot[[which_p]]

  line_data_avg <- bind_rows(ridge$line_data_avg, ridge_boot$line_data_avg) %>% mutate(method = method_labels[method])
  line_data <- bind_rows(ridge$line_data, ridge_boot$line_data) %>% mutate(method = method_labels[method])


  sd <- sqrt(1 / 0.8)
  cutoff <- sd * 3
  xvals <- seq(from = -cutoff, to = cutoff, length.out = 101)
  density_data <- data.frame(x = xvals, density = dnorm(xvals, sd = sd))
  density_data <- bind_rows(
    density_data
  )

  plots[[j]] <- ggplot() +
    geom_line(data = line_data , aes(x = x, y = y, color = method)) +
    geom_hline(data = line_data_avg, aes(yintercept = avg, color = method), linetype = 2) +
    geom_area(data = density_data, aes(x = x, y = density / max(density)), fill = "grey", alpha = 0.5, inherit.aes = FALSE) +
    theme_minimal() +
    xlab(expression(beta)) +
    ylab("Coverage") +
    coord_cartesian(ylim = c(0, 1), xlim = c(-cutoff, cutoff)) +
    scale_color_manual(name = "Method", values = colors) +
    geom_hline(yintercept = 0.8) +
    ggtitle(glue("p = {lookup[j,'p']}"))

}

if (interactive()) {
  pdf("out/figure2.pdf", height = 3, width = 6)
} else {
  pdf("code/out/figure2.pdf", height = 3, width = 6)
}
full   <- wrap_plots(plots, ncol = 3)

# then do one global collect of legends, axis‐titles, and axes
full + plot_layout(
  guides      = "collect",
  axis_titles = "collect",
  axes        = "collect"
)
dev.off()
