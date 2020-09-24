#ifndef GOS_ANALYSIS_TYPES_H_
#define GOS_ANALYSIS_TYPES_H_

#include <utility>

#include <vector>

namespace gos {
namespace analysis {
namespace type {

typedef ::std::pair<double, double> Range;
typedef ::std::vector<double> DoubleVector;
typedef DoubleVector::iterator DoubleIterator;
typedef DoubleVector::size_type DoubleSize;

Range make_range(const double& lowest, const double& highest);

} // namespace type
} // namespace analysis
} // namespace gos


#endif