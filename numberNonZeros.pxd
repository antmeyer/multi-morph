#sparsemat.pxd
#cython: boundscheck=False
#cython: wraparound=False
#cython: cdivision=True

cimport cython
ctypedef double FLOAT

cdef int matrixNonZeros(FLOAT** matrix, int I, int J)

cdef int vectorNonZeros(FLOAT* vector, int J)