cmake_minimum_required(VERSION 3.16)

project(MyQmlApp VERSION 0.1 LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTORCC ON)

# find_package(Qt6 6.2 COMPONENTS Quick Location Positioning Sql REQUIRED)
find_package(Qt6 6.2 COMPONENTS Quick Positioning Sql Graphs REQUIRED)

qt_add_executable(appMyQmlApp
    application.qrc
    main.cpp
    markermodel.h markermodel.cpp
    databasecontroller.h databasecontroller.cpp
    databaseworker.h databaseworker.cpp
    processing.h processing.cpp
    processingcontroller.h processingcontroller.cpp
    processingworker.h processingworker.cpp
)

qt_add_qml_module(appMyQmlApp
    URI MyQmlApp
    VERSION 1.0
    QML_FILES main.qml
    QML_FILES SplashWindow.qml
    QML_FILES AppWindow.qml
    QML_FILES MapPage.qml
    QML_FILES DensityPage.qml
    QML_FILES NavigationButton.qml
    QML_FILES CurrentLocationMarker.qml
    QML_FILES MapControls.qml
)

set_target_properties(appMyQmlApp PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER my.example.com
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_compile_definitions(appMyQmlApp
    PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)
target_link_libraries(appMyQmlApp
    PRIVATE Qt6::Quick Qt6::Positioning Qt6::Sql Qt6::Graphs)
