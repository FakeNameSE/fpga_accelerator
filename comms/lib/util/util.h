#include <unistd.h>
#include <unistd.h>

ssize_t read_all_from_fd(int fd, char *buffer, size_t count);
ssize_t write_all_to_fd(int fd, const char *buffer, size_t count);
