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

#include <errno.h>
#include <maxminddb.h>

#include "tbb/concurrent_hash_map.h"
#include "tbb/blocked_range.h"
#include "tbb/parallel_for.h"
#include "tbb/tick_count.h"
#include "tbb/task_scheduler_init.h"
#include "tbb/concurrent_vector.h"
#include "tbb/concurrent_unordered_map.h"

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
namespace fs = boost::filesystem;

// 2 / 1024
#define WORKER_THREAD_NUM 3
#define MAX_QUEUE_NUM 12
#define END_MARK_FNAME   "///"
#define END_MARK_FLENGTH 3

// typedef tbb::concurrent_hash_map<string, int> iTbb_Vec_timestamp;
// static iTbb_Vec_timestamp TbbVec_timestamp; 

typedef tbb::concurrent_hash_map<string, int> itbbidx;
static itbbidx tbbidx; 

// tbb::concurrent_unordered_multimap<string, string> tbbidx;
// tbb::concurrent_vector< string > data;

struct myhash {
    size_t operator()(const int& a) const {
        return 1;
    }
};

static int global_counter = 0;
static double global_duration = 0;

static int ingress_counter_global = 0;
static int egress_counter_global = 0;
static int miss_counter = 0;

extern void kernel(long* h_key, long* h_value_1, long* h_value_2, int size);

#define rad2deg(a) ((a)/M_PI * 180.0) 
#define deg2rad(a) ((a)/180.0 * M_PI) 

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
    char* iocFilename;
    int filenum;
    int mindis;
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

int traverse_file(char* filename, int thread_id, int mindis, char *iocFilename) {

    char buf[1024];
    int n = 0, sumn = 0;
    unsigned int t;

    FILE *fp;	
    char s[256];

    double earth_r = 6378.137;
    double laRe,loRe,NSD,EWD,distance;

    string line;
    string line2;

    int display_counter = 0;

    ifstream input_file(filename);
    if (!input_file.is_open()) {
        cerr << "Could not open the file - '"
             << filename << "'" << endl;
        return EXIT_FAILURE;
    }

    ifstream input_file_2(iocFilename);
    if (!input_file_2.is_open()) {
        cerr << "Could not open the file - '"
             << "gs.txt" << "'" << endl;
        return EXIT_FAILURE;
    }

    string dbname_s = "GeoLite2-City.mmdb";
    
    MMDB_s mmdb;
    int status = MMDB_open(dbname_s.c_str(), MMDB_MODE_MMAP, &mmdb);

    if (MMDB_SUCCESS != status) {
        fprintf(stderr, "\n  Can't open %s - %s\n",
                filename, MMDB_strerror(status));

        if (MMDB_IO_ERROR == status) {
            fprintf(stderr, "    IO error: %s\n", strerror(errno));
        }
        // exit(1);
	pthread_exit(0);
    }

    double lat, lng;
    double lat2, lng2;
    int gai_error, mmdb_error;
    int gai_error2, mmdb_error2;

    MMDB_entry_data_s data;
    MMDB_entry_data_s data2;

    MMDB_entry_data_list_s *entry_data_list2 = NULL;
    MMDB_entry_data_list_s *entry_data_list = NULL;
    MMDB_lookup_result_s result;
    MMDB_lookup_result_s result2;
    
    while (getline(input_file, line)){

      /* lookup */

      result = MMDB_lookup_string(&mmdb, line.c_str(), &gai_error, &mmdb_error);

      if (0 != gai_error) {
	// pthread_exit(0);
	cout << "lookup error at thread ID:" + to_string(thread_id) << ":filename:" << filename << endl;
	continue;
      }

      if (MMDB_SUCCESS != mmdb_error) {
        fprintf(stderr,
                "\n  Got an error from libmaxminddb: %s\n\n",
                MMDB_strerror(mmdb_error));
	// pthread_exit(0);
	cout << "parse error" << endl; 
	continue;
      }

      if (result.found_entry) {
        int status = MMDB_get_entry_data_list(&result.entry,
                                              &entry_data_list);

        if (MMDB_SUCCESS != status) {
            fprintf(
                stderr,
                "Got an error looking up the entry data - %s\n",
                MMDB_strerror(status));
	    
	    cout << "parse error" << endl; 
	    // pthread_exit(0);

        }
	
	MMDB_get_value(&result.entry, &data, "location", "latitude", NULL);
	lat = data.double_value;
	MMDB_get_value(&result.entry, &data, "location", "longitude", NULL);
	lng = data.double_value;

      }

      while (getline(input_file_2, line2)){
	result2 =  MMDB_lookup_string(&mmdb, line2.c_str(), &gai_error2, &mmdb_error2);

	if (0 != gai_error2) {
	  cout << "lookup error 1" << endl; 
	  continue;
	}

	if (MMDB_SUCCESS != mmdb_error2) {
	  fprintf(stderr,
                "\n  Got an error from libmaxminddb: %s\n\n",
                MMDB_strerror(mmdb_error2));
	  cout << "lookup error 2" << endl; 
	  continue;
	}

	if (result2.found_entry) {
        int status2 = MMDB_get_entry_data_list(&result2.entry,
                                              &entry_data_list2);

        if (MMDB_SUCCESS != status2) {
            fprintf(
                stderr,
                "Got an error looking up the entry data - %s\n",
                MMDB_strerror(status2));
  	    cout << "lookup error 3" << endl;
	    continue;
          }
	}


	MMDB_get_value(&result2.entry, &data2, "location", "latitude", NULL);
	lat2 = data2.double_value;
	
	MMDB_get_value(&result2.entry, &data2, "location", "longitude", NULL);
	lng2 = data2.double_value;


	/*
	if (display_counter % 50 == 0)
	  {
	    cout << "[thread_id]:" + to_string(thread_id) + ":" + filename + ":" << line << ":"
		 << lat << "," << lng << "->" << line2 << ":" << lat2 << "," << lng2 << ":" << display_counter << endl;
	  }
	*/
	
	// MMDB_free_entry_data(entry_data2);
	
	laRe = deg2rad(lat - lat2);
	loRe = deg2rad(lng - lng2);
	NSD = earth_r*laRe;
	EWD = cos(deg2rad(lat2))*earth_r*loRe;
	distance = sqrt(pow(NSD,2)+pow(EWD,2));

	/*
	if(display_counter % 100 == 0)
	  {
	  cout << "[thread_id]:" + to_string(thread_id) + ":" + filename + ":" << line << ":" << lat << "," << lng << "->"  << line2 << ":" << lat2 << "," << lng2 << "," << "distance:" << distance << endl;
	  }
	*/	  

	if (distance <= mindis)
	  {
	  cout << "[BINGO][thread_id]:" + to_string(thread_id) + ":" + filename + ":" << line << ":" << lat << "," << lng << "->"
	  << line2 << ":" << lat2 << "," << lng2 << "," << "distance:" << distance << endl;

	  // typedef tbb::concurrent_hash_map<string, string> itbbidx;
	  // static itbbidx tbbidx; 

	  string gs_src = line + "," + line2; 
	  // string dns_dst_dis = distance; 
      
	  itbbidx::accessor t;
	  tbbidx.insert(t, gs_src);
	  t->second = distance;
	  
	  }
	

	display_counter++;
	
      } // while(2)

    }

    MMDB_free_entry_data_list(entry_data_list2);
    MMDB_free_entry_data_list(entry_data_list);
	
    cout << "[thread_id]:" << thread_id << ":filename:" << filename << "- finished" << endl; 

    MMDB_close(&mmdb);

    input_file.close();
    input_file_2.close();
    
    // pthread_exit(0);
    return 0;  
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
    int mindis = arg->mindis;
   
    char* iocFilename = arg->iocFilename;
    
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

        n = traverse_file(fname, thread_id, mindis, iocFilename);
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

        n = traverse_file(fname, thread_id, mindis, iocFilename);

	/*
        if (n > my_result_num) {
            my_result_num = n;
            my_result_len = flen;
            my_result_fname = (char*)alloca(flen);
            strcpy(my_result_fname, fname);
        }
	*/
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
    
    if (argc != 4) {
        printf("Usage: time ./multi_measure_2 box/a/ $MINDIS iocFilename \n"); return 0;
    }
    
    
    cpu_num = sysconf(_SC_NPROCESSORS_CONF);

    initqueue(&q);

    for (i = 0; i < thread_num; ++i) {
        targ[i].q = &q;
        // targ[i].srchstr = argv[1];
        targ[i].dirname = argv[1];
	targ[i].iocFilename = argv[3];
        targ[i].filenum = 0;
        targ[i].cpuid = i%cpu_num;
	targ[i].mindis = atoi(argv[2]);
    }
    result.fname = NULL;

    /*
    start_timer(&t);
    travdirtime = stop_timer(&t);
    print_timer(travdirtime);
    */    

    cout << "Main" << endl;
    
    pthread_mutex_init(&result.mutex, NULL);

    pthread_create(&master, NULL, (void*)master_func, (void*)&targ[0]);
    for (i = 1; i < thread_num; ++i) {
        targ[i].id = i;
	cout << "[" << now_str() << "]" << " thread - " << i << " launched." << endl; 
        pthread_create(&worker[i], NULL, (void*)worker_func, (void*)&targ[i]);
    }
	
    for (i = 1; i < thread_num; ++i) 
        pthread_join(worker[i], NULL);

    printf("total# of files :%d\n", global_counter);
    clock_gettime(CLOCK_REALTIME, &startTime);
    sleepTime.tv_sec = 0;
    sleepTime.tv_nsec = 123;

    for(auto itr = tbbidx.begin(); itr != tbbidx.end(); ++itr) {

	  std::cout << "tbb:" << itr->first << "," << itr->second << std::endl;

	  /*
	  std::vector<std::string> results; 
	  boost::split(results, itr->second, boost::is_any_of(","));
	  if(atoi(results[1].c_str())==0)
	    {
	      std::cout << "ZERO:" << tbb_counter << ":" << itr->first << "," << itr->second << std::endl;
	      number_of_zero[itr->first]++;
	    }
	  */

    }


    
    return 0;
}
