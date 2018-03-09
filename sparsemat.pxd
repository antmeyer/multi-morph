#cython: boundscheck=False
#cython: wraparound=False
#cython: cdivision=True

cimport cython
cimport numpy as np
# from dealloc cimport dealloc_matrix
# from dealloc cimport dealloc_matrix_2
# from dealloc cimport dealloc_vector
# from dealloc cimport dealloc_vec_int
# from libc.stdlib cimport malloc, free, realloc
from libc.math cimport sqrt, fabs

ctypedef int INT
ctypedef unsigned int unint
ctypedef double FLOAT

cdef void compress_dbl_mat(double** matrix, double* data, INT* indices, INT* indptr, int I, int J)

cdef void compress_dbl_mat_val(double** matrix, 
	double* data, INT* indices, INT* indptr,
	double val, INT* val_count, INT* val_index, INT* val_ptr,
	int I, int J)

cdef void compress_dbl_mat_Pr(double** matrix, double* data, INT* indices, 
						INT* indptr, int I, int J, 
						INT* P_indices, INT* P_indptr, INT* P_zero_indices, 
						INT* P_zero_indptr)

cdef void compress_dbl_mat_for_mult(double** matrix, double* data, INT* indices, INT* indptr, int I, int J)

cdef void compress_dbl_mat_lt0(double** matrix, double* data, INT* indices, INT* indptr, int I, int J)

cdef void compress_dbl_mat_gt0(double** matrix, double* data, INT* indices, INT* indptr, int I, int J)

cdef void compress_dbl_mat_lge0(double** matrix, 
	double* data_lt0, INT* indices_lt0, INT* indptr_lt0,
	double* data_gt0, INT* indices_gt0, INT* indptr_gt0,
	double* data_eq0, INT* indices_eq0, INT* indptr_eq0, 
	int I, int J)

cdef void compress_dbl_mat_eq0(double** matrix, INT* indices, 
	INT* indptr, int I, int J)
	
cdef void compress_dbl_mat_lge0(double** matrix, 
	double* data_lt0, INT* indices_lt0, INT* indptr_lt0,
	double* data_gt0, INT* indices_gt0, INT* indptr_gt0,
	double* data_eq0, INT* indices_eq0, INT* indptr_eq0, 
	int I, int J)
	
cdef void compress_dbl_mat_col(double** matrix, double* data, INT* indices, INT* indptr, int I, int J)

cdef void compress_dbl_mat_col_lt0(double** matrix, double* data, INT* indices, INT* indptr, int I, int J)

cdef void compress_dbl_mat_col_gt0(double** matrix, double* data, INT* indices, INT* indptr, int I, int J)

cdef void compress_dbl_mat_col_lge0(double** matrix, 
	double* data_lt0, INT* indices_lt0, INT* indptr_lt0,
	double* data_gt0, INT* indices_gt0, INT* indptr_gt0,
	double* data_eq0, INT* indices_eq0, INT* indptr_eq0, 
	int I, int J)
	
cdef void compress_dbl_matview(double[:,::1] matrix, double** data, INT* indices, INT* indptr, int I, int J)

cdef void invDiag_dbl_mat(double** matrix, double* data, INT* indices, INT* indptr, int I)

cdef void compress_int_mat(INT** matrix, INT* data, INT* indices, INT* indptr, int I, int J)

cdef void compress_dbl_vec(double* vector, double* data, INT* indices, INT* indptr, int J)

cdef void compress_dbl_vec_for_mult(double* vector, double* data, INT* indices, INT* indptr, int J)

cdef void compress_dbl_vec_lt0(double* vector, double* data, INT* indices, INT* indptr, int J)

cdef void compress_dbl_vec_gt0(double* vector, double* data, INT* indices, INT* indptr, int J)

cdef void compress_dbl_vec_lge0(double* vector, 
	#double* data_ne0, INT* indices_ne0, INT* indptr_ne0,
	double* data_lt0, INT* indices_lt0, INT* indptr_lt0,
	double* data_gt0, INT* indices_gt0, INT* indptr_gt0, 
	double* data_eq0, INT* indices_eq0, INT* indptr_eq0,
	int J)

cdef void compress_dbl_vec_lge0_Pr0(double* vector, 
	#double* data_ne0, INT* indices_ne0, INT* indptr_ne0,
	double* data_lt0, INT* indices_lt0, INT* indptr_lt0,
	double* data_gt0, INT* indices_gt0, INT* indptr_gt0, 
	double* data_eq0, INT* indices_eq0, INT* indptr_eq0,
	double* vector_Pr, int J)
	
cdef void compress_dbl_vec_eq0(double* vector, 
	double* data_eq0, INT* indices_eq0, INT* indptr_eq0, int J)
	
cdef void compress_dbl_vec_Pr(double* vector, double* data, INT* indices, INT* indptr, 
							int J, INT* P_indices, INT* P_indptr, 
							INT* P_zero_indices, INT* P_zero_indptr)

cdef void transfer_zeros_dbl_vec(double* vector,
							INT* P_zero_indices, INT* P_zero_indptr)
							
cdef void compress_int_vec(INT* vector, INT* data, INT* indices, INT* indptr, int J)

cdef void decompress(double* data, INT* indices, INT* indptr, double** matrix, int I, int J)

cdef void decompress_T(double* data, INT* indices, INT* indptr, double** matrix, int I, int J)

cdef void decompress_vec(double* data, INT* indices, INT* indptr, double* vector, int K)

cdef void vector_zeros(double* vector, INT*	zero_indices, INT* indptr, int J)

cdef void compress_flt_mat(FLOAT** matrix, FLOAT* data, INT* indices, INT* indptr, int I, int J)

cdef void compress_flt_vec(FLOAT* vector, FLOAT* data, INT* indices, INT* indptr, int J)