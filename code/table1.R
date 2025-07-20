library(optparse)
option_list <- list(
  make_option(c("--iterations"), type="integer", default=1000)
)
opt <- parse_args(OptionParser(option_list=option_list))
iterations <- opt$iterations

if (interactive()) {
  source("scripts/setup.R")
  laplace <- readRDS("rds/{iterations}/laplace_relaxed_lasso_posterior.rds")
  normal  <- readRDS("rds/{iterations}/normal_relaxed_lasso_posterior.rds")
  t       <- readRDS("rds/{iterations}/t_relaxed_lasso_posterior.rds")
  uniform <- readRDS("rds/{iterations}/uniform_relaxed_lasso_posterior.rds")
  beta    <- readRDS("rds/{iterations}/beta_relaxed_lasso_posterior.rds")
  sparse1 <- readRDS("rds/{iterations}/sparse1_relaxed_lasso_posterior.rds")
  sparse2 <- readRDS("rds/{iterations}/sparse2_relaxed_lasso_posterior.rds")
  sparse3 <- readRDS("rds/{iterations}/sparse3_relaxed_lasso_posterior.rds")
} else {
  source("code/scripts/setup.R")
  laplace <- readRDS("code/rds/{iterations}/laplace_relaxed_lasso_posterior.rds")
  normal  <- readRDS("code/rds/{iterations}/normal_relaxed_lasso_posterior.rds")
  t       <- readRDS("code/rds/{iterations}/t_relaxed_lasso_posterior.rds")
  uniform <- readRDS("code/rds/{iterations}/uniform_relaxed_lasso_posterior.rds")
  beta    <- readRDS("code/rds/{iterations}/beta_relaxed_lasso_posterior.rds")
  sparse1 <- readRDS("code/rds/{iterations}/sparse1_relaxed_lasso_posterior.rds")
  sparse2 <- readRDS("code/rds/{iterations}/sparse2_relaxed_lasso_posterior.rds")
  sparse3 <- readRDS("code/rds/{iterations}/sparse3_relaxed_lasso_posterior.rds")
}

results <- bind_rows(laplace, normal, t, uniform, beta, sparse1, sparse2, sparse3) %>%
  mutate(method = "relaxed_lasso_posterior")

ps <- list(
  "laplace" = qlaplace((1:101) / (101 + 1), rate = 1),
  "t" = qt((1:101) / (101 + 1), df = 4),
  "normal" = qnorm((1:101) / (101 + 1), sd = 1),
  "uniform" = qunif((1:101) / (101 + 1), -1, 1),
  "beta" = qbeta((1:101) / (101 + 1),  .1, .1) - .5,
  "sparse 3" = c(qnorm((1:51) / 52, sd = 1), rep(0, 50)),
  "sparse 2" = c(qnorm((1:31) / 32, sd = 1), rep(0, 70)),
  "sparse 1" = c(rep(c(rep(0.5, 3), 1, 2), 2) * c(rep(1, 5), rep(-1, 5)), rep(0, 91)),
  " " = c()
)
ps <- lapply(ps, function(x) if (!is.null(x)) {x / max(abs(x))})

table_results <- results %>%
  rename(Distribution = distribution) %>%
  mutate(covered = lower <= truth & truth <= upper) %>%
  group_by(Distribution, method, n) %>%
  summarise(coverage = mean(covered)) %>%
  ungroup() %>%
  mutate(coverage = glue::glue("{round(coverage, 3) * 100}%")) %>%
  pivot_wider(names_from = n, values_from = coverage) %>%
  mutate(
    ` ` = "",
    Distribution = stringr::str_to_title(Distribution),
    distribution_order = factor(Distribution, levels = stringr::str_to_title(names(ps))),
    Method = method_labels[method]
  ) %>%
  arrange(distribution_order, Method) %>%
  dplyr::select(` `, Distribution, Method, `50`, `100`, `400`, `1000`) %>%
  group_by(Distribution) %>%
  mutate(
    Distribution = ifelse(dplyr::row_number() == 2, " ", Distribution),
    Distribution = factor(Distribution, levels = stringr::str_to_title(names(ps)))
  ) %>%
  dplyr::select(!Method)


ps <- ps[stringr::str_to_lower(table_results$Distribution)]
names(ps) <- paste0('distribution_table_', letters[1:length(ps)])

# Assuming wide_data is your data frame
if (interactive()) {
  path_pre <- "out/"
} else {
  path_pre <- "code/out/"
}
kbl(table_results,
    format = "latex",
    align = "ccccc",  # Alignments for the columns
    booktabs = TRUE,
    digits = 3,
    linesep = "",
    table.envir = NULL) %>%
  add_header_above(c("  " = 2, "Sample Size" = 4)) %>%
  column_spec(1, image = spec_hist(ps, breaks = 20, dir='out', file_type='pdf', file = glue("./{path_pre}{names(ps)}.pdf"))) %>%
  stringr::str_replace_all('file:.*?/out/', '') %>%
  write(glue('{path_pre}/table1.tex'))

