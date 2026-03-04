#' Manylinux Permitted System Libraries
#'
#' Returns a character vector of shared library sonames permitted under
#' the manylinux2014 (PEP 599) policy. These are system libraries expected
#' to be present on any compliant Linux distribution.
#'
#' Users can extend the allowlist by combining with their own entries:
#' \code{c(manylinux_libs(), "libcurl.so.4")}
#'
#' @return Character vector of permitted sonames.
#'
#' @export
manylinux_libs <- function() {
    .MANYLINUX_LIBS
}

#' @noRd
.MANYLINUX_LIBS <- c(
                     # Virtual / loader
                     "linux-vdso.so.1",
                     "linux-gate.so.1",
                     "ld-linux.so.2",
                     "ld-linux-x86-64.so.2",
                     "ld-linux-aarch64.so.1",
                     "ld-linux-armhf.so.3",
                     # C runtime
                     "libc.so.6",
                     "libm.so.6",
                     "libpthread.so.0",
                     "libdl.so.2",

                     "librt.so.1",
                     "libutil.so.1",
                     "libnsl.so.1",
                     "libresolv.so.2",
                     "libcrypt.so.1",
                     # C++ runtime
                     "libstdc++.so.6",
                     "libgcc_s.so.1",
                     # Fortran runtime
                     "libgfortran.so.5",
                     "libgfortran.so.4",
                     "libgfortran.so.3",
                     "libquadmath.so.0",
                     # OpenMP
                     "libgomp.so.1",
                     # R itself
                     "libR.so",
                     # X11 / display (manylinux2014)
                     "libGL.so.1",
                     "libGLdispatch.so.0",
                     "libGLX.so.0",
                     "libX11.so.6",
                     "libXext.so.6",
                     "libXrender.so.1",
                     "libICE.so.6",
                     "libSM.so.6",
                     "libXi.so.6",
                     "libXfixes.so.3",
                     "libXcursor.so.1",
                     "libXft.so.2",
                     "libXrandr.so.2",
                     "libXss.so.1",
                     "libXt.so.6",
                     "libxcb.so.1"
)

