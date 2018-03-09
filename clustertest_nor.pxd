#clustertest.pxd
#cython: boundscheck=False
#cython: wraparound=False
#cython: cdivision=True

cimport cython
cimport numpy as np

from dealloc cimport dealloc_matrix_2
from dealloc cimport dealloc_matrix
from dealloc cimport dealloc_vector
from dealloc cimport dealloc_vec_int
from libc.stdlib cimport malloc  #, free, realloc

from libc.math cimport fabs, log
# cimport utility
# cimport sparsemat as sp

ctypedef int INT
ctypedef double FLOAT

cdef FLOAT clustertest(FLOAT** M, FLOAT* M_data, int* M_indices, int* M_indptr, 
		FLOAT** C, FLOAT** X, FLOAT** R,
		int I, int J, int K, int k_to_skip, FLOAT normConstant)