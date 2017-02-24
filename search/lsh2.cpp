#include <iostream>
#include <vector>
#include <map>
#include <set>
#include <algorithm>
#include <cmath>
#include <stdio.h>
using namespace std;

static const double PI = 3.14159265358979323846264338;
unsigned long xor128(){
  static unsigned long x=123456789,y=362436069,z=521288629,w=88675123;
  unsigned long t;
  t=(x^(x<<11));x=y;y=z;z=w; return( w=(w^(w>>19))^(t^(t>>8)) );
}

double frand(){
  return xor128()%10000000/static_cast<double>(10000000);
}

double normal_rand(double mu, double sigma2){
  double sigma = sqrt(sigma2);
  double u1 = frand(), u2 = frand();
  double z1 = sqrt(-2*log(u1)) * cos(2*PI*u2);
  //double z2 = sqrt(-2*log(u1)) * sin(2*PI*u2);
  return mu + sigma*z1;
}

bool operator<(const pair<int,int>& u, const pair<int,int>& v){
  if(u.first == v.first) return u.second < v.second;
  return u.first < v.first;
}

class LSHSearch {
  const static int mod = 99991; 

  int k, d, p, B;
  vector< pair<int,int> > abset;
  vector< vector<double> > rndvec; 

  vector< vector< pair<int,int> > > dataset;

  double dot(const vector<double>& u, const vector<double>& v){
    double ret = 0;
    for(int i=0; i<k; i++){
      ret += u[i] * v[i];
    }
    return ret;
  }

public:
  double cossim(const vector<double>& u, const vector<double>& v){
    double ret = 0;
    double uu = 0, vv = 0;
    for(int i=0; i<k; i++){
      ret += u[i] * v[i];
      uu += u[i] * u[i];
      vv += v[i] * v[i];
    }
    return ret / ( sqrt(uu) * sqrt(vv) );
  }
  

public:
  LSHSearch(int k_, int d_, int p_, int B_):k(k_),d(d_),p(p_),B(B_){
    for(int i=0; i<p; i++){
      abset.push_back(make_pair<int,int>(xor128()%mod, xor128()%mod));
    }

    for(int i=0; i<d; i++){
      vector<double> tmp;
      for(int j=0; j<k; j++){
        tmp.push_back(normal_rand(0.0, 1.0));
      }
      rndvec.push_back(tmp);
    }

    vector< pair<int,int> > emp;
    for(int i=0; i<p; i++){
      dataset.push_back(emp);
    }
  }

  void createDataSet(const vector< vector<double> >& list){
    for(int i=0; i<list.size(); i++){
      
      int h = 0;
      for(int j=0; j<d; j++){
        h <<= 1;
        if(dot(list[i], rndvec[j])>=0.0){
          h += 1;
        }else{
          h += 0;
        }
      }

     
      for(int j=0; j<p; j++){

	int data, i; 
	unsigned int mask;
	/*
	mask = 1 << ( sizeof( int )*2-1 );

	for( i = 0; i < sizeof( int )*2; i++ )
	  {
	    if( h & mask )
	      printf( "1" );
	    else
	      printf( "0" );
	    mask >>= 1;
	  }
        printf("\n");
	*/

        int pi = (abset[j].first * h + abset[j].second)%mod;
        dataset[j].push_back(make_pair<int,int>(pi, i));
	// std::cout << dataset[j] << std::endl;
      }
      cout << endl;

    }

    for(int i=0; i<p; i++){
      sort(dataset[i].begin(), dataset[i].end());

      cout << i << "=====" << endl;
      for(int j=0; j<dataset[i].size(); j++){
        cout << dataset[i][j].first << endl;
      }
           
    }
  }
};


int main(int argc, char** argv){
  int k = 5; 
  int d = 4; 
  int p = 1; 
  int B = 50;

  LSHSearch lshs(k, d, p, B);

  vector< vector<double> > list;
  for(int i=0; i<1000; i++){
    vector<double> tmp;
    for(int j=0; j<k; j++){
      tmp.push_back( frand()*2.0-1.0 );
    }
    list.push_back(tmp);
  }

  lshs.createDataSet(list);

  vector<double> v;
  for(int i=0; i<k; i++){
    v.push_back( frand()*2.0-1.0 );
  }

  return 0;
}

