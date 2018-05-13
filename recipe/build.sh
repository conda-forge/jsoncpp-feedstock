#!/bin/bash

# FIXME: This is a hack to make sure the environment is activated.
# The reason this is required is due to the conda-build issue
# mentioned below.
#
# https://github.com/conda/conda-build/issues/910
#
source activate "${CONDA_DEFAULT_ENV}"

if [ "$(uname)" == "Darwin" ]
then
    export LIBRARY_SEARCH_VAR=DYLD_FALLBACK_LIBRARY_PATH
else
    export LIBRARY_SEARCH_VAR=LD_LIBRARY_PATH
fi

mkdir build
cd build
cmake \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCMAKE_INSTALL_LIBDIR="${PREFIX}/lib" \
  -DCMAKE_PREFIX_PATH="${PREFIX}" \
  -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
  -DBUILD_STATIC_LIBS=1 \
  -DBUILD_SHARED_LIBS=1 \
  -DPYTHON_EXECUTABLE="${BUILD_PREFIX}/bin/python" \
  ..

make -j${CPU_COUNT}
eval ${LIBRARY_SEARCH_VAR}=$PREFIX/lib make jsoncpp_check
make install
