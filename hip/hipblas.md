# Install HipBLAS

**hipBLAS with ROCm 4.0.0**

* Execute:

`git clone -b rocm-4.0.0 https://github.com/ROCmSoftwarePlatform/hipBLAS.git`

`cd hipBLAS `

* Add in CMakeLists.txt

`set(CMAKE_MODULE_PATH "/path_to_hip/hip/cmake/" ${CMAKE_MODULE_PATH})`

* Execute:

`mkdir build`

`cd build`

`module load cmake`

`ccmake ..`

* Select Configure twice (c) and then Generate (g)

* Execute:
`make`

* The libraries are available in the directory `library/src/`

