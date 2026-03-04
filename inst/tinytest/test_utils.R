# .parse_version
expect_equal(tinyelf:::.parse_version("2.28"), c(2L, 28L))
expect_equal(tinyelf:::.parse_version("3.4.25"), c(3L, 4L, 25L))
expect_equal(tinyelf:::.parse_version("2.2.5"), c(2L, 2L, 5L))

# .version_gt
expect_true(tinyelf:::.version_gt(c(2L, 29L), c(2L, 28L)))
expect_false(tinyelf:::.version_gt(c(2L, 28L), c(2L, 28L)))
expect_false(tinyelf:::.version_gt(c(2L, 17L), c(2L, 28L)))
expect_true(tinyelf:::.version_gt(c(3L, 0L), c(2L, 99L)))
# Different lengths
expect_true(tinyelf:::.version_gt(c(2L, 28L, 1L), c(2L, 28L)))
expect_false(tinyelf:::.version_gt(c(2L, 28L), c(2L, 28L, 1L)))

# .find_so_files — directory
tmp_dir <- tempfile("tinyelf_test_")
dir.create(tmp_dir)
file.create(file.path(tmp_dir, "foo.so"))
file.create(file.path(tmp_dir, "bar.so.1"))
file.create(file.path(tmp_dir, "baz.txt"))
found <- tinyelf:::.find_so_files(tmp_dir)
expect_equal(length(found), 2L)

# .find_so_files — single .so file
so_file <- file.path(tmp_dir, "foo.so")
expect_equal(tinyelf:::.find_so_files(so_file), so_file)

# Cleanup
unlink(tmp_dir, recursive = TRUE)
