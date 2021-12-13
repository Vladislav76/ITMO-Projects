cmake_minimum_required(VERSION 3.21)
project(jpg_encoder)

set(CMAKE_CXX_STANDARD 14)

set(CMAKE_EXE_LINKER_FLAGS "-static")

add_executable(jpg_encoder jpegenc.cpp)
