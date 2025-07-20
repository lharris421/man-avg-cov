library(optparse)
option_list <- list(
  make_option(c("--iterations"), type="integer", default=1000)
)
opt <- parse_args(OptionParser(option_list=option_list))
iterations <- opt$iterations

if (interactive()) {
  source("scripts/setup.R")
  res <- readRDS("rds/{iterations}/laplace_selective_inference.rds")
  path_pre <- "out/"
} else {
  source("code/scripts/setup.R")
  res <- readRDS("code/rds/{iterations}/laplace_selective_inference.rds")
  path_pre <- "code/out/"
}

# 1) # Simulations Null Selected
null_sel <- res %>%
  filter(variable == "V001") %>%
  group_by(n, iteration) %>%
  summarise(selected = any(!is.na(lower)), .groups = "drop") %>%
  group_by(n) %>%
  summarise(
    denom         = n(),
    null_selected = denom - sum(selected),
    .groups       = "drop"
  ) %>%
  dplyr::select(n, null_selected)

# 2) Average # Parameters included
avg_sel <- res %>%
  group_by(n, iteration) %>%
  summarise(num_inc = sum(!is.na(lower)), .groups = "drop") %>%
  group_by(n) %>%
  summarise(avg_inc = mean(num_inc), .groups = "drop")

# 3) # Simulations with infinite *median* width
inf_med <- res %>%
  mutate(width = upper - lower) %>%
  group_by(n, iteration) %>%
  summarise(med = median(width, na.rm = TRUE), .groups = "drop") %>%
  group_by(n) %>%
  summarise(inf_median = sum(is.infinite(med)), .groups = "drop")

# 4) # Simulations with *any* infinite width
any_inf <- res %>%
  mutate(width = upper - lower) %>%
  group_by(n, iteration) %>%
  summarise(any_inf = any(is.infinite(width), na.rm = TRUE), .groups = "drop") %>%
  group_by(n) %>%
  summarise(any_inf_width = sum(any_inf), .groups = "drop")

# 5) Assemble into one tibble
tab_sel_inf <- tibble(n = sort(unique(res$n))) %>%
  left_join(null_sel, by = "n") %>%
  left_join(avg_sel, by = "n") %>%
  left_join(inf_med, by = "n") %>%
  left_join(any_inf, by = "n")

# 6) Column‐headers matching your manual layout
col_names <- c(
  "n",
  "# Simulations Null Selected",
  "Average # Parameters",
  "# Simulations Inf Median Width",
  "# Simulations Any Inf Width"
)

# 7) Render only the tabular (no table env), write to file
kbl(
  tab_sel_inf,
  format     = "latex",
  booktabs   = TRUE,
  align     = c("c", rep("p{3cm}", 4)),
  # digits     = c(0, 0, 1, 0, 0),
  digits = 3,
  col.names  = col_names,
  table.envir= NULL,
  linesep    = ""
) %>%
  write(glue("{path_pre}tableD1.tex"))
