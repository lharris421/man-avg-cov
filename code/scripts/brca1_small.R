## Build a small version of data/brca1.rds for smoke-testing the pipeline.
##
## The full dataset (1,111 TCGA-BRCA tumour samples x 18,480 genes, log2
## expression; produced by brca1.R) is too large to ship with the repository
## and too slow for a quick end-to-end check of the slower methods. This script
## keeps a random subset of samples and the most variable genes, always
## including BRCA1 (the response), and writes data/brca1_small.rds.
##
## Set `smoke: true` in config.yaml (or pass `--config smoke=true` to
## snakemake) to run the data analysis on the small dataset instead.
##
## Regenerate from the repository root with
##   Rscript code/scripts/brca1_small.R
## or interactively from code/. The result is deterministic given --seed.

library(optparse)
option_list <- list(
  make_option(c("--n"),    type="integer", default=150,  help="samples to keep"),
  make_option(c("--p"),    type="integer", default=300,  help="genes to keep, not counting BRCA1"),
  make_option(c("--seed"), type="double",  default=1234)
)
opt <- parse_args(OptionParser(option_list=option_list))

if (interactive()) {
  source("scripts/setup.R")
} else {
  source("./code/scripts/setup.R")
}

full <- readRDS(glue("{data_dir}/brca1.rds"))
stopifnot(is.matrix(full), "BRCA1" %in% colnames(full),
          opt$n <= nrow(full), opt$p < ncol(full))

set.seed(opt$seed)
rows  <- sort(sample(nrow(full), opt$n))
genes <- setdiff(colnames(full), "BRCA1")
vars  <- apply(full[rows, genes], 2, var)
keep  <- c("BRCA1", names(sort(vars, decreasing = TRUE))[seq_len(opt$p)])

small <- full[rows, keep]
out   <- glue("{data_dir}/brca1_small.rds")
saveRDS(small, out)
cat(sprintf("Wrote %s: %d samples x %d columns (BRCA1 + %d genes)\n",
            out, nrow(small), ncol(small), opt$p))
