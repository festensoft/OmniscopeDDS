# =============================================================================
# CycloneDDSLib unit tests
# =============================================================================

add_executable(CycloneDDSTests
   TestMain.cpp
   DDSTopicConfigUt.cpp
)

target_link_libraries(CycloneDDSTests
   PRIVATE
      CycloneDDSLib
      GTest::gtest
)

set_target_properties(CycloneDDSTests PROPERTIES
   RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
)

gtest_discover_tests(CycloneDDSTests
   WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
   DISCOVERY_MODE PRE_TEST
)
