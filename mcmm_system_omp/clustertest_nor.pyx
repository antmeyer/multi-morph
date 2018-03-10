#cython: profile=True
#cython: boundscheck=False
#cython: wraparound=False
#cython: cdivision=True
#encoding: utf-8
#filename: clustertest_nor.pyx

cdef FLOAT clustertest(FLOAT** M, 
		FLOAT* M_data, int* M_indices, int* M_indptr, 
		FLOAT** C, FLOAT** X, FLOAT** R,
		int I, int J, int K, int k_to_skip, FLOAT normConstant):
	
	cdef int i, j, k, k_ptr, ctr
	cdef FLOAT E = 0.0
	cdef FLOAT diff_j, prod_j		
	cdef int m_row_start, m_row_end
	E = 0.0
	
	# for i in range(I):
	# 	m_row_start = M_indptr[i]
	# 	m_row_end = M_indptr[i+1]
	# 	for j in range(J):
	# 		prod_j = 1.0			
	# 		for k_ptr from m_row_start <= k_ptr < m_row_end:
	# 		prod_j *= (1.0 - M_data[k_ptr] * C[j][M_indices[k_ptr]])
	# 		R[i][j] = 1.0 - prod_j
	# 		diff_j = X[i][j] - R[i][j]
	# 		E += diff_j*diff_j

	for i in range(I):
		m_row_start = M_indptr[i]
		m_row_end = M_indptr[i+1]
		for j in range(J):
			prod_j = 1.0			
			for k_ptr from m_row_start <= k_ptr < k_to_skip:
				prod_j *= (1.0 - M_data[k_ptr] * C[j][M_indices[k_ptr]])
			for k_ptr from k_to_skip < k_ptr < m_row_end:
				prod_j *= (1.0 - M_data[k_ptr] * C[j][M_indices[k_ptr]])
			R[i][j] = 1.0 - prod_j
			#diff_j = X[i][j] - R[i][j]
	
	for i in range(I):
		for j in range(J):		
			E += (X[i][j] - R[i][j])*(X[i][j] - R[i][j])

	return 0.5 * E * normConstant
	
