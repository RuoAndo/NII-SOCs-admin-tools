#include <iostream>
#include <vector>
#include <map>
#include <set>
#include <algorithm>
#include <cmath>
using namespace std;

template <class T>ostream &operator<<(ostream &o,const vector<T>&v)
{o<<"{";for(int i=0;i<(int)v.size();i++)o<<(i>0?", ":"")<<v[i];o<<"}"<<endl;;return o;}

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
        int pi = (abset[j].first * h + abset[j].second)%mod;
        dataset[j].push_back(make_pair<int,int>(pi, i));
      }

    }

    for(int i=0; i<p; i++){
      sort(dataset[i].begin(), dataset[i].end());

      /* //ハッシュ値
      cout << i << "=====" << endl;
      for(int j=0; j<dataset[i].size(); j++){
        cout << dataset[i][j].first << endl;
      }
      //*/
    }
  }

  vector<int> search(const vector<double> v, double th, const vector< vector<double> >& list){
    set<int> ret;

    cout << v << endl;
    
    int h = 0;
    for(int j=0; j<d; j++){
      h <<= 1;
      if(dot(v, rndvec[j])>=0.0){
        h += 1;
      }else{
        h += 0;
      }
    }
    
    for(int j=0; j<p; j++){
      int pi = (abset[j].first * h + abset[j].second)%mod;

      int lb = 0, ub = dataset[j].size();
      while(ub-lb>1){
        int m = (lb+ub)/2;
        if(dataset[j][m].first <= pi) lb = m;
        else ub = m;
      }
      
      for(int b = -B; b<=B; b++){
        if(0<=lb+b && lb+b < dataset[j].size()){
          int idx = dataset[j][lb+b].second;
          if(cossim(v, list[idx]) >= th){
            ret.insert(idx);
          }
        }
      }
      
      /*
      while(lb>=0 && dataset[j][lb].first == pi){
        int idx = dataset[j][lb].second;
        if(cossim(v, list[idx]) >= th){
          ret.insert(idx);
        }
        lb--;
      }
      */
    }

    return vector<int>(ret.begin(), ret.end());
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

  // cout << list << endl;

  lshs.createDataSet(list);

  vector<double> v;
  for(int i=0; i<k; i++){
    v.push_back( frand()*2.0-1.0 );
  }

  cout << v << endl;
  
  vector<int> res = lshs.search(v, 0.9, list);

  for(int i=0; i<res.size(); i++){
    cout << res[i] << " : " << lshs.cossim(list[res[i]], v) << endl;
  }

  cout << "----" << endl;
  for(int i=0; i<list.size(); i++){
    if(lshs.cossim(list[i], v) >= 0.9){
      cout << i << " : " << lshs.cossim(list[i], v) << endl;
    }
  }

  return 0;
}
