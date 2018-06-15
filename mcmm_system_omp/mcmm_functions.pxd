#cython: profile=True
#cython: boundscheck=False
#cython: wraparound=False
#cython: cdivision=True
cimport c_mcmm_functions
cimport numpy as np
#ctypedef np.float64_t double
ctypedef unsigned int int

cdef void cg_M(double** M, double** C, double** X, double** R, int I, int J, int K, 
				double normConstant, double l, double u)

cdef double cg_C(double** C, double** M, double** X, double** R, int I, int J, int K, 
				double normConstant, double l, double u)

# cdef double R_and_E(double** R, double** M, double* M_data, int* M_indices, int* M_indptr, 
# 				double* vec_C, double** X,
# 				int I, int J, int K, double normConstant)

cdef double R_and_E_2(double** R, double** M, double** C, double** X,
				int I, int J, int K, double normConstant)
				
cdef int get_cluster_to_split(double** M, double* M_data, int* M_indices, int* M_indptr, 
				double** C, double** X, double** R, unsigned int I, unsigned int J, unsigned int K, 
				double normConstant)