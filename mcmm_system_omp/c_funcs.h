#include <stdio.h>

double r_and_e(double* r, double* m, double *C_data, int *C_indices, 
			int *C_indptr, double* x, int J, int K, double normConstant);

double r_and_e_nsp(double* r, double* m, double **C, double* x,
				int J, int K, double normConstant);

double r_e_and_grad_m(double* grad, double* m, double *C_data, int *C_indices, 
			int *C_indptr, double* x, double* r,
			int J, int K, double normConstant);

double r_e_and_grad_m_nsp(double* grad, double* m, double **C, 
			double* x, double* r, 
			int J, int K, double normConstant);

double quadratic_interpolate(double phi_0, double der_phi_0, double a_cur, double phi_cur);

double cubic_interpolate(double ai_old, double phi_old, double phi_prime_old, 
							double ai, double phi, double phi_prime);

double cubic(double phi0, double phi0_prime, 
				double phi_alpha0, double alpha0,
				double phi_alpha1, double alpha1);

void compress_flt_mat(double** matrix, double* data, int* indices, int* indptr, int M, int N);

void compress_flt_vec(double* vector, double* data, int* indices, int* indptr, int N);

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

double armijo2_M_nor_nsp(double a_new, double a_max, double c1,
							double phi_0, double der_phi_0,
							double** M_ptr, double* m_test, int i,
							double** C, 
							double** X_ptr, double** R_ptr,
							double* d, 
							double normConstant, 
							int K, int J, int* itrs,
							double lowerBound, double upperBound);

double armijo2_M_increase_alpha_nor_nsp(double a_higher, double phi_a_higher,
				double a_lower, double phi_a_lower,
				double phi_0, double der_phi_0,
				double c1,
				double* m_test, int i,
				double** C,
				double** X_ptr, double** R_ptr,
				double* d,
				double normConstant, int K, int J,
				double lowerBound, double upperBound);

double armijo2_M_interpolate_nor_nsp(double a2, double phi_a2,
				double a1, double phi_a1,
				double phi_0, double der_phi_0,
				double c1, double** M_ptr, double* m_test, int i,
				double** C, double** X_ptr, double** R_ptr,
				double* d, double normConstant, int K, int J,
				double lowerBound, double upperBound);