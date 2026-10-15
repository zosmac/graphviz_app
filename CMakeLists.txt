cmake_minimum_required(VERSION 3.28.0)
project(Graphviz LANGUAGES C OBJC)

if(EXISTS "/opt/homebrew/bin/dot")
  set(PREFIX "/opt/homebrew" CACHE PATH "Prefix for Graphviz")
elseif(EXISTS "/usr/local/bin/dot")
  set(PREFIX "/usr/local" CACHE PATH "Prefix for Graphviz")
else()
  set(PREFIX "/usr/local/graphviz" CACHE PATH "Prefix for Graphviz")
endif()

set(CMAKE_OSX_DEPLOYMENT_TARGET "11.0" CACHE STRING "Minimum OS X deployment version")
if(NOT CMAKE_OSX_ARCHITECTURES)
  set(CMAKE_OSX_ARCHITECTURES "arm64" CACHE STRING "Build architectures")
endif()
set(CMAKE_INSTALL_RPATH "${PREFIX}/lib")
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

find_program(XCODEBUILD NAMES xcodebuild)

file(GLOB_RECURSE sources "*.m")
file(GLOB_RECURSE headers "*.h")
file(GLOB_RECURSE ibfiles "*.xib")

set(APP_BUNDLE "/tmp/graphviz.dst/Applications/Graphviz.app")

add_custom_command(
  OUTPUT ${APP_BUNDLE}
  COMMENT "Building macOS Graphviz.app"
  DEPENDS
    ${headers}
    ${sources}
    ${ibfiles}
    ${PREFIX}/bin/dot
    ${CMAKE_CURRENT_SOURCE_DIR}/Info.plist
  COMMAND ${CMAKE_COMMAND} -E env
    DEVELOPER_DIR=$<IF:$<BOOL:$ENV{DEVELOPER_DIR}>,$ENV{DEVELOPER_DIR},/Applications/Xcode-beta.app/Contents/Developer>
    ${XCODEBUILD}
    -project ${CMAKE_CURRENT_SOURCE_DIR}/graphviz.xcodeproj
    -target Graphviz
    -configuration Release
    install
    ARCHS="${CMAKE_OSX_ARCHITECTURES}"
    MACOSX_DEPLOYMENT_TARGET="${CMAKE_OSX_DEPLOYMENT_TARGET}"
    __DIAGNOSE_INVALID_DEPLOYMENT_TARGET_AS_ERROR=NO
    USER_HEADER_SEARCH_PATHS="${PREFIX}/include/graphviz"
    LIBRARY_SEARCH_PATHS="${CMAKE_INSTALL_RPATH}"
    LD_RUNPATH_SEARCH_PATHS="${CMAKE_INSTALL_RPATH}"
    DSTROOT=/tmp/graphviz.dst
)

add_custom_target(app ALL
  DEPENDS ${APP_BUNDLE}
)

install(DIRECTORY ${APP_BUNDLE}
  DESTINATION /Applications/
  USE_SOURCE_PERMISSIONS
)
