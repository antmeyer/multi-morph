#cython: profile=True
#cython: boundscheck=False
#cython: wraparound=False
#cython: cdivision=True

cimport cython
#cimport numpy as np
#ctypedef np.float64_t double

cdef extern from "c_funcs.h":
	double cg_M(double** M,
				double** C,
				double** X, double** R,
				int I, int J, int K, double normConstant,
				double l, double u)

	double cg_C(double** C,
				double** M,
				double** X, double** R,
				int I, int J, int K, double normConstant,
				double l, double u)

	double R_and_E(double** R, double** M, double* vec_C, double** X,
					int I, int J, int K, double normConstant)

	double R_and_E_2(double** R, double** M, double** C, double** X,
				int I, int J, int K, double normConstant)

	int cluster_to_split(double** M, double** C, 
						double** X, double** R, int I, int J, int K, double normConstant)