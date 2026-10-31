library(TCGAbiolinks)
library(SummarizedExperiment)
library(dplyr)
library(tibble)
library(edgeR)

query <- GDCquery(
  project = "TCGA-BRCA",
  data.category = "Transcriptome Profiling",
  data.type = "Gene Expression Quantification",
  workflow.type = "STAR - Counts"
)

GDCdownload(query, directory = "../data/GDCdata")
brca <- GDCprepare(query, directory = "../data/GDCdata")

sample_types <- TCGAquery_SampleTypes(
  colnames(brca),   # vector of barcodes
  "TP"              # sample type: primary tumor
)

brca_tumor <- brca[, sample_types]

counts <- assay(brca_tumor)
gene_info <- rowData(brca_tumor)
gene_symbols <- gene_info$gene_name
rownames(counts) <- gene_symbols

dge <- DGEList(counts = gene_mat)
cpm_mat <- cpm(dge)  # log = FALSE by default

keep_genes <- rowMeans(cpm_mat > 1) >= 0.1
gene_mat_filt <- gene_mat[keep_genes, ]

log_expr <- log2(gene_mat_filt + 1)
final_df <- t(log_expr)

saveRDS(final_df, "../data/brca1.rds")
