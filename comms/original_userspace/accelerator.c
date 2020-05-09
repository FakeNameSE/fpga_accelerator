
#include <errno.h>
#include <fcntl.h>
#include <string.h>
#include <termios.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <sys/ioctl.h>
#include "filter.h"

int main(int argc, char* argv[]) {
        if (argc < 3) {
            fprintf(stderr, "usage: ./write string bytes_to_send (can be -1 for all) \n");
            return 1;
        }

        char *message = argv[1];
        int bytes_to_send = atoi(argv[2]);
        if (bytes_to_send == -1)
                bytes_to_send = strlen(message);
        char *portname = "/dev/ttyUSB1";
        int fd = open (portname, O_RDWR | O_NOCTTY | O_SYNC);
        if (fd < 0) {
            fprintf(stderr, "error %d opening %s: %s\n", errno, portname, strerror (errno));
            return 1;
        }

        struct termios options;
        tcgetattr(fd, &options);
        cfsetispeed(&options, B115200);
        cfsetospeed(&options, B115200);
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
        tcsetattr(fd, TCSANOW, &options);

        int sent = write (fd, message, bytes_to_send);           // send byte of all 1's
        printf("sent %d bytes\n", sent);
        if (sent != bytes_to_send) {
                return 1;
        }

        char buf[100];
        printf("waiting for response...\n");
        int n = read (fd, buf, sizeof buf);  // read up to 100 characters if ready to read
        if (n < 0) {
            fprintf(stderr, "error %d: %s\n", errno, strerror (errno));
            return 1;
        }
        printf("read %d bytes\n", n);
        int i;
        for (i = 0; i < n; i++)
          printf("char: %c, as int: %d\n", buf[i], (int) buf[i]);

        close(fd);
        return 0;
}
