#cython: profile=True
#cython: boundscheck=False
#cython: wraparound=False
#cython: cdivision=True

cimport cython
ctypedef int uint

cdef extern from "c_funcs.h":
	void cg_M(double** M,
				double** C,
				double** X, double** R,
				unsigned int I, unsigned int J, unsigned int K, double normConstant,
				double l, double u)

	double cg_C(double** C,
				double** M,
				double** X, double** R,
				unsigned int I, unsigned int J, unsigned int K, double normConstant,
				double l, double u)

	# double R_and_E(double** R, double** M, double* M_data, int* M_indices, int * M_indptr, 
	# 				double* vec_C, double** X, 
	# 				unsigned int I, unsigned int J, 
	# 				unsigned int K, double normConstant)

	double R_and_E_2(double** R, double** M, double** C, double** X,
				unsigned int I, unsigned int J, unsigned int K, double normConstant)

	int cluster_to_split(double** M, double* M_data, int* M_indices, int * M_indptr, double** C, 
						double** X, double** R, unsigned int I, unsigned int J, 
						unsigned int K, double normConstant)