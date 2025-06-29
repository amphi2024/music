cmake_minimum_required(VERSION 3.13)
project(runner LANGUAGES CXX)

# Define the application target. To change its name, change BINARY_NAME in the
# top-level CMakeLists.txt, not the value here, or `flutter run` will no longer
# work.
#
# Any new source files that you add to the application should be added here.

if(CMAKE_SYSTEM_PROCESSOR MATCHES "x86_64")
    set(BASS_ARCH "x86_64")
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "i686" OR CMAKE_SYSTEM_PROCESSOR MATCHES "i386")
    set(BASS_ARCH "x86")
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "aarch64")
    set(BASS_ARCH "aarch64")
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "armv7" OR CMAKE_SYSTEM_PROCESSOR MATCHES "armhf")
    set(BASS_ARCH "armhf")
else()
    message(FATAL_ERROR "Unsupported architecture: ${CMAKE_SYSTEM_PROCESSOR}")
endif()

set(BASS_LIB_PATH "${CMAKE_SOURCE_DIR}/libs/${BASS_ARCH}/libbass.so")

add_library(bass SHARED IMPORTED GLOBAL)
set_target_properties(bass PROPERTIES
    IMPORTED_LOCATION "${BASS_LIB_PATH}"
)

find_package(PkgConfig REQUIRED)
pkg_check_modules(TAGLIB REQUIRED IMPORTED_TARGET taglib)

add_executable(${BINARY_NAME}
  "main.cc"
  "my_application.cc"
  "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
  "metadata_retriever.cc"
  "audio_player.cc"
)

# Apply the standard set of build settings. This can be removed for applications
# that need different build settings.
apply_standard_settings(${BINARY_NAME})

# Add preprocessor definitions for the application ID.
add_definitions(-DAPPLICATION_ID="${APPLICATION_ID}")

# Add dependency libraries. Add any application-specific dependencies here.
target_link_libraries(${BINARY_NAME} PRIVATE flutter PkgConfig::TAGLIB bass)
target_link_libraries(${BINARY_NAME} PRIVATE PkgConfig::GTK)

target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_SOURCE_DIR}"  ${BASS_INCLUDE_DIR})

add_custom_target(copy_bass_lib ALL
  COMMAND ${CMAKE_COMMAND} -E copy_if_different
          "${BASS_LIB_PATH}"
          $<TARGET_FILE_DIR:${BINARY_NAME}>
  COMMENT "Copying BASS library to output directory"
)

add_dependencies(${BINARY_NAME} copy_bass_lib)