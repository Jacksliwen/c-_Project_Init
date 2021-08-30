cmake_minimum_required(VERSION 2.8)
project(:myproject)
include(cmake/depend_git.cmake)

include proto
include(proto/proto_template.cmake) 

# Debug Release Rel WithDebInfo MinSizeRel
set(CMAKE_BUILD_TYPE "Debug")

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS} -DEXPORT -O3 -DNODEBUG -std=c++0x -fopenmp -pthread -Wl,-rpath=./lib:../lib")
set(CMAKE_CXX_FLAGS_DEBUG   "${CMAKE_CXX_FLAGS} -DEXPORT -O0 -g -ggdb -std=c++0x -fopenmp -pthread -Wl,-rpath=./lib:../lib")

if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    message(STATUS "Build Type: Debug Mode")
    message(STATUS "Flags:" ${CMAKE_CXX_FLAGS_DEBUG})
    add_definitions(-DDEBUG_) 
else()
    set(CMAKE_BUILD_TYPE "Release" CACHE STRING "build type" FORCE)
    message(STATUS "Build Type: Release Mode")
    message(STATUS "Flags:" ${CMAKE_CXX_FLAGS_RELEASE})
endif(CMAKE_BUILD_TYPE STREQUAL "Debug")

#service version get
EXECUTE_PROCESS(COMMAND git describe --tags
        TIMEOUT 5
        OUTPUT_VARIABLE GIT_VERSION
        OUTPUT_STRIP_TRAILING_WHITESPACE
        )
MESSAGE(STATUS "BUILD FROM GIT TAG ${GIT_VERSION}")
add_definitions(-DBUILD_VERSION=\"${GIT_VERSION}\")

#The graphics card type x86_64 OR aarch64
EXECUTE_PROCESS(COMMAND arch
        TIMEOUT 5
        OUTPUT_VARIABLE ARCH_TYPE
        OUTPUT_STRIP_TRAILING_WHITESPACE
        )
MESSAGE(STATUS "BUILD ARCH_TYPE ${ARCH_TYPE}")

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
