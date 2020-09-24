#ifndef GOS_ANALYSIS_TC_H_
#define GOS_ANALYSIS_TC_H_

#include <vector>

namespace gos {
namespace analysis {
namespace tc {

struct Standard {
  Standard();
  Standard(const double& time, const double& control, const double& temperature);
  Standard(const Standard& standard);
  Standard& operator=(const Standard& standard);
  double Time;
  double Control;
  double Temperature;
};

typedef ::std::vector<Standard> StandardVector;

void parse(StandardVector& vector, const char* filepath);

void filter(
  StandardVector& destination,
  const StandardVector& source,
  const size_t& windowsize,
  const double& sdthreshold);

} // namespace tc
} // namespace analysis
} // namespace gos

#endif
