cmake_minimum_required(VERSION 3.10)
project(template-test)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

file(GLOB_RECURSE SOURCES "./*.cpp" "./*.h")

add_executable(template-test ${SOURCES})

target_link_libraries(template-test PRIVATE template)
target_link_libraries(template-test PRIVATE tablog)

install(TARGETS template-test DESTINATION bin)
