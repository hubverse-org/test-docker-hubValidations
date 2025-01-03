#!/usr/bin/env Rscript
#
# Validate a model submission via pull request via (default args)
# `hubValidations::validate_pr()`
#
# USAGE
#
#    validate.R [/path/to/hub] [org/repo] [pr]
#
# ARGUMENTS
# 
#   [/path/to/hub]  path to a local copy of the hub
#   [org/repo]      github repository name (e.g. reichlab/variant-nowcast-hub)
#   [pr]            pull request number (e.g. 237)
# 
# EXAMPLE
#
#   This validates pull request 246 from the variant nowcast hub. The first
#   two lines clone the repository, so skip them if you already have it locally
#
#   ```
#   tmp=$(mktemp -d)
#   git clone https://github.com/reichlab/variant-nowcast-hub.git $tmp
#   validate.R $tmp reichlab/variant-nowcast-hub 246
#   ```

args <- commandArgs(trailingOnly = TRUE)

ci_cat <- function(...) {
  not_ci <- isFALSE(as.logical(Sys.getenv("CI", "false")))
  if (not_ci) {
    return(invisible(NULL))
  }
  cat(...)
}

print_error <- function(obj, name) {
  cli::cli_h2("{.var ${name}}")
  print(obj)
}

# Find the errors and extract the extra attributes
#
# The `hub_validations` class object contains individual `hub_check` objects.
# If these objects are errors, they _may_ contain extra data fields passed on
# to [rlang::error_cnd()]. There is no standard for what extra data fields
# should be present---they could be `errors`, `error_object`, `missing`, etc.
# (dependent on context). 
#
# However, whenever there _is_ an error, it is important to print these data
# fields so that users can address errors quickly.
#
# This function trims the `hub_validations` object to the ones that caused a
# failure/error. It then walks through each `hub_check` object and plucks out
# all of the elements that do not match the arguments to [rlang::error_cnd()].
#
# If any elements exist, then they are printed out to the console.
get_error_data <- function(result) {
  baddies <- result[purrr::map_lgl(result, hubValidations::not_pass)]
  reserved <- c("where", names(formals(rlang::error_cnd)))
  res <- purrr::map(baddies, \(bad) bad[!names(bad) %in% reserved]) |>
    purrr::compact()
  if (all(lengths(res)) == 0) {
    return(NULL)
  }
  ci_cat("::group::Additional error attributes\n")
  for (err in names(res)) {
    cli::cli_h1("{.var [{err}]} attributes")
    purrr::iwalk(res[[err]], print_error)
  }
  ci_cat("::endgroup::\n")
  return(invisible(res))
}


ci_cat("::group::Running Validations\n")
cli::cli_alert_info("VALIDATING {args[2]}#{args[3]}\n")
result <- hubValidations::validate_pr(
  hub_path = args[1],
  gh_repo = args[2],
  pr_number = args[3]
)
validation_result <- try(hubValidations::check_for_errors(result))
ci_cat("::endgroup::\n")
if (!isTRUE(validation_result)) {
  err <- get_error_data(result)
  stop("validation failed", call. = FALSE)
}
