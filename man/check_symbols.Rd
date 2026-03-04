% tinyrox says don't edit this manually, but it can't stop you!
\name{check_symbols}
\alias{check_symbols}
\title{Audit GLIBC Symbol Versions in a Shared Library}
\usage{
check_symbols(path, glibc_max = "2.28", glibcxx_max = NULL)
}
\arguments{
\item{path}{Path to a single .so file.}

\item{glibc_max}{Maximum permitted GLIBC version string (default "2.28").}

\item{glibcxx_max}{Maximum permitted GLIBCXX version string.
Default NULL skips the GLIBCXX check.}
}
\value{
A list with components:
  \describe{
    \item{pass}{Logical. TRUE if no symbols exceed the threshold.}
    \item{issues}{Character vector of offending "symbol@@VERSION" strings.}
    \item{max_glibc}{Highest GLIBC version found (string), or NA.}
  }
}
\description{
Runs \code{readelf -sW} on the given .so file and checks all versioned
symbol references against the specified maximum GLIBC version. Symbols
newer than the threshold indicate the library will not load on older
systems.
}
