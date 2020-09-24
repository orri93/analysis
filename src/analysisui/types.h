#ifndef TYPES_H
#define TYPES_H

namespace gos {
namespace analysis {
namespace ui {

enum class status {
  undefined,
  idle,
  connecting,
  connected,
  disconnecting,
  down };

} // namespace ui
} // namespace analysis
} // namespace gos

#endif
