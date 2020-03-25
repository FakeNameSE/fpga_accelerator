
#include <errno.h>
#include <fcntl.h> 
#include <string.h>
#include <termios.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

int
set_interface_attribs (int fd, int speed, int parity)
{
        struct termios tty;
        if (tcgetattr (fd, &tty) != 0)
        {
                // error_message ("error %d from tcgetattr", errno);
                return -1;
        }

        cfsetospeed (&tty, speed);
        cfsetispeed (&tty, speed);

        tty.c_cflag = (tty.c_cflag & ~CSIZE) | CS8;     // 8-bit chars
        // disable IGNBRK for mismatched speed tests; otherwise receive break
        // as \000 chars
        tty.c_iflag &= ~IGNBRK;         // disable break processing
        tty.c_lflag = 0;                // no signaling chars, no echo,
                                        // no canonical processing
        tty.c_oflag = 0;                // no remapping, no delays
        tty.c_cc[VMIN]  = 0;            // read doesn't block
        tty.c_cc[VTIME] = 5;            // 0.5 seconds read timeout

        tty.c_iflag &= ~(IXON | IXOFF | IXANY); // shut off xon/xoff ctrl

        tty.c_cflag |= (CLOCAL | CREAD);// ignore modem controls,
                                        // enable reading
        tty.c_cflag &= ~(PARENB | PARODD);      // shut off parity
        tty.c_cflag |= parity;
        tty.c_cflag &= ~CSTOPB;
        tty.c_cflag &= ~CRTSCTS;

        if (tcsetattr (fd, TCSANOW, &tty) != 0)
        {
                // error_message ("error %d from tcsetattr", errno);
                return -1;
        }
        return 0;
}

void
set_blocking (int fd, int should_block)
{
        struct termios tty;
        memset (&tty, 0, sizeof tty);
        if (tcgetattr (fd, &tty) != 0)
        {
                // error_message ("error %d from tggetattr", errno);
                return;
        }

        tty.c_cc[VMIN]  = should_block ? 1 : 0;
        tty.c_cc[VTIME] = 5;            // 0.5 seconds read timeout

        // if (tcsetattr (fd, TCSANOW, &tty) != 0)
                // error_message ("error %d setting term attributes", errno);
}

int main(int argc, char* argv[]) {
        if (argc < 3) {
            fprintf(stderr, "usage: ./write string bytes_to_send\n");
            return 1;
        }
        
        char *message = argv[1];
        int bytes_to_send = atoi(argv[2]);
        char *portname = "/dev/ttyS4";
        int fd = open (portname, O_RDWR | O_NOCTTY | O_SYNC);
        if (fd < 0) {
            fprintf(stderr, "error %d opening %s: %s\n", errno, portname, strerror (errno));
            return 1;
        }

        set_interface_attribs (fd, 9600, 0);  // set speed to 9600 baud, 8n1 (no parity)
        set_blocking (fd, 0);                // set no blocking

        int sent = write (fd, message, bytes_to_send);           // send byte of all 1's
        printf("sent %d bytes\n", sent);

        // usleep ((7 + 25) * 100);             // sleep enough to transmit the 7 plus
                                        // receive 25:  approx 100 uS per char transmit

        char buf [100];
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

