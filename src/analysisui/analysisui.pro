QT += charts qml quick

HEADERS += \
    types.h \
    configuration.h \
    orchestration.h

SOURCES += \
    main.cpp \
    configuration.cpp \
    orchestration.cpp

RESOURCES += \
    resources.qrc

DISTFILES += \
    qml/analysis/* \
    qml/analysis/AnalysisChart.qml \
    qml/analysis/AnalysisPanel.qml \
    qml/analysis/RealSpinBox.qml \
    qml/analysis/main.qml
