# TODO: revise library order, it's very messy
SET(QT_LIBS "")
LIST(APPEND QT_LIBS "-limm32 -ldwmapi -lwinmm -lversion -lwtsapi32 -lmincore -luserenv -lnetui1 -lnetapi32 -ldxgi -ld3d11")
LIST(APPEND QT_LIBS "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libQt5Network.a")
LIST(APPEND QT_LIBS "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libQt5Gui.a")
LIST(APPEND QT_LIBS "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libQt5Qml.a")
LIST(APPEND QT_LIBS "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libQt5QmlWorkerScript.a")
LIST(APPEND QT_LIBS "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/plugins/platforms/libqdirect2d.a")
LIST(APPEND QT_LIBS "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/qml/QtQuick.2/libqtquick2plugin.a")
LIST(APPEND QT_LIBS "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/qml/QtQuick/Window.2/libwindowplugin.a")
LIST(APPEND QT_LIBS "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libQt5QmlModels.a")
LIST(APPEND QT_LIBS "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libQt5Quick.a")
LIST(APPEND QT_LIBS "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libqtlibpng.a")
LIST(APPEND QT_LIBS "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libqtharfbuzz.a")
LIST(APPEND QT_LIBS "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libz.a")
LIST(APPEND QT_LIBS "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libQt5Widgets.a")
LIST(APPEND QT_LIBS "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libQt5WindowsUIAutomationSupport.a")
LIST(APPEND QT_LIBS "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/plugins/platforms/libqwindows.a")
LIST(APPEND QT_LIBS "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libqtpcre2.a")
LIST(APPEND QT_LIBS "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libQt5Core.a")
LIST(APPEND QT_LIBS "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libQt5EdidSupport.a")
LIST(APPEND QT_LIBS "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libQt5EventDispatcherSupport.a")
LIST(APPEND QT_LIBS "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libQt5ThemeSupport.a")
LIST(APPEND QT_LIBS "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libQt5FontDatabaseSupport.a")
LIST(APPEND QT_LIBS "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/plugins/platforms/libqdirect2d.a")
LIST(APPEND QT_LIBS "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/plugins/platforms/libqminimal.a")
# I don't know why this works the way it does, it just *does*, let's roll with it
LIST(APPEND QT_LIBS "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libQt5Network.a")
LIST(APPEND QT_LIBS "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libQt5Gui.a")
LIST(APPEND QT_LIBS "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/qml/QtQuick/Controls.2/libqtquickcontrols2plugin.a")
LIST(APPEND QT_LIBS "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libQt5QuickControls2.a")
LIST(APPEND QT_LIBS "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/qml/QtQuick/Templates.2/libqtquicktemplates2plugin.a")
LIST(APPEND QT_LIBS "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libQt5QuickTemplates2.a")
LIST(APPEND QT_LIBS "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/qml/Qt/labs/platform/libqtlabsplatformplugin.a")
LIST(APPEND QT_LIBS "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libQt5Widgets.a")
LIST(APPEND QT_LIBS "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/qml/QtCharts/libqtchartsqml2.a")
LIST(APPEND QT_LIBS "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libQt5Charts.a")
LIST(APPEND QT_LIBS "-static -luxtheme")

SET(BOOST_LIBS "")
LIST(APPEND BOOST_LIBS "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libboost_filesystem-mt-s-x64.a")
LIST(APPEND BOOST_LIBS "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libboost_program_options-mt-s-x64.a")
LIST(APPEND BOOST_LIBS "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libboost_system-mt-s-x64.a")
LIST(APPEND BOOST_LIBS "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libboost_thread-mt-s-x64.a")
LIST(APPEND BOOST_LIBS "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libboost_chrono-mt-s-x64.a")



