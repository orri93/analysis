#include <cmath>

#include <algorithm>

#include <gos/analysis/window.h>

namespace ga = ::gos::analysis;

namespace gos {
namespace analysis {

window::window() : size_(10), sum_(0.0) {
}

window::window(const size_t& size) : size_(size), sum_(0.0) {
}

void window::setrange(const double& lowest, const double& highest) {
  range_ = std::make_unique<ga::type::Range>(lowest, highest);
}

void window::add(const double& value) {
  if (this->vector_.size() >= this->size_) {
    this->sum_ -= *(this->vector_.begin());
    this->vector_.erase(this->vector_.begin());
  }
  this->vector_.push_back(value);
  this->sum_ += value;
}

void window::clear() {
  this->sum_ = 0.0;
  this->vector_.clear();
}

void window::set(const size_t& size) {
  this->size_ = size;
}

const size_t& window::size() const {
  return size_;
}

size_t window::count() const {
  return vector_.size();
}

const ::gos::analysis::type::DoubleVector& window::vector() const {
  return vector_;
}

const double& window::sum() const {
  return sum_;
}

double window::mean() const {
  return sum_ / static_cast<double>(vector_.size());
}

double window::median() {
  ga::type::DoubleSize size = this->vector_.size();
  if (size > 1) {
    size_t medianindex = size / 2;
    ga::type::DoubleVector sorted(vector_);
    std::sort(sorted.begin(), sorted.end());
    if (size % 2 == 0) {
      return (sorted[medianindex - 1] + sorted[medianindex]) / 2.0;
    } else {
      return sorted[medianindex];
    }
  } else if(size == 1) {
    return *(this->vector_.begin());
  } else {
    return 0.0;
  }
}

double window::variance() const {
  double diff;
  double variance = 0.0;
  double mean = this->mean();
  for (auto v : this->vector_) {
    diff = v - mean;
    variance += diff * diff;
  }
  return variance / this->vector_.size();
}

double window::sd() const {
  return ::sqrt(variance());
}

} // namespace analysis
} // namespace gos
