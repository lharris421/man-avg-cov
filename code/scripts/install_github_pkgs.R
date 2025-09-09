#!/usr/bin/env Rscript

# install_github_pkgs.R
# Usage:
#   Rscript install_github_pkgs.R
# Installs/refreshes selected GitHub packages into ./github/lib

`%||%` <- function(a, b) if (!is.null(a)) a else b

github_install_latest <- function(pkgs, lib_dir = file.path("github", "lib")) {
  # 1) library path ---------------------------------------------------------
  dir.create(lib_dir, recursive = TRUE, showWarnings = FALSE)
  .libPaths(c(normalizePath(lib_dir), .libPaths()))  # prefer github/lib

  # 2) ensure remotes is available -----------------------------------------
  if (!requireNamespace("remotes", quietly = TRUE)) {
    install.packages("remotes",
                     repos = "https://cloud.r-project.org",
                     quiet = TRUE)
  }

  # 3) install/refresh ------------------------------------------------------
  for (pkg in names(pkgs)) {
    spec <- pkgs[[pkg]]
    repo <- spec$repo                  # "owner/repo"
    ref  <- spec$ref  %||% "HEAD"      # branch/tag/SHA
    ver  <- spec$version %||% NA       # optional pinned version (packageVersion)

    # Quick skip when a tag is pinned with an R version (e.g., 3.12.0)
    if (!is.na(ver)) {
      cur <- tryCatch(utils::packageVersion(pkg, lib.loc = lib_dir),
                      error = function(e) NULL)
      if (!is.null(cur) && cur == ver) {
        message(sprintf("[%s] %s already in %s — skipping",
                        pkg, ver, lib_dir))
        next
      }
    }

    message(sprintf("[%s] installing %s@%s → %s", pkg, repo, ref, lib_dir))
    remotes::install_github(repo,
                            ref     = ref,
                            lib     = lib_dir,
                            upgrade = "never",   # don't touch deps
                            force   = FALSE,     # remotes will compare and skip if up-to-date
                            quiet   = TRUE)
  }

  message(sprintf("Done. Library at: %s", lib_dir))
}

# ---------------------------------------------------------------------------
# Define what to install here
# ---------------------------------------------------------------------------
pkgs_to_install <- list(
  ncvreg = list(repo = "pbreheny/ncvreg", ref = "pipe"),   # branch/tag/SHA
  hdi    = list(repo = "lharris421/hdi",   ref = "master") # or "HEAD"
)

# Run
github_install_latest(pkgs_to_install)
