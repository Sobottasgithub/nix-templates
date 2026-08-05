cmake_minimum_required(VERSION 3.10)
project(template)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

option(DEF_TEMPLATE "configure library" ON)
option(DEF_TEST "configure test" ON)

if(DEF_TEMPLATE)
    add_subdirectory(lib/template)
endif()

if(DEF_TEST)
    add_subdirectory(test)
endif()
