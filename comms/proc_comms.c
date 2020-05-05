#include <linux/module.h>
#include <linux/init.h>
#include <linux/errno.h>
#include <linux/fs.h>
#include <linux/proc_fs.h>
#include <linux/kernel.h>

#include "kfile_io.h"

MODULE_AUTHOR("Alexander Ding");
MODULE_DESCRIPTION("User to Kernel communication layer");
MODULE_LICENSE("GPL");

#define PROC_CONFIG_FILENAME "custom_proc_file"
#define PORTNAME "/dev/ttyUSB1"

static ssize_t proc_read(struct file*, char*, size_t, loff_t*);
static ssize_t proc_write(struct file*, const char*, size_t, loff_t*);
static int proc_open(struct inode*, struct file*);
static int proc_release(struct inode*, struct file*);

//Kernel Struct
//Uses callback functions
static struct file_operations custom_fops = {
	.owner = THIS_MODULE,
	.read  = proc_read,
	.write = proc_write,
	.open  = proc_open,
	.release = proc_release
};

//proc file kernel object
static struct proc_dir_entry* proc_file_entry = NULL;

//Device IO
static struct file* device_fp = NULL;

//Creates proc_file
static int __init setup(void){
	printk(KERN_INFO "filter: Loading proc_file module\n");
	
	//Kernel function call to create a file in the proc directory
	proc_file_entry = proc_create(PROC_CONFIG_FILENAME, 0777, NULL, &custom_fops);
	if(proc_file_entry == NULL){
		printk(KERN_ALERT "filter: Could not create proc file at /proc/%s\n", PROC_CONFIG_FILENAME);
		return -ENOMEM;
	}

	device_fp = file_open(PORTNAME, O_RDWR, O_NONBLOCK);
	if(device_fp == NULL){
		printk(KERN_INFO "filter: could not open device fd\n");
		return 0;
	}
	return 0;
}

//Invoked when anyone(presumably user) tries to write to PROC_CONFIG_FILENAME
static ssize_t proc_write(struct file* file, const char* buf, size_t count, loff_t* ppos){
	//Calls filter.c write
	return file_write(device_fp, *ppos, buf, count);

}

//Invoked when anyone(persumably user) tries to read from PROC_CONFIG_FILENAME
static ssize_t proc_read(struct file* file, char* buf, size_t count, loff_t* ppos) {
	//Calls filter.c read
	return file_read(device_fp, *ppos, buf, count);
}

//Invoked when anyone(persumably user) tries to open PROC_CONFIG_FILENAME
static int proc_open(struct inode* inode, struct file* file){return 0;}

//Invoked when a file_descriptor is closed to PROC_CONFIG_FILENAME
static int proc_release(struct inode* inode, struct file* file){return 0;}

static void __exit cleanup(void){
	printk(KERN_INFO "filter: Cleaning up and exiting proc_file\n");
	
	//Removes proc_file so there is no error when loading the same file next time
	file_close(device_fp);
	proc_remove(proc_file_entry);
}

module_init(setup);
module_exit(cleanup);
