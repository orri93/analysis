list(APPEND gos_analysis_ui_source
  orchestration.cpp
  configuration.cpp
  orchestration.h
  configuration.h
  resources.qrc
  main.cpp)

list(APPEND gos_analysis_ui_include
  ${CMAKE_CURRENT_SOURCE_DIR})

list(APPEND gos_analysis_ui_libraries
  ${gos_analysis_library_target}
  Qt5::QuickControls2
  Qt5::Charts
  Qt5::Quick  
  Qt5::Core
  Qt5::Qml)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC OFF)

find_package(Qt5 COMPONENTS REQUIRED
  QuickControls2
  Charts
  Quick
  Core
  Qml)

add_executable(${gos_analysis_ui_target}
  ${gos_analysis_ui_source})

target_include_directories(${gos_analysis_ui_target} PRIVATE
  ${gos_analysis_ui_include})

target_link_libraries(${gos_analysis_ui_target}
  ${gos_analysis_ui_libraries})

add_custom_command(TARGET ${gos_analysis_ui_target} POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy_if_different
    ${CMAKE_CURRENT_SOURCE_DIR}/configuration.ini
    $<TARGET_FILE_DIR:${gos_analysis_ui_target}>)

install(TARGETS ${gos_analysis_ui_target}
  LIBRARY DESTINATION bin/tools
  ARCHIVE DESTINATION bin/tools)
