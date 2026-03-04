# Fabricated readelf -sW output
lines <- c(
  "Symbol table '.dynsym' contains 5 entries:",
  "   Num:    Value          Size Type    Bind   Vis      Ndx Name",
  "     0: 0000000000000000     0 NOTYPE  LOCAL  DEFAULT  UND ",
  "    41: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND exp@GLIBC_2.29 (6)",
  "   102: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND log@GLIBC_2.29 (6)",
  "    19: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND tanh@GLIBC_2.2.5 (2)",
  "     3: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND malloc@GLIBC_2.17 (3)"
)

# Threshold 2.28 — should flag exp and log (2.29 > 2.28)
res <- tinyelf:::.parse_symbol_issues(lines, "2.28", NULL)
expect_false(res$pass)
expect_equal(length(res$issues), 2L)
expect_true(any(grepl("exp@GLIBC_2.29", res$issues)))
expect_true(any(grepl("log@GLIBC_2.29", res$issues)))
expect_equal(res$max_glibc, "2.29")

# Threshold 2.29 — should pass (nothing exceeds 2.29)
res2 <- tinyelf:::.parse_symbol_issues(lines, "2.29", NULL)
expect_true(res2$pass)
expect_equal(length(res2$issues), 0L)

# Threshold 2.17 — should flag exp and log (2.29 > 2.17)
# tanh@GLIBC_2.2.5 is version 2.2.5 which is < 2.17, so not flagged
res3 <- tinyelf:::.parse_symbol_issues(lines, "2.17", NULL)
expect_false(res3$pass)
expect_equal(length(res3$issues), 2L)

# Very high threshold — all pass
res4 <- tinyelf:::.parse_symbol_issues(lines, "99.0", NULL)
expect_true(res4$pass)

# GLIBCXX check
lines_cxx <- c(
  "    5: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND _ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERmm@GLIBCXX_3.4.21 (4)",
  "    6: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND __cxa_atexit@GLIBC_2.17 (3)"
)
res5 <- tinyelf:::.parse_symbol_issues(lines_cxx, "2.28", "3.4.20")
expect_false(res5$pass)
expect_equal(length(res5$issues), 1L)
expect_true(grepl("GLIBCXX_3.4.21", res5$issues[1]))

# .extract_symbol_name
line <- "    41: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND exp@GLIBC_2.29 (6)"
expect_equal(tinyelf:::.extract_symbol_name(line), "exp")
