#cython: boundscheck=False
#cython: wraparound=False
#cython: cdivision=True
# cython: profile=True
# encoding: utf-8
# filename: matmath_sparse.pyx

#import numpy as np

cdef void mul_1d_scalar(double* v_data,
						int* v_indices,
						int* v_indptr,
						double scalar,
						double* output_data,
						int* output_indices,
						int* output_indptr):
	cdef unint j
	cdef int v_data_len = v_indptr[1]
	for j in range(v_data_len):
		output_data[j] = v_data[j]*scalar
		output_indices[j] = v_indices[j]
	output_indptr[0] = 0
	output_indptr[1] = v_data_len
	
cdef void mul_2d_scalar(double* M_data,
						int* M_indices,
						int* M_indptr,
						int M_data_len,
						int M_indptr_len,
						double scalar,
						double* output_data,
						int* output_indices,
						int* output_indptr):
	cdef unint i
	for i in range(M_data_len):
		output_data[i] = M_data[i]*scalar
		output_indices[i] = M_indices[i]
	for i in range(M_indptr_len):
		output_indptr[i] = M_indptr[i]

cdef void mul_2d_scalar_2(double* M_data,
						int* M_indices,
						int* M_indptr,
						int M_indptr_len,
						double scalar,
						double** output):
	
	cdef unint count, col_ptr
	cdef int start, end, i, j
	for count in range(M_indptr_len):
		start = M_indptr[count]
		end = M_indptr[count+1]
		for col_ptr in range(start, end):
			j = M_indices[col_ptr]
			output[count][j] = M_data[col_ptr]*scalar
		
cdef double mul_1d_1d(double* v1_data,
						int* v1_indices,
						int* v1_indptr,
						double* v2_data,
						int* v2_indices,
						int* v2_indptr):						
	cdef int count, v1_pointer, v2_pointer, v1_index, v2_index
	cdef int v1_nnz = v1_indptr[1]
	cdef int v2_nnz = v2_indptr[1]
	cdef bint increase_v1, increase_v2, exhausted_v2
	cdef double inner_product
	cdef int num_rows = 1
	
	for count in range(num_rows):
		inner_product = 0.0
		
		v2_pointer = 0
		increase_v2 = 0
		exhausted_v2 = 0
		
		v2_index = v2_indices[v2_pointer]
		row_start = v1_indptr[count]
		row_end = v1_indptr[count+1]

		for v1_pointer in range(row_start, row_end):
			if exhausted_v2 == 1:
				exhausted_v2 = 0
				break
			
			increase_v1 = 0
			while increase_v1 == 0:
				if increase_v2 == 1:
					v2_pointer += 1
					if v2_pointer >= v2_nnz:
						exhausted_v2 = 1
						break
					v2_index = v2_indices[v2_pointer]
					increase_v2 = 0
				
				v1_index = v1_indices[v1_pointer]

				if v1_index < v2_index:
					increase_v1 = 1
					continue

				elif v1_index == v2_index:
					inner_product += v1_data[v1_pointer]*v2_data[v2_pointer]
					increase_v2 = 1
					increase_v1 = 1

				elif v1_index > v2_index:
					increase_v2 = 1
  
	return inner_product

						
cdef int mul_2d_1d(double* M_data, int* M_indices, int* M_indptr, int M_indptr_len, double* v_data, int* v_indices, int* v_indptr, double* output):
# 	ASSUMPTION: CSR structure of input matrix has sorted indices.
# 
# 	m_indptr,       matrix's pointer to row start in indices/data
# 	m_indices,      non-negative column indices for matrix
# 	m_data,         non-negative data values for matrix
# 	v_indices,      non-negative column indices for vector
# 	v_data,         non-negative data values for vector

#     assert m_indptr.dtype == DTYPE_INT
#     assert m_indices.dtype == DTYPE_INT
#     assert m_data.dtype == DTYPE_FLT
#     assert v_indices.dtype == DTYPE_INT
#     assert v_data.dtype == DTYPE_FLT
	cdef int i
	cdef int count, v_pointer, increase_v, exhausted_v, v_index, row_start
	cdef int v_indices_len = v_indptr[1]
	cdef int row_end, m_pointer, increase_m, col_index
	cdef int num_rows = M_indptr_len - 1
	cdef double inner_product
	
	for count in range(num_rows):
		inner_product = 0.0
		
		v_pointer = 0
		increase_v = 0
		exhausted_v = 0
		
		v_index = v_indices[v_pointer]
		row_start = M_indptr[count]
		row_end = M_indptr[count+1]
# 		print ""
# 		print "M row_start:", row_start, "  M row_end:", row_end
# 		print ""
		for m_pointer in range(row_start, row_end):
			if exhausted_v == 1:
				exhausted_v = 0
				break
			
			#print "\tM", "index:", M_indices[m_pointer], "  datum:", M_data[m_pointer]
			
			increase_m = 0
			while increase_m == 0:
				if increase_v == 1:
					v_pointer += 1
					if v_pointer >= v_indices_len:
						exhausted_v = 1
						break
					v_index = v_indices[v_pointer]
					increase_v = 0
					
				#print "\t\tv", "index:", v_indices[v_pointer], "  datum:", v_data[v_pointer]
				
				col_index = M_indices[m_pointer]

				if col_index < v_index:
					increase_m = 1
					continue

				elif col_index == v_index:
					inner_product += M_data[m_pointer]*v_data[v_pointer]
					increase_v = 1
					increase_m = 1

				elif col_index > v_index:
					increase_v = 1
 
		output[count] = inner_product
	
	
cdef int mul_1d_2d(double* v_data, int* v_indices, int* v_indptr,
					double* M_data, int* M_indices, int* M_indptr, int M_indptr_len, 
					double* output):
	cdef int i
	cdef int count, v_pointer, increase_v, exhausted_v, v_index, row_start
	cdef int v_indices_len = v_indptr[1]
	cdef int row_end, m_pointer, increase_m, col_index
	cdef int M_num_rows = M_indptr_len - 1
	cdef double inner_product
	
	for count in range(M_num_rows):
		inner_product = 0.0
		
		v_pointer = 0
		increase_v = 0
		exhausted_v = 0
		
		v_index = v_indices[v_pointer]
		row_start = M_indptr[count]
		row_end = M_indptr[count+1]

		for m_pointer in range(row_start, row_end):
			if exhausted_v == 1:
				exhausted_v = 0
				break
			
			increase_m = 0
			while increase_m == 0:
				if increase_v == 1:
					v_pointer += 1
					if v_pointer >= v_indices_len:
						exhausted_v = 1
						break
					v_index = v_indices[v_pointer]
					increase_v = 0
				
				col_index = M_indices[m_pointer]

				if col_index < v_index:
					increase_m = 1
					continue

				elif col_index == v_index:
					inner_product += M_data[m_pointer]*v_data[v_pointer]
					increase_v = 1
					increase_m = 1

				elif col_index > v_index:
					increase_v = 1
 
		output[count] = inner_product
		
		
cdef int mul_2d_2d(double* M1_data,
				int* M1_indices,
				int* M1_indptr,
				int M1_indptr_len,
				double* M2_data,
				int* M2_indices,
				int* M2_indptr,
				int M2_indptr_len,
				double** output):
	cdef unint i,j
	cdef int m1_row_start, m2_row_start, m1_row_end, m2_row_end
	cdef int m1_pointer, m2_pointer, increase_m1, increase_m2, m1_index, m2_index
	cdef int M1_num_rows = M1_indptr_len - 1
	cdef int M2_num_rows = M2_indptr_len - 1
	cdef double inner_product
# 	print "mul_2d_2d; M1 rows:", M1_num_rows 
# 	print "mul_2d_2d; M2 rows:", M2_num_rows 
# 	print "mul_2d_2d; output[0][0]:", output[0][0]
	for i in range(M1_num_rows):
		m1_row_start = M1_indptr[i]
		m1_row_end = M1_indptr[i+1]
		
		for j in range(M2_num_rows):
			inner_product = 0.0
		
			m1_pointer = m1_row_start		# v_pointer = m1_row_start
			increase_m1 = 0
			exhausted_m1 = 0
		
			m1_index = M1_indices[m1_pointer]
			
			m2_row_start = M2_indptr[j]
			m2_row_end = M2_indptr[j+1]
			#print "mul_2d_2d 1"
			for m2_pointer in range(m2_row_start, m2_row_end):
				if exhausted_m1 == 1:
					exhausted_m1 = 0
					break
			
				increase_m2 = 0  
					# increase_m is a flag that indicates when it is time to
					## increment to the next integer in the current indptr span.
					### an indptr span is the interval between any two adjacent integers
					### in an indptr array.
					# In the while loop below, we increment v_pointer until
					## v_indices[v_pointer] > M_indices[m_pointer], or until we
					## run out of items in v_indices.
					# Then we break and increment m_pointer.
				while increase_m2 == 0:
					if increase_m1 == 1:
						m1_pointer += 1
						if m1_pointer >= m1_row_end:  # if v_pointer >= M1_row_end
							exhausted_m1 = 1
							break
						m1_index = M1_indices[m1_pointer]
						increase_m1 = 0
				
					m2_index = M2_indices[m2_pointer]
					#print "mul_2d_2d 2"
					if m2_index < m1_index:
						increase_m2 = 1
						continue

					elif m2_index == m1_index:
						inner_product += M2_data[m2_pointer]*M1_data[m1_pointer]
						increase_m1 = 1
						increase_m2 = 1

					elif m2_index > m1_index:
						increase_m1 = 1
			#print "mul_2d_2d 3"
			output[i][j] = inner_product

cdef int transpose(double* M_data,
					int* M_indices,
					int* M_indptr,
					int M_numrows,
					double* M_T_data,
					int* M_T_indices,
					int* M_T_indptr,
					int M_T_numrows):
	cdef int j
	cdef double ** M_T = <double **>malloc(M_T_numrows * sizeof(double*))
	for j in range(M_T_numrows):
		M_T[j] = <double *>malloc(M_numrows * sizeof(double))
	M_T = &M_T[0]
	#print "trans 1"
	sparsemat.decompress_T(M_data, M_indices, M_indptr, M_T, M_numrows, M_T_numrows)
	#print "trans 2"
	sparsemat.compress_dbl_mat(M_T, M_T_data, M_T_indices, M_T_indptr, M_T_numrows, M_numrows)
	#print "trans 3"
	dealloc_matrix_2(M_T, M_T_numrows)
	#print "trans 4"
	
cdef int square_2d(double* M1_data,
						int* M1_indices,
						int* M1_indptr,
						int M1_indptr_len,
						double** output):
	cdef unint i1,i2
	cdef int m1_row_start, m2_row_start, m1_row_end, m2_row_end
	cdef int m1_pointer, m2_pointer, increase_m1, increase_m2, m1_index, m2_index
	cdef int M1_num_rows = M1_indptr_len - 1
	cdef int M2_num_rows = M1_num_rows 
	cdef double inner_product
	#print "M1_num_rows, M2_num_rows = ", M1_num_rows, M2_num_rows
	for i1 in range(M1_num_rows):
		m1_row_start = M1_indptr[i1]
		m1_row_end = M1_indptr[i2+1]
		
		for i2 in range(M2_num_rows):
			inner_product = 0.0
		
			m1_pointer = m1_row_start		# v_pointer = m1_row_start
			increase_m1 = 0
			exhausted_m1 = 0
		
			m1_index = M1_indices[m1_pointer]
			
			m2_row_start = M1_indptr[i2]
			m2_row_end = M1_indptr[i2+1]
			#print "sparse square 1"
			
			for m2_pointer in range(m2_row_start, m2_row_end):  # These are the columns.
				if exhausted_m1 == 1:
					exhausted_m1 = 0
					break
			
				increase_m2 = 0  
					# increase_m is a flag that indicates when it is time to
					## increment to the next integer in the current indptr span.
					### an indptr span is the interval between any two adjacent integers
					### in an indptr array.
					# In the while loop below, we increment M1_pointer until
					## M1_indices[M1_pointer] > M2_indices[M2_pointer], or until we
					## run out of items in M1_indices.
					# Then we break and increment m_pointer.
				while increase_m2 == 0:
					if increase_m1 == 1:
						m1_pointer += 1
						if m1_pointer >= m1_row_end:  # if v_pointer >= M1_row_end
							exhausted_m1 = 1
							break
						m1_index = M1_indices[m1_pointer]
						increase_m1 = 0
						
					m2_index = M1_indices[m2_pointer]
					#print "sparse square 2"

					if m2_index < m1_index:
						increase_m2 = 1
						continue

					elif m2_index == m1_index:
						inner_product += M1_data[m2_pointer]*M1_data[m1_pointer]
						
						increase_m1 = 1
						increase_m2 = 1

					elif m2_index > m1_index:
						increase_m1 = 1
					#print "sparse square 3"
			#print "i1,i2 =", i1, ",", i2
			output[i1][i2] = inner_product
			#print "sparse square 4"
			
# cdef int square_2d_diag(double* M1_data,
# 						int* M1_indices,
# 						int* M1_indptr,
# 						int M1_indptr_len,
# 						double* output):
# 	cdef unint k
# 	cdef int m1_row_start, m2_row_start
# 	cdef int M1_num_rows = M1_indptr_len - 1
# 	cdef double inner_product
# 	
# 	for k in range(M1_num_rows):
# 		m1_row_start = M1_indptr[k]
# 		m1_row_end = M1_indptr[k+1]
# 		
# 		inner_product = 0.0
# 
# 		for m1_pointer in range(m1_row_start, m1_row_end):
# 			inner_product += M1_data[m1_pointer]*M1_data[m1_pointer]
#  
# 		output[k] = inner_product
		
cdef int square_2d_invDiag(double* M1_data,
						int* M1_indices,
						int* M1_indptr,
						int M1_indptr_len,
						double* output_data,
						int* output_indices,
						int* output_indptr):
	cdef unint k
	cdef int m1_row_start, m2_row_start
	cdef int M1_num_rows = M1_indptr_len - 1
	cdef double inner_product
	
	for k in range(M1_num_rows):
		m1_row_start = M1_indptr[k]
		m1_row_end = M1_indptr[k+1]
		
		inner_product = 0.0

		for m1_pointer in range(m1_row_start, m1_row_end):
			inner_product += M1_data[m1_pointer]*M1_data[m1_pointer]
		
		output_indices[k] = k
		output_indptr[k] = k
		
		if inner_product == 0.0:
			output_data[k] = 1.0
		else:
			output_data[k] = 1.0 / inner_product
	
	output_data[M1_num_rows] = M1_num_rows

# cdef int add_1d_1d(double* v1_data, int* v1_indices, int* v1_indptr,
# 				double* v2_data, int* v2_indices, int* v2_indptr, 
# 				#double* output_data, int* output_indices, int* output_indptr,
# 				double* output,
# 				int output_len):
# 	cdef int v1_nnz, v2_nnz, v1_pointer, v2_pointer, v1_index, v2_index, counter, k
# 	#cdef int output_nnz
# 	cdef bint increase_v1, increase_v2, exhausted_v1, exhausted_v2
# 	cdef int k_pointer
# 	cdef double diff
# 	v1_nnz = v1_indptr[1]
# 	v2_nnz = v2_indptr[1]
# 	#output_nnz = v1_nnz + v2_nnz 
# 	v1_pointer = 0
# 	v2_pointer = 0
# 	v1_index = v1_indices[v1_pointer]
# 	v2_index = v2_indices[v2_pointer]
# 	increase_v1 = 0
# 	increase_v2 = 0
# 	exhausted_v1 = 0
# 	exhausted_v2 = 0
# # 	k_pointer = 0
# # 	counter = 0
# 	
# 	for k in range(output_len):
# 		output[k] = 0.0
# 		
# 	while v1_pointer < v1_nnz or v2_pointer < v2_nnz:
# 		if exhausted_v1 == 1 and exhausted_v2 == 0:
# 			while v2_pointer < v2_nnz:
# 				v2_index = v2_indices[v2_pointer]
# 				output_data[v2_index] = v2_data[v2_pointer]
# # 				output_indices[k_pointer] = counter
# # 				counter += 1
# # 				k_pointer += 1
# 				v2_pointer += 1
# 			break
# 		elif exhausted_v2 == 1 and exhausted_v1 == 0:
# 			while v1_pointer < v1_nnz:
# 				v1_index = v1_indices[v1_pointer]
# 				output_data[v1_index] = v1_data[v1_pointer]
# # 				output_indices[k_pointer] = counter
# # 				counter += 1
# # 				k_pointer += 1
# 				v1_pointer += 1
# 			break
# 		if v1_index < v2_index:
# 			output_data[v1_indices] = v1_data[v1_pointer]
# # 			output_data[k_pointer] = v1_data[v1_pointer]
# # 			output_indices[k_pointer] = counter
# # 			counter += 1
# # 			k_pointer += 1
# 			increase_v1 = 1
# 			
# 		elif v1_index == v2_index:
# 			output_data[v1_index] = v1_data[v1_pointer] + v2_data[v2_pointer]
# # 			output_nnz -= 1
# # 			output_data[k_pointer] = v1_data[v1_pointer] + v2_data[v2_pointer]
# # 			output_indices[k_pointer] = counter
# # 			counter += 1
# # 			k_pointer += 1
# # 			increase_v2 = 1
# 			increase_v1 = 1
# 
# 		elif v1_index > v2_index:
# 			output_data[v2_index:] = v2_data[v2_pointer]
# # 			output_data[k_pointer] = v2_data[v2_pointer]
# # 			output_indices[k_pointer] = counter
# # 			counter += 1
# # 			k_pointer += 1
# 			increase_v2 = 1
# 		
# 		if increase_v2 == 1:
# 			v2_pointer += 1
# 			if v2_pointer > v2_nnz-1:
# 				exhausted_v2 = 1
# 			else:
# 				v2_index = v2_indices[v2_pointer]
# 			increase_v2 = 0
# 		
# 		if increase_v1 == 1:
# 			v1_pointer += 1
# 			if v1_pointer > v1_nnz-1:
# 				exhausted_v1 = 1
# 			else:
# 				v1_index = v1_indices[v1_pointer]
# 			increase_v1 = 0
# # 	output_indptr[0] = 0
# # 	output_indptr[1] = output_nnz


# cdef int subt_1d_1d(double* v1_data, int* v1_indices, int* v1_indptr,
# 				double* v2_data, int* v2_indices, int* v2_indptr, 
# 				#double* output_data, int* output_indices, int* output_indptr,
# 				double* output,
# 				int output_len):
# 	cdef int v1_nnz, v2_nnz, v1_pointer, v2_pointer, v1_index, v2_index, counter
# 	cdef int output_nnz
# 	cdef bint increase_v1, increase_v2, exhausted_v1, exhausted_v2
# 	cdef int k_pointer
# 	cdef double diff
# 	v1_nnz = v1_indptr[1]
# 	v2_nnz = v2_indptr[1]
# 	output_nnz = v1_nnz + v2_nnz
# 	v1_pointer = 0
# 	v2_pointer = 0
# 	v1_index = v1_indices[v1_pointer]
# 	v2_index = v2_indices[v2_pointer]
# 	increase_v1 = 0
# 	increase_v2 = 0
# 	exhausted_v1 = 0
# 	exhausted_v2 = 0
# 	k_pointer = 0
# 	counter = 0
# 	while v1_pointer < v1_nnz or v2_pointer < v2_nnz:
# 		if exhausted_v1 == 1 and exhausted_v2 == 0:
# 			while v2_pointer < v2_nnz:
# 				output_data[k_pointer] = -v2_data[v2_pointer]
# 				output_indices[k_pointer] = counter
# 				k_pointer += 1
# 				counter += 1
# 				v2_pointer += 1
# 			break
# 		elif exhausted_v2 == 1 and exhausted_v1 == 0:
# 			while v1_pointer < v1_nnz:
# 				output_data[k_pointer] = v1_data[v1_pointer]
# 				output_indices[k_pointer] = counter
# 				k_pointer += 1
# 				counter += 1
# 				v1_pointer += 1
# 			break
# 		if v1_index < v2_index:
# 			#print "\t", v1_index, "<", v2_index
# 			output_data[k_pointer] = v1_data[v1_pointer]
# 			output_indices[k_pointer] = counter
# 			k_pointer += 1
# 			counter += 1
# 			increase_v1 = 1
# 			
# 		elif v1_index == v2_index:
# 			#print "\t", v1_index, "==", v2_index
# 			diff = v1_data[v1_pointer] - v2_data[v2_pointer]
# 			if diff == 0.0:
# 				output_nnz -= 2
# 			else:
# 				output_data[k_pointer] = diff
# 				output_indices[k_pointer] = counter
# 				output_nnz -= 1
# 				k_pointer += 1
# 			counter += 1
# 			increase_v2 = 1
# 			increase_v1 = 1
# 
# 		elif v1_index > v2_index:
# 			#print "\t", v1_index, ">", v2_index
# 			output_data[k_pointer] = - v2_data[v2_pointer]
# 			output_indices[k_pointer] = counter
# 			k_pointer += 1
# 			counter += 1
# 			increase_v2 = 1
# 		
# 		if increase_v2 == 1:
# 			v2_pointer += 1
# 			if v2_pointer > v2_nnz-1:
# 				exhausted_v2 = 1
# 			else:
# 				v2_index = v2_indices[v2_pointer]
# 			increase_v2 = 0
# 		
# 		if increase_v1 == 1:
# 			v1_pointer += 1
# 			if v1_pointer > v1_nnz-1:
# 				exhausted_v1 = 1
# 			else:
# 				v1_index = v1_indices[v1_pointer]
# 			increase_v1 = 0
# 	output_indptr[0] = 0
# 	output_indptr[1] = output_nnz 

# cdef add_1d_1d(double* v1_data,
# 						int* v1_indices,
# 						int* v1_indptr,
# 						double* v2_data,
# 						int* v2_indices,
# 						int* v2_indptr,
# 						double* output,
# 						int output_len):
# 						
# 	cdef int count, v1_pointer, v2_pointer, v1_index, v2_index, k
# 	cdef int v1_nnz = v1_indptr[1]
# 	cdef int v2_nnz = v2_indptr[1]
# 	cdef bint increase_v1, increase_v2, exhausted_v2
# 	cdef double inner_product
# 	cdef int num_rows = 1
# 
# 	# make sure output vector is initially all zeros
# 	for k in range(output_len):
# 		output[k] = 0.0
# 	
# 	for count in range(num_rows):
# 		inner_product = 0.0
# 		
# 		v2_pointer = 0
# 		increase_v2 = 0
# 		exhausted_v2 = 0
# 		
# 		v2_index = v2_indices[v2_pointer]
# 		row_start = v1_indptr[count]
# 		row_end = v1_indptr[count+1]
# 
# 		for v1_pointer in range(row_start, row_end):
# 			if exhausted_v2 == 1:
# 				exhausted_v2 = 0
# 				break
# 			
# 			increase_v1 = 0
# 			while increase_v1 == 0:
# 				if increase_v2 == 1:
# 					v2_pointer += 1
# 					if v2_pointer >= v2_nnz:
# 						exhausted_v2 = 1
# 						break
# 					v2_index = v2_indices[v2_pointer]
# 					increase_v2 = 0
# 				
# 				v1_index = v1_indices[v1_pointer]
# 
# 				if v1_index < v2_index:
# 					output[v1_index] = v1_data[v1_pointer]
# 					increase_v1 = 1
# 					continue
# 
# 				elif v1_index == v2_index:
# 					output[v1_index] = v1_data[v1_pointer] + v2_data[v2_pointer]
# 					increase_v2 = 1
# 					increase_v1 = 1
# 
# 				elif v1_index > v2_index:
# 					output[v2_index] = v2_data[v2_pointer]
# 					increase_v2 = 1
# 
# cdef subt_1d_1d(double* v1_data,
# 						int* v1_indices,
# 						int* v1_indptr,
# 						double* v2_data,
# 						int* v2_indices,
# 						int* v2_indptr,
# 						double* output,
# 						int output_len):
# 						
# 	cdef int count, v1_pointer, v2_pointer, v1_index, v2_index, k
# 	cdef int v1_nnz = v1_indptr[1]
# 	cdef int v2_nnz = v2_indptr[1]
# 	cdef bint increase_v1, increase_v2, exhausted_v2
# 	cdef double inner_product
# 	cdef int num_rows = 1
# 	
# 	# make sure output vector is initially all zeros
# 	for k in range(output_len):
# 		output[k] = 0.0
# 		
# 	for count in range(num_rows):
# 		inner_product = 0.0
# 		
# 		v2_pointer = 0
# 		increase_v2 = 0
# 		exhausted_v2 = 0
# 		
# 		v2_index = v2_indices[v2_pointer]
# 		row_start = v1_indptr[count]
# 		row_end = v1_indptr[count+1]
# 
# 		for v1_pointer in range(row_start, row_end):
# # 			if exhausted_v2 == 1:
# # 				exhausted_v2 = 0	
# # 				break
# 			
# 			increase_v1 = 0
# 			while increase_v1 == 0:
# 				if increase_v2 == 1:
# 					v2_pointer += 1
# 					if v2_pointer >= v2_nnz:
# 						exhausted_v2 = 1
# 						break
# 					v2_index = v2_indices[v2_pointer]
# 					increase_v2 = 0
# 				
# 				v1_index = v1_indices[v1_pointer]
# 
# 				if v1_index < v2_index:
# 					output[v1_index] = v1_data[v1_pointer]
# 					increase_v1 = 1
# 					continue
# 
# 				elif v1_index == v2_index:
# 					output[v1_index] = v1_data[v1_pointer] - v2_data[v2_pointer]
# 					increase_v2 = 1
# 					increase_v1 = 1
# 
# 				elif v1_index > v2_index:
# 					output[v2_index] = -v2_data[v2_pointer]
# 					increase_v2 = 1

cdef int add_1d_1d(double* v1_data, int* v1_indices, int* v1_indptr,
				double* v2_data, int* v2_indices, int* v2_indptr, 
				#double* output_data, int* output_indices, int* output_indptr,
				double* output,
				int output_len):
	cdef int v1_nnz, v2_nnz, v1_pointer, v2_pointer, v1_index, v2_index, k
	cdef bint increase_v1, increase_v2, exhausted_v1, exhausted_v2
	cdef double diff
	v1_nnz = v1_indptr[1]
	v2_nnz = v2_indptr[1] 
	v1_pointer = 0
	v2_pointer = 0
	v1_index = v1_indices[v1_pointer]
	v2_index = v2_indices[v2_pointer]
	increase_v1 = 0
	increase_v2 = 0
	exhausted_v1 = 0
	exhausted_v2 = 0
	
	for k in range(output_len):
		output[k] = 0.0
		
	while v1_pointer < v1_nnz or v2_pointer < v2_nnz:
		if exhausted_v1 == 1 and exhausted_v2 == 0:
			while v2_pointer < v2_nnz:
				v2_index = v2_indices[v2_pointer]
				output[v2_index] = v2_data[v2_pointer]
				v2_pointer += 1
			break
		elif exhausted_v2 == 1 and exhausted_v1 == 0:
			while v1_pointer < v1_nnz:
				v1_index = v1_indices[v1_pointer]
				output[v1_index] = v1_data[v1_pointer]
				v1_pointer += 1
			break
		if v1_index < v2_index:
			output[v1_index] = v1_data[v1_pointer]
			increase_v1 = 1
			
		elif v1_index == v2_index:
			output[v1_index] = v1_data[v1_pointer] + v2_data[v2_pointer]
			increase_v1 = 1
			increase_v2 = 1

		elif v1_index > v2_index:
			output[v2_index] = v2_data[v2_pointer]
			increase_v2 = 1
		
		if increase_v2 == 1:
			v2_pointer += 1
			if v2_pointer > v2_nnz-1:
				exhausted_v2 = 1
			else:
				v2_index = v2_indices[v2_pointer]
			increase_v2 = 0
		
		if increase_v1 == 1:
			v1_pointer += 1
			if v1_pointer > v1_nnz-1:
				exhausted_v1 = 1
			else:
				v1_index = v1_indices[v1_pointer]
			increase_v1 = 0

cdef int subt_1d_1d(double* v1_data, int* v1_indices, int* v1_indptr,
				double* v2_data, int* v2_indices, int* v2_indptr, 
				#double* output_data, int* output_indices, int* output_indptr,
				double* output,
				int output_len):
	cdef int v1_nnz, v2_nnz, v1_pointer, v2_pointer, v1_index, v2_index, k
	cdef bint increase_v1, increase_v2, exhausted_v1, exhausted_v2
	cdef double diff
	v1_nnz = v1_indptr[1]
	v2_nnz = v2_indptr[1] 
	v1_pointer = 0
	v2_pointer = 0
	v1_index = v1_indices[v1_pointer]
	v2_index = v2_indices[v2_pointer]
	increase_v1 = 0
	increase_v2 = 0
	exhausted_v1 = 0
	exhausted_v2 = 0
	
	for k in range(output_len):
		output[k] = 0.0
		
	while v1_pointer < v1_nnz or v2_pointer < v2_nnz:
		if exhausted_v1 == 1 and exhausted_v2 == 0:
			while v2_pointer < v2_nnz:
				v2_index = v2_indices[v2_pointer]
				output[v2_index] = -v2_data[v2_pointer]
				v2_pointer += 1
			break
		elif exhausted_v2 == 1 and exhausted_v1 == 0:
			while v1_pointer < v1_nnz:
				v1_index = v1_indices[v1_pointer]
				output[v1_index] = v1_data[v1_pointer]
				v1_pointer += 1
			break
		if v1_index < v2_index:
			output[v1_index] = v1_data[v1_pointer]
			increase_v1 = 1
			
		elif v1_index == v2_index:
			output[v1_index] = v1_data[v1_pointer] - v2_data[v2_pointer]
			increase_v1 = 1
			increase_v2 = 1

		elif v1_index > v2_index:
			output[v2_index] = -v2_data[v2_pointer]
			increase_v2 = 1
		
		if increase_v2 == 1:
			v2_pointer += 1
			if v2_pointer > v2_nnz-1:
				exhausted_v2 = 1
			else:
				v2_index = v2_indices[v2_pointer]
			increase_v2 = 0
		
		if increase_v1 == 1:
			v1_pointer += 1
			if v1_pointer > v1_nnz-1:
				exhausted_v1 = 1
			else:
				v1_index = v1_indices[v1_pointer]
			increase_v1 = 0
