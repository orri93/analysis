set(gos_analysis_concepts_test_target concepts)

add_executable(${gos_analysis_concepts_test_target}
  nearest.cpp)

target_include_directories(${gos_analysis_concepts_test_target} PRIVATE
  ${gos_unit_testing_gmock_include_dir})

target_link_libraries(${gos_analysis_concepts_test_target}
  ${gos_gtest_libraries})

add_test(NAME concepts_test COMMAND
  ${gos_analysis_concepts_test_target})
