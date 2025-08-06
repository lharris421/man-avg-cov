`%||%` <- function(a, b) if (!is.null(a)) a else b

github_install_latest <- function(pkgs) {

  ## 1.  library path -------------------------------------------------------
  lib_dir <- if (interactive()) file.path("github", "lib")
  else                file.path("code", "github", "lib")

  dir.create(lib_dir, recursive = TRUE, showWarnings = FALSE)
  .libPaths(c(normalizePath(lib_dir), .libPaths()))  # github/lib first

  ## 2.  make sure remotes is around (lighter than full devtools) ----------
  if (!requireNamespace("remotes", quietly = TRUE))
    install.packages("remotes",
                     repos  = "https://cloud.r-project.org",
                     quiet  = TRUE)

  ## 3.  loop over spec list -----------------------------------------------
  for (pkg in names(pkgs)) {

    spec <- pkgs[[pkg]]
    repo <- spec$repo                  # "owner/repo"
    ref  <- spec$ref  %||% "HEAD"      # branch/tag/SHA
    ver  <- spec$version %||% NA       # optional pinned version

    ## 3a.  Quick skip via DESCRIPTION version (when pinned to a tag)
    if (!is.na(ver)) {
      cur <- tryCatch(utils::packageVersion(pkg, lib.loc = lib_dir),
                      error = function(e) NULL)
      if (!is.null(cur) && cur == ver) {
        message("[", pkg, "] ", ver, " already in github/lib — skipping")
        next
      }
    }

    ## 3b.  Ask remotes to install/refresh only if needed
    message("[", pkg, "] updating ", repo, "@", ref)
    remotes::install_github(repo,
                            ref      = ref,
                            lib      = lib_dir,
                            upgrade  = "never",   # don't touch deps
                            force    = FALSE,     # let remotes decide
                            quiet    = TRUE)
  }
}

## ------------------------------------------------------------------------
##  Hook: runs each time *your* package is loaded
## ------------------------------------------------------------------------
.onLoad <- function(libname, pkgname) {
  pkgs_to_github <- list(
    ncvreg = list(repo = "pbreheny/ncvreg", ref = "pipe"),  # any branch/tag
    hdi    = list(repo = "lharris421/hdi" , ref = "master")      # or "HEAD"
  )
  github_install_latest(pkgs_to_github)
}
