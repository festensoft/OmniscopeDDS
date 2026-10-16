# =============================================================================
# DdsCore — vendor-agnostic DDS abstractions (header-only)
#
# Interfaces and plain data types for dynamic topic discovery and raw-bytes
# pub/sub. Deliberately depends on nothing but the standard library.
# Concrete implementations live in vendor modules (e.g. CycloneDDS).
# =============================================================================

add_library(DdsCore INTERFACE)
add_library(OmniscopeDDS::DdsCore ALIAS DdsCore)

target_include_directories(DdsCore INTERFACE
   $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
   $<INSTALL_INTERFACE:include>
)
