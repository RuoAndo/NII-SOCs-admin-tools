/*
 * vldc_data.h -- definitions for the char module
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
 * $Id: vldc_data.h,v 1.15 2004/11/04 17:51:18 rubini Exp $
 */

#ifndef _VLDC_DATA_H_
#define _VLDC_DATA_H_

#include <linux/ioctl.h> /* needed for the _IOW etc stuff used later */

/*
 * Macros to help debugging
 */

#undef PDEBUG             /* undef it, just in case */
#ifdef VLDC_DATA_DEBUG
#  ifdef __KERNEL__
     /* This one if debugging is on, and kernel space */
#    define PDEBUG(fmt, args...) printk( KERN_DEBUG "vldc_data: " fmt, ## args)
#  else
     /* This one for user space */
#    define PDEBUG(fmt, args...) fprintf(stderr, fmt, ## args)
#  endif
#else
#  define PDEBUG(fmt, args...) /* not debugging: nothing */
#endif

#undef PDEBUGG
#define PDEBUGG(fmt, args...) /* nothing: it's a placeholder */

#ifndef VLDC_DATA_MAJOR
#define VLDC_DATA_MAJOR 0   /* dynamic major by default */
#endif

#ifndef VLDC_DATA_NR_DEVS
<<<<<<< HEAD
#define VLDC_DATA_NR_DEVS 1589    /* vldc_data0 through vldc_data3 */
#endif

#ifndef VLDC_DATA_P_NR_DEVS
#define VLDC_DATA_P_NR_DEVS 1589  /* vldc_datapipe0 through vldc_datapipe3 */
=======
#define VLDC_DATA_NR_DEVS 2000    /* vldc_data0 through vldc_data3 */
#endif

#ifndef VLDC_DATA_P_NR_DEVS
#define VLDC_DATA_P_NR_DEVS 2000  /* vldc_datapipe0 through vldc_datapipe3 */
>>>>>>> 816c3d96107606a7228acd00dbba2a6b1699daef
#endif

/*
 * The bare device is a variable-length region of memory.
 * Use a linked list of indirect blocks.
 *
 * "vldc_data_dev->data" points to an array of pointers, each
 * pointer refers to a memory area of VLDC_DATA_QUANTUM bytes.
 *
 * The array (quantum-set) is VLDC_DATA_QSET long.
 */
#ifndef VLDC_DATA_QUANTUM
#define VLDC_DATA_QUANTUM 4000
#endif

#ifndef VLDC_DATA_QSET
#define VLDC_DATA_QSET    1000
#endif

/*
 * The pipe device is a simple circular buffer. Here its default size
 */
#ifndef VLDC_DATA_P_BUFFER
#define VLDC_DATA_P_BUFFER 4000
#endif

/*
 * Representation of vldc_data quantum sets.
 */
struct vldc_data_qset {
	void **data;
	struct vldc_data_qset *next;
};

struct vldc_data_dev {
	struct vldc_data_qset *data;  /* Pointer to first quantum set */
	int quantum;              /* the current quantum size */
	int qset;                 /* the current array size */
	unsigned long size;       /* amount of data stored here */
	unsigned int access_key;  /* used by vldc_datauid and vldc_datapriv */
	struct semaphore sem;     /* mutual exclusion semaphore     */
	struct cdev cdev;	  /* Char device structure		*/
};

/*
 * Split minors in two parts
 */
#define TYPE(minor)	(((minor) >> 4) & 0xf)	/* high nibble */
#define NUM(minor)	((minor) & 0xf)		/* low  nibble */


/*
 * The different configurable parameters
 */
extern int vldc_data_major;     /* main.c */
extern int vldc_data_nr_devs;
extern int vldc_data_quantum;
extern int vldc_data_qset;

extern int vldc_data_p_buffer;	/* pipe.c */


/*
 * Prototypes for shared functions
 */

int     vldc_data_p_init(dev_t dev);
void    vldc_data_p_cleanup(void);
int     vldc_data_access_init(dev_t dev);
void    vldc_data_access_cleanup(void);

int     vldc_data_trim(struct vldc_data_dev *dev);

ssize_t vldc_data_read(struct file *filp, char __user *buf, size_t count,
                   loff_t *f_pos);
ssize_t vldc_data_write(struct file *filp, const char __user *buf, size_t count,
                    loff_t *f_pos);
loff_t  vldc_data_llseek(struct file *filp, loff_t off, int whence);
long     vldc_data_ioctl(struct file *filp, unsigned int cmd, unsigned long arg);


/*
 * Ioctl definitions
 */

/* Use 'k' as magic number */
#define VLDC_DATA_IOC_MAGIC  'k'
/* Please use a different 8-bit number in your code */

#define VLDC_DATA_IOCRESET    _IO(VLDC_DATA_IOC_MAGIC, 0)

/*
 * S means "Set" through a ptr,
 * T means "Tell" directly with the argument value
 * G means "Get": reply by setting through a pointer
 * Q means "Query": response is on the return value
 * X means "eXchange": switch G and S atomically
 * H means "sHift": switch T and Q atomically
 */
#define VLDC_DATA_IOCSQUANTUM _IOW(VLDC_DATA_IOC_MAGIC,  1, int)
#define VLDC_DATA_IOCSQSET    _IOW(VLDC_DATA_IOC_MAGIC,  2, int)
#define VLDC_DATA_IOCTQUANTUM _IO(VLDC_DATA_IOC_MAGIC,   3)
#define VLDC_DATA_IOCTQSET    _IO(VLDC_DATA_IOC_MAGIC,   4)
#define VLDC_DATA_IOCGQUANTUM _IOR(VLDC_DATA_IOC_MAGIC,  5, int)
#define VLDC_DATA_IOCGQSET    _IOR(VLDC_DATA_IOC_MAGIC,  6, int)
#define VLDC_DATA_IOCQQUANTUM _IO(VLDC_DATA_IOC_MAGIC,   7)
#define VLDC_DATA_IOCQQSET    _IO(VLDC_DATA_IOC_MAGIC,   8)
#define VLDC_DATA_IOCXQUANTUM _IOWR(VLDC_DATA_IOC_MAGIC, 9, int)
#define VLDC_DATA_IOCXQSET    _IOWR(VLDC_DATA_IOC_MAGIC,10, int)
#define VLDC_DATA_IOCHQUANTUM _IO(VLDC_DATA_IOC_MAGIC,  11)
#define VLDC_DATA_IOCHQSET    _IO(VLDC_DATA_IOC_MAGIC,  12)

/*
 * The other entities only have "Tell" and "Query", because they're
 * not printed in the book, and there's no need to have all six.
 * (The previous stuff was only there to show different ways to do it.
 */
#define VLDC_DATA_P_IOCTSIZE _IO(VLDC_DATA_IOC_MAGIC,   13)
#define VLDC_DATA_P_IOCQSIZE _IO(VLDC_DATA_IOC_MAGIC,   14)
/* ... more to come */

#define VLDC_DATA_IOC_MAXNR 14

#endif /* _VLDC_DATA_H_ */
