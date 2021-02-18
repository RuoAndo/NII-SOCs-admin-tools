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
#include <boost/algorithm/string.hpp>

#include "csv.hpp"
#include "timer.h"

#include <boost/date_time/posix_time/posix_time.hpp>
#include <boost/filesystem/path.hpp>
#include <boost/filesystem/operations.hpp>
#include <boost/filesystem.hpp>

using namespace std;
using namespace tbb;

// 2 / 1024
#define WORKER_THREAD_NUM 11
#define MAX_QUEUE_NUM 128
#define END_MARK_FNAME   "///"
#define END_MARK_FLENGTH 3

typedef tbb::concurrent_hash_map<unsigned long long, long> iTbb_Vec_timestamp;
static iTbb_Vec_timestamp TbbVec_timestamp; 

static int global_counter = 0;
static double global_duration = 0;
static int file_counter = 0;

static int ingress_counter_global = 0;
static int egress_counter_global = 0;
static int miss_counter = 0;

extern void kernel(long* h_key, long* h_value_1, long* h_value_2, int size);
void discern(unsigned long *IPaddress, unsigned long *netmask, unsigned long address_to_match, double *result, size_t data_size, int thread_id);

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
    char* fname_list;
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

int traverse_file(char* filename, char* filename_list, int thread_id) {


  int counter = 0;
  int addr_counter = 0;
  int egress_counter = 0;
  int in_counter = 0;
  
  // int N = atoi(argv[3]);  
  int netmask;
  std::map <int,int> found_flag;
  std::map <int,int> found_flag_2;
  std::map <int,int> destPort2;
 
  struct timespec startTime, endTime, sleepTime;
  unsigned int t, travdirtime;

  try {

    const string list_file = string(filename_list);
    vector<vector<string>> list_data; 
    
    const string session_file = string(filename); 
    vector<vector<string>> session_data; 
	
    try {
      Csv objCsv(list_file);
      if (!objCsv.getCsv(list_data)) {
	cout << "read ERROR" << endl;
	return 1;
      }
    }
    catch (...) {
      cout << "EXCEPTION (session)" << endl;
      return 1;
    }
  
    try {
      Csv objCsv(session_file);
      if (!objCsv.getCsv(session_data)) {
	cout << "read ERROR" << endl;
	return 1;
      }
    }
    catch (...) {
      cout << "EXCEPTION (session)" << endl;
      return 1;
    }

    // init map
    for(int i=0; i<session_data.size(); i++)
      {
	found_flag[i] = 0;
	found_flag_2[i] = 0;
	destPort2[i] = 0;
      }

    counter = 0;
    for (unsigned int row = 0; row < list_data.size(); row++) {
      
      vector<string> rec = list_data[row];
      const string argIP = rec[0]; 
      std::string argIPstring;

      egress_counter = 0;

      // start_timer(&t);
      
      netmask = atoi(rec[1].c_str());
	    
      // std::cout << addr_counter << "(" << list_data.size() << "):" << argIP << "/" << netmask << std::endl;
	    
      char del2 = '.';
	    
      for (const auto subStr : split_string_2(argIP, del2)) {
	unsigned long ipaddr_src;
	ipaddr_src = atol(subStr.c_str());
	std::bitset<8> trans =  std::bitset<8>(ipaddr_src);
	std::string trans_string = trans.to_string();
	argIPstring = argIPstring + trans_string;
      }

      std::bitset<32> argIP_bitset = std::bitset<32>(stoul(argIPstring,0,2));
      unsigned long address_to_match = argIP_bitset.to_ulong();

      /* allocate */
      size_t sBytes = session_data.size() * sizeof(unsigned long);
      unsigned long *srcIP_ul;
      srcIP_ul = (unsigned long *)malloc(sBytes);

      size_t dBytes = session_data.size() * sizeof(unsigned long);
      unsigned long *dstIP_ul;
      dstIP_ul = (unsigned long *)malloc(dBytes);

      size_t mBytes = session_data.size() * sizeof(unsigned long);
      unsigned long *netmask_ul;
      netmask_ul = (unsigned long *)malloc(mBytes);

      size_t rBytes = session_data.size() * sizeof(double);
      double *result;
      result = (double *)malloc(rBytes);

      for (unsigned int row2 = 0; row2 < session_data.size(); row2++) {
	vector<string> rec2 = session_data[row2];

	if(rec2.size() < 7)
	  {
	    miss_counter++;
	    continue;
	  }
	    
	std::string srcIP = rec2[27];
	std::string destIP = rec2[20];
	std::string destPort = rec2[19];
	
	for(size_t c = srcIP.find_first_of("\""); c != string::npos; c = c = srcIP.find_first_of("\"")){
	  srcIP.erase(c,1);
	}
	
	for(size_t c = destIP.find_first_of("\""); c != string::npos; c = c = destIP.find_first_of("\"")){
	  destIP.erase(c,1);
	}
	for(size_t c = destPort.find_first_of("\""); c != string::npos; c = c = destPort.find_first_of("\"")){
	  destPort.erase(c,1);
	  destPort2[row2] = atoi(destPort.c_str());
	} 
	
	std::string srcIPstring;
	for (const auto subStr : split_string_2(srcIP, del2)) {
	  unsigned long ipaddr_src;
	  ipaddr_src = atol(subStr.c_str());
	  std::bitset<8> trans =  std::bitset<8>(ipaddr_src);
	  std::string trans_string = trans.to_string();
	  srcIPstring = srcIPstring + trans_string;
	}

	std::bitset<32> srcIP_bitset = std::bitset<32>(stoul(srcIPstring,0,2));
	// cout << srcIP_bitset.to_ulong() << endl;
	srcIP_ul[row2] = srcIP_bitset.to_ulong();

	std::string dstIPstring;
	for (const auto subStr : split_string_2(destIP, del2)) {
	  unsigned long ipaddr_src;
	  ipaddr_src = atol(subStr.c_str());
	  std::bitset<8> trans =  std::bitset<8>(ipaddr_src);
	  std::string trans_string = trans.to_string();
	  dstIPstring = dstIPstring + trans_string;
	}

	std::bitset<32> dstIP_bitset = std::bitset<32>(stoul(dstIPstring,0,2));
	dstIP_ul[row2] = dstIP_bitset.to_ulong();

	std::bitset<32> trans2(0xFFFFFFFF);
	trans2 <<= 32 - netmask;
	netmask_ul[row2] = trans2.to_ulong();
      }
      
      /* reset */
      for(int i =0; i < session_data.size(); i++)
	  result[i]=1;

      clock_gettime(CLOCK_REALTIME, &startTime);
      sleepTime.tv_sec = 0;
      sleepTime.tv_nsec = 123;
      
      discern(srcIP_ul, netmask_ul, address_to_match, result, session_data.size(), thread_id);

      /*
      clock_gettime(CLOCK_REALTIME, &endTime);
      printf("discern 1 (srcIP)");
      if (endTime.tv_nsec < startTime.tv_nsec) {
	printf("%10ld.%09ld", endTime.tv_sec - startTime.tv_sec - 1
	       ,endTime.tv_nsec + 1000000000 - startTime.tv_nsec);
      } else {
	printf("%10ld.%09ld", endTime.tv_sec - startTime.tv_sec
	       ,endTime.tv_nsec - startTime.tv_nsec);
      }
      printf(" sec\n");
      */      

      for(int i =0; i < session_data.size(); i++)
	{
	  if(result[i]==0)
	    {
	      if(destPort2[i] == 25)
		{
		  found_flag[i] = 1;
		  ingress_counter_global++;
		}
	    }
	}

      /* reset */
      for(int i =0; i < session_data.size(); i++)
	  result[i]=1;

      clock_gettime(CLOCK_REALTIME, &startTime);
      sleepTime.tv_sec = 0;
      sleepTime.tv_nsec = 123;
      
      discern(dstIP_ul, netmask_ul, address_to_match, result, session_data.size(), thread_id);

      /*
      clock_gettime(CLOCK_REALTIME, &endTime);
      printf("discern 2 (destIP) ");
      if (endTime.tv_nsec < startTime.tv_nsec) {
	printf("%10ld.%09ld", endTime.tv_sec - startTime.tv_sec - 1
	       ,endTime.tv_nsec + 1000000000 - startTime.tv_nsec);
      } else {
	printf("%10ld.%09ld", endTime.tv_sec - startTime.tv_sec
	       ,endTime.tv_nsec - startTime.tv_nsec);
      }
      printf(" sec\n");
      */      

      for(int i =0; i < session_data.size(); i++)
	{
	  if(result[i]==0)
	    {
	      if(destPort2[i] == 25)
		{
		  found_flag_2[i] = 1;
		  egress_counter_global++;
		}
	    }
	}

      /* per one list */
      std::cout << "[" << now_str() << "] " << "ThreadID" << thread_id << ":[" << file_counter << "]" << "(" << list_file << ")" << addr_counter
		<< "(" << list_data.size() << "):" << argIP << "/"
		<< netmask << " @ " << filename << ":" << ingress_counter_global << ":" << egress_counter_global << ":" << miss_counter << std::endl;
      
      // travdirtime = stop_timer(&t);
      // print_timer(travdirtime);

      addr_counter++;

      /* free */
      free(srcIP_ul);
      free(dstIP_ul);
      free(netmask_ul);
      free(result);

      //  cout << address_to_match << "," << egress_counter << endl;
    }

    int counter_flag = 0;
    for(int i =0; i < session_data.size(); i++)
      {
	if(found_flag[i]==1)
	  counter_flag++;	
      }

    int counter_flag_2 = 0;
    for(int i =0; i < session_data.size(); i++)
      {
	if(found_flag_2[i]==1)
	  counter_flag_2++;	
      }

    file_counter++;
    cout << "[" << file_counter << "]" << counter_flag << "," << counter_flag_2 << " @ " << filename << endl;

    const string file_rendered_egress = session_file + "_egress";
    ofstream outputfile_egress(file_rendered_egress);
    
    for (unsigned int row3 = 0; row3 < session_data.size(); row3++) {
      vector<string> rec3 = session_data[row3];
      if(found_flag[row3]==1)
	{
	  std::string all_line;
	  all_line = "1";
	  for(auto itr = rec3.begin(); itr != rec3.end(); ++itr) {
	    all_line = all_line + "," + *itr;
	  }
	  outputfile_egress << all_line << std::endl;
	}
    }
    outputfile_egress.close();

    const string file_rendered_ingress = session_file + "_ingress";
    ofstream outputfile_ingress(file_rendered_ingress);

    for (unsigned int row3 = 0; row3 < session_data.size(); row3++) {
      vector<string> rec3 = session_data[row3];
      if(found_flag_2[row3]==1)
	{
	  std::string all_line;
	  all_line = "0";
	  for(auto itr = rec3.begin(); itr != rec3.end(); ++itr) {
	    all_line = all_line + "," + *itr;
	  }
	  outputfile_ingress << all_line << std::endl;
	}
    }
    outputfile_ingress.close();
  	 
    return 0;
  }
    
  catch(std::exception& e) {
    std::cerr<<"error occurred. error text is :\"" <<e.what()<<"\"\n";
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
    char* fname= NULL;

    queue_t* q = arg->q;
    char* srchstr = arg->srchstr;

    int thread_id = arg->id;
    char* fname_list = arg->fname_list;

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

        n = traverse_file(fname, fname_list, thread_id);
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

        n = traverse_file(fname, fname_list, thread_id);

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
      // printf("Total %d files\n", arg->filenum);
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
	targ[i].fname_list = argv[2];
        targ[i].filenum = 0;
        targ[i].cpuid = i%cpu_num;
	cout << "threadID" << i << " - launched." << endl;
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
        pthread_create(&worker[i], NULL, (void*)worker_func, (void*)&targ[i]);
    }
	
    for (i = 1; i < thread_num; ++i) 
        pthread_join(worker[i], NULL);

    // print_result(&targ[0]);

    // double avg = global_duration / (double)global_counter;
    // cout << global_counter << endl;
    // printf("avg:%10f\n", avg);

    // printf("total# of files :%d\n", global_counter);
    //cout << "[insertion]avg time for insertion:" << avg << endl;
    
    // printf("[insertion]total duration time insertion:%f\n", global_duration);
    // cout << "avg:" << avg << endl;
    
    clock_gettime(CLOCK_REALTIME, &startTime);
    sleepTime.tv_sec = 0;
    sleepTime.tv_nsec = 123;
    
    std::map<unsigned long long, long> final;

    int tmp_counter = 0;
    for(auto itr = TbbVec_timestamp.begin(); itr != TbbVec_timestamp.end(); ++itr) {
      final.insert(std::make_pair((unsigned long long)(itr->first), long(itr->second)));
      tmp_counter++;
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
    // printf("[insertion and sorting] elapsed time of sort:%f - %d \n",tmp, tmp_counter);

    ofstream outputfile("tmp-counts");
    for(auto itr = final.begin(); itr != final.end(); ++itr) {

      std::string timestamp = to_string(itr->first);

      outputfile << timestamp.substr(0,4) << "-" << timestamp.substr(4,2) << "-" << timestamp.substr(6,2) << " "
		 << timestamp.substr(8,2) << ":" << timestamp.substr(10,2) << ":" << timestamp.substr(12,2)
		 << "." << timestamp.substr(14,3) << ","
		 << itr->second << endl; 
    }
    outputfile.close();

    cout << "FINISHED: " << ingress_counter_global << ":" << egress_counter_global << endl;
    
    return 0;
}
