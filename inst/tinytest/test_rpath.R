# Hardcoded build paths — should fail
lines_bad <- c(
  " 0x000000000000000f (RPATH)              Library rpath: [/home/builder/conda/lib:/opt/build/lib]"
)
res <- tinyelf:::.parse_rpath_entries(lines_bad, c("$ORIGIN", "$LIB"))
expect_false(res$pass)
expect_equal(length(res$issues), 2L)
expect_true("/home/builder/conda/lib" %in% res$issues)
expect_true("/opt/build/lib" %in% res$issues)

# $ORIGIN-relative — should pass
lines_good <- c(
  " 0x000000000000001d (RUNPATH)            Library runpath: [$ORIGIN/../lib]"
)
res2 <- tinyelf:::.parse_rpath_entries(lines_good, c("$ORIGIN", "$LIB"))
expect_true(res2$pass)
expect_equal(length(res2$entries), 1L)

# Mixed: one good, one bad
lines_mixed <- c(
  " 0x000000000000001d (RUNPATH)            Library runpath: [$ORIGIN/lib:/usr/local/custom/lib]"
)
res3 <- tinyelf:::.parse_rpath_entries(lines_mixed, c("$ORIGIN", "$LIB"))
expect_false(res3$pass)
expect_equal(length(res3$issues), 1L)
expect_equal(res3$issues, "/usr/local/custom/lib")

# No rpath at all — should pass
lines_none <- c(
  " 0x0000000000000001 (NEEDED)             Shared library: [libc.so.6]",
  " 0x000000000000000e (SONAME)             Library soname: [libfoo.so.1]"
)
res4 <- tinyelf:::.parse_rpath_entries(lines_none, c("$ORIGIN", "$LIB"))
expect_true(res4$pass)
expect_equal(length(res4$entries), 0L)

# Custom allowlist with absolute path permitted
res5 <- tinyelf:::.parse_rpath_entries(lines_bad, c("$ORIGIN", "/home/builder/conda/lib"))
expect_false(res5$pass)
expect_equal(length(res5$issues), 1L)
expect_equal(res5$issues, "/opt/build/lib")
