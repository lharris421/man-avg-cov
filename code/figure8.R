if (interactive()) {
  source("setup.R")
} else {
  source("code/setup.R")
}

option_list <- list(
  make_option(c("--alpha"), type="integer", default=5),
  make_option(c("-d", "--desparsified"), action="store_true", default=FALSE),
  make_option(c("--loc"), type="character", default=glue("{res_dir}/"))
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
  results[[i]] <- readRDS(glue("{opt$loc}rds/{alpha}/brca1_{results_lookup[i,'method']}.rds"))
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
  pdf("out/figure8.pdf", height = 3.9, width = 5.9)
} else {
  pdf("code/out/figure8.pdf", height = 3.9, width = 5.9)
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
  geom_errorbar(aes(xmin = lower, xmax = upper, y = variable), width = 0) +
  geom_segment(aes(x = lowerF, xend = lowerF,
                   y = as.numeric(variable) - 0.5,
                   yend = as.numeric(variable) + 0.5)) +
  geom_segment(aes(x = upperF, xend = upperF,
                   y = as.numeric(variable) - 0.5,
                   yend = as.numeric(variable) + 0.5)) +
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
dev.off()

library(msigdbr)
library(dplyr)
library(stringr)

# 1) Pull CGP and keep BRCA1 / breast-related signatures
cgp <- msigdbr(species = "Homo sapiens", category = "C2", subcategory = "CGP") %>%
  mutate(gs_name_l = str_to_lower(gs_name)) %>%
  filter(str_detect(gs_name_l, "brca1|breast_cancer|mammary")) %>%
  distinct(gs_name, gene_symbol)

# How many signatures did we keep?
n_sets <- n_distinct(cgp$gs_name)
n_sets

# 2) Count how often each gene appears across these signatures
validated_genes <- cgp %>%
  dplyr::count(gene_symbol, name = "n_sets_present") %>%
  filter(n_sets_present >= 1) %>%
  pull(gene_symbol)

length(validated_genes)
validated_brca1_genes <- validated_genes


msigdb_genes_full <- validated_brca1_genes
length(msigdb_genes_full)
msigdb_genes <- unique(msigdb_genes_full[msigdb_genes_full %in% unique(cis$variable)])

length(msigdb_genes) / length(unique(cis$variable))


cis$method <- factor(cis$method, levels = c("Desparsified Lasso", "Selective Inference", "PIPE Posterior"))
cis %>%
  group_by(variable) %>%
  arrange(method) %>%
  mutate(
    estimate = ifelse(is.na(estimate), NA, last(estimate))
  ) %>%
  filter(method == "PIPE Posterior" & (estimate == 0) & (lower >= 0 | upper <= 0)) %>% nrow()

cis %>%
  filter(lower >= 0 | upper <= 0) %>%
  mutate(in_msigdb = variable %in% msigdb_genes_full) %>%
  group_by(method) %>%
  summarise(in_db = sum(in_msigdb), sig = n()) %>%
  mutate(ratio = in_db / sig)

