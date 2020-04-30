#include <linux/module.h>
#include <linux/init.h>
#include <linux/errno.h>
#include <linux/fs.h>
#include <linux/proc_fs.h>
#include <linux/kernel.h>

MODULE_AUTHOR("Alexander Ding");
MODULE_DESCRIPTION("User to Kernel communication layer");
MODULE_LICENSE("GPL");

#define PROC_CONFIG_FILENAME "custom_proc_file"

static ssize_t proc_read(struct file*, char* size_t, loff_t*);
static ssize_t proc_write(struct file*, const char*, size_t, loff_t*);
static int proc_open(struct inode*, struct file*);
static int proc_release(struct inode*, struct file*);

static struct file_operations custom_fops = {
	.owner = THIS_MODULE;
	.read  = proc_read;
	.write = proc_write;
	.open  = proc_open;
	.release = proc_release;
}

static struct proc_dir_entry* proc_file_entry = NULL;

static int __int proc_file_init(void){
	printk(KERN_INFO "Loading proc_file module\n");

	proc_file_entry = proc_create(PROC_CONFIG_FILENAME, 0777, NULL, &custom_fops);
	if(proc_file_entry == NULL){
		prink(KERN_ALERT "Could not create proc file at /proc/%s\n", PROC_CONFIG_FILENAME);
		return -ENOMEM;
	}

	return 0;
}

static ssize_t proc_write(struct file* file, const char* buf, size_t count, loff_t* ppos){
	
	return count;
}

static ssize_t proc_read(struct file* file, char* buf, size_t count, loff_t* ppos){return 0;}
static int proc_open(struct inode* inode, struct file* file){return 0;}
static int proc_release(struct inode* inode, struct file* file){return 0;}

static void __exit proc_file_exit(void){
	printk(KERN_INFO "Cleaning up and exiting proc_file\n");

	proc_remove(proc_dir_entry);
}

module_init(proc_file_init);
module_exit(proc_file_exit);
