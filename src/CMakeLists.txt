if (GOS_ANALYSIS)
  add_subdirectory(libanalysis)
  if (GOS_ANALYSIS_UI)
    add_subdirectory(analysisui)
  endif (GOS_ANALYSIS_UI)
endif (GOS_ANALYSIS)

if (GOS_ANALYSIS_CDF)
  add_subdirectory(cdf)
endif (GOS_ANALYSIS_CDF)

add_subdirectory(nn)
