file(REMOVE_RECURSE
  "FilterDesigner/fonts/Inter-Bold.ttf"
  "FilterDesigner/fonts/Inter-Medium.ttf"
  "FilterDesigner/fonts/Inter-Regular.ttf"
  "FilterDesigner/fonts/Inter-SemiBold.ttf"
  "FilterDesigner/fonts/NOTICE"
  "FilterDesigner/fonts/codicon.ttf"
  "FilterDesigner/qml/Main.qml"
  "FilterDesigner/qml/components/CodeViewer.qml"
  "FilterDesigner/qml/components/Codicon.qml"
  "FilterDesigner/qml/components/FilterCard.qml"
  "FilterDesigner/qml/components/FrequencyPlot.qml"
  "FilterDesigner/qml/components/ImpulseStepPlot.qml"
  "FilterDesigner/qml/components/ParameterRow.qml"
  "FilterDesigner/qml/components/PoleZeroPlot.qml"
  "FilterDesigner/qml/components/SectionHeader.qml"
  "FilterDesigner/qml/components/Sidebar.qml"
  "FilterDesigner/qml/components/SidebarItem.qml"
  "FilterDesigner/qml/components/SignalPlot.qml"
  "FilterDesigner/qml/components/StyledButton.qml"
  "FilterDesigner/qml/components/StyledCombo.qml"
  "FilterDesigner/qml/components/StyledSlider.qml"
  "FilterDesigner/qml/pages/AnalysisPage.qml"
  "FilterDesigner/qml/pages/DesignPage.qml"
  "FilterDesigner/qml/pages/DocsPage.qml"
  "FilterDesigner/qml/pages/ExportPage.qml"
  "FilterDesigner/qml/pages/SettingsPage.qml"
  "FilterDesigner/qml/pages/SimulationPage.qml"
  "FilterDesigner/qml/theme/Theme.qml"
)

# Per-language clean rules from dependency scanning.
foreach(lang )
  include(CMakeFiles/FilterDesigner_tooling.dir/cmake_clean_${lang}.cmake OPTIONAL)
endforeach()
