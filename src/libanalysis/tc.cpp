#include <csv.h>

#include <gos/analysis/tc.h>
#include <gos/analysis/window.h>

namespace ga = ::gos::analysis;

namespace gos {
namespace analysis {
namespace tc {

Standard::Standard() :
  Time(0.0),
  Control(0.0),
  Temperature(0.0) {
}

Standard::Standard(
  const double& time,
  const double& control,
  const double& temperature) :
  Time(time),
  Control(control),
  Temperature(temperature) {
}

Standard::Standard(const Standard& standard) :
  Time(standard.Time),
  Control(standard.Control),
  Temperature(standard.Temperature) {
}

Standard& Standard::operator=(const Standard& standard) {
  if (this != &standard) {
    this->Time = standard.Time;
    this->Control = standard.Control;
    this->Temperature = standard.Temperature;
  }
  return *this;
}

void parse(StandardVector& vector, const char* filepath) {
  ::io::CSVReader<3> csvreader(filepath);
  csvreader.read_header(
    io::ignore_extra_column,
    "time",
    "control",
    "temperature");
  double time, control, temperature;
  while (csvreader.read_row(time, control, temperature)) {
    vector.push_back(Standard(time, control, temperature));
  }
}

void filter(
  StandardVector& destination,
  const StandardVector& source,
  const size_t& windowsize,
  const double& sdthreshold) {
  ga::window window(windowsize);
  for (auto v : source) {
    window.add(v.Temperature);
    if (window.sd() < sdthreshold) {
      destination.push_back(v);
    }
  }
}

} // namespace tc
} // namespace analysis
} // namespace gos
