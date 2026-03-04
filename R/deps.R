#' Check Shared Library Dependencies Against Allowlist
#'
#' Checks the shared library dependencies of a .so file against a permitted
#' allowlist. By default checks only direct dependencies (via
#' \code{readelf -d}). Set \code{transitive = TRUE} to check the full
#' dependency tree (via \code{ldd}), which includes libraries pulled in
#' by libR.so and other indirect dependencies.
#'
#' @param path Path to a single .so file.
#' @param allowlist Character vector of permitted sonames.
#'   Default is \code{manylinux_libs()}.
#' @param transitive Logical. If FALSE (default), check only direct
#'   dependencies (NEEDED entries). If TRUE, check the full transitive
#'   closure via ldd.
#'
#' @return A list with components:
#'   \describe{
#'     \item{pass}{Logical. TRUE if all deps are on the allowlist.}
#'     \item{issues}{Character vector of unexpected sonames.}
#'     \item{missing}{Character vector of sonames reported "not found"
#'       (only when \code{transitive = TRUE}).}
#'     \item{all_deps}{Character vector of all sonames found.}
#'   }
#'
#' @export
check_deps <- function(path, allowlist = manylinux_libs(), transitive = FALSE) {
    .require_linux()
    path <- normalizePath(path, mustWork = TRUE)
    if (transitive) {
        .require_tool("ldd")
        lines <- .run_cmd("ldd", character(), path)
        .parse_ldd_output(lines, allowlist)
    } else {
        .require_tool("readelf")
        lines <- .run_cmd("readelf", "-d", path)
        .parse_needed_output(lines, allowlist)
    }
}

#' Parse readelf -d Output for NEEDED Entries
#'
#' @noRd
.parse_needed_output <- function(lines, allowlist) {
    all_deps <- character()
    for (line in lines) {
        if (!grepl("\\(NEEDED\\)", line)) {
            next
        }
        m <- regmatches(line, regexpr("\\[([^]]+)\\]", line))
        if (length(m) == 0L || nchar(m) == 0L) {
            next
        }
        soname <- sub("^\\[", "", sub("\\]$", "", m))
        all_deps <- c(all_deps, soname)
    }
    unexpected <- setdiff(all_deps, allowlist)
    list(
         pass = length(unexpected) == 0L,
         issues = unexpected,
         missing = character(),
         all_deps = all_deps
    )
}

#' Parse ldd Output Lines
#'
#' @noRd
.parse_ldd_output <- function(lines, allowlist) {
    all_deps <- character()
    missing <- character()

    for (line in lines) {
        line <- trimws(line)
        if (nchar(line) == 0L) {
            next
        }

        if (grepl("=>", line)) {
            soname <- trimws(sub("=>.*$", "", line))
            rhs <- trimws(sub("^.*=>\\s*", "", line))
            rhs <- sub("\\s*\\(0x[0-9a-fA-F]+\\)$", "", trimws(rhs))
            if (rhs == "not found") {
                missing <- c(missing, soname)
            }
            all_deps <- c(all_deps, soname)
        } else {
            soname <- sub("\\s*\\(0x[0-9a-fA-F]+\\).*$", "", line)
            soname <- basename(trimws(soname))
            if (nchar(soname) > 0L) {
                all_deps <- c(all_deps, soname)
            }
        }
    }

    unexpected <- setdiff(all_deps, allowlist)

    list(
         pass = length(unexpected) == 0L && length(missing) == 0L,
         issues = unexpected,
         missing = missing,
         all_deps = all_deps
    )
}

