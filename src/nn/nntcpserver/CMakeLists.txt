set(nn_tcp_server_target nntcpserver)

list(APPEND nn_tcp_server_source
  ${nn_genann_src}
  nntcpserver.c)

list(APPEND nn_tcp_server_include
  ${nn_genann_dir})

if(MSVC)
  list(APPEND nn_tcp_server_libraries
    Ws2_32)
  list(APPEND nn_tcp_server_definitions
    WIN32_LEAN_AND_MEAN)
endif()

add_executable(${nn_tcp_server_target}
  ${nn_tcp_server_source})

target_include_directories(${nn_tcp_server_target} PUBLIC
  ${nn_tcp_server_include})

if(nn_tcp_server_libraries)
  target_link_libraries(${nn_tcp_server_target}
    ${nn_tcp_server_libraries})
endif()

if(nn_tcp_server_definitions)
  target_compile_definitions(${nn_tcp_server_target} PUBLIC
    ${nn_tcp_server_definitions})
endif()

if(DEPLOY_PDB_FILES)
  install(FILES "$<TARGET_PDB_FILE:${nn_tcp_server_target}>"
    DESTINATION pdb
    COMPONENT pdb)
endif()

install(TARGETS ${nn_tcp_server_target}
  RUNTIME DESTINATION bin)
