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

/*
#include <thrust/host_vector.h>
#include <thrust/device_vector.h>
#include <thrust/system/cuda/experimental/pinned_allocator.h>
#include <thrust/system/cuda/execution_policy.h>
#include <thrust/fill.h>
#include <thrust/sequence.h>
#include <thrust/for_each.h>
*/

#include "csv.hpp"
#include "timer.h"

using namespace std;
using namespace tbb;

#define STR(var) #var 

// 2 / 1024
#define WORKER_THREAD_NUM (50)
#define MAX_QUEUE_NUM (100)
#define END_MARK_FNAME   "///"
#define END_MARK_FLENGTH 3

// 96typedef concurrent_hash_map<unsigned long long, int, HashCompare> CharTable2;
// 97static CharTable2 table2; 

typedef tbb::concurrent_hash_map<long, int> iTbb_Vec_timestamp_inward;
static iTbb_Vec_timestamp_inward TbbVec_timestamp_inward;

typedef tbb::concurrent_hash_map<long, int> iTbb_Vec_bytes_inward;
static iTbb_Vec_bytes_inward TbbVec_bytes_inward;

typedef tbb::concurrent_hash_map<long, int> iTbb_Vec_timestamp_outward;
static iTbb_Vec_timestamp_outward TbbVec_timestamp_outward;

typedef tbb::concurrent_hash_map<long, int> iTbb_Vec_bytes_outward;
static iTbb_Vec_bytes_outward TbbVec_bytes_outward;

extern void kernel(long* h_key, long* h_value_1, long* h_value_2, string filename, int size);

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
    int id;
    int cpuid;
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
    std::string s1 = "-read";

    int netmask;
    int found_flag = 0;
    int counter = 0;

    printf("%s \n", filename);

    const string list_file = "monitoring_list"; 
    vector<vector<string>> list_data; 
	
    const string session_file = std::string(filename); 
    vector<vector<string>> session_data; 

    Csv objCsv(list_file);
    if (!objCsv.getCsv(list_data)) {
      cout << "read ERROR" << endl;
      return 1;
    }

    Csv objCsv2(session_file);
    if (!objCsv2.getCsv(session_data)) {
       cout << "read ERROR" << endl;
       return 1;
    }

    // for(int i=0; i < session_data.size(); i++)
    // found_flag[i]=0;

    /*
      X.X.X.X,16
      Y.Y.Y.Y,30
    */    

    for (unsigned int row2 = 0; row2 < session_data.size(); row2++) {

	       vector<string> rec2 = session_data[row2];
	       std::string srcIP = rec2[4];

	       for(size_t c = srcIP.find_first_of("\""); c != string::npos; c = c = srcIP.find_first_of("\"")){
		 srcIP.erase(c,1);
	       }

	       std::string tms = rec2[0];
	       std::string bytes = rec2[20];

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
	       for(size_t c = bytes.find_first_of("\""); c != string::npos; c = c = bytes.find_first_of("\"")){
		 bytes.erase(c,1);
	       }

	       char del2 = '.';
	       
	       std::string sessionIPstring;
	       for (const auto subStr : split_string_2(srcIP, del2)) {
		 unsigned long ipaddr_src;
		 ipaddr_src = atol(subStr.c_str());
		 std::bitset<8> trans =  std::bitset<8>(ipaddr_src);
		 std::string trans_string = trans.to_string();
		 sessionIPstring = sessionIPstring + trans_string;
	       }

	     found_flag = 0;
	       
             for (unsigned int row = 0; row < list_data.size(); row++) {

	       vector<string> rec = list_data[row];
	       const string argIP = rec[0]; 
	       std::string argIPstring;

	       netmask = atoi(rec[1].c_str());
	    
	     // std::cout << argIP << "/" << netmask << std::endl;
	    	    
	       for (const auto subStr : split_string_2(argIP, del2)) {
		 unsigned long ipaddr_src;
		 ipaddr_src = atol(subStr.c_str());
		 std::bitset<8> trans =  std::bitset<8>(ipaddr_src);
		 std::string trans_string = trans.to_string();
		 argIPstring = argIPstring + trans_string;
	       }
	       
	       std::bitset<32> bit_argIP(argIPstring);
	       std::bitset<32> bit_sessionIP(sessionIPstring);
	       
	       std::bitset<32> trans2(0xFFFFFFFF);
	       trans2 <<= netmask;
	       bit_sessionIP &= trans2;
		
	       if(bit_sessionIP == bit_argIP)
		 {
		 found_flag = 1;

		 iTbb_Vec_timestamp_outward::accessor tms_out;
		 TbbVec_timestamp_outward.insert(tms_out, stol(tms)); 
		 tms_out->second += 1;

		 iTbb_Vec_bytes_outward::accessor bytes_out;
		 TbbVec_bytes_outward.insert(bytes_out, stol(tms)); 
		 bytes_out->second += stol(bytes);
		 
		 counter = counter + 1;
		 }
	     }

	     if( row2 % (session_data.size()/100) == 0)
	       cout << "threadID:" << thread_id << ":" << filename << ":"
		    <<((float)row2 / (float)session_data.size()) * 100
		    << "% done" << endl; 
	     
	     if(found_flag == 0)
	       {
		 iTbb_Vec_timestamp_inward::accessor tms_in;
		 TbbVec_timestamp_inward.insert(tms_in, stol(tms)); 
		 tms_in->second += 1;

		 iTbb_Vec_bytes_inward::accessor bytes_in;
		 TbbVec_bytes_inward.insert(bytes_in, stol(tms)); 
		 bytes_in->second += stol(bytes);
		 
	       }
    }   
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
    for (i = 0; i < WORKER_THREAD_NUM; ++i) 
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

void print_result(thread_arg_t* arg) {
    if (result.num) {
        printf("Total %d files\n", arg->filenum);
        printf("Max include file: %s[include %d]\n", result.fname, result.num);	
    }
    return;
}

int main(int argc, char* argv[]) {
    int i; 
    int thread_num = 1 + WORKER_THREAD_NUM;
    unsigned int t, travdirtime;
    queue_t q;
    thread_arg_t targ[thread_num];
    pthread_t master;
    pthread_t worker[thread_num];
    int cpu_num;

    /*
    if (argc != 3) {
        printf("Usage: search_strings PATTERN [DIR]\n"); return 0;
    }
    */
    
    cpu_num = sysconf(_SC_NPROCESSORS_CONF);

    initqueue(&q);

    for (i = 0; i < thread_num; ++i) {
        targ[i].q = &q;
        // targ[i].srchstr = argv[1];
        targ[i].dirname = argv[1];
        targ[i].filenum = 0;
        targ[i].cpuid = i%cpu_num;
    }
    result.fname = NULL;

    start_timer(&t);

    pthread_mutex_init(&result.mutex, NULL);

    pthread_create(&master, NULL, (void*)master_func, (void*)&targ[0]);
    for (i = 1; i < thread_num; ++i)
      {
        targ[i].id = i;  
        pthread_create(&worker[i], NULL, (void*)worker_func, (void*)&targ[i]);
      }
	
    for (i = 1; i < thread_num; ++i) 
        pthread_join(worker[i], NULL);

    travdirtime = stop_timer(&t);
    print_timer(travdirtime);
    print_result(&targ[0]);
    for (i = 1; i < thread_num; ++i) {
        if ((targ[i].q)->fname[i] != NULL) free((targ[i].q)->fname[i]);
    }
    if(result.fname != NULL) free(result.fname);

    ofstream outputfile("tmp"); 

    int counter = 0;

    std::map<long, long> inward_tms;
    
    for( iTbb_Vec_timestamp_inward::iterator i = TbbVec_timestamp_inward.begin(); i!=TbbVec_timestamp_inward.end(); ++i )
    {
      inward_tms.insert(std::make_pair(long(i->first),long(i->second)));      
    }

    std::map<long, long> inward_bytes;
    
    for( iTbb_Vec_bytes_inward::iterator i = TbbVec_bytes_inward.begin(); i!=TbbVec_bytes_inward.end(); ++i )
    {
      // cout << i->first << "," << i->second << endl;
      inward_bytes.insert(std::make_pair(long(i->first),long(i->second)));      
    }

    counter = 0;
    for(auto itr = inward_tms.begin(); itr != inward_tms.end(); ++itr) {
      outputfile << itr->first << "," << itr->second << "," << inward_bytes[(long)itr->first] << endl;
      counter++;
    }
      
    return 0;
}
