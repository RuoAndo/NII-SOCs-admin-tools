#include <Eigen/Dense>
using namespace Eigen;
class KalmanFilter {

	public:

		int n;
		int m;

		MatrixXf A;
		MatrixXf B;
		MatrixXf H;
		MatrixXf Q;
		MatrixXf R;
		MatrixXf I;

		VectorXf X; 
		MatrixXf P; 
		MatrixXf K; 

		VectorXf X0; 
		MatrixXf P0; 
		
		KalmanFilter(int _n,  int _m);

		void setFixed ( MatrixXf _A, MatrixXf _H, MatrixXf _Q, MatrixXf _R );

		void setFixed ( MatrixXf _A, MatrixXf _B, MatrixXf _H, MatrixXf _Q, MatrixXf _R );

		void setInitial( VectorXf _X0, MatrixXf _P0 );
		
		void predict ( void );

		void predict ( VectorXf U );

		void correct ( VectorXf Z );

};





