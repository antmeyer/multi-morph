#include <omp.h>

double cg_M(double** M,
			double** C,
			double** X, double** R,
			int I, int J, int K, double normConstant,
			double l, double u);

double cg_C(double** C,
			double** M,
			double** X, double** R,
			int I, int J, int K, double normConstant,
			double l, double u);

double R_and_E(double** R, double** M, double* vec_C, double** X,
				int I, int J, int K, double normConstant);

double R_and_E_2(double** R, double** M, double** C, double** X,
				int I, int J, int K, double normConstant);

double R_E_and_Grad_C(double* vec_Grad,
						double** M, double* vec_C, double** X, double** R,
						int I, int J, int K, double normConstant);

double r_and_e(double* r, double* m, double *C_data, int *C_indices, 
			int *C_indptr, double* x, int J, int K, double normConstant);

double r_and_e_nsp(double* r, double* m, double **C, double* x, int J, int K, double normConstant);

double r_e_and_grad_m(double* grad, double* m, double *C_data, int *C_indices, 
			int *C_indptr, double* x, double* r,
			int J, int K, double normConstant);

int cluster_to_split(double** M, double** C, 
					double** X, double** R, int I, int J, int K, double normConstant);

double quadratic_interpolate(double phi_0, double der_phi_0, double a_cur, double phi_cur);

double cubic_interpolate(double ai_old, double phi_old, double phi_prime_old, 
							double ai, double phi, double phi_prime);

double cubic(double phi0, double phi0_prime, 
				double phi_alpha0, double alpha0,
				double phi_alpha1, double alpha1);

void compress_flt_mat(double** matrix, double* data, int* indices, int* indptr, int M, int N);

void compress_flt_vec(double* vector, double* data, int* indices, int* indptr, int N);

double armijo_M(double a_new, double a_max, double c1,
							double phi_0, double der_phi_0,
							double** M_ptr, double* m_test, int i,
							double** C, 
							double* C_data, int* C_indices, int* C_indptr,
							double** X_ptr, double** R_ptr,
							double* d, double* d_data, int* d_indices, int* d_indptr,
							double normConstant, 
							int J, int K, int* itrs,
							double lowerBound, double upperBound);

double armijo_M_increase(double a_higher, double phi_a_higher,
				double a_lower, double phi_a_lower,
				double phi_0, double der_phi_0,
				double c1,
				double* m_test, int i,
				double** C, 
				double* C_data, int* C_indices, int* C_indptr,
				double** X_ptr, double** R_ptr,
				double* d, double* d_data, int* d_indices, int* d_indptr,
				double normConstant, int J, int K,
				double lowerBound, double upperBound);

double armijo_M_interpolate(double a2, double phi_a2,
				double a1, double phi_a1,
				double phi_0, double der_phi_0,
				double c1, double** M_ptr, double* m_test, int i,
				double** C, double* C_data, int* C_indices, int* C_indptr,
				double** X_ptr, double** R_ptr,
				double* d, double* d_data, int* d_indices, int* d_indptr,
				double normConstant, int J, int K,
				double lowerBound, double upperBound);

double armijo_C(double a_new, double a_max, double c1,
							double phi_0, double der_phi_0,
							double* vec_C0, double* vec_C, 
							double** M,
							double** X, double** R,
							double* d, double* d_data, int* d_indices, int* d_indptr,
							double normConstant, 
							int I, int J, int K, int* itrs, 
							double l, double u);

double armijo_C_increase(double a_higher, double phi_a_higher,
				double a_lower, double phi_a_lower,
				double phi_0, double der_phi_0,
				double c1,
				double* vec_C0, double* vec_C,
				double** M,
				double** X, double** R,
				double* d, double* d_data, int* d_indices, int* d_indptr,
				double normConstant, int I, int J, int K,
				double l, double u);

double armijo_C_interpolate(double a2, double phi_a2,
				double a1, double phi_a1,
				double phi_0, double der_phi_0,
				double c1,
				double* vec_C0, double* vec_C,
				double** M,
				double** X, double** R,
				double* d, double* d_data, int* d_indices, int* d_indptr,
				double normConstant, int I, int J, int K,
				double l, double u);

// double armijo_C_nsp(double a_new, double a_max, double c1,
// 							double phi_0, double der_phi_0,
// 							double* vec_C0, double* vec_C, 
// 							double** M,
// 							double** X, double** R,
// 							double* d,
// 							double normConstant, 
// 							int I, int K, int J, int* itrs, 
// 							double l, double u);
// double armijo_C_nsp(double a_new, double a_max, double c1,
// 							double phi_0, double der_phi_0,
// 							double* vec_C0, double* vec_C, 
// 							double** M,
// 							double** X, double** R,
// 							double* d,
// 							double normConstant, 
// 							int I, int J, int K, int* itrs, 
// 							double l, double u);

// double armijo_C_nsp2(double a_new, double a_max, double c1,
// 							double phi_0, double der_phi_0,
// 							double* vec_C0, double* vec_C, 
// 							double** M,
// 							double** X, double** R,
// 							double* d, double* d_data, int* d_indices, int* d_indptr,
// 							double normConstant, 
// 							int I, int J, int K, int* itrs, 
// 							double l, double u);
// double armijo_C_increase_nsp(double a_higher, double phi_a_higher,
// 				double a_lower, double phi_a_lower,
// 				double phi_0, double der_phi_0,
// 				double c1,
// 				double* vec_C0, double* vec_C,
// 				double** M,
// 				double** X, double** R,
// 				double* d,
// 				double normConstant, int I, int K, int J,
// 				double l, double u);
// double armijo_C_increase_nsp(double a_higher, double phi_a_higher,
// 				double a_lower, double phi_a_lower,
// 				double phi_0, double der_phi_0,
// 				double c1,
// 				double* vec_C0, double* vec_C,
// 				double** M,
// 				double** X, double** R,
// 				double* d,
// 				double normConstant, int I, int J, int K,
// 				double l, double u);

// double armijo_C_increase_nsp2(double a_higher, double phi_a_higher,
// 				double a_lower, double phi_a_lower,
// 				double phi_0, double der_phi_0,
// 				double c1,
// 				double* vec_C0, double* vec_C,
// 				double** M,
// 				double** X, double** R,
// 				double* d, double* d_data, int* d_indices, int* d_indptr,
// 				double normConstant, int I, int J, int K,
// 				double l, double u);

// double armijo_C_interpolate_nsp(double a2, double phi_a2,
// 				double a1, double phi_a1,
// 				double phi_0, double der_phi_0,
// 				double c1,
// 				double* vec_C0, double* vec_C,
// 				double** M,
// 				double** X, double** R,
// 				double* d,
// 				double normConstant, int I, int K, int J,
// 				double l, double u);

// double armijo_C_interpolate_nsp2(double a2, double phi_a2,
// 				double a1, double phi_a1,
// 				double phi_0, double der_phi_0,
// 				double c1,
// 				double* vec_C0,double* vec_C,
// 				double** M,
// 				double** X, double** R,
// 				double* d, double* d_data, int* d_indices, int* d_indptr,
// 				double normConstant, int I, int J, int K,
// 				double l, double u);
