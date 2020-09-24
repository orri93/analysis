#include <gtest/gtest.h>
#include <gmock/gmock.h>

#include <gos/analysis/window.h>

namespace ga = ::gos::analysis;

static void CreateWindow(
  ga::window& window,
  const double* array,
  const size_t& count,
  const size_t& size);

TEST(AnalysisWindowTest, Median) {
  const double a1[] = { 9.0, 1.0, 3.0, 6.0, 3.0, 8.0, 7.0 };
  const double a2[] = { 9.0, 1.0, 3.0, 2.0, 4.0, 5.0, 8.0, 6.0 };

  ga::window window;
  
  CreateWindow(window, a1, 7, 7);
  EXPECT_DOUBLE_EQ(6.0, window.median());

  window.clear();
  CreateWindow(window, a2, 8, 8);
  EXPECT_DOUBLE_EQ(4.5, window.median());
}

TEST(AnalysisWindowTest, Sum) {
  const double a1[] = { 900.0, 600.0, 470.0, 170.0, 430.0, 300.0 };
  ga::window window;
  CreateWindow(window, a1, 6, 5);
  double sum = window.sum();
  EXPECT_DOUBLE_EQ(600.0 + 470.0 + 170.0 + 430.0 + 300.0, sum);
}

TEST(AnalysisWindowTest, Mean) {
  const double a1[] = { 900.0, 600.0, 470.0, 170.0, 430.0, 300.0 };
  ga::window window;
  CreateWindow(window, a1, 6, 5);
  double mean = window.mean();
  EXPECT_DOUBLE_EQ(394, mean);
}

TEST(AnalysisWindowTest, Variance) {
  const double a1[] = { 900.0, 600.0, 470.0, 170.0, 430.0, 300.0 };
  ga::window window;
  CreateWindow(window, a1, 6, 5);
  double variance = window.variance();
  EXPECT_DOUBLE_EQ(21704.0, variance);
}

TEST(AnalysisWindowTest, Sd) {
  const double a1[] = { 900.0, 600.0, 470.0, 170.0, 430.0, 300.0 };
  ga::window window;
  CreateWindow(window, a1, 6, 5);
  double sd = window.sd();
  EXPECT_DOUBLE_EQ(147.32277488562318, sd);
}

void CreateWindow(
  ga::window& window,
  const double* array,
  const size_t& count,
  const size_t& size) {
  window.set(size);
  for (size_t i = 0; i < count; i++) {
    window.add(array[i]);
  }
}
