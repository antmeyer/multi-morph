#cython: profile=True
#cython: cdivision=True

cimport cython
cimport numpy as np

cpdef get_prec_subset(object prec_type, object vowels, object cons, object alphabet)

cdef class FeatureEncoder:
	cdef int affixlen
	cdef int prec_span
	cdef bint positional
	cdef bint precedence
	cdef object prec_types
	cdef object V_string
	# cdef object V_pat
	# cdef object re_V
	cdef bint bigrams
	cdef object words
	cdef np.ndarray vectors
	cdef object alphabet
	cdef object alphalen
	cdef int numV
	cdef int numC
	cdef object posFeatures
	cdef object precFeatures
	cdef object bigramFeatures
	cdef object allFeatures
	cdef int numPosFeatures
	cdef int numPrecFeatures
	cdef int numBigramFeatures
	cdef object V_set
	cdef object C_set
	cpdef bint isCons(self, object x)
	cpdef object C_or_V(self, object x)
	cpdef int encodeWords(self)
	cpdef object getFeatures(self)
	cpdef np.ndarray getVectors(self)
	#cpdef int writeVectorsToFile(self, object outputFile)