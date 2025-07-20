library(optparse)
option_list <- list(
  make_option(c("--iterations"), type="integer", default=1000)
)
opt <- parse_args(OptionParser(option_list=option_list))
iterations <- opt$iterations

if (interactive()) {
  source("scripts/setup.R")
  results <- readRDS("rds/{iterations}/bias_decomposition.rds")
} else {
  source("code/scripts/setup.R")
  results <- readRDS("code/rds/{iterations}/bias_decomposition.rds")
}


plots <- bias_decomp_plots(results, params)
plots[[1]]  <- plots[[1]]  + coord_cartesian(xlim = c(-0.1, 0.1))
plots[[2]]  <- plots[[2]]  + coord_cartesian(xlim = c(-0.1, 0.1))
plots[[3]]  <- plots[[3]]  + coord_cartesian(xlim = c(-0.1, 0.1))

# Create density plots using ggplot2
if (interactive()) {
  pdf("out/figureF1.pdf", height = 4, width = 8)
} else {
  pdf("code/out/figureF1.pdf", height = 4, width = 8)
}
plots[[3]] / plots[[2]] / plots[[1]] +
  patchwork::plot_layout(guides = "collect", axes = "collect")
dev.off()
