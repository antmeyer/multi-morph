#cython: profile=True
#cython: boundscheck=False
#cython: wraparound=False
#cython: cdivision=True
#import sys

cimport numpy as np
cimport cython
cimport matmath_nullptr, matmath_sparse, predict
#cimport utility
cimport sparsemat as sp
cimport interpolate as ip
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

cdef FLOAT zoom_M_nor(FLOAT alpha_lo, FLOAT phi_lo, FLOAT der_phi_lo,
				FLOAT alpha_hi, FLOAT phi_hi, FLOAT der_phi_hi,
				FLOAT phi_0, FLOAT der_phi_0,
				FLOAT c1, FLOAT c2,
				FLOAT* m0, FLOAT* m,
				FLOAT** C,FLOAT* C_data, int* C_indices, int* C_indptr,
				FLOAT* x, FLOAT* r,
				FLOAT* d, FLOAT* d_data, int* d_indices, int* d_indptr,
				FLOAT* grad, 
				FLOAT* grad_data, int* grad_indices, int* grad_indptr,
				FLOAT normConstant, int K, int J, int num_rounds,
				FLOAT l, FLOAT u)

cdef FLOAT zoom_C_nor(FLOAT alpha_lo, FLOAT phi_lo, FLOAT der_phi_lo,
				FLOAT alpha_hi, FLOAT phi_hi, FLOAT der_phi_hi,
				FLOAT phi_0, FLOAT der_phi_0,
				FLOAT c1, FLOAT c2,
				FLOAT** C0, FLOAT** C,
				FLOAT** M, FLOAT** X, FLOAT** R,
				FLOAT* d, FLOAT* d_data, int* d_indices, int* d_indptr,
				FLOAT** grad, FLOAT* vec_grad, 
				FLOAT* vec_grad_data, int* vec_grad_indices, int* vec_grad_indptr,
				FLOAT normConstant, int I, int K, int J, int num_rounds,
				FLOAT l, FLOAT u)
				
# cdef FLOAT armijo_zoom_M(FLOAT a_old, FLOAT phi_a_old,
# 				FLOAT a_new, FLOAT phi_a_new,
# 				FLOAT phi_0, FLOAT der_phi_0,
# 				FLOAT c1,
# 				FLOAT* m0, FLOAT* m,
# 				FLOAT** C, FLOAT* x, FLOAT* r,
# 				FLOAT* d, FLOAT* d_data, int* d_indices, int* d_indptr,
# 				FLOAT normConstant, FLOAT eta, int K, int J)

# cdef FLOAT armijo_zoom_C(FLOAT a_old, FLOAT phi_a_old,
# 				FLOAT a_new, FLOAT phi_a_new,
# 				FLOAT phi_0, FLOAT der_phi_0,
# 				FLOAT c1,
# 				FLOAT** C0, FLOAT** C,
# 				FLOAT** M, FLOAT** X, FLOAT** R,
# 				FLOAT* d, FLOAT* d_data, int* d_indices, int* d_indptr,
# 				FLOAT normConstant, FLOAT eta, int I, int K, int J)

cdef FLOAT armijo2_C_increase_alpha_nor(FLOAT a_higher, FLOAT phi_a_higher,
				FLOAT a_lower, FLOAT phi_a_lower,
				FLOAT phi_0, FLOAT der_phi_0,
				FLOAT c1,
				FLOAT** C0, FLOAT** C,
				FLOAT** M, 
				FLOAT* M_data, int* M_indices, int* M_indptr,
				FLOAT** X, FLOAT** R,
				FLOAT* d, FLOAT* d_data, int* d_indices, int* d_indptr,
				FLOAT normConstant, int I, int K, int J,
				FLOAT lowerBound, FLOAT upperBound)
				
cdef FLOAT armijo2_C_decrease_alpha_nor(FLOAT a_higher, FLOAT phi_a_higher,
				FLOAT a_lower, FLOAT phi_a_lower,
				FLOAT phi_0, FLOAT der_phi_0,
				FLOAT c1,
				FLOAT** C0, FLOAT** C,
				FLOAT** M, 
				FLOAT* M_data, int* M_indices, int* M_indptr,
				FLOAT** X, FLOAT** R,
				FLOAT* d, FLOAT* d_data, int* d_indices, int* d_indptr,
				FLOAT normConstant, int I, int K, int J,
				FLOAT lowerBound, FLOAT upperBound)

cdef FLOAT armijo2_C_correct_nor(FLOAT a_1, FLOAT phi_a_1,
				FLOAT a_2, FLOAT phi_a_2,
				FLOAT phi_0, FLOAT der_phi_0,
				FLOAT c1,
				FLOAT** C0, FLOAT** C,
				FLOAT** M,
				FLOAT* M_data, int* M_indices, int* M_indptr,
				FLOAT** X, FLOAT** R,
				FLOAT* d, FLOAT* d_data, int* d_indices, int* d_indptr,
				FLOAT normConstant, int I, int K, int J,
				FLOAT lowerBound, FLOAT upperBound)

cdef FLOAT armijo2_M_increase_alpha_nor(FLOAT a_higher, FLOAT phi_a_higher,
				FLOAT a_lower, FLOAT phi_a_lower,
				FLOAT phi_0, FLOAT der_phi_0,
				FLOAT c1,
				FLOAT* m0, FLOAT* m,
				FLOAT** C, FLOAT* C_data, int* C_indices, int* C_indptr,
				#FLOAT* prod,
				FLOAT* x, FLOAT* r,
				FLOAT* d, FLOAT* d_data, int* d_indices, int* d_indptr,
				FLOAT normConstant, int K, int J,
				FLOAT lowerBound, FLOAT upperBound)
				
cdef FLOAT armijo2_M_decrease_alpha_nor(FLOAT a_higher, FLOAT phi_a_higher,
				FLOAT a_lower, FLOAT phi_a_lower, FLOAT phi_0, 
				FLOAT der_phi_0,
				FLOAT c1,
				FLOAT* m0, FLOAT* m,
				FLOAT** C, FLOAT* C_data, int* C_indices, int* C_indptr,
				#FLOAT* prod,
				FLOAT* x, FLOAT* r,
				FLOAT* d, FLOAT* d_data, int* d_indices, int* d_indptr,
				FLOAT normConstant, int K, int J,
				FLOAT lowerBound, FLOAT upperBound)
				
cdef FLOAT armijo2_M_correct_nor(FLOAT a_1, FLOAT phi_a_1,
				FLOAT a_2, FLOAT phi_a_2,
				FLOAT phi_0, FLOAT der_phi_0,
				FLOAT c1,
				FLOAT* m0, FLOAT* m,
				FLOAT** C, FLOAT* C_data, int* C_indices, int* C_indptr,
				#FLOAT* prod,
				FLOAT* x, FLOAT* r,
				FLOAT* d, FLOAT* d_data, int* d_indices, int* d_indptr,
				FLOAT normConstant, int K, int J,
				FLOAT lowerBound, FLOAT upperBound)

# cdef FLOAT armijo2_M_interpolate_nor(FLOAT a_2gher, FLOAT phi_a_2gher,
# 				FLOAT a_1wer, FLOAT phi_a_1wer,
# 				FLOAT phi_0, FLOAT der_phi_0,
# 				FLOAT c1, FLOAT* m0, FLOAT* m,
# 				FLOAT** C, FLOAT* x, FLOAT* r,
# 				FLOAT* d, FLOAT* d_data, int* d_indices, int* d_indptr,
# 				FLOAT normConstant, FLOAT eta, int K, int J,
# 				FLOAT lowerBound, FLOAT upperBound)				

cdef FLOAT armijo2_M_interpolate_nor(FLOAT a2, FLOAT phi_a2,
				FLOAT a1, FLOAT phi_a1,
				FLOAT phi_0, FLOAT der_phi_0,
				FLOAT c1, FLOAT* m0, FLOAT* m,
				FLOAT** C, FLOAT* C_data, int* C_indices, int* C_indptr,
				FLOAT* x, FLOAT* r,
				FLOAT* d, FLOAT* d_data, int* d_indices, int* d_indptr,
				FLOAT normConstant, int K, int J,
				FLOAT lowerBound, FLOAT upperBound)
				
cdef FLOAT armijo2_C_interpolate_nor(FLOAT a_2, FLOAT phi_a_2,
				FLOAT a_1, FLOAT phi_a_1,
				FLOAT phi_0, FLOAT der_phi_0,
				FLOAT c1,
				FLOAT** C0, FLOAT** C,
				FLOAT** M, 
				FLOAT* M_data, int* M_indices, int* M_indptr,
				FLOAT** X, FLOAT** R,
				FLOAT* d, FLOAT* d_data, int* d_indices, int* d_indptr,
				FLOAT normConstant, int I, int K, int J,
				FLOAT lowerBound, FLOAT upperBound)
