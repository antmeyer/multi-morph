#cython: boundscheck=False
#cython: wraparound=False
#cython: cdivision=True

cimport cython
#cimport numpy as np
from libc.stdlib cimport malloc, free
from dealloc cimport dealloc_matrix_2
from dealloc cimport dealloc_matrix
from dealloc cimport dealloc_vector
from dealloc cimport dealloc_vec_int
cimport sparsemat

#ctypedef np.intp_t INT_t
#ctypedef np.float64_t DOUBLE_t
ctypedef unsigned int unint
ctypedef double FLOAT

# cdef int mul_1d_scalar(double* v_data,
# 						int v_data_len,
# 						double scalar,
# 						double* output_data)

cdef void mul_1d_scalar(double* v_data,
						int* v_indices,
						int* v_indptr,
						double scalar,
						double* output_data,
						int* output_indices,
						int* output_indptr)						

# cdef int mul_2d_scalar(double* M_data,
# 						int M_data_len,
# 						double scalar,
# 						double* output_data)

cdef void mul_2d_scalar(double* M_data,
						int* M_indices,
						int* M_indptr,
						int M_data_len,
						int M_indptr_len,
						double scalar,
						double* output_data,
						int* output_indices,
						int* output_indptr)

cdef void mul_2d_scalar_2(double* M_data,
						int* M_indices,
						int* M_indptr,
						int M_indptr_len,
						double scalar,
						double** output)
						
cdef double mul_1d_1d(double* v1_data,
						int* v1_indices,
						int* v1_indptr,
						double* v2_data,
						int* v2_indices,
						int* v2_indptr)					
						
cdef int mul_2d_1d(double* M_data, 
				int* M_indices,
				int* M_indptr,
				int M_indptr_len,
				double* v_data,
				int* v_indices,
				int* v_indptr,
				double* output)

cdef int mul_1d_2d(double* v_data,
				int* v_indices,
				int* v_indptr,
				double* M_data, 
				int* M_indices,
				int* M_indptr,
				int M_indptr_len,
				double* output)

cdef int mul_2d_2d(double* M1_data, 
				int* M1_indices,
				int* M1_indptr,
				int M1_indptr_len,
				double* M2_data, 
				int* M2_indices,
				int* M2_indptr,
				int M2_indptr_len,
				double** output)

cdef int transpose(double* M_data,
				int* M_indices,
				int* M_indptr,
				int M_numrows,
				double* M_T_data,
				int* M_T_indices,
				int* M_T_indptr,
				int M_T_numrows)

cdef int square_2d(double* M1_data,
						int* M1_indices,
						int* M1_indptr,
						int M1_indptr_len,
						double** output)
						
# cdef int square_2d_diag(double* M1_data,
# 						int* M1_indices,
# 						int* M1_indptr,
# 						int M1_indptr_len,
# 						double* output)

cdef int square_2d_invDiag(double* M1_data,
						int* M1_indices,
						int* M1_indptr,
						int M1_indptr_len,
						double* output_data,
						int* output_indices,
						int* output_indptr)

cdef int add_1d_1d(double* v1_data, int* v1_indices, int* v1_indptr,
				double* v2_data, int* v2_indices, int* v2_indptr, 
				#double* output_data, int* output_indices, int* output_indptr,
				double* output,
				int output_len)
				
cdef int subt_1d_1d(double* v1_data, int* v1_indices, int* v1_indptr,
				double* v2_data, int* v2_indices, int* v2_indptr, 
				#double* output_data, int* output_indices, int* output_indptr,
				double* output,
				int output_len)

# cdef add_1d_1d(double* v1_data,
# 						int* v1_indices,
# 						int* v1_indptr,
# 						double* v2_data,
# 						int* v2_indices,
# 						int* v2_indptr,
# 						double* output,
# 						int output_len)
# 						
# cdef subt_1d_1d(double* v1_data,
# 						int* v1_indices,
# 						int* v1_indptr,
# 						double* v2_data,
# 						int* v2_indices,
# 						int* v2_indptr,
# 						double* output,
# 						int output_len)