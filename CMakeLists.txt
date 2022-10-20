cmake_minimum_required(VERSION 3.19)

if (NOT DEFINED CUDAToolkit_ROOT)
    set(CUDAToolkit_ROOT /usr/local/cuda)
endif ()

message("CUDAToolkit path = ${CUDAToolkit_ROOT}")
include_directories(${CUDAToolkit_ROOT}/include)
set(CMAKE_CUDA_COMPILER ${CUDAToolkit_ROOT}/bin/nvcc)

#-----------------------------------------------------------------------------------------------------------------------
project(polybench-gpu-wasm CUDA)
set(CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS} -fno-rtti -O3 -flto -fno-exceptions -DPOLYBENCH_TIME -URUN_ON_CPU)
set(CMAKE_C_FLAGS ${CMAKE_C_FLAGS} -fno-rtti -O3 -flto -fno-exceptions -DPOLYBENCH_TIME -URUN_ON_CPU)
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


set(CLANG /opt/clang+llvm-15.0.1/bin/clang)
set(WASI_SDK_CLANG /opt/wasi-sdk/bin/clang)
set(CLANG_COMPILE_FLAGS ${CMAKE_C_FLAGS} -emit-llvm -fno-exceptions -fPIE -fPIC -flto)
set(WASI_SDK_LD_FLAGS ${CMAKE_C_FLAGS} -fno-exceptions -fPIE -fPIC -msimd128 -mbulk-memory -Wl,--allow-undefined)

set(CUDA_WASI_TOOLKIT_ROOT /opt/cuda-wasm-toolkit)
set(PLUGIN_FILE_1 ${CUDA_WASI_TOOLKIT_ROOT}/plugins/libcuda-wasm-pass.so)
set(PLUGIN_FILE_2 ${CUDA_WASI_TOOLKIT_ROOT}/plugins/liblibc64-pass.so)
set(STUB_FILE_1 ${CUDA_WASI_TOOLKIT_ROOT}/lib/cuda-runtime-stub.bc)
set(STUB_FILE_2 ${CUDA_WASI_TOOLKIT_ROOT}/lib/libc64-stub.bc)
set(BIN2BC ${CUDA_WASI_TOOLKIT_ROOT}/bin/bin2bc)

function(compile_to_wasm target_name source_file)
    set(source_file "${CMAKE_CURRENT_LIST_DIR}/${source_file}")
    get_filename_component(file_name ${source_file} NAME_WE)
    add_custom_command(
            OUTPUT ${target_name}.wasm ${file_name}.opt.bc ${file_name}.bc ${file_name}.fatbin ${file_name}.fatbin.bc
            COMMAND ${CMAKE_CUDA_COMPILER} ${source_file} -O3 -noeh -m64 -dopt=on -ccbin ${CLANG} -allow-unsupported-compiler -Xcompiler '${CLANG_COMPILE_FLAGS}' -c -o ${file_name}.bc
            COMMAND ${CMAKE_CUDA_COMPILER} ${source_file} -O3 -noeh -m64 -dopt=on -ccbin ${CLANG} -allow-unsupported-compiler -Xcompiler '${CLANG_COMPILE_FLAGS}' -fatbin -o ${file_name}.fatbin
            COMMAND opt --load-pass-plugin ${PLUGIN_FILE_1} --load-pass-plugin ${PLUGIN_FILE_2} --enable-new-pm --passes='default<O3>,cuda-wasm,libc64' ${file_name}.bc -o ${file_name}.opt.bc
            COMMAND ${BIN2BC} ${file_name}.fatbin -o ${file_name}.fatbin.bc
            COMMAND ${WASI_SDK_CLANG} ${WASI_SDK_LD_FLAGS} ${STUB_FILE_1} ${STUB_FILE_2} ${file_name}.opt.bc ${file_name}.fatbin.bc -o ${target_name}.wasm
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
