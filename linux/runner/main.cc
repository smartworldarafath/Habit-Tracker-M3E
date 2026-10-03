#include "my_application.h"

#include <stdlib.h>

int main(int argc, char** argv) {
  setenv("FLUTTER_ENGINE_SWITCHES", "1", 1);
  setenv("FLUTTER_ENGINE_SWITCH_1", "enable-impeller=false", 1);
  g_autoptr(MyApplication) app = my_application_new();
  return g_application_run(G_APPLICATION(app), argc, argv);
}
