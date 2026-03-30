cmake_minimum_required(VERSION 3.10)
project(cpp-demo-app)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# A
add_subdirectory(src/A)

# B
add_subdirectory(src/B)

