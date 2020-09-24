#ifndef GOS_ANALYSIS_WINDOW_H_
#define GOS_ANALYSIS_WINDOW_H_

#include <memory>

#include <gos/analysis/types.h>

namespace gos {
namespace analysis {

class window {
public:
  window();

  window(const size_t& size);

  void setrange(const double& lowest, const double& highest);

  void add(const double& value);

  void set(const size_t& size);

  const size_t& size() const;

  size_t count() const;

  const ::gos::analysis::type::DoubleVector& vector() const;
  
  const double& sum() const;

  void clear();

  double mean() const;

  double median();

  double variance() const;

  double sd() const;

private:
  typedef std::unique_ptr<::gos::analysis::type::Range> RangePointer;
  ::gos::analysis::type::DoubleVector vector_;
  RangePointer range_;
  size_t size_;
  double sum_;
};
} // namespace analysis
} // namespace gos


#endif