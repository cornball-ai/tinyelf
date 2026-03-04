#' Check Shared Library Dependencies Against Allowlist
#'
#' Runs \code{ldd} on the given .so file and checks all resolved shared
#' library dependencies against the manylinux permitted set (or a custom
#' allowlist). Flags any library not on the allowlist and any libraries
#' reported as "not found".
#'
#' @param path Path to a single .so file.
#' @param allowlist Character vector of permitted sonames.
#'   Default is \code{manylinux_libs()}.
#'
#' @return A list with components:
#'   \describe{
#'     \item{pass}{Logical. TRUE if all deps are on the allowlist.}
#'     \item{issues}{Character vector of unexpected sonames.}
#'     \item{missing}{Character vector of sonames reported "not found".}
#'     \item{all_deps}{Character vector of all sonames found.}
#'   }
#'
#' @export
check_deps <- function(path, allowlist = manylinux_libs()) {
    .require_linux()
    .require_tool("ldd")
    path <- normalizePath(path, mustWork = TRUE)
    lines <- .run_cmd("ldd", character(), path)
    .parse_ldd_output(lines, allowlist)
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

