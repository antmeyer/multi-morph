#cython: boundscheck=False
#cython: wraparound=False
#cython: cdivision=True
# encoding: utf-8
# filename: matmath.pyx

import numpy as np

cdef void mul_2d_2d(FLOAT** M1, FLOAT** M2, FLOAT** out, INT_t I, INT_t K, INT_t J):
	cdef unint i,j,k
	#I = M1.shape[0] # the number of rows in the first item,
		# as well as the number of columns in the result matrix	
	#K = M1.shape[1] # the number of columns in the first item 
		# (= the number of rows in the 2nd item).
	#J = M2.shape[1] # the number of columns in the second item, 
		# as well as the number of columns in the result matrix
	cdef FLOAT s
	for i in range(I):
		# For each individual i iteration, we do a simple vector-to-matrix product,
		# namely, the vector M1_i[k] times the matrix M2[k][j].
		for j in range(J):
			s = 0.0
			for k in range(K):
				s += M1[i][k] * M2[k][j]
			out[i][j] = s

cdef void mul_1d_2d(FLOAT* v1, FLOAT** M2, FLOAT* out, INT_t J, INT_t K):
	cdef unint j,k
	# J = number of columns in matrix M2 and the
		#**number of columns in the result vector "out"**.
	# K = number of columns in v1 and number of rows in M2.
	cdef FLOAT s
	for j in range(J):
		s = 0.0
		for k in range(K):
			s += v1[k]*M2[k][j]
		out[j] = s

cdef void mul_2d_1d(FLOAT** M1, FLOAT* v2, FLOAT* out, INT_t I, INT_t K):
	cdef unint i,k
	#I = M1.shape[0] # the number of rows in the 1st item, the matrix M1
	#K = M1.shape[1] # the number of columns in the matrix M1
		# (= number of "rows" in the column vector v2,
		# but essentially the length of v2 regardless of its orientation).
	#J = v2.shape[0] # the number of columns in the 2nd item 
		#(But here, J = 1, since the 2nd item is a vector.)
	cdef FLOAT s
	for i in range(I):
		s = 0.0
		for k in range(K):
			s += M1[i][k] * v2[k]
		out[i] = s
	
# cdef inline FLOAT mul_1d_1d(FLOAT* v1, FLOAT* v2, INT_t J):
# 	#cdef INT_t J
# 	cdef unint j
# 	cdef FLOAT out
# 	#J = v1.shape[0]
# 	for j in range(J):
# 		out += v1[j] * v2[j]
# 	return out
	
# cdef inline void mul_1d_scalar(FLOAT* v1, FLOAT scalar, FLOAT* out, INT_t J):
# 	cdef unint j
# 	#cdef FLOAT[::1] out = np.empty(J)
# 	for j in range(J):
# 		out[j] = v1[j]*scalar
	
# cdef inline void add_2d_2d(FLOAT** M1, FLOAT** M2, FLOAT** out, INT_t I, INT_t J):
# 	#cdef INT_t ndx
# 	cdef unint i,j
# 	#cdef FLOAT[:,::1] out = np.empty([I,J])
# 	for i in range(I): #I
# 		for j in range(J):  #J
# 			#ndx = i*J + j
# 			out[i][j] = M1[i][j] + M2[i][j]
	
# cdef inline void add_1d_1d(FLOAT* v1, FLOAT* v2, FLOAT* out, INT_t J):
# 	#cdef INT_t J = v1.shape[0]
# 	cdef unint j
# 	#cdef FLOAT[::1] out = np.empty(J)
# 	for j in range(J):
# 		out[j] = v1[j] + v2[j]

# cdef inline void subt_2d_2d(FLOAT** M1, FLOAT** M2, FLOAT** out, INT_t I, INT_t J):
# 	cdef unint i,j
# 	for i in range(I):
# 		for j in range(J):
# 			out[i][j] = M1[i][j] - M2[i][j]

# cdef inline void subt_1d_1d(FLOAT* v1, FLOAT* v2, FLOAT* out, INT_t J):
# 	cdef unint j
# 	#cdef FLOAT[::1] out = np.empty(J)
# 	for j in range(J):
# 		out[j] = v1[j] - v2[j]
	
# cdef inline void trans_2d(FLOAT** M1, FLOAT** out, INT_t J, INT_t I):
# 	cdef unint i,j
# 	#cdef FLOAT[:,::1] out = np.empty([J,I])
# 	for j in range(J):
# 		for i in range(I):
# 			out[j][i] = M1[i][j]

cdef FLOAT norm_2d(FLOAT** M, int I, int J):
	cdef unint i,j
	cdef FLOAT sum_sq
	for i in range(I):
		for j in range(J):
			sum_sq += M[i][j]*M[i][j]
	return sqrt(sum_sq)

cdef FLOAT sum_elems_2d(FLOAT** M, int I, int J):
	cdef unint i,j
	cdef FLOAT sum
	for i in range(I):
		for j in range(J):
			sum += M[i][j]
	return sum
	
cdef void vec(FLOAT** A, FLOAT* vecA, int M, int N):
	cdef int n,m
	for n in range(N):
		for m in range(M):
			vecA[n*M + m] = A[m][n]

cdef void devec(FLOAT* vecA, FLOAT** A, int M, int N):
	cdef int n,m
	for n in range(N):
		for m in range(M):
			A[m][n] = vecA[n*M + m]