/****************************************************************************
**
** Copyright (C) 2016 The Qt Company Ltd.
** Contact: https://www.qt.io/licensing/
**
** This file is part of the Qt Charts module of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:GPL$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see https://www.qt.io/terms-conditions. For further
** information use the contact form at https://www.qt.io/contact-us.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 3 or (at your option) any later version
** approved by the KDE Free Qt Foundation. The licenses are as published by
** the Free Software Foundation and appearing in the file LICENSE.GPL3
** included in the packaging of this file. Please review the following
** information to ensure the GNU General Public License requirements will
** be met: https://www.gnu.org/licenses/gpl-3.0.html.
**
** $QT_END_LICENSE$
**
****************************************************************************/

#include <cstdlib>

#include <QtWidgets/QApplication>
#include <QtQml/QQmlContext>
#include <QtQuick/QQuickView>
#include <QtQml/QQmlEngine>
#include <QtCore/QDir>

#include "orchestration.h"

namespace ga = ::gos::analysis;

int main(int argc, char *argv[])
{
  // Qt Charts uses Qt Graphics View Framework for drawing,
  // therefore QApplication must be used.
  QApplication app(argc, argv);

  QQuickView viewer;

  // The following are needed to make examples run
  // without having to install the module in desktop environments.
#ifdef Q_OS_WIN
  QString extraImportPath(QStringLiteral("%1/../../../../%2"));
#else
  QString extraImportPath(QStringLiteral("%1/../../../%2"));
#endif
  viewer.engine()->addImportPath(
    extraImportPath.arg(
      QGuiApplication::applicationDirPath(),
      QString::fromLatin1("qml"))
  );

  viewer.setTitle(QStringLiteral("Analysis UI"));

  QObject::connect(
    viewer.engine(),
    &QQmlEngine::quit,
    &viewer,
    &QWindow::close);

  ga::ui::Orchestration orchestration(&viewer);

  viewer.rootContext()->setContextProperty("orchestration", &orchestration);
  if (!orchestration.initialize(viewer.rootContext())) {
    return EXIT_FAILURE;
  }

  viewer.setSource(QUrl("qrc:/qml/analysis/main.qml"));
  viewer.setResizeMode(QQuickView::SizeRootObjectToView);
  viewer.setColor(QColor("#404040"));
  viewer.show();

  return app.exec();
}
