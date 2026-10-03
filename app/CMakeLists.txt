cmake_minimum_required(VERSION 3.24)

qt_standard_project_setup()

set(APP_EXTRA_SOURCES)
if(WIN32)
    configure_file(app_version.rc.in ${CMAKE_CURRENT_BINARY_DIR}/app_version.rc @ONLY)
    list(APPEND APP_EXTRA_SOURCES app.rc)
    list(APPEND APP_EXTRA_SOURCES ${CMAKE_CURRENT_BINARY_DIR}/app_version.rc)
endif()

# ── Application ───────────────────────────────────────────────────────────────
set_source_files_properties(../assets/banner.png PROPERTIES QT_RESOURCE_ALIAS "icons/banner.png")
set_source_files_properties(../assets/shadcy-for-white-bg.png PROPERTIES QT_RESOURCE_ALIAS "icons/shadcy-for-white-bg.png")
set_source_files_properties(../assets/shadcy-for-black-bg.png PROPERTIES QT_RESOURCE_ALIAS "icons/shadcy-for-black-bg.png")

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
    src/ChatController.cpp
    src/ChatController.h
    src/ChatPromptBudget.cpp
    src/ChatPromptBudget.h
    ${APP_EXTRA_SOURCES}
)


qt_add_qml_module(FilterDesigner
    URI FilterDesigner
    VERSION 1.0
    QML_FILES
        qml/Main.qml
        qml/InstallerApp.qml
        qml/theme/Theme.qml
        qml/components/Sidebar.qml
        qml/components/SidebarItem.qml
        qml/components/CustomToolTip.qml
        qml/components/Codicon.qml
        qml/components/PageHeader.qml
        qml/components/StandalonePlotWindow.qml
        qml/components/FrequencyPlot.qml
        qml/components/PoleZeroPlot.qml
        qml/components/ImpulseStepPlot.qml
        qml/components/WhatsNewWindow.qml
        qml/components/InstallerUpdaterWindow.qml
        qml/components/WindowingStudio.qml

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
        qml/pages/ChatPage.qml
        qml/components/ChatPlot.qml
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
        math/axis_mag_db_dark.png
        math/axis_mag_db_light.png
        math/axis_mag_lin_dark.png
        math/axis_mag_lin_light.png
        math/axis_phase_dark.png
        math/axis_phase_light.png
        math/axis_group_delay_dark.png
        math/axis_group_delay_light.png
        math/axis_freq_hz_dark.png
        math/axis_freq_hz_light.png
        math/axis_freq_rad_dark.png
        math/axis_freq_rad_light.png
        math/axis_freq_norm_dark.png
        math/axis_freq_norm_light.png
        math/axis_re_z_dark.png
        math/axis_re_z_light.png
        math/axis_im_z_dark.png
        math/axis_im_z_light.png
        math/axis_unit_circle_dark.png
        math/axis_unit_circle_light.png
        math/axis_hn_dark.png
        math/axis_hn_light.png
        math/axis_sn_dark.png
        math/axis_sn_light.png
        math/axis_sample_n_dark.png
        math/axis_sample_n_light.png
        math/axis_signals_dark.png
        math/axis_signals_light.png
        math/win_rectangular_dark.png
        math/win_rectangular_light.png
        math/win_bartlett_dark.png
        math/win_bartlett_light.png
        math/win_hann_dark.png
        math/win_hann_light.png
        math/win_hamming_dark.png
        math/win_hamming_light.png
        math/win_blackman_dark.png
        math/win_blackman_light.png
        math/win_blackman_harris_dark.png
        math/win_blackman_harris_light.png
        math/win_nuttall_dark.png
        math/win_nuttall_light.png
        math/win_flat_top_dark.png
        math/win_flat_top_light.png
        math/win_kaiser_dark.png
        math/win_kaiser_light.png
        math/win_tukey_dark.png
        math/win_tukey_light.png
        math/win_gaussian_dark.png
        math/win_gaussian_light.png
        math/win_bohman_dark.png
        math/win_bohman_light.png
        math/win_lanczos_dark.png
        math/win_lanczos_light.png
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
        ../assets/shadcy-for-white-bg.png
        ../assets/shadcy-for-black-bg.png
        ../assets/banner.png
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

if(WIN32)
    target_link_libraries(FilterDesigner PRIVATE crypt32)
endif()

target_include_directories(FilterDesigner PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
)

target_compile_definitions(FilterDesigner PRIVATE OVERTUNE_VERSION="${PROJECT_VERSION}")

if(BUILD_TESTING)
    add_executable(chat_prompt_tests
        src/ChatPromptBudget.cpp
        tests/ChatPromptBudgetTests.cpp
    )
    target_include_directories(chat_prompt_tests PRIVATE src)
    target_link_libraries(chat_prompt_tests PRIVATE Qt6::Core)
    add_test(NAME chat_prompt_budget COMMAND chat_prompt_tests)
endif()

set_target_properties(FilterDesigner PROPERTIES OUTPUT_NAME "ot3")

install(TARGETS FilterDesigner RUNTIME DESTINATION bin)

if(WIN32)
    set_target_properties(FilterDesigner PROPERTIES WIN32_EXECUTABLE TRUE)

    # Standalone native installer launcher
    add_executable(ot3_installer
        src/launcher_main.cpp
        app.rc
    )
    set_target_properties(ot3_installer PROPERTIES
        WIN32_EXECUTABLE TRUE
        OUTPUT_NAME "ot3-installer"
    )
    target_link_libraries(ot3_installer PRIVATE shlwapi shell32)

    # Post-build copy FilterDesigner.exe and ot3-installer.exe in target dir
    add_custom_command(TARGET FilterDesigner POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different $<TARGET_FILE:FilterDesigner> $<TARGET_FILE_DIR:FilterDesigner>/FilterDesigner.exe
        COMMENT "Creating FilterDesigner.exe compatibility binary"
    )
elseif(APPLE)
    set_target_properties(FilterDesigner PROPERTIES MACOSX_BUNDLE TRUE)
else()
    # Create FilterDesigner symlink to ot3 for seamless compatibility
    add_custom_command(TARGET FilterDesigner POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E create_symlink ot3 $<TARGET_FILE_DIR:FilterDesigner>/FilterDesigner
        COMMENT "Creating FilterDesigner compatibility symlink to ot3"
    )
endif()

