#' Format an Audit Report
#'
#' Converts the list returned by \code{audit_so()} into a human-readable
#' character vector. Output style mirrors \code{R CMD check}: each file
#' gets a header, each check gets a PASS/FAIL line, failing checks list
#' the offending entries.
#'
#' @param results List as returned by \code{audit_so()}.
#' @param color Logical. Use ANSI color codes? Default auto-detects.
#'
#' @return Character vector of formatted lines (invisibly).
#'
#' @export
format_report <- function(results, color = isatty(stdout())) {
    lines <- character()
    for (res in results) {
        lines <- c(lines, .format_file_result(res, color))
        lines <- c(lines, "")
    }
    invisible(lines)
}

#' Print an Audit Report
#'
#' @noRd
.print_report <- function(results, color = isatty(stdout())) {
    lines <- format_report(results, color)
    cat(lines, sep = "\n")
}

#' Format a Single File Result
#'
#' @noRd
.format_file_result <- function(res, color) {
    if (color) {
        pass_str <- "\033[32mPASS\033[0m"
    } else {
        pass_str <- "PASS"
    }
    if (color) {
        fail_str <- "\033[31mFAIL\033[0m"
    } else {
        fail_str <- "FAIL"
    }

    if (isTRUE(res$pass)) {
        overall <- pass_str
    } else {
        overall <- fail_str
    }
    hdr <- paste0("* checking ", basename(res$file), " ... ", overall)
    lines <- hdr

    checks <- list(
                   list(name = "  GLIBC symbols", r = res$symbols),
                   list(name = "  system deps", r = res$deps),
                   list(name = "  rpath/runpath", r = res$rpath)
    )

    for (chk in checks) {
        r <- chk$r
        if (is.null(r)) {
            next
        }
        if (isTRUE(r$pass)) {
            status <- pass_str
        } else {
            status <- fail_str
        }
        lines <- c(lines, paste0(chk$name, ": ", status))
        if (!isTRUE(r$pass)) {
            for (issue in r$issues) {
                lines <- c(lines, paste0("    - ", issue))
            }
            if (!is.null(r$missing) && length(r$missing) > 0L) {
                for (m in r$missing) {
                    lines <- c(lines, paste0("    - ", m, " [NOT FOUND]"))
                }
            }
        }
    }
    lines
}

