
#include <iostream>
#include <fstream>
#include "KalmanFilter.h"

// #define LINE_NUM 5000
#define CHUNK_SIZE 5

using namespace std;
// static float measure[LINE_NUM] = {0};

void readFromFile(char *fname, int nData, float *measure)
{
  std::ifstream ifs(fname);
  std::string str;
  int counter;
  
  counter = 0;
  while(getline(ifs,str))
    {
      measure[counter] = std::atof(str.c_str()); 
      counter = counter + 1;
    }
}

int main(int argc, char const *argv[])
{
  int i;
  int nData;
  int counter = 0;
  
  nData = atoi(argv[2]);
  float* measure = new float[atoi(argv[2])];
  float* tmp = new float[25];

  float* all = new float[atoi(argv[2])];
  float* diff = new float[atoi(argv[2])];
  
  readFromFile(argv[1], int(argv[2]), measure);

  /*
  for(i=0;i<nData;i++)
    {
      cout << measure[i] << endl;
    }
  */  

  MatrixXf A(1, 1); A << 1;
  MatrixXf H(1, 1); H << 1;
  MatrixXf Q(1, 1); Q << 0;
  MatrixXf R(1, 1); R << 0.1;
  VectorXf X0(1); X0 << 0;
  MatrixXf P0(1, 1); P0 << 1;

  /*
  KalmanFilter filter1(1, 0);

  filter1.setFixed(A, H, Q, R);
  filter1.setInitial(ctorXf Z(1);
  */

  ofstream outputfile("tmp");

  counter = 0;
  for (int i = 0; i < nData - CHUNK_SIZE; ++i)
  {
    KalmanFilter filter1(1, 0);

    filter1.setFixed(A, H, Q, R);
    filter1.setInitial(X0, P0);

    VectorXf Z(1);
    
    for(int j = 0; j < CHUNK_SIZE; j++)
      {
	tmp[j] = measure[i+j];
	
	filter1.predict(); 
	Z << tmp[j];
	filter1.correct( Z ); 

	/*
	cout << tmp[j] << "," << filter1.X << endl;
	outputfile<< filter1.X << endl;
	*/
	all[counter] = all[counter] + tmp[j];
      }

    counter = counter + 1;
	  
  }

  for (int i = 0; i < counter; ++i)
    diff[i] = all[i+1]-all[i];

  for (int i = 0; i < counter; ++i)
    cout << fabs(diff[i]) << endl;
  
  outputfile.close();

  return 0;
}
