#include <strstream>

#include <gos/analysis/exception.h>

namespace gos {
namespace analysis {
exception::exception(const char* what) {
  std::strstream s;
  s << "Analysis error: " << what << std::ends;
  what_ = s.str();
}
#if _MSC_VER >= 1910
const char* exception::what() const noexcept { return what_.c_str(); }
#else
const char* exception::what() const { return what_.c_str(); }
#endif
} // namespace analysis
} // namespace gos
