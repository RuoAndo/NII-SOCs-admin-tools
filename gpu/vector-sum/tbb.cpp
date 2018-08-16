#include <iostream>
#include <ctime>
#include <stdlib.h>

#include "tbb/task_scheduler_init.h"
#include "tbb/blocked_range2d.h"
#include "tbb/parallel_for.h"

using namespace std;
using namespace tbb;

const long M=250000000;

float a[M];
float b[M];
float c[M];

class MatrixMult{
  float (*a);
  float (*b);
  float (*c);
public:
    void operator() ( const blocked_range<size_t>& range ) const {
      float (*aa) = a;
      float (*bb) = b;
      float (*cc) = c;
      float total = 0;
      
      for (long i = range.begin(); i != range.end(); ++i){
            total += a[i] + b[i];
	    c[i] = total;
      }
	    
      for (long i = range.begin(); i != range.end(); ++i){
            total += a[i] - b[i];
	    c[i] = total;
      }
    }
    MatrixMult (float aa[M], float bb[M], float cc[M]):
       a(aa), b(bb), c(cc) {}
};


void initialData(float *ip, long size)
{
    time_t t;
    srand((unsigned) time(&t));

    for (long i = 0; i < size; i++)
    {
      ip[i] = (float)rand();
    }

    return;
}

int main(int argc, char *argv)
{
    task_scheduler_init init;

    time_t t;
    srand((unsigned)time(&t));

    initialData(a, M);
    initialData(b, M);

    parallel_for( blocked_range<size_t>(0, M),
            MatrixMult(a, b, c) );
    
    cout << "done" << endl;

    for (size_t i=0; i<5; i++) {
      cout << a[i] << " ";
    }
    cout << endl;

    for (size_t i=0; i<5; i++) {
      cout << b[i] << " ";
    }
    cout << endl;

    for (size_t i=0; i<5; i++) {
      cout << c[i] << " ";
    }
    cout << endl;
    
    return 0;
}

