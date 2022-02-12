set(nn_wave_target nnwave)

list(APPEND nn_wave_source
  ${nn_genann_src}
  nnwave.c)

list(APPEND nn_wave_include
  ${nn_genann_dir})

if(MSVC)
#  list(APPEND nn_wave_libraries
#    Ws2_32)
  list(APPEND nn_wave_definitions
    _USE_MATH_DEFINES)
endif()

add_executable(${nn_wave_target}
  ${nn_wave_source})

target_include_directories(${nn_wave_target} PUBLIC
  ${nn_wave_include})

if(nn_wave_libraries)
  target_link_libraries(${nn_wave_target}
    ${nn_wave_libraries})
endif()

if(nn_wave_definitions)
  target_compile_definitions(${nn_wave_target} PUBLIC
    ${nn_wave_definitions})
endif()

if(DEPLOY_PDB_FILES)
  install(FILES "$<TARGET_PDB_FILE:${nn_wave_target}>"
    DESTINATION pdb
    COMPONENT pdb)
endif()

install(TARGETS ${nn_wave_target}
  RUNTIME DESTINATION bin)
