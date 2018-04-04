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

cdef FLOAT get_R_E_and_Grad_C_nsp_omp(FLOAT* vec_Grad, FLOAT** M, FLOAT** C, FLOAT** X, FLOAT** R,
						int I, int J, int K, FLOAT normConstant):
	return c_predict.R_E_and_Grad_C_nsp_omp( vec_Grad, M, C, X, R, I, J, K, normConstant )



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

# cdef double armijo2_M_increase_alpha_nor(double a_higher, double phi_a_higher,
# 				double a_lower, double phi_a_lower,
# 				double phi_0, double der_phi_0,
# 				double c1,
# 				double* m0, double* m,
# 				double** C, double* C_data, int* C_indices, int* C_indptr,
# 				double* x, double* r,
# 				double* d, double* d_data, int* d_indices, int* d_indptr,
# 				double normConstant, int K, int J,
# 				double lowerBound, double upperBound):
# 	return c_predict.armijo2_M_increase_alpha_nor(a_higher, phi_a_higher, 
# 				a_lower, phi_a_lower, phi_0, der_phi_0, c1, m0, m,
# 				C, C_data, C_indices, C_indptr,
# 				x, r, d, d_data, d_indices, d_indptr,
# 				normConstant, K, J,lowerBound, upperBound)

# cdef double armijo2_M_interpolate_nor(double a2, double phi_a2,
# 				double a1, double phi_a1,
# 				double phi_0, double der_phi_0,
# 				double c1, double* m0, double* m,
# 				double** C, double* C_data, int* C_indices, int* C_indptr,
# 				double* x, double* r,
# 				double* d, double* d_data, int* d_indices, int* d_indptr,
# 				double normConstant, int K, int J,
# 				double lowerBound, double upperBound):
# 	return c_predict.armijo2_M_interpolate_nor(a2, phi_a2, a1, phi_a1,
# 				phi_0, der_phi_0, c1, m0, m,
# 				C, C_data, C_indices, C_indptr,
# 				x, r, d, d_data, d_indices, d_indptr,
# 				normConstant, K, J,lowerBound, upperBound)

# cdef double quadratic_interpolate(double phi_0, double der_phi_0, double a_cur, double phi_cur):
# 	return c_predict.quadratic_interpolate(phi_0, der_phi_0, a_cur, phi_cur)

# cdef double cubic_interpolate(double ai_old, double phi_old, double phi_prime_old, 
# 							double ai, double phi, double phi_prime):
# 	return c_predict.ubic_interpolate(ai_old, phi_old, phi_prime_old, ai, phi, phi_prime)

# cdef double cubic(double phi0, double phi0_prime, 
# 				double phi_alpha0, double alpha0,
# 				double phi_alpha1, double alpha1):
# 	return c_predict.cubic(phi0, phi0_prime, phi_alpha0, alpha0, phi_alpha1, alpha1)

# cdef double armijo2_M_nor(double a_new, double a_max, double c1,
# 							double phi_0, double der_phi_0,
# 							double* m0, double* m, 
# 							double** C, 
# 							double* C_data, int* C_indices, int* C_indptr,
# 							double* x, double* r,
# 							double* d, double* d_data, int* d_indices, int* d_indptr,
# 							double normConstant, 
# 							int K, int J, int* itrs,
# 							double lowerBound, double upperBound):
# 	return c_predict.armijo2_M_nor(a_new, a_max, c1, phi_0, der_phi_0,
# 							m0, m, C, C_data, C_indices, C_indptr,
# 							x, r, d, d_data, d_indices, d_indptr,
# 							normConstant, K, J, itrs, lowerBound, upperBound)

# cdef void prelims_slmqn(double* grad,
# 					double* grad_data, int* grad_indices, int* grad_indptr,
# 					double* x,
# 					double* diagP0, int* diagP0_indices, int* diagP0_indptr,
# 					int* diagP0_zero_indices, int* diagP0_zero_indptr,
# 					double* diagP1, int* diagP1_indices, int* diagP1_indptr,
# 					int* diagP1_zero_indices, int* diagP1_zero_indptr,
# 					int* diagP2_indices, int* diagP2_indptr,
# 					int* diagP3_indices, int* diagP3_indptr,
# 					double eps, double zero_eps, int J, int K, int N, double l, double u):
# 	c_predict.prelims_slmqn(grad, grad_data, grad_indices, grad_indptr,
# 					x, diagP0, diagP0_indices, diagP0_indptr,
# 					diagP0_zero_indices, diagP0_zero_indptr,
# 					diagP1, diagP1_indices, diagP1_indptr,
# 					diagP1_zero_indices, diagP1_zero_indptr,
# 					diagP2_indices, diagP2_indptr,
# 					diagP3_indices, diagP3_indptr,
# 					eps, zero_eps, J, K, N, l, u)

# cdef void direction_slmqn(double* d, double* d_data, int* d_indices, int* d_indptr,
# 					double* x,
# 					double* grad, double* grad_data, int* grad_indices, int* grad_indptr,
# 					double** s_vecs, 
# 					double** s_vecs_data, int** s_vecs_indices, int** s_vecs_indptr, 
# 					double** y_vecs,
# 					double** y_vecs_data, int** y_vecs_indices, int** y_vecs_indptr,
# 					double* diagP0, int* diagP0_indices, int* diagP0_indptr,
# 					int* diagP0_zero_indices, int* diagP0_zero_indptr,
# 					double* diagP1, int* diagP1_indices, int* diagP1_indptr,
# 					int* diagP1_zero_indices, int* diagP1_zero_indptr,
# 					int* diagP2_indices, int* diagP2_indptr,
# 					int* diagP3_indices, int* diagP3_indptr,
# 					double* rho, double gamma, int Z, int cur_iter, 
# 					double eps, double zero_eps, int N, double l, double u, double sign):
# 	c_predict.direction_slmqn(d, d_data, d_indices, d_indptr,
# 					x, grad, grad_data, grad_indices, grad_indptr,
# 					s_vecs, s_vecs_data, s_vecs_indices, s_vecs_indptr, 
# 					y_vecs, y_vecs_data, y_vecs_indices, y_vecs_indptr,
# 					diagP0, diagP0_indices, diagP0_indptr,
# 					diagP0_zero_indices, diagP0_zero_indptr,
# 					diagP1, diagP1_indices, diagP1_indptr,
# 					diagP1_zero_indices, diagP1_zero_indptr,
# 					diagP2_indices, diagP2_indptr,
# 					diagP3_indices, diagP3_indptr,
# 					rho, gamma, Z, cur_iter, 
# 					eps, zero_eps, N, l, u, sign)

# cdef void vector_zeros(double* vector, int*	zero_indices, int* indptr, int J):
# 	c_predict.vector_zeros(vector, zero_indices, indptr, J)

# cdef void compress_flt_mat(double** matrix, double* data, int* indices, int* indptr, int I, int J):
# 	c_predict.compress_flt_mat(matrix, data, indices, indptr, I, J)

# cdef void compress_flt_vec(double* vector, double* data, int* indices, int* indptr, int J):
# 	c_predict.compress_flt_vec(vector, data, indices, indptr, J)
	
# cdef double cg_M_nor(double* m, double* m_old, double* m_test,
# 			double** C, double* C_data, int* C_indices, int* C_indptr,
# 			double* x, double* r, double* grad, 
# 			double* grad_data, int* grad_indices, int* grad_indptr,
# 			double* grad_old,
# 			double* z, double* z_data, int* z_indices, int* z_indptr, 
# 			double* z_old,
# 			double* s_vec, double* y_vec, double* Hy,
# 			double* d, double* d_data, int* d_indices, int* d_indptr,
# 			double* diagPre, double gTd,
# 			double* gamma, double error, 
# 			int itr_max, int* cg_itrs, int* nr_itrs, 
# 			int K, int J, double normConstant, int precondition,
# 			double* diagP0, int* diagP0_indices, int* diagP0_indptr,
# 			int* diagP0_zero_indices, int* diagP0_zero_indptr,
# 			double* diagP1, int* diagP1_indices, int* diagP1_indptr,
# 			int* diagP1_zero_indices, int* diagP1_zero_indptr,
# 			int* diagP2_indices, int* diagP2_indptr,
# 			int* diagP3_indices, int* diagP3_indptr,
# 			double eps, double* distance, int* num_steps, double l, double u):
# 	return c_predict.cg_M_nor(m, m_old, m_test,
# 			C, C_data, C_indices, C_indptr,
# 			x, r, grad, grad_data, grad_indices, grad_indptr, grad_old,
# 			z, z_data, z_indices, z_indptr, z_old,
# 			s_vec, y_vec, Hy,
# 			d, d_data, d_indices, d_indptr,
# 			diagPre, gTd, gamma, error, 
# 			itr_max, cg_itrs, nr_itrs, 
# 			K, J, normConstant, precondition,
# 			diagP0, diagP0_indices, diagP0_indptr,
# 			diagP0_zero_indices, diagP0_zero_indptr,
# 			diagP1, diagP1_indices, diagP1_indptr,
# 			diagP1_zero_indices, diagP1_zero_indptr,
# 			diagP2_indices, diagP2_indptr,
# 			diagP3_indices, diagP3_indptr,
# 			eps, distance, num_steps, l, u)

# cdef double cg_M_nor(double** M_ptr, int i,
# 			double** C, double* C_data, int* C_indices, int* C_indptr,
# 			double** X_ptr, double** R_ptr,
# 			double* grad, 
# 			double gamma,
# 			int itr_max, int* cg_itrs, int* nr_itrs, 
# 			int K, int J, double normConstant, 
# 			int precondition,
# 			double* distance, int* num_steps, double l, double u):
# 	return c_predict.cg_M_nor(M_ptr, i,
# 			C, C_data, C_indices, C_indptr,
# 			X_ptr, R_ptr, grad, gamma, itr_max, cg_itrs, nr_itrs, 
# 			K, J, normConstant, precondition,
# 			distance, num_steps, l, u)

cdef void optimize_M(double** X_ptr, double** R_ptr, double** M_ptr, double** C_ptr,
					int I, int J, int K, double normConstant, 
					int numIters, int qn, int cg, double* distance, int* num_steps,
					double lower, double upper):
	c_predict.optimize_M_nor(X_ptr, R_ptr, M_ptr, C_ptr, I, J, K, normConstant, 
					numIters, qn, cg, distance, num_steps, lower, upper)
