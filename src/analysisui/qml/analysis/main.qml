import QtQuick 2.0
import QtCharts 2.3

Item {
  id: main
  implicitHeight: 800
  implicitWidth: 1024

  property int statusHeight: 52

  AnalysisPanel {
    id: analysisParameterPanel
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.bottom: parent.bottom
  }

  AnalysisChart {
    id: analysisChart
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    anchors.right: parent.right
    anchors.left: analysisParameterPanel.right
    height: main.height
  }
}
