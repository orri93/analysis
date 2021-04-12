configure_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/analysis.h.in"
  "gos/analysis/tests/analysis.h"
  @ONLY)
set(gos_analysis_unit_test_include_dir
   "${CMAKE_CURRENT_BINARY_DIR}")

list(APPEND gos_analysis_test_source
  "window.cpp"
  "tc.cpp")

set(gos_analysis_test_target gosanalysistest)

add_executable(${gos_analysis_test_target}
  ${gos_analysis_test_source})

target_include_directories(${gos_analysis_test_target} PUBLIC
  ${gos_analysis_unit_test_include_dir}
  ${gos_analysis_include}
# ${Boost_INCLUDE_DIRS}
  )

#target_compile_definitions(${gos_analysis_test_target} PUBLIC
#  SOME_DEF)

target_link_libraries(${gos_analysis_test_target}
# Boost::serialization
  ${gos_analysis_library_target}
  ${gos_analysis_gtest_libraries})

#if(CLANG_TIDY_EXE)
#  set_target_properties(${gos_analysis_test_target} PROPERTIES
#    CXX_CLANG_TIDY "${CMAKE_CXX_CLANG_TIDY}")
#endif()

add_test(NAME gos_analysis_test COMMAND
  ${gos_analysis_test_target})
