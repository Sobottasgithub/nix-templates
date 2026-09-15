#include "../include/cpp_template.h"

#include <tablog.h>
#include <memory>

namespace cppTemplate {
  CppTemplate::CppTemplate() {
    std::shared_ptr<tablog::Tablog> logger = std::make_shared<tablog::Tablog>();
    logger->configure("Cpp-Lib-Template", true);
    logger->log(tablog::DEBUG, "CPP lib template");
  }
}
