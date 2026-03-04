# Integration tests — Linux only, real .so files
if (.Platform$OS.type == "unix" && Sys.info()[["sysname"]] == "Linux") {

  # Find a real .so from base R
  stats_so <- system.file("libs", "stats.so", package = "stats")

  if (nzchar(stats_so) && file.exists(stats_so)) {

    # check_symbols returns correct structure
    res <- check_symbols(stats_so, glibc_max = "99.0")
    expect_true(is.list(res))
    expect_true(is.logical(res$pass))
    expect_true(is.character(res$issues))

    # check_deps returns correct structure
    res2 <- check_deps(stats_so)
    expect_true(is.list(res2))
    expect_true(is.logical(res2$pass))
    expect_true(is.character(res2$all_deps))
    expect_true(length(res2$all_deps) > 0L)

    # check_rpath returns correct structure
    res3 <- check_rpath(stats_so)
    expect_true(is.list(res3))
    expect_true(is.logical(res3$pass))

    # audit_so on the libs directory
    libs_dir <- system.file("libs", package = "stats")
    res4 <- audit_so(libs_dir, glibc_max = "99.0", machine_readable = TRUE)
    expect_true(is.list(res4))
    expect_true(length(res4) > 0L)
    expect_true("pass" %in% names(res4[[1]]))
  }

  # No .so files in a temp dir
  tmp_empty <- tempfile()
  dir.create(tmp_empty)
  on.exit(unlink(tmp_empty, recursive = TRUE), add = TRUE)
  res5 <- audit_so(tmp_empty, machine_readable = TRUE)
  expect_equal(length(res5), 0L)

  # manylinux_libs returns non-empty character vector
  libs <- manylinux_libs()
  expect_true(is.character(libs))
  expect_true(length(libs) > 20L)
  expect_true("libc.so.6" %in% libs)
}
