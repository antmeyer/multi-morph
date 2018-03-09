#cython: profile=True
#cython: boundscheck=False
#cython: wraparound=False
#cython: cdivision=True

ctypedef double FLOAT

cdef extern from "predict_c_funcs.h":
	FLOAT R_and_E(FLOAT** R, FLOAT* M_data, int * M_indices, 
						int * M_indptr, FLOAT** C, FLOAT** X, 
						int I, int J, int K, FLOAT normConstant)

	FLOAT R_and_E_omp(FLOAT** R, FLOAT* M_data, int * M_indices, 
						int * M_indptr, FLOAT** C, FLOAT** X, 
						int I, int J, int K, FLOAT normConstant)

	FLOAT R_and_E_nsp(FLOAT** R, FLOAT** M, FLOAT** C, FLOAT** X,
					int I, int J, int K, FLOAT normConstant)

	FLOAT R_and_E_nsp_omp(FLOAT** R, FLOAT** M, FLOAT** C, FLOAT** X,
					int I, int J, int K, FLOAT normConstant)

	FLOAT R_E_and_Grad_C(FLOAT** Grad, FLOAT* M_data, int * M_indices, 
							int * M_indptr, FLOAT** C, FLOAT** X, FLOAT** R,
							int I, int J, int K, FLOAT normConstant)

	FLOAT R_E_and_Grad_C_omp(FLOAT** Grad, FLOAT* M_data, 
							int * M_indices, int * M_indptr,
							FLOAT** C, FLOAT** X, FLOAT** R,
							int I, int J, int K, FLOAT normConstant)				

	FLOAT R_E_and_Grad_C_nsp(FLOAT** Grad,
							FLOAT** M, FLOAT** C, FLOAT** X, FLOAT** R,
							int I, int J, int K, FLOAT normConstant)

	FLOAT R_E_and_Grad_C_nsp_omp(FLOAT** Grad,
							FLOAT** M, FLOAT** C, FLOAT** X, FLOAT** R,
							int I, int J, int K, FLOAT normConstant)			

	FLOAT r_and_e(FLOAT* r, FLOAT* m, FLOAT *C_data, int *C_indices, 
				int *C_indptr, FLOAT* x, int J, int K, FLOAT normConstant) 

	FLOAT r_and_e_omp(FLOAT* r, FLOAT* m, FLOAT *C_data, int *C_indices, 
				int *C_indptr, FLOAT* x, int J, int K, FLOAT normConstant) 

	FLOAT r_and_e_nsp(FLOAT* r, FLOAT* m, FLOAT ** C, FLOAT* x,
					int J, int K, FLOAT normConstant)

	FLOAT r_and_e_nsp_omp(FLOAT* r, FLOAT* m, FLOAT ** C, 
						FLOAT* x, int J, int K, FLOAT normConstant) 

	FLOAT r_e_and_grad_m(FLOAT* grad, FLOAT* m, 
				FLOAT *C_data, int *C_indices, 
				int *C_indptr, FLOAT* x, FLOAT* r,  
				int J, int K, FLOAT normConstant)

	FLOAT r_e_and_grad_m_omp(FLOAT* grad, FLOAT* m, FLOAT *C_data, int *C_indices, 
				int *C_indptr, FLOAT* x, FLOAT* r,
				int J, int K, FLOAT normConstant)

	FLOAT r_e_and_grad_m_nsp(FLOAT* grad, FLOAT* m, FLOAT **C, 
				FLOAT* x, FLOAT* r,
				int J, int K, FLOAT normConstant)

	FLOAT r_e_and_grad_m_nsp_omp(FLOAT* grad, FLOAT* m, FLOAT **C, 
				FLOAT* x, FLOAT* r, int J, int K, FLOAT normConstant)

	int inv_diag_bfgs(FLOAT* diagH, FLOAT* s, FLOAT* y, FLOAT* Hy, 
						FLOAT sTy, int N, FLOAT* p)
		
	int inv_diag_bfgs_omp(FLOAT* diagH, FLOAT* s, FLOAT* y, FLOAT* Hy, 
						FLOAT sTy, int N, FLOAT* p)

	int cluster_to_split_omp(FLOAT* M_data, int* M_indices, int* M_indptr, FLOAT** C, 
					FLOAT** X, FLOAT** R, int I, int J, int K, FLOAT normConstant)

	int cluster_to_split_nsp(FLOAT** M, FLOAT** C, 
					FLOAT** X, FLOAT** R, int I, int J, int K, FLOAT normConstant)

	int cluster_to_split_nsp_omp(FLOAT** M, FLOAT** C, 
					FLOAT** X, FLOAT** R, int I, int J, int K, FLOAT normConstant)

# cdef extern from "arr_math.h":
# 	void init_consec_1( FLOAT *array_ptr, int M )
# 	void init_consec_2( FLOAT *array_ptr, int M )
# 	void init_consec_3( FLOAT *array_ptr, int M )
# 	void init_consec_4( FLOAT *array_ptr, int M )
# 	void init_zeros( FLOAT *array_ptr, int M )
# 	void init_const( FLOAT *array_ptr, int M, FLOAT constant)
# 	FLOAT array_norm( FLOAT *array_ptr, int M )
# 	FLOAT array_sum( FLOAT *array_ptr, int M )
# 	void sum_of_vectors(FLOAT *array1_ptr, FLOAT *array2_ptr, FLOAT *result, int M )
# 	void elem_subtract(FLOAT *array1_ptr, FLOAT *array2_ptr, FLOAT *difference, int M)
# 	void between0and1(FLOAT *array_ptr, int M)