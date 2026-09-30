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
    src/UpdateInstallerEngine.cpp
    src/UpdateInstallerEngine.h
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
        qml/components/PageHeader.qml
        qml/components/StandalonePlotWindow.qml
        qml/components/FrequencyPlot.qml
        qml/components/PoleZeroPlot.qml
        qml/components/ImpulseStepPlot.qml
        qml/components/WhatsNewWindow.qml
        qml/components/InstallerUpdaterWindow.qml

        qml/components/FilterCard.qml
        qml/components/ParameterRow.qml
        qml/components/StyledCombo.qml
        qml/components/StyledSlider.qml
        qml/components/StyledButton.qml
        qml/components/SegmentedButton.qml
        qml/components/SectionHeader.qml
        qml/components/CodeViewer.qml
        qml/components/SignalPlot.qml
        qml/components/LaTeXBlock.qml
        qml/components/LatexDocViewer.qml
        qml/components/TutorialStudio.qml
        qml/components/TutorialEngine.qml
        qml/components/SpotlightOverlay.qml
        qml/components/ChallengeStudio.qml
        qml/components/ModeHeaderBar.qml
        qml/components/WindowMenuBar.qml
        qml/components/DesignVerifierModal.qml
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
        latex/theory_and_math.pdf
        latex/theory_and_math_page-1.png
        latex/theory_and_math_page-2.png
        latex/theory_and_math_page-3.png
        latex/tutorials_and_guides.pdf
        latex/tutorials_and_guides_page-1.png
        latex/tutorials_and_guides_page-2.png
        latex/tutorials_and_guides_page-3.png
        latex/contributors_and_wiki.pdf
        latex/contributors_and_wiki_page-1.png
        latex/contributors_and_wiki_page-2.png
        icons/16-9ar-logo.png
        icons/16-9ar-compliance.png
        icons/logo.png
)

target_link_libraries(FilterDesigner PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Multimedia
    Qt6::Network
    dsp
)

target_include_directories(FilterDesigner PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
)

set_target_properties(FilterDesigner PROPERTIES OUTPUT_NAME "ot3")

install(TARGETS FilterDesigner RUNTIME DESTINATION bin)

if(WIN32)
    set_target_properties(FilterDesigner PROPERTIES WIN32_EXECUTABLE TRUE)
elseif(APPLE)
    set_target_properties(FilterDesigner PROPERTIES MACOSX_BUNDLE TRUE)
else()
    # Create FilterDesigner symlink to ot3 for seamless compatibility
    add_custom_command(TARGET FilterDesigner POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E create_symlink ot3 $<TARGET_FILE_DIR:FilterDesigner>/FilterDesigner
        COMMENT "Creating FilterDesigner compatibility symlink to ot3"
    )
endif()

