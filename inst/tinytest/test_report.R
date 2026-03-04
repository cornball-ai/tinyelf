# Mock results for format_report
mock_results <- list(
  "foo.so" = list(
    file = "/path/to/foo.so",
    pass = FALSE,
    symbols = list(pass = FALSE, issues = c("exp@GLIBC_2.29"), max_glibc = "2.29"),
    deps = list(pass = TRUE, issues = character(), missing = character(), all_deps = "libc.so.6"),
    rpath = list(pass = TRUE, issues = character(), entries = character())
  ),
  "bar.so" = list(
    file = "/path/to/bar.so",
    pass = TRUE,
    symbols = list(pass = TRUE, issues = character(), max_glibc = "2.17"),
    deps = list(pass = TRUE, issues = character(), missing = character(), all_deps = "libc.so.6"),
    rpath = list(pass = TRUE, issues = character(), entries = character())
  )
)

lines <- format_report(mock_results, color = FALSE)
expect_true(is.character(lines))
expect_true(any(grepl("foo.so", lines)))
expect_true(any(grepl("bar.so", lines)))
expect_true(any(grepl("FAIL", lines)))
expect_true(any(grepl("PASS", lines)))
expect_true(any(grepl("exp@GLIBC_2.29", lines)))

# All-pass results
mock_pass <- list(
  "ok.so" = list(
    file = "/path/to/ok.so",
    pass = TRUE,
    symbols = list(pass = TRUE, issues = character(), max_glibc = "2.17"),
    deps = list(pass = TRUE, issues = character(), missing = character(), all_deps = character()),
    rpath = list(pass = TRUE, issues = character(), entries = character())
  )
)
lines2 <- format_report(mock_pass, color = FALSE)
expect_false(any(grepl("FAIL", lines2)))
