% tinyrox says don't edit this manually, but it can't stop you!
\name{audit_so}
\alias{audit_so}
\title{Audit Shared Libraries for Portability}
\usage{
audit_so(path = ".", glibc_max = "2.28", glibcxx_max = NULL,
         allowlist = manylinux_libs(), rpath_ok = c("$ORIGIN", "$LIB"),
         transitive = FALSE, machine_readable = FALSE)
}
\arguments{
\item{path}{Path to a .so file or a directory. If a directory, all
.so files found recursively are audited.}

\item{glibc_max}{Maximum permitted GLIBC version string (default "2.28",
corresponding to manylinux_2_28 policy).}

\item{glibcxx_max}{Maximum permitted GLIBCXX version string.
Default NULL skips the GLIBCXX check.}

\item{allowlist}{Character vector of permitted shared library sonames.
Default is \code{manylinux_libs()}.}

\item{rpath_ok}{Character vector of permitted rpath prefixes.
Default \code{c("$ORIGIN", "$LIB")}.}

\item{transitive}{Logical. If FALSE (default), check only direct
dependencies. If TRUE, check the full transitive closure via ldd
(includes indirect deps from libR.so, etc.).}

\item{machine_readable}{Logical. If TRUE, return results list without
printing. Default FALSE.}
}
\value{
Invisibly, a list of per-file result lists. Each element has:
  \describe{
    \item{file}{Path to the .so file.}
    \item{pass}{Logical overall result.}
    \item{symbols}{Result from \code{check_symbols()}.}
    \item{deps}{Result from \code{check_deps()}.}
    \item{rpath}{Result from \code{check_rpath()}.}
  }
}
\description{
Runs all tinyelf checks (GLIBC symbol versions, system dependencies,
rpath/runpath entries) on every .so file found at the given path.
Prints a \code{check()}-style report and returns results invisibly.
}
\examples{
\dontrun{
# Audit all .so files in an installed package
audit_so(system.file("libs", package = "stats"))

# Stricter GLIBC threshold
audit_so("mypackage/src/mypackage.so", glibc_max = "2.17")

# Machine-readable for CI
res <- audit_so(".", machine_readable = TRUE)
all_pass <- all(vapply(res, function(x) x$pass, logical(1)))
}
}
