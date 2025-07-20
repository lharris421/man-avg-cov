if (interactive()) {
  source("scripts/setup.R")
  results_rlp <- readRDS("rds/sparse1_relaxed_lasso_posterior.rds")
  results_rmp  <- readRDS("rds/sparse1_relaxed_MCP_posterior.rds")
  path_pre <- "out/"
} else {
  source("code/scripts/setup.R")
  results_rlp <- readRDS("code/rds/sparse1_relaxed_lasso_posterior.rds")
  results_rmp  <- readRDS("code/rds/sparse1_relaxed_MCP_posterior.rds")
  path_pre <- "code/out/"
}

results <- bind_rows(
  results_rlp,
  results_rmp
) %>%
  mutate(method = method_labels[method])

tab <- results %>%
  mutate(
    abs_truth = abs(truth),
    covered = lower <= truth & upper >= truth
  ) %>%
  group_by(method, abs_truth) %>%
  summarise(coverage = glue("{round(mean(covered), 3)*100}%"), .groups = "drop") %>%
  pivot_wider(names_from = method, values_from = coverage)


# Render only the tabular (no table env), write to file
out_file <- glue("{path_pre}tableE1.tex")

# write the kable as before
colnames(tab)[1] <- "beta"
kbl(
  tab,
  format    = "latex",
  booktabs  = TRUE,
  align     = rep("c", ncol(tab)),
  escape    = TRUE,
  sanitize.colnames.function = identity,
  digits    = 3,
  table.envir = NULL,
  linesep     = ""
) %>%
  add_header_above(c(" " = 1, "Coverage (%)" = 2)) %>%
  write(out_file)

# now read it back, replace "beta" with "$|\\beta|$" and overwrite
tex <- readLines(out_file)
tex <- gsub("\\bbeta\\b", "\\$|\\\\beta|\\$", tex)
writeLines(tex, out_file)



