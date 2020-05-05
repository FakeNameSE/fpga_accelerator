#define _DEFAULT_SOURCE

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <termios.h>
#include <unistd.h>
#include "util/util.h"
#include "accelerator_lib.h"

bool accelerator_initialize(const char* port_name) {
  int fd = open(port_name, O_RDWR | O_NOCTTY | O_SYNC);
  // Return immediately on error, errno should still be set for the user to use if desired then.
  if (fd == -1) {
    return false;
  }

  struct termios options;
  if (tcgetattr(fd, &options) == -1) {
    close(fd);
    return false;
  }
  cfsetispeed(&options, ACCELERATOR_BAUD_RATE);
  cfsetospeed(&options, ACCELERATOR_BAUD_RATE);
  options.c_cflag = (options.c_cflag & ~CSIZE) | CS8;     // 8-bit chars
  // disable IGNBRK for mismatched speed tests; otherwise receive break
  // as \000 chars
  options.c_iflag &= ~IGNBRK;         // disable break processing
  options.c_lflag = 0;                // no signaling chars, no echo,
  options.c_oflag = 0;                // no remapping, no delays
  options.c_cc[VMIN]  = 0;            // read doesn't block
  options.c_cc[VTIME] = 5;            // 0.5 seconds read timeout
  options.c_iflag &= ~(IXON | IXOFF | IXANY); // shut off xon/xoff ctrl
  options.c_cflag |= (CLOCAL | CREAD);// ignore modem controls,
  options.c_cflag &= ~(PARENB | PARODD);      // shut off parity
  options.c_cflag &= ~CSTOPB;
  options.c_cflag &= ~CRTSCTS;
  if (tcsetattr(fd, TCSANOW, &options) == -1) {
    return false;
  }

  if (close(fd) == -1) {
    return false;
  }
  return true;
}

result_t accelerator_xor_two_bytes(char* bytes) {
  result_t result = {.error = NO_ERROR};
  // TODO put correct proc filename in here.
  int accel_fd = open("/proc/custom_proc_file", O_RDWR | O_TRUNC);
  if (accel_fd == -1) {
    result.error = ERROR_OPENING_PROC_FILE;
    return result;
  }

  if (write_all_to_fd(accel_fd, bytes, sizeof(char) * 2) == -1) {
    result.error = ERROR_SENDING_BYTES;
    close(accel_fd);
    return result;
  }

  if (read_all_from_fd(accel_fd, &result.result_byte, 1) == -1) {
    result.error = ERROR_RECEIVING_BYTES;
    close(accel_fd);
    return result;
  }

  close(accel_fd);
  return result;
}
