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

  unsigned long long counter = 20201124000000;
  unsigned long long counter2 = 0;
  
  ofstream outfile;
  outfile.open("data.dat",ios::trunc | ios::out);

  std::srand( time(NULL) );
  
  for(int j=0;j<NWAVES;j++)
    {  
      for(int i=0;i<NSAMPLES;i++)
	{
	  float rads = M_PI/180;
	  outfile << counter << "," << (float)(3276*sin(3.6*i*rads)+32767) + rand() % 3000 << endl;
	  counter2++;

	  if(counter2%10==0)
	    counter = counter + 1;
	}
    }
  outfile.close();
  return 0;
}
