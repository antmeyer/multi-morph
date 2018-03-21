#cython: profile=True
#cython: boundscheck=False
#cython: wraparound=False
#cython: cdivision=True
import sys

cdef void prelims_slmqn(FLOAT* grad,
					FLOAT* grad_data, int* grad_indices, int* grad_indptr,
					FLOAT* x,
					FLOAT* diagP0, int* diagP0_indices, int* diagP0_indptr,
					int* diagP0_zero_indices, int* diagP0_zero_indptr,
					FLOAT* diagP1, int* diagP1_indices, int* diagP1_indptr,
					int* diagP1_zero_indices, int* diagP1_zero_indptr,
					int* diagP2_indices, int* diagP2_indptr,
					int* diagP3_indices, int* diagP3_indptr,
					FLOAT eps, FLOAT zero_eps, int J, int K, int N, FLOAT l, FLOAT u):
					
	cdef int n, n1, n2, i, h, pos, neg, zero
	cdef FLOAT m = 0.0
	cdef FLOAT m_eps = zero_eps
	cdef FLOAT gradFactor, l_plus_eps, u_minus_eps, m_plus_eps, m_minus_eps
	l_plus_eps = l+eps
	u_minus_eps = u-eps
	#cdef FLOAT span = fabs(u)+fabs(l)
	cdef FLOAT boundSum = u+l
	for n in range(N):
		diagP0[n] = 0.0
		diagP1[n] = 0.0
# 		diagP2[n] = 0.0
# 		diagP3[n] = 0.0
	diagP0_indptr[1] = 0
	diagP1_indptr[1] = 0
	diagP2_indptr[1] = 0
	diagP3_indptr[1] = 0

	# populate V, U1, U2, and U3
	for n in range(N):
		gradFactor = (boundSum - 2.0*x[n]) * grad[n]
		# in the case of descent to toward minimum, is the grad positive or negative?
		# --> We want gTd to be negative, and d = -grad initially. That is, d and grad
		# point in opposing directions. When this is no longer true, the model
		# is moving away from its target.
		# However, d is not always going to be negative; its sign just needs to oppose
		# the gradient's sign.
		if l_plus_eps < x[n] < u_minus_eps:
			diagP0_indices[diagP0_indptr[1]] = n
			#print "(P0), ",
			diagP0_indptr[1] += 1
		
		elif (x[n] == l or x[n] == u) and gradFactor >= 0.0:
			diagP1_indices[diagP1_indptr[1]] = n
			#print "(P1), ",
			diagP1_indptr[1] += 1
			
		elif ((l <= x[n] <= l_plus_eps) or (u_minus_eps <= x[n] <= u)) and gradFactor < 0.0:
			diagP2_indices[diagP2_indptr[1]] = n
			diagP2_indptr[1] += 1
			#print "(P2), ",
		elif ((l < x[n] <= l_plus_eps) or (u_minus_eps <= x[n] < u)) and gradFactor >= 0.0:
			diagP3_indices[diagP3_indptr[1]] = n
			#print "(P3), ",
			diagP3_indptr[1] += 1

	for i in range(diagP0_indptr[1]):
		diagP0[diagP0_indices[i]] = 1.0

	for i in range(diagP1_indptr[1]):
		diagP1[diagP1_indices[i]] = 1.0

	sp.vector_zeros(diagP0, diagP0_zero_indices, diagP0_zero_indptr, N)
	sp.vector_zeros(diagP1, diagP1_zero_indices, diagP1_zero_indptr, N)


cdef void direction_slmqn(FLOAT* d, FLOAT* d_data, int* d_indices, int* d_indptr,
					FLOAT* x,
					FLOAT* grad, FLOAT* grad_data, int* grad_indices, int* grad_indptr,
					FLOAT** s_vecs, 
					FLOAT** s_vecs_data, int** s_vecs_indices, int** s_vecs_indptr, 
					FLOAT** y_vecs,
					FLOAT** y_vecs_data, int** y_vecs_indices, int** y_vecs_indptr,
					FLOAT* diagP0, int* diagP0_indices, int* diagP0_indptr,
					int* diagP0_zero_indices, int* diagP0_zero_indptr,
					FLOAT* diagP1, int* diagP1_indices, int* diagP1_indptr,
					int* diagP1_zero_indices, int* diagP1_zero_indptr,
					int* diagP2_indices, int* diagP2_indptr,
					int* diagP3_indices, int* diagP3_indptr,
					FLOAT* rho, FLOAT gamma, int Z, int cur_iter, 
					FLOAT eps, FLOAT zero_eps, int N, FLOAT l, FLOAT u, FLOAT sign):
					
	cdef int i,k,n,n1,n2,h
	cdef int P0_nnz = diagP0_indptr[1]
	cdef int s_nnz, y_nnz
	cdef FLOAT beta, denom, sigma

	cdef FLOAT * alpha = <FLOAT*>malloc(cur_iter*sizeof(FLOAT))
	for n in range(cur_iter):
		alpha[n] = 0.0
	cdef FLOAT * q = <FLOAT*>malloc(N*sizeof(FLOAT))
	for n in range(N):
		q[n] = 0.0
	for n in range(N):
		d[n] = 0.0
	if P0_nnz > 0:
		for n in range(diagP0_indptr[1]):
			q[diagP0_indices[n]] = -grad[diagP0_indices[n]]

		for i from cur_iter > i >= max(0, cur_iter-Z):
			s_nnz = s_vecs_indptr[i][1]
			y_nnz = y_vecs_indptr[i][1]

			sigma = 0.0
			for n in range(s_nnz):
				sigma += s_vecs_data[i][n] * q[s_vecs_indices[i][n]]
			alpha[i] = rho[i] * sigma

			for n in range(y_nnz):
				q[y_vecs_indices[i][n]] -= alpha[i] * y_vecs_data[i][n]

		for n in range(P0_nnz):
			q[diagP0_indices[n]] *= gamma
		for n in range(diagP0_zero_indptr[1]):
			q[diagP0_zero_indices[n]] = 0.0
	
		for i from max(0, cur_iter-Z) <= i < cur_iter:
			y_nnz = y_vecs_indptr[i][1]
			s_nnz = s_vecs_indptr[i][1]

			sigma = 0.0
			for n in range(y_nnz):
				sigma += y_vecs_data[i][n] * q[y_vecs_indices[i][n]]
			beta = rho[i] * sigma
			for n in range(s_nnz):
				q[s_vecs_indices[i][n]] += s_vecs_data[i][n] * (alpha[i] - beta)

	# 	for n in range(N):
	# 		d[n] = q[n]
		for n in range(diagP0_indptr[1]):
			if x[diagP0_indices[n]] + q[diagP0_indices[n]] > u:
				d[diagP0_indices[n]] = u - x[diagP0_indices[n]]
			elif x[diagP0_indices[n]] + q[diagP0_indices[n]] < l:
				d[diagP0_indices[n]] = l - x[diagP0_indices[n]]
			else:
				d[diagP0_indices[n]] = q[diagP0_indices[n]]
		#d[diagP0_indices[n]] = q[diagP0_indices[n]]
		#sp.compress_flt_vec(d, d_data, d_indices, d_indptr, N)
	
	#P1
	for n in range(diagP1_indptr[1]):
		d[diagP1_indices[n]] = 0.0
		
	#P2
	for h in range(diagP2_indptr[1]):
		n = diagP2_indices[h]
		if (x[n] - grad[n] <= l):
			d[n] = l - x[n]
		elif (x[n] - grad[n] >= u):
			d[n] = u - x[n]
		else:
			d[n] = -grad[n]
	#P3
	for h in range(diagP3_indptr[1]):
		n = diagP3_indices[h]
		if (l < x[n] <= l+eps) and (x[n] - grad[n] <= l):
			#d[n] = -(x[n]/grad[n]) * grad[n]
			#d[n] = (x[n] - l)/grad[n] * (-grad[n])
			d[n] = l - x[n]
		elif (u-eps <= x[n] < u) and (x[n] - grad[n] >= u):
			d[n] = u - x[n] 
		else:
			if x[n] - grad[n] <= l:
				d[n] = l - x[n]
			elif x[n] - grad[n] >= u:
				d[n] = u - x[n]
			else:
				d[n] = -grad[n]
	
	sp.compress_flt_vec(d, d_data, d_indices, d_indptr, N)
	dealloc_vector(alpha)
	dealloc_vector(q)

cdef void prelims_slmqn_C(FLOAT* grad,
					FLOAT* grad_data, int* grad_indices, int* grad_indptr,
					FLOAT* x,
					FLOAT* diagP0, int* diagP0_indices, int* diagP0_indptr,
					int* diagP0_zero_indices, int* diagP0_zero_indptr,
					FLOAT* diagP1, int* diagP1_indices, int* diagP1_indptr,
					int* diagP1_zero_indices, int* diagP1_zero_indptr,
					int* diagP2_indices, int* diagP2_indptr,
					int* diagP3_indices, int* diagP3_indptr,
					int* diagP4_indices, int* diagP4_indptr,
					int* diagP5_indices, int* diagP5_indptr, #bint wwb,
					FLOAT eps, FLOAT zero_eps, int J, int K, int N, FLOAT l, FLOAT u):
					
	cdef int n, n1, n2, i, h, pos, neg, zero
	cdef FLOAT m = 0.0
	cdef FLOAT m_eps = zero_eps
	cdef FLOAT gradFactor, l_plus_eps, u_minus_eps, m_plus_eps, m_minus_eps
	l_plus_eps = l+eps
	u_minus_eps = u-eps
	m_plus_eps = m+m_eps
	m_minus_eps = m-m_eps
	cdef FLOAT boundSum = u+l
	for n in range(N):
		diagP0[n] = 0.0
		diagP1[n] = 0.0
	diagP0_indptr[1] = 0
	#diagP0_zeros_indptr[1] = 0
	diagP1_indptr[1] = 0
	#diagP1_zeros_indptr[1] = 0
	diagP2_indptr[1] = 0
	diagP3_indptr[1] = 0
	diagP4_indptr[1] = 0
	diagP5_indptr[1] = 0

	# populate V, U1, U2, and U3
	for n in range(N):
		gradFactor = (boundSum - 2.0*x[n]) * grad[n]
		# If x[n] = 1.0, this is true if grad[n] is negative.
		# if x[n] = 0.0, this true if grad is positive
		# The purpose of the following is to partition the "distance" vector
		# into distict "zones". These are P0, P1, and so on. 
		# The distance vector is added to data vector during the update stage.
		# But we may want to do different things with different indices, hence
		# the partitioning.
		# The indexing scheme of D(istance) should ultimately conform to that of 
		# x (the data vector) and the gradient. That is, 
		#              n = row_idx * num_columns + col_idx
		if (l_plus_eps < x[n] < m_minus_eps) or (m_plus_eps < x[n] < u_minus_eps):
			diagP0_indices[diagP0_indptr[1]] = n
			diagP0_indptr[1] += 1	
			#P0_counts[counter] += 1
		elif (x[n]==l or x[n]==u) and gradFactor >= 0.0:
			diagP1_indices[diagP1_indptr[1]] = n
			diagP1_indptr[1] += 1
			#P1_counts[counter] += 1

		elif ((l <= x[n] <= l_plus_eps) or (u_minus_eps <= x[n] <= u)) and gradFactor < 0.0:
			diagP2_indices[diagP2_indptr[1]] = n
			diagP2_indptr[1] += 1
			#P2_counts[counter] += 1
		elif ((l < x[n] <= l_plus_eps) or (u_minus_eps <= x[n] < u)) and gradFactor >= 0.0:
			diagP3_indices[diagP3_indptr[1]] = n
			diagP3_indptr[1] += 1
			#P3_counts[counter] += 1
		# elif (m_minus_eps <= x[n] <= m_plus_eps) and gradFactor >= 0.0 and wwb == 1:
		# 	# we don't need to truncate in this case, 
		# 	# since 0 is not an absolute boundary.
		# 	# Even so...
		# 	diagP4_indices[diagP4_indptr[1]] = n
		# 	diagP4_indptr[1] += 1
		# 	#P4_counts[counter] += 1
		# elif (m_minus_eps <= x[n] <= m_plus_eps) and gradFactor < 0.0 and wwb == 1:
		# 	diagP5_indices[diagP5_indptr[1]] = n
		# 	diagP5_indptr[1] += 1
			#P5_counts[counter] += 1

# 	diagP0_indptr[1] = len_P0
# 	diagP1_indptr[1] = len_P1
# 	diagP2_indptr[1] = len_P2
# 	diagP3_indptr[1] = len_P3
# 	diagP4_indptr[1] = len_P3
# 	diagP5_indptr[1] = len_P3

	for i in range(diagP0_indptr[1]):
		diagP0[diagP0_indices[i]] = 1.0

	for i in range(diagP1_indptr[1]):
		diagP1[diagP1_indices[i]] = 1.0

	sp.vector_zeros(diagP0, diagP0_zero_indices, diagP0_zero_indptr, N)
	sp.vector_zeros(diagP1, diagP1_zero_indices, diagP1_zero_indptr, N)

# 	dealloc_vec_int(P0_counts)
# 	dealloc_vec_int(P1_counts)
# 	dealloc_vec_int(P2_counts)
# 	dealloc_vec_int(P3_counts)
# 	dealloc_vec_int(positives)
# 	dealloc_vec_int(negatives)
# 	dealloc_vec_int(zeros)
	
	
cdef void direction_slmqn_C(FLOAT* d, FLOAT* d_data, int* d_indices, int* d_indptr,
					FLOAT* x,
					FLOAT* grad, FLOAT* grad_data, int* grad_indices, int* grad_indptr,
					FLOAT** s_vecs, 
					FLOAT** s_vecs_data, int** s_vecs_indices, int** s_vecs_indptr, 
					FLOAT** y_vecs,
					FLOAT** y_vecs_data, int** y_vecs_indices, int** y_vecs_indptr,
					FLOAT* diagP0, int* diagP0_indices, int* diagP0_indptr,
					int* diagP0_zero_indices, int* diagP0_zero_indptr,
					FLOAT* diagP1, int* diagP1_indices, int* diagP1_indptr,
					int* diagP1_zero_indices, int* diagP1_zero_indptr,
					int* diagP2_indices, int* diagP2_indptr,
					int* diagP3_indices, int* diagP3_indptr,
					int* diagP4_indices, int* diagP4_indptr,
					int* diagP5_indices, int* diagP5_indptr,
					FLOAT * rho, FLOAT gamma, int Z, int cur_iter, #bint wwb,
					FLOAT eps, FLOAT zero_eps, int N, FLOAT l, FLOAT u, FLOAT sign):
	cdef int i,k,n,n1,n2,h
	cdef int P0_nnz = diagP0_indptr[1]
	cdef int s_nnz, y_nnz
	cdef FLOAT beta, denom, sigma
	cdef FLOAT m = 0.0

	cdef FLOAT * alpha = <FLOAT*>malloc(cur_iter*sizeof(FLOAT))
	for n in range(cur_iter):
		alpha[n] = 0.0
	cdef FLOAT * q = <FLOAT*>malloc(N*sizeof(FLOAT))
	for n in range(N):
		q[n] = 0.0
	for n in range(N):
		d[n] = 0.0
	if P0_nnz > 0:
		for n in range(diagP0_indptr[1]):
			q[diagP0_indices[n]] = -grad[diagP0_indices[n]]

		for i from cur_iter > i >= max(0, cur_iter-Z):
			s_nnz = s_vecs_indptr[i][1]
			y_nnz = y_vecs_indptr[i][1]

			for n in range(s_nnz):
				sigma += s_vecs_data[i][n] * q[s_vecs_indices[i][n]]
			alpha[i] = rho[i] * sigma

			for n in range(y_nnz):
				q[y_vecs_indices[i][n]] -= alpha[i] * y_vecs_data[i][n]

		for n in range(P0_nnz):
			q[diagP0_indices[n]] *= gamma
		for n in range(diagP0_zero_indptr[1]):
			q[diagP0_zero_indices[n]] = 0.0
	# 	for n in range(N):
	# 		q[n] *= gamma
	
		for i from max(0, cur_iter-Z) <= i < cur_iter:
			y_nnz = y_vecs_indptr[i][1]
			s_nnz = s_vecs_indptr[i][1]

			for n in range(y_nnz):
				sigma += y_vecs_data[i][n] * q[y_vecs_indices[i][n]]
			beta = rho[i] * sigma
			##print "SD ;", "beta =", beta, "rho[", i, "] =", rho[i]
			for n in range(s_nnz):
				q[s_vecs_indices[i][n]] += s_vecs_data[i][n] * (alpha[i] - beta)

	# 	for n in range(N):
	# 		d[n] = q[n]
		for n in range(diagP0_indptr[1]):
			if x[diagP0_indices[n]] + q[diagP0_indices[n]] > u:
				d[diagP0_indices[n]] = u - x[diagP0_indices[n]]
			elif x[diagP0_indices[n]] + q[diagP0_indices[n]] < l:
				d[diagP0_indices[n]] = l - x[diagP0_indices[n]]
			else:
				d[diagP0_indices[n]] = q[diagP0_indices[n]]
	
	#P1
	for n in range(diagP1_indptr[1]):
		d[diagP1_indices[n]] = 0.0
		
	#P2
	for h in range(diagP2_indptr[1]):
		n = diagP2_indices[h]
		if (x[n] - grad[n] <= l):
			d[n] = l - x[n]
		elif (x[n] - grad[n] >= u):
			d[n] = u - x[n]
		else:
			d[n] = -grad[n]
	
	#P3
	for h in range(diagP3_indptr[1]):
		n = diagP3_indices[h]
		if (l < x[n] <= l+eps) and (x[n] - grad[n] <= l):
			d[n] = l - x[n]
		elif (u-eps <= x[n] < u) and (x[n] - grad[n] >= u):
			d[n] = u - x[n] 
		else:
			if x[n] - grad[n] <= l:
				d[n] = l - x[n]
			elif x[n] - grad[n] >= u:
				d[n] = u - x[n]
			else:
				d[n] = -grad[n]
# 				if (l < x[n] <= l+eps):
# 					d[n] = grad[n]
# 				else:
# 					d[n] = -grad[n]
	#P4
	# if wwb == 1:
	# 	for h in range(diagP4_indptr[1]):
	# 		n = diagP4_indices[h]
	# 		print "** SD C", ";", "*** P4 ***", "; gF =", "{:.7f}".format(-2.0*x[n]*grad[n]),  "; C[" ,n, "] =", "{:.7f}".format(x[n]), "; -grad =", "{:.7f}".format(-grad[n]),
	# 		if x[n] < m:
	# 			if x[n] - grad[n] < l:
	# 				print "; case 1",
	# 				d[n] = l - x[n]
	# 			else:
	# 				print "; case 1.1",
	# 				d[n] = x[n] - zero_eps
	# 		elif x[n] > m:
	# 			if x[n] - grad[n] > u:
	# 				print "; case 2",
	# 				d[n] = u - x[n]
	# 			else:
	# 				print "; case 2.1",
	# 				d[n] = x[n] + zero_eps
	# 		else:
	# 			d[n] = x[n] + zero_eps
	# # 		if x[n] < m:
	# # 			d[n] = grad[n]
	# # 		if x[n] > m:
	# # 			d[n] = -grad[n]
	# 		print "; d[", n, "] =", "{:.7f}".format(d[n])
	
	# 	#P5
	# 	for h in range(diagP5_indptr[1]):
	# 		#both grad and x have the same sign; 
	# 		# so d[n] = -x[n] gives d[n] the same sign as d[n] = -grad 
	# 		n = diagP5_indices[h]
	# 		print "** SD C", ";", "*** P5 ***", "; gF =", "{:.7f}".format(-2.0*x[n]*grad[n]), "; C[" ,n, "] =", "{:.7f}".format(x[n]), "; -grad =", "{:.7f}".format(-grad[n]),
	# 		if x[n] < m:
	# 			#Since x is less than 0, we want to give a little push 
	# 			# to get it safely above 0, hence the "1.1*zero_eps".
	# 			# Both -(x[n]) and zero_eps are positive.
	# 			#d[n] = -x[n] + min(u, 2.0*x[n]*grad[n])
	# 			#d[n] = -2.0*x[n] + 2.0*zero_eps
	# 			#d[n] = -(x[n]/fabs(x[n])) * grad[n]
	# 			d[n] = -x[n] + u
	# 			#d[n] = -x[n] + 10.0*zero_eps
	# 			#d[n] = -2.0*x[n] + zero_eps
	# 			#d[n] = -2.0*x[n] + zero_eps
	# 			#d[n] = -x[n] + zero_eps + 0.1
	# 			#if d[n] > -x[n] + u:
	# 				#d[n] = -x[n] + u
	# 			#d[n] = -x[n] + 0.1
	# 		elif x[n] > m:
	# 			#Since x > 0, -(x[n]) is negative. We make it more negative by
	# 			#subtractive 1.1*zero_eps
	# 			# adding -(x[n]) will place x[n] at 0. Then subtracting 1.1*zero_eps
	# 			# will bring it below the epsilon boundary.
	# 			#d[n] = -2.0*x[n] - 2.0*zero_eps
	# 			#d[n] = -(x[n]/fabs(x[n])) * grad[n]
	# 			#d[n] = -x[n] + max(l, -2.0*x[n]*grad[n])
	# 			d[n] = x[n] - l
	# 			#d[n] = -2.0*x[n] - zero_eps
	# 			#d[n] = -x[n] - zero_eps - 0.1
	# 			#if d[n] < -x[n] + l:
	# 				#d[n] = -x[n] + l
	# 			#d[n] = -x[n] - 0.5*zero_eps
	# 		else:
	# 			d[n] = -grad[n]
	# 			#d[n] = 2.0*zero_eps
	# 		print "; d[", n, "] =", "{:.7f}".format(d[n])	
	sp.compress_flt_vec(d, d_data, d_indices, d_indptr, N)
	dealloc_vector(alpha)
	dealloc_vector(q)
	
# cdef int direction_slm_bfgs(FLOAT* d, FLOAT* d_data, int* d_indices, int* d_indptr,
# 					FLOAT* x,
# 					FLOAT* grad, FLOAT* grad_data, int* grad_indices, int* grad_indptr,
# 					FLOAT** H, FLOAT* H_data, int* H_indices, int* H_indptr, 
# 					FLOAT* diagH,
# 					FLOAT* diagP0, int* diagP0_indices, int* diagP0_indptr,
# 					int* diagP0_zero_indices, int* diagP0_zero_indptr,
# 					int* diagP2_indices, int* diagP2_indptr,
# 					int* diagP3_indices, int* diagP3_indptr, 
# 					FLOAT eps, int N, FLOAT sign):
# 	##print "SD_dir", 0
# 	#cdef FLOAT eps = 0.0001
# 	cdef FLOAT u = 1.0
# 	cdef FLOAT l = 0.0
# 	cdef int i,k,n,n1,n2,h
# 	cdef int P0_nnz = diagP0_indptr[1]
# 	cdef int s_nnz, y_nnz
# 	cdef FLOAT beta, denom, sigma
# 	cdef FLOAT* grad_P0 = <FLOAT *>malloc(N * sizeof(FLOAT))
# 	cdef FLOAT* grad_P0_data = <FLOAT *>malloc(N * sizeof(FLOAT))
# # 	for n in range(N):
# # 		grad_P0_data[n] = 0.0
# 	cdef int* grad_P0_indices = <int *>malloc(N * sizeof(FLOAT))
# # 	for n in range(N):
# # 		grad_P0_indices[n] = 0
# 	cdef int* grad_P0_indptr = <int *>malloc(2 * sizeof(FLOAT))
# 	grad_P0_indptr[0] = 0
# 	grad_P0_indptr[1] = 0
# 	for n in range(N):
# 		d[n] = 0.0
# 		grad_P0[n] = -grad[n]
# 		
# 	#P0
# # 	for h in range(diagP0_indptr[1]):
# # 		#n = diagP2_indices[h]
# # 		d[diagP0_indices[h]] = diagH[diagP0_indices[h]] * sign*grad[diagP0_indices[h]]
# 	#print "***&&&*** PO_nnz =", diagP0_indptr[1]
# 	sp.compress_flt_vec_Pr(grad_P0, grad_P0_data, grad_P0_indices, grad_P0_indptr, N,
# 			diagP0_indices, diagP0_indptr, diagP0_zero_indices, diagP0_zero_indptr)
# 	if diagP0_indptr[1] > 0:
# 		matmath_sparse.mul_2d_1d(H_data, H_indices, H_indptr, N+1, 
# 							grad_P0_data, grad_P0_indices, grad_P0_indptr, d)
# # 	else:
# # 		#for h in range(diagP0_indptr[1]):
# # 		#n = diagP2_indices[h]
# # 	for h in range(diagP0_indptr[1]):
# # 		d[diagP0_indices[h]] = -d[diagP0_indices[h]]
# # 	for h in range(diagP0_zero_indptr[1]):
# # 		d[diagP0_zero_indices[h]] = 0.0
# 	#P2
# 	for h in range(diagP2_indptr[1]):
# 		#n = diagP2_indices[h]
# 		d[diagP2_indices[h]] = -grad[diagP2_indices[h]]
# 	#P3
# 	
# # 	for h in range(diagP3_indptr[1]):
# # 		n = diagP3_indices[h]
# # 		if (l < x[n] <= l+eps) and (x[n] - grad[n] <= l):
# # 			#d[n] = -(x[n]/grad[n]) * grad[n]
# # 			d[n] = sign*x[n]
# # 		elif (u-eps <= x[n] < u) and (x[n] - grad[n] >= u):
# # 			#d[n] = -((x[n] - 1.0) / grad[n]) * grad[n]
# # 			d[n] = sign*x[n] + 1.0
# # 		else:
# # 			d[n] = sign*grad[n]
# 	for h in range(diagP3_indptr[1]):
# 		n = diagP3_indices[h]
# 		if (l < x[n] <= l+eps) and (x[n] - grad[n] <= l):
# 			#d[n] = -(x[n]/grad[n]) * grad[n]
# 			#d[n] = (x[n] - l)/grad[n] * (-grad[n])
# 			d[n] = -(x[n] - l)
# 			#d[n] = sign*x[n]
# 		elif (u-eps <= x[n] < u) and (x[n] - grad[n] >= u):
# 			d[n] = -(x[n] - u) 
# 			#d[n] = sign*x[n] + 1.0
# 		else:
# 			d[n] = -grad[n]
# # 	for n in range(N):
# # 		#n = diagP2_indices[h]
# # 		d[n] = -d[n]
# 	sp.compress_flt_vec(d, d_data, d_indices, d_indptr, N)
# 	dealloc_vector(grad_P0)
# 	dealloc_vector(grad_P0_data)
# 	dealloc_vec_int(grad_P0_indices)
# 	dealloc_vec_int(grad_P0_indptr)
