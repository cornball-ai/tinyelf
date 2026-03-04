% tinyrox says don't edit this manually, but it can't stop you!
\name{check_deps}
\alias{check_deps}
\title{Check Shared Library Dependencies Against Allowlist}
\usage{
check_deps(path, allowlist = manylinux_libs())
}
\arguments{
\item{path}{Path to a single .so file.}

\item{allowlist}{Character vector of permitted sonames.
Default is \code{manylinux_libs()}.}
}
\value{
A list with components:
  \describe{
    \item{pass}{Logical. TRUE if all deps are on the allowlist.}
    \item{issues}{Character vector of unexpected sonames.}
    \item{missing}{Character vector of sonames reported "not found".}
    \item{all_deps}{Character vector of all sonames found.}
  }
}
\description{
Runs \code{ldd} on the given .so file and checks all resolved shared
library dependencies against the manylinux permitted set (or a custom
allowlist). Flags any library not on the allowlist and any libraries
reported as "not found".
}
