#include <stdio.h>
#include <pthread.h>

#include <curl/curl.h>
#include <jansson.h>

#define THREAD_NUM 2
#define DATA_NUM 10

static int SLICE_SIZE = 0;
//#define SLICE_SIZE 3072

#define JSON_SIZE 1024

static int LINE_LIMIT = 0; 
//#define LINE_LIMIT 9000
#define DISP_RATIO 10

static int line_counter = 0;
static int curl_counter = 0;

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

    /*
    if(mf->data[mf->size] != "")
      mf->data[mf->size] = '\n';
    */    

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

    struct timespec startTime, endTime, sleepTime;
    
    FILE *outputfile;

    char filename[32];
    sprintf(filename,"f%d", targ->thread_no); 
    
    outputfile = fopen(filename, "a"); 

    // printf("%s \n", targ->scrollID);

    
    char dispstring[2048];
    
    for(int i = 0; i < 10000; i++)
      {
        memset(post_data, 0, 4096);
        snprintf(post_data, 4096, "{\"scroll\": \"1m\",\"scroll_id\": \"%s\"}", targ->scrollID);

        // printf("%s \n", post_data);

	clock_gettime(CLOCK_REALTIME, &startTime);
	sleepTime.tv_sec = 0;
	sleepTime.tv_nsec = 123;

        mf = memfopen();
	
	curl = curl_easy_init();

        struct curl_slist* headers = NULL;
        headers = curl_slist_append(headers, "Content-Type: application/json");
        curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);

        curl_easy_setopt(curl, CURLOPT_URL, url);
        curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0);
	
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, mf);
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, memfwrite);

        curl_easy_setopt(curl, CURLOPT_POSTFIELDS, post_data);
	
        curl_easy_perform(curl);
        curl_easy_cleanup(curl);

	curl_counter++;

	char date[64];
	time_t t = time(NULL);
	strftime(date, sizeof(date), "%Y/%m/%d %a %H:%M:%S", localtime(&t)); 
	
	clock_gettime(CLOCK_REALTIME, &endTime);
	
	printf("[%s][curl] threadID:%d ", date, targ->thread_no);
	
	if (endTime.tv_nsec < startTime.tv_nsec) {
	  printf("%ld.%09ld", endTime.tv_sec - startTime.tv_sec - 1
		 ,endTime.tv_nsec + 1000000000 - startTime.tv_nsec);
	} else {
	  printf("%ld.%09ld", endTime.tv_sec - startTime.tv_sec
		 ,endTime.tv_nsec - startTime.tv_nsec);
	}
	printf(" sec %d doc counts %d \n", curl_counter, curl_counter * SLICE_SIZE);
	
        char* rest2 = mf->data;
        memset(dispstring, 0, 2048);
        snprintf(dispstring, 2048, "%s", rest2);

	if(line_counter % DISP_RATIO == 0)
	  printf("threadID: %d len(%d) line %d - %s \n", targ->thread_no, mf->size, line_counter, dispstring);

        fprintf(outputfile, rest2);
	fprintf(outputfile, "\n");
	
        line_counter++;

        js = memfstrdup(mf);
        memfclose(mf);

        json_error_t error;
        json_t *result = json_loads(js, 0, &error);
        if (result == NULL) {
          fputs(error.text, stderr);
        }

        free(js);

        strcpy(targ->scrollID, json_string_value(json_object_get(result, "_scroll_id")));

        if(line_counter > LINE_LIMIT)
	  pthread_exit(0);
     }

     fclose(outputfile);

}

int main(int argc, char *argv[]){

    pthread_t handle[THREAD_NUM];
    thread_arg_t targ[THREAD_NUM];
    int data[DATA_NUM];
    int i;

    SLICE_SIZE = atoi(argv[1]);
    LINE_LIMIT = atoi(argv[2]);
    
    CURL* curl;
    MEMFILE* mf = NULL;
    char* js = NULL;

    char scrollID[2048];
    
    static time_t t1,t2;
    static clock_t start, end;
    
    start = clock();
    t1 = time(NULL);    
    
    for (i = 0; i < THREAD_NUM; i++) {
        targ[i].thread_no = i;
        // targ[i].data = data;

        mf = memfopen();
  
        
  
        char post_data[512];
        memset(post_data,0,512);
        sprintf(post_data, "{\"size\": \"%d\",\"slice\": {\"id\":%d,\"max\":%d}}", SLICE_SIZE, 4, 5);
  
        curl = curl_easy_init();
        curl_easy_setopt(curl, CURLOPT_URL, url);

        struct curl_slist* headers = NULL;
        headers = curl_slist_append(headers, "Content-Type: application/json");
        curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
  
        curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, mf);
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, memfwrite);
        curl_easy_setopt(curl, CURLOPT_POSTFIELDS, post_data);
        curl_easy_perform(curl);
        curl_easy_cleanup(curl);

        js = memfstrdup(mf);
        memfclose(mf);

        json_error_t error;
        json_t *result = json_loads(js, 0, &error);
        if (result == NULL) {
          fputs(error.text, stderr);
        }

        free(js);

        strcpy(scrollID, json_string_value(json_object_get(result, "_scroll_id")));
        printf("%s len(%d) \n", scrollID, strlen(scrollID));

        sprintf(targ[i].scrollID, "%s", scrollID);     
        pthread_create(&handle[i], NULL, (void *)thread_func, (void *)&targ[i]);

    }

    for (i = 0; i < THREAD_NUM; i++)
        pthread_join(handle[i], NULL);

    t2 = time(NULL);
    end = clock();


    printf("SLICE SIZE %d \n", SLICE_SIZE);
    printf("LINE LIMIT %d \n", LINE_LIMIT);
    printf("time = %d[s]\n", (int)(t2-t1));
    printf( "elapsed time:%d[ms]\n", end - start );
    
}
