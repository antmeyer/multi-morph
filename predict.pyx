#cython: profile=True
#cython: boundscheck=False
#cython: wraparound=False
#cython: cdivision=True

cdef FLOAT get_R_and_E(FLOAT** R, FLOAT* M_data, int* M_indices, int* M_indptr,
						FLOAT** C, FLOAT** X,
						int I, int J, int K, FLOAT normConstant):
	return c_predict.R_and_E( R, M_data, M_indices, M_indptr, C, X, I, J, K, normConstant )

cdef FLOAT get_R_and_E_omp(FLOAT** R,
						FLOAT* M_data, int* M_indices, int* M_indptr,
						FLOAT** C, FLOAT** X,
						int I, int J, int K, FLOAT normConstant):
	return c_predict.R_and_E_omp( R, M_data, M_indices, M_indptr, C, X, I, J, K, normConstant )

cdef FLOAT get_R_and_E_nsp(FLOAT** R, FLOAT** M, FLOAT** C, FLOAT** X, int I, int J, int K, 
						FLOAT normConstant):
	return c_predict.R_and_E_nsp( R, M, C, X, I, J, K, normConstant )

cdef FLOAT get_R_and_E_nsp_omp(FLOAT** R, FLOAT** M, FLOAT** C, FLOAT** X, int I, int J, int K, 
						FLOAT normConstant):	
	return c_predict.R_and_E_nsp_omp( R, M, C, X, I, J, K, normConstant )

cdef FLOAT get_R_E_and_Grad_C(FLOAT** Grad,
						FLOAT* M_data, int * M_indices, int * M_indptr,
						FLOAT** C, FLOAT** X, FLOAT** R,
						int I, int J, int K, FLOAT normConstant):
	return c_predict.R_E_and_Grad_C(Grad, M_data, M_indices, M_indptr,
						C, X, R, I, J, K, normConstant)

cdef FLOAT get_R_E_and_Grad_C_omp(FLOAT** Grad,
						FLOAT* M_data, int * M_indices, int * M_indptr,
						FLOAT** C, FLOAT** X, FLOAT** R,
						int I, int J, int K, FLOAT normConstant):
	return c_predict.R_E_and_Grad_C_omp(Grad, M_data, M_indices, M_indptr,
						C, X, R, I, J, K, normConstant)

cdef FLOAT get_R_E_and_Grad_C_nsp(FLOAT** Grad, FLOAT** M, FLOAT** C, FLOAT** X, FLOAT** R,
						int I, int J, int K, FLOAT normConstant):
	return c_predict.R_E_and_Grad_C_nsp( Grad, M, C, X, R, I, J, K, normConstant )

cdef FLOAT get_R_E_and_Grad_C_nsp_omp(FLOAT** Grad, FLOAT** M, FLOAT** C, FLOAT** X, FLOAT** R,
						int I, int J, int K, FLOAT normConstant):
	return c_predict.R_E_and_Grad_C_nsp_omp( Grad, M, C, X, R, I, J, K, normConstant )



cdef FLOAT get_r_and_e(FLOAT* r, FLOAT* m, FLOAT * C_data, int * C_indices, int * C_indptr, 
						FLOAT* x, int J, int K, FLOAT normConstant):
	return c_predict.r_and_e(r, m, C_data, C_indices, C_indptr, x, J, K, normConstant)

cdef FLOAT get_r_and_e_omp( FLOAT* r, FLOAT* m, FLOAT *C_data, int *C_indices, int *C_indptr, 
						FLOAT* x, int J, int K, FLOAT normConstant ):
	return c_predict.r_and_e_omp(r, m, C_data, C_indices, C_indptr, x, J, K, normConstant)

cdef FLOAT get_r_and_e_nsp(FLOAT* r, FLOAT* m, FLOAT **C, FLOAT* x, int J, int K, FLOAT normConstant):
	return c_predict.r_and_e_nsp(r, m, C, x, J, K, normConstant)

cdef FLOAT get_r_and_e_nsp_omp(FLOAT* r, FLOAT* m, FLOAT **C, FLOAT* x, int J, int K, 
						FLOAT normConstant):
	return c_predict.r_and_e_nsp_omp(r, m, C, x, J, K, normConstant)

cdef FLOAT get_r_e_and_grad_m(FLOAT* grad, FLOAT* m, FLOAT *C_data, int *C_indices, int *C_indptr, 
						FLOAT* x, FLOAT* r, int J, int K, FLOAT normConstant):
	return c_predict.r_e_and_grad_m(grad, m, C_data, C_indices, C_indptr, x, r, J, K, normConstant)

cdef FLOAT get_r_e_and_grad_m_omp(FLOAT* grad, FLOAT* m, FLOAT *C_data, int *C_indices, int *C_indptr, 
						FLOAT* x, FLOAT* r, int J, int K, FLOAT normConstant):
	return c_predict.r_e_and_grad_m_omp(grad, m, C_data, C_indices, C_indptr, x, r, J, K, normConstant)

cdef FLOAT get_r_e_and_grad_m_nsp(FLOAT* grad, FLOAT* m, FLOAT **C, 
						FLOAT* x, FLOAT* r, int J, int K, FLOAT normConstant):
	return c_predict.r_e_and_grad_m_nsp(grad, m, C, x, r, J, K, normConstant)

cdef FLOAT get_r_e_and_grad_m_nsp_omp(FLOAT* grad, FLOAT* m, 
						FLOAT **C, FLOAT* x, FLOAT* r, int J, int K, FLOAT normConstant):
	return c_predict.r_e_and_grad_m_nsp_omp(grad, m, C, x, r, J, K, normConstant)


cdef void get_inv_diag_bfgs(FLOAT* diagH, FLOAT* s, FLOAT* y, FLOAT* Hy, FLOAT sTy, int N, 
			FLOAT* p):
	c_predict.inv_diag_bfgs( diagH, s, y, Hy, sTy, N, p)

cdef void get_inv_diag_bfgs_omp(FLOAT* diagH, FLOAT* s, FLOAT* y, FLOAT* Hy, FLOAT sTy, int N, 
			FLOAT* p):
	c_predict.inv_diag_bfgs_omp(diagH, s, y, Hy, sTy, N, p)


cdef int get_cluster_to_split_omp(FLOAT* M_data, int* M_indices, int* M_indptr, FLOAT** C, 
					FLOAT** X, FLOAT** R, int I, int J, int K, FLOAT normConstant):
	return c_predict.cluster_to_split_omp(M_data, M_indices, M_indptr, C, 
					X, R, I, J, K, normConstant)

cdef int get_cluster_to_split_nsp(FLOAT** M, FLOAT** C, 
					FLOAT** X, FLOAT** R, int I, int J, int K, FLOAT normConstant):
	return c_predict.cluster_to_split_nsp(M, C, X, R, I, J, K, normConstant)

cdef int get_cluster_to_split_nsp_omp(FLOAT** M, FLOAT** C, 
					FLOAT** X, FLOAT** R, int I, int J, int K, FLOAT normConstant):
	return c_predict.cluster_to_split_nsp_omp(M, C, X, R, I, J, K, normConstant)
