cmake_minimum_required(VERSION 3.20.0 FATAL_ERROR)

set(CPM_VERSION 0.37.0)
set(CPM_PATH "${CMAKE_BINARY_DIR}/cmake/CPM_${CPM_VERSION}.cmake")
if(NOT (EXISTS ${CPM_PATH}))
    message(STATUS "Downloading CPM.cmake to ${CPM_PATH}")
    set(CPM_GH_URL https://github.com/cpm-cmake/cpm.cmake/releases/download)
    set(CPM_RELEASE_URL ${CPM_GH_URL}/v${CPM_VERSION}/CPM.cmake)
    file(DOWNLOAD ${CPM_RELEASE_URL} ${CPM_PATH})
endif()

include(${CPM_PATH})

get_filename_component(APP_NAME ${CMAKE_CURRENT_SOURCE_DIR} NAME)
set(CONFIG_KERNEL_BIN_NAME "\"${APP_NAME}[${BOARD}]\"" CACHE INTERNAL "The kernel binary name")
set(CONFIG_BUILD_OUTPUT_HEX "y" CACHE INTERNAL "Build a binary in HEX format")
set(CONFIG_BUILD_OUTPUT_BIN "y" CACHE INTERNAL "Build a binary in BIN format")
find_package(Zephyr $ENV{ZEPHYR_VERSION} REQUIRED HINTS $ENV{ZEPHYR_BASE})
project(app)

file(GLOB fw_sources src/main.c)
target_sources(app PRIVATE ${fw_sources})
