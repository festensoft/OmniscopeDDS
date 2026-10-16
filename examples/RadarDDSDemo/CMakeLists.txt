# =============================================================================
# RadarDDSDemo
#
# Two-app demo (Workstation + Radar) exercising CycloneDDSLib with a distinct
# QoS profile per topic. Owns its IDL under idl/ — CycloneDDSLib ships none.
# =============================================================================

find_package(CycloneDDS REQUIRED)
find_package(CycloneDDS-CXX REQUIRED)

# Ensure CycloneDDS::idlc has an IMPORTED_LOCATION for non-Release configs.
if(TARGET CycloneDDS::idlc)
   get_target_property(_idlc_loc CycloneDDS::idlc IMPORTED_LOCATION)
   if(_idlc_loc)
      set_target_properties(CycloneDDS::idlc PROPERTIES
         IMPORTED_LOCATION_DEBUG "${_idlc_loc}"
         IMPORTED_LOCATION_RELEASE "${_idlc_loc}"
      )
   endif()
endif()

file(GLOB RADAR_IDL_FILES CONFIGURE_DEPENDS
   "${CMAKE_CURRENT_SOURCE_DIR}/idl/*.idl")

idlcxx_generate(TARGET RadarDDSMessages FILES ${RADAR_IDL_FILES})

get_target_property(_radar_dds_gen_dir RadarDDSMessages INTERFACE_INCLUDE_DIRECTORIES)
if(_radar_dds_gen_dir)
   file(WRITE "${_radar_dds_gen_dir}/.clang-tidy"
      "---\nChecks: '-*,misc-definitions-in-headers'\nHeaderFilterRegex: ''\n"
   )
endif()
set_target_properties(RadarDDSMessages PROPERTIES CXX_CLANG_TIDY "")

add_library(RadarTopics STATIC RadarTopics.cpp)

target_include_directories(RadarTopics PUBLIC
   ${CMAKE_CURRENT_SOURCE_DIR}
)

target_link_libraries(RadarTopics PUBLIC
   RadarDDSMessages
   CycloneDDSLib
   CommonUtils
)

add_executable(RadarDDSWorkstation Workstation.cpp)
target_link_libraries(RadarDDSWorkstation PRIVATE RadarTopics)

add_executable(RadarDDSRadar Radar.cpp)
target_link_libraries(RadarDDSRadar PRIVATE RadarTopics)

set_target_properties(
   RadarDDSWorkstation RadarDDSRadar
   PROPERTIES
      RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
)
