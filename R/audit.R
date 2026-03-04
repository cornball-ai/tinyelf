#' Audit Shared Libraries for Portability
#'
#' Runs all tinyelf checks (GLIBC symbol versions, system dependencies,
#' rpath/runpath entries) on every .so file found at the given path.
#' Prints a \code{check()}-style report and returns results invisibly.
#'
#' @param path Path to a .so file or a directory. If a directory, all
#'   .so files found recursively are audited.
#' @param glibc_max Maximum permitted GLIBC version string (default "2.28",
#'   corresponding to manylinux_2_28 policy).
#' @param glibcxx_max Maximum permitted GLIBCXX version string.
#'   Default NULL skips the GLIBCXX check.
#' @param allowlist Character vector of permitted shared library sonames.
#'   Default is \code{manylinux_libs()}.
#' @param rpath_ok Character vector of permitted rpath prefixes.
#'   Default \code{c("$ORIGIN", "$LIB")}.
#' @param machine_readable Logical. If TRUE, return results list without
#'   printing. Default FALSE.
#'
#' @return Invisibly, a list of per-file result lists. Each element has:
#'   \describe{
#'     \item{file}{Path to the .so file.}
#'     \item{pass}{Logical overall result.}
#'     \item{symbols}{Result from \code{check_symbols()}.}
#'     \item{deps}{Result from \code{check_deps()}.}
#'     \item{rpath}{Result from \code{check_rpath()}.}
#'   }
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Audit all .so files in an installed package
#' audit_so(system.file("libs", package = "stats"))
#'
#' # Stricter GLIBC threshold
#' audit_so("mypackage/src/mypackage.so", glibc_max = "2.17")
#'
#' # Machine-readable for CI
#' res <- audit_so(".", machine_readable = TRUE)
#' all_pass <- all(vapply(res, function(x) x$pass, logical(1)))
#' }
audit_so <- function(path = ".", glibc_max = "2.28", glibcxx_max = NULL,
                     allowlist = manylinux_libs(),
                     rpath_ok = c("$ORIGIN", "$LIB"),
                     machine_readable = FALSE) {
    .require_linux()

    so_files <- .find_so_files(path)
    if (length(so_files) == 0L) {
        message("No .so files found at: ", path)
        return(invisible(list()))
    }

    results <- lapply(so_files, function(f) {
        sym <- check_symbols(f, glibc_max = glibc_max,
                             glibcxx_max = glibcxx_max)
        deps <- check_deps(f, allowlist = allowlist)
        rp <- check_rpath(f, rpath_ok = rpath_ok)
        list(
             file = f,
             pass = sym$pass && deps$pass && rp$pass,
             symbols = sym,
             deps = deps,
             rpath = rp
        )
    })
    names(results) <- basename(so_files)

    if (!machine_readable) {
        .print_report(results)
    }

    n_fail <- sum(vapply(results, function(r) !isTRUE(r$pass), logical(1L)))
    if (n_fail > 0L) {
        message(n_fail, " of ", length(results), " .so file(s) FAILED audit.")
    } else {
        message("All ", length(results), " .so file(s) passed.")
    }

    invisible(results)
}

