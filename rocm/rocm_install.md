# Compilation of ROCm and HIP

This document describes the installation of ROCm 4.0 and HIP from scratch. It is still under testing but some initial cases worked.Some libraries are not required for NVIDIA HW.

* Start with default options

```
module load gcc
module load cuda
module load cmake
```

* Install rocm-cmake

```
git clone -b rocm-4.0.0 https://github.com/RadeonOpenCompute/rocm-cmake.git
cd rocm-cmake
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/opt/rocm ..
make
sudo make install
```

* Install ROCT Thunk Interface

```
git clone -b roc-4.0.x https://github.com/RadeonOpenCompute/ROCT-Thunk-Interface.git
cd ROCT-Thunk-Interface
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/opt/rocm ..
make
sudo make install
sudo cp -r ../include /opt/rocm/
```

* Install ROCM LLVM / CLang

```
git clone -b amd-stg-open https://github.com/RadeonOpenCompute/llvm-project.git
cd llvm-project
git checkout rocm-4.0.0
mkdir build-llvm
cd build-llvm

* For NVIDIA: 
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/opt/rocm//llvm \
-DCLANG_OPENMP_NVPTX_DEFAULT_ARCH=sm_70 -DLIBOMPTARGET_NVPTX_COMPUTE_CAPABILITIES=70\
-DLLVM_ENABLE_PROJECTS="compiler-rt;lld;clang;clang-tools-extra;libcxx;libcxxabi;lld;openmp"\
-DCMAKE_C_COMPILER=`which gcc` -DCMAKE_CXX_COMPILER=`which g++`+ 
-DGCC_INSTALL_PREFIX=/appl/spack/install-tree/gcc-4.8.5/gcc-9.1.0-vpjht2/ ../llvm

make -j 8
sudo make install

cd ..
mkdir build-openmp
cd build-openmp
export CXXFLAGS=-stdlib=libc++
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/opt/rocm/llvm  \
-DCLANG_OPENMP_NVPTX_DEFAULT_ARCH=sm_70 -DLIBOMPTARGET_NVPTX_COMPUTE_CAPABILITIES=70\
-DCMAKE_C_COMPILER=/opt/rocm//llvm/bin/clang -DCMAKE_CXX_COMPILER=/opt/rocm//llvm/bin/clang++ \
 ../openmp

make -j 8
sudo make install

* For AMD HW (not tested): 
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/opt/rocm/llvm\ 
-DLLVM_ENABLE_ASSERTIONS=1 -DLLVM_TARGETS_TO_BUILD="AMDGPU;X86"\ 
-DLLVM_ENABLE_PROJECTS="compiler-rt;lld;clang" -DCMAKE_C_COMPILER=`which gcc` -DCMAKE_CXX_COMPILER=`which g++` ../llvm

make -j 8
sudo make install
```

* Install rocminfo (only for AMD HW)

```
git clone https://github.com/RadeonOpenCompute/rocminfo.git
cd rocminfo
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/opt/rocm -DROCM_DIR=/opt/rocm ..
make
sudo make install

```

* Install ROCm-Device-Libs

```
git clone -b rocm-4.0.0 http://github.com/RadeonOpenCompute/ROCm-Device-Libs.git
cd ROCm-Device-Libs
export PATH=/opt/rocm/llvm/bin:$PATH
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/opt/rocm ..
make
sudo make install
```

* Install HSA Runtime API and runtime for ROCm

```
git clone -b rocm-4.0.0 https://github.com/RadeonOpenCompute/ROCR-Runtime.git
cd ROCR-Runtime/src
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/opt/rocm -DHSAKMT_INC_PATH=/opt/rocm/include -DHSAKMT_LIB_PATH=/opt/rocm/lib64 ..
make
sudo make install
cp ../../../ROCT-Thunk-Interface/build/hsakmt-config.cmake /opt/rocm/share/rocm/cmake/
cp ../../../ROCT-Thunk-Interface/build/CMakeFiles/Export/lib64/cmake/hsakmt/hsakmtTargets* /opt/rocm/share/rocm/cmake/
```

* Install ROCm-CompilerSupport

```
git clone -b rocm-4.0.0 https://github.com/RadeonOpenCompute/ROCm-CompilerSupport
cd ROCm-CompilerSupport/lib/comgr
export PATH=/opt/rocm/llvm/bin:$PATH
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/opt/rocm ..
make
sudo make install

```

* Install ROCclr - Radeon Open Compute Common Language Runtime

```
git clone -b rocm-4.0.x https://github.com/ROCm-Developer-Tools/ROCclr.git
git clone -b roc-4.0.x https://github.com/RadeonOpenCompute/ROCm-OpenCL-Runtime.git
export CMAKE_PREFIX_PATH=${install_prefix}/lib/cmake/:$CMAKE_PREFIX_PATH

export ROCclr_DIR="$(readlink -f ROCclr)"
export OPENCL_DIR="$(readlink -f ROCm-OpenCL-Runtime)"

cd "$ROCclr_DIR"
mkdir -p build; 
cd build
cmake -DOPENCL_DIR="$OPENCL_DIR" -DCMAKE_INSTALL_PREFIX=/opt/rocm/rocclr ..
make -j$(nproc)
sudo make install
```

* Install HIP

```
git clone -b rocm-4.0.x https://github.com/ROCm-Developer-Tools/HIP.git
cd HIP
mkdir build
cd build

* For NVIDIA HW:

cmake -DCMAKE_BUILD_TYPE=Release -DHIP_COMPILER=clang -DHIP_PLATFORM=nvcc\-
DCMAKE_PREFIX_PATH=/opt/rocm-DCMAKE_INSTALL_PREFIX=/opt/rocm ..

* For AMD HW (not tested):

cmake -DCMAKE_BUILD_TYPE=Release -DHIP_COMPILER=clang -DHIP_PLATFORM=rocclr\
-DCMAKE_PREFIX_PATH=/opt/rocm -DCMAKE_INSTALL_PREFIX=/opt/rocm ..

make
sudo make install
```

## Declare environment variables

```
export HIP_PLATFORM=nvcc
export CUDA_PATH=$CUDA_INSTALL_ROOT
export HIP_PATH=/opt/rocm/
```
