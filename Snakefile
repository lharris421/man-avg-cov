import os

# ensure the RDS directory exists
os.makedirs("code/rds", exist_ok=True)

configfile: "config.yaml"
ITER = config["iterations"]
SEED = config["seed"]
DESPARSIFIED = config.get("desparsified", False)
os.makedirs(f"code/rds/{ITER}", exist_ok=True)

def make_inputs(fig, p1, p2, p3):
    d = {
        "script": f"code/figure{fig}.R",
        "rds1":   f"code/rds/{ITER}/{p1}.rds",
        "rds2":   f"code/rds/{ITER}/{p2}.rds",
    }
    if DESPARSIFIED:
        d["rds3"] = f"code/rds/{ITER}/{p3}.rds"
    return d

rule all:
    input:
        "avg-cov.pdf",
        "code/out/figure1.pdf",
        "code/out/figure2.pdf",
        "code/out/figure3.pdf",
        "code/out/figure4.png",
        "code/out/figure5.pdf",
        "code/out/figure6.pdf",
        "code/out/figure7.pdf",
        "code/out/figure8.pdf",
        "code/out/figure9.pdf",
        "code/out/figureA1.pdf",
        "code/out/figureC1.pdf",
        "code/out/figureF1.pdf",
        "code/out/table1.tex",
        "code/out/tableD1.tex",
        "code/out/tableE1.tex",
        "code/out/tableG1.tex"

rule laplace_relaxed_lasso_posterior:
    input:
        script = "code/scripts/laplace_relaxed_lasso_posterior.R"
    output:
        "code/rds/{ITER}/laplace_relaxed_lasso_posterior.rds"
    shell:
        "Rscript {input.script} --iterations {ITER} --seed {SEED}"
        
rule ridge_posterior_converge:
    input:
        script = "code/scripts/ridge_posterior_converge.R"
    output:
        "code/rds/{ITER}/ridge_posterior_converge.rds"
    shell:
        "Rscript {input.script} --iterations {ITER} --seed {SEED}"
        
rule laplace_selective_inference:
    input:
        script = "code/scripts/laplace_selective_inference.R"
    output:
        "code/rds/{ITER}/laplace_selective_inference.rds"
    shell:
        "Rscript {input.script} --iterations {ITER} --seed {SEED}"
        
rule laplace_desparsified_lasso:
    input:
        script = "code/scripts/laplace_desparsified_lasso.R"
    output:
        "code/rds/{ITER}/laplace_desparsified_lasso.rds"
    shell:
        "Rscript {input.script} --iterations {ITER} --seed {SEED}"
        
rule laplace_traditional_bootstrap:
    input:
        script = "code/scripts/laplace_traditional_bootstrap.R"
    output:
        "code/rds/{ITER}/laplace_traditional_bootstrap.rds"
    shell:
        "Rscript {input.script} --iterations {ITER} --seed {SEED}"
        
rule normal_relaxed_lasso_posterior:
    input:
        script = "code/scripts/normal_relaxed_lasso_posterior.R"
    output:
        "code/rds/{ITER}/normal_relaxed_lasso_posterior.rds"
    shell:
        "Rscript {input.script} --iterations {ITER} --seed {SEED}"

rule t_relaxed_lasso_posterior:
    input:
        script = "code/scripts/t_relaxed_lasso_posterior.R"
    output:
        "code/rds/{ITER}/t_relaxed_lasso_posterior.rds"
    shell:
        "Rscript {input.script} --iterations {ITER} --seed {SEED}"
        
rule uniform_relaxed_lasso_posterior:
    input:
        script = "code/scripts/uniform_relaxed_lasso_posterior.R"
    output:
        "code/rds/{ITER}/uniform_relaxed_lasso_posterior.rds"
    shell:
        "Rscript {input.script} --iterations {ITER} --seed {SEED}"
        
rule beta_relaxed_lasso_posterior:
    input:
        script = "code/scripts/beta_relaxed_lasso_posterior.R"
    output:
        "code/rds/{ITER}/beta_relaxed_lasso_posterior.rds"
    shell:
        "Rscript {input.script} --iterations {ITER} --seed {SEED}"
        
rule sparse1_relaxed_lasso_posterior:
    input:
        script = "code/scripts/sparse1_relaxed_lasso_posterior.R"
    output:
        "code/rds/{ITER}/sparse1_relaxed_lasso_posterior.rds"
    shell:
        "Rscript {input.script} --iterations {ITER} --seed {SEED}"
        
rule sparse1_relaxed_MCP_posterior:
    input:
        script = "code/scripts/sparse1_relaxed_MCP_posterior.R"
    output:
        "code/rds/{ITER}/sparse1_relaxed_MCP_posterior.rds"
    shell:
        "Rscript {input.script} --iterations {ITER} --seed {SEED}"
        
rule sparse2_relaxed_lasso_posterior:
    input:
        script = "code/scripts/sparse2_relaxed_lasso_posterior.R"
    output:
        "code/rds/{ITER}/sparse2_relaxed_lasso_posterior.rds"
    shell:
        "Rscript {input.script} --iterations {ITER} --seed {SEED}"
        
rule sparse3_relaxed_lasso_posterior:
    input:
        script = "code/scripts/sparse3_relaxed_lasso_posterior.R"
    output:
        "code/rds/{ITER}/sparse3_relaxed_lasso_posterior.rds"
    shell:
        "Rscript {input.script} --iterations {ITER} --seed {SEED}"
        
rule whoari_relaxed_lasso_posterior:
    input:
        script = "code/scripts/whoari_relaxed_lasso_posterior.R"
    output:
        "code/rds/whoari_relaxed_lasso_posterior.rds"
    shell:
        "Rscript {input.script} --seed {SEED}"
        
rule Scheetz2006_relaxed_lasso_posterior:
    input:
        script = "code/scripts/Scheetz2006_relaxed_lasso_posterior.R"
    output:
        "code/rds/Scheetz2006_relaxed_lasso_posterior.rds"
    shell:
        "Rscript {input.script} --seed {SEED}"
        
rule whoari_selective_inference:
    input:
        script = "code/scripts/whoari_selective_inference.R"
    output:
        "code/rds/whoari_selective_inference.rds"
    shell:
        "Rscript {input.script} --seed {SEED}"
        
rule Scheetz2006_selective_inference:
    input:
        script = "code/scripts/Scheetz2006_selective_inference.R"
    output:
        "code/rds/Scheetz2006_selective_inference.rds"
    shell:
        "Rscript {input.script} --seed {SEED}"
        
rule whoari_desparsified_lasso:
    input:
        script = "code/scripts/whoari_desparsified_lasso.R"
    output:
        "code/rds/whoari_desparsified_lasso.rds"
    shell:
        "Rscript {input.script} --seed {SEED}"
        
rule Scheetz2006_desparsified_lasso:
    input:
        script = "code/scripts/Scheetz2006_desparsified_lasso.R"
    output:
        "code/rds/Scheetz2006_desparsified_lasso.rds"
    shell:
        "Rscript {input.script} --seed {SEED}"
        
rule highcorr:
    input:
        script = "code/scripts/highcorr.R"
    output:
        f"code/rds/{ITER}/highcorr.rds"
    shell:
        "Rscript {input.script} --iterations {ITER} --seed {SEED}"
        
rule laplace_corr_relaxed_lasso_posterior:
    input:
        script = "code/scripts/laplace_corr_relaxed_lasso_posterior.R"
    output:
        "code/rds/{ITER}/laplace_corr_relaxed_lasso_posterior.rds"
    shell:
        "Rscript {input.script} --iterations {ITER} --seed {SEED}"

rule laplace_gam_fits:
    input:
        script = "code/scripts/laplace_gam_fits.R",
        rds = "code/rds/{ITER}/laplace_relaxed_lasso_posterior.rds"
    output:
        "code/rds/{ITER}/laplace_gam_fits.rds"
    shell:
        "Rscript {input.script} --iterations {ITER}"
        
rule ridge_gam_fits:
    input:
        script = "code/scripts/ridge_gam_fits.R",
        rds = "code/rds/{ITER}/ridge_posterior_converge.rds"
    output:
        "code/rds/{ITER}/ridge_gam_fits.rds"
    shell:
        "Rscript {input.script} --iterations {ITER}"
        
rule laplace_gam_fits_selective_inference:
    input:
        script = "code/scripts/laplace_gam_fits_selective_inference.R",
        rds = "code/rds/{ITER}/laplace_selective_inference.rds"
    output:
        "code/rds/{ITER}/laplace_gam_fits_selective_inference.rds"
    shell:
        "Rscript {input.script} --iterations {ITER}"
        
rule laplace_gam_fits_desparsified_lasso:
    input:
        script = "code/scripts/laplace_gam_fits_desparsified_lasso.R",
        rds = "code/rds/{ITER}/laplace_desparsified_lasso.rds"
    output:
        "code/rds/{ITER}/laplace_gam_fits_desparsified_lasso.rds"
    shell:
        "Rscript {input.script} --iterations {ITER}"
        
rule laplace_gam_fits_traditional_bootstrap:
    input:
        script = "code/scripts/laplace_gam_fits_traditional_bootstrap.R",
        rds = "code/rds/{ITER}/laplace_traditional_bootstrap.rds"
    output:
        "code/rds/{ITER}/laplace_gam_fits_traditional_bootstrap.rds"
    shell:
        "Rscript {input.script} --iterations {ITER}"
        
rule across_lambda_coverage:
    input:
        script = "code/scripts/across_lambda_coverage.R"
    output:
        "code/rds/{ITER}/across_lambda_coverage.rds"
    shell:
        "Rscript {input.script} --iterations {ITER} --seed {SEED}"
        
rule across_lambda_gam:
    input:
        script = "code/scripts/across_lambda_gam.R",
        rds    = "code/rds/{ITER}/across_lambda_coverage.rds"
    output:
        "code/rds/{ITER}/across_lambda_gam.rds"
    shell:
        "Rscript {input.script} --iterations {ITER}"
        
rule bias_decomposition:
    input:
        script = "code/scripts/bias_decomposition.R",
    output:
        "code/rds/{ITER}/bias_decomposition.rds"
    shell:
        "Rscript {input.script} --iterations {ITER} --seed {SEED}"
        
rule stability_selection:
    input:
        script = "code/scripts/stability_selection.R",
    output:
        "code/rds/{ITER}/stability_selection.rds"
    shell:
        "Rscript {input.script} --iterations {ITER} --seed {SEED}"

rule figure1:
    input:
        script = "code/figure1.R",
        gam_rds = "code/rds/{ITER}/laplace_gam_fits.rds"
    output:
        "code/out/figure1.pdf"
    shell:
        "Rscript {input.script} --iterations {ITER}"
        
rule figure2:
    input:
        script = "code/figure2.R",
        gam_rds = "code/rds/{ITER}/ridge_gam_fits.rds"
    output:
        "code/out/figure2.pdf"
    shell:
        "Rscript {input.script} --iterations {ITER}"
        
rule figure3:
    input:
        script = "code/figure3.R",
        rds1 = "code/rds/{ITER}/laplace_relaxed_lasso_posterior.rds",
        rds2 = "code/rds/{ITER}/laplace_corr_relaxed_lasso_posterior.rds"
    output:
        "code/out/figure3.pdf"
    shell:
        "Rscript {input.script} --iterations {ITER}"
        
rule figure4:
    input:
        script = "code/figure4.R",
        rds1 = "code/rds/{ITER}/across_lambda_coverage.rds",
        rds2 = "code/rds/{ITER}/across_lambda_gam.rds"
    output:
        "code/out/figure4.png"
    shell:
        "Rscript {input.script} --iterations {ITER}"
        
rule figure5:
    input:
        script = "code/figure5.R",
        rds = f"code/rds/{ITER}/highcorr.rds"
    output:
        "code/out/figure5.pdf"
    shell:
        "Rscript {input.script} --iterations {ITER}"
    
rule figure6:
    input: make_inputs(6, "laplace_gam_fits", "laplace_gam_fits_selective_inference", "laplace_gam_fits_desparsified_lasso")
    output:
        "code/out/figure6.pdf"
    shell:
        "Rscript {input.script} --iterations {ITER} {'--desparsified' if DESPARSIFIED else ''}"
        
rule figure7:
    input:make_inputs(7,"laplace_relaxed_lasso_posterior","laplace_selective_inference","laplace_desparsified_lasso")
    output:
        "code/out/figure7.pdf"
    shell:
        "Rscript {input.script} --iterations {ITER} {'--desparsified' if DESPARSIFIED else ''}"
        
        
rule figure8:
    input: make_inputs(8,"whoari_relaxed_lasso_posterior","whoari_selective_inference","whoari_desparsified_lasso")
    output:
        "code/out/figure8.pdf"
    shell:
        "Rscript {input.script} --iterations {ITER} {'--desparsified' if DESPARSIFIED else ''}"
        
rule figure9:
    input:make_inputs(9,"Scheetz2006_relaxed_lasso_posterior","Scheetz2006_selective_inference","Scheetz2006_desparsified_lasso")
    output:
        "code/out/figure9.pdf"
    shell:
        "Rscript {input.script} --iterations {ITER} {'--desparsified' if DESPARSIFIED else ''}"

rule figureA1:
    input:
        script = "code/figureA1.R",
        rds = "code/rds/{ITER}/laplace_gam_fits_traditional_bootstrap.rds",
    output:
        "code/out/figureA1.pdf"
    shell:
        "Rscript {input.script} --iterations {ITER}"
        
rule figureC1:
    input:
        script = "code/figureC1.R",
        rds = "code/rds/{ITER}/laplace_gam_fits.rds",
    output:
        "code/out/figureC1.pdf"
    shell:
        "Rscript {input.script} --iterations {ITER}"
        
rule figureF1:
    input:
        script = "code/figureF1.R",
        rds = "code/rds/{ITER}/bias_decomposition.rds",
    output:
        "code/out/figureF1.pdf"
    shell:
        "Rscript {input.script} --iterations {ITER}"
        
rule table1:
    input:
        script = "code/table1.R",
        rds1 = "code/rds/{ITER}/laplace_relaxed_lasso_posterior.rds",
        rds2 = "code/rds/{ITER}/normal_relaxed_lasso_posterior.rds",
        rds3 = "code/rds/{ITER}/t_relaxed_lasso_posterior.rds",
        rds4 = "code/rds/{ITER}/uniform_relaxed_lasso_posterior.rds",
        rds5 = "code/rds/{ITER}/beta_relaxed_lasso_posterior.rds",
        rds6 = "code/rds/{ITER}/sparse1_relaxed_lasso_posterior.rds",
        rds7 = "code/rds/{ITER}/sparse2_relaxed_lasso_posterior.rds",
        rds8 = "code/rds/{ITER}/sparse3_relaxed_lasso_posterior.rds"
    output:
        "code/out/table1.tex"
    shell:
        "Rscript {input.script} --iterations {ITER}"
        
rule tableD1:
    input:
        script = "code/tableD1.R",
        rds = "code/rds/{ITER}/laplace_selective_inference.rds"
    output:
        "code/out/tableD1.tex"
    shell:
        "Rscript {input.script} --iterations {ITER}"
        
rule tableE1:
    input:
        script = "code/tableE1.R",
        rds1 = "code/rds/{ITER}/sparse1_relaxed_lasso_posterior.rds",
        rds2 = "code/rds/{ITER}/sparse1_relaxed_MCP_posterior.rds"
    output:
        "code/out/tableE1.tex"
    shell:
        "Rscript {input.script} --iterations {ITER}"
        
rule tableG1:
    input:
        script = "code/tableG1.R",
        rds = "code/rds/{ITER}/stability_selection.rds",
    output:
        "code/out/tableG1.tex"
    shell:
        "Rscript {input.script} --iterations {ITER}"

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
        "code/out/figure9.pdf",
        "code/out/figureA1.pdf",
        "code/out/figureC1.pdf",
        "code/out/figureF1.pdf",
        "code/out/table1.tex",
        "code/out/tableD1.tex",
        "code/out/tableE1.tex",
        "code/out/tableG1.tex"
    output:
        "avg-cov.pdf"
    shell:
        "cleantex -btq avg-cov.tex"
