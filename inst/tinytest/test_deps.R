# Fabricated ldd output
lines <- c(
  "\tlinux-vdso.so.1 (0x00007fff12345000)",
  "\tlibssl.so.3 => /lib/x86_64-linux-gnu/libssl.so.3 (0x00007f1234560000)",
  "\tlibc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f1234000000)",
  "\tlibm.so.6 => /lib/x86_64-linux-gnu/libm.so.6 (0x00007f1233000000)",
  "\tlibfoo.so.99 => not found",
  "\t/lib64/ld-linux-x86-64.so.2 (0x00007f1235000000)"
)

allowlist <- tinyelf::manylinux_libs()
res <- tinyelf:::.parse_ldd_output(lines, allowlist)

# libssl.so.3 is not in the manylinux allowlist
expect_false(res$pass)
expect_true("libssl.so.3" %in% res$issues)
expect_true("libfoo.so.99" %in% res$missing)
# libc, libm, linux-vdso, ld-linux should be in allowlist
expect_false("libc.so.6" %in% res$issues)
expect_false("libm.so.6" %in% res$issues)

# All deps collected
expect_true("libssl.so.3" %in% res$all_deps)
expect_true("libc.so.6" %in% res$all_deps)
expect_true("linux-vdso.so.1" %in% res$all_deps)

# Clean case: only permitted libs
lines_clean <- c(
  "\tlinux-vdso.so.1 (0x00007fff12345000)",
  "\tlibc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f1234000000)",
  "\t/lib64/ld-linux-x86-64.so.2 (0x00007f1235000000)"
)
res2 <- tinyelf:::.parse_ldd_output(lines_clean, allowlist)
expect_true(res2$pass)
expect_equal(length(res2$issues), 0L)
expect_equal(length(res2$missing), 0L)

# Empty input
res3 <- tinyelf:::.parse_ldd_output(character(), allowlist)
expect_true(res3$pass)
