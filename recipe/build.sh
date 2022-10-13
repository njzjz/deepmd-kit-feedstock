set -e

if [[ ${cuda_compiler_version} != "None" ]]; then
    DEEPMD_USE_CUDA_TOOLKIT=TRUE
    DP_VARIANT=cuda
else
    DEEPMD_USE_CUDA_TOOLKIT=FALSE
    DP_VARIANT=cpu
fi
if [[ "${target_platform}" == "osx-arm64" ]]; then
    export CMAKE_OSX_ARCHITECTURES = "arm64"
fi
DP_VARIANT=${DP_VARIANT} \
	SETUPTOOLS_SCM_PRETEND_VERSION=$PKG_VERSION pip install . --no-deps -vv --no-use-pep517


mkdir $SRC_DIR/source/build
cd $SRC_DIR/source/build

cmake -D TENSORFLOW_ROOT=${PREFIX} \
	  -D CMAKE_INSTALL_PREFIX=${PREFIX} \
      -D USE_CUDA_TOOLKIT=${DEEPMD_USE_CUDA_TOOLKIT} \
	  -D LAMMPS_SOURCE_ROOT=$SRC_DIR/lammps \
	  ${CMAKE_ARGS} \
	  $SRC_DIR/source
make -j${CPU_COUNT}
make install
