#cython: boundscheck=False
#cython: wraparound=False
#cython: cdivision=True

cimport cython

cdef class FeatureEncoder:
	cdef int affixlen
	cdef int prec_span
	cdef bint positional
	cdef bint precedence
	cdef bint bigrams
	cdef object words
	cdef object vectors
	cdef object alphabet
	cdef object alphalen
	cdef object posFeatures
	cdef object precFeatures
	cdef object bigramFeatures
	cdef object allFeatures
	cdef int numPosFeatures
	cdef int numPrecFeatures
	cdef int numBigramFeatures
	
	
# 		self.affixlen = affixlen
# 		self.prec_span = 0
# 		self.positional = False
# 		self.precedence = False
# 		self.bigrams = False
# 		if affixlen != "0":
# 
# 		fobj = open(corpusFile, 'r')
# 		self.words = list()
# 		self.vectors = list()
# 		self.alphabet = list()
# 		self.alphalen = 0
# 		self.numPosFeatures = 0
# 		self.numPrecFeatures = 0
# 		self.posFeatures = list()
# 		self.precFeatures = list()
# 		self.bigramFeatures = list()
# 		self.allFeatures = list()
		
	cpdef int encodeWords(self)
	
	cpdef object getFeatures(self)
	
	cpdef object getVectors(self)

	cpdef int writeVectorsToFile(self, object outputFile)


