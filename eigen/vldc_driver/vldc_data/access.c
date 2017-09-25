/*
 * access.c -- the files with access control on open
 *
 * Copyright (C) 2001 Alessandro Rubini and Jonathan Corbet
 * Copyright (C) 2001 O'Reilly & Associates
 *
 * The source code in this file can be freely used, adapted,
 * and redistributed in source or binary form, so long as an
 * acknowledgment appears in derived source files.  The citation
 * should list that the code comes from the book "Linux Device
 * Drivers" by Alessandro Rubini and Jonathan Corbet, published
 * by O'Reilly & Associates.   No warranty is attached;
 * we cannot take responsibility for errors or fitness for use.
 *
 * $Id: access.c,v 1.17 2004/09/26 07:29:56 gregkh Exp $
 */

/* FIXME: cloned devices as a use for kobjects? */
 
#include <linux/kernel.h> /* printk() */
#include <linux/module.h>
#include <linux/slab.h>   /* kmalloc() */
#include <linux/fs.h>     /* everything... */
#include <linux/errno.h>  /* error codes */
#include <linux/types.h>  /* size_t */
#include <linux/fcntl.h>
#include <linux/cdev.h>
#include <linux/tty.h>
#include <asm/atomic.h>
#include <linux/list.h>
#include <linux/cred.h> /* current_uid(), current_euid() */
#include <linux/sched.h>

#include "vldc_data.h"        /* local definitions */

static dev_t vldc_data_a_firstdev;  /* Where our range begins */

/*
 * These devices fall back on the main vldc_data operations. They only
 * differ in the implementation of open() and close()
 */



/************************************************************************
 *
 * The first device is the single-open one,
 *  it has an hw structure and an open count
 */

static struct vldc_data_dev vldc_data_s_device;
static atomic_t vldc_data_s_available = ATOMIC_INIT(1);

static int vldc_data_s_open(struct inode *inode, struct file *filp)
{
	struct vldc_data_dev *dev = &vldc_data_s_device; /* device information */

	if (! atomic_dec_and_test (&vldc_data_s_available)) {
		atomic_inc(&vldc_data_s_available);
		return -EBUSY; /* already open */
	}

	/* then, everything else is copied from the bare vldc_data device */
	if ( (filp->f_flags & O_ACCMODE) == O_WRONLY)
		vldc_data_trim(dev);
	filp->private_data = dev;
	return 0;          /* success */
}

static int vldc_data_s_release(struct inode *inode, struct file *filp)
{
	atomic_inc(&vldc_data_s_available); /* release the device */
	return 0;
}


/*
 * The other operations for the single-open device come from the bare device
 */
struct file_operations vldc_data_sngl_fops = {
	.owner =	THIS_MODULE,
	.llseek =     	vldc_data_llseek,
	.read =       	vldc_data_read,
	.write =      	vldc_data_write,
	.unlocked_ioctl = vldc_data_ioctl,
	.open =       	vldc_data_s_open,
	.release =    	vldc_data_s_release,
};


/************************************************************************
 *
 * Next, the "uid" device. It can be opened multiple times by the
 * same user, but access is denied to other users if the device is open
 */

static struct vldc_data_dev vldc_data_u_device;
static int vldc_data_u_count;	/* initialized to 0 by default */
static uid_t vldc_data_u_owner;	/* initialized to 0 by default */
static DEFINE_SPINLOCK(vldc_data_u_lock);

static int vldc_data_u_open(struct inode *inode, struct file *filp)
{
	struct vldc_data_dev *dev = &vldc_data_u_device; /* device information */

	spin_lock(&vldc_data_u_lock);
	if (vldc_data_u_count && 
	                (vldc_data_u_owner != current_uid().val) &&  /* allow user */
	                (vldc_data_u_owner != current_euid().val) && /* allow whoever did su */
			!capable(CAP_DAC_OVERRIDE)) { /* still allow root */
		spin_unlock(&vldc_data_u_lock);
		return -EBUSY;   /* -EPERM would confuse the user */
	}

	if (vldc_data_u_count == 0)
		vldc_data_u_owner = current_uid().val; /* grab it */

	vldc_data_u_count++;
	spin_unlock(&vldc_data_u_lock);

/* then, everything else is copied from the bare vldc_data device */

	if ((filp->f_flags & O_ACCMODE) == O_WRONLY)
		vldc_data_trim(dev);
	filp->private_data = dev;
	return 0;          /* success */
}

static int vldc_data_u_release(struct inode *inode, struct file *filp)
{
	spin_lock(&vldc_data_u_lock);
	vldc_data_u_count--; /* nothing else */
	spin_unlock(&vldc_data_u_lock);
	return 0;
}



/*
 * The other operations for the device come from the bare device
 */
struct file_operations vldc_data_user_fops = {
	.owner =      THIS_MODULE,
	.llseek =     vldc_data_llseek,
	.read =       vldc_data_read,
	.write =      vldc_data_write,
	.unlocked_ioctl = vldc_data_ioctl,
	.open =       vldc_data_u_open,
	.release =    vldc_data_u_release,
};


/************************************************************************
 *
 * Next, the device with blocking-open based on uid
 */

static struct vldc_data_dev vldc_data_w_device;
static int vldc_data_w_count;	/* initialized to 0 by default */
static uid_t vldc_data_w_owner;	/* initialized to 0 by default */
static DECLARE_WAIT_QUEUE_HEAD(vldc_data_w_wait);
static DEFINE_SPINLOCK(vldc_data_w_lock);

static inline int vldc_data_w_available(void)
{
	return vldc_data_w_count == 0 ||
		vldc_data_w_owner == current_uid().val ||
		vldc_data_w_owner == current_euid().val ||
		capable(CAP_DAC_OVERRIDE);
}


static int vldc_data_w_open(struct inode *inode, struct file *filp)
{
	struct vldc_data_dev *dev = &vldc_data_w_device; /* device information */

	spin_lock(&vldc_data_w_lock);
	while (! vldc_data_w_available()) {
		spin_unlock(&vldc_data_w_lock);
		if (filp->f_flags & O_NONBLOCK) return -EAGAIN;
		if (wait_event_interruptible (vldc_data_w_wait, vldc_data_w_available()))
			return -ERESTARTSYS; /* tell the fs layer to handle it */
		spin_lock(&vldc_data_w_lock);
	}
	if (vldc_data_w_count == 0)
		vldc_data_w_owner = current_uid().val; /* grab it */
	vldc_data_w_count++;
	spin_unlock(&vldc_data_w_lock);

	/* then, everything else is copied from the bare vldc_data device */
	if ((filp->f_flags & O_ACCMODE) == O_WRONLY)
		vldc_data_trim(dev);
	filp->private_data = dev;
	return 0;          /* success */
}

static int vldc_data_w_release(struct inode *inode, struct file *filp)
{
	int temp;

	spin_lock(&vldc_data_w_lock);
	vldc_data_w_count--;
	temp = vldc_data_w_count;
	spin_unlock(&vldc_data_w_lock);

	if (temp == 0)
		wake_up_interruptible_sync(&vldc_data_w_wait); /* awake other uid's */
	return 0;
}


/*
 * The other operations for the device come from the bare device
 */
struct file_operations vldc_data_wusr_fops = {
	.owner =      THIS_MODULE,
	.llseek =     vldc_data_llseek,
	.read =       vldc_data_read,
	.write =      vldc_data_write,
	.unlocked_ioctl = vldc_data_ioctl,
	.open =       vldc_data_w_open,
	.release =    vldc_data_w_release,
};

/************************************************************************
 *
 * Finally the `cloned' private device. This is trickier because it
 * involves list management, and dynamic allocation.
 */

/* The clone-specific data structure includes a key field */

struct vldc_data_listitem {
	struct vldc_data_dev device;
	dev_t key;
	struct list_head list;
    
};

/* The list of devices, and a lock to protect it */
static LIST_HEAD(vldc_data_c_list);
static DEFINE_SPINLOCK(vldc_data_c_lock);

/* A placeholder vldc_data_dev which really just holds the cdev stuff. */
static struct vldc_data_dev vldc_data_c_device;   

/* Look for a device or create one if missing */
static struct vldc_data_dev *vldc_data_c_lookfor_device(dev_t key)
{
	struct vldc_data_listitem *lptr;

	list_for_each_entry(lptr, &vldc_data_c_list, list) {
		if (lptr->key == key)
			return &(lptr->device);
	}

	/* not found */
	lptr = kmalloc(sizeof(struct vldc_data_listitem), GFP_KERNEL);
	if (!lptr)
		return NULL;

	/* initialize the device */
	memset(lptr, 0, sizeof(struct vldc_data_listitem));
	lptr->key = key;
	vldc_data_trim(&(lptr->device)); /* initialize it */
	sema_init(&(lptr->device.sem), 1);

	/* place it in the list */
	list_add(&lptr->list, &vldc_data_c_list);

	return &(lptr->device);
}

static int vldc_data_c_open(struct inode *inode, struct file *filp)
{
	struct vldc_data_dev *dev;
	dev_t key;
 
	if (!current->signal->tty) { 
		PDEBUG("Process \"%s\" has no ctl tty\n", current->comm);
		return -EINVAL;
	}
	key = tty_devnum(current->signal->tty);

	/* look for a vldc_datac device in the list */
	spin_lock(&vldc_data_c_lock);
	dev = vldc_data_c_lookfor_device(key);
	spin_unlock(&vldc_data_c_lock);

	if (!dev)
		return -ENOMEM;

	/* then, everything else is copied from the bare vldc_data device */
	if ( (filp->f_flags & O_ACCMODE) == O_WRONLY)
		vldc_data_trim(dev);
	filp->private_data = dev;
	return 0;          /* success */
}

static int vldc_data_c_release(struct inode *inode, struct file *filp)
{
	/*
	 * Nothing to do, because the device is persistent.
	 * A `real' cloned device should be freed on last close
	 */
	return 0;
}



/*
 * The other operations for the device come from the bare device
 */
struct file_operations vldc_data_priv_fops = {
	.owner =    THIS_MODULE,
	.llseek =   vldc_data_llseek,
	.read =     vldc_data_read,
	.write =    vldc_data_write,
	.unlocked_ioctl = vldc_data_ioctl,
	.open =     vldc_data_c_open,
	.release =  vldc_data_c_release,
};

/************************************************************************
 *
 * And the init and cleanup functions come last
 */

static struct vldc_data_adev_info {
	char *name;
	struct vldc_data_dev *vldc_datadev;
	struct file_operations *fops;
} vldc_data_access_devs[] = {
	{ "vldc_datasingle", &vldc_data_s_device, &vldc_data_sngl_fops },
	{ "vldc_datauid", &vldc_data_u_device, &vldc_data_user_fops },
	{ "vldc_datawuid", &vldc_data_w_device, &vldc_data_wusr_fops },
	{ "sullpriv", &vldc_data_c_device, &vldc_data_priv_fops }
};
#define VLDC_DATA_N_ADEVS 4

/*
 * Set up a single device.
 */
static void vldc_data_access_setup (dev_t devno, struct vldc_data_adev_info *devinfo)
{
	struct vldc_data_dev *dev = devinfo->vldc_datadev;
	int err;

	/* Initialize the device structure */
	dev->quantum = vldc_data_quantum;
	dev->qset = vldc_data_qset;
	sema_init(&dev->sem, 1);

	/* Do the cdev stuff. */
	cdev_init(&dev->cdev, devinfo->fops);
	kobject_set_name(&dev->cdev.kobj, devinfo->name);
	dev->cdev.owner = THIS_MODULE;
	err = cdev_add (&dev->cdev, devno, 1);
        /* Fail gracefully if need be */
	if (err) {
		printk(KERN_NOTICE "Error %d adding %s\n", err, devinfo->name);
		kobject_put(&dev->cdev.kobj);
	} else
		printk(KERN_NOTICE "%s registered at %x\n", devinfo->name, devno);
}


int vldc_data_access_init(dev_t firstdev)
{
	int result, i;

	/* Get our number space */
	result = register_chrdev_region (firstdev, VLDC_DATA_N_ADEVS, "vldc_dataa");
	if (result < 0) {
		printk(KERN_WARNING "vldc_dataa: device number registration failed\n");
		return 0;
	}
	vldc_data_a_firstdev = firstdev;

	/* Set up each device. */
	for (i = 0; i < VLDC_DATA_N_ADEVS; i++)
		vldc_data_access_setup (firstdev + i, vldc_data_access_devs + i);
	return VLDC_DATA_N_ADEVS;
}

/*
 * This is called by cleanup_module or on failure.
 * It is required to never fail, even if nothing was initialized first
 */
void vldc_data_access_cleanup(void)
{
	struct vldc_data_listitem *lptr, *next;
	int i;

	/* Clean up the static devs */
	for (i = 0; i < VLDC_DATA_N_ADEVS; i++) {
		struct vldc_data_dev *dev = vldc_data_access_devs[i].vldc_datadev;
		cdev_del(&dev->cdev);
		vldc_data_trim(vldc_data_access_devs[i].vldc_datadev);
	}

    	/* And all the cloned devices */
	list_for_each_entry_safe(lptr, next, &vldc_data_c_list, list) {
		list_del(&lptr->list);
		vldc_data_trim(&(lptr->device));
		kfree(lptr);
	}

	/* Free up our number space */
	unregister_chrdev_region(vldc_data_a_firstdev, VLDC_DATA_N_ADEVS);
	return;
}
