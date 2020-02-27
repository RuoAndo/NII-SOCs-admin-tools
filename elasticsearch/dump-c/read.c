#include <stdio.h>
#include <pthread.h>

#include <curl/curl.h>
#include <jansson.h>

#define THREAD_NUM 2
#define DATA_NUM 10

static int SLICE_SIZE = 0;
static int LINE_SIZE = 0;
// #define SLICE_SIZE 1024
#define JSON_SIZE 2048

static int line_counter = 0;
static int LINE_LIMIT = 0;

typedef struct _thread_arg {
    int thread_no;
    // int *data;
    char scrollID[2048];
} thread_arg_t;


typedef struct {
  char* data;   // response data from server
  size_t size;  // response size of data
} MEMFILE;


MEMFILE*
memfopen() {
  MEMFILE* mf = (MEMFILE*) malloc(sizeof(MEMFILE));
  if (mf) {
    mf->data = NULL;
    mf->size = 0;
  }
  return mf;
}

void
memfclose(MEMFILE* mf) {
  if (mf->data) free(mf->data);
  free(mf);
}

size_t
memfwrite(char* ptr, size_t size, size_t nmemb, void* stream) {
  MEMFILE* mf = (MEMFILE*) stream;
  int block = size * nmemb;

  if (!mf) return block; // through
  
  if (!mf->data)
    {
      mf->data = (char*) malloc(block);
      // mf->data = (char*) malloc(strlen(mf->data));
    }
    
  else
    mf->data = (char*) realloc(mf->data, mf->size + block);
  
  if (mf->data) {
    memcpy(mf->data + mf->size, ptr, block);
    mf->size += block;
  }
  return block;
}

char*
memfstrdup(MEMFILE* mf) {
  char* buf;
  if (mf->size == 0) return NULL;
  buf = (char*) malloc(mf->size + 1);
  memcpy(buf, mf->data, mf->size);
  buf[mf->size] = 0;
  return buf;
}

void thread_func(void *arg) {
    thread_arg_t* targ = (thread_arg_t *)arg;

    char post_data[4096];
    char data_to_write[8192];

    CURL* curl;
    MEMFILE* mf = NULL;
    char* js = NULL;

    FILE *outputfile;

    int line_counter = 0;
    int i;
    
    char filename[32];
    sprintf(filename,"f%d", targ->thread_no); 

    char ch;
    char buffer[SLICE_SIZE * JSON_SIZE * LINE_SIZE];
    
    outputfile = fopen(filename, "r"); 

    while( ( ch = fgetc(outputfile) ) != EOF ) {
      // printf("%c", ch);
    }

    /*
    while(fgets(buffer, 2048, outputfile) != NULL) {
    }
    */
    
    // while(fgets(buffer, SLICE_SIZE * JSON_SIZE * LINE_SIZE, outputfile) != NULL) {
      
      // printf("%s", buffer);

      /*
      json_error_t error;
      json_t *result = json_loads(buffer, 0, &error);
      if (result == NULL) {
	fputs(error.text, stderr);
      }
	      
      json_t *repositories = json_object_get(result, "hits");
      
      json_t *value;
      const char *key;

      json_t *value_source;
      const char *key_source;

      json_t *hits;
      json_t *hits_inside;
	    
      json_object_foreach(repositories,key,value){

	json_t *hits = json_object_get(repositories, "hits"); 

	
	json_array_foreach(hits,i,hits_inside){

	  json_t *repositories_source = json_object_get(hits_inside, "_source");
	  json_t *capture_time = json_object_get(repositories_source, "capture_time");
	  json_t *bytes = json_object_get(repositories_source, "bytes");

	  printf("%s,%s \n", json_string_value(capture_time), json_string_value(bytes));
	}
	
      }
      */

      /*
      if(line_counter > LINE_LIMIT)
	pthread_exit(0);
      */      

      // line_counter++;
     
    // }
      
    printf("thread %d done \n", targ->thread_no);
    
    fclose(outputfile);
}
   
int main(int argc, char *argv[]){

    pthread_t handle[THREAD_NUM];
    thread_arg_t targ[THREAD_NUM];
    int data[DATA_NUM];
    int i;

    CURL* curl;
    MEMFILE* mf = NULL;
    char* js = NULL;

    char scrollID[2048];

    // SLICE_SIZE = atoi(argv[1]);
    // LINE_SIZE = atoi(argv[2]);
    
    clock_t start,end;
    start = clock();
    
    for (i = 0; i < THREAD_NUM; i++) {
        targ[i].thread_no = i;
        // targ[i].data = data;

        pthread_create(&handle[i], NULL, (void *)thread_func, (void *)&targ[i]);

    }

    for (i = 0; i < THREAD_NUM; i++)
        pthread_join(handle[i], NULL);

    // printf("LINE LIMIT %d \n", LINE_LIMIT);

    end = clock();
    printf("%.2f sec \n",(double)(end-start)/CLOCKS_PER_SEC);
    
    return 0;
}
