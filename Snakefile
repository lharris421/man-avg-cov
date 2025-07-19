# Snakefile

import os

# ensure the RDS directory exists
os.makedirs("code/rds", exist_ok=True)

rule all:
    input:
        "avg-cov.pdf",
        "code/out/figure1.pdf"

rule laplace_relaxed_lasso_posterior:
    input:
        script = "code/scripts/laplace_relaxed_lasso_posterior.R"
    output:
        "code/rds/laplace_relaxed_lasso_posterior.rds"
    shell:
        "Rscript {input.script}"
        
rule ridge_posterior_converge:
    input:
        script = "code/scripts/ridge_posterior_converge.R"
    output:
        "code/rds/ridge_posterior_converge.rds"
    shell:
        "Rscript {input.script}"
        
rule laplace_selective_inference:
    input:
        script = "code/scripts/laplace_selective_inference.R"
    output:
        "code/rds/laplace_selective_inference.rds"
    shell:
        "Rscript {input.script}"
        
rule laplace_desparsified_lasso:
    input:
        script = "code/scripts/laplace_desparsified_lasso.R"
    output:
        "code/rds/laplace_desparsified_lasso.rds"
    shell:
        "Rscript {input.script}"
        
rule normal_relaxed_lasso_posterior:
    input:
        script = "code/scripts/normal_relaxed_lasso_posterior.R"
    output:
        "code/rds/normal_relaxed_lasso_posterior.rds"
    shell:
        "Rscript {input.script}"

rule t_relaxed_lasso_posterior:
    input:
        script = "code/scripts/t_relaxed_lasso_posterior.R"
    output:
        "code/rds/t_relaxed_lasso_posterior.rds"
    shell:
        "Rscript {input.script}"
        
rule uniform_relaxed_lasso_posterior:
    input:
        script = "code/scripts/uniform_relaxed_lasso_posterior.R"
    output:
        "code/rds/uniform_relaxed_lasso_posterior.rds"
    shell:
        "Rscript {input.script}"
        
rule beta_relaxed_lasso_posterior:
    input:
        script = "code/scripts/beta_relaxed_lasso_posterior.R"
    output:
        "code/rds/beta_relaxed_lasso_posterior.rds"
    shell:
        "Rscript {input.script}"
        
rule sparse1_relaxed_lasso_posterior:
    input:
        script = "code/scripts/sparse1_relaxed_lasso_posterior.R"
    output:
        "code/rds/sparse1_relaxed_lasso_posterior.rds"
    shell:
        "Rscript {input.script}"
        
rule sparse2_relaxed_lasso_posterior:
    input:
        script = "code/scripts/sparse2_relaxed_lasso_posterior.R"
    output:
        "code/rds/sparse2_relaxed_lasso_posterior.rds"
    shell:
        "Rscript {input.script}"
        
rule sparse3_relaxed_lasso_posterior:
    input:
        script = "code/scripts/sparse3_relaxed_lasso_posterior.R"
    output:
        "code/rds/sparse3_relaxed_lasso_posterior.rds"
    shell:
        "Rscript {input.script}"
        
rule whoari_relaxed_lasso_posterior:
    input:
        script = "code/scripts/whoari_relaxed_lasso_posterior.R"
    output:
        "code/rds/whoari_relaxed_lasso_posterior.rds"
    shell:
        "Rscript {input.script}"
        
rule Scheetz2006_relaxed_lasso_posterior:
    input:
        script = "code/scripts/Scheetz2006_relaxed_lasso_posterior.R"
    output:
        "code/rds/Scheetz2006_relaxed_lasso_posterior.rds"
    shell:
        "Rscript {input.script}"
        
rule whoari_selective_inference:
    input:
        script = "code/scripts/whoari_selective_inference.R"
    output:
        "code/rds/whoari_selective_inference.rds"
    shell:
        "Rscript {input.script}"
        
rule Scheetz2006_selective_inference:
    input:
        script = "code/scripts/Scheetz2006_selective_inference.R"
    output:
        "code/rds/Scheetz2006_selective_inference.rds"
    shell:
        "Rscript {input.script}"
        
rule whoari_desparsified_lasso:
    input:
        script = "code/scripts/whoari_desparsified_lasso.R"
    output:
        "code/rds/whoari_desparsified_lasso.rds"
    shell:
        "Rscript {input.script}"
        
rule Scheetz2006_desparsified_lasso:
    input:
        script = "code/scripts/Scheetz2006_desparsified_lasso.R"
    output:
        "code/rds/Scheetz2006_desparsified_lasso.rds"
    shell:
        "Rscript {input.script}"
        
rule highcorr:
    input:
        script = "code/scripts/highcorr.R"
    output:
        "code/rds/highcorr.rds"
    shell:
        "Rscript {input.script}"
        
rule laplace_corr_relaxed_lasso_posterior:
    input:
        script = "code/scripts/laplace_corr_relaxed_lasso_posterior.R"
    output:
        "code/rds/laplace_corr_relaxed_lasso_posterior.rds"
    shell:
        "Rscript {input.script}"

rule laplace_gam_fits:
    input:
        script = "code/scripts/laplace_gam_fits.R",
        rds = "code/rds/laplace_relaxed_lasso_posterior.rds"
    output:
        "code/rds/laplace_gam_fits.rds"
    shell:
        "Rscript {input.script}"
        
rule ridge_gam_fits:
    input:
        script = "code/scripts/ridge_gam_fits.R",
        rds = "code/rds/ridge_posterior_converge.rds"
    output:
        "code/rds/ridge_gam_fits.rds"
    shell:
        "Rscript {input.script}"
        
rule laplace_gam_fits_selective_inference:
    input:
        script = "code/scripts/laplace_gam_fits_selective_inference.R",
        rds = "code/rds/laplace_selective_inference.rds"
    output:
        "code/rds/laplace_gam_fits_selective_inference.rds"
    shell:
        "Rscript {input.script}"
        
rule laplace_gam_fits_desparsified_lasso:
    input:
        script = "code/scripts/laplace_gam_fits_desparsified_lasso.R",
        rds = "code/rds/laplace_desparsified_lasso.rds"
    output:
        "code/rds/laplace_gam_fits_desparsified_lasso.rds"
    shell:
        "Rscript {input.script}"
        
rule across_lambda_coverage:
    input:
        script = "code/scripts/across_lambda_coverage.R"
    output:
        "code/rds/across_lambda_coverage.rds"
    shell:
        "Rscript {input.script}"
        
rule across_lambda_gam:
    input:
        script = "code/scripts/across_lambda_gam.R",
        rds    = "code/rds/across_lambda_coverage.rds"
    output:
        "code/rds/across_lambda_gam.rds"
    shell:
        "Rscript {input.script}"

rule figure1:
    input:
        script = "code/figure1.R",
        gam_rds = "code/rds/laplace_gam_fits.rds"
    output:
        "code/out/figure1.pdf"
    shell:
        "Rscript {input.script}"
        
rule figure2:
    input:
        script = "code/figure2.R",
        gam_rds = "code/rds/ridge_gam_fits.rds"
    output:
        "code/out/figure2.pdf"
    shell:
        "Rscript {input.script}"
        
rule figure3:
    input:
        script = "code/figure3.R",
        rds1 = "code/rds/laplace_relaxed_lasso_posterior.rds",
        rds2 = "code/rds/laplace_corr_relaxed_lasso_posterior.rds"
    output:
        "code/out/figure3.pdf"
    shell:
        "Rscript {input.script}"
        
rule figure4:
    input:
        script = "code/figure4.R",
        rds1 = "code/rds/across_lambda_coverage.rds",
        rds2 = "code/rds/across_lambda_gam.rds"
    output:
        "code/out/figure4.png"
    shell:
        "Rscript {input.script}"
        
rule figure5:
    input:
        script = "code/figure5.R",
        rds = "code/rds/highcorr.rds"
    output:
        "code/out/figure5.pdf"
    shell:
        "Rscript {input.script}"
        
rule figure6:
    input:
        script = "code/figure6.R",
        rds1 = "code/rds/laplace_gam_fits.rds",
        rds2 = "code/rds/laplace_gam_fits_selective_inference.rds",
        rds3 = "code/rds/laplace_gam_fits_desparsified_lasso.rds"
    output:
        "code/out/figure6.pdf"
    shell:
        "Rscript {input.script}"
        
rule figure7:
    input:
        script = "code/figure7.R",
        rds1 = "code/rds/laplace_relaxed_lasso_posterior.rds",
        rds2 = "code/rds/laplace_selective_inference.rds",
        rds3 = "code/rds/laplace_desparsified_lasso.rds"
    output:
        "code/out/figure7.pdf"
    shell:
        "Rscript {input.script}"
        
        
rule figure8:
    input:
        script = "code/figure8.R",
        rds1 = "code/rds/whoari_relaxed_lasso_posterior.rds",
        rds2 = "code/rds/whoari_selective_inference.rds",
        rds3 = "code/rds/whoari_desparsified_lasso.rds"
    output:
        "code/out/figure8.pdf"
    shell:
        "Rscript {input.script}"
        
# rule figure9:
#     input:
#         script = "code/figure9.R",
#         rds1 = "code/rds/Scheetz2006_relaxed_lasso_posterior.rds.rds",
#         rds2 = "code/rds/Scheetz2006_selective_inference.rds",
#         rds3 = "code/rds/Scheetz2006_desparsified_lasso.rds"
#     output:
#         "code/out/figure9.pdf"
#     shell:
#         "Rscript {input.script}"
        
rule table1:
    input:
        script = "code/table1.R",
        rds1 = "code/rds/laplace_relaxed_lasso_posterior.rds",
        rds2 = "code/rds/normal_relaxed_lasso_posterior.rds",
        rds3 = "code/rds/t_relaxed_lasso_posterior.rds",
        rds4 = "code/rds/uniform_relaxed_lasso_posterior.rds",
        rds5 = "code/rds/beta_relaxed_lasso_posterior.rds",
        rds6 = "code/rds/sparse1_relaxed_lasso_posterior.rds",
        rds7 = "code/rds/sparse2_relaxed_lasso_posterior.rds",
        rds8 = "code/rds/sparse3_relaxed_lasso_posterior.rds"
    output:
        "code/out/table1.tex"
    shell:
        "Rscript {input.script}"
        
rule tableS1:
    input:
        script = "code/tableS1.R",
        rds = "code/rds/laplace_selective_inference.rds"
    output:
        "code/out/tableS1.tex"
    shell:
        "Rscript {input.script}"

rule manuscript:
    input:
        "abstract.tex",
        "avg-cov.tex",
        "main.tex",
        "code/out/figure1.pdf",
        "code/out/figure2.pdf",
        "code/out/figure3.pdf",
        "code/out/figure4.png",
        "code/out/figure5.pdf",
        "code/out/figure6.pdf",
        "code/out/figure7.pdf",
        "code/out/figure8.pdf",
        "code/out/table1.tex",
        "code/out/tableS1.tex"
    output:
        "avg-cov.pdf"
    shell:
        "cleantex -btq avg-cov.tex"
