#cython: boundscheck=False
#cython: wraparound=False
#cython: cdivision=True
#linesearch.pxd

cimport numpy as np
cimport cython
cimport matmath_nullptr, matmath_sparse, predict, search_direction
cimport sparsemat as sp
cimport interpolate as ip
cimport selection_phase_nor as zmnor
from libc.math cimport sqrt, fabs, log
from libc.stdlib cimport malloc, free
from dealloc cimport dealloc_matrix_2
from dealloc cimport dealloc_matrix
from dealloc cimport dealloc_vector
from dealloc cimport dealloc_vec_int
from libc.stdlib cimport malloc, free, realloc


ctypedef int INT
ctypedef unsigned int unint
ctypedef double FLOAT

cdef bint isNaN(FLOAT x)

cdef FLOAT wolfe_M_nor(FLOAT alpha_new, FLOAT alpha_max, FLOAT c1, FLOAT c2,
				FLOAT phi_0, FLOAT der_phi_0,
				FLOAT* m0, FLOAT* m,
				FLOAT** C, FLOAT* C_data, int* C_indices, int* C_indptr,
				FLOAT* x, FLOAT* r,
				FLOAT* d, FLOAT* d_data, int* d_indices, int* d_indptr,
				FLOAT* grad, FLOAT* grad_data, int* grad_indices, int* grad_indptr,
				FLOAT normConstant, int J, int K, int* iterations,
				FLOAT l, FLOAT u)
				
cdef FLOAT wolfe_C_nor(FLOAT alpha_new, FLOAT alpha_max, FLOAT c1, FLOAT c2,
				FLOAT phi_0, FLOAT der_phi_0,
				FLOAT** C0, FLOAT** C, 
				FLOAT** M, FLOAT** X, FLOAT** R,
				FLOAT* d, FLOAT* d_data, int* d_indices, int* d_indptr,
				FLOAT** grad, FLOAT* vec_grad, 
				FLOAT* vec_grad_data, int* vec_grad_indices, int* vec_grad_indptr,
				FLOAT normConstant, int I, int K, int J, int* iterations,
				FLOAT l, FLOAT u)
				
# cdef FLOAT wolfe_M_wwb(FLOAT alpha_new, FLOAT alpha_max, FLOAT c1, FLOAT c2,
# 				FLOAT phi_0, FLOAT der_phi_0,
# 				FLOAT* m0, FLOAT* m, #FLOAT* m_data, int* m_indices, int* m_indptr,
# 				FLOAT** C, FLOAT* C_lt0_data, int* C_lt0_indices, int* C_lt0_indptr,
# 				FLOAT* C_gt0_data, int* C_gt0_indices, int* C_gt0_indptr,
# 				FLOAT* x, FLOAT* r,
# 				FLOAT* d, FLOAT* d_data, int* d_indices, int* d_indptr,
# 				FLOAT* grad, FLOAT* grad_data, int* grad_indices, int* grad_indptr,
# 				FLOAT normConstant, int J, int K, int* iterations)

# cdef FLOAT wolfe_C_wwb(FLOAT alpha_new, FLOAT alpha_max, FLOAT c1, FLOAT c2,
# 				FLOAT phi_0, FLOAT der_phi_0,
# 				FLOAT** C0, FLOAT** C, 
# 				FLOAT** M, 
# 				FLOAT** X, FLOAT** R,
# 				FLOAT* d, FLOAT* d_data, int* d_indices, int* d_indptr,
# 				FLOAT** grad, FLOAT* vec_grad, 
# 				FLOAT* vec_grad_data, int* vec_grad_indices, int* vec_grad_indptr,
# 				FLOAT normConstant, int I, int K, int J, int* iterations)

# cdef FLOAT goldstein_armijo_M(FLOAT alpha0, 
# 					FLOAT phi_0, FLOAT der_phi_0,
# 					FLOAT c1, FLOAT c2,
# 					FLOAT* m0, FLOAT* m,
# 					FLOAT** C, FLOAT* x, FLOAT* r,
# 					FLOAT* d, FLOAT* d_data, int* d_indices, int* d_indptr,
# 					FLOAT normConstant, int K, int J, int* itrs)

# cdef FLOAT goldstein_armijo_C(FLOAT alpha0, FLOAT phi_0, FLOAT der_phi_0,
# 					FLOAT c1, FLOAT c2,
# 					FLOAT** C0, FLOAT** C,
# 					FLOAT** M, FLOAT** X, FLOAT** R,
# 					FLOAT* d, FLOAT normConstant, 
# 					int I, int K, int J, int* itrs)
					
cdef FLOAT armijo2_M_nor(FLOAT a_new, FLOAT a_max, FLOAT c1,
							FLOAT phi_0, FLOAT der_phi_0,
							FLOAT* m0, FLOAT* m, 
							FLOAT** C, 
							FLOAT* C_data, int* C_indices, int* C_indptr,
							FLOAT* x, FLOAT* r,
							FLOAT* d, FLOAT* d_data, int* d_indices, int* d_indptr,
							FLOAT normConstant, 
							int K, int J, int* itrs,
							FLOAT lowerBound, FLOAT upperBound)
							
cdef FLOAT armijo2_C_nor(FLOAT a_new, FLOAT a_max, FLOAT c1,
							FLOAT phi_0, FLOAT der_phi_0,
							FLOAT** C0, FLOAT** C, 
							FLOAT** M,
							FLOAT* M_data, int* M_indices, int* M_indptr,
							FLOAT** X, FLOAT** R,
							FLOAT* d, FLOAT* d_data, int* d_indices, int* d_indptr, 
							FLOAT normConstant, 
							int I, int K, int J, int* itrs,
							FLOAT lowerBound, FLOAT upperBound)
	
# cdef FLOAT armijo2_M_wwb(FLOAT a_new, FLOAT a_max, FLOAT c1,
# 							FLOAT phi_0, FLOAT der_phi_0,
# 							FLOAT* m0, FLOAT* m, 
# 							FLOAT** C, FLOAT* x, FLOAT* r,
# 							FLOAT* d, FLOAT* d_data, int* d_indices, int* d_indptr,
# 							FLOAT normConstant, 
# 							FLOAT eta, int K, int J, int* itrs,
# 							FLOAT lowerBound, FLOAT upperBound)
							
# cdef FLOAT armijo2_C_wwb(FLOAT a_new, FLOAT a_max, FLOAT c1,
# 							FLOAT phi_0, FLOAT der_phi_0,
# 							FLOAT** C0, FLOAT** C, 
# 							FLOAT** M, FLOAT** X, FLOAT** R,
# 							FLOAT* d, FLOAT* d_data, int* d_indices, int* d_indptr, 
# 							FLOAT normConstant, 
# 							int I, int K, int J, int* itrs,
# 							FLOAT lowerBound, FLOAT upperBound)
