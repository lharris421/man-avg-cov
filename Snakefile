import os

# ensure the RDS directory exists
os.makedirs("code/rds", exist_ok=True)

configfile: "config.yaml"
ITER = config["iterations"]
SEED = config["seed"]
DESPARSIFIED = config.get("desparsified", False)
os.makedirs(f"code/rds/{ITER}", exist_ok=True)

def make_inputs(fig, p1, p2, p3, iter=None):
    # build the base RDS directory, with or without the iteration folder
    base = f"code/rds/{iter}" if iter else "code/rds"

    d = {
        "script": f"code/figure{fig}.R",
        "rds1":   f"{base}/{p1}.rds",
        "rds2":   f"{base}/{p2}.rds",
    }
    if DESPARSIFIED:
        d["rds3"] = f"{base}/{p3}.rds"
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

rule distribution_results:
    input:
        script = "code/scripts/distribution_results.R"
    output:
        f"code/rds/{ITER}/original/{{distribution}}_{{corr}}_{{rho}}_{{n}}_{{p}}_{{sigma}}_{{snr}}_{{method}}.rds"
    shell:
        "Rscript {input.script} "
        "--iterations {ITER} "
        "--seed {SEED} "
        "--n {wildcards.n} "
        "--p {wildcards.p} "
        "--sigma {wildcards.sigma} "
        "--snr {wildcards.snr} " ## Signal as a percent of noise
        "--distribution {wildcards.distribution} "
        "--corr {wildcards.corr} "
        "--rho {wildcards.rho} " ## As a percent
        "--method {wildcards.method}"
        
rule highcorr_results:
    input:
        script = "code/scripts/highcorr_results.R"
    output:
        f"code/rds/{ITER}/original/highcorr_{{method}}.rds"
    shell:
        "Rscript {input.script} "
        "--iterations {ITER} "
        "--seed {SEED} "
        "--method {wildcards.method}"
        
rule fit_gam:
    input:
        script = "code/scripts/fit_gam.R",
        rds    = f"code/rds/{ITER}/original/{{distribution}}_{{corr}}_{{rho}}_{{n}}_{{p}}_{{sigma}}_{{snr}}_{{method}}.rds"
    output:
        f"code/rds/{ITER}/gam/{{distribution}}_{{corr}}_{{rho}}_{{n}}_{{p}}_{{sigma}}_{{snr}}_{{method}}.rds"
    shell:
        "Rscript {input.script} "
        "--iterations {ITER} "
        "--seed {SEED} "
        "--n {wildcards.n} "
        "--p {wildcards.p} "
        "--sigma {wildcards.sigma} "
        "--snr {wildcards.snr} " ## Signal as a percent of noise
        "--distribution {wildcards.distribution} "
        "--corr {wildcards.corr} "
        "--rho {wildcards.rho} "
        "--method {wildcards.method}"
        
rule laplace_traditional_bootstrap:
    input:
        script = "code/scripts/laplace_traditional_bootstrap.R"
    output:
        f"code/rds/{ITER}/laplace_traditional_bootstrap.rds"
    shell:
        "Rscript {input.script} --iterations {ITER} --seed {SEED}"
        
rule sparse1_relaxed_MCP_posterior:
    input:
        script = "code/scripts/sparse1_relaxed_MCP_posterior.R"
    output:
        f"code/rds/{ITER}/sparse1_relaxed_MCP_posterior.rds"
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
        
rule laplace_gam_fits_traditional_bootstrap:
    input:
        script = "code/scripts/laplace_gam_fits_traditional_bootstrap.R",
        rds = f"code/rds/{ITER}/laplace_traditional_bootstrap.rds"
    output:
        f"code/rds/{ITER}/laplace_gam_fits_traditional_bootstrap.rds"
    shell:
        "Rscript {input.script} --iterations {ITER}"
        
rule across_lambda_coverage:
    input:
        script = "code/scripts/across_lambda_coverage.R"
    output:
        f"code/rds/{ITER}/across_lambda_coverage.rds"
    shell:
        "Rscript {input.script} --iterations {ITER} --seed {SEED}"
        
rule across_lambda_gam:
    input:
        script = "code/scripts/across_lambda_gam.R",
        rds    = f"code/rds/{ITER}/across_lambda_coverage.rds"
    output:
        f"code/rds/{ITER}/across_lambda_gam.rds"
    shell:
        "Rscript {input.script} --iterations {ITER}"
        
rule bias_decomposition:
    input:
        script = "code/scripts/bias_decomposition.R",
    output:
        f"code/rds/{ITER}/bias_decomposition.rds"
    shell:
        "Rscript {input.script} --iterations {ITER} --seed {SEED}"
        
rule stability_selection:
    input:
        script = "code/scripts/stability_selection.R",
    output:
        f"code/rds/{ITER}/stability_selection.rds"
    shell:
        "Rscript {input.script} --iterations {ITER} --seed {SEED}"

rule figure1:
    input:
        script = "code/figure1.R",
        rds    = f"code/rds/{ITER}/gam/laplace_autoregressive_0_100_101_10_100_rlp.rds"
    output:
        "code/out/figure1.pdf"
    shell:
        "Rscript {input.script} --iterations {ITER}"
        
rule figure2:
    input:
        script = "code/figure2.R",
        rds    = expand(
            f"code/rds/{ITER}/gam/normal_autoregressive_0_200_{{p_sigma_snr}}_{{method}}.rds",
            p_sigma_snr  = ["20_10_19", "100_10_115", "200_10_239"],
            method = ["ridgeT", "ridgebootT"]
        )
    output:
        "code/out/figure2.pdf"
    shell:
        "Rscript {input.script} --iterations {ITER}"
        
rule figure3:
    input:
        script = "code/figure3.R",
        rds = expand(
            f"code/rds/{ITER}/original/laplace_autoregressive_{{rho}}_{{n}}_101_10_100_rlp.rds",
            rho = [0, 50, 80],               
            n = [50, 100, 400, 1000]
        )
    output:
        "code/out/figure3.pdf"
    shell:
        "Rscript {input.script} --iterations {ITER}"
        
rule figure4:
    input:
        script = "code/figure4.R",
        rds1 = f"code/rds/{ITER}/across_lambda_coverage.rds",
        rds2 = f"code/rds/{ITER}/across_lambda_gam.rds"
    output:
        "code/out/figure4.png"
    shell:
        "Rscript {input.script} --iterations {ITER}"
        
rule figure5:
    input:
        script = "code/figure5.R",
        rds = expand(
            f"code/rds/{ITER}/original/highcorr_{{method}}.rds",
            method = ["rlp", "ridge"]
        )
    output:
        "code/out/figure5.pdf"
    shell:
        "Rscript {input.script} --iterations {ITER}"
    
rule figure6:
    input: 
      script = "code/figure6.R",
        rds = expand(
            f"code/rds/{ITER}/gam/laplace_autoregressive_0_100_101_10_100_{{method}}.rds",
            method = ["rlp", "selectiveinference"]
        )
    output:
        "code/out/figure6.pdf"
    shell:
        f"Rscript {input.script} --iterations {ITER} {'--desparsified' if DESPARSIFIED else ''}"
        
rule figure7:
    input: 
      script = "code/figure7.R",
        rds = expand(
            f"code/rds/{ITER}/original/laplace_autoregressive_0_{{n}}_101_10_100_{{method}}.rds",
            method = ["rlp", "selectiveinference"],
            n = [50, 100, 400]
        )
    output:
        "code/out/figure7.pdf"
    shell:
        f"Rscript {input.script} --iterations {ITER} {'--desparsified' if DESPARSIFIED else ''}"
        
        
rule figure8:
    input: **make_inputs(8,"whoari_relaxed_lasso_posterior","whoari_selective_inference","whoari_desparsified_lasso")
    output:
        "code/out/figure8.pdf"
    shell:
        f"Rscript {input.script} {'--desparsified' if DESPARSIFIED else ''}"
        
rule figure9:
    input: **make_inputs(9,"Scheetz2006_relaxed_lasso_posterior","Scheetz2006_selective_inference","Scheetz2006_desparsified_lasso")
    output:
        "code/out/figure9.pdf"
    shell:
        f"Rscript {input.script} {'--desparsified' if DESPARSIFIED else ''}"

rule figureA1:
    input:
        script = "code/figureA1.R",
        rds = f"code/rds/{ITER}/laplace_gam_fits_traditional_bootstrap.rds",
    output:
        "code/out/figureA1.pdf"
    shell:
        "Rscript {input.script} --iterations {ITER}"
        
rule figureC1:
    input:
        script = "code/figureC1.R",
        rds = f"code/rds/{ITER}/laplace_gam_fits.rds",
    output:
        "code/out/figureC1.pdf"
    shell:
        "Rscript {input.script} --iterations {ITER}"
        
rule figureF1:
    input:
        script = "code/figureF1.R",
        rds = f"code/rds/{ITER}/bias_decomposition.rds",
    output:
        "code/out/figureF1.pdf"
    shell:
        "Rscript {input.script} --iterations {ITER}"
        
rule table1:
    input:
        script = "code/table1.R",
        rds = expand(
            f"code/rds/{ITER}/original/{{dist}}_autoregressive_0_{{n}}_101_10_100_rlp.rds",
            dist = ["laplace", "t", "normal", "uniform", "beta", "sparse3", "sparse2", "sparse1"],
            n = [50, 100, 400, 1000]
        )
    output:
        "code/out/table1.tex"
    shell:
        "Rscript {input.script} --iterations {ITER}"
        
rule tableD1:
    input:
        script = "code/tableD1.R",
        rds = f"code/rds/{ITER}/laplace_selective_inference.rds"
    output:
        "code/out/tableD1.tex"
    shell:
        "Rscript {input.script} --iterations {ITER}"
        
rule tableE1:
    input:
        script = "code/tableE1.R",
        rds1 = f"code/rds/{ITER}/sparse1_relaxed_lasso_posterior.rds",
        rds2 = f"code/rds/{ITER}/sparse1_relaxed_MCP_posterior.rds"
    output:
        "code/out/tableE1.tex"
    shell:
        "Rscript {input.script} --iterations {ITER}"
        
rule tableG1:
    input:
        script = "code/tableG1.R",
        rds = f"code/rds/{ITER}/stability_selection.rds",
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
