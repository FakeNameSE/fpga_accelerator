#include <stdio.h>
#include "accelerator_lib.h"

int main(int argc, char const *argv[]) {
  if (argc != 4) {
    fprintf(stderr, "Usage: %s port_name byte_1 byte_2\n", argv[0]);
    return 1;
  }

  const char* port_name = argv[1];
  char bytes[2] = {*argv[2], *argv[3]};

  if (accelerator_initialize(port_name) == false) {
    perror("Failed to initialize accelerator");
    return 1;
  }

  result_t result = accelerator_xor_two_bytes(bytes);

  if (result.error != NO_ERROR) {
    perror("Accelerator computation failed");
    return 1;
  }

  printf("Accelerator computation result: %c, as int: %d\n", result.result_byte, (int) result.result_byte);

  return 0;
}
