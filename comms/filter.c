#include <linux/ip.h>
#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/mutex.h>
#include <linux/netdevice.h>
#include <linux/netfilter.h>
#include <linux/netfilter_ipv4.h>
#include <linux/proc_fs.h>
#include <linux/skbuff.h>
#include <linux/slab.h>
#include <linux/udp.h>

int __init setup(void) {
    printk(KERN_INFO "filter: hello world\n");
    return 0;
}
 
void __exit finish(void) {
    printk(KERN_ALERT "filter: goodbye world\n");
}
 
module_init(setup);
module_exit(finish);
 
MODULE_LICENSE("GPL");

