# =============================================================================
# OmniscopeDDS - Root CMakeLists.txt (thin aggregator)
# =============================================================================
cmake_minimum_required(VERSION 4.1)

project(OmniscopeDDS
   VERSION 1.0.0
   DESCRIPTION "DDS traffic inspector (Omniscope) built on Cyclone DDS"
   LANGUAGES CXX
)

# =============================================================================
# Global Settings
# =============================================================================

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

if(CMAKE_EXPORT_COMPILE_COMMANDS)
   file(CREATE_LINK "${CMAKE_BINARY_DIR}/compile_commands.json"
      "${CMAKE_SOURCE_DIR}/compile_commands.json" SYMBOLIC)
endif()

if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
   set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "Build type" FORCE)
   set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS
      "Debug" "Release" "MinSizeRel" "RelWithDebInfo")
endif()

# =============================================================================
# Options
# =============================================================================

option(BUILD_TESTS "Build unit tests" OFF)
option(BUILD_EXAMPLES "Build example applications" ON)
option(ENABLE_COVERAGE "Enable code coverage reporting" OFF)
option(ENABLE_SANITIZERS "Enable ASan and UBSan" OFF)
option(ENABLE_CLANG_TIDY "Enable clang-tidy static analysis" OFF)

# =============================================================================
# Compiler Warnings
# =============================================================================

set(GCC_WARNINGS
   -Wall
   -Wextra
   -Wshadow
   -Wnon-virtual-dtor
   -Wold-style-cast
   -Wcast-align
   -Wunused
   -Woverloaded-virtual
   -Wconversion
   -Wsign-conversion
   -Wnull-dereference
   -Wdouble-promotion
   -Wformat=2
   -Wimplicit-fallthrough
)

set(MSVC_WARNINGS
   /W4
   /permissive-
   /w14640
   /w14242
   /w14254
   /w14263
   /w14265
   /w14287
)

if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
   add_compile_options(${GCC_WARNINGS})
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
   add_compile_options(${MSVC_WARNINGS})
endif()

# =============================================================================
# Sanitizers / Coverage / Clang-Tidy
# =============================================================================

if(ENABLE_SANITIZERS)
   if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
      message(STATUS "Enabling Address Sanitizer (ASan) and Undefined Behavior Sanitizer (UBSan)")
      add_compile_options(-fsanitize=address,undefined -fno-omit-frame-pointer)
      add_link_options(-fsanitize=address,undefined)
   else()
      message(WARNING "Sanitizers are not supported with this compiler")
   endif()
endif()

if(ENABLE_COVERAGE)
   if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
      message(STATUS "Enabling code coverage with gcov")
      add_compile_options(--coverage -fprofile-arcs -ftest-coverage)
      add_link_options(--coverage)
   elseif(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
      message(STATUS "Enabling code coverage with llvm-cov")
      add_compile_options(-fprofile-instr-generate -fcoverage-mapping)
      add_link_options(-fprofile-instr-generate -fcoverage-mapping)
   else()
      message(WARNING "Code coverage is not supported with this compiler")
   endif()
endif()

if(ENABLE_CLANG_TIDY)
   find_program(CLANG_TIDY_PROGRAM clang-tidy)
   if(CLANG_TIDY_PROGRAM)
      message(STATUS "Found clang-tidy: ${CLANG_TIDY_PROGRAM}")
      set(CMAKE_CXX_CLANG_TIDY
         "${CLANG_TIDY_PROGRAM}"
         "--header-filter=${CMAKE_SOURCE_DIR}/source/.*"
      )
   else()
      message(WARNING "clang-tidy requested but not found")
   endif()
endif()

# =============================================================================
# Dependencies
# =============================================================================

include(FetchContent)

set(COMMONUTILS_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(BUILD_TESTING OFF CACHE BOOL "" FORCE)
# HTTPS so configure works in containers without an SSH agent (dev image also
# rewrites git@ → https as a belt-and-suspenders for other deps).
FetchContent_Declare(CommonUtils
   GIT_REPOSITORY https://github.com/festensoft/CommonUtils.git
   GIT_TAG        v1.0.0
   GIT_SHALLOW    TRUE
   SYSTEM
   EXCLUDE_FROM_ALL
)
FetchContent_MakeAvailable(CommonUtils)
# CommonUtils toggles BUILD_TESTING; keep FetchContent's suite off — ours is
# gated by BUILD_TESTS below.
set(BUILD_TESTING OFF CACHE BOOL "" FORCE)

find_package(CycloneDDS REQUIRED)
find_package(CycloneDDS-CXX REQUIRED)
find_package(Crow REQUIRED)

# =============================================================================
# Output Directories
# =============================================================================

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

# =============================================================================
# Modules
# =============================================================================

add_subdirectory(source/DdsCore)
add_subdirectory(source/CycloneDDS)
add_subdirectory(source/Omniscope)

if(BUILD_EXAMPLES)
   add_subdirectory(examples)
endif()

# =============================================================================
# Tests
# =============================================================================

if(BUILD_TESTS)
   enable_testing()
   find_package(GTest REQUIRED)
   include(GoogleTest)
   add_subdirectory(source/CycloneDDS/tests)
   add_subdirectory(source/Omniscope/tests)
endif()

# =============================================================================
# Installation
# =============================================================================

include(GNUInstallDirs)

install(TARGETS Omniscope
   RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

if(BUILD_EXAMPLES)
   install(TARGETS RadarDDSWorkstation RadarDDSRadar
      RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
   )
endif()

# =============================================================================
# Summary
# =============================================================================

message(STATUS "")
message(STATUS "=== OmniscopeDDS Configuration ===")
message(STATUS "  Version:          ${PROJECT_VERSION}")
message(STATUS "  Build type:       ${CMAKE_BUILD_TYPE}")
message(STATUS "  C++ Standard:     ${CMAKE_CXX_STANDARD}")
message(STATUS "  Compiler:         ${CMAKE_CXX_COMPILER_ID} ${CMAKE_CXX_COMPILER_VERSION}")
message(STATUS "  Build tests:      ${BUILD_TESTS}")
message(STATUS "  Build examples:   ${BUILD_EXAMPLES}")
message(STATUS "  Coverage:         ${ENABLE_COVERAGE}")
message(STATUS "  Sanitizers:       ${ENABLE_SANITIZERS}")
message(STATUS "  Clang-tidy:       ${ENABLE_CLANG_TIDY}")
message(STATUS "==================================")
message(STATUS "")
