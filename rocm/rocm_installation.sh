# Install ROCm ecosystem with options for NVIDIA HW
#!/bin/sh

module load gcc
module load cuda
module load cmake

# Edit the variabled bellow if necessary

export cur=$PWD
export install_prefix=/opt/rocm/
export sud="" # Declare the value empty (default) if no sudo required, otherwise declare sudo, it is empty for safety purposes
export ver="rocm-4.0.0"
export targ=nvidia # Declare nvidia or amd
export nprocs=8 # Processes to be used from make
export gccpath=/appl/spack/install-tree/gcc-4.8.5/gcc-9.1.0-vpjht2/ # PATH of your GNU installation

# Install rocm-cmake

git clone -b $ver  https://github.com/RadeonOpenCompute/rocm-cmake.git
cd rocm-cmake
git checkout rocm-4.0.0
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=${install_prefix} ..
make
$sud make install
cd $cur

# Install ROCT Thunk Interface

git clone -b $ver https://github.com/RadeonOpenCompute/ROCT-Thunk-Interface.git
cd ROCT-Thunk-Interface
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=${install_prefix} ..
make -j $nprocs
$sud make install
$sud cp -r ../include ${install_prefix}
cd $cur

# Install ROCM LLVM/CLang

git clone -b $ver https://github.com/RadeonOpenCompute/llvm-project.git
cd llvm-project
mkdir build-llvm
cd build-llvm

if [ $targ = "nvidia" ]; then 

cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${install_prefix}/llvm \
-DCLANG_OPENMP_NVPTX_DEFAULT_ARCH=sm_70 -DLIBOMPTARGET_NVPTX_COMPUTE_CAPABILITIES=70  \
-DCMAKE_C_COMPILER=`which gcc` -DCMAKE_CXX_COMPILER=`which g++` \
-DLLVM_ENABLE_PROJECTS="compiler-rt;lld;clang;clang-tools-extra;libcxx;libcxxabi;lld;openmp"  \
-DGCC_INSTALL_PREFIX=$gccpath ../llvm


make -j $nprocs
$sud make install

cd ..
mkdir build-openmp
cd build-openmp
export PATH=${install_prefix}/llvm/bin:$cur/llvm-project/build/bin:$PATH
export CXXFLAGS=-stdlib=libc++
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${install_prefix}/llvm  \
-DCLANG_OPENMP_NVPTX_DEFAULT_ARCH=sm_70 -DLIBOMPTARGET_NVPTX_COMPUTE_CAPABILITIES=70 \
-DCMAKE_C_COMPILER=${install_prefix}/llvm/bin/clang -DCMAKE_CXX_COMPILER=${install_prefix}/llvm/bin/clang++ \
 ../openmp

make -j $nprocs
$sud make install
unset CXXFLAGS
else
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${install_prefix}/llvm -DLLVM_ENABLE_ASSERTIONS=1 -DLLVM_TARGETS_TO_BUILD="AMDGPU;X86"\ 
-DLLVM_ENABLE_ASSERTIONS=1 -DLLVM_TARGETS_TO_BUILD="AMDGPU;X86"\ 
-DLLVM_ENABLE_PROJECTS="compiler-rt;lld;clang" ../llvm


make -j $nprocs
$sud make install
cd ..
mkdir build-openmp
cd build-openmp


fi

cd $cur

# Install rocminfo

if [ $targ = "amd" ]; then
git clone -b $ver https://github.com/RadeonOpenCompute/rocminfo.git
cd rocminfo
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=${install_prefix} -DROCM_DIR=${install_prefix} ..
make -j $nprocs
$sud make install
cd $cur
fi

# Install ROCm-Device-Libs

git clone  -b $ver  http://github.com/RadeonOpenCompute/ROCm-Device-Libs.git
cd ROCm-Device-Libs
export PATH=${install_prefix}/llvm/bin:$PATH
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=${install_prefix} ..
make -j $nprocs
$sud make install
cd $cur

# Install HSA Runtime API and runtime for ROCm

git clone  -b $ver  https://github.com/RadeonOpenCompute/ROCR-Runtime.git
cd ROCR-Runtime/src
mkdir build
cd build
cp $cur/ROCT-Thunk-Interface/build/hsakmt-config.cmake ${install_prefix}/share/rocm/cmake/
cp $cur/ROCT-Thunk-Interface/build/CMakeFiles/Export/lib64/cmake/hsakmt/hsakmtTargets* ${install_prefix}/share/rocm/cmake/
export hsakmt_DIR=${install_prefix}/share/rocm/cmake/
cmake -DCMAKE_INSTALL_PREFIX=${install_prefix} -DHSAKMT_INC_PATH=${install_prefix}/include -DHSAKMT_LIB_PATH=${install_prefix}/lib64 ..
make -j $nprocs
$sud make install
cd $cur

# Install ROCm-CompilerSupport

git clone  -b $ver  https://github.com/RadeonOpenCompute/ROCm-CompilerSupport
cd ROCm-CompilerSupport/lib/comgr
export PATH=${install_prefix}/llvm/bin:$PATH
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=${install_prefix}   ..
make -j $nprocs
$sud make install
cd $cur

# Install ROCclr - Radeon Open Compute Common Language Runtime

git clone -b $ver https://github.com/ROCm-Developer-Tools/ROCclr.git
git clone -b $ver https://github.com/RadeonOpenCompute/ROCm-OpenCL-Runtime.git

export ROCclr_DIR="$(readlink -f ROCclr)"
export OPENCL_DIR="$(readlink -f ROCm-OpenCL-Runtime)"

cd "$ROCclr_DIR"
mkdir -p build
cd build
export CMAKE_PREFIX_PATH=${install_prefix}/lib/cmake/:$CMAKE_PREFIX_PATH
cmake -DOPENCL_DIR="$OPENCL_DIR" -DCMAKE_INSTALL_PREFIX=${install_prefix}/rocclr ..
make -j $nprocs
$sud make install
cd $cur

# Instal HIP

git clone -b $ver https://github.com/ROCm-Developer-Tools/HIP.git
cd HIP
mkdir build
cd build

if [ $targ = "nvidia" ]; then
cmake -DCMAKE_BUILD_TYPE=Release -DHIP_COMPILER=clang -DHIP_PLATFORM=nvcc -DCMAKE_PREFIX_PATH=${install_prefix} -DCMAKE_INSTALL_PREFIX=${install_prefix}/hip ..

else

cmake -DCMAKE_BUILD_TYPE=Release -DHIP_COMPILER=clang -DHIP_PLATFORM=rocclr\
-DCMAKE_PREFIX_PATH=/opt/rocm -DCMAKE_INSTALL_PREFIX=${install_prefix} ..

fi

make -j $nprocs
$sud make install

export HIP_PLATFORM=nvcc
export CUDA_PATH=$CUDA_INSTALL_ROOT
export HIP_PATH=${install_prefix}/hip
export ROCM_PATH=${install_prefix}/

git clone -b $ver https://github.com/ROCm-Developer-Tools/HIPIFY.git
cd HIPIFY
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=${install_prefix}/hip/bin ..
make -j $nprocs 
$sud make install

