//#include "c_funcs.h"

double cg_M_omp(double** M,
			double** C,
			double** X, double** R,
			int I, int K, int J, double normConstant,
			double l, double u);

double cg_M_nsp_omp(double** M,
			double** C,
			double** X, double** R,
			int I, int K, int J, double normConstant,
			double l, double u);