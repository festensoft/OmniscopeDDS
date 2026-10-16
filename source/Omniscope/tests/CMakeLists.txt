# =============================================================================
# Omniscope unit tests (codec / protocol — no Crow HTTP, no live DDS)
# =============================================================================

add_executable(OmniscopeTests
   TestMain.cpp
   RawSampleJsonCodecUt.cpp
)

target_link_libraries(OmniscopeTests
   PRIVATE
      OmniscopeCodec
      GTest::gtest
)

set_target_properties(OmniscopeTests PROPERTIES
   RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
)

gtest_discover_tests(OmniscopeTests
   WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
   DISCOVERY_MODE PRE_TEST
)
