import os

configfile: "config.yaml"
ITER         = config["iterations"]
SEED         = config["seed"]
LOC          = config["res-loc"]
DESPARSIFIED = config.get("desparsified", False)
os.makedirs(f"{LOC}rds/{ITER}", exist_ok=True)

wildcard_constraints:
    dataset = "[A-Za-z0-9_]+"

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
        f"{LOC}rds/{ITER}/original/{{distribution}}_{{corr}}_{{rho}}_{{n}}_{{p}}_{{sigma}}_{{snr}}_{{method}}.rds"
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
        f"{LOC}rds/{ITER}/original/highcorr_{{method}}.rds"
    shell:
        "Rscript {input.script} "
        "--iterations {ITER} "
        "--seed {SEED} "
        "--method {wildcards.method}"
        
rule data_results:
    input:
        script = "code/scripts/data_results.R"
    output:
        f"{LOC}rds/{{dataset}}_{{method}}.rds"
    shell:
        "Rscript {input.script} "
        "--seed {SEED} "
        "--method {wildcards.method} "
        "--data {wildcards.dataset}"
        
rule fit_gam:
    input:
        script = "code/scripts/fit_gam.R",
        rds    = f"{LOC}rds/{ITER}/original/{{distribution}}_{{corr}}_{{rho}}_{{n}}_{{p}}_{{sigma}}_{{snr}}_{{method}}.rds"
    output:
        f"{LOC}rds/{ITER}/gam/{{distribution}}_{{corr}}_{{rho}}_{{n}}_{{p}}_{{sigma}}_{{snr}}_{{method}}.rds"
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
        
rule across_lambda_coverage:
    input:
        script = "code/scripts/across_lambda_coverage.R"
    output:
        f"{LOC}rds/{ITER}/across_lambda_coverage.rds"
    shell:
        "Rscript {input.script} --iterations {ITER} --seed {SEED}"
        
rule across_lambda_gam:
    input:
        script = "code/scripts/across_lambda_gam.R",
        rds    = f"{LOC}rds/{ITER}/across_lambda_coverage.rds"
    output:
        f"{LOC}rds/{ITER}/across_lambda_gam.rds"
    shell:
        "Rscript {input.script} --iterations {ITER}"
        
rule bias_decomposition:
    input:
        script = "code/scripts/bias_decomposition.R",
    output:
        f"{LOC}rds/{ITER}/bias_decomposition.rds"
    shell:
        "Rscript {input.script} --iterations {ITER} --seed {SEED}"
        
rule stability_selection:
    input:
        script = "code/scripts/stability_selection.R",
    output:
        f"{LOC}rds/{ITER}/stability_selection.rds"
    shell:
        "Rscript {input.script} --iterations {ITER} --seed {SEED}"

rule figure1:
    input:
        script = "code/figure1.R",
        rds    = f"{LOC}rds/{ITER}/gam/laplace_autoregressive_0_100_101_10_100_rlp.rds"
    output:
        "code/out/figure1.pdf"
    shell:
        "Rscript {input.script} --iterations {ITER}"
        
rule figure2:
    input:
        script = "code/figure2.R",
        rds    = expand(
            f"{LOC}rds/{ITER}/gam/normal_autoregressive_0_200_{{p_sigma_snr}}_{{method}}.rds",
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
            f"{LOC}rds/{ITER}/original/laplace_autoregressive_{{rho}}_{{n}}_101_10_100_rlp.rds",
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
        rds1 = f"{LOC}rds/{ITER}/across_lambda_coverage.rds",
        rds2 = f"{LOC}rds/{ITER}/across_lambda_gam.rds"
    output:
        "code/out/figure4.png"
    shell:
        "Rscript {input.script} --iterations {ITER}"
        
rule figure5:
    input:
        script = "code/figure5.R",
        rds = expand(
            f"{LOC}rds/{ITER}/original/highcorr_{{method}}.rds",
            method = ["rlp", "ridge"]
        )
    output:
        "code/out/figure5.pdf"
    shell:
        "Rscript {input.script} "
        "--iterations {ITER} "
        "--loc {LOC}"
    
rule figure6:
    input: 
      script = "code/figure6.R",
        rds = expand(
            f"{LOC}rds/{ITER}/gam/laplace_autoregressive_0_100_101_10_100_{{method}}.rds",
            method = ["rlp", "selectiveinference"] + (["desparsified0"] if DESPARSIFIED else [])
        )
    output:
        "code/out/figure6.pdf"
    shell:
        "Rscript {input.script} "
        "--iterations {ITER} "
        "--loc {LOC} "
        f"{'--desparsified' if DESPARSIFIED else ''}"
        
rule figure7:
    input: 
      script = "code/figure7.R",
      rds = expand(
          f"{LOC}rds/{ITER}/original/laplace_autoregressive_0_{{n}}_101_10_100_{{method}}.rds",
          method = ["rlp", "selectiveinference"] + (["desparsified0"] if DESPARSIFIED else []),
          n = [50, 100, 400]
      )
    output:
        "code/out/figure7.pdf"
    shell:
        "Rscript {input.script} "
        "--iterations {ITER} "
        "--loc {LOC} "
        f"{'--desparsified' if DESPARSIFIED else ''}"
        
        
rule figure8:
    input:
      script = "code/figure8.R",
      rds = expand(
          f"{LOC}rds/whoari_{{method}}.rds",
          method = ["rlp", "selectiveinference"] + (["desparsified"] if DESPARSIFIED else [])
      )
    output:
        "code/out/figure8.pdf"
    shell:
        f"Rscript {input.script} {'--desparsified' if DESPARSIFIED else ''}"
        
rule figure9:
    input:
      script = "code/figure9.R",
      rds = expand(
          f"{LOC}rds/Scheetz2006_{{method}}.rds",
          method = ["rlp", "selectiveinference"] + (["desparsified"] if DESPARSIFIED else [])
      )
    output:
        "code/out/figure9.pdf"
    shell:
        f"Rscript {input.script} {'--desparsified' if DESPARSIFIED else ''}"

rule figureA1:
    input:
        script = "code/figureA1.R",
        rds    = f"{LOC}rds/{ITER}/gam/laplace_autoregressive_0_100_101_10_100_traditional.rds"
    output:
        "code/out/figureA1.pdf"
    shell:
        "Rscript {input.script} --iterations {ITER}"
        
rule figureC1:
    input: 
      script = "code/figureC1.R",
      rds = expand(
          f"{LOC}rds/{ITER}/gam/laplace_autoregressive_0_{{n}}_101_10_100_rlp.rds",
          n = [50, 100, 400]
      )
    output:
        "code/out/figureC1.pdf"
    shell:
        "Rscript {input.script} --iterations {ITER}"
        
rule figureF1:
    input:
        script = "code/figureF1.R",
        rds = f"{LOC}rds/{ITER}/bias_decomposition.rds",
    output:
        "code/out/figureF1.pdf"
    shell:
        "Rscript {input.script} --iterations {ITER}"
        
rule table1:
    input:
        script = "code/table1.R",
        rds = expand(
            f"{LOC}rds/{ITER}/original/{{dist}}_autoregressive_0_{{n}}_101_10_100_rlp.rds",
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
      rds = expand(
          f"{LOC}rds/{ITER}/original/laplace_autoregressive_0_{{n}}_101_10_100_selectiveinference.rds",
          n = [50, 100, 400]
      )
    output:
        "code/out/tableD1.tex"
    shell:
        "Rscript {input.script} --iterations {ITER}"
        
rule tableE1:
    input: 
      script = "code/tableE1.R",
      rds = expand(
          f"{LOC}rds/{ITER}/original/sparse1_autoregressive_0_100_101_10_100_{{method}}.rds",
          method = ["rlp", "rmp"]
      )
    output:
        "code/out/tableE1.tex"
    shell:
        "Rscript {input.script} --iterations {ITER}"
        
rule tableG1:
    input:
        script = "code/tableG1.R",
        rds = f"{LOC}rds/{ITER}/stability_selection.rds",
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
