#include <stdio.h>
#include <pthread.h>

#include <curl/curl.h>
#include <jansson.h>

#define THREAD_NUM 2
#define DATA_NUM 10

#define SLICE_SIZE 16384
#define JSON_SIZE 2048

static int line_counter = 0;

typedef struct _thread_arg {
    int thread_no;
    // int *data;
    char scrollID[2048];
} thread_arg_t;

void thread_func(void *arg) {
    thread_arg_t* targ = (thread_arg_t *)arg;

    char post_data[4096];
    char data_to_write[8192];

    CURL* curl;
    MEMFILE* mf = NULL;
    char* js = NULL;

    FILE *outputfile;

    int line_counter = 0;
    
    char filename[32];
    sprintf(filename,"f%d", targ->thread_no); 

    char ch;
    
    outputfile = fopen(filename, "r"); 

    while( ( ch = fgetc(outputfile) ) != EOF ) {
      // printf("%c", ch);
    }

    printf("thread %d done \n", targ->thread_no);
    
    fclose(outputfile);
}

int main()
{
    pthread_t handle[THREAD_NUM];
    thread_arg_t targ[THREAD_NUM];
    int data[DATA_NUM];
    int i;

    CURL* curl;
    MEMFILE* mf = NULL;
    char* js = NULL;

    char scrollID[2048];
   
    for (i = 0; i < THREAD_NUM; i++) {
        targ[i].thread_no = i;
        // targ[i].data = data;
	
        pthread_create(&handle[i], NULL, (void *)thread_func, (void *)&targ[i]);

    }

    for (i = 0; i < THREAD_NUM; i++)
        pthread_join(handle[i], NULL);
    
    return 0;
}
