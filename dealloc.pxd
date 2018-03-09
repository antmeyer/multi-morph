# dealloc.pxd
#cython: boundscheck=False
#cython: wraparound=False
#cython: cdivision=True

cimport numpy as np
ctypedef np.int8_t I8
ctypedef double FLOAT

from libc.stdlib cimport malloc, free

cdef void dealloc_matrix(FLOAT ** M, int num_rows)

cdef void dealloc_matrix_2(FLOAT ** M, int num_rows)

cdef void dealloc_mat_2_int(int ** M, int num_rows)

cdef void dealloc_matrix_3d(FLOAT *** M, int num_rows_1, int num_rows_2)

cdef void dealloc_vector(FLOAT * v)

cdef void dealloc_vec_int(int * v)

cdef void dealloc_vec_i8(I8 * v)