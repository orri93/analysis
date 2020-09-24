list(APPEND gos_analysis_library_source
  "exception.cpp"
  "version.cpp"
  "window.cpp"
  "types.cpp"
  "tc.cpp")

add_library(${gos_analysis_library_target}
  ${gos_analysis_library_source})

list(APPEND gos_analysis_include
# ${Boost_INCLUDE_DIRS}
  ${fast_cpp_csv_parser_dir})

if(CLANG_TIDY_EXE)
  set_target_properties(${gos_analysis_library_target} PROPERTIES
    CXX_CLANG_TIDY "${CMAKE_CXX_CLANG_TIDY}")
endif()

target_include_directories(${gos_analysis_library_target} PUBLIC
  ${gos_analysis_include})

if (gos_analysis_public_header)
  set_target_properties(${gos_analysis_library_target}
    PROPERTIES PUBLIC_HEADER
    "${gos_analysis_public_header}")
endif ()

install(TARGETS ${gos_analysis_library_target}
  LIBRARY DESTINATION lib
  PUBLIC_HEADER DESTINATION include/gos/analysis
  ARCHIVE DESTINATION lib)
