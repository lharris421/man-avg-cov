# A New Perspective on High Dimensional Confidence Intervals

Code, simulations, and manuscript for the paper. The Snakefile lays out the flow of the build.

# Requirements

- R 4.5 (the lockfile records 4.5.2). R packages are installed automatically by renv the first time you run snakemake, so the first run needs an internet connection.
- snakemake 8 or later.
- TeX Live with `latexmk`, `lualatex`, and `texfot`.

# Results

The simulation results (`code/rds/`, about 360 MB) are not tracked in git. [TODO: where to get them.] Put them in `code/rds/`. They are protected by default (`protect_results: true`): snakemake treats them as given, never regenerates or deletes them, and stops with a clear message if one is missing. Set `protect_results: false` to regenerate them from scratch, which takes days at 1000 iterations.

The raw BRCA1 data (`data/brca1.rds`, 69 MB) is not tracked either. It is only needed to regenerate the BRCA1 results, and is built from TCGA by `code/scripts/brca1.R`.

# Compiling

From the repository root:

    snakemake --cores 4

This produces the figures and tables in `code/out/` and the manuscript at `build/avg-cov.pdf`. To check your setup before a full run, `snakemake --cores 1 code/out/figure3.pdf` builds the one figure that needs no results. Also see options below for doing a less demanding full run.

The scripts can also be run interactively from `code/`.

# Options

Set in `config.yaml`, or override on the command line, e.g. `snakemake --cores 4 --config smoke=true iterations=10`.

- `iterations`: simulation iterations per setting. The manuscript uses 1000. Results are stored by iteration count (`code/rds/5/<iterations>/`), so changing this never overwrites the manuscript results.
- `smoke`: use `data/brca1_small.rds` (tracked; 150 samples x 300 genes) in place of the full BRCA1 data. With `iterations: 10` the whole pipeline, manuscript included, builds in a few minutes.
- `quiet`: print only the simulation progress bars. `snakemake -q` does the same.
- `desparsified`: include the desparsified lasso. It is slow, and on the full BRCA1 data takes hours. It uses the fork of `hdi` at https://github.com/lharris421/hdi, which renv installs.
<<<<<<< HEAD
- `protect_results`: see Results. Smoke runs always regenerate their own results regardless.
- `alpha` (5, so 95% intervals) and `seed` should be left alone.

# Smoke test

Every push runs `.github/workflows/smoke.yml`, which builds everything on a clean Ubuntu machine with the smoke settings. Pushes to `main`, or a manual run of the workflow, also publish the resulting PDF at https://lharris421.github.io/man-avg-cov/avg-cov.pdf.
=======
- `alpha` (5, so 95% intervals)
- `seed`
>>>>>>> 95ba494b1bf697251c2917f94504bfc557c63751
