#include <string>
#include <algorithm>

#include <gtest/gtest.h>
#include <gmock/gmock.h>

#include <gos/analysis/tests/analysis.h>

#include <gos/analysis/tc.h>

namespace ga = ::gos::analysis;

static std::string GetTestingVarFilePath();

TEST(AnalysisTcTest, Parse) {
  std::string varfilepath = GetTestingVarFilePath();

  ga::tc::StandardVector vector;

  ga::tc::parse(vector, varfilepath.c_str());

  EXPECT_EQ(3937, vector.size());
}

std::string GetTestingVarFilePath() {
  std::string varfilepath(GA_UNIT_TESTING_VAR_TC_STANDARD_PATH);
#ifdef _WIN32
  std::replace(varfilepath.begin(), varfilepath.end(), '/', '\\');
#endif
  return varfilepath;
}
