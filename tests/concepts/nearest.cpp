#include <cmath>

#include <algorithm>
#include <vector>

#include <gtest/gtest.h>
#include <gmock/gmock.h>

namespace gos {
namespace analysis {
namespace testing {
namespace concepts {

struct a {
  int x;
  int n;
};

struct b {
  int x;
  char c;
};

struct c {
  int x;
  int n;
  char c;
};

typedef std::vector<a> VectorA;
typedef std::vector<b> VectorB;
typedef std::vector<c> VectorC;

typedef VectorA::iterator IteratorA;
typedef VectorB::iterator IteratorB;
typedef VectorA::const_iterator ConstantIteratorA;
typedef VectorB::const_iterator ConstantIteratorB;
static VectorA va = {
  { 38, 6 },
  { 42, 8 },
  { 39, 7 },
  { 10, 1 },
  { 15, 3 },
  { 30, 5 },
  { 12, 2 },
  { 22, 4 },
  { 61, 14 },
  { 44, 9 },
  { 52, 11 },
  { 60, 13 },
  { 53, 12 },
  { 51, 10 }
};

static VectorB vb = {
  { 10, 'D' },
  { 30, 'G' },
  { 2, 'A' },
  { 9, 'C' },
  { 8, 'B' },
  { 56, 'J' },
  { 60, 'L' },
  { 61, 'M' },
  { 62, 'N' },
  { 15, 'E' },
  { 28, 'F' },
  { 55, 'I' },
  { 49, 'H' },
  { 57, 'K' }
};

static bool operator<(const a& l, const a& r);
static bool rcomparea(const a& l, const a& r);
static bool operator<(const b& l, const b& r);

static void combine(VectorC& vc, const VectorA& va, VectorB& vb);
static void combine(VectorC& vc, const VectorB& vb, VectorA& va);

TEST(AnalysisConceptsNearest, Oder) {
  std::sort(va.begin(), va.end(), rcomparea);
  EXPECT_EQ(14, va.begin()->n);
  std::sort(va.begin(), va.end());
  EXPECT_EQ(1, va.begin()->n);
}

TEST(AnalysisConceptsNearest,  Combine) {
  std::sort(va.begin(), va.end());
  std::sort(vb.begin(), vb.end());

  VectorC vc;
  combine(vc, va, vb);
  vc.clear();
  combine(vc, vb, va);
}

bool operator<(const a& l, const a& r) {
  return l.x < r.x;
}

bool rcomparea(const a& l, const a& r) {
  return l.x > r.x;
}

bool operator<(const b& l, const b& r) {
  return l.x < r.x;
}

void combine(VectorC& vc, const VectorA& va, VectorB& vb) {
  IteratorB sit;
  for (const a& a : va) {
    c c;
    c.x = a.x;
    c.n = a.n;
    IteratorB it = vb.begin();
    if (it != vb.end()) {
      c.c = it->c;
      while ((sit = it + 1) != vb.end()) {
        if (a.x > it->x && a.x <= sit->x) {
          if (std::abs(a.x - it->x) <= std::abs(a.x - sit->x)) {
            c.c = it->c;
          } else {
            c.c = sit->c;
          }
          break;
        }
        it++;
      }
    }
    vc.push_back(c);
  }
}

void combine(VectorC& vc, const VectorB& vb, VectorA& va) {
  IteratorA sit;
  for (const b& b : vb) {
    c c;
    c.x = b.x;
    c.c = b.c;
    IteratorA it = va.begin();
    if (it != va.end()) {
      c.n = it->n;
      while ((sit = it + 1) != va.end()) {
        if (b.x > it->x && b.x <= sit->x) {
          if (std::abs(b.x - it->x) <= std::abs(b.x - sit->x)) {
            c.n = it->n;
          } else {
            c.n = sit->n;
          }
          break;
        }
        it++;
      }
      if (b.x > it->x) {
        c.n = it->n;
      }
    }
    vc.push_back(c);
  }
}


} // namespace concepts
} // namespace testing
} // namespace analysis
} // namespace gos
