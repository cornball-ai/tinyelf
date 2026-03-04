#' Audit GLIBC Symbol Versions in a Shared Library
#'
#' Runs \code{readelf -sW} on the given .so file and checks all versioned
#' symbol references against the specified maximum GLIBC version. Symbols
#' newer than the threshold indicate the library will not load on older
#' systems.
#'
#' @param path Path to a single .so file.
#' @param glibc_max Maximum permitted GLIBC version string (default "2.28").
#' @param glibcxx_max Maximum permitted GLIBCXX version string.
#'   Default NULL skips the GLIBCXX check.
#'
#' @return A list with components:
#'   \describe{
#'     \item{pass}{Logical. TRUE if no symbols exceed the threshold.}
#'     \item{issues}{Character vector of offending "symbol@@VERSION" strings.}
#'     \item{max_glibc}{Highest GLIBC version found (string), or NA.}
#'   }
#'
#' @export
check_symbols <- function(path, glibc_max = "2.28", glibcxx_max = NULL) {
    .require_linux()
    .require_tool("readelf")
    path <- normalizePath(path, mustWork = TRUE)
    lines <- .run_cmd("readelf", "-sW", path)
    .parse_symbol_issues(lines, glibc_max, glibcxx_max)
}

#' Parse readelf -sW Output for Version Issues
#'
#' @noRd
.parse_symbol_issues <- function(lines, glibc_max, glibcxx_max) {
    threshold_glibc <- .parse_version(glibc_max)
    issues <- character()
    max_found <- NA_character_

    for (line in lines) {
        m <- regmatches(line, regexpr("@GLIBC_([0-9]+\\.[0-9]+(\\.[0-9]+)?)",
                                      line, perl = TRUE))
        if (length(m) > 0L && nchar(m) > 0L) {
            ver_str <- sub("^@GLIBC_", "", m)
            ver <- .parse_version(ver_str)
            if (.version_gt(ver, threshold_glibc)) {
                sym <- .extract_symbol_name(line)
                issues <- c(issues, paste0(sym, "@GLIBC_", ver_str))
            }
            if (is.na(max_found) ||
                .version_gt(ver, .parse_version(max_found))) {
                max_found <- ver_str
            }
        }

        if (!is.null(glibcxx_max)) {
            m2 <- regmatches(line, regexpr("@GLIBCXX_([0-9]+\\.[0-9]+(\\.[0-9]+)?)",
                    line, perl = TRUE))
            if (length(m2) > 0L && nchar(m2) > 0L) {
                ver_str2 <- sub("^@GLIBCXX_", "", m2)
                ver2 <- .parse_version(ver_str2)
                if (.version_gt(ver2, .parse_version(glibcxx_max))) {
                    sym <- .extract_symbol_name(line)
                    issues <- c(issues, paste0(sym, "@GLIBCXX_", ver_str2))
                }
            }
        }
    }

    list(pass = length(issues) == 0L, issues = issues, max_glibc = max_found)
}

#' Extract Symbol Name from readelf -sW Line
#'
#' @noRd
.extract_symbol_name <- function(line) {
    parts <- strsplit(trimws(line), "\\s+")[[1L]]
    at_fields <- grep("@", parts, value = TRUE)
    if (length(at_fields) == 0L) {
        return("")
    }
    sub("@.*$", "", at_fields[1L])
}

