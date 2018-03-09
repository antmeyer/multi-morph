#cython: boundscheck=False
#cython: wraparound=False
#cython: cdivision=True
#encoding: utf-8
#filename: numberNonZeros.pyx

cdef int matrixNonZeros(FLOAT** matrix, int I, int J):
	cdef int i, j, nnz
	nnz = 0
	for i in range(I):
		for j in range(J):
			if matrix[i][j] != 0:
				nnz += 1
	return nnz
	
cdef int vectorNonZeros(FLOAT* vector, int J):
	cdef int j, nnz 
	nnz = 0
	for j in range(J):
		if vector[j] != 0:
			nnz += 1
	return nnz