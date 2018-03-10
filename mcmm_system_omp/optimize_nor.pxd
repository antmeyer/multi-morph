#cython: profile=True
#cython: boundscheck=False
#cython: wraparound=False
#cython: cdivision=True

cimport numpy as np
cimport cython
#from cython.parallel cimport parallel, prange
cimport matmath_nullptr, matmath_sparse, predict
cimport sparsemat as sp
cimport numberNonZeros as nnz
cimport linesearch
from search_direction cimport prelims_slmqn, direction_slmqn
from cg_nor cimport cg_C_nor, cg_M_nor
from dealloc cimport dealloc_matrix_2
from dealloc cimport dealloc_mat_2_int
from dealloc cimport dealloc_matrix
from dealloc cimport dealloc_vector
from dealloc cimport dealloc_vec_int
#from utility cimport print_matrix_2d
#from utility cimport print_matrix_sparse
from libc.stdlib cimport malloc, calloc, realloc
from libc.math cimport sqrt, fabs

ctypedef int INT
ctypedef unsigned int unint
ctypedef np.int64_t I64
ctypedef np.float64_t float64
ctypedef double FLOAT

                    
cdef FLOAT optimize_C_nor(FLOAT** X_ptr, FLOAT** R_ptr, FLOAT** C_ptr,
					FLOAT** M_ptr,
					INT I, INT J, INT K, FLOAT normConstant,  
					INT numIters, INT objFunc, bint qn, bint cg, 
                    FLOAT* distance, INT* num_steps,
                    FLOAT lower, FLOAT upper)

cdef FLOAT optimize_M_nor(FLOAT** X_ptr, FLOAT** R_ptr, FLOAT** M_ptr, 
					FLOAT** C_ptr,
					INT I, INT J, INT K, FLOAT* normConstants,  
					INT numIters, bint qn, bint cg, FLOAT* distance, INT* num_steps,
					FLOAT lower, FLOAT upper)
