cmake_minimum_required(VERSION 3.10)
project(B)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

file(GLOB_RECURSE SOURCES "./*.cpp" "./*.h")

add_executable(B ${SOURCES})

install(TARGETS B DESTINATION bin)
