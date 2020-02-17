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
#include "timer.h"

#include <iostream>
#include <fstream>

#include<boost/spirit/include/qi.hpp>
#include <boost/fusion/include/std_pair.hpp>
#include <boost/any.hpp>
#include <boost/tokenizer.hpp>
#include <boost/date_time/posix_time/posix_time.hpp>

#include "csv.hpp"

#include "tbb/task_scheduler_init.h"
#include "tbb/concurrent_hash_map.h"
#include "tbb/blocked_range.h"
#include "tbb/parallel_for.h"  

#define WORKER_THREAD_NUM (33)
#define MAX_QUEUE_NUM (1024)
#define END_MARK_FNAME   "///"
#define END_MARK_FLENGTH 3

typedef struct _tms_string {
    std::string timestamp_string;
    pthread_mutex_t mutex;    
} tms_string_t;
tms_string_t tms_string;

namespace qi = boost::spirit::qi;
namespace ascii = boost::spirit::ascii;

using namespace std;
using namespace tbb;

using namespace tbb;

struct HashCompare {
    static size_t hash( std::string x ) {
    return x.length();
  }
    static bool equal( std::string x, std::string y ) {
    return x==y;
  }
};

typedef concurrent_hash_map<std::string, int, HashCompare> TimeStamp_msec;
static TimeStamp_msec timestamp_msec;    

template<typename Iterator>
struct json_grammar : qi::grammar<Iterator, boost::any(), ascii::space_type>
{
  json_grammar()
    : json_grammar::base_type(element)
  {
    number %= qi::double_;
    date %= qi::lexeme['"' >> (qi::long_ - '/') >> (qi::long_ - '/') >> (qi::long_ - '/') >>
		       (qi::long_ - ':') >> (qi::long_ - ':') >> (qi::long_) >> '"'];

    array %= qi::eps >> '[' >> element % ',' >> ']';
    array2 %= qi::eps >> '[' >> element >> ']';
    
    string %= qi::lexeme['"' >> *(ascii::char_ - '"' | '/' | '-' )>> '"'];
    key_value %= string >> ':' >> element;
    object %= qi::eps >> '{' >> key_value % ',' >> '}';
    element %= array | object | string | number | array2 | date;
  }

  qi::rule<Iterator, std::vector<boost::any>(), ascii::space_type> array;
  qi::rule<Iterator, std::vector<boost::any>(), ascii::space_type> array2;
  qi::rule<Iterator, std::pair<std::string, boost::any>(), ascii::space_type> key_value;
  qi::rule<Iterator, std::map<std::string, boost::any>(), ascii::space_type> object;
  qi::rule<Iterator, std::string(), ascii::space_type> string;
  qi::rule<Iterator, double(), ascii::space_type> number;

  qi::rule<Iterator, boost::any(), ascii::space_type> date;
  qi::rule<Iterator, boost::any(), ascii::space_type> element;
};

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
    int thread_id;
    queue_t* q;
    char* srchstr;
    char* dirname;
    int filenum;
} thread_arg_t;

std::string now_str()
{
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

int traverse_file(char* filename, char* srchstr, int thread_id) {

  typedef json_grammar<std::string::const_iterator> Parser;
  Parser p;

  int linecounter = 0;
  
  ifstream ifs(filename, ios::in);
  if(!ifs){
    cerr << "Error: file not opened." << endl;
    return 1;
  }

  string tmp;
  while(getline(ifs, tmp)){
    const std::string str = tmp;
    
    boost::any result;
    if(qi::phrase_parse(str.begin(), str.end(), p, ascii::space, result))
      {
	std::map<std::string, boost::any> p = boost::any_cast<std::map<std::string, boost::any>>(result);

	/*
	  std::cout << boost::any_cast<std::string>(p["capture_time"]) << ",";
	  std::cout << boost::any_cast<std::string>(p["source_ip"]) << std::endl;
	*/

        std::string timestamp_string =  boost::any_cast<std::string>(p["capture_time"]);

        TimeStamp_msec::accessor a;
        timestamp_msec.insert(a, timestamp_string);
        a->second += 1;

	if(linecounter%1000==0 && linecounter > 10)
	  std::cout << "[" << now_str() << "] " << "threadID:" << thread_id << ":" << linecounter << " lines - done." << endl;

      }
	
      linecounter++;
    
  }

  ifs.close();    

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

    int thread_id = arg->thread_id;

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

        n = traverse_file(fname, srchstr, thread_id);
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

        n = traverse_file(fname, srchstr, thread_id);

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

    int line_counter = 0;
    
    if (argc != 2) {
      printf("Usage: ./traverse [DIR]\n"); return 0;
    }
    cpu_num = sysconf(_SC_NPROCESSORS_CONF);

    initqueue(&q);

    for (i = 0; i < thread_num; ++i) {
        targ[i].q = &q;
        // targ[i].srchstr = argv[1];
        targ[i].dirname = argv[1];
        targ[i].filenum = 0;
	targ[i].thread_id = i;
        targ[i].cpuid = i%cpu_num;
    }
    result.fname = NULL;

    start_timer(&t);

    pthread_mutex_init(&result.mutex, NULL);

    pthread_create(&master, NULL, (void*)master_func, (void*)&targ[0]);
    for (i = 1; i < thread_num; ++i)
        pthread_create(&worker[i], NULL, (void*)worker_func, (void*)&targ[i]);
	
    for (i = 1; i < thread_num; ++i) 
        pthread_join(worker[i], NULL);

    travdirtime = stop_timer(&t);
    print_timer(travdirtime);

    print_result(&targ[0]);
    for (i = 1; i < thread_num; ++i) {
        if ((targ[i].q)->fname[i] != NULL) free((targ[i].q)->fname[i]);
    }
    if(result.fname != NULL) free(result.fname);

    line_counter = 0;
    for( TimeStamp_msec::iterator i=timestamp_msec.begin(); i!=timestamp_msec.end(); ++i )
      {
	if(line_counter % 100000 && line_counter > 1)
	    cout << i->first << "," << i->second << endl;

	line_counter++;
      }                         

    return 0;
}
