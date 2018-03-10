#matmath.pxd
#cython: boundscheck=False
#cython: wraparound=False
#cython: cdivision=True

cimport cython
cimport numpy as np
from libc.stdlib cimport malloc, free
from libc.math cimport sqrt

ctypedef np.intp_t INT_t
ctypedef np.float64_t DOUBLE_t
ctypedef unsigned int unint
ctypedef double FLOAT

#cdef unint i,j,k

cdef void mul_2d_2d(FLOAT** M1, FLOAT** M2, FLOAT** out, INT_t I, INT_t K, INT_t J)
# 	#cdef INT_t I,J,K
# 	cdef unint i,j,k
# 	#I = M1.shape[0]	# the number of rows in the first item
# 	#J = M2.shape[1] # the number of columns in the second item
# 	#K = M1.shape[1] # the number of columns in the first item (= the number of rows in the 2nd item).
# 	cdef FLOAT* s = <FLOAT *>malloc(1*sizeof(FLOAT))
# 	#cdef FLOAT[:,::1] out = np.empty([I,K])
# 	for i in range(I):
# 		for j in range(J):
# 			s[0] = 0.0
# 			for k in range(K):
# 				s[0] += M1[i][k] * M2[k][j]
# 			out[i][j] = s[0]
# 	free(s)

cdef inline void mul_2d_scalar(FLOAT** M1, FLOAT scalar, FLOAT** out, INT_t I, INT_t J):
	cdef unint i,j
	for i in range(I):
		for j in range(J):
			out[i][j] = M1[i][j]*scalar
			
cdef void mul_1d_2d(FLOAT* v1, FLOAT** M2, FLOAT* out, INT_t J, INT_t K)
# 	#cdef INT_t J,K
# 	cdef unint j,k
# 	# I = 1 in this case, so we can omit it. (This would have been the 1st dim. of the 1st item.)
# 	#J = M2.shape[1] # the number of columns in the second item
# 	#K = v1.shape[0] # the number of columns in the first item (but vectors have only one dimension).
# 	cdef FLOAT* s = <FLOAT *>malloc(1*sizeof(FLOAT))
# 	#cdef FLOAT[::1] out = np.empty(J)
# 	for j in range(J):
# 		s[0] = 0.0
# 		for k in range(K):
# 			s[0] += v1[k]*M2[k][j]
# 		out[j] = s[0]
# 	free(s)

cdef void mul_2d_1d(FLOAT** M1, FLOAT* v2, FLOAT* out, INT_t I, INT_t K)
# 	cdef unint i,k
# 	#I = M1.shape[0] # the number of rows in the first item
# 	#J = v1.shape[0] # the number of columns in the second item (J = 1, since the 2nd item is a vector.)
# 	#K = M1.shape[0]	# the number of columns in the first item
# 	cdef FLOAT* s = <FLOAT *>malloc(1*sizeof(FLOAT))
# 	for i in range(I):
# 		s[0] = 0.0
# 		for k in range(K):
# 			s[0] += M1[i][k] * v2[k]
# 		out[k] = s[0]
# 	free(s)

cdef inline FLOAT mul_1d_1d(FLOAT* v1, FLOAT* v2, INT_t J):
	cdef unint j
	cdef FLOAT out
	for j in range(J):
		out += v1[j] * v2[j]
	return out

cdef inline void mul_1d_scalar(FLOAT* v1, FLOAT scalar, FLOAT* out, INT_t J):
	cdef unint j
	for j in range(J):
		out[j] = v1[j]*scalar

cdef inline void add_2d_2d(FLOAT** M1, FLOAT** M2, FLOAT** out, INT_t I, INT_t J):
	cdef unint i,j
	for i in range(I): #I
		for j in range(J):  #J
			out[i][j] = M1[i][j] + M2[i][j]

cdef inline void add_1d_1d(FLOAT* v1, FLOAT* v2, FLOAT* out, INT_t J):
	cdef unint j
	for j in range(J):
		out[j] = v1[j] + v2[j]

cdef inline void subt_2d_2d(FLOAT** M1, FLOAT** M2, FLOAT** out, INT_t I, INT_t J):
	cdef unint i,j
	for i in range(I):
		for j in range(J):
			out[i][j] = M1[i][j] - M2[i][j]

cdef inline void subt_1d_1d(FLOAT* v1, FLOAT* v2, FLOAT* out, INT_t J):
	cdef unint j
	for j in range(J):
		out[j] = v1[j] - v2[j]

cdef inline void trans_2d(FLOAT** M1, FLOAT** out, INT_t J, INT_t I):
	cdef unint i,j
	for j in range(J):
		for i in range(I):
			out[j][i] = M1[i][j]

cdef FLOAT norm_2d(FLOAT** M, int I, int J)

cdef FLOAT sum_elems_2d(FLOAT** M, int I, int J)

cdef void vec(FLOAT** A, FLOAT* vecA, int M, int N)

cdef void devec(FLOAT* vecA, FLOAT** A, int M, int N)
