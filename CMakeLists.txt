cmake_minimum_required(VERSION 3.12)

project(Analysis VERSION 1.0.0.0
  DESCRIPTION "Analysis"
  LANGUAGES C CXX)
  
set(CMAKE_PLATFORM_INDEPENDENT_CODE ON)

option(GOS_TEST "Build and execute the unit tests" OFF)

option(GOS_ANALYSIS "Build analysis C++ library" ON)
option(GOS_ANALYSIS_UI "Build analysis C++ UI" ON)
option(GOS_ANALYSIS_TEST "Build and execute the unit tests for the analysis library" OFF)

option(GOS_ANALYSIS_CDF "Build the analysis CDF projects" OFF)

option(BUILD_SHARED_LIBS "Build using shared libraries" OFF)

option(CLANG_TIDY "Perform Clang-Tidy check" OFF)

if (CLANG_TIDY)
  option(CLANG_TIDY_FIX_ERRORS
    "Perform fixes with Clang-Tidy even if compilation errors were found" OFF)
  option(CLANG_TIDY_FIX "Perform fixes with Clang-Tidy" OFF)
  set(TIDY_ARGUMENTS "-checks=*,-clang-analyzer-alpha.* "
    CACHE STRING "Arguments for Clang-Tidy check")
  set(TIDY_FIX_ARGUMENTS "-list-checks=*,-clang-analyzer-alpha.* "
    CACHE STRING "Arguments for Clang-Tidy fix")
  set(TIDY_FIX_ERRORS_ARGUMENTS "-checks=*,-clang-analyzer-alpha.* "
    CACHE STRING "Arguments for Clang-Tidy fix errors")
  find_program(CLANG_TIDY_EXE
    NAMES "clang-tidy"
    DOC "Path to clang-tidy executable")
  if(CLANG_TIDY_EXE)
    if(CLANG_TIDY_FIX_ERRORS)
      set(CMAKE_CXX_CLANG_TIDY
        "${CLANG_TIDY_EXE}" "${TIDY_FIX_ERRORS_ARGUMENTS}-fix-errors")
      message(STATUS "Using clang-tidy with fix")
      message(STATUS "  ${CLANG_TIDY_EXE} ${TIDY_FIX_ERRORS_ARGUMENTS}-fix-errors")
    elseif(CLANG_TIDY_FIX)
      set(CMAKE_CXX_CLANG_TIDY "${CLANG_TIDY_EXE}" "${TIDY_FIX_ARGUMENTS}-fix")
      message(STATUS "Using clang-tidy with fix")
      message(STATUS "  ${CLANG_TIDY_EXE} ${TIDY_FIX_ARGUMENTS}-fix")
    else()
      set(CMAKE_CXX_CLANG_TIDY
        "${CLANG_TIDY_EXE}" "${TIDY_ARGUMENTS}")
      message(STATUS "Using clang-tidy")
      message(STATUS "  ${CLANG_TIDY_EXE} ${TIDY_ARGUMENTS}")
    endif()
  endif()
endif (CLANG_TIDY)

set(nn_genann_dir "${CMAKE_CURRENT_SOURCE_DIR}/extern/genann")
set(nn_genann_src "${nn_genann_dir}/genann.c")

set(fast_cpp_csv_parser_dir
  "${CMAKE_CURRENT_SOURCE_DIR}/extern/fast-cpp-csv-parser")

set(gos_analysis_include_dir
  "${CMAKE_CURRENT_SOURCE_DIR}/include")
configure_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/include/gos/analysis/version.h.in"
  "include/gos/analysis/version.h"
  @ONLY)
set(gos_analysis_version_include_file
  "${CMAKE_CURRENT_BINARY_DIR}/include/gos/analysis/version.h")
set(gos_analysis_binary_include_dir
  "${CMAKE_CURRENT_BINARY_DIR}/include")
list(APPEND gos_analysis_public_header
  "${CMAKE_CURRENT_SOURCE_DIR}/include/gos/analysis/exception.h"
  "${gos_analysis_version_include_file}")
list(APPEND gos_analysis_include
  "${gos_analysis_binary_include_dir}"
  "${gos_analysis_include_dir}")
list(APPEND gos_analysis_ui_include
  "${gos_analysis_include}")
set(gos_analysis_library_target libanalysis)
set(gos_analysis_ui_target analysisui)
#set(gos_build_dependency_boost ON)

if (gos_build_dependency_boost)
  set(Boost_USE_MULTITHREADED        ON)
  set(Boost_USE_STATIC_RUNTIME      OFF)
  if (BUILD_SHARED_LIBS)
    set(Boost_USE_STATIC_LIBS       OFF)    
  else ()
    set(Boost_USE_STATIC_LIBS        ON)
  endif ()

  list(APPEND gos_analysis_boost_package
#   system
#   date_time
#   filesystem
    serialization)
 list(REMOVE_DUPLICATES gos_analysis_boost_package)

  if (gos_analysis_boost_package)
    find_package(Boost 1.71 COMPONENTS REQUIRED
      ${gos_analysis_boost_package})
  else ()
    find_package(Boost 1.71)
  endif ()

# if (GOS_ANALYSIS_CPP)
#   list(APPEND gos_pid_toolkit_cpp_include
#     ${Boost_INCLUDE_DIRS})
# endif (GOS_ANALYSIS_CPP)
endif ()

add_subdirectory(src)

if (GOS_TEST)
  if (MSVC)
    #if (GOS_FORCE_SHARED_CRT)
      set(gtest_force_shared_crt ON CACHE BOOL "Use Shared CRT")
    #endif ()
  endif (MSVC)
  if (GOS_INSTRUCT_GOOGLE_TEST_PATH)
    set(GOS_GOOGLE_TEST_PATH
      "${GOS_INSTRUCT_GOOGLE_TEST_PATH}")
  else ()
    set(GOS_GOOGLE_TEST_PATH
      "${CMAKE_CURRENT_SOURCE_DIR}/extern/googletest")
    add_subdirectory(extern/googletest)
  endif ()
  set(gos_unit_testing_dir
    "${CMAKE_CURRENT_SOURCE_DIR}/tests")
  set(gos_unit_testing_gmock_include_dir
    "${GOS_GOOGLE_TEST_PATH}/googlemock/include")
  set(gos_unit_testing_gtest_include_dir
    "${GOS_GOOGLE_TEST_PATH}/googletest/include")
  enable_testing()
  list(APPEND gos_gtest_libraries
    gtest
    gmock
    gmock_main)
  set(gos_unit_testing_var_tc_standard_dir
    "${CMAKE_CURRENT_SOURCE_DIR}/var/tc/standard/200410a.csv")
  add_subdirectory(tests)
endif (GOS_TEST)

message(STATUS "")
message(STATUS "Analysis BUILD SUMMARY")
message(STATUS "  CMAKE_SYSTEM_NAME    : ${CMAKE_SYSTEM_NAME}")
message(STATUS "  CMAKE_GENERATOR      : ${CMAKE_GENERATOR}")
message(STATUS "  CMAKE_MODULE_PATH    : ${CMAKE_MODULE_PATH}")
message(STATUS "  C Compiler ID        : ${CMAKE_C_COMPILER_ID}")
message(STATUS "  C++ Compiler ID      : ${CMAKE_CXX_COMPILER_ID}")
message(STATUS "  Build type           : ${CMAKE_BUILD_TYPE}")
if (gos_build_dependency_boost)
message(STATUS "  Boost version        : ${Boost_VERSION}")
message(STATUS "  Boost include dir    : ${Boost_INCLUDE_DIRS}")
endif ()
if (GOS_TEST)
message(STATUS "  Google Test dir      : ${GOS_ANALYSIS_GOOGLE_TEST_PATH}")
message(STATUS "  Force Shared CRT     : ${gtest_force_shared_crt}")
message(STATUS "  Build and execute unit tests")
endif (GOS_TEST)
message(STATUS "")
