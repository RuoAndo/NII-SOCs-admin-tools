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
#include <sys/resource.h>

#include "tbb/concurrent_hash_map.h"
#include "tbb/blocked_range.h"
#include "tbb/parallel_for.h"
#include "tbb/tick_count.h"
#include "tbb/task_scheduler_init.h"
#include "tbb/concurrent_vector.h"
#include "utility.h"

#include "csv.hpp"
#include "timer.h"

#include <boost/date_time/posix_time/posix_time.hpp>

using namespace std;
using namespace tbb;

// 2 / 1024
#define WORKER_THREAD_NUM 33
#define MAX_QUEUE_NUM 97
#define END_MARK_FNAME   "///"
#define END_MARK_FLENGTH 3

typedef tbb::concurrent_hash_map<unsigned long long, long> iTbb_Vec_timestamp;
static iTbb_Vec_timestamp TbbVec_timestamp; 

static int global_counter = 0;
static double global_duration = 0;

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

std::string now_str()
{
  // Get current time from the clock, using microseconds resolution
  const boost::posix_time::ptime now =
    boost::posix_time::microsec_clock::local_time();

  const boost::posix_time::time_duration td = now.time_of_day();

  const long hours        = td.hours();
  const long minutes      = td.minutes();
  const long seconds      = td.seconds();
  const long milliseconds = td.total_milliseconds() -
    ((hours * 3600 + minutes * 60 + seconds) * 1000);

  char buf[40];
  sprintf(buf, "%02ld:%02ld:%02ld.%03ld",
	  hours, minutes, seconds, milliseconds);

  return buf;
}

std::vector<size_t> get_cpu_times() {
  std::ifstream proc_stat("/proc/stat");
  proc_stat.ignore(5, ' '); // Skip the 'cpu' prefix.
  std::vector<size_t> times;
  for (size_t time; proc_stat >> time; times.push_back(time));
  return times;
}

bool get_cpu_times(size_t &idle_time, size_t &total_time) {
  const std::vector<size_t> cpu_times = get_cpu_times();
  if (cpu_times.size() < 4)
    return false;
  idle_time = cpu_times[3];
  total_time = std::accumulate(cpu_times.begin(), cpu_times.end(), 0);
  return true;
}

int traverse_file(char* filename, int thread_id) {
    char buf[1024];
    int n = 0, sumn = 0;
    int i;
    unsigned int t, travdirtime;
    struct timeval tv;

    struct timespec startTime, endTime, sleepTime;
    int counter = 0;
    
    std::string s1 = "-read";

    clock_t start = clock();
    
    // printf("threadID:%d:%d:%s \n", thread_id, global_counter, filename);
  
    std::cout << "[" << now_str() << "] " "threadID:" << thread_id << ",fileNo:" << global_counter << ","
	      << filename << std::endl;

    gettimeofday(&tv, NULL);

    // printf("%ld %06lu\n", tv.tv_sec, tv.tv_usec);
    
    const string csv_file = std::string(filename); 
    vector<vector<string>> data; 

    Csv objCsv(csv_file);
    if (!objCsv.getCsv(data)) {
       cout << "read ERROR" << endl;
       return 1;
    }

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
    int line_counter = 0;
    
    start_timer(&t);    
    for (unsigned int row = 0; row < data.size(); row++)
      {
	std::vector<string> rec = data[row];

	if(line_counter == 0)
	  {
	    line_counter++;
	    continue;
	  }
	    
	std::string tms = rec[37];
	
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

	// key[row] = stoull(tms);
	// value[row] = 1;

	// std::string bytes = rec[20];
	std::string bytes = "1";

	for(size_t c = bytes.find_first_of("\""); c != string::npos; c = c = bytes.find_first_of("\"")){
	  bytes.erase(c,1);
	}         

	clock_gettime(CLOCK_REALTIME, &startTime);
	sleepTime.tv_sec = 0;
	sleepTime.tv_nsec = 123;
	
	iTbb_Vec_timestamp::accessor t;
	TbbVec_timestamp.insert(t, stoull(tms));
	t->second += 1;
	t->second += stol(bytes);

	char str[100];
	char *ends;
	
	clock_gettime(CLOCK_REALTIME, &endTime);

	// printf("開始時刻　 = %10ld.%09ld\n", startTime.tv_sec, startTime.tv_nsec);
	// printf("終了時刻　 = %10ld.%09ld\n", endTime.tv_sec, endTime.tv_nsec);
	// printf("経過実時間 = ");
	if (endTime.tv_nsec < startTime.tv_nsec) {
	  sprintf(str, "%10ld.%09ld", endTime.tv_sec - startTime.tv_sec - 1 ,endTime.tv_nsec + 1000000000 - startTime.tv_nsec);
	} else {
	  sprintf(str,"%10ld.%09ld", endTime.tv_sec - startTime.tv_sec ,endTime.tv_nsec - startTime.tv_nsec);
	}
	
	// double tmp = atof(str);
	double tmp = strtod( str, &ends );
	// printf("%f\n",tmp);
	
	global_duration = global_duration + tmp;

	// counter++;
	
	// tms->second += 1;
	line_counter++;
	global_counter++;    
      }
   
   size_t previous_idle_time=0, previous_total_time=0;
   size_t idle_time=0, total_time=0;
   get_cpu_times(idle_time, total_time); 
   const float idle_time_delta = idle_time - previous_idle_time;
   const float total_time_delta = total_time - previous_total_time;
   const float utilization = 100.0 * (1.0 - idle_time_delta / total_time_delta);

   struct rusage r;
   getrusage(RUSAGE_SELF, &r); 

   clock_t end = clock();
   const double time = static_cast<double>(end - start) / CLOCKS_PER_SEC * 1000.0;
   
   // std::cout << "[log]," << tv.tv_sec << "," << global_counter << "," << utilization << "," << r.ru_maxrss << "," << time << endl;
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
    // int thread_num = 1 + WORKER_THREAD_NUM;
    int thread_num = WORKER_THREAD_NUM;
    unsigned int t, travdirtime;
    queue_t q;
    thread_arg_t targ[thread_num];
    pthread_t master;
    pthread_t worker[thread_num];
    int cpu_num;

    struct timespec startTime, endTime, sleepTime;
    
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

    /*
    start_timer(&t);
    travdirtime = stop_timer(&t);
    print_timer(travdirtime);
    */    

    pthread_mutex_init(&result.mutex, NULL);

    pthread_create(&master, NULL, (void*)master_func, (void*)&targ[0]);
    for (i = 1; i < thread_num; ++i) {
        targ[i].id = i;
	std::cout << "threadID:" << i << " - launched" << std::endl;
        pthread_create(&worker[i], NULL, (void*)worker_func, (void*)&targ[i]);
    }
	
    for (i = 1; i < thread_num; ++i) 
        pthread_join(worker[i], NULL);

    // print_result(&targ[0]);

    double avg = global_duration / (double)global_counter;
    // cout << global_counter << endl;
    // printf("avg:%10f\n", avg);
    cout << "avg:" << avg << endl;
    printf("duration total:%10f\n", global_duration);
    printf("total:%d\n", global_counter);
    
    // cout << "avg:" << avg << endl;
    
    clock_gettime(CLOCK_REALTIME, &startTime);
    sleepTime.tv_sec = 0;
    sleepTime.tv_nsec = 123;
    
    std::map<unsigned long long, long> final;
    
    for(auto itr = TbbVec_timestamp.begin(); itr != TbbVec_timestamp.end(); ++itr) {
      final.insert(std::make_pair((unsigned long long)(itr->first), long(itr->second)));
    }

    char str[100];
    char *ends;
	
    clock_gettime(CLOCK_REALTIME, &endTime);
    if (endTime.tv_nsec < startTime.tv_nsec) {
      sprintf(str, "%ld.%ld", endTime.tv_sec - startTime.tv_sec - 1 ,endTime.tv_nsec + 1000000000 - startTime.tv_nsec);
    } else {
      sprintf(str,"%ld.%ld", endTime.tv_sec - startTime.tv_sec ,endTime.tv_nsec - startTime.tv_nsec);
    }
    
    // double tmp = atof(str);
    double tmp = strtod( str, &ends );
    printf("sort:%f\n",tmp);

    ofstream outputfile("tmp-counts");
    for(auto itr = final.begin(); itr != final.end(); ++itr) {

      std::string timestamp = to_string(itr->first);

      outputfile << timestamp.substr(0,4) << "-" << timestamp.substr(4,2) << "-" << timestamp.substr(6,2) << " "
		 << timestamp.substr(8,2) << ":" << timestamp.substr(10,2) << ":" << timestamp.substr(12,2)
		 << "." << timestamp.substr(14,3) << ","
		 << itr->second << endl; 
    }
    outputfile.close();


    
    return 0;
}
