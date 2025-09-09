plot_ci_comparison <- function(cis, nvars = 20, ref = NULL) {

  plot_vars <- cis %>%
    filter(method == ref) %>%
    dplyr::arrange(desc(abs(estimate))) %>%
    slice_head(n = nvars) %>%
    dplyr::arrange(desc(estimate)) %>%
    pull(variable)

  plot_res <- cis %>%
    filter(variable %in% plot_vars) %>%
    dplyr::arrange(desc(estimate))

  plot_res$variable <- factor(plot_res$variable, levels = rev(plot_vars))
  plot_res$method <- factor(plot_res$method, levels = unique(cis$method))

  plot_res %>%
    group_by(variable) %>%
    arrange(method) %>%
    mutate(
      estimate = ifelse(is.na(estimate), NA, first(estimate)),
      lowerF    = ifelse(is.infinite(lower), NA, lower),
      upperF    = ifelse(is.infinite(upper), NA, upper)
    ) %>%
    ungroup() %>%
    ggplot() +
    geom_errorbar(aes(xmin = lower, xmax = upper, y = variable), width = 0) +
    geom_segment(aes(x = lowerF, xend = lowerF,
                     y = as.numeric(variable) - 0.5,
                     yend = as.numeric(variable) + 0.5)) +
    geom_segment(aes(x = upperF, xend = upperF,
                     y = as.numeric(variable) - 0.5,
                     yend = as.numeric(variable) + 0.5)) +
    #geom_line(aes(x = upper, y = variable), shape = "|", size = 3) +
    geom_point(aes(x = estimate, y = variable)) +
    theme_minimal() +
    ylab(NULL) + xlab(NULL) +
    scale_color_manual(name = "Method", values = colors) +
    theme(legend.position = "none",
          legend.justification = c("right", "bottom"),
          legend.box.just = "right",
          legend.margin = margin(6, 6, 6, 6),
          legend.background = element_rect(fill = "transparent")) +
    facet_wrap(~method, scales = "free_x", nrow = 1)

}
