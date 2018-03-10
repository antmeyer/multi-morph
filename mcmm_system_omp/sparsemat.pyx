#cython: profile=True
#cython: boundscheck=False
#cython: wraparound=False
#cython: cdivision=True
#encoding: utf-8
#filename: sparsemat.pyx

cdef void compress_dbl_mat(double** matrix, double* data, INT* indices, INT* indptr, int I, int J):
	# Argument I = number of rows in the matrix to be compressed
	# Argument J = number of columns in the matrix to be compressed
	cdef int i, j, row_end, counter, nnz
	indptr[0] = 0
	counter = 0
	for i in range(I):
		row_end = 0
		indptr[i+1] = indptr[i] 
		for j in range(J):
			if matrix[i][j] != 0.0:
				data[counter] = matrix[i][j]
				indices[counter] = j
				counter += 1
				row_end += 1
		indptr[i+1] += row_end

cdef void compress_dbl_mat_val(double** matrix, 
	double* data, INT* indices, INT* indptr,
	double val, INT* val_count, INT* val_index, INT* val_ptr,
	int I, int J):
	# Argument I = number of rows in the matrix to be compressed
	# Argument J = number of columns in the matrix to be compressed
	cdef int i, j, row_end, counter, nnz
	indptr[0] = 0
	counter = 0
	for i in range(I):
		row_end = 0
		indptr[i+1] = indptr[i] 
		for j in range(J):
			if matrix[i][j] != 0.0:
				data[counter] = matrix[i][j]
				indices[counter] = j
				counter += 1
				row_end += 1
				if matrix[i][j] == val:
					val_count[i] = row_end
					val_index[i] = j
					val_ptr[i] = indptr[i] + row_end
		indptr[i+1] += row_end

cdef void compress_dbl_mat_Pr(double** matrix, double* data, INT* indices, INT* indptr, int I, int J, INT* P_indices, INT* P_indptr, INT* P_zero_indices, INT* P_zero_indptr):
	# Pr stands for "projection". In compressing the main input matrix, this function also 
	# makes it conform to the projection matrix (represented in compressed form by the
	# vectors starting with P).
	# The projection matrix here is a unit matrix, containing only 1's and 0's.
	# P_indices are the indices (within rows indicated by P_indptr) containing 1's.
	# P_zero_indices are indices of cells containing zeros;
	# Argument I = number of rows in the matrix to be compressed
	# Argument J = number of columns in the matrix to be compressed
	cdef int h, i, row_end, counter, nnz
	indptr[0] = 0
	counter = 0
	for i in range(I):
		row_end = 0
		indptr[i+1] = indptr[i] 
		for h in range(P_indptr[1]):
			# we only care about cells in matrix with column indices in P_indices.
			# i.e., column indicies associated with a 1 in the P matrix.
			if matrix[i][P_indices[h]] != 0.0:
				data[counter] = matrix[i][P_indices[h]]
				indices[counter] = P_indices[h]
				counter += 1
				row_end += 1
		for h in range(P_zero_indptr[1]):
			matrix[i][P_zero_indices[h]] = 0.0
		indptr[i+1] += row_end

# cdef void compress_dbl_mat_multPr(double** mat,
# 	double* mat_data, INT* mat_indices, INT* mat_indptr
# 	double** P, double* P_data, INT* P_indices, INT* P_indptr
# 	double** out, double* out_data, INT* out_indices, INT* out_indptr,
# 	int i, int J):
# 	# Pr stands for "projection", and mult for "multiply".
# 	# In compressing the main input matrix, this function multiples the main
# 	# matrix's rows (elementwise) by a "projection vector", but only where both
# 	# the projection vector and the main matrix are non-zero.
# 	cdef int j, pk_ptr, ck_ptr, pk, ck, h, counter
# 	cdef bint exhausted_c, exhausted_p, increase_c, increase_p
# 	# This function works with a non-unit projection matrix.
# 	out_indptr[0] = 0
# 	counter = 0
# 	p_nnz = P_indptr[i+1] - P_indptr[i]
# 	for j in range(J):
# 		out_indptr[j+1] - out_indptr[j] 
# 		for k_ptr in range(mat_indptr[j], mat_indptr[j+1]):
# 			row_end = 0
# 	
# 		for ck_ptr in range(mat_indptr[j], mat_indptr[j+1]:
# 			if exhausted_p == 1:
# 				exhausted_p = 0
# 				break
# 				
# 			increase_c = 0
# 			while increase_c == 0:
# 				if increase_p == 1:
# 					pk_ptr += 1
# 					if pk_ptr >= p_nnz:
# 						exhausted_p = 1
# 						break
# 					pk = P_indices[pk_ptr]
# 					increase_p = 0
# 			
# 				ck = mat_indices[ck_ptr]
# 
# 				if ck < pk:
# 					increase_c = 1
# 					continue
# 
# 				elif ck == pk:
# 					output[j][ck] = mat_data[ck_ptr]*P_data[pk_ptr]
# 					increase_p = 1
# 					increase_c = 1
# 
# 				elif ck > pk:
# 					increase_p = 1
# 				
# 			for h in range(P_indptr[i], P_indptr[i+1]):
# 				#out[mat_indices[k]][P_indices[h]] = mat_data[g]*P_indices[h]
# 				out_data[counter] = mat_data[k]*P_indices[h]
# 				out_indices[counter] = P_indices[h]
# 				counter += 1
# 				row_end += 1
# # 			for h in range(zero_indptr[j], zero_indptr[j+1]):
# # 				out[j][zero_indices[h]] = 0.0
# 		out_indptr[j+1] += row_end

cdef void compress_dbl_mat_zeroPr(double** matrix,
	INT* P_zero_indices, INT* P_zero_indptr,
	INT* out_indices, INT* out_indptr,
	int i, int J):
	# Pr stands for "projection", and mult for "multiply".
	# In compressing the main input matrix, this function also 
	# makes it conform to the projection matrix (represented in compressed form by the
	# vectors starting with P).
	# This function works with a non-unit projection matrix.
	cdef int j, h, counter, row_end
	out_indptr[0] = 0
	counter = 0
	for j in range(J):
		row_end = 0
		out_indptr[j+1] = out_indptr[j] 
		for h in range(P_zero_indptr[i], P_zero_indptr[i+1]):
			if matrix[j][P_zero_indices[h]] == 0.0:
				out_indices[counter] = P_zero_indices[h]
				counter += 1
				row_end += 1
		out_indptr[j+1] += row_end


cdef void compress_dbl_mat_for_mult(double** matrix, double* data, INT* indices, INT* indptr, int I, int J):
	# Argument I = number of rows in the matrix to be compressed
	# Argument J = number of columns in the matrix to be compressed
	cdef int i, j, row_end, counter, nnz
	indptr[0] = 0
	counter = 0
	for i in range(I):
		row_end = 0
		indptr[i+1] = indptr[i] 
		for j in range(J):
			if matrix[i][j] != 1.0:
				data[counter] = matrix[i][j]
				indices[counter] = j
				counter += 1
				row_end += 1
		indptr[i+1] += row_end
		
cdef void compress_dbl_mat_lt0(double** matrix, 
	double* data, INT* indices, INT* indptr, int I, int J):
	# lt0 means "less than 0". Thus, this program compresses matrices
	# so that values >= 0 are ignored (as opposed to, e.g., only values = 0).
	# Argument I = number of rows in the matrix to be compressed
	# Argument J = number of columns in the matrix to be compressed
	cdef int i, j, row_end, counter, nnz
	indptr[0] = 0
	counter = 0
	for i in range(I):
		row_end = 0
		indptr[i+1] = indptr[i] 
		for j in range(J):
			if matrix[i][j] < 0.0:
				data[counter] = matrix[i][j]
				indices[counter] = j
				counter += 1
				row_end += 1
		indptr[i+1] += row_end

cdef void compress_dbl_mat_gt0(double** matrix, double* data, INT* indices, 
	INT* indptr, int I, int J):
	# gt0 means "greater than 0". Thus, this program compresses matrices
	# so that values <= 0 are ignored (as opposed to, e.g., only values =0).
	# Argument I = number of rows in the matrix to be compressed
	# Argument J = number of columns in the matrix to be compressed
	cdef int i, j, row_end, counter, nnz
	indptr[0] = 0
	counter = 0
	for i in range(I):
		row_end = 0
		indptr[i+1] = indptr[i] 
		for j in range(J):
			if matrix[i][j] > 0.0:
				data[counter] = matrix[i][j]
				indices[counter] = j
				counter += 1
				row_end += 1
		indptr[i+1] += row_end

cdef void compress_dbl_mat_eq0(double** matrix, INT* indices, 
	INT* indptr, int I, int J):
	# gt0 means "greater than 0". Thus, this program compresses matrices
	# so that values <= 0 are ignored (as opposed to, e.g., only values =0).
	# Argument I = number of rows in the matrix to be compressed
	# Argument J = number of columns in the matrix to be compressed
	cdef int i, j, row_end, counter, nnz
	indptr[0] = 0
	counter = 0
	for i in range(I):
		row_end = 0
		indptr[i+1] = indptr[i] 
		for j in range(J):
			if matrix[i][j] == 0.0:
				indices[counter] = j
				counter += 1
				row_end += 1
		indptr[i+1] += row_end
		
cdef void compress_dbl_mat_lge0(double** matrix, 
	double* data_lt0, INT* indices_lt0, INT* indptr_lt0,
	double* data_gt0, INT* indices_gt0, INT* indptr_gt0,
	double* data_eq0, INT* indices_eq0, INT* indptr_eq0, 
	int I, int J):
	# gt0 means "greater than 0". Thus, this program compresses matrices
	# so that values <= 0 are ignored (as opposed to, e.g., only values =0).
	# Argument I = number of rows in the matrix to be compressed
	# Argument J = number of columns in the matrix to be compressed
	cdef int i, j, counter, nnz, row_end
	cdef int counter_lt0, counter_gt0, counter_eq0,
	cdef int row_end_lt0, row_end_gt0, row_end_eq0
	indptr_lt0[0] = 0 
	indptr_gt0[0] = 0
	indptr_eq0[0] = 0
	counter_lt0 = 0
	counter_gt0 = 0
	counter_eq0 = 0
	for i in range(I):
		row_end_lt0 = 0
		row_end_gt0 = 0
		row_end_eq0 = 0
		indptr_lt0[i+1] = indptr_lt0[i] 
		indptr_gt0[i+1] = indptr_gt0[i]
		indptr_eq0[i+1] = indptr_eq0[i] 
		for j in range(J):
			if matrix[i][j] != 0.0:			
				if matrix[i][j] < 0.0:
					data_lt0[counter_lt0] = matrix[i][j]
					indices_lt0[counter_lt0] = j
					counter_lt0 += 1
					row_end_lt0 += 1
				else:
					data_gt0[counter_gt0] = matrix[i][j]
					indices_gt0[counter_gt0] = j
					counter_gt0 += 1
					row_end_gt0 += 1
			else:
				data_eq0[counter_eq0] = matrix[i][j]
				data_eq0[counter_eq0] = j
				counter_eq0 += 1
				row_end_eq0 += 1
		indptr_lt0[i+1] += row_end_lt0
		indptr_gt0[i+1] += row_end_gt0
		indptr_eq0[i+1] += row_end_eq0
		
cdef void compress_dbl_mat_col(double** matrix, double* data, INT* indices, INT* indptr, int I, int J):
	# Argument I = number of rows in the matrix to be compressed
	# Argument J = number of columns in the matrix to be compressed
	cdef int i, j, col_end, counter, nnz
	indptr[0] = 0
	counter = 0
	for j in range(J):
		col_end = 0
		indptr[j+1] = indptr[j]
		for i in range(I):
			if matrix[i][j] != 0.0:
				data[counter] = matrix[i][j]
				indices[counter] = i
				counter += 1
				col_end += 1
		indptr[j+1] += col_end

cdef void compress_dbl_mat_col_lt0(double** matrix, double* data, INT* indices, INT* indptr, int I, int J):
	# Argument I = number of rows in the matrix to be compressed
	# Argument J = number of columns in the matrix to be compressed
	cdef int i, j, col_end, counter, nnz
	indptr[0] = 0
	counter = 0
	for j in range(J):
		col_end = 0
		indptr[j+1] = indptr[j]
		for i in range(I):
			if matrix[i][j] < 0.0:
				data[counter] = matrix[i][j]
				indices[counter] = i
				counter += 1
				col_end += 1
		indptr[j+1] += col_end

cdef void compress_dbl_mat_col_gt0(double** matrix, double* data, INT* indices, INT* indptr, int I, int J):
	# Argument I = number of rows in the matrix to be compressed
	# Argument J = number of columns in the matrix to be compressed
	cdef int i, j, col_end, counter, nnz
	indptr[0] = 0
	counter = 0
	for j in range(J):
		col_end = 0
		indptr[j+1] = indptr[j]
		for i in range(I):
			if matrix[i][j] > 0.0:
				data[counter] = matrix[i][j]
				indices[counter] = i
				counter += 1
				col_end += 1
		indptr[j+1] += col_end

cdef void compress_dbl_mat_col_lge0(double** matrix, 
	double* data_lt0, INT* indices_lt0, INT* indptr_lt0,
	double* data_gt0, INT* indices_gt0, INT* indptr_gt0,
	double* data_eq0, INT* indices_eq0, INT* indptr_eq0, 
	int I, int J):
	# gt0 means "greater than 0". Thus, this program compresses matrices
	# so that values <= 0 are ignored (as opposed to, e.g., only values =0).
	# Argument I = number of rows in the matrix to be compressed
	# Argument J = number of columns in the matrix to be compressed
	cdef int i, j, col_end_lt0, col_end_gt0, col_end_eq0
	cdef int counter_lt0, counter_gt0, counter_eq0
	indptr_lt0[0] = 0
	indptr_gt0[0] = 0
	indptr_eq0[0] = 0
	counter_lt0 = 0
	counter_gt0 = 0
	counter_eq0 = 0
	for j in range(J):
		col_end_lt = 0
		col_end_gt = 0
		col_end_eq = 0
		indptr_lt0[j+1] = indptr_lt0[j] 
		indptr_gt0[j+1] = indptr_gt0[j]
		indptr_eq0[j+1] = indptr_eq0[j] 
		for i in range(I):
			if matrix[i][j] != 0.0:
				if matrix[i][j] < 0.0:
					data_lt0[counter_lt0] = matrix[i][j]
					indices_lt0[counter_lt0] = i
					counter_lt0 += 1
					col_end_lt0 += 1
				else:
					data_gt0[counter_gt0] = matrix[i][j]
					indices_gt0[counter_gt0] = i
					counter_gt0 += 1
					col_end_gt0 += 1
			else:
				data_eq0[counter_eq0] = matrix[i][j]
				data_eq0[counter_eq0] = i
				counter_eq0 += 1
				col_end_eq0 += 1
		indptr_lt0[j+1] += col_end_lt0
		indptr_gt0[j+1] += col_end_gt0
		indptr_eq0[j+1] += col_end_eq0
		
cdef void compress_dbl_matview(double[:,::1] matrix, double** data, INT* indices, INT* indptr, int I, int J):
	cdef int i, j, row_end, counter, nnz
	indptr[0] = 0
	counter = 0
	for i in range(I):
		row_end = 0
		for j in range(J):
			if matrix[i,j] != 0:
				data[counter] = &matrix[i,j]
				indices[counter] = j
				counter += 1
				row_end += 1
		indptr[i+1] = indptr[i] + row_end

cdef void invDiag_dbl_mat(double** matrix, double* data, INT* indices, INT* indptr, int I):
	cdef int i
	indptr[0] = 0
	for i in range(I):
		row_end = 0
		data[i] = 1.0/matrix[i][i]
		indices[i] = i
		indptr[i+1] = indptr[i] + 1
		
cdef void diag_dbl_mat(double** matrix, double* data, INT* indices, INT* indptr, int I):
	cdef int i
	indptr[0] = 0
	for i in range(I):
		row_end = 0
		data[i] = matrix[i][i]
		indices[i] = i
		indptr[i+1] = indptr[i] + 1
		
cdef void compress_int_mat(INT** matrix, INT* data, INT* indices, INT* indptr, int I, int J):
	cdef int i, j, row_end, counter, nnz
	indptr[0] = 0
	counter = 0
	for i in range(I):
		row_end = 0
		for j in range(J):
			if matrix[i][j] != 0:
				data[counter] = matrix[i][j]
				indices[counter] = j
				counter += 1
				row_end += 1
		indptr[i+1] = indptr[i] + row_end
	
cdef void compress_dbl_vec(double* vector, double* data, INT* indices, INT* indptr, int J):
	# J is the length of the original vector.
	cdef int j, counter, nnz
	indptr[0] = 0
	counter = 0
	for j in range(J):
		if vector[j] != 0.0:
			data[counter] = vector[j]
			indices[counter] = j
			counter += 1
	indptr[1] = counter

cdef void compress_dbl_vec_for_mult(double* vector, double* data, INT* indices, INT* indptr, int J):
	# J is the length of the original vector.
	cdef int j, counter, nnz
	indptr[0] = 0
	counter = 0
	for j in range(J):
		if vector[j] != 1.0:
			data[counter] = vector[j]
			indices[counter] = j
			counter += 1
	indptr[1] = counter

cdef void compress_dbl_vec_lt0(double* vector, double* data, INT* indices, INT* indptr, int J):
	# J is the length of the original vector.
	cdef int j, counter, nnz
	indptr[0] = 0
	indptr[1] = 0
	counter = 0
	for j in range(J):
		if vector[j] < 0.0:
			data[counter] = vector[j]
			indices[counter] = j
			counter += 1
	indptr[1] = counter

cdef void compress_dbl_vec_gt0(double* vector, double* data, INT* indices, INT* indptr, int J):
	# J is the length of the original vector.
	cdef int j, counter, nnz
	indptr[0] = 0
	indptr[1] = 0
	counter = 0
	for j in range(J):
		if vector[j] > 0.0:
			data[counter] = vector[j]
			indices[counter] = j
			counter += 1
	indptr[1] = counter

cdef void compress_dbl_vec_lge0(double* vector, 
	#double* data_ne0, INT* indices_ne0, INT* indptr_ne0,
	double* data_lt0, INT* indices_lt0, INT* indptr_lt0,
	double* data_gt0, INT* indices_gt0, INT* indptr_gt0, 
	double* data_eq0, INT* indices_eq0, INT* indptr_eq0,
	int J):
	# J is the length of the original vector.
	cdef int j
	#cdef int counter_lt0, counter_gt0, counter_eq0, counter_ne0
	indptr_lt0[0] = 0
	indptr_gt0[0] = 0
	indptr_eq0[0] = 0
	indptr_lt0[1] = 0
	indptr_gt0[1] = 0
	indptr_eq0[1] = 0
	#indptr_ne0[0] = 0
# 	counter_lt0 = 0
# 	counter_gt0 = 0
# 	counter_eq0 = 0
	#counter_ne0 = 0
	for j in range(J):
		if vector[j] != 0.0:
# 			data_ne0[counter_ne0] = vector[j]
# 			indices_ne0[counter_ne0] = j
# 			indptr_ne0[1] += 1
# 			counter_ne0 += 1
			if vector[j] < 0.0:
				data_lt0[indptr_lt0[1]] = vector[j]
				indices_lt0[indptr_lt0[1]] = j
				indptr_lt0[1] += 1
				#counter_lt0 += 1
			else:
				data_gt0[indptr_gt0[1]] = vector[j]
				indices_gt0[indptr_gt0[1]] = j
				indptr_gt0[1] += 1
				#counter_gt0 += 1
		else:
			data_eq0[indptr_eq0[1]] = vector[j]
			indices_eq0[indptr_eq0[1]] = j
			indptr_eq0[1] += 1
			#counter_eq0 += 1

cdef void compress_dbl_vec_lge0_Pr0(double* vector, 
	#double* data_ne0, INT* indices_ne0, INT* indptr_ne0,
	double* data_lt0, INT* indices_lt0, INT* indptr_lt0,
	double* data_gt0, INT* indices_gt0, INT* indptr_gt0, 
	double* data_eq0, INT* indices_eq0, INT* indptr_eq0,
	double* vector_Pr, int K):
	# K is the length of the original vector.
	cdef int k
	cdef int counter_lt0, counter_gt0, counter_eq0
	indptr_lt0[0] = 0
	indptr_gt0[0] = 0
	indptr_eq0[0] = 0
	indptr_lt0[1] = 0
	indptr_gt0[1] = 0
	indptr_eq0[1] = 0
	#indptr_ne0[0] = 0
	counter_lt0 = 0
	counter_gt0 = 0
	counter_eq0 = 0
	#counter_ne0 = 0
	for k in range(K):
		if vector[k] != 0.0 and vector_Pr[k] != 0.0:
# 			data_ne0[counter_ne0] = vector[k]
# 			indices_ne0[counter_ne0] = k
# 			indptr_ne0[1] += 1
# 			counter_ne0 += 1
			if vector[k] < 0.0:
				data_lt0[counter_lt0] = vector[k]
				indices_lt0[counter_lt0] = k
				indptr_lt0[1] += 1
				counter_lt0 += 1
			else:
				data_gt0[counter_gt0] = vector[k]
				indices_gt0[counter_gt0] = k
				indptr_gt0[1] += 1
				counter_gt0 += 1
		else:
			data_eq0[counter_eq0] = vector[k]
			indices_eq0[counter_eq0] = k
			indptr_eq0[1] += 1
			counter_eq0 += 1
	#print "sp; indptr_lt0[1] =", indptr_lt0[1]
	
cdef void compress_dbl_vec_eq0(double* vector, 
	double* data_eq0, INT* indices_eq0, INT* indptr_eq0,
	int J):
	# J is the length of the original vector.
	cdef int j, counter_eq0,

	indptr_eq0[0] = 0
	indptr_eq0[1] = 0
	#indptr_ne0[0] = 0
	counter_eq0 = 0
	#counter_ne0 = 0
	for j in range(J):
		if vector[j] == 0.0:
			data_eq0[counter_eq0] = vector[j]
			indices_eq0[counter_eq0] = j
			indptr_eq0[1] += 1
			counter_eq0 += 1	

	
cdef void compress_dbl_vec_Pr(double* vector, double* data, INT* indices, INT* indptr, 
							int J, INT* P_indices, INT* P_indptr, 
							INT* P_zero_indices, INT* P_zero_indptr):
	# J is the length of the original vector.
	cdef int h, j, counter, nnz
	indptr[0] = 0
	indptr[1] = 0
	counter = 0
	for h in range(P_indptr[1]):
		j = P_indices[h]
		if vector[j] != 0.0:
			data[counter] = vector[j]
			indices[counter] = j
			counter += 1
	# Enforce agreement between source vector and its compressed form
	for h in range(P_zero_indptr[1]):
		vector[P_zero_indices[h]] = 0.0		
	indptr[1] = counter

cdef void transfer_zeros_dbl_vec(double* vector,
							INT* P_zero_indices, INT* P_zero_indptr):
	cdef unint h
	# Enforce agreement in zeros between source vector and its compressed form
	for h in range(P_zero_indptr[1]):
		vector[P_zero_indices[h]] = 0.0	
	
cdef void compress_int_vec(INT* vector, INT* data, INT* indices, INT* indptr, int J):
	cdef int j, row_end, counter, nnz
	row_end = 0
	indptr[0] = 0
	counter = 0
	for j in range(J):
		if vector[j] != 0:
			data[counter] = vector[j]
			indices[counter] = j
			counter += 1
			row_end += 1
	indptr[1] = row_end
	
cdef void decompress(double* data, INT* indices, INT* indptr, double** matrix, int I, int J):
	cdef int i, j, j_ptr, row_start, row_end
	cdef double j_datum
	for i in range(I):
		row_start = indptr[i]
		row_end = indptr[i+1]
		for j in range(J):
			matrix[i][j] = 0.0
		for j_ptr in range(row_start, row_end):
			j = indices[j_ptr]
			matrix[i][j] = data[j_ptr]
			
cdef void decompress_T(double* data, INT* indices, INT* indptr, double** matrix_T, int I, int J):
	#decompress sparse matrix as transposed
	cdef int i, j, j_ptr, row_start, row_end
	cdef double j_datum
	for i in range(I):
		col_start = indptr[i]
		col_end = indptr[i+1]
		for j in range(J):
			matrix_T[j][i] = 0.0
		for j_ptr in range(col_start, col_end):
			j = indices[j_ptr]
			matrix_T[j][i] = data[j_ptr]
			
cdef void decompress_vec(double* data, INT* indices, INT* indptr, double* vector, int K):
	#decompress compressed sparse vector
	cdef int k, k_ptr
	for k in range(K):
		vector[k] = 0.0
	for k_ptr in range(indptr[0], indptr[1]):
		vector[indices[k_ptr]] = data[k_ptr]

cdef void vector_zeros(double* vector, INT*	zero_indices, INT* indptr, int J):
	cdef int j, counter
	indptr[0] = 0
	indptr[1] = 0
	counter = 0
	for j in range(J):
		if vector[j] == 0.0:
			zero_indices[counter] = j
			counter += 1
	indptr[1] = counter

############ FLOAT DATATYPE ############

cdef void compress_flt_mat(FLOAT** matrix, FLOAT* data, INT* indices, INT* indptr, int I, int J):
	# Argument I = number of rows in the matrix to be compressed
	# Argument J = number of columns in the matrix to be compressed
	cdef int i, j, row_end, counter, nnz
	indptr[0] = 0
	counter = 0
	for i in range(I):
		row_end = 0
		indptr[i+1] = indptr[i] 
		for j in range(J):
			if matrix[i][j] != 0.0:
				data[counter] = matrix[i][j]
				indices[counter] = j
				counter += 1
				row_end += 1
		indptr[i+1] += row_end

cdef void compress_flt_vec(FLOAT* vector, FLOAT* data, INT* indices, INT* indptr, int J):
	# J is the length of the original vector.
	cdef int j, counter, nnz
	indptr[0] = 0
	counter = 0
	for j in range(J):
		if vector[j] != 0.0:
			data[counter] = vector[j]
			indices[counter] = j
			counter += 1
	indptr[1] = counter
