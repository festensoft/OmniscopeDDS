# =============================================================================
# CycloneDDSLib — Eclipse Cyclone DDS helpers
#
# Public API (include/CycloneDDS/):
#   DDSPublisher / DDSSubscriber / DDSTopicConfig  — typed app helpers
#   CycloneDdsParticipant / CycloneDiscoveryService /
#   CycloneRawTopicPublisher / CycloneRawTopicSubscriber — Omniscope stack
#
# Private (src/): BlobSertype, BuiltinTopicReader, and .cpp implementations.
# No IDL ships in this module.
# =============================================================================

find_package(CycloneDDS REQUIRED)
find_package(CycloneDDS-CXX REQUIRED)

if(TARGET CycloneDDS::idlc)
   get_target_property(_idlc_loc CycloneDDS::idlc IMPORTED_LOCATION)
   if(_idlc_loc)
      set_target_properties(CycloneDDS::idlc PROPERTIES
         IMPORTED_LOCATION_DEBUG "${_idlc_loc}"
         IMPORTED_LOCATION_RELEASE "${_idlc_loc}"
      )
   endif()
endif()

add_library(CycloneDDSLib STATIC
   src/DDSTopicConfig.cpp
   src/CycloneDdsParticipant.cpp
   src/CycloneDiscoveryService.cpp
   src/CycloneRawTopicPublisher.cpp
   src/CycloneRawTopicSubscriber.cpp
   src/BlobSertype.cpp
   src/BuiltinTopicReader.cpp
)

add_library(OmniscopeDDS::CycloneDDS ALIAS CycloneDDSLib)

target_include_directories(CycloneDDSLib
   PUBLIC
      $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
      $<INSTALL_INTERFACE:include>
   PRIVATE
      ${CMAKE_CURRENT_SOURCE_DIR}/src
)

target_link_libraries(CycloneDDSLib
   PUBLIC
      CycloneDDS-CXX::ddscxx
      CommonUtils
      DdsCore
)
