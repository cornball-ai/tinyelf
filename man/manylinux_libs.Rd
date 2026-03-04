% tinyrox says don't edit this manually, but it can't stop you!
\name{manylinux_libs}
\alias{manylinux_libs}
\title{Manylinux Permitted System Libraries}
\usage{
manylinux_libs()
}
\value{
Character vector of permitted sonames.
}
\description{
Returns a character vector of shared library sonames permitted under
the manylinux2014 (PEP 599) policy. These are system libraries expected
to be present on any compliant Linux distribution.
Users can extend the allowlist by combining with their own entries:
\code{c(manylinux_libs(), "libcurl.so.4")}
}
