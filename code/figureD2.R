if (interactive()) {
  source("setup.R")
} else {
  source("code/setup.R")
}


option_list <- list(
  make_option(c("--loc"), type="character", default=glue("{res_dir}/"))
)
opt <- parse_args(OptionParser(option_list=option_list))

methods <- c("selectiveinference")

results_lookup <- expand.grid(
  method = methods
)

results <- list()
for (i in 1:nrow(results_lookup)) {
  results[[i]] <- readRDS(glue("{opt$loc}rds/whoari_{results_lookup[i,'method']}.rds"))
}

results <- bind_rows(results) %>%
  mutate(method = method_labels[method],
         estimate = ifelse(method == "RL Posterior", coef, estimate))

if (interactive()) {
  pdf("out/figureD2.pdf", height = 3.9, width = 5.9)
} else {
  pdf("code/out/figureD2.pdf", height = 3.9, width = 5.9)
}
plot_ci_comparison(results, nvars = 32, ref = "Selective Inference") +
  theme(strip.text = element_blank())
dev.off()
