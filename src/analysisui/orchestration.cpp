#include <sstream>
#include <iostream>
#include <iomanip>
#include <fstream>
#include <string>
#include <memory>
#include <chrono>

#include <QDebug>

#include <QtCharts/QXYSeries>
#include <QtCharts/QAreaSeries>
#include <QtQuick/QQuickView>
#include <QtQuick/QQuickItem>
#include <QtCore/QRandomGenerator>
#include <QtCore/QtMath>

#include "types.h"
#include "orchestration.h"

namespace ga = ::gos::analysis;

QT_CHARTS_USE_NAMESPACE

Q_DECLARE_METATYPE(QAbstractSeries*)
Q_DECLARE_METATYPE(QAbstractAxis*)

namespace gos {
namespace analysis {
namespace ui {

std::unique_ptr<std::ofstream> _file;

typedef std::chrono::steady_clock Clock;
typedef Clock::duration Duration;
typedef Clock::time_point Time;

Time _start;

status _status = status::undefined;

namespace real {
QString format(const float& real, const int& precision) {
  std::stringstream stream;
  stream << std::setprecision(precision) << real;
  return QString::fromStdString(stream.str());
}
float parse(const QString& string) {
  return static_cast<float>(string.toDouble());
}
}

Orchestration::Orchestration(QQuickView* appViewer, QObject* parent) :
  QObject(parent),
  appViewer_(appViewer),
  count_(0),
  isTunningWithT_(false),
  isConnected_(false),
  lastErrorNumber_(0),
  refreshInterval_(1000),
  refreshFrequency_(1.0),
  manual_(0),
  setpoint_(0.0),
  kp_(0.0),
  ki_(0.0),
  kd_(0.0),
  ti_(0.0),
  td_(0.0) {
  qRegisterMetaType<QAbstractSeries*>();
  qRegisterMetaType<QAbstractAxis*>();
}

Orchestration::~Orchestration() {
}

bool Orchestration::initialize(QQmlContext* context) {
  return true;
}

bool Orchestration::connectDisconnect() {
  status saved = _status;
  return true;
}

bool Orchestration::startStopLogging() {
  return false;
}

bool Orchestration::switchTuning() {
  bool saved = isTunningWithT_;
  return true;
}

bool Orchestration::isTunningWithT() { return isTunningWithT_; }
bool Orchestration::isConnected() { return isConnected_; }
bool Orchestration::isLogging() {
  if (_file) {
    return _file->is_open();
  } else {
    return false;
  }
}
QString Orchestration::statusString() { return statusString_; }
QString Orchestration::lastErrorString() { return lastErrorString_; }
errno_t Orchestration::lastErrorNumber() { return lastErrorNumber_; }
int Orchestration::refreshInterval() { return refreshInterval_; }
double Orchestration::refreshFrequency() { return refreshFrequency_; }
int Orchestration::manual() { return manual_; }
double Orchestration::setpoint() { return setpoint_; }
double Orchestration::kp() { return kp_; }
double Orchestration::ki() { return ki_; }
double Orchestration::kd() { return kd_; }
double Orchestration::ti() { return ti_; }
double Orchestration::td() { return td_; }

void Orchestration::setRefreshFrequency(const double& value) {
  if (refreshFrequency_ != value && value >= 0.1 && value <= 10) {
    refreshFrequency_ = value;
    setRefreshInterval(static_cast<int>(1000.0 / refreshFrequency_));
    emit refreshFrequencyChanged();
  }
}

void Orchestration::setManual(const int& manual) {
}

void Orchestration::setSetpoint(const double& setpoint) {
  if (setpoint_ != setpoint && setpoint >= 0.0 && setpoint <= 300.0) {
    if (_status == status::connected) {
    }
    setpoint_ = setpoint;
    emit setpointChanged();
  }
}

void Orchestration::setKp(const double& value) {
  if (kp_ != value && value >= 0.0 && value <= 100.0) {
    if (_status == status::connected) {
    } else {
      qDebug() << "Not connected when Kp changed from "
        << kp_ << " to " << value;
    }
    kp_ = value;
    emit kpChanged();
  }
}

void Orchestration::setKi(const double& value) {
  if (ki_ != value && value >= 0.0 && value <= 100.0) {
    if (_status == status::connected) {
    } else {
      qDebug() << "Not connected when Ki changed from "
        << ki_ << " to " << value;
    }
    ki_ = value;
    emit kpChanged();
  }
}

void Orchestration::setKd(const double& value) {
  if (kd_ != value && value >= 0.0 && value <= 100.0) {
    if (_status == status::connected) {
    } else {
      qDebug() << "Not connected when Kd changed from "
        << kd_ << " to " << value;
    }
    kd_ = value;
    emit kpChanged();
  }
}

void Orchestration::setTi(const double& value) {
  if (ti_ != value && value >= 0.0 && value <= 100.0) {
    if (_status == status::connected) {
    } else {
      qDebug() << "Not connected when Ti changed from "
        << ti_ << " to " << value;
    }
    ti_ = value;
    emit kpChanged();
  }
}

void Orchestration::setTd(const double& value) {
  if (td_ != value && value >= 0.0 && value <= 100.0) {
    if (_status == status::connected) {
    } else {
      qDebug() << "Not connected when Td changed from "
        << td_ << " to " << value;
    }
    td_ = value;
    emit kpChanged();
  }
}

int Orchestration::update(
  QAbstractSeries* output,
  QAbstractSeries* temperature,
  QAbstractSeries* setpoints) {
  if (_status == status::connected) {
    uint16_t output;
    float temperature;
  }
  if (count_ > 2) {
    if (output) {
      QXYSeries* xySeries = static_cast<QXYSeries*>(output);
      xySeries->replace(outputs_);
    }
    if (temperature) {
      QXYSeries* xySeries = static_cast<QXYSeries*>(temperature);
      xySeries->replace(temperature_);
    }
    if (setpoints) {
      QXYSeries* xySeries = static_cast<QXYSeries*>(setpoints);
      xySeries->replace(setpoints_);
    }
  }
  return count_;
}

void Orchestration::setIsConnected(const bool& value) {
  if (isConnected_ != value) {
    isConnected_ = value;
    emit isConnectedChanged();
  }
}

void Orchestration::setStatusString(const QString& value) {
  if (statusString_ != value) {
    statusString_ = value;
    emit statusStringChanged();
  }
}

void Orchestration::setLastErrorString(const QString& value) {
  if (lastErrorString_ != value) {
    lastErrorString_ = value;
    emit lastErrorStringChanged();
  }
}

void Orchestration::setLastErrorNumber(const errno_t& value) {
  if (lastErrorNumber_ != value) {
    lastErrorNumber_ = value;
    emit lastErrorNumberChanged();
  }
}

void Orchestration::setRefreshInterval(const int& value) {
  if (refreshInterval_ != value) {
    refreshInterval_ = value;
    emit refreshIntervalChanged();
  }
}

} // namespace ui
} // namespace analysis
} // namespace gos


