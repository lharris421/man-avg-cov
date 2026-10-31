if (interactive()) {
  source("scripts/setup.R")
} else {
  source("./code/scripts/setup.R")
}

option_list <- list(
  make_option(c("--alpha"), type="integer", default=5),
  make_option(c("-d", "--desparsified"), action="store_true", default=FALSE),
  make_option(c("--dataset"), type="character", default="brca1",
              help="brca1 (full data) or brca1_small (smoke test)")
)
opt <- parse_args(OptionParser(option_list=option_list))
desparsified <- opt$desparsified
alpha <- opt$alpha

methods <- c("pipep", "selectiveinferenceS")
if (desparsified) methods <- c(methods, "desparsified")

results_lookup <- expand.grid(
  method = methods
)

results <- list()
for (i in 1:nrow(results_lookup)) {
  results[[i]] <- readRDS(glue("{rds_dir}/{alpha}/{opt$dataset}_{results_lookup[i,'method']}.rds"))
}

cis <- bind_rows(results) %>%
  mutate(method = method_labels[method],
         estimate = ifelse(method == "PIPE Posterior", coef, estimate))

plot_vars <- cis %>%
  filter(method == "PIPE Posterior") %>%
  dplyr::arrange(desc(abs(estimate))) %>%
  slice_head(n = 30) %>%
  dplyr::arrange(desc(estimate)) %>%
  pull(variable)

plot_res <- cis %>%
  filter(variable %in% plot_vars) %>%
  dplyr::arrange(desc(estimate))

plot_res$variable <- factor(plot_res$variable, levels = rev(plot_vars))
plot_res$method <- factor(plot_res$method, levels = c("Desparsified Lasso", "Selective Inference", "PIPE Posterior"))

if (interactive()) {
  pdf("out/figure1.pdf", height = 3.9, width = 5.9)
} else {
  pdf("code/out/figure1.pdf", height = 3.9, width = 5.9)
}
plot_res %>%
  group_by(variable) %>%
  arrange(method) %>%
  mutate(
    estimate = ifelse(is.na(estimate), NA, last(estimate)),
    lowerF    = ifelse(is.infinite(lower), NA, lower),
    upperF    = ifelse(is.infinite(upper), NA, upper)
  ) %>%
  ungroup() %>%
  ggplot() +
  geom_errorbar(aes(xmin = lower, xmax = upper, y = variable), width = 0, na.rm = TRUE) +
  geom_segment(aes(x = lowerF, xend = lowerF,
                   y = as.numeric(variable) - 0.5,
                   yend = as.numeric(variable) + 0.5), na.rm = TRUE) +
  geom_segment(aes(x = upperF, xend = upperF,
                   y = as.numeric(variable) - 0.5,
                   yend = as.numeric(variable) + 0.5), na.rm = TRUE) +
  geom_point(aes(x = estimate, y = variable), na.rm = TRUE) +
  theme_minimal() +
  ylab(NULL) + xlab(NULL) +
  scale_color_manual(name = "Method", values = colors) +
  theme(legend.position = "none",
        legend.justification = c("right", "bottom"),
        legend.box.just = "right",
        legend.margin = margin(6, 6, 6, 6),
        legend.background = element_rect(fill = "transparent")) +
  facet_wrap(~method, scales = "free_x", nrow = 1)
invisible(dev.off())
