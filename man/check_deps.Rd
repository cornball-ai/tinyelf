% tinyrox says don't edit this manually, but it can't stop you!
\name{check_deps}
\alias{check_deps}
\title{Check Shared Library Dependencies Against Allowlist}
\usage{
check_deps(path, allowlist = manylinux_libs(), transitive = FALSE)
}
\arguments{
\item{path}{Path to a single .so file.}

\item{allowlist}{Character vector of permitted sonames.
Default is \code{manylinux_libs()}.}

\item{transitive}{Logical. If FALSE (default), check only direct
dependencies (NEEDED entries). If TRUE, check the full transitive
closure via ldd.}
}
\value{
A list with components:
  \describe{
    \item{pass}{Logical. TRUE if all deps are on the allowlist.}
    \item{issues}{Character vector of unexpected sonames.}
    \item{missing}{Character vector of sonames reported "not found"
      (only when \code{transitive = TRUE}).}
    \item{all_deps}{Character vector of all sonames found.}
  }
}
\description{
Checks the shared library dependencies of a .so file against a permitted
allowlist. By default checks only direct dependencies (via
\code{readelf -d}). Set \code{transitive = TRUE} to check the full
dependency tree (via \code{ldd}), which includes libraries pulled in
by libR.so and other indirect dependencies.
}
