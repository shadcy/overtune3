cmake_minimum_required(VERSION 3.24)

qt_standard_project_setup()

# ── Application ───────────────────────────────────────────────────────────────
qt_add_executable(FilterDesigner
    src/main.cpp
    src/FilterEngine.cpp
    src/FilterEngine.h
    src/SimulationModel.cpp
    src/SimulationModel.h
    src/ExportModel.cpp
    src/ExportModel.h
    src/ThemeManager.cpp
    src/ThemeManager.h
)

qt_add_qml_module(FilterDesigner
    URI FilterDesigner
    VERSION 1.0
    QML_FILES
        qml/Main.qml
        qml/theme/Theme.qml
        qml/components/Sidebar.qml
        qml/components/SidebarItem.qml
        qml/components/Codicon.qml
        qml/components/FrequencyPlot.qml
        qml/components/PoleZeroPlot.qml
        qml/components/ImpulseStepPlot.qml
        qml/components/FilterCard.qml
        qml/components/ParameterRow.qml
        qml/components/StyledCombo.qml
        qml/components/StyledSlider.qml
        qml/components/StyledButton.qml
        qml/components/SectionHeader.qml
        qml/components/CodeViewer.qml
        qml/components/SignalPlot.qml
        qml/components/LaTeXBlock.qml
        qml/pages/DesignPage.qml
        qml/pages/AnalysisPage.qml
        qml/pages/SimulationPage.qml
        qml/pages/ExportPage.qml
        qml/pages/DocsPage.qml
        qml/pages/SettingsPage.qml
    RESOURCES
        fonts/StackSansHeadline-Regular.ttf
        fonts/StackSansHeadline-Medium.ttf
        fonts/StackSansHeadline-SemiBold.ttf
        fonts/StackSansHeadline-Bold.ttf
        fonts/Inter-Regular.ttf
        fonts/Inter-Medium.ttf
        fonts/Inter-SemiBold.ttf
        fonts/Inter-Bold.ttf
        fonts/codicon.ttf
        fonts/NOTICE
        math/eq1_dark.png
        math/eq1_light.png
        math/eq2_dark.png
        math/eq2_light.png
        math/eq3_dark.png
        math/eq3_light.png
        math/eq4_dark.png
        math/eq4_light.png
        math/eq5_dark.png
        math/eq5_light.png
        math/eq6_dark.png
        math/eq6_light.png
        math/eq7_dark.png
        math/eq7_light.png
)

target_link_libraries(FilterDesigner PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Multimedia
    dsp
)

target_include_directories(FilterDesigner PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
)

if(WIN32)
    set_target_properties(FilterDesigner PROPERTIES WIN32_EXECUTABLE TRUE)
elseif(APPLE)
    set_target_properties(FilterDesigner PROPERTIES MACOSX_BUNDLE TRUE)
endif()
