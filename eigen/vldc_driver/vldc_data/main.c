 /*
 * main.c -- the bare vldc_data char module
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
 */

#include <linux/module.h>
#include <linux/moduleparam.h>
#include <linux/init.h>

#include <linux/kernel.h>	/* printk() */
#include <linux/slab.h>		/* kmalloc() */
#include <linux/fs.h>		/* everything... */
#include <linux/errno.h>	/* error codes */
#include <linux/types.h>	/* size_t */
#include <linux/proc_fs.h>
#include <linux/fcntl.h>	/* O_ACCMODE */
#include <linux/seq_file.h>
#include <linux/cdev.h>

#include <asm/uaccess.h>	/* copy_*_user */

#include "vldc_data.h"		/* local definitions */

/*
 * Our parameters which can be set at load time.
 */

int vldc_data_major =   VLDC_DATA_MAJOR;
int vldc_data_minor =   0;
int vldc_data_nr_devs = VLDC_DATA_NR_DEVS;	/* number of bare vldc_data devices */
int vldc_data_quantum = VLDC_DATA_QUANTUM;
int vldc_data_qset =    VLDC_DATA_QSET;

module_param(vldc_data_major, int, S_IRUGO);
module_param(vldc_data_minor, int, S_IRUGO);
module_param(vldc_data_nr_devs, int, S_IRUGO);
module_param(vldc_data_quantum, int, S_IRUGO);
module_param(vldc_data_qset, int, S_IRUGO);

MODULE_AUTHOR("Alessandro Rubini, Jonathan Corbet");
MODULE_LICENSE("Dual BSD/GPL");

struct vldc_data_dev *vldc_data_devices;	/* allocated in vldc_data_init_module */


/*
 * Empty out the vldc_data device; must be called with the device
 * semaphore held.
 */
int vldc_data_trim(struct vldc_data_dev *dev)
{
	struct vldc_data_qset *next, *dptr;
	int qset = dev->qset;   /* "dev" is not-null */
	int i;

	for (dptr = dev->data; dptr; dptr = next) { /* all the list items */
		if (dptr->data) {
			for (i = 0; i < qset; i++)
				kfree(dptr->data[i]);
			kfree(dptr->data);
			dptr->data = NULL;
		}
		next = dptr->next;
		kfree(dptr);
	}
	dev->size = 0;
	dev->quantum = vldc_data_quantum;
	dev->qset = vldc_data_qset;
	dev->data = NULL;
	return 0;
}
#ifdef VLDC_DATA_DEBUG /* use proc only if debugging */
/*
 * The proc filesystem: function to read and entry
 */

int vldc_data_read_procmem(struct seq_file *s, void *v)
{
        int i, j;
        int limit = s->size - 80; /* Don't print more than this */

        for (i = 0; i < vldc_data_nr_devs && s->count <= limit; i++) {
                struct vldc_data_dev *d = &vldc_data_devices[i];
                struct vldc_data_qset *qs = d->data;
                if (down_interruptible(&d->sem))
                        return -ERESTARTSYS;
                seq_printf(s,"\nDevice %i: qset %i, q %i, sz %li\n",
                             i, d->qset, d->quantum, d->size);
                for (; qs && s->count <= limit; qs = qs->next) { /* scan the list */
                        seq_printf(s, "  item at %p, qset at %p\n",
                                     qs, qs->data);
                        if (qs->data && !qs->next) /* dump only the last item */
                                for (j = 0; j < d->qset; j++) {
                                        if (qs->data[j])
                                                seq_printf(s, "    % 4i: %8p\n",
                                                             j, qs->data[j]);
                                }
                }
                up(&vldc_data_devices[i].sem);
        }
        return 0;
}



/*
 * Here are our sequence iteration methods.  Our "position" is
 * simply the device number.
 */
static void *vldc_data_seq_start(struct seq_file *s, loff_t *pos)
{
	if (*pos >= vldc_data_nr_devs)
		return NULL;   /* No more to read */
	return vldc_data_devices + *pos;
}

static void *vldc_data_seq_next(struct seq_file *s, void *v, loff_t *pos)
{
	(*pos)++;
	if (*pos >= vldc_data_nr_devs)
		return NULL;
	return vldc_data_devices + *pos;
}

static void vldc_data_seq_stop(struct seq_file *s, void *v)
{
	/* Actually, there's nothing to do here */
}

static int vldc_data_seq_show(struct seq_file *s, void *v)
{
	struct vldc_data_dev *dev = (struct vldc_data_dev *) v;
	struct vldc_data_qset *d;
	int i;

	if (down_interruptible(&dev->sem))
		return -ERESTARTSYS;
	seq_printf(s, "\nDevice %i: qset %i, q %i, sz %li\n",
			(int) (dev - vldc_data_devices), dev->qset,
			dev->quantum, dev->size);
	for (d = dev->data; d; d = d->next) { /* scan the list */
		seq_printf(s, "  item at %p, qset at %p\n", d, d->data);
		if (d->data && !d->next) /* dump only the last item */
			for (i = 0; i < dev->qset; i++) {
				if (d->data[i])
					seq_printf(s, "    % 4i: %8p\n",
							i, d->data[i]);
			}
	}
	up(&dev->sem);
	return 0;
}
	
/*
 * Tie the sequence operators up.
 */
static struct seq_operations vldc_data_seq_ops = {
	.start = vldc_data_seq_start,
	.next  = vldc_data_seq_next,
	.stop  = vldc_data_seq_stop,
	.show  = vldc_data_seq_show
};

/*
 * Now to implement the /proc files we need only make an open
 * method which sets up the sequence operators.
 */
static int vldc_datamem_proc_open(struct inode *inode, struct file *file)
{
	return single_open(file, vldc_data_read_procmem, NULL);
}

static int vldc_dataseq_proc_open(struct inode *inode, struct file *file)
{
	return seq_open(file, &vldc_data_seq_ops);
}

/*
 * Create a set of file operations for our proc files.
 */
static struct file_operations vldc_datamem_proc_ops = {
	.owner   = THIS_MODULE,
	.open    = vldc_datamem_proc_open,
	.read    = seq_read,
	.llseek  = seq_lseek,
	.release = single_release
};

static struct file_operations vldc_dataseq_proc_ops = {
	.owner   = THIS_MODULE,
	.open    = vldc_dataseq_proc_open,
	.read    = seq_read,
	.llseek  = seq_lseek,
	.release = seq_release
};
	

/*
 * Actually create (and remove) the /proc file(s).
 */

static void vldc_data_create_proc(void)
{
	proc_create_data("vldc_datamem", 0 /* default mode */,
			NULL /* parent dir */, &vldc_datamem_proc_ops,
			NULL /* client data */);
	proc_create("vldc_dataseq", 0, NULL, &vldc_dataseq_proc_ops);
}

static void vldc_data_remove_proc(void)
{
	/* no problem if it was not registered */
	remove_proc_entry("vldc_datamem", NULL /* parent dir */);
	remove_proc_entry("vldc_dataseq", NULL);
}


#endif /* VLDC_DATA_DEBUG */





/*
 * Open and close
 */

int vldc_data_open(struct inode *inode, struct file *filp)
{
	struct vldc_data_dev *dev; /* device information */

	dev = container_of(inode->i_cdev, struct vldc_data_dev, cdev);
	filp->private_data = dev; /* for other methods */

	/* now trim to 0 the length of the device if open was write-only */
	if ( (filp->f_flags & O_ACCMODE) == O_WRONLY) {
		if (down_interruptible(&dev->sem))
			return -ERESTARTSYS;
		vldc_data_trim(dev); /* ignore errors */
		up(&dev->sem);
	}
	return 0;          /* success */
}

int vldc_data_release(struct inode *inode, struct file *filp)
{
	return 0;
}
/*
 * Follow the list
 */
struct vldc_data_qset *vldc_data_follow(struct vldc_data_dev *dev, int n)
{
	struct vldc_data_qset *qs = dev->data;

        /* Allocate first qset explicitly if need be */
	if (! qs) {
		qs = dev->data = kmalloc(sizeof(struct vldc_data_qset), GFP_KERNEL);
		if (qs == NULL)
			return NULL;  /* Never mind */
		memset(qs, 0, sizeof(struct vldc_data_qset));
	}

	/* Then follow the list */
	while (n--) {
		if (!qs->next) {
			qs->next = kmalloc(sizeof(struct vldc_data_qset), GFP_KERNEL);
			if (qs->next == NULL)
				return NULL;  /* Never mind */
			memset(qs->next, 0, sizeof(struct vldc_data_qset));
		}
		qs = qs->next;
		continue;
	}
	return qs;
}

/*
 * Data management: read and write
 */

ssize_t vldc_data_read(struct file *filp, char __user *buf, size_t count,
                loff_t *f_pos)
{
	struct vldc_data_dev *dev = filp->private_data; 
	struct vldc_data_qset *dptr;	/* the first listitem */
	int quantum = dev->quantum, qset = dev->qset;
	int itemsize = quantum * qset; /* how many bytes in the listitem */
	int item, s_pos, q_pos, rest;
	ssize_t retval = 0;

	if (down_interruptible(&dev->sem))
		return -ERESTARTSYS;
	if (*f_pos >= dev->size)
		goto out;
	if (*f_pos + count > dev->size)
		count = dev->size - *f_pos;

	/* find listitem, qset index, and offset in the quantum */
	item = (long)*f_pos / itemsize;
	rest = (long)*f_pos % itemsize;
	s_pos = rest / quantum; q_pos = rest % quantum;

	/* follow the list up to the right position (defined elsewhere) */
	dptr = vldc_data_follow(dev, item);

	if (dptr == NULL || !dptr->data || ! dptr->data[s_pos])
		goto out; /* don't fill holes */

	/* read only up to the end of this quantum */
	if (count > quantum - q_pos)
		count = quantum - q_pos;

	if (copy_to_user(buf, dptr->data[s_pos] + q_pos, count)) {
		retval = -EFAULT;
		goto out;
	}
	*f_pos += count;
	retval = count;

  out:
	up(&dev->sem);
	return retval;
}

ssize_t vldc_data_write(struct file *filp, const char __user *buf, size_t count,
                loff_t *f_pos)
{
	struct vldc_data_dev *dev = filp->private_data;
	struct vldc_data_qset *dptr;
	int quantum = dev->quantum, qset = dev->qset;
	int itemsize = quantum * qset;
	int item, s_pos, q_pos, rest;
	ssize_t retval = -ENOMEM; /* value used in "goto out" statements */

	if (down_interruptible(&dev->sem))
		return -ERESTARTSYS;

	/* find listitem, qset index and offset in the quantum */
	item = (long)*f_pos / itemsize;
	rest = (long)*f_pos % itemsize;
	s_pos = rest / quantum; q_pos = rest % quantum;

	/* follow the list up to the right position */
	dptr = vldc_data_follow(dev, item);
	if (dptr == NULL)
		goto out;
	if (!dptr->data) {
		dptr->data = kmalloc(qset * sizeof(char *), GFP_KERNEL);
		if (!dptr->data)
			goto out;
		memset(dptr->data, 0, qset * sizeof(char *));
	}
	if (!dptr->data[s_pos]) {
		dptr->data[s_pos] = kmalloc(quantum, GFP_KERNEL);
		if (!dptr->data[s_pos])
			goto out;
	}
	/* write only up to the end of this quantum */
	if (count > quantum - q_pos)
		count = quantum - q_pos;

	if (copy_from_user(dptr->data[s_pos]+q_pos, buf, count)) {
		retval = -EFAULT;
		goto out;
	}
	*f_pos += count;
	retval = count;

        /* update the size */
	if (dev->size < *f_pos)
		dev->size = *f_pos;

  out:
	up(&dev->sem);
	return retval;
}

/*
 * The ioctl() implementation
 */

long vldc_data_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
{

	int err = 0, tmp;
	int retval = 0;
    
	/*
	 * extract the type and number bitfields, and don't decode
	 * wrong cmds: return ENOTTY (inappropriate ioctl) before access_ok()
	 */
	if (_IOC_TYPE(cmd) != VLDC_DATA_IOC_MAGIC) return -ENOTTY;
	if (_IOC_NR(cmd) > VLDC_DATA_IOC_MAXNR) return -ENOTTY;

	/*
	 * the direction is a bitmask, and VERIFY_WRITE catches R/W
	 * transfers. `Type' is user-oriented, while
	 * access_ok is kernel-oriented, so the concept of "read" and
	 * "write" is reversed
	 */
	if (_IOC_DIR(cmd) & _IOC_READ)
		err = !access_ok(VERIFY_WRITE, (void __user *)arg, _IOC_SIZE(cmd));
	else if (_IOC_DIR(cmd) & _IOC_WRITE)
		err =  !access_ok(VERIFY_READ, (void __user *)arg, _IOC_SIZE(cmd));
	if (err) return -EFAULT;

	switch(cmd) {

	  case VLDC_DATA_IOCRESET:
		vldc_data_quantum = VLDC_DATA_QUANTUM;
		vldc_data_qset = VLDC_DATA_QSET;
		break;
        
	  case VLDC_DATA_IOCSQUANTUM: /* Set: arg points to the value */
		if (! capable (CAP_SYS_ADMIN))
			return -EPERM;
		retval = __get_user(vldc_data_quantum, (int __user *)arg);
		break;

	  case VLDC_DATA_IOCTQUANTUM: /* Tell: arg is the value */
		if (! capable (CAP_SYS_ADMIN))
			return -EPERM;
		vldc_data_quantum = arg;
		break;

	  case VLDC_DATA_IOCGQUANTUM: /* Get: arg is pointer to result */
		retval = __put_user(vldc_data_quantum, (int __user *)arg);
		break;

	  case VLDC_DATA_IOCQQUANTUM: /* Query: return it (it's positive) */
		return vldc_data_quantum;

	  case VLDC_DATA_IOCXQUANTUM: /* eXchange: use arg as pointer */
		if (! capable (CAP_SYS_ADMIN))
			return -EPERM;
		tmp = vldc_data_quantum;
		retval = __get_user(vldc_data_quantum, (int __user *)arg);
		if (retval == 0)
			retval = __put_user(tmp, (int __user *)arg);
		break;

	  case VLDC_DATA_IOCHQUANTUM: /* sHift: like Tell + Query */
		if (! capable (CAP_SYS_ADMIN))
			return -EPERM;
		tmp = vldc_data_quantum;
		vldc_data_quantum = arg;
		return tmp;
        
	  case VLDC_DATA_IOCSQSET:
		if (! capable (CAP_SYS_ADMIN))
			return -EPERM;
		retval = __get_user(vldc_data_qset, (int __user *)arg);
		break;

	  case VLDC_DATA_IOCTQSET:
		if (! capable (CAP_SYS_ADMIN))
			return -EPERM;
		vldc_data_qset = arg;
		break;

	  case VLDC_DATA_IOCGQSET:
		retval = __put_user(vldc_data_qset, (int __user *)arg);
		break;

	  case VLDC_DATA_IOCQQSET:
		return vldc_data_qset;

	  case VLDC_DATA_IOCXQSET:
		if (! capable (CAP_SYS_ADMIN))
			return -EPERM;
		tmp = vldc_data_qset;
		retval = __get_user(vldc_data_qset, (int __user *)arg);
		if (retval == 0)
			retval = put_user(tmp, (int __user *)arg);
		break;

	  case VLDC_DATA_IOCHQSET:
		if (! capable (CAP_SYS_ADMIN))
			return -EPERM;
		tmp = vldc_data_qset;
		vldc_data_qset = arg;
		return tmp;

        /*
         * The following two change the buffer size for vldc_datapipe.
         * The vldc_datapipe device uses this same ioctl method, just to
         * write less code. Actually, it's the same driver, isn't it?
         */

	  case VLDC_DATA_P_IOCTSIZE:
		vldc_data_p_buffer = arg;
		break;

	  case VLDC_DATA_P_IOCQSIZE:
		return vldc_data_p_buffer;


	  default:  /* redundant, as cmd was checked against MAXNR */
		return -ENOTTY;
	}
	return retval;

}



/*
 * The "extended" operations -- only seek
 */

loff_t vldc_data_llseek(struct file *filp, loff_t off, int whence)
{
	struct vldc_data_dev *dev = filp->private_data;
	loff_t newpos;

	switch(whence) {
	  case 0: /* SEEK_SET */
		newpos = off;
		break;

	  case 1: /* SEEK_CUR */
		newpos = filp->f_pos + off;
		break;

	  case 2: /* SEEK_END */
		newpos = dev->size + off;
		break;

	  default: /* can't happen */
		return -EINVAL;
	}
	if (newpos < 0) return -EINVAL;
	filp->f_pos = newpos;
	return newpos;
}



struct file_operations vldc_data_fops = {
	.owner =    THIS_MODULE,
	.llseek =   vldc_data_llseek,
	.read =     vldc_data_read,
	.write =    vldc_data_write,
	.unlocked_ioctl = vldc_data_ioctl,
	.open =     vldc_data_open,
	.release =  vldc_data_release,
};

/*
 * Finally, the module stuff
 */

/*
 * The cleanup function is used to handle initialization failures as well.
 * Thefore, it must be careful to work correctly even if some of the items
 * have not been initialized
 */
void vldc_data_cleanup_module(void)
{
	int i;
	dev_t devno = MKDEV(vldc_data_major, vldc_data_minor);

	/* Get rid of our char dev entries */
	if (vldc_data_devices) {
		for (i = 0; i < vldc_data_nr_devs; i++) {
			vldc_data_trim(vldc_data_devices + i);
			cdev_del(&vldc_data_devices[i].cdev);
		}
		kfree(vldc_data_devices);
	}

#ifdef VLDC_DATA_DEBUG /* use proc only if debugging */
	vldc_data_remove_proc();
#endif

	/* cleanup_module is never called if registering failed */
	unregister_chrdev_region(devno, vldc_data_nr_devs);

	/* and call the cleanup functions for friend devices */
	vldc_data_p_cleanup();
	vldc_data_access_cleanup();

}


/*
 * Set up the char_dev structure for this device.
 */
static void vldc_data_setup_cdev(struct vldc_data_dev *dev, int index)
{
	int err, devno = MKDEV(vldc_data_major, vldc_data_minor + index);
    
	cdev_init(&dev->cdev, &vldc_data_fops);
	dev->cdev.owner = THIS_MODULE;
	dev->cdev.ops = &vldc_data_fops;
	err = cdev_add (&dev->cdev, devno, 1);
	/* Fail gracefully if need be */
	if (err)
		printk(KERN_NOTICE "Error %d adding vldc_data%d", err, index);
}


int vldc_data_init_module(void)
{
	int result, i;
	dev_t dev = 0;

/*
 * Get a range of minor numbers to work with, asking for a dynamic
 * major unless directed otherwise at load time.
 */
	if (vldc_data_major) {
		dev = MKDEV(vldc_data_major, vldc_data_minor);
		result = register_chrdev_region(dev, vldc_data_nr_devs, "vldc_data");
	} else {
		result = alloc_chrdev_region(&dev, vldc_data_minor, vldc_data_nr_devs,
				"vldc_data");
		vldc_data_major = MAJOR(dev);
	}
	if (result < 0) {
		printk(KERN_WARNING "vldc_data: can't get major %d\n", vldc_data_major);
		return result;
	}

        /* 
	 * allocate the devices -- we can't have them static, as the number
	 * can be specified at load time
	 */
	vldc_data_devices = kmalloc(vldc_data_nr_devs * sizeof(struct vldc_data_dev), GFP_KERNEL);
	if (!vldc_data_devices) {
		result = -ENOMEM;
		goto fail;  /* Make this more graceful */
	}
	memset(vldc_data_devices, 0, vldc_data_nr_devs * sizeof(struct vldc_data_dev));

        /* Initialize each device. */
	for (i = 0; i < vldc_data_nr_devs; i++) {
		vldc_data_devices[i].quantum = vldc_data_quantum;
		vldc_data_devices[i].qset = vldc_data_qset;
		sema_init(&vldc_data_devices[i].sem, 1);
		vldc_data_setup_cdev(&vldc_data_devices[i], i);
	}

        /* At this point call the init function for any friend device */
	dev = MKDEV(vldc_data_major, vldc_data_minor + vldc_data_nr_devs);
	dev += vldc_data_p_init(dev);
	dev += vldc_data_access_init(dev);

#ifdef VLDC_DATA_DEBUG /* only when debugging */
	vldc_data_create_proc();
#endif

	return 0; /* succeed */

  fail:
	vldc_data_cleanup_module();
	return result;
}

module_init(vldc_data_init_module);
module_exit(vldc_data_cleanup_module);
