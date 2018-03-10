#decode.pxd

cimport numpy as np
cimport cython
ctypedef np.float64_t DOUBLE_t
ctypedef int INT
ctypedef double FLOAT

cpdef object sequenceMap(np.ndarray[FLOAT, ndim=1] valList, np.ndarray alphabet)

cpdef int greaterThanMin(FLOAT candidate, object valsAndIndices)

cpdef object sorted_output_str(object memberList)

cdef class FeatureDecoder:
    cdef INT affixlen
    cdef object prec_span
    cdef bint positional
    cdef bint precedence
    cdef bint bigrams
    cdef object joiner
    cdef np.ndarray featureVector
    cdef np.ndarray alphabet
    cdef object posFeatures
    cdef object precFeatures
    cdef object bigramFeatures
    cdef object allFeatures
    cpdef object highestValsAndIndices(self, INT N)
    cpdef object lowestValsAndIndices(self, INT N)
    cpdef object decodedFeatures(self, object valsAndIndices)
    cpdef object decodedFeatures(self, object valsAndIndices)
    cpdef object tenMostActive(self)
    cpdef object tenLeastActive(self)

cdef class ActivationsDecoder:
    cdef FLOAT[:,::1] Mv, Cv, Rv
    cdef object clusters_m_toPrint
    cdef object clusters_mr_toPrint
    cdef object clusters_mc_toPrint
    cdef object clusters_mcr_toPrint
    cdef object clusters_justWords
    cpdef object getClusters(self, object standard)
    cpdef object getClusters_justWords(self, standard)
