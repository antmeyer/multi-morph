#cython: profile=True
#cython: boundscheck=False
#cython: wraparound=False
#cython: cdivision=True

from dealloc cimport dealloc_matrix_2
from dealloc cimport dealloc_mat_2_int
from dealloc cimport dealloc_matrix
from dealloc cimport dealloc_matrix_3d
from dealloc cimport dealloc_vector
from dealloc cimport dealloc_vec_int
from libc.stdlib cimport malloc, calloc, free, realloc

from libc.math cimport sqrt, fabs, log
cimport matmath_sparse
#cimport matmath_nullptr
cimport sparsemat as sp
ctypedef double FLOAT

cdef int prelims_slmqn(FLOAT* grad,
					FLOAT* grad_data, int* grad_indices, int* grad_indptr,
					FLOAT* x,
					FLOAT* diagP0, int* diagP0_indices, int* diagP0_indptr,
					int* diagP0_zero_indices, int* diagP0_zero_indptr,
					FLOAT* diagP1, int* diagP1_indices, int* diagP1_indptr,
					int* diagP1_zero_indices, int* diagP1_zero_indptr,
					int* diagP2_indices, int* diagP2_indptr,
					int* diagP3_indices, int* diagP3_indptr,
					FLOAT eps, FLOAT zero_eps, int J, int K, int N, FLOAT l, FLOAT u)


cdef int direction_slmqn(FLOAT* d, FLOAT* d_data, int* d_indices, int* d_indptr,
					FLOAT* x,
					FLOAT* grad, FLOAT* grad_data, int* grad_indices, int* grad_indptr,
					FLOAT** s_vecs, 
					FLOAT** s_vecs_data, int** s_vecs_indices, int** s_vecs_indptr, 
					FLOAT** y_vecs,
					FLOAT** y_vecs_data, int** y_vecs_indices, int** y_vecs_indptr,
					FLOAT* diagP0, int* diagP0_indices, int* diagP0_indptr,
					int* diagP0_zero_indices, int* diagP0_zero_indptr,
					FLOAT* diagP1, int* diagP1_indices, int* diagP1_indptr,
					int* diagP1_zero_indices, int* diagP1_zero_indptr,
					int* diagP2_indices, int* diagP2_indptr,
					int* diagP3_indices, int* diagP3_indptr,
					FLOAT* rho, FLOAT gamma, int Z, int cur_iter, 
					FLOAT eps, FLOAT zero_eps, int N, FLOAT l, FLOAT u, FLOAT sign)

# 	search_direction.prelims_slmqn_C(vec_grad,
# 				vec_grad_data, vec_grad_indices, vec_grad_indptr,
# 				vec_C,
# 				diagP0, diagP0_indices, diagP0_indptr,
# 				diagP0_zero_indices, diagP0_zero_indptr,
# 				diagP1, diagP1_indices, diagP1_indptr,
# 				diagP1_zero_indices, diagP1_zero_indptr,
# 				diagP2_indices, diagP2_indptr,
# 				diagP3_indices, diagP3_indptr,
# 				diagP4_indices, diagP4_indptr,
# 				diagP5_indices, diagP5_indptr, 0,
# 				eps, zero_eps, J, K, N, l, u)

cdef int prelims_slmqn_C(FLOAT* grad,
					FLOAT* grad_data, int* grad_indices, int* grad_indptr,
					FLOAT* x,
					FLOAT* diagP0, int* diagP0_indices, int* diagP0_indptr,
					int* diagP0_zero_indices, int* diagP0_zero_indptr,
					FLOAT* diagP1, int* diagP1_indices, int* diagP1_indptr,
					int* diagP1_zero_indices, int* diagP1_zero_indptr,
					int* diagP2_indices, int* diagP2_indptr,
					int* diagP3_indices, int* diagP3_indptr,
					int* diagP4_indices, int* diagP4_indptr,
					int* diagP5_indices, int* diagP5_indptr,
					FLOAT eps, FLOAT zero_eps, int J, int K, int N, FLOAT l, FLOAT u)

cdef int direction_slmqn_C(FLOAT* d, FLOAT* d_data, int* d_indices, int* d_indptr,
					FLOAT* x,
					FLOAT* grad, FLOAT* grad_data, int* grad_indices, int* grad_indptr,
					FLOAT** s_vecs, 
					FLOAT** s_vecs_data, int** s_vecs_indices, int** s_vecs_indptr, 
					FLOAT** y_vecs,
					FLOAT** y_vecs_data, int** y_vecs_indices, int** y_vecs_indptr,
					FLOAT* diagP0, int* diagP0_indices, int* diagP0_indptr,
					int* diagP0_zero_indices, int* diagP0_zero_indptr,
					FLOAT* diagP1, int* diagP1_indices, int* diagP1_indptr,
					int* diagP1_zero_indices, int* diagP1_zero_indptr,
					int* diagP2_indices, int* diagP2_indptr,
					int* diagP3_indices, int* diagP3_indptr,
					int* diagP4_indices, int* diagP4_indptr,
					int* diagP5_indices, int* diagP5_indptr,
					FLOAT * rho, FLOAT gamma, int Z, int cur_iter, #bint wwb, 
					FLOAT eps, FLOAT zero_eps, int N, FLOAT l, FLOAT u, FLOAT sign)


				
# cdef int direction_slm_bfgs(FLOAT* d, FLOAT* d_data, int* d_indices, int* d_indptr,
# 					FLOAT* x,
# 					FLOAT* grad, FLOAT* grad_data, int* grad_indices, int* grad_indptr,
# 					FLOAT** H, FLOAT* H_data, int* H_indices, int* H_indptr, 
# 					FLOAT* diagH,
# 					FLOAT* diagP0, int* diagP0_indices, int* diagP0_indptr,
# 					int* diagP0_zero_indices, int* diagP0_zero_indptr,
# 					int* diagP2_indices, int* diagP2_indptr,
# 					int* diagP3_indices, int* diagP3_indptr, 
# 					FLOAT eps, int N, FLOAT sign)
