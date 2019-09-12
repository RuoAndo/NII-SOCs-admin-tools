#include "spdk/stdinc.h"

#include "spdk/nvme.h"
#include "spdk/vmd.h"
#include "spdk/env.h"
#include <time.h>

struct ctrlr_entry {
	struct spdk_nvme_ctrlr	*ctrlr;
	struct ctrlr_entry	*next;
	char			name[1024];
};

struct ns_entry {
	struct spdk_nvme_ctrlr	*ctrlr;
	struct spdk_nvme_ns	*ns;
	struct ns_entry		*next;
	struct spdk_nvme_qpair	*qpair;
};

typedef struct _thread_arg {
    int thread_no;
    int *data;
} thread_arg_t;

static struct ctrlr_entry *g_controllers = NULL;
static struct ns_entry *g_namespaces = NULL;

static bool g_vmd = false;

static void
register_ns(struct spdk_nvme_ctrlr *ctrlr, struct spdk_nvme_ns *ns)
{
	struct ns_entry *entry;
	const struct spdk_nvme_ctrlr_data *cdata;

	cdata = spdk_nvme_ctrlr_get_data(ctrlr);

	if (!spdk_nvme_ns_is_active(ns)) {
		printf("Controller %-20.20s (%-20.20s): Skipping inactive NS %u\n",
		       cdata->mn, cdata->sn,
		       spdk_nvme_ns_get_id(ns));
		return;
	}

	entry = malloc(sizeof(struct ns_entry));
	if (entry == NULL) {
		perror("ns_entry malloc");
		exit(1);
	}

	entry->ctrlr = ctrlr;
	entry->ns = ns;
	entry->next = g_namespaces;
	g_namespaces = entry;

	printf("  Namespace ID: %d size: %juGB\n", spdk_nvme_ns_get_id(ns),
	       spdk_nvme_ns_get_size(ns) / 1000000000);
}

struct write_sequence {
	struct ns_entry	*ns_entry;
	char		*buf;
	unsigned        using_cmb_io;
	int		is_completed;
        int             counter; 
};

static void
write_complete(void *arg, const struct spdk_nvme_cpl *completion)
{
	struct write_sequence	        *sequence = arg;
	struct ns_entry			*ns_entry = sequence->ns_entry;
	int				rc;

	if (spdk_nvme_cpl_is_error(completion)) {
		spdk_nvme_qpair_print_completion(sequence->ns_entry->qpair, (struct spdk_nvme_cpl *)completion);
		fprintf(stderr, "I/O error status: %s\n", spdk_nvme_cpl_get_status_string(&completion->status));
		fprintf(stderr, "Write I/O failed, aborting run\n");
		sequence->is_completed = 2;
		exit(1);
	}
	else
	  {
	    sequence->is_completed = 1;
	    sequence->counter++;
	    // fprintf(stderr, "write_complete() done. \n");
	  }	
}

static void
thread_func(void *arg)
{
        struct ns_entry			*ns_entry;
	struct write_sequence	        sequence;
	int				rc;

	long int elapsed_time_1;
	long int elapsed_time_2;
	
	thread_arg_t* targ = (thread_arg_t *)arg;

	struct timespec startTime, endTime, sleepTime;

	clock_gettime(CLOCK_REALTIME, &startTime);
	sleepTime.tv_sec = 0;
	sleepTime.tv_nsec = 123;
		
	ns_entry = g_namespaces;
	while (ns_entry != NULL) {
		ns_entry->qpair = spdk_nvme_ctrlr_alloc_io_qpair(ns_entry->ctrlr, NULL, 0);
		if (ns_entry->qpair == NULL) {
			printf("ERROR: spdk_nvme_ctrlr_alloc_io_qpair() failed\n");
			return;
		}

		sequence.using_cmb_io = 1;
		sequence.buf = spdk_nvme_ctrlr_alloc_cmb_io_buffer(ns_entry->ctrlr, 0x1000);
		if (sequence.buf == NULL) {
			sequence.using_cmb_io = 0;
			sequence.buf = spdk_zmalloc(0x1000, 0x1000, NULL, SPDK_ENV_SOCKET_ID_ANY, SPDK_MALLOC_DMA);
		}
		if (sequence.buf == NULL) {
			printf("ERROR: write buffer allocation failed\n");
			return;
		}
		if (sequence.using_cmb_io) {
			printf("INFO: using controller memory buffer for IO\n");
		} else {
		        printf("INFO: thread %d using host memory buffer for IO\n", targ->thread_no);
		}
		sequence.is_completed = 0;
		sequence.ns_entry = ns_entry;

		snprintf(sequence.buf, 0x1000, "[%d]%s", targ->thread_no, "Hello world!\n");

		    int rc = spdk_nvme_ns_cmd_write(ns_entry->ns, ns_entry->qpair, sequence.buf,
						    targ->thread_no, /* LBA start */
						    1, /* number of LBAs */
						    write_complete, &sequence, 0);
		    if (rc != 0) {
		      fprintf(stderr, "starting write I/O failed\n");
		      exit(1);
		    }

		    while (!sequence.is_completed) {
		      spdk_nvme_qpair_process_completions(ns_entry->qpair, 0);
		    }		
		    spdk_nvme_ctrlr_free_io_qpair(ns_entry->qpair);

		ns_entry = ns_entry->next;
	}

	clock_gettime(CLOCK_REALTIME, &endTime);

	// printf("開始時刻　 = %10ld.%09ld\n", startTime.tv_sec, startTime.tv_nsec);
	// printf("終了時刻　 = %10ld.%09ld\n", endTime.tv_sec, endTime.tv_nsec);
	
	// printf("経過実時間 = ");
	if (endTime.tv_nsec < startTime.tv_nsec) {
	  elapsed_time_1 = endTime.tv_sec - startTime.tv_sec - 1;
	  elapsed_time_2 = endTime.tv_nsec + 1000000000 - startTime.tv_nsec;
	} else {
	  elapsed_time_1 = endTime.tv_sec - startTime.tv_sec;
	  elapsed_time_2 = endTime.tv_nsec - startTime.tv_nsec;
	}
       		
	printf("THREAD ID %d done. - %10ld.%09ld (sec) \n", targ->thread_no, elapsed_time_1, elapsed_time_2);

}

static bool
probe_cb(void *cb_ctx, const struct spdk_nvme_transport_id *trid,
	 struct spdk_nvme_ctrlr_opts *opts)
{
	printf("Attaching to %s\n", trid->traddr);

	return true;
}

static void
attach_cb(void *cb_ctx, const struct spdk_nvme_transport_id *trid,
	  struct spdk_nvme_ctrlr *ctrlr, const struct spdk_nvme_ctrlr_opts *opts)
{
	int nsid, num_ns;
	struct ctrlr_entry *entry;
	struct spdk_nvme_ns *ns;
	const struct spdk_nvme_ctrlr_data *cdata = spdk_nvme_ctrlr_get_data(ctrlr);

	entry = malloc(sizeof(struct ctrlr_entry));
	if (entry == NULL) {
		perror("ctrlr_entry malloc");
		exit(1);
	}

	printf("Attached to %s\n", trid->traddr);

	snprintf(entry->name, sizeof(entry->name), "%-20.20s (%-20.20s)", cdata->mn, cdata->sn);

	entry->ctrlr = ctrlr;
	entry->next = g_controllers;
	g_controllers = entry;

	num_ns = spdk_nvme_ctrlr_get_num_ns(ctrlr);
	printf("Using controller %s with %d namespaces.\n", entry->name, num_ns);
	for (nsid = 1; nsid <= num_ns; nsid++) {
		ns = spdk_nvme_ctrlr_get_ns(ctrlr, nsid);
		if (ns == NULL) {
			continue;
		}
		register_ns(ctrlr, ns);
	}
}

static void
cleanup(void)
{
	struct ns_entry *ns_entry = g_namespaces;
	struct ctrlr_entry *ctrlr_entry = g_controllers;

	while (ns_entry) {
		struct ns_entry *next = ns_entry->next;
		free(ns_entry);
		ns_entry = next;
	}

	while (ctrlr_entry) {
		struct ctrlr_entry *next = ctrlr_entry->next;

		spdk_nvme_detach(ctrlr_entry->ctrlr);
		free(ctrlr_entry);
		ctrlr_entry = next;
	}

	printf("cleanup() done. \n");
	
}

int main(int argc, char **argv)
{
	int rc;
	struct spdk_env_opts opts;

	int THREAD_NUM = 100;
	
	pthread_t handle[THREAD_NUM];
	thread_arg_t targ[THREAD_NUM];
	
	spdk_env_opts_init(&opts);
	opts.name = "hello_world";
	opts.shm_id = 0;
	if (spdk_env_init(&opts) < 0) {
		fprintf(stderr, "Unable to initialize SPDK env\n");
		return 1;
	}

	printf("Initializing NVMe Controllers\n");

	if (g_vmd && spdk_vmd_init()) {
		fprintf(stderr, "Failed to initialize VMD."
			" Some NVMe devices can be unavailable.\n");
	}

	rc = spdk_nvme_probe(NULL, NULL, probe_cb, attach_cb, NULL);
	if (rc != 0) {
		fprintf(stderr, "spdk_nvme_probe() failed\n");
		cleanup();
		return 1;
	}

	if (g_controllers == NULL) {
		fprintf(stderr, "no NVMe controllers found\n");
		cleanup();
		return 1;
	}

	printf("Initialization complete.\n");

	for (int i = 0; i < THREAD_NUM; i++) {
	  targ[i].thread_no = i;        
	  pthread_create(&handle[i], NULL, (void *)thread_func, (void *)&targ[i]);
	}

	for (int i = 0; i < THREAD_NUM; i++)
	  pthread_join(handle[i], NULL);

	cleanup();
	return 0;
}
