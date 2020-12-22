cmake_minimum_required(VERSION 2.8)
project(:myproject)
include(cmake/depend_git.cmake)

#include proto
#include(proto/proto_template.cmake) 

#version
EXECUTE_PROCESS(COMMAND git describe --tags
        TIMEOUT 5
        OUTPUT_VARIABLE GIT_VERSION
        OUTPUT_STRIP_TRAILING_WHITESPACE
        )
MESSAGE(STATUS "BUILD FROM GIT TAG ${GIT_VERSION}")
add_definitions(-DBUILD_VERSION=\"${GIT_VERSION}\")

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DEXPORT")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O1")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++0x -g -Wl,-rpath=./lib:../lib")


file(GLOB_RECURSE SOURCE_FILES
        ${PROJECT_SOURCE_DIR}/src/*.cpp
)

include_directories(
        ${PROJECT_SOURCE_DIR}/include
        ${PROJECT_SOURCE_DIR}/proto
)

link_directories(
)

add_executable(${PROJECT_NAME} ${SOURCE_FILES} ${GRPC_SOURCE_FILES})

target_link_libraries(
        ${PROJECT_NAME}
        ${GRPC_LIBS}
)

if (BUILD_TEST)
        add_subdirectory(test)
endif()
