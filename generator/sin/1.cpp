#include <stdio.h>
#include <fstream> 
#include <iostream>
#include <math.h>

#include <ctime>        // time
#include <cstdlib>      // srand,rand

using namespace std;

#define NSAMPLES 100
#define NWAVES 50

int main()
{
  double AMP = NSAMPLES/10;
  double RATIO = 360/NSAMPLES;
  
  ofstream outfile;
  outfile.open("data.dat",ios::trunc | ios::out);

  std::srand( time(NULL) );
  
  for(int j=0;j<NWAVES;j++)
    {  
      for(int i=0;i<NSAMPLES;i++)
	{
	  float rads = M_PI/180;
	  outfile << (float)(3276*sin(3.6*i*rads)+32767) + rand() % 3000 << endl;
	}
    }
  outfile.close();
  return 0;
}
