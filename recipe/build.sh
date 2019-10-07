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

for libtype in shared static
do
    mkdir build_${libtype}
    cd build_${libtype}
    BUILD_STATIC_LIBS=$( [[ "${libtype}" == "static" ]] && echo "1" || echo "0" )
    BUILD_SHARED_LIBS=$( [[ "${libtype}" == "shared" ]] && echo "1" || echo "0" )
    cmake \
      -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
      -DCMAKE_INSTALL_LIBDIR="${PREFIX}/lib" \
      -DCMAKE_PREFIX_PATH="${PREFIX}" \
      -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
      -DBUILD_STATIC_LIBS="${BUILD_STATIC_LIBS}" \
      -DBUILD_SHARED_LIBS="${BUILD_SHARED_LIBS}" \
      -DPYTHON_EXECUTABLE="${BUILD_PREFIX}/bin/python" \
      ..

    make -j${CPU_COUNT}
    eval ${LIBRARY_SEARCH_VAR}=$PREFIX/lib make jsoncpp_check
    make install
    cd ..
done
