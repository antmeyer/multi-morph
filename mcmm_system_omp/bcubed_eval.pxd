cimport numpy as np
cimport cython
cimport set_ops as so

from libc.stdlib cimport malloc, free
from dealloc cimport dealloc_matrix_2
from dealloc cimport dealloc_matrix
from dealloc cimport dealloc_vector
from dealloc cimport dealloc_vec_int
from libc.stdlib cimport malloc, free, realloc
from libc.math cimport sqrt

ctypedef np.int32_t INT_t
ctypedef unsigned int unint
ctypedef double FLOAT

cpdef double bcubed_rec(object wordsAndClusters, object clusters_lengths, 
						object wordsAndClasses, object classes_lengths,
						int numClusters, int numClasses)
						
cpdef double bcubed_prec(object wordsAndClusters, object clusters_lengths, 
						object wordsAndClasses, object classes_lengths,
						int numClusters, int numClasses)
