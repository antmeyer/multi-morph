#cython: boundscheck=False
#cython: wraparound=False
#cython: cdivision=True
# encoding: utf-8
# filename: dealloc.pyx

cdef void dealloc_matrix(FLOAT ** M, int num_rows):
	cdef int n 
	for n in range(num_rows):
		if M[n] != NULL:
			M[n] = NULL
	free(M)
	M = NULL

cdef void dealloc_matrix_2(FLOAT ** M, int num_rows):
	cdef int n 
	for n in range(num_rows):
		if M[n] != NULL:
			free(M[n])
			M[n] = NULL
	free(M)
	M = NULL

cdef void dealloc_mat_2_int(int ** M, int num_rows):
	cdef int n 
	for n in range(num_rows):
		if M[n] != NULL:
			free(M[n])
			M[n] = NULL
	free(M)
	M = NULL
	
cdef void dealloc_matrix_3d(FLOAT *** M, int num_rows_1, int num_rows_2):
	cdef int i,j
	for i in range(num_rows_1):
		for j in range(num_rows_2):
			if M[i][j] != NULL:
				free(M[i][j])
				M[i][j] = NULL
		if M[i] != NULL:
			free(M[i])
			M[i] = NULL			
	free(M)
	M = NULL
	
cdef void dealloc_vector(FLOAT * v):
	free(v)
	v = NULL
	
cdef void dealloc_vec_int(int * v):
	free(v)
	v = NULL
	
cdef void dealloc_vec_i8(I8 * v):
	free(v)
	v = NULL