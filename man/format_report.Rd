% tinyrox says don't edit this manually, but it can't stop you!
\name{format_report}
\alias{format_report}
\title{Format an Audit Report}
\usage{
format_report(results, color = isatty(stdout()))
}
\arguments{
\item{results}{List as returned by \code{audit_so()}.}

\item{color}{Logical. Use ANSI color codes? Default auto-detects.}
}
\value{
Character vector of formatted lines (invisibly).
}
\description{
Converts the list returned by \code{audit_so()} into a human-readable
character vector. Output style mirrors \code{R CMD check}: each file
gets a header, each check gets a PASS/FAIL line, failing checks list
the offending entries.
}
