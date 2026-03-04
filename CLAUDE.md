# tinyelf

Audit R shared libraries for portability on Linux. Inspired by auditwheel.

## Exports

| Function | Purpose |
|----------|---------|
| `audit_so()` | Full audit of .so files (all checks combined) |
| `check_symbols()` | GLIBC/GLIBCXX symbol version audit via readelf |
| `check_deps()` | Shared library dependency check via ldd |
| `check_rpath()` | rpath/runpath inspection via readelf |
| `format_report()` | Format audit results as character vector |
| `manylinux_libs()` | Returns permitted library sonames |

## File Structure

| File | Purpose |
|------|---------|
| R/audit.R | Main entry point: audit_so() |
| R/symbols.R | check_symbols() + .parse_symbol_issues() |
| R/deps.R | check_deps() + .parse_ldd_output() |
| R/rpath.R | check_rpath() + .parse_rpath_entries() |
| R/report.R | format_report() + .print_report() + .format_file_result() |
| R/allowlist.R | MANYLINUX_LIBS constant + manylinux_libs() |
| R/utils.R | Platform checks, system2 wrappers, version parsing |

## System Requirements

Linux only (OS_type: unix in DESCRIPTION). Requires binutils (readelf, ldd).

## Things you SHOULD do

- Test parsing logic with fabricated tool output (no .so needed)
- Gate real .so tests on Linux platform detection
- Keep functions under 80 lines

## Things you SHOULD NOT do

- Add Imports dependencies
- Use stop() on audit failure (report and return instead)
- Hardcode paths to system libraries
