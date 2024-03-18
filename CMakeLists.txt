cmake_minimum_required(VERSION 3.28.0)
project(Graphviz)
set(PREFIX "/usr/local")

#set(CMAKE_OSX_ARCHITECTURES "arm64" "x86_64")
set(CMAKE_OSX_ARCHITECTURES "arm64")
set(CMAKE_INSTALL_RPATH "${PREFIX}/lib")
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

find_program(XCODEBUILD NAMES xcodebuild)

file(GLOB_RECURSE sources "*.m")
file(GLOB_RECURSE headers "*.h")
file(GLOB_RECURSE ibfiles "*.xib")

install(DIRECTORY /tmp/graphviz.dst/Applications/Graphviz.app
  DESTINATION /Applications/
  USE_SOURCE_PERMISSIONS
)

add_custom_target(app ALL
  COMMENT "Built macOS Graphviz app"
  DEPENDS /tmp/graphviz.dst/Applications/Graphviz.app
)

add_custom_command(OUTPUT app
  COMMENT "Build macOS Graphviz app" 
  OUTPUT /tmp/graphviz.dst/Applications/Graphviz.app
  DEPENDS
    ${headers}
    ${sources}
    ${ibfiles}
    ${PREFIX}/bin/dot
    ${CMAKE_CURRENT_SOURCE_DIR}/Info.plist
  COMMAND ${XCODEBUILD}
    -project ${CMAKE_CURRENT_SOURCE_DIR}/graphviz.xcodeproj
    -target Graphviz
    -configuration Release
    install
    ARCHS="${CMAKE_OSX_ARCHITECTURES}"
    USER_HEADER_SEARCH_PATHS="${PREFIX}/include/graphviz"
    LIBRARY_SEARCH_PATHS="${CMAKE_INSTALL_RPATH}"
    LD_RUNPATH_SEARCH_PATHS=${CMAKE_INSTALL_RPATH}
)
