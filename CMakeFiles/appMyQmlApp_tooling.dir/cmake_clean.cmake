file(REMOVE_RECURSE
  "MyQmlApp/AppWindow.qml"
  "MyQmlApp/DensityPage.qml"
  "MyQmlApp/SplashWindow.qml"
  "MyQmlApp/main.qml"
)

# Per-language clean rules from dependency scanning.
foreach(lang )
  include(CMakeFiles/appMyQmlApp_tooling.dir/cmake_clean_${lang}.cmake OPTIONAL)
endforeach()
