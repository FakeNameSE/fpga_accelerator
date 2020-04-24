#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/module.h>
#include <linux/syscalls.h>
#include <linux/fcntl.h>
#include <asm/uaccess.h>
#include <linux/fs.h>
#include <asm/segment.h>
#include <linux/buffer_head.h>

#include "filter.h"


struct file *file_open(const char *path, int flags, int rights) {
    struct file *filp = NULL;
    mm_segment_t oldfs;
    int err = 0;

    oldfs = get_fs();
    set_fs(get_ds());
    filp = filp_open(path, flags, rights);
    set_fs(oldfs);
    if (IS_ERR(filp)) {
        err = PTR_ERR(filp);
        return NULL;
    }
    return filp;
}

void file_close(struct file *file) {
    filp_close(file, NULL);
}


int file_write(struct file *file, unsigned long long offset, unsigned char *data, unsigned int size) {
    mm_segment_t oldfs;
    int ret;

    oldfs = get_fs();
    set_fs(get_ds());

    ret = vfs_write(file, data, size, &offset);

    set_fs(oldfs);
    return ret;
}

int file_read(struct file *file, unsigned long long offset, unsigned char *data, unsigned int size) {
    mm_segment_t oldfs;
    int ret;

    oldfs = get_fs();
    set_fs(get_ds());

    ret = vfs_read(file, data, size, &offset);

    set_fs(oldfs);
    return ret;
}   


int __init setup(void) {
    printk(KERN_INFO "filter: hello world\n");

    // setup port interface
    char *message, *portname;
    int bytes_to_send;
    message = "ab";
    bytes_to_send = 2;
    portname = "/dev/ttyUSB1";
    struct file *fp = file_open(portname, O_RDWR, 0);
    if (fp == NULL) {
        printk(KERN_INFO "filter: could not open FD\n");
        return 0;
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

    // send bytes
    file_write(fp, 0, message, bytes_to_send);

    // close port interface
    char buf[100];
    printk(KERN_INFO "filter: waiting for response...\n");
    int nb = file_read(fp, 0, buf, sizeof(buf));
    printk(KERN_INFO "filter: read %d bytes, 1st as int: %d\n", nb, (int) buf[0]);
    int i;
    for (i = 0; i < nb; i++) {
        printk(KERN_INFO "filter: read as int: %d\n", (int) buf[i]);
    }
    
    file_close(fp);
    return 0;
}
 
void __exit finish(void) {
    printk(KERN_ALERT "filter: goodbye world\n");
}
 
module_init(setup);
module_exit(finish);
 
MODULE_LICENSE("GPL");

