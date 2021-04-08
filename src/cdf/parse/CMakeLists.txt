message(STATUS "")
message(STATUS "Analysis Parse CDF BUILD SUMMARY")

set(gos_parse_cdf_target pcdf)

if (CDF_INCLUDE_DIR)
  message(STATUS "  CDF Include          : ${CDF_INCLUDE_DIR}")
else ()
  message(FATAL_ERROR "  CDF Include not defined")
endif ()
if (CDF_LIBRARY)
  message(STATUS "  CDF Library          : ${CDF_LIBRARY}")
else ()
  message(FATAL_ERROR "  CDF Library not defined")
endif ()

list(APPEND gos_parse_cdf_source
  parsecdf.c)

list(APPEND gos_parse_cdf_include
  ${CDF_INCLUDE_DIR})

list(APPEND gos_parse_cdf_libraries
  ${CDF_LIBRARY})

add_executable(${gos_parse_cdf_target}
  ${gos_parse_cdf_source})

target_include_directories(${gos_parse_cdf_target} PRIVATE
  ${gos_parse_cdf_include})
target_link_libraries(${gos_parse_cdf_target}
  ${gos_parse_cdf_libraries})

install(TARGETS ${gos_parse_cdf_target}
  RUNTIME DESTINATION bin)
