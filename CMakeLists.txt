cmake_minimum_required(VERSION 3.19)
project(polybench-gpu-wasm)

if (NOT CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    message("${CMAKE_CXX_COMPILER_ID}")
    message(FATAL_ERROR "Only Using Clang as Compiler")
endif ()

enable_language(CUDA)
find_package(CUDAToolkit REQUIRED)
include_directories(${CUDAToolkit_INCLUDE_DIRS})

set(CMAKE_CUDA_HOST_LINK_LAUNCHER ${CMAKE_CXX_COMPILER})
set(CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS} -fno-rtti -O3 -flto -fno-exceptions-fPIE -fPIC -DPOLYBENCH_TIME -URUN_ON_CPU)
set(CMAKE_C_FLAGS ${CMAKE_C_FLAGS} -fno-rtti -O3 -flto -fno-exceptions -fPIE -fPIC -DPOLYBENCH_TIME -URUN_ON_CPU)
add_compile_options(-O3 -w -noeh -m64 -dopt=on -DPOLYBENCH_TIME)

#add_definitions(-DRUN_ON_CPU)

add_executable(2DConvolution CUDA/2DCONV/2DConvolution.cu)
add_executable(2mm CUDA/2MM/2mm.cu)
add_executable(3DConvolution CUDA/3DCONV/3DConvolution.cu)
add_executable(3mm CUDA/3MM/3mm.cu)
add_executable(adi CUDA/ADI/adi.cu)
add_executable(atax CUDA/ATAX/atax.cu)
add_executable(bicg CUDA/BICG/bicg.cu)
add_executable(covariance CUDA/COVAR/covariance.cu)
add_executable(correlation CUDA/CORR/correlation.cu)
add_executable(doitgen CUDA/DOITGEN/doitgen.cu)
add_executable(fdtd2d CUDA/FDTD-2D/fdtd2d.cu)
add_executable(gemm CUDA/GEMM/gemm.cu)
add_executable(gemver CUDA/GEMVER/gemver.cu)
add_executable(gesummv CUDA/GESUMMV/gesummv.cu)
add_executable(gramschmidt CUDA/GRAMSCHM/gramschmidt.cu)
add_executable(jacobi1D CUDA/JACOBI1D/jacobi1D.cu)
add_executable(jacobi2D CUDA/JACOBI2D/jacobi2D.cu)
add_executable(lu CUDA/LU/lu.cu)
add_executable(mvt CUDA/MVT/mvt.cu)
add_executable(syr2k CUDA/SYR2K/syr2k.cu)
add_executable(syrk CUDA/SYRK/syrk.cu)


if (NOT DEFINED CUDA_WASM_TOOLKIT_ROOT)
    set(CUDA_WASM_TOOLKIT_ROOT /opt/cuda-wasm-toolkit)
endif ()
if (NOT DEFINED WASI_SYS_ROOT)
    set(WASI_SYS_ROOT /opt/wasi-sdk/share/wasi-sysroot)
endif ()

set(PLUGIN_FILE_1 ${CUDA_WASM_TOOLKIT_ROOT}/plugins/libcuda-wasm-pass.so)
set(PLUGIN_FILE_2 ${CUDA_WASM_TOOLKIT_ROOT}/plugins/liblibc64-pass.so)
set(STUB_FILE_1 ${CUDA_WASM_TOOLKIT_ROOT}/lib/cuda-runtime-stub.bc)
set(STUB_FILE_2 ${CUDA_WASM_TOOLKIT_ROOT}/lib/libc64-stub.bc)
set(BIN2BC ${CUDA_WASM_TOOLKIT_ROOT}/bin/bin2bc)
set(CLANG_COMPILE_FLAGS ${CMAKE_C_FLAGS} -emit-llvm -Xclang -disable-llvm-passes -fno-exceptions -fPIE -fPIC)
set(WASM_COMPILE_FLAGS ${CMAKE_C_FLAGS} --sysroot=${WASI_SYS_ROOT} --target=wasm32-wasi -msimd128 -mbulk-memory)
set(WASI_LD_FLAGS -Wl,--gc-sections,--lto-O3,--allow-undefined)

function(compile_to_wasm target_name source_file)
    set(source_file "${CMAKE_CURRENT_LIST_DIR}/${source_file}")
    get_filename_component(file_name ${source_file} NAME_WE)
    add_custom_command(
            OUTPUT ${target_name}.wasm ${file_name}.bc ${file_name}.wasm.bc ${file_name}.fatbin ${file_name}.fatbin.bc
            COMMAND ${CUDAToolkit_NVCC_EXECUTABLE} ${source_file} -O3 -noeh -m64 -dopt=on -ccbin ${CMAKE_CXX_COMPILER} -allow-unsupported-compiler -Xcompiler '${CLANG_COMPILE_FLAGS}' -c -o ${file_name}.bc
            COMMAND ${CUDAToolkit_NVCC_EXECUTABLE} ${source_file} -O3 -noeh -m64 -dopt=on -ccbin ${CMAKE_CXX_COMPILER} -allow-unsupported-compiler -Xcompiler '${CLANG_COMPILE_FLAGS}' -fatbin -o ${file_name}.fatbin
            COMMAND ${BIN2BC} ${file_name}.fatbin -o ${file_name}.fatbin.bc
            COMMAND ${CMAKE_C_COMPILER} ${WASM_COMPILE_FLAGS} -fpass-plugin=${PLUGIN_FILE_1} -fpass-plugin=${PLUGIN_FILE_2} ${file_name}.bc -c -o ${file_name}.wasm.bc
            COMMAND ${CMAKE_CXX_COMPILER} ${WASM_COMPILE_FLAGS} ${WASI_LD_FLAGS} -x ir ${STUB_FILE_1} ${STUB_FILE_2} ${file_name}.wasm.bc ${file_name}.fatbin.bc -o ${target_name}.wasm
            DEPENDS ${source_file}
    )
    add_custom_target(${target_name}.wasm.target ALL DEPENDS ${target_name}.wasm)
endfunction()

compile_to_wasm(2DConvolution CUDA/2DCONV/2DConvolution.cu)
compile_to_wasm(2mm CUDA/2MM/2mm.cu)
compile_to_wasm(3DConvolution CUDA/3DCONV/3DConvolution.cu)
compile_to_wasm(3mm CUDA/3MM/3mm.cu)
compile_to_wasm(adi CUDA/ADI/adi.cu)
compile_to_wasm(atax CUDA/ATAX/atax.cu)
compile_to_wasm(bicg CUDA/BICG/bicg.cu)
compile_to_wasm(covariance CUDA/COVAR/covariance.cu)
compile_to_wasm(correlation CUDA/CORR/correlation.cu)
compile_to_wasm(doitgen CUDA/DOITGEN/doitgen.cu)
compile_to_wasm(fdtd2d CUDA/FDTD-2D/fdtd2d.cu)
compile_to_wasm(gemm CUDA/GEMM/gemm.cu)
compile_to_wasm(gemver CUDA/GEMVER/gemver.cu)
compile_to_wasm(gesummv CUDA/GESUMMV/gesummv.cu)
compile_to_wasm(gramschmidt CUDA/GRAMSCHM/gramschmidt.cu)
compile_to_wasm(jacobi1D CUDA/JACOBI1D/jacobi1D.cu)
compile_to_wasm(jacobi2D CUDA/JACOBI2D/jacobi2D.cu)
compile_to_wasm(lu CUDA/LU/lu.cu)
compile_to_wasm(mvt CUDA/MVT/mvt.cu)
compile_to_wasm(syr2k CUDA/SYR2K/syr2k.cu)
compile_to_wasm(syrk CUDA/SYRK/syrk.cu)
