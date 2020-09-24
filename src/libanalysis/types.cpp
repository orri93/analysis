#include <gos/analysis/types.h>

namespace gos {
namespace analysis {
namespace type {

Range make_range(const double& lowest, const double& highest) {
  return std::make_pair(lowest, highest);
}

} // namespace type
} // namespace analysis
} // namespace gos
