#' Assert Linux Platform
#'
#' Stops with an informative message on non-Linux platforms.
#'
#' @noRd
.require_linux <- function() {
    if (.Platform$OS.type != "unix" || Sys.info()[["sysname"]] != "Linux") {
        stop(
             "tinyelf requires Linux. ",
             "The binutils tools (readelf, ldd) are not available on ",
             Sys.info()[["sysname"]], ".",
             call. = FALSE
        )
    }
    invisible(TRUE)
}

#' Assert a System Tool is Available
#'
#' @noRd
.require_tool <- function(tool) {
    if (nchar(Sys.which(tool)) == 0L) {
        stop(
             "Required tool '", tool, "' not found on PATH. ",
             "Install binutils: apt-get install binutils",
             call. = FALSE
        )
    }
    invisible(TRUE)
}

#' Run a System Command and Return Lines
#'
#' Thin wrapper around system2() that captures stdout and checks exit status.
#'
#' @noRd
.run_cmd <- function(cmd, args, so_path) {
    out <- system2(cmd, args = c(args, shQuote(so_path)),
                   stdout = TRUE, stderr = FALSE)
    status <- attr(out, "status")
    if (!is.null(status) && status != 0L) {
        warning("'", cmd, "' returned non-zero exit status ", status,
                " for: ", so_path, call. = FALSE)
        return(character())
    }
    out
}

#' Parse a Version String into an Integer Vector
#'
#' Converts "2.28" into c(2L, 28L).
#'
#' @noRd
.parse_version <- function(v) {
    as.integer(strsplit(v, "\\.")[[1L]])
}

#' Compare Two Version Tuples
#'
#' Returns TRUE if a > b (lexicographic on integer components).
#'
#' @noRd
.version_gt <- function(a, b) {
    n <- max(length(a), length(b))
    a <- c(a, rep(0L, n - length(a)))
    b <- c(b, rep(0L, n - length(b)))
    for (i in seq_len(n)) {
        if (a[i] > b[i]) {
            return(TRUE)
        }
        if (a[i] < b[i]) {
            return(FALSE)
        }
    }
    FALSE
}

#' Find .so Files in a Path
#'
#' @noRd
.find_so_files <- function(path) {
    if (!file.exists(path)) {
        stop("Path does not exist: ", path, call. = FALSE)
    }
    if (grepl("\\.so(\\.[0-9]+)*$", path)) {
        return(path)
    }
    list.files(path, pattern = "\\.so(\\.[0-9]+)*$",
               recursive = TRUE, full.names = TRUE)
}

