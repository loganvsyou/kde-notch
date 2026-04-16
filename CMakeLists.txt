cmake_minimum_required(VERSION 3.20)
project(kde-notch)

set(CMAKE_CXX_STANDARD 17)

find_package(Qt6 REQUIRED COMPONENTS Gui Qml Quick)
find_package(LayerShellQt REQUIRED)

add_definitions(-DSOURCE_DIR="${CMAKE_CURRENT_SOURCE_DIR}")

add_executable(kde-notch main.cpp)
target_link_libraries(kde-notch
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    LayerShellQt::Interface
)
