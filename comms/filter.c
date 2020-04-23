#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/module.h>
#include <linux/syscalls.h>
#include <linux/fcntl.h>
#include <asm/uaccess.h>

#include <filter.h>

int __init setup(void) {
    printk(KERN_INFO "filter: hello world\n");

    // setup port interface
    char *message = "ab";
    int bytes_to_send = 2;
    char *portname = "/dev/ttyS4";
    old_fs = get_fs();
    set_fs(KERNEL_DS);
    int fd = sys_open(portname, O_RDWR, 0);
    if (fd < 0) {
        printk(KERN_INFO "filter: could not open FD\n");
        return 0;
    }

    // struct termios options;
    // tcgetattr(fd, &options);
    // cfsetispeed(&options, B115200);
    // cfsetospeed(&options, B115200);
    // options.c_cflag = (options.c_cflag & ~CSIZE) | CS8;     // 8-bit chars
    // // disable IGNBRK for mismatched speed tests; otherwise receive break
    // // as \000 chars
    // options.c_iflag &= ~IGNBRK;         // disable break processing
    // options.c_lflag = 0;                // no signaling chars, no echo,
    // options.c_oflag = 0;                // no remapping, no delays
    // options.c_cc[VMIN]  = 0;            // read doesn't block
    // options.c_cc[VTIME] = 5;            // 0.5 seconds read timeout
    // options.c_iflag &= ~(IXON | IXOFF | IXANY); // shut off xon/xoff ctrl
    // options.c_cflag |= (CLOCAL | CREAD);// ignore modem controls,
    // options.c_cflag &= ~(PARENB | PARODD);      // shut off parity
    // options.c_cflag &= ~CSTOPB;
    // options.c_cflag &= ~CRTSCTS;
    // tcsetattr(fd, TCSANOW, &options);

    // send bytes
    loff_t pos = 0;
    sys_write(fd, message, bytes_to_send);
    struct file *file = fget(fd);
    if (file != NULL) {
      vfs_write(file, message, bytes_to_send, &pos);
      fput(file);
      printk(KERN_INFO "sent %d bytes\n", bytes_to_send);
    }
    else {
        printk(KERN_INFO "could not create file struct properly");
    }

    // close port interface
    char buf[100];
    printk(KERN_INFO "waiting for response...\n");
    int n = sys_read(fd, buf, sizeof(buf));  // read up to 100 characters if ready to read
    if (n < 0) {
        printk(KERN_INFO "error %d: %s\n", errno, strerror(errno));
        return 1;
    }
    printk(KERN_INFO "read %d bytes\n", n);
    int i;
    for (i = 0; i < n; i++)
        printk(KERN_INFO "char: %c, as int: %d\n", buf[i], (int) buf[i]);
    
    set_fs(old_fs);
    sys_close(fd);
    return 0;
}
 
void __exit finish(void) {
    printk(KERN_ALERT "filter: goodbye world\n");
}
 
module_init(setup);
module_exit(finish);
 
MODULE_LICENSE("GPL");

