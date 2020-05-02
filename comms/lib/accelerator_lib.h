#include <stdbool.h>

#define ACCELERATOR_BAUD_RATE         B115200

typedef enum {
  NO_ERROR,
  ERROR_OPENING_PROC_FILE,
  ERROR_SENDING_BYTES,
  ERROR_RECEIVING_BYTES
} accelerator_error_t;

typedef struct {
  char result_byte;
  accelerator_error_t error;
} result_t;

bool accelerator_initialize(const char* port_name);

result_t accelerator_xor_two_bytes(char* bytes);
