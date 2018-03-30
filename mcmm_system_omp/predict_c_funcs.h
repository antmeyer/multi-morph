double R_and_E(double** R, double* M_data, int * M_indices, 
					int * M_indptr, double** C, double** X, 
					int I, int J, int K, double normConstant);

double R_and_E_omp(double** R, double* M_data, int * M_indices, 
					int * M_indptr, double** C, double** X, 
					int I, int J, int K, double normConstant);

double R_and_E_nsp(double** R, double** M, double** C, double** X,
						int I, int J, int K, double normConstant);

double R_and_E_nsp_omp(double** R, double** M, double** C, double** X,
						int I, int J, int K, double normConstant);

double R_E_and_Grad_C(double** Grad, double* M_data, int * M_indices, int * M_indptr,
						double** C, double** X, double** R,
						int I, int J, int K, double normConstant);

double R_E_and_Grad_C_omp(double** Grad, double* M_data, 
						int * M_indices, int * M_indptr,
						double** C, double** X, double** R,
						int I, int J, int K, double normConstant);				

double R_E_and_Grad_C_nsp(double** Grad,
						double** M, double** C, double** X, double** R,
						int I, int J, int K, double normConstant);

double R_E_and_Grad_C_nsp_omp(double* vec_Grad,
						double** M, double** C, double** X, double** R,
						int I, int J, int K, double normConstant);			

double r_and_e(double* r, double* m, double *C_data, int *C_indices, 
			int *C_indptr, double* x, int J, int K, double normConstant); 

double r_and_e_omp(double* r, double* m, double *C_data, int *C_indices, 
			int *C_indptr, double* x, int J, int K, double normConstant); 

double r_and_e_nsp(double* r, double* m, double **C, double* x,
				int J, int K, double normConstant);

double r_and_e_nsp_omp(double* r, double* m, double** C, 
					double* x, int J, int K, double normConstant); 

double r_e_and_grad_m(double* grad, double* m, 
			double *C_data, int *C_indices, 
			int *C_indptr, double* x, double* r, 
			int J, int K, double normConstant);

double r_e_and_grad_m_omp(double* grad, double* m, double *C_data, int *C_indices, 
			int *C_indptr, double* x, double* r, 
			int J, int K, double normConstant);

double r_e_and_grad_m_nsp(double* grad, double* m, double **C, 
			double* x, double* r, 
			int J, int K, double normConstant);

double r_e_and_grad_m_nsp_omp(double* grad, double* m, double **C, 
			double* x, double* r, 
			int J, int K, double normConstant);

int inv_diag_bfgs(double* diagH, double* s, double* y, double* Hy, 
					double sTy, int N, double* p);
	
int inv_diag_bfgs_omp(double* diagH, double* s, double* y, double* Hy, 
					double sTy, int N, double* p);

int cluster_to_split_omp(double* M_data, int* M_indices, int* M_indptr, double** C, 
					double** X, double** R, int I, int J, int K, double normConstant);

int cluster_to_split_nsp(double** M, double** C, 
					double** X, double** R, int I, int J, int K, double normConstant);

int cluster_to_split_nsp_omp(double** M, double** C, 
					double** X, double** R, int I, int J, int K, double normConstant);

// double armijo2_M_increase_alpha_nor(double a_higher, double phi_a_higher,
// 				double a_lower, double phi_a_lower,
// 				double phi_0, double der_phi_0,
// 				double c1,
// 				double* m0, double* m,
// 				double** C, double* C_data, int* C_indices, int* C_indptr,
// 				double* x, double* r,
// 				double* d, double* d_data, int* d_indices, int* d_indptr,
// 				double normConstant, int K, int J,
// 				double lowerBound, double upperBound);

// double armijo2_M_interpolate_nor(double a2, double phi_a2,
// 				double a1, double phi_a1,
// 				double phi_0, double der_phi_0,
// 				double c1, double* m0, double* m,
// 				double** C, double* C_data, int* C_indices, int* C_indptr,
// 				double* x, double* r,
// 				double* d, double* d_data, int* d_indices, int* d_indptr,
// 				double normConstant, int K, int J,
// 				double lowerBound, double upperBound);

double armijo2_M_increase_alpha_nor(double a_higher, double phi_a_higher,
				double a_lower, double phi_a_lower,
				double phi_0, double der_phi_0,
				double c1,
				double* m_test, int i,
				double** C, double* C_data, int* C_indices, int* C_indptr,
				double** X_ptr, double** R_ptr,
				double* d, double* d_data, int* d_indices, int* d_indptr,
				double normConstant, int K, int J,
				double lowerBound, double upperBound);

double armijo2_M_interpolate_nor(double a2, double phi_a2,
				double a1, double phi_a1,
				double phi_0, double der_phi_0,
				double c1, double** M_ptr, double* m_test, int i,
				double** C, double* C_data, int* C_indices, int* C_indptr,
				double** X_ptr, double** R_ptr,
				double* d, double* d_data, int* d_indices, int* d_indptr,
				double normConstant, int K, int J,
				double lowerBound, double upperBound);

double quadratic_interpolate(double phi_0, double der_phi_0, double a_cur, double phi_cur);

double cubic_interpolate(double ai_old, double phi_old, double phi_prime_old, 
							double ai, double phi, double phi_prime);

double cubic(double phi0, double phi0_prime, 
				double phi_alpha0, double alpha0,
				double phi_alpha1, double alpha1);

// double armijo2_M_nor(double a_new, double a_max, double c1,
// 							double phi_0, double der_phi_0,
// 							double* m0, double* m, 
// 							double** C, 
// 							double* C_data, int* C_indices, int* C_indptr,
// 							double* x, double* r,
// 							double* d, double* d_data, int* d_indices, int* d_indptr,
// 							double normConstant, 
// 							int K, int J, int* itrs,
// 							double lowerBound, double upperBound);

double armijo2_M_nor(double a_new, double a_max, double c1,
							double phi_0, double der_phi_0,
							double** M_ptr, double* m_test, int i,
							double** C, 
							double* C_data, int* C_indices, int* C_indptr,
							double** X_ptr, double** R_ptr,
							double* d, double* d_data, int* d_indices, int* d_indptr,
							double normConstant, 
							int K, int J, int* itrs,
							double lowerBound, double upperBound);

void prelims_slmqn_M(double* grad,
					double* grad_data, int* grad_indices, int* grad_indptr,
					double** M_ptr, int i,
					double* diagP0, int* diagP0_indices, int* diagP0_indptr,
					int* diagP0_zero_indices, int* diagP0_zero_indptr,
					double* diagP1, int* diagP1_indices, int* diagP1_indptr,
					int* diagP1_zero_indices, int* diagP1_zero_indptr,
					int* diagP2_indices, int* diagP2_indptr,
					int* diagP3_indices, int* diagP3_indptr,
					double eps, int J, int K, double l, double u);

// void prelims_slmqn(double* grad,
// 					double* grad_data, int* grad_indices, int* grad_indptr,
// 					double* x,
// 					double* diagP0, int* diagP0_indices, int* diagP0_indptr,
// 					int* diagP0_zero_indices, int* diagP0_zero_indptr,
// 					double* diagP1, int* diagP1_indices, int* diagP1_indptr,
// 					int* diagP1_zero_indices, int* diagP1_zero_indptr,
// 					int* diagP2_indices, int* diagP2_indptr,
// 					int* diagP3_indices, int* diagP3_indptr,
// 					double eps, double zero_eps, int J, int K, int N, double l, double u);

void direction_slmqn(double* d, double* d_data, int* d_indices, int* d_indptr,
					double* x,
					double* grad, double* grad_data, int* grad_indices, int* grad_indptr,
					double** s_vecs, 
					double** s_vecs_data, int** s_vecs_indices, int** s_vecs_indptr, 
					double** y_vecs,
					double** y_vecs_data, int** y_vecs_indices, int** y_vecs_indptr,
					double* diagP0, int* diagP0_indices, int* diagP0_indptr,
					int* diagP0_zero_indices, int* diagP0_zero_indptr,
					double* diagP1, int* diagP1_indices, int* diagP1_indptr,
					int* diagP1_zero_indices, int* diagP1_zero_indptr,
					int* diagP2_indices, int* diagP2_indptr,
					int* diagP3_indices, int* diagP3_indptr,
					double* rho, double gamma, int Z, int cur_iter, 
					double eps, double zero_eps, int N, double l, double u, double sign);

void vector_zeros(double* vector, int*	zero_indices, int* indptr, int J);

void compress_flt_mat(double** matrix, double* data, int* indices, int* indptr, int M, int N);

void compress_flt_vec(double* vector, double* data, int* indices, int* indptr, int M);

// double cg_M_nor(double* m, double* m_old,
// 			double* m_test,
// 			double** C, double* C_data, int* C_indices, int* C_indptr,
// 			double* x, double* r,
// 			double* grad, 
// 			double* grad_data, int* grad_indices, int* grad_indptr,
// 			double* grad_old,
// 			double* z, double* z_data, int* z_indices, int* z_indptr,
// 			double* z_old,
// 			double* s_vec, double* y_vec, double* Hy,
// 			double* d, double* d_data, int* d_indices, int* d_indptr,
// 			double* diagPre, double gTd,
// 			double* gamma, double error, 
// 			int itr_max, int* cg_itrs, int* nr_itrs, 
// 			const int K, const int J, double normConstant, 
// 			int precondition,
// 			double* diagP0, int* diagP0_indices, int* diagP0_indptr,
// 			int* diagP0_zero_indices, int* diagP0_zero_indptr,
// 			double* diagP1, int* diagP1_indices, int* diagP1_indptr,
// 			int* diagP1_zero_indices, int* diagP1_zero_indptr,
// 			int* diagP2_indices, int* diagP2_indptr,
// 			int* diagP3_indices, int* diagP3_indptr,
// 			double eps, double* distance, int* num_steps, const double l, const double u);

// double cg_M_nor(double* m,
// 			double** C, double* C_data, int* C_indices, int* C_indptr,
// 			double* x, double* r,
// 			double* grad, 
// 			double gamma,
// 			int itr_max, int* cg_itrs, int* nr_itrs, 
// 			const int K, const int J, const double normConstant, 
// 			int precondition,
// 			double* distance, int* num_steps, const double l, const double u);

// void optimize_M_nor(double** X_ptr, double** R_ptr, double** M_ptr, 
// 					double** C_ptr,
// 					int I, int J, int K, double* normConstants, 
// 					int numIters, int qn, int cg, double* distance, int* num_steps,
// 					double lower, double upper);

double cg_M_nor(double** M_ptr, int i, double* m_old,
			double* m_test, 
			double** C, double* C_data, int* C_indices, int* C_indptr,
			double** X_ptr, double** R_ptr,
			double* grad, 
			double* grad_data, int* grad_indices, int* grad_indptr,
			double* grad_old,
			double* z, double* z_data, int* z_indices, int* z_indptr,
			double* z_old,
			double* s_vec, double* y_vec, double* Hy,
			double* d, double* d_data, int* d_indices, int* d_indptr,
			double* diagPre, double gTd,
			double gamma, double error, 
			int itr_max, int* cg_itrs, int* nr_itrs, 
			int K, int J, double normConstant, 
			int precondition,
			double* diagP0, int* diagP0_indices, int* diagP0_indptr,
			int* diagP0_zero_indices, int* diagP0_zero_indptr,
			double* diagP1, int* diagP1_indices, int* diagP1_indptr,
			int* diagP1_zero_indices, int* diagP1_zero_indptr,
			int* diagP2_indices, int* diagP2_indptr,
			int* diagP3_indices, int* diagP3_indptr,
			double eps, double* distance, int* num_steps, double l, double u);

void optimize_M_nor(double** X_ptr, double** R_ptr, double** M_ptr, 
					double** C_ptr,
					int I, int J, int K, double normConstant,
					int numIters, int qn, int cg, double* distance, int* num_steps,
					double lower, double upper);
