# A New Perspective on High Dimensional Confidence Intervals

A minimal reproducible repository.

# Packages

Before continuing, ensure you have the following packages installed:

- hdrm (remotes::install_github("pbreheny/hdrm"))
- selectiveInference
- glmnet
- dplyr
- glue
- mgcv
- progress
- optparse

The following need to be installed from github branches instead of CRAN which can be easily done by running the script `install_github_pkgs.R`:

- ncvreg (3.16.0)
- hdi

Additionally to create all the plots / tables you will need:

- ggplot2
- patchwork
- grid
- kableExtra
- stringr
- tidyr
- purrr

# Compiling

There are a couple of ways to run code in this repo. With a working installation of snakemake (https://snakemake.readthedocs.io/en/stable/) you should be able to run: `snakemake --cores=1` to run the simulations and build the manuscript. Note, this can take a while, but snakemake can run in parallel if you are willing to allow it to run on more cores.

We recommend you start with the Snakefile as that will help layout the flow of the manuscript build.

From there, we recommend running `snakemake figure1`. This will just produce figure1.pdf in code/out. Once you confirm that works, then you can proceed with `snakemake --cores=1`.

However, note, all the scripts can be run interactively as well.

# Options

There are a few options that should be consider before building as running the simulations from scratch is quite time consuming.

These can be adjusted in `config.yaml`.

1. The number of iterations in the original manuscript is 1000 for each simulation, but leaving this at 100 will greatly reduce computational costs. 
2. Running the desparsified lasso is slow in general and applying it to the Scheetz2006 dataset takes hours. The default here is to not produce these results. If you do wish to, you will also need the version of `hdi` that was updated for this manuscript which can be found here: https://github.com/lharris421/hdi (see above)

