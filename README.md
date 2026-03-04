# tinyelf

Audit R shared libraries for portability on Linux. Inspired by Python's [auditwheel](https://github.com/pypa/auditwheel).

tinyelf checks `.so` files for three classes of portability problems:

- **GLIBC symbol versions** — flags symbols requiring a newer glibc than your target baseline (default 2.28, the manylinux_2_28 policy)
- **System library dependencies** — checks direct linkage against a manylinux allowlist, catching unexpected deps without the false positives from transitive `ldd` output
- **rpath/runpath entries** — catches hardcoded build-container paths that won't exist on user machines

Zero dependencies. Base R only. Wraps `readelf` and `ldd` via `system2()`.

## Installation

```r
# From GitHub
remotes::install_github("cornball-ai/tinyelf")
```

## Usage

```r
library(tinyelf)

# Audit all .so files in an installed package
audit_so(system.file("libs", package = "mypackage"))

# Stricter threshold
audit_so("path/to/lib.so", glibc_max = "2.17")

# Machine-readable output for CI
res <- audit_so(".", machine_readable = TRUE)
all_pass <- all(vapply(res, function(x) x$pass, logical(1)))
```

Example output:

```
* checking mypackage.so ... FAIL
  GLIBC symbols: FAIL
    - exp@GLIBC_2.29
    - log@GLIBC_2.29
  system deps: PASS
  rpath/runpath: PASS

1 of 1 .so file(s) FAILED audit.
```

## Individual checks

```r
# GLIBC symbol versions (via readelf -sW, .dynsym only)
check_symbols("lib.so", glibc_max = "2.28")
check_symbols("lib.so", glibc_max = "2.28", glibcxx_max = "3.4.25")

# Direct dependencies (via readelf -d NEEDED entries)
check_deps("lib.so")
check_deps("lib.so", transitive = TRUE)  # full ldd closure
check_deps("lib.so", allowlist = c(manylinux_libs(), "libcurl.so.4"))

# rpath/runpath inspection (via readelf -d)
check_rpath("lib.so")
check_rpath("lib.so", rpath_ok = c("$ORIGIN", "/opt/myapp/lib"))
```

## CI usage

Fail a build if binaries exceed your target glibc:

```yaml
- name: Audit shared libraries
  run: |
    Rscript -e '
      res <- tinyelf::audit_so("path/to/libs", glibc_max = "2.28", machine_readable = TRUE)
      if (any(!vapply(res, function(x) x$pass, logical(1)))) stop("Audit failed")
    '
```

## Platform support

Linux only. Requires `binutils` (provides `readelf`) and `ldd`. These are present on any Linux system with build tools. On macOS/Windows, tinyelf functions stop with an informative error.

## License

GPL-3
