#cython: profile=True
#cython: boundscheck=False
#cython: wraparound=False
#cython: cdivision=True
# cg.pxd

cimport numpy as np
cimport cython
cimport matmath_nullptr, matmath_sparse
cimport sparsemat as sp
cimport linesearch, search_direction
cimport predict
from dealloc cimport dealloc_matrix_2
from dealloc cimport dealloc_mat_2_int
from dealloc cimport dealloc_matrix
from dealloc cimport dealloc_vector
from dealloc cimport dealloc_vec_int
from libc.stdlib cimport malloc, realloc
from libc.math cimport sqrt, fabs

ctypedef int INT
#ctypedef np.intp_t INT_t
ctypedef unsigned int unint
ctypedef double FLOAT

cdef FLOAT isNaN(FLOAT x)

cdef FLOAT cg_M_nor(FLOAT* m, FLOAT* m_old,
			FLOAT* m_test,
			FLOAT** C, FLOAT* C_data, int* C_indices, int* C_indptr,
			#FLOAT* prod,
			FLOAT* x, FLOAT* r,
			FLOAT* grad, 
			FLOAT* grad_data, int* grad_indices, int* grad_indptr,
			FLOAT* grad_old,
			FLOAT* z, FLOAT* z_data, int* z_indices, int* z_indptr,
			FLOAT* z_old,
			FLOAT* s_vec, FLOAT* y_vec, FLOAT* Hy,
			FLOAT* d, FLOAT* d_data, int* d_indices, int* d_indptr,
			FLOAT* diagPre, FLOAT gTd,
			FLOAT* gamma, FLOAT error, 
			int itr_max, int* cg_itrs, int* nr_itrs, 
			int K, int J, FLOAT normConstant, 
			int precondition,
			FLOAT* diagP0, int* diagP0_indices, int* diagP0_indptr,
			int* diagP0_zero_indices, int* diagP0_zero_indptr,
			FLOAT* diagP1, int* diagP1_indices, int* diagP1_indptr,
			int* diagP1_zero_indices, int* diagP1_zero_indptr,
			int* diagP2_indices, int* diagP2_indptr,
			int* diagP3_indices, int* diagP3_indptr,
			FLOAT eps, FLOAT* distance, int* num_steps, FLOAT l, FLOAT u)

cdef FLOAT cg_C_nor(FLOAT** C, FLOAT* vec_C, FLOAT* vec_C_old,
			FLOAT** C_test, 
			FLOAT** M, FLOAT* M_data, int* M_indices, int* M_indptr,
			FLOAT** X, FLOAT** R,
			FLOAT** grad, FLOAT* vec_grad,
			FLOAT* vec_grad_data, int* vec_grad_indices, int* vec_grad_indptr,
			FLOAT* vec_grad_old,
			FLOAT* vec_z, FLOAT* vec_z_data, int* vec_z_indices, int* vec_z_indptr,
			FLOAT* vec_z_old,
			FLOAT* s_vec, FLOAT* y_vec, FLOAT* Hy,
			FLOAT* vec_D, FLOAT* vec_D_data, int* vec_D_indices, int* vec_D_indptr,
			FLOAT* diagPre, FLOAT gTd,
			FLOAT* gamma, FLOAT error, int itr_max, int* cg_itrs, int* nr_itrs,
			int I, int K, int J,
			FLOAT normConstant, int objFunc,
			int precondition,
			FLOAT* diagP0, int* diagP0_indices, int* diagP0_indptr,
			int* diagP0_zero_indices, int* diagP0_zero_indptr,
			FLOAT* diagP1, int* diagP1_indices, int* diagP1_indptr,
			int* diagP1_zero_indices, int* diagP1_zero_indptr,
			int* diagP2_indices, int* diagP2_indptr,
			int* diagP3_indices, int* diagP3_indptr,
			FLOAT eps, FLOAT* distance, int* num_steps, FLOAT l, FLOAT u)