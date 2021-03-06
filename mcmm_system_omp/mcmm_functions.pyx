#cython: profile=True
#cython: boundscheck=False
#cython: wraparound=False
#cython: cdivision=True

cdef void cg_M(double** M, double** C, double** X, double** R, int I, int J, int K, 
					double normConstant, double l, double u):
	c_mcmm_functions.cg_M(M, C, X, R, I, J, K, normConstant, l, u)

cdef double cg_C(double** C, double** M, double** X, double** R, int I, int J, int K, 
				double normConstant, double l, double u):
	return c_mcmm_functions.cg_C(C, M, X, R, I, J, K, normConstant, l, u)


# cdef double R_and_E(double** R, double** M, double* M_data, int* M_indices, int* M_indptr, 
# 				double* vec_C, double** X, 
# 				int I, int J, int K, double normConstant):
# cdef double R_and_E(double** R, double** M, double* M_data, int* M_indices, int* M_indptr, 
# 				double* vec_C, double** X,
# 				int I, int J, int K, double normConstant):
# 	return c_mcmm_functions.R_and_E(R, M, M_data, M_indices, M_indptr, 
# 					vec_C, X, I, J, K, normConstant)

cdef double R_and_E_2(double** R, double** M, double** C, double** X,
				int I, int J, int K, double normConstant):
	return c_mcmm_functions.R_and_E_2(R, M, C, X, I, J, K, normConstant)

cdef int get_cluster_to_split(double** M, double* M_data, int* M_indices, int* M_indptr, 
				double** C, double** X, double** R, unsigned int I, unsigned int J, unsigned int K, 
				double normConstant):
	return c_mcmm_functions.cluster_to_split(M, M_data, M_indices, M_indptr, 
				C, X, R, I, J, K, normConstant)