#' Check rpath and runpath Entries in a Shared Library
#'
#' Runs \code{readelf -d} on the given .so file and inspects RPATH and
#' RUNPATH entries. Flags any absolute path that does not match a permitted
#' pattern. The \code{$ORIGIN} token is always permitted by default.
#'
#' @param path Path to a single .so file.
#' @param rpath_ok Character vector of permitted path prefixes.
#'   Default \code{c("$ORIGIN", "$LIB")}.
#'
#' @return A list with components:
#'   \describe{
#'     \item{pass}{Logical. TRUE if no suspicious rpath entries found.}
#'     \item{issues}{Character vector of offending rpath entries.}
#'     \item{entries}{Character vector of all rpath/runpath entries found.}
#'   }
#'
#' @export
check_rpath <- function(path, rpath_ok = c("$ORIGIN", "$LIB")) {
    .require_linux()
    .require_tool("readelf")
    path <- normalizePath(path, mustWork = TRUE)
    lines <- .run_cmd("readelf", "-d", path)
    .parse_rpath_entries(lines, rpath_ok)
}

#' Parse readelf -d Output for rpath/runpath Entries
#'
#' @noRd
.parse_rpath_entries <- function(lines, rpath_ok) {
    entries <- character()

    for (line in lines) {
        if (!grepl("\\(RPATH\\)|\\(RUNPATH\\)", line)) {
            next
        }
        m <- regmatches(line, regexpr("\\[([^]]+)\\]", line))
        if (length(m) == 0L || nchar(m) == 0L) {
            next
        }
        val <- sub("^\\[", "", sub("\\]$", "", m))
        paths <- strsplit(val, ":")[[1L]]
        entries <- c(entries, paths)
    }

    if (length(entries) == 0L) {
        return(list(pass = TRUE, issues = character(), entries = character()))
    }

    issues <- character()
    for (e in entries) {
        if (!startsWith(e, "/")) {
            next
        }
        permitted <- any(vapply(rpath_ok,
                                function(ok) startsWith(e, ok),
                                logical(1L)))
        if (!permitted) {
            issues <- c(issues, e)
        }
    }

    list(pass = length(issues) == 0L, issues = issues, entries = entries)
}

