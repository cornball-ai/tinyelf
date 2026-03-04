% tinyrox says don't edit this manually, but it can't stop you!
\name{check_rpath}
\alias{check_rpath}
\title{Check rpath and runpath Entries in a Shared Library}
\usage{
check_rpath(path, rpath_ok = c("$ORIGIN", "$LIB"))
}
\arguments{
\item{path}{Path to a single .so file.}

\item{rpath_ok}{Character vector of permitted path prefixes.
Default \code{c("$ORIGIN", "$LIB")}.}
}
\value{
A list with components:
  \describe{
    \item{pass}{Logical. TRUE if no suspicious rpath entries found.}
    \item{issues}{Character vector of offending rpath entries.}
    \item{entries}{Character vector of all rpath/runpath entries found.}
  }
}
\description{
Runs \code{readelf -d} on the given .so file and inspects RPATH and
RUNPATH entries. Flags any absolute path that does not match a permitted
pattern. The \code{$ORIGIN} token is always permitted by default.
}
