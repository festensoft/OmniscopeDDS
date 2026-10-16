# =============================================================================
# Omniscope — web-based DDS traffic inspector with dynamic topic discovery
# =============================================================================

include(${CMAKE_CURRENT_SOURCE_DIR}/EmbedAsset.cmake)

# Codec is a separate static lib so unit tests can link it without Crow/HTTP.
add_library(OmniscopeCodec STATIC
   src/RawSampleJsonCodec.cpp
)
target_include_directories(OmniscopeCodec
   PUBLIC
      ${CMAKE_CURRENT_SOURCE_DIR}/src
)
target_link_libraries(OmniscopeCodec
   PUBLIC
      DdsCore
   PRIVATE
      Crow::Crow
)

embed_web_asset(OmniscopeHtml web/monitor.html)
embed_web_asset(OmniscopeCss  web/style.css)
embed_web_asset(OmniscopeJs   web/app.js)

add_executable(Omniscope
   src/main.cpp
   src/OmniscopeApp.cpp
   src/PlaybackEngine.cpp
   src/TransportDds.cpp
)
add_dependencies(Omniscope OmniscopeHtml OmniscopeCss OmniscopeJs)

set_target_properties(Omniscope PROPERTIES CXX_CLANG_TIDY "")

if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
   target_compile_options(Omniscope PRIVATE
      $<$<CONFIG:Release>:-Wno-null-dereference>
   )
endif()

target_include_directories(Omniscope
   PRIVATE
      ${CMAKE_CURRENT_SOURCE_DIR}/include
      ${CMAKE_CURRENT_SOURCE_DIR}/src
      ${CMAKE_CURRENT_BINARY_DIR}
)

target_link_libraries(Omniscope
   PRIVATE
      Crow::Crow
      CommonUtils
      CycloneDDSLib
      DdsCore
      OmniscopeCodec
)

set_target_properties(Omniscope PROPERTIES
   RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
)
