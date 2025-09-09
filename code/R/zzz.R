## zzz.R

.onLoad <- function(libname, pkgname) {
  # Path where your install script puts them
  lib_dir <- normalizePath(file.path("github", "lib"), mustWork = FALSE)

  # Prepend to library paths
  if (dir.exists(lib_dir)) {
    .libPaths(c(lib_dir, .libPaths()))
  }

  # Packages that should already be installed
  required_pkgs <- c("ncvreg", "hdi")

  # Check each one
  for (pkg in required_pkgs) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      stop(sprintf(
        "The package '%s' is not installed in %s.\n\n",
        pkg, lib_dir
      ),
      "Run: Rscript install_github_pkgs.R",
      call. = FALSE
      )
    }
  }
}
