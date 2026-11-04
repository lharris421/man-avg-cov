import os

configfile: "config.yaml"

# Boolean config values. config.yaml gives real booleans, but a command-line
# override such as `--config smoke=false` arrives as the string "false", which
# would otherwise count as true.
def flag(name, default=False):
    v = config.get(name, default)
    if isinstance(v, str):
        return v.strip().lower() in ("1", "true", "yes", "on")
    return bool(v)

ITER         = config["iterations"]
ALPHA        = config["alpha"]
SEED         = config["seed"]
DESPARSIFIED = flag("desparsified")

# Smoke test: regenerate everything on the small BRCA1 dataset
# (data/brca1_small.rds, from code/scripts/brca1_small.R). Its results are
# written as brca1_small_*.rds, so they never overwrite the real ones.
SMOKE        = flag("smoke")

# Zenodo downloads, both off by default and only of what is missing.
# fetch_brca1: the full BRCA1 data, downloaded at startup (see onstart).
# Figure 1 uses it whenever data/brca1.rds exists, else data/brca1_small.rds.
# fetch_results: the published results (alpha 5, 1000 iterations) into
# code/rds. Smoke runs ignore both.
FETCH_BRCA1    = flag("fetch_brca1") and not SMOKE and not os.path.exists("data/brca1.rds")
FETCH_RESULTS  = flag("fetch_results") and not SMOKE
BRCA1          = "brca1" if not SMOKE and (FETCH_BRCA1 or os.path.exists("data/brca1.rds")) else "brca1_small"
ZENODO_BRCA1   = "https://zenodo.org/api/records/23894239/files/brca1.rds/content"  # doi:10.5281/zenodo.23894238
ZENODO_RESULTS = "https://zenodo.org/api/records/23894707/files/rds.zip/content"    # doi:10.5281/zenodo.23894706

# Quiet mode: silence R messages and warnings so that only the simulation
# progress bars print. Turned on by `quiet: true` in config.yaml, by
# `--config quiet=true`, or by Snakemake's own -q/--quiet flag. Errors are
# never silenced. The R side reads the AVGCOV_QUIET environment variable in
# code/scripts/setup.R.
QUIET        = flag("quiet") or bool(getattr(workflow.output_settings, "quiet", None))
if QUIET:
    os.environ["AVGCOV_QUIET"] = "1"

# Protect results. When true (the default), the rules that produce the files
# under code/rds are not defined at all, so existing results are plain inputs:
# Snakemake never regenerates or deletes them, whatever their timestamps, and
# stops with a "missing input" message if one is absent. Set protect_results to
# false (or pass --config protect_results=false) to let Snakemake rebuild
# missing or outdated results. Smoke runs always regenerate their own results;
# fetched results are never regenerated.
PROTECT      = flag("protect_results", True)
RUN_SIMS     = SMOKE or not (PROTECT or FETCH_RESULTS)

# Make sure the R packages recorded in renv.lock are installed before any job
# runs. renv::restore() installs only what is missing or mismatched, so once the
# project library is in sync this is a one-second no-op. Dry runs skip it.
onstart:
    shell("Rscript -e 'renv::restore(prompt = FALSE)'" + (" > /dev/null" if QUIET else ""))
    if FETCH_BRCA1:
        shell(f"curl -fL -o data/brca1.rds {ZENODO_BRCA1}")

os.makedirs(f"code/rds/{ALPHA}/{ITER}", exist_ok=True)

wildcard_constraints:
    dataset = "[A-Za-z0-9_]+",
    method  = "[A-Za-z0-9]+"

rule all:
    input:
        "build/avg-cov.pdf",
        "code/out/figure1.pdf",
        "code/out/figure2.pdf",
        "code/out/figure3.pdf",
        "code/out/figure4.pdf",
        "code/out/figure5.png",
        "code/out/figure6.pdf",
        "code/out/figure7L.pdf",
        "code/out/figure7R.pdf",
        "code/out/table1.tex",
        "code/out/tableD1.tex",
        "code/out/tableE1.tex"

if RUN_SIMS:
    # Everything below writes to code/rds.
    rule distribution_results:
        input:
            script = f"code/scripts/distribution_results.R"
        output:
            f"code/rds/{ALPHA}/{ITER}/original/{{distribution}}_{{corr}}_{{rho}}_{{n}}_{{p}}_{{family}}_{{snr}}_{{method}}.rds"
        shell:
            "Rscript {input.script} "
            "--alpha {ALPHA} "
            "--iterations {ITER} "
            "--seed {SEED} "
            "--n {wildcards.n} "
            "--p {wildcards.p} "
            "--family {wildcards.family} "
            "--snr {wildcards.snr} " ## Signal as a percent of noise
            "--distribution {wildcards.distribution} "
            "--corr {wildcards.corr} "
            "--rho {wildcards.rho} " ## As a percent
            "--method {wildcards.method} "
        
    
    rule highcorr_results:
        input:
            script = f"code/scripts/highcorr_results.R"
        output:
            f"code/rds/{ALPHA}/{ITER}/original/highcorr_{{method}}.rds"
        shell:
            "Rscript {input.script} "
            "--alpha {ALPHA} "
            "--iterations {ITER} "
            "--seed {SEED} "
            "--method {wildcards.method} "
        
    
    rule data_results:
        input:
            script = f"code/scripts/data_results.R"
        output:
            f"code/rds/{ALPHA}/{{dataset}}_{{method}}.rds"
        shell:
            "Rscript {input.script} "
            "--alpha {ALPHA} "
            "--seed {SEED} "
            "--method {wildcards.method} "
            "--dataset {wildcards.dataset} "
        
    
    rule fit_gam:
        input:
            script = f"code/scripts/fit_gam.R",
            rds    = f"code/rds/{ALPHA}/{ITER}/original/{{distribution}}_{{corr}}_{{rho}}_{{n}}_{{p}}_{{family}}_{{snr}}_{{method}}.rds"
        output:
            rds_out = f"code/rds/{ALPHA}/{ITER}/gam/{{distribution}}_{{corr}}_{{rho}}_{{n}}_{{p}}_{{family}}_{{snr}}_{{method}}.rds"
        shell:
            "Rscript {input.script} "
            "--alpha {ALPHA} "
            "--iterations {ITER} "
            "--seed {SEED} "
            "--n {wildcards.n} "
            "--p {wildcards.p} "
            "--family {wildcards.family} "
            "--snr {wildcards.snr} " ## Signal as a percent of noise
            "--distribution {wildcards.distribution} "
            "--corr {wildcards.corr} "
            "--rho {wildcards.rho} "
            "--method {wildcards.method} "
        
    
    rule across_lambda_coverage:
        input:
            script = f"code/scripts/across_lambda_coverage.R"
        output:
            f"code/rds/{ALPHA}/{ITER}/across_lambda_coverage.rds"
        shell:
            "Rscript {input.script} "
            "--alpha {ALPHA} "
            "--iterations {ITER} "
            "--seed {SEED} "
        
    
    rule across_lambda_gam:
        input:
            script = f"code/scripts/across_lambda_gam.R",
            rds    = f"code/rds/{ALPHA}/{ITER}/across_lambda_coverage.rds"
        output:
            f"code/rds/{ALPHA}/{ITER}/across_lambda_gam.rds"
        shell:
            "Rscript {input.script} "
            "--alpha {ALPHA} "
            "--iterations {ITER} "
        

rule figure1:
    input:
      script = "code/figure1.R",
      rds = expand(
          f"code/rds/{ALPHA}/{BRCA1}_{{method}}.rds",
          method = ["pipep", "selectiveinferenceS"] + (["desparsified"] if DESPARSIFIED else [])
      )
    output:
        "code/out/figure1.pdf"
    shell:
        "Rscript {input.script} "
        "--alpha {ALPHA} "
        "--dataset {BRCA1} "
        f"{'--desparsified' if DESPARSIFIED else ''}"

rule figure2:
    input:
        script = "code/figure2.R",
        rds    = f"code/rds/{ALPHA}/{ITER}/gam/laplace_autoregressive_0_100_101_gaussian_100_pipep.rds"
    output:
        "code/out/figure2.pdf"
    shell:
        "Rscript {input.script} "
        "--alpha {ALPHA} "
        "--iterations {ITER} "
        

rule figure3:
    input:
        script = "code/figure3.R",
    output:
        "code/out/figure3.pdf"
    shell:
        "Rscript {input.script} "
        
        
rule figure4:
    input:
        script = "code/figure4.R",
        rds = expand(
            f"code/rds/{ALPHA}/{ITER}/original/laplace_autoregressive_{{rho}}_{{n}}_101_gaussian_100_pipep.rds",
            rho = [0, 50, 80],               
            n = [50, 100, 400, 1000]
        )
    output:
        "code/out/figure4.pdf"
    shell:
        "Rscript {input.script} "
        "--alpha {ALPHA} "
        "--iterations {ITER} "
        
        
rule figure5:
    input:
        script = "code/figure5.R",
        rds1 = f"code/rds/{ALPHA}/{ITER}/across_lambda_coverage.rds",
        rds2 = f"code/rds/{ALPHA}/{ITER}/across_lambda_gam.rds"
    output:
        "code/out/figure5.png"
    shell:
        "Rscript {input.script} "
        "--alpha {ALPHA} "
        "--iterations {ITER} "
        
        
rule figure6:
    input:
        script = "code/figure6.R",
        rds = expand(
            f"code/rds/{ALPHA}/{ITER}/original/highcorr_{{method}}.rds",
            method = ["pipep", "ridge"]
        )
    output:
        "code/out/figure6.pdf"
    shell:
        "Rscript {input.script} "
        "--alpha {ALPHA} "
        "--iterations {ITER} "
        
    
rule figure7L:
    input: 
      script = "code/figure7L.R",
        rds = expand(
            f"code/rds/{ALPHA}/{ITER}/gam/laplace_autoregressive_0_100_101_gaussian_100_{{method}}.rds",
            method = ["pipep", "selectiveinferenceS"] + (["desparsified"] if DESPARSIFIED else [])
        )
    output:
        "code/out/figure7L.pdf"
    shell:
        "Rscript {input.script} "
        "--alpha {ALPHA} "
        "--iterations {ITER} "
        f"{'--desparsified' if DESPARSIFIED else ''}"
        
rule figure7R:
    input: 
      script = "code/figure7R.R",
      rds = expand(
          f"code/rds/{ALPHA}/{ITER}/original/laplace_autoregressive_0_{{n}}_101_gaussian_100_{{method}}.rds",
          method = ["pipep", "selectiveinferenceS"] + (["desparsified"] if DESPARSIFIED else []),
          n = [50, 100, 400]
      )
    output:
        "code/out/figure7R.pdf"
    shell:
        "Rscript {input.script} "
        "--alpha {ALPHA} "
        "--iterations {ITER} "
        f"{'--desparsified' if DESPARSIFIED else ''}"
        
rule figureC1:
    input: 
      script = "code/figureC1.R",
      rds = expand(
          f"code/rds/{ALPHA}/{ITER}/gam/laplace_autoregressive_0_{{n}}_101_gaussian_100_pipep.rds",
          n = [50, 100, 400]
      )
    output:
        "code/out/figureC1.pdf"
    shell:
        "Rscript {input.script} "
        "--alpha {ALPHA} "
        "--iterations {ITER} "
        
        
rule table1:
    input:
        script = "code/table1.R",
        rds = expand(
            f"code/rds/{ALPHA}/{ITER}/original/{{dist}}_autoregressive_0_{{n}}_101_gaussian_100_pipep.rds",
            dist = ["laplace", "t", "normal", "uniform", "beta", "sparse3", "sparse2", "sparse1"],
            n = [50, 100, 400, 1000]
        )
    output:
        "code/out/table1.tex"
    shell:
        "Rscript {input.script} "
        "--alpha {ALPHA} "
        "--iterations {ITER} "
        
        
rule tableD1:
    input: 
      script = "code/tableD1.R",
      rds = expand(
          f"code/rds/{ALPHA}/{ITER}/original/laplace_autoregressive_0_{{n}}_101_gaussian_100_selectiveinferenceS.rds",
          n = [50, 100, 400]
      )
    output:
        "code/out/tableD1.tex"
    shell:
        "Rscript {input.script} "
        "--alpha {ALPHA} "
        "--iterations {ITER} "
        
        
rule tableE1:
    input: 
      script = "code/tableE1.R",
      rds = expand(
          f"code/rds/{ALPHA}/{ITER}/original/sparse1_autoregressive_0_100_101_gaussian_100_{{method}}.rds",
          method = ["pipep", "pipepmcp"]
      )
    output:
        "code/out/tableE1.tex"
    shell:
        "Rscript {input.script} "
        "--alpha {ALPHA} "
        "--iterations {ITER} "
        

rule manuscript:
    input:
        "abstract.tex",
        "avg-cov.tex",
        "main.tex",
        "supp.tex",
        "config.yaml",
        "code/out/figure1.pdf",
        "code/out/figure2.pdf",
        "code/out/figure3.pdf",
        "code/out/figure4.pdf",
        "code/out/figure5.png",
        "code/out/figure6.pdf",
        "code/out/figure7L.pdf",
        "code/out/figure7R.pdf",
        "code/out/figureC1.pdf",
        "code/out/table1.tex",
        "code/out/tableD1.tex",
        "code/out/tableE1.tex"
    output:
        "build/avg-cov.pdf"
    shell:
        r"""
        latexmk -pdf -outdir=build -silent avg-cov.tex
        texfot lualatex -interaction=nonstopmode -output-directory=build avg-cov.tex
        """

# Every result the figure and table rules read.
RESULTS = sorted({str(f) for r in workflow.rules for f in r.input
                  if str(f).startswith("code/rds/")})

# Defined only while a result is missing, so present results stay protected.
if FETCH_RESULTS and not all(os.path.exists(f) for f in RESULTS):
    rule fetch_results:
        output:
            RESULTS
        shell:
            r"""
            curl -fL -o code/rds/rds.zip {ZENODO_RESULTS}
            unzip -oq code/rds/rds.zip 'rds/5/*' -x '*.DS_Store' -d code
            rm code/rds/rds.zip
            """
elif not RUN_SIMS:
    # With results protected, Snakemake only notices a missing result when a
    # figure has to be rebuilt; an existing figure would silently be kept. So
    # check every result up front and stop with a clear list.
    from snakemake.exceptions import WorkflowError
    _missing = [f for f in RESULTS if not os.path.exists(f)]
    if _missing:
        raise WorkflowError(
            "protect_results is on, but these result files are missing:\n  "
            + "\n  ".join(_missing)
            + "\nSet fetch_results: true to download them, or protect_results: false "
              "to regenerate them.")
