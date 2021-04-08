message(STATUS "")
message(STATUS "Analysis Fetch CDF BUILD SUMMARY")

set(gos_fetch_cdf_target fcdf)

find_package(CURL REQUIRED)

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

message(STATUS "  Curl Version         : ${CURL_VERSION_STRING}")

list(APPEND gos_fetch_cdf_source
  fetchcdf.c)

list(APPEND gos_fetch_cdf_include
  ${CURL_INCLUDE_DIRS}
  ${CDF_INCLUDE_DIR})

list(APPEND gos_fetch_cdf_libraries
  ${CURL_LIBRARIES}
  ${CDF_LIBRARY})

add_executable(${gos_fetch_cdf_target}
  ${gos_fetch_cdf_source})

target_include_directories(${gos_fetch_cdf_target} PRIVATE
  ${gos_fetch_cdf_include})
target_link_libraries(${gos_fetch_cdf_target}
  ${gos_fetch_cdf_libraries})

install(TARGETS ${gos_fetch_cdf_target}
  RUNTIME DESTINATION bin)
