 /*
 * pipe.c -- fifo driver for vldc_relabel
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

#include <linux/kernel.h>	/* printk(), min() */
#include <linux/slab.h>		/* kmalloc() */
#include <linux/fs.h>		/* everything... */
#include <linux/proc_fs.h>
#include <linux/errno.h>	/* error codes */
#include <linux/types.h>	/* size_t */
#include <linux/fcntl.h>
#include <linux/poll.h>
#include <linux/cdev.h>
#include <asm/uaccess.h>
#include <linux/sched.h>
#include <linux/seq_file.h>

#include "vldc_relabel.h"		/* local definitions */

struct vldc_relabel_pipe {
        wait_queue_head_t inq, outq;       /* read and write queues */
        char *buffer, *end;                /* begin of buf, end of buf */
        int buffersize;                    /* used in pointer arithmetic */
        char *rp, *wp;                     /* where to read, where to write */
        int nreaders, nwriters;            /* number of openings for r/w */
        struct fasync_struct *async_queue; /* asynchronous readers */
        struct semaphore sem;              /* mutual exclusion semaphore */
        struct cdev cdev;                  /* Char device structure */
};

/* parameters */
static int vldc_relabel_p_nr_devs = VLDC_RELABEL_P_NR_DEVS;	/* number of pipe devices */
int vldc_relabel_p_buffer =  VLDC_RELABEL_P_BUFFER;	/* buffer size */
dev_t vldc_relabel_p_devno;			/* Our first device number */

module_param(vldc_relabel_p_nr_devs, int, 0);	/* FIXME check perms */
module_param(vldc_relabel_p_buffer, int, 0);

static struct vldc_relabel_pipe *vldc_relabel_p_devices;

static int vldc_relabel_p_fasync(int fd, struct file *filp, int mode);
static int spacefree(struct vldc_relabel_pipe *dev);
/*
 * Open and close
 */


static int vldc_relabel_p_open(struct inode *inode, struct file *filp)
{
	struct vldc_relabel_pipe *dev;

	dev = container_of(inode->i_cdev, struct vldc_relabel_pipe, cdev);
	filp->private_data = dev;

	if (down_interruptible(&dev->sem))
		return -ERESTARTSYS;
	if (!dev->buffer) {
		/* allocate the buffer */
		dev->buffer = kmalloc(vldc_relabel_p_buffer, GFP_KERNEL);
		if (!dev->buffer) {
			up(&dev->sem);
			return -ENOMEM;
		}
	}
	dev->buffersize = vldc_relabel_p_buffer;
	dev->end = dev->buffer + dev->buffersize;
	dev->rp = dev->wp = dev->buffer; /* rd and wr from the beginning */

	/* use f_mode,not  f_flags: it's cleaner (fs/open.c tells why) */
	if (filp->f_mode & FMODE_READ)
		dev->nreaders++;
	if (filp->f_mode & FMODE_WRITE)
		dev->nwriters++;
	up(&dev->sem);

	return nonseekable_open(inode, filp);
}



static int vldc_relabel_p_release(struct inode *inode, struct file *filp)
{
	struct vldc_relabel_pipe *dev = filp->private_data;

	/* remove this filp from the asynchronously notified filp's */
	vldc_relabel_p_fasync(-1, filp, 0);
	down(&dev->sem);
	if (filp->f_mode & FMODE_READ)
		dev->nreaders--;
	if (filp->f_mode & FMODE_WRITE)
		dev->nwriters--;
	if (dev->nreaders + dev->nwriters == 0) {
		kfree(dev->buffer);
		dev->buffer = NULL; /* the other fields are not checked on open */
	}
	up(&dev->sem);
	return 0;
}


/*
 * Data management: read and write
 */

static ssize_t vldc_relabel_p_read (struct file *filp, char __user *buf, size_t count,
                loff_t *f_pos)
{
	struct vldc_relabel_pipe *dev = filp->private_data;

	if (down_interruptible(&dev->sem))
		return -ERESTARTSYS;

	while (dev->rp == dev->wp) { /* nothing to read */
		up(&dev->sem); /* release the lock */
		if (filp->f_flags & O_NONBLOCK)
			return -EAGAIN;
		PDEBUG("\"%s\" reading: going to sleep\n", current->comm);
		if (wait_event_interruptible(dev->inq, (dev->rp != dev->wp)))
			return -ERESTARTSYS; /* signal: tell the fs layer to handle it */
		/* otherwise loop, but first reacquire the lock */
		if (down_interruptible(&dev->sem))
			return -ERESTARTSYS;
	}
	/* ok, data is there, return something */
	if (dev->wp > dev->rp)
		count = min(count, (size_t)(dev->wp - dev->rp));
	else /* the write pointer has wrapped, return data up to dev->end */
		count = min(count, (size_t)(dev->end - dev->rp));
	if (copy_to_user(buf, dev->rp, count)) {
		up (&dev->sem);
		return -EFAULT;
	}
	dev->rp += count;
	if (dev->rp == dev->end)
		dev->rp = dev->buffer; /* wrapped */
	up (&dev->sem);

	/* finally, awake any writers and return */
	wake_up_interruptible(&dev->outq);
	PDEBUG("\"%s\" did read %li bytes\n",current->comm, (long)count);
	return count;
}

/* Wait for space for writing; caller must hold device semaphore.  On
 * error the semaphore will be released before returning. */
static int vldc_relabel_getwritespace(struct vldc_relabel_pipe *dev, struct file *filp)
{
	while (spacefree(dev) == 0) { /* full */
		DEFINE_WAIT(wait);
		
		up(&dev->sem);
		if (filp->f_flags & O_NONBLOCK)
			return -EAGAIN;
		PDEBUG("\"%s\" writing: going to sleep\n",current->comm);
		prepare_to_wait(&dev->outq, &wait, TASK_INTERRUPTIBLE);
		if (spacefree(dev) == 0)
			schedule();
		finish_wait(&dev->outq, &wait);
		if (signal_pending(current))
			return -ERESTARTSYS; /* signal: tell the fs layer to handle it */
		if (down_interruptible(&dev->sem))
			return -ERESTARTSYS;
	}
	return 0;
}	

/* How much space is free? */
static int spacefree(struct vldc_relabel_pipe *dev)
{
	if (dev->rp == dev->wp)
		return dev->buffersize - 1;
	return ((dev->rp + dev->buffersize - dev->wp) % dev->buffersize) - 1;
}

static ssize_t vldc_relabel_p_write(struct file *filp, const char __user *buf, size_t count,
                loff_t *f_pos)
{
	struct vldc_relabel_pipe *dev = filp->private_data;
	int result;

	if (down_interruptible(&dev->sem))
		return -ERESTARTSYS;

	/* Make sure there's space to write */
	result = vldc_relabel_getwritespace(dev, filp);
	if (result)
		return result; /* vldc_relabel_getwritespace called up(&dev->sem) */

	/* ok, space is there, accept something */
	count = min(count, (size_t)spacefree(dev));
	if (dev->wp >= dev->rp)
		count = min(count, (size_t)(dev->end - dev->wp)); /* to end-of-buf */
	else /* the write pointer has wrapped, fill up to rp-1 */
		count = min(count, (size_t)(dev->rp - dev->wp - 1));
	PDEBUG("Going to accept %li bytes to %p from %p\n", (long)count, dev->wp, buf);
	if (copy_from_user(dev->wp, buf, count)) {
		up (&dev->sem);
		return -EFAULT;
	}
	dev->wp += count;
	if (dev->wp == dev->end)
		dev->wp = dev->buffer; /* wrapped */
	up(&dev->sem);

	/* finally, awake any reader */
	wake_up_interruptible(&dev->inq);  /* blocked in read() and select() */

	/* and signal asynchronous readers, explained late in chapter 5 */
	if (dev->async_queue)
		kill_fasync(&dev->async_queue, SIGIO, POLL_IN);
	PDEBUG("\"%s\" did write %li bytes\n",current->comm, (long)count);
	return count;
}

static unsigned int vldc_relabel_p_poll(struct file *filp, poll_table *wait)
{
	struct vldc_relabel_pipe *dev = filp->private_data;
	unsigned int mask = 0;

	/*
	 * The buffer is circular; it is considered full
	 * if "wp" is right behind "rp" and empty if the
	 * two are equal.
	 */
	down(&dev->sem);
	poll_wait(filp, &dev->inq,  wait);
	poll_wait(filp, &dev->outq, wait);
	if (dev->rp != dev->wp)
		mask |= POLLIN | POLLRDNORM;	/* readable */
	if (spacefree(dev))
		mask |= POLLOUT | POLLWRNORM;	/* writable */
	up(&dev->sem);
	return mask;
}





static int vldc_relabel_p_fasync(int fd, struct file *filp, int mode)
{
	struct vldc_relabel_pipe *dev = filp->private_data;

	return fasync_helper(fd, filp, mode, &dev->async_queue);
}



/* FIXME this should use seq_file */
#ifdef VLDC_RELABEL_DEBUG

static int vldc_relabel_read_p_mem(struct seq_file *s, void *v)
{
	int i;
	struct vldc_relabel_pipe *p;

#define LIMIT (PAGE_SIZE-200)        /* don't print any more after this size */
	seq_printf(s, "Default buffersize is %i\n", vldc_relabel_p_buffer);
	for(i = 0; i<vldc_relabel_p_nr_devs && s->count <= LIMIT; i++) {
		p = &vldc_relabel_p_devices[i];
		if (down_interruptible(&p->sem))
			return -ERESTARTSYS;
		seq_printf(s, "\nDevice %i: %p\n", i, p);
/*		seq_printf(s, "   Queues: %p %p\n", p->inq, p->outq);*/
		seq_printf(s, "   Buffer: %p to %p (%i bytes)\n", p->buffer, p->end, p->buffersize);
		seq_printf(s, "   rp %p   wp %p\n", p->rp, p->wp);
		seq_printf(s, "   readers %i   writers %i\n", p->nreaders, p->nwriters);
		up(&p->sem);
	}
	return 0;
}

static int vldc_relabelpipe_proc_open(struct inode *inode, struct file *file)
{
	return single_open(file, vldc_relabel_read_p_mem, NULL);
}

static struct file_operations vldc_relabelpipe_proc_ops = {
	.owner   = THIS_MODULE,
	.open    = vldc_relabelpipe_proc_open,
	.read    = seq_read,
	.llseek  = seq_lseek,
	.release = single_release
};

#endif



/*
 * The file operations for the pipe device
 * (some are overlayed with bare vldc_relabel)
 */
struct file_operations vldc_relabel_pipe_fops = {
	.owner =	THIS_MODULE,
	.llseek =	no_llseek,
	.read =		vldc_relabel_p_read,
	.write =	vldc_relabel_p_write,
	.poll =		vldc_relabel_p_poll,
	.unlocked_ioctl = vldc_relabel_ioctl,
	.open =		vldc_relabel_p_open,
	.release =	vldc_relabel_p_release,
	.fasync =	vldc_relabel_p_fasync,
};


/*
 * Set up a cdev entry.
 */
static void vldc_relabel_p_setup_cdev(struct vldc_relabel_pipe *dev, int index)
{
	int err, devno = vldc_relabel_p_devno + index;
    
	cdev_init(&dev->cdev, &vldc_relabel_pipe_fops);
	dev->cdev.owner = THIS_MODULE;
	err = cdev_add (&dev->cdev, devno, 1);
	/* Fail gracefully if need be */
	if (err)
		printk(KERN_NOTICE "Error %d adding vldc_relabelpipe%d", err, index);
}

 

/*
 * Initialize the pipe devs; return how many we did.
 */
int vldc_relabel_p_init(dev_t firstdev)
{
	int i, result;

	result = register_chrdev_region(firstdev, vldc_relabel_p_nr_devs, "vldc_relabelp");
	if (result < 0) {
		printk(KERN_NOTICE "Unable to get vldc_relabelp region, error %d\n", result);
		return 0;
	}
	vldc_relabel_p_devno = firstdev;
	vldc_relabel_p_devices = kmalloc(vldc_relabel_p_nr_devs * sizeof(struct vldc_relabel_pipe), GFP_KERNEL);
	if (vldc_relabel_p_devices == NULL) {
		unregister_chrdev_region(firstdev, vldc_relabel_p_nr_devs);
		return 0;
	}
	memset(vldc_relabel_p_devices, 0, vldc_relabel_p_nr_devs * sizeof(struct vldc_relabel_pipe));
	for (i = 0; i < vldc_relabel_p_nr_devs; i++) {
		init_waitqueue_head(&(vldc_relabel_p_devices[i].inq));
		init_waitqueue_head(&(vldc_relabel_p_devices[i].outq));
		sema_init(&vldc_relabel_p_devices[i].sem, 1);
		vldc_relabel_p_setup_cdev(vldc_relabel_p_devices + i, i);
	}
#ifdef VLDC_RELABEL_DEBUG
	proc_create("vldc_relabelpipe", 0, NULL, &vldc_relabelpipe_proc_ops);
#endif
	return vldc_relabel_p_nr_devs;
}

/*
 * This is called by cleanup_module or on failure.
 * It is required to never fail, even if nothing was initialized first
 */
void vldc_relabel_p_cleanup(void)
{
	int i;

#ifdef VLDC_RELABEL_DEBUG
	remove_proc_entry("vldc_relabelpipe", NULL);
#endif

	if (!vldc_relabel_p_devices)
		return; /* nothing else to release */

	for (i = 0; i < vldc_relabel_p_nr_devs; i++) {
		cdev_del(&vldc_relabel_p_devices[i].cdev);
		kfree(vldc_relabel_p_devices[i].buffer);
	}
	kfree(vldc_relabel_p_devices);
	unregister_chrdev_region(vldc_relabel_p_devno, vldc_relabel_p_nr_devs);
	vldc_relabel_p_devices = NULL; /* pedantic */
}
