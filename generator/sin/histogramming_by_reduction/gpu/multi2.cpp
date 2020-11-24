#include <string>
#include <cstring>
#include <cctype>
#include <cstdlib>
#include <cstdio>
#include <iostream>
#include <fstream>
#include <bitset>

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <dirent.h>
#include <pthread.h>
#include <alloca.h>

#include <sys/socket.h>
#include <sys/time.h>
#include <netinet/in.h>
#include <arpa/inet.h>   

#include "tbb/concurrent_hash_map.h"
#include "tbb/blocked_range.h"
#include "tbb/parallel_for.h"
#include "tbb/tick_count.h"
#include "tbb/task_scheduler_init.h"
#include "tbb/concurrent_vector.h"
#include "utility.h"

#include "csv.hpp"
#include "timer.h"

using namespace std;
using namespace tbb;

// 2 / 1024

// CPU (-1) actural number of CPU (threads) is +1, 4->3 
#define WORKER_THREAD_NUM_CPU 2
// GPU (-1) actural number of GPU is +1
#define WORKER_THREAD_NUM_GPU 2

#define MAX_QUEUE_NUM 6
#define END_MARK_FNAME   "///"
#define END_MARK_FLENGTH 3

extern void kernel(long* h_key, long* h_value_1, long* h_value_2, string filename, int size);
extern void transfer(unsigned long long *key, long *value, unsigned long long *key_out, long *value_out, int kBytes, int vBytes, size_t data_size, int* new_size, int thread_id);

typedef tbb::concurrent_hash_map<unsigned long long, int> iTbb_Vec_timestamp;
static iTbb_Vec_timestamp TbbVec_timestamp; 

typedef tbb::concurrent_hash_map<unsigned long long, std::vector<int>> iTbb_Vec_timestamp_thread_1;
static iTbb_Vec_timestamp_thread_1 TbbVec_timestamp_thread_1;

typedef tbb::concurrent_hash_map<unsigned long long, std::vector<int>> iTbb_Vec_timestamp_thread_2;
static iTbb_Vec_timestamp_thread_2 TbbVec_timestamp_thread_2;

typedef tbb::concurrent_hash_map<unsigned long long, std::vector<int>> iTbb_Vec_timestamp_thread_3;
static iTbb_Vec_timestamp_thread_3 TbbVec_timestamp_thread_3;

typedef tbb::concurrent_hash_map<unsigned long long, std::vector<int>> iTbb_Vec_timestamp_thread_4;
static iTbb_Vec_timestamp_thread_4 TbbVec_timestamp_thread_4 ;

extern void kernel(long* h_key, long* h_value_1, long* h_value_2, int size);

typedef struct _result {
    int num;
    char* fname;
    pthread_mutex_t mutex;    
} result_t;
result_t result;

typedef struct _queue {
    char* fname[MAX_QUEUE_NUM];
    int flength[MAX_QUEUE_NUM];
    int rp, wp;
    int remain;
    pthread_mutex_t mutex;
    pthread_cond_t not_full;
    pthread_cond_t not_empty;
} queue_t;

typedef struct _thread_arg {
    int cpuid;
    int id;
    queue_t* q;
    char* srchstr;
    char* dirname;
    int filenum;
} thread_arg_t;

std::vector<std::string> split_string_2(std::string str, char del) {
  int first = 0;
  int last = str.find_first_of(del);

  std::vector<std::string> result;

  while (first < str.size()) {
    std::string subStr(str, first, last - first);

    result.push_back(subStr);

    first = last + 1;
    last = str.find_first_of(del, first);

    if (last == std::string::npos) {
      last = str.size();
    }
  }

  return result;
}

int traverse_file(char* filename, int thread_id) {
    char buf[1024];
    int n = 0, sumn = 0;
    int i;
    unsigned int t, travdirtime;
    
    std::string s1 = "-read";
    
    printf("%s \n", filename);

    const string csv_file = std::string(filename); 
    vector<vector<string>> data; 

    Csv objCsv(csv_file);
    if (!objCsv.getCsv(data)) {
       cout << "read ERROR" << endl;
       return 1;
    }

    /*
    size_t kBytes = data.size() * sizeof(unsigned long long);
    unsigned long long *key;
    key = (unsigned long long *)malloc(kBytes);

    size_t vBytes = data.size() * sizeof(long);
    long *value;
    value = (long *)malloc(vBytes);

    unsigned long long *key_out;
    key_out = (unsigned long long *)malloc(kBytes);
    
    long *value_out;
    value_out = (long *)malloc(vBytes);

    int new_size = 0;
    */    

    start_timer(&t);    
    for (unsigned int row = 0; row < data.size(); row++)
      {
	std::vector<string> rec = data[row];

	std::string tms = rec[0];
	
	for(size_t c = tms.find_first_of("\""); c != string::npos; c = c = tms.find_first_of("\"")){
    	      tms.erase(c,1);
	}

	for(size_t c = tms.find_first_of("/"); c != string::npos; c = c = tms.find_first_of("/")){
	      tms.erase(c,1);
	}

        for(size_t c = tms.find_first_of("."); c != string::npos; c = c = tms.find_first_of(".")){
	      tms.erase(c,1);
	}

	for(size_t c = tms.find_first_of(" "); c != string::npos; c = c = tms.find_first_of(" ")){
	      tms.erase(c,1);
	}

	for(size_t c = tms.find_first_of(":"); c != string::npos; c = c = tms.find_first_of(":")){
	      tms.erase(c,1);
	}
		
	if(thread_id % 4 == 1)
	  { 
 	    iTbb_Vec_timestamp_thread_1::accessor tms_thread_1;
	    TbbVec_timestamp_thread_1.insert(tms_thread_1, stoull(tms));
	    tms_thread_1->second.push_back(1);    
	  }

	if(thread_id % 4 == 2)
	  {  
	    iTbb_Vec_timestamp_thread_2::accessor tms_thread_2;
	    TbbVec_timestamp_thread_2.insert(tms_thread_2, stoull(tms));
	    tms_thread_2->second.push_back(1);    
	  }
	
	if(thread_id % 4 == 3)
	  {  
	    iTbb_Vec_timestamp_thread_3::accessor tms_thread_3;
	    TbbVec_timestamp_thread_3.insert(tms_thread_3, stoull(tms));
	    tms_thread_3->second.push_back(1);    
	  } 

	/* moved to worker_2
	key[row] = stoull(tms);
	value[row] = 1;
	*/
    }

    /* moved to worker_2
    cout << "thread:" << thread_id << ":" << data.size() << " lines - read done." << endl;
    travdirtime = stop_timer(&t);
    print_timer(travdirtime);
    cout << endl;

    transfer(key, value, key_out, value_out, kBytes, vBytes, data.size(), &new_size, thread_id);
   
    for(int i = 0; i < new_size; i++)
      {
	iTbb_Vec_timestamp::accessor tms;
	TbbVec_timestamp.insert(tms, key_out[i]);
	tms->second += value_out[i];
      }
    */

    /*
    long *d_A;
    long *d_B;

    cudaMalloc((long**)&d_A, kBytes);
    cudaMalloc((long**)&d_B, vBytes);
    cudaSetDevice(thread_id);
    cudaMemcpy(d_A, key, kBytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, value, vBytes, cudaMemcpyHostToDevice);
    */
}

void initqueue(queue_t* q) {
    int i;
    q->rp = q->wp = q->remain = 0;
    for (i = 0; i < MAX_QUEUE_NUM; ++i) q->fname[i] = NULL;
    pthread_mutex_init(&q->mutex,    NULL);
    pthread_cond_init(&q->not_full,  NULL);
    pthread_cond_init(&q->not_empty, NULL);
    return;
}

void enqueue(queue_t* q, char* path, int size) {
  
    pthread_mutex_lock(&q->mutex);
    while (q->remain == MAX_QUEUE_NUM) {
        pthread_cond_wait(&q->not_full, &q->mutex);
    }
    char** fname = (char**)&q->fname[q->wp];
    if (*fname != NULL) free(*fname);
    *fname = (char*)malloc(size);
    strcpy(*fname, path);
    q->flength[q->wp] = size;
    q->wp++; q->remain++;

    if (q->wp == MAX_QUEUE_NUM) q->wp = 0;

    pthread_cond_signal(&q->not_empty);
    pthread_mutex_unlock(&q->mutex);
    return;
}

void dequeue(queue_t* q, char** fname, int* flen) {

    pthread_mutex_lock(&q->mutex);
    while (q->remain == 0) 
        pthread_cond_wait(&q->not_empty, &q->mutex);

    *flen  = q->flength[q->rp];
    if (*fname != NULL) free(*fname);
    *fname = (char*)malloc(*flen);
    strcpy(*fname, q->fname[q->rp]);
    q->rp++; q->remain--;
    if (q->rp == MAX_QUEUE_NUM) q->rp = 0;
    pthread_cond_signal(&q->not_full);
    pthread_mutex_unlock(&q->mutex);
    if (strcmp(*fname,"")==0) printf("rp=%d\n", q->rp-1);
    return;
}

int traverse_dir_thread(queue_t* q, char* dirname) {
    static int cnt = 0;
    struct dirent* dent;
    DIR* dd = opendir(dirname);

    if (dd == NULL) {
        printf("Could not open the directory %s\n", dirname); return 0;
    }

    while ((dent = readdir(dd)) != NULL) {
        if (strncmp(dent->d_name, ".",  2) == 0) continue;
        if (strncmp(dent->d_name, "..", 3) == 0) continue;	

        int size = strlen(dirname) + strlen(dent->d_name) + 2;
#if 0
        char* path = (char*)malloc(size);
        sprintf(path, "%s/%s", dirname, dent->d_name);

        struct stat fs;
        if (stat(path, &fs) < 0)
            continue;
        else {
            if (S_ISDIR(fs.st_mode))
                traverse_dir_thread(q, path);
            else if (S_ISREG(fs.st_mode)) {
                enqueue(q, path, size);
                cnt++;
            }
        }
#else
        {
            char* path = (char*)alloca(size);
            sprintf(path, "%s/%s", dirname, dent->d_name);

            struct stat fs;
            if (stat(path, &fs) < 0)
                continue;
            else {
                if (S_ISDIR(fs.st_mode))
                    traverse_dir_thread(q, path);
                else if (S_ISREG(fs.st_mode)) {
                    enqueue(q, path, size);
                    cnt++;
                }
            }
        }
#endif
    }
    closedir(dd);
    return cnt;
}

void master_func(thread_arg_t* arg) {
    queue_t* q = arg->q;
    int i;
    arg->filenum = traverse_dir_thread(q, arg->dirname);
    /* enqueue END_MARK */
    for (i = 0; i < WORKER_THREAD_NUM_CPU; ++i) 
        enqueue(q, END_MARK_FNAME, END_MARK_FLENGTH);
    return;
}

void worker_func(thread_arg_t* arg) {
    int flen;
    char* fname = NULL;
    queue_t* q = arg->q;
    char* srchstr = arg->srchstr;

    int thread_id = arg->id;
    
#ifdef __CPU_SET
    cpu_set_t mask;    
    __CPU_ZERO(&mask);
    __CPU_SET(arg->cpuid, &mask);
    if (sched_setaffinity(0, sizeof(mask), &mask) == -1)
        printf("WARNING: faild to set CPU affinity...\n");
#endif

#if 0
    while (1) {
        int n;

        dequeue(q, &fname, &flen));

        if (strncmp(fname, END_MARK_FNAME, END_MARK_FLENGTH + 1) == 0)
            break;

        n = traverse_file(fname, thread_id);
        pthread_mutex_lock(&result.mutex);

        if (n > result.num) {
            result.num = n;
            if (result.fname != NULL) free(result.fname);
            result.fname = (char*)malloc(flen);
            strcpy(result.fname, fname);
        }
        pthread_mutex_unlock(&result.mutex);
    }
#else
    char* my_result_fname;
    int my_result_num = 0;
    int my_result_len = 0;
    while (1) {
        int n;

        dequeue(q, &fname, &flen);

        if (strncmp(fname, END_MARK_FNAME, END_MARK_FLENGTH + 1) == 0)
            break;

        n = traverse_file(fname, thread_id);

        if (n > my_result_num) {
            my_result_num = n;
            my_result_len = flen;
            my_result_fname = (char*)alloca(flen);
            strcpy(my_result_fname, fname);
        }
    }
    pthread_mutex_lock(&result.mutex);
    if (my_result_num > result.num) {
        result.num = my_result_num;
	if (result.fname != NULL) free(result.fname);
        result.fname = (char*)malloc(my_result_len);
        strcpy(result.fname, my_result_fname);	
    }
    pthread_mutex_unlock(&result.mutex);
#endif
    return;
}

void worker_func_2(thread_arg_t* arg) {
    int flen;
    char* fname = NULL;
    queue_t* q = arg->q;
    char* srchstr = arg->srchstr;
    unsigned int t, travdirtime;
    
    int thread_id = arg->id;

    cout << "func_2 - threadID: " << thread_id << endl;
    
    if(thread_id == 1)
      {
	int hashmap_size = 0;
	
	for(  iTbb_Vec_timestamp_thread_1::iterator i=TbbVec_timestamp_thread_1.begin(); i!=TbbVec_timestamp_thread_1.end(); ++i )
	  {
	    for(auto itr = i->second.begin(); itr != i->second.end(); ++itr) 
	      hashmap_size++;
	  }

	cout << "threadID1 - datasize:" << hashmap_size << endl;
	
	size_t kBytes = hashmap_size * sizeof(unsigned long);
	unsigned long long *key;
	key = (unsigned long long *)malloc(kBytes);
    
	size_t vBytes = hashmap_size * sizeof(long);
	long *value;
	value = (long *)malloc(vBytes);
    
	unsigned long long *key_out;
	key_out = (unsigned long long *)malloc(kBytes);
    
	long *value_out;
	value_out = (long *)malloc(vBytes);

	int new_size = 0;
	int counter = 0;

	counter = 0;
	for(  iTbb_Vec_timestamp_thread_1::iterator i=TbbVec_timestamp_thread_1.begin(); i!=TbbVec_timestamp_thread_1.end(); ++i )
	  {
	    for(auto itr = i->second.begin(); itr != i->second.end(); ++itr) {
	      key[counter] = (unsigned long long)i->first;
	      value[counter] = (long)*itr;
	      
	      if(counter < 3)
		{
		  cout << "threadID - 1:" << (unsigned long long)i->first << "," <<  (long)*itr << endl;
		  cout << "threadID - 1:" << key[counter] << "," << value[counter] << endl;
		}
	      counter++;
	    }
	  }

	cout << "thread:" << thread_id << ":" << TbbVec_timestamp_thread_1.size()
	     << " lines - read done." << endl;
	travdirtime = stop_timer(&t);
	print_timer(travdirtime);
	cout << endl;

	cout << "thread:" << thread_id << ":calling transfer:data size:" << hashmap_size << endl;
	
	transfer(key, value, key_out, value_out, kBytes, vBytes, hashmap_size,
		 &new_size, thread_id);

	cout << "thread:" << thread_id << ":transfer done:data size:" << new_size << endl;
	
	for(int i = 0; i < new_size; i++)
	  {
	    iTbb_Vec_timestamp::accessor tms;
	    TbbVec_timestamp.insert(tms, key_out[i]);
	    tms->second += value_out[i];

	    /*
	    if(i<100)
	      cout << key_out[i] << "," << value_out[i] << endl;
	    */
	  }
      }

    //// GPU 2 

    if(thread_id == 2)
      {
	int hashmap_size = 0;
	
	for(  iTbb_Vec_timestamp_thread_2::iterator i=TbbVec_timestamp_thread_2.begin(); i!=TbbVec_timestamp_thread_2.end(); ++i )
	  {
	    for(auto itr = i->second.begin(); itr != i->second.end(); ++itr) 
	      hashmap_size++;
	  }

	cout << "threadID2 - datasize:" << hashmap_size << endl;
	
	size_t kBytes = hashmap_size * sizeof(unsigned long);
	unsigned long long *key;
	key = (unsigned long long *)malloc(kBytes);
    
	size_t vBytes = hashmap_size * sizeof(long);
	long *value;
	value = (long *)malloc(vBytes);
    
	unsigned long long *key_out;
	key_out = (unsigned long long *)malloc(kBytes);
    
	long *value_out;
	value_out = (long *)malloc(vBytes);

	int new_size = 0;
	int counter = 0;

	counter = 0;
	for(  iTbb_Vec_timestamp_thread_2::iterator i=TbbVec_timestamp_thread_2.begin(); i!=TbbVec_timestamp_thread_2.end(); ++i )
	  {
	    for(auto itr = i->second.begin(); itr != i->second.end(); ++itr) {
	      key[counter] = (unsigned long long)i->first;
	      value[counter] = (long)*itr;
	      
	      if(counter < 3)
		{
		  cout << "threadID - 2:" << (unsigned long long)i->first << "," <<  (long)*itr << endl;
		  cout << "threadID - 2:" << key[counter] << "," << value[counter] << endl;
		}
	      counter++;
	    }
	  }

	cout << "thread:" << thread_id << ":" << TbbVec_timestamp_thread_2.size()
	     << " lines - read done." << endl;
	travdirtime = stop_timer(&t);
	print_timer(travdirtime);
	cout << endl;

	cout << "thread:" << thread_id << ":calling transfer:data size:" << hashmap_size << endl;
	
	transfer(key, value, key_out, value_out, kBytes, vBytes, hashmap_size,
		 &new_size, thread_id);

	cout << "thread:" << thread_id << ":transfer done:data size:" << new_size << endl;
	
	for(int i = 0; i < new_size; i++)
	  {
	    iTbb_Vec_timestamp::accessor tms;
	    TbbVec_timestamp.insert(tms, key_out[i]);
	    tms->second += value_out[i];

	    /*
	    if(i<100)
	      cout << key_out[i] << "," << value_out[i] << endl;
	    */
	  }
      }		

    //// GPU 3

    if(thread_id == 3)
      {
	int hashmap_size = 0;
	
	for(  iTbb_Vec_timestamp_thread_3::iterator i=TbbVec_timestamp_thread_3.begin(); i!=TbbVec_timestamp_thread_3.end(); ++i )
	  {
	    for(auto itr = i->second.begin(); itr != i->second.end(); ++itr) 
	      hashmap_size++;
	  }

	cout << "threadID3 - datasize:" << hashmap_size << endl;
	
	size_t kBytes = hashmap_size * sizeof(unsigned long);
	unsigned long long *key;
	key = (unsigned long long *)malloc(kBytes);
    
	size_t vBytes = hashmap_size * sizeof(long);
	long *value;
	value = (long *)malloc(vBytes);
    
	unsigned long long *key_out;
	key_out = (unsigned long long *)malloc(kBytes);
    
	long *value_out;
	value_out = (long *)malloc(vBytes);

	int new_size = 0;
	int counter = 0;

	counter = 0;
	for(  iTbb_Vec_timestamp_thread_3::iterator i=TbbVec_timestamp_thread_3.begin(); i!=TbbVec_timestamp_thread_3.end(); ++i )
	  {
	    for(auto itr = i->second.begin(); itr != i->second.end(); ++itr) {
	      key[counter] = (unsigned long long)i->first;
	      value[counter] = (long)*itr;
	      
	      if(counter < 3)
		{
		  cout << "threadID - 3:" << (unsigned long long)i->first << "," <<  (long)*itr << endl;
		  cout << "threadID - 3:" << key[counter] << "," << value[counter] << endl;
		}
	      counter++;
	    }
	  }

	cout << "thread:" << thread_id << ":" << TbbVec_timestamp_thread_3.size()
	     << " lines - read done." << endl;
	travdirtime = stop_timer(&t);
	print_timer(travdirtime);
	cout << endl;

	cout << "thread:" << thread_id << ":calling transfer:data size:" << hashmap_size << endl;
	
	transfer(key, value, key_out, value_out, kBytes, vBytes, hashmap_size,
		 &new_size, thread_id);

	cout << "thread:" << thread_id << ":transfer done:data size:" << new_size << endl;
	
	for(int i = 0; i < new_size; i++)
	  {
	    iTbb_Vec_timestamp::accessor tms;
	    TbbVec_timestamp.insert(tms, key_out[i]);
	    tms->second += value_out[i];

	    /*
	    if(i<100)
	      cout << key_out[i] << "," << value_out[i] << endl;
	    */
	  }
      }		

    
}

void print_result(thread_arg_t* arg) {
    if (result.num) {
        printf("Total %d files\n", arg->filenum);
        printf("Max include file: %s[include %d]\n", result.fname, result.num);	
    }
    return;
}

int main(int argc, char* argv[]) {
    int i;

    int thread_num;
    unsigned int t, travdirtime;
    queue_t q;
    
    thread_arg_t targ[WORKER_THREAD_NUM_CPU];
    pthread_t master;
    pthread_t worker[WORKER_THREAD_NUM_CPU];

    thread_arg_t targ_2[WORKER_THREAD_NUM_GPU];
    pthread_t worker_2[WORKER_THREAD_NUM_GPU];
    
    int cpu_num;

    /*
    if (argc != 3) {
        printf("Usage: search_strings PATTERN [DIR]\n"); return 0;
    }
    */
    
    cpu_num = sysconf(_SC_NPROCESSORS_CONF);

    initqueue(&q);

    // thread_num = WORKER_THREAD_NUM_1;
    for (i = 0; i < WORKER_THREAD_NUM_CPU; ++i) {
        targ[i].q = &q;
        // targ[i].srchstr = argv[1];
        targ[i].dirname = argv[1];
        targ[i].filenum = 0;
        targ[i].cpuid = i%cpu_num;
    }
    result.fname = NULL;
    
    pthread_mutex_init(&result.mutex, NULL);

    pthread_create(&master, NULL, (void*)master_func, (void*)&targ[0]);
    for (i = 1; i < WORKER_THREAD_NUM_CPU; ++i) {
        targ[i].id = i;
        pthread_create(&worker[i], NULL, (void*)worker_func, (void*)&targ[i]);
    }
    for (i = 1; i < WORKER_THREAD_NUM_CPU; ++i) 
        pthread_join(worker[i], NULL);

    print_result(&targ[0]);

    cout << "2nd phase" << endl;
    thread_num = 2;

    for (i = 1; i < WORKER_THREAD_NUM_GPU; ++i) {
        targ_2[i].id = i;
        pthread_create(&worker_2[i], NULL, (void*)worker_func_2, (void*)&targ_2[i]);
    }
	
    for (i = 1; i < WORKER_THREAD_NUM_GPU; ++i) 
        pthread_join(worker_2[i], NULL);
    

    /* for automatic sorting, std::map is used */
    std::map<unsigned long long, long> final;

    
    for(auto itr = TbbVec_timestamp.begin(); itr != TbbVec_timestamp.end(); ++itr) {
      final.insert(std::make_pair((unsigned long long)(itr->first), long(itr->second)));
    }
    
    ofstream outputfile("tmp-counts");
    for(auto itr = final.begin(); itr != final.end(); ++itr) {
   
      std::string timestamp = to_string(itr->first);

      outputfile << timestamp.substr(0,4) << "-" << timestamp.substr(4,2) << "-" << timestamp.substr(6,2) << " "
		 << timestamp.substr(8,2) << ":" << timestamp.substr(10,2) << ":" << timestamp.substr(12,2)
		 << "." << timestamp.substr(14,3) << ","
		 << itr->second << endl; 

      // outputfile << itr->first << "," << itr->second << endl;			       
    }
    outputfile.close();
    
    return 0;
}
