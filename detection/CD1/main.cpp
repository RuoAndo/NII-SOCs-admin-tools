
#include <iostream>
#include <fstream>
#include "KalmanFilter.h"

using namespace std;
static float measure[288] = {0};

void readFromFile()
{
  std::ifstream ifs("data");
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
  readFromFile();

  MatrixXf A(1, 1); A << 1;
  MatrixXf H(1, 1); H << 1;
  MatrixXf Q(1, 1); Q << 0;
  MatrixXf R(1, 1); R << 0.1;
  VectorXf X0(1); X0 << 0;
  MatrixXf P0(1, 1); P0 << 1;
  
  KalmanFilter filter1(1, 0);

  filter1.setFixed(A, H, Q, R);
  filter1.setInitial(X0, P0);

  VectorXf Z(1);

  for (int i = 0; i < 288; ++i)
  {
    filter1.predict(); 
    Z << measure[i];
    filter1.correct( Z ); 
  
    cout << measure[i] << "," << filter1.X << endl;
  }

	return 0;
}
