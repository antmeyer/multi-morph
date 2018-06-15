#cython: boundscheck=False
#cython: wraparound=False
#cython: cdivision=True

cimport cython
cimport numpy as np
#cimport clustertest_nor
cimport mcmm_functions
cimport sparsemat as sp
cimport decode
from dealloc cimport dealloc_matrix_2
from dealloc cimport dealloc_mat_2_int
from dealloc cimport dealloc_matrix
from dealloc cimport dealloc_matrix_3d
from dealloc cimport dealloc_vector
from dealloc cimport dealloc_vec_int
#cimport wrapper_nor as wrp
from libc.stdlib cimport malloc, free, realloc
from libc.math cimport sqrt, fabs

#ctypedef np.float64_t DOUBLE_t
ctypedef int INT
ctypedef unsigned int unint
ctypedef double FLOAT

cdef class MCMM:

	cdef int I, J, K, midpoint, prec_span, max_K, evalInterval, numIters, objFunc,
	cdef object prec_types
	cdef bint initFlag, qn, cg
	cdef FLOAT[:,::1] Xv, Rv, Cv, Mv
	cdef FLOAT initTime, timePrevious, E, original_E
	cdef object alphabet,wordList,splitSequence,featureList
	cdef object experimentTitle
	cdef object outputPrefix
	cdef object deletedFeatures_str
	cdef object tempDir
	cdef FLOAT M_distance, C_distance
	cdef int num_M_steps, num_C_steps
	cdef FLOAT normConstant
	cdef FLOAT normConstant_M
	cdef FLOAT thresh
	
	cdef void split_cluster(self)

	cdef int find_cluster_to_split(self)
	
	cdef void shake(self, INT k, rate)
    
	cdef void duplicate_cluster(self, INT k)

	cpdef run_MCMM(self)

	cpdef int get_K(self)
    
	cpdef int get_I(self)
    
	cpdef int get_J(self)
    
	cpdef FLOAT[:,::1] get_M(self)
    
	cpdef FLOAT[:,::1] get_C(self)

	cpdef FLOAT[:,::1] get_R(self)

	cpdef object get_splitSequence(self)

	cpdef FLOAT getError(self)
	
	cpdef FLOAT getOriginalError(self)
