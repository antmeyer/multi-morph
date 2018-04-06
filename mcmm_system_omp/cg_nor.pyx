#cython: boundscheck=False
#cython: wraparound=False
#cython: cdivision=True
#cython: profile=True
# encoding: utf-8
# filename: cg.pyx
import sys

cdef FLOAT isNaN(FLOAT x):
	return x != x
	
cdef FLOAT cg_M_nor(FLOAT* m, FLOAT* m_old,
			FLOAT* m_test,
			FLOAT** C, FLOAT* C_data, int* C_indices, int* C_indptr,
			#FLOAT* prod,
			FLOAT* x, FLOAT* r,
			FLOAT* grad, 
			FLOAT* grad_data, int* grad_indices, int* grad_indptr,
			FLOAT* grad_old,
			FLOAT* z, FLOAT* z_data, int* z_indices, int* z_indptr,
			FLOAT* z_old,
			FLOAT* s_vec, FLOAT* y_vec, FLOAT* Hy,
			FLOAT* d, FLOAT* d_data, int* d_indices, int* d_indptr,
			FLOAT* diagPre, FLOAT gTd,
			FLOAT* gamma, FLOAT error, 
			int itr_max, int* cg_itrs, int* nr_itrs, 
			int K, int J, FLOAT normConstant, 
			int precondition,
			FLOAT* diagP0, int* diagP0_indices, int* diagP0_indptr,
			int* diagP0_zero_indices, int* diagP0_zero_indptr,
			FLOAT* diagP1, int* diagP1_indices, int* diagP1_indptr,
			int* diagP1_zero_indices, int* diagP1_zero_indptr,
			int* diagP2_indices, int* diagP2_indptr,
			int* diagP3_indices, int* diagP3_indptr,
			FLOAT eps, FLOAT* distance, int* num_steps, FLOAT l, FLOAT u):
	eps = 0.00000001
	cdef bint terminate = 0
	cdef FLOAT eps_cg_sq = 0.01*0.01
	cdef FLOAT eps_nr_sq = 0.01*0.01
	cdef bint cg_init = 1
	cdef FLOAT error0 = error
	cdef FLOAT prev_err = 0.0
	cdef FLOAT H0_sum, H_sum
	cdef bint init = 1
	cdef bint nr_break = 0
	cdef INT nr_i, cg_i, cg_k, cg_n
	cg_n = 10 
	cg_k = 0 
	cdef unint i,j,k,h,n
	cdef INT nr_max = 10
	cdef INT cg_max = itr_max
	cdef FLOAT cg_alpha = 0.0
	cdef FLOAT alpha1 = 1.0
	cdef FLOAT alpha_max = 1000000000.0
	cdef FLOAT c1 = 0.0001
	cdef FLOAT c2 = 0.1
	cdef FLOAT zero_eps = 0.001
	cdef int a_iter = 0
	cdef int* a_iter_ptr = &a_iter
	cdef FLOAT delta_0, delta_new, delta_d, s_norm, y_norm, grad_norm
	cdef FLOAT gTd_old = 0.0
	cdef FLOAT dTy = 0.0
	cdef FLOAT gTy = 0.0 
	cdef FLOAT sTs = 0.0
	cdef FLOAT sTy = 0.0
	cdef FLOAT yTy = 0.0
	cdef FLOAT cg_beta, beta_HS, beta_PRP, beta_reg, beta_DY, beta_DYCD, 
	cdef FLOAT prev_err_cg, prev_err_nr, nr_criterion_old, nr_criterion_new, cg_criterion
	cdef FLOAT numer = 1.0
	cdef FLOAT denom = 1.0
	cdef FLOAT rate = 1.0
	cdef FLOAT g_diff_sum = 0.0
	prev_err_cg = -0.1
	cdef FLOAT old_m
	cg_beta = 0.0

	if precondition > 0:
		#as long as precondition is not 1 or 2, the gradient is 
		#multipilied by a preconditioner that is supplied to the 
		#program as a parameter. We use the diagonal of the 
		#preconditioner.
		for k in range(K):
			z[k] = grad[k] * diagPre[k]
	else:
		for k in range(K):
			z[k] = grad[k]
	sp.compress_flt_vec(grad, grad_data, grad_indices, grad_indptr, K)
	sp.compress_flt_vec(z, z_data, z_indices, z_indptr, K)
	sp.compress_flt_vec(grad, grad_data, grad_indices, grad_indptr, K)
	sp.compress_flt_vec(z, z_data, z_indices, z_indptr, K)
	
	search_direction.prelims_slmqn(grad,
					grad_data, grad_indices, grad_indptr,
					m,
					diagP0, diagP0_indices, diagP0_indptr,
					diagP0_zero_indices, diagP0_zero_indptr,
					diagP1, diagP1_indices, diagP1_indptr,
					diagP1_zero_indices, diagP1_zero_indptr,
					diagP2_indices, diagP2_indptr,
					diagP3_indices, diagP3_indptr,
					eps, zero_eps, J, K, K, l, u)
	#P0
	for h in range(diagP0_indptr[1]):
		d[diagP0_indices[h]] = -z[diagP0_indices[h]]

	#P1
	for h in range(diagP1_indptr[1]):
		d[diagP1_indices[h]] = 0.0

	#P2
	for h in range(diagP2_indptr[1]):
		#n = diagP2_indices[h]
		d[diagP2_indices[h]] = -z[diagP2_indices[h]]

	#P3
	for h in range(diagP3_indptr[1]):
		n = diagP3_indices[h]
		if (l < m[n] <= l+eps) and (m[n] - z[n] <= l):
			#d[n] = -(m[n]/grad[n]) * grad[n]
			d[n] = -m[n]
		elif (u-eps <= m[n] < u) and (m[n] - z[n] >= u):
			#d[n] = -((m[n] - 1.0) / grad[n]) * grad[n]
			d[n] = -m[n] + 1.0
		else:
			d[n] = -z[n]

	cg_i = 0

	sp.compress_flt_vec(d, d_data, d_indices, d_indptr, K)
	
	gTd = 0.0
	for h in range(d_indptr[1]):
		gTd = gTd + grad[d_indices[h]] * d_data[h] #* diagP0[d_indices[h]]
	#sp.compress_flt_vec(m, m_data, m_indices, m_indptr, K)

	delta_new = 0.0
	for h in range(grad_indptr[1]):
		delta_new = delta_new + (grad_data[h] * z[grad_indices[h]]) * diagP0[grad_indices[h]]
	grad_norm = sqrt(delta_new)
	delta_0 = delta_new 
	
	cg_i = 0
	while cg_i <= cg_max:
		cg_k = cg_k + 1
		cg_i = cg_i + 1
		prev_err = prev_err_cg
		prev_err_cg = error
		delta_d = 0.0
		for h in range(d_indptr[1]):
			delta_d += d_data[h] * d_data[h]

		gTd_old = gTd
		alpha1 = 1.0

		cg_alpha = linesearch.armijo2_M_nor(alpha1, alpha_max, 
					c1, error, gTd,
					m, m_test,
					C, C_data, C_indices, C_indptr, 
					x, r,
					d, d_data, d_indices, d_indptr,
					normConstant, K, J, a_iter_ptr,
					l, u)
		for k in range(K):
			m_old[k] = m[k]
		for h in range(d_indptr[1]):
			old_m = m[d_indices[h]]
			m[d_indices[h]] = m[d_indices[h]] + cg_alpha * d_data[h]
			if m[d_indices[h]] > u:
				m[d_indices[h]] = u
			elif m[d_indices[h]] < l:
				m[d_indices[h]] = l
			distance[0] = distance[0] + fabs(m[d_indices[h]] - old_m)
			num_steps[0] = num_steps[0] + 1
		for k in range(K):
			s_vec[k] = m[k] - m_old[k]	
		prev_err_nr = error
		for k in range(K):
			grad_old[k] = grad[k]
		prev_err_cg = error
		# error = predict_nor.r_e_and_grad_m_2(grad, m, 
		# 		C, C_data, C_indices, C_indptr, 
		# 		x, r, error, J, K, normConstant, eta)
		error = predict.get_r_e_and_grad_m(grad, m, 
				C_data, C_indices, C_indptr, 
				x, r, J, K, normConstant)	
		for k in range(K):
			s_vec[k] = m[k] - m_old[k]
			y_vec[k] = grad[k] - grad_old[k]	
		
		if precondition > 0:
			for k in range(K):
				Hy[k] = diagPre[k] * y_vec[k]
		# for k in range(K):
		# 	yTy += y_vec[k]*y_vec[k]
		# if yTy <= 0.0000000001: 
		# 	break
		delta_old = delta_new
		delta_new = 0.0
		for h in range(diagP0_indptr[1]):
			k = diagP0_indices[h]
			delta_new += grad[k] * z[k]
		grad_norm = sqrt(delta_new)
		if precondition == 2:
			#if precondition = 2, the preconditioner is updated with each iteration.
			#if precondition = 1, it is kept fixed.
			sTy = 0.0
			for h in range(diagP0_indptr[1]):
				sTy += s_vec[diagP0_indices[h]] * y_vec[diagP0_indices[h]]
			if sTy == 0.0:
				break
			else:
				predict.get_inv_diag_bfgs(diagPre, s_vec, y_vec, 
							Hy, sTy, K, diagP0)
				#cdef void get_inv_diag_bfgs(FLOAT* diagH, FLOAT* s, FLOAT* y, FLOAT* Hy, FLOAT sTy, int N, FLOAT* p)
		if precondition > 0:
			#the preconditioner is applied as long as precondition isn't 0.
			for k in range(K):
				z[k] = grad[k] * diagPre[k]
			gTy = 0.0
			for h in range(diagP0_indptr[1]):
				gTy += z[diagP0_indices[h]] * Hy[diagP0_indices[h]]				
		else:
			for k in range(K):
				z[k] = grad[k]
			gTy = 0.0
			for h in range(diagP0_indptr[1]):
				gTy += z[diagP0_indices[h]] * y_vec[diagP0_indices[h]]
		
		sp.compress_flt_vec(grad, grad_data, grad_indices, grad_indptr, K)
		sp.compress_flt_vec(z, z_data, z_indices, z_indptr, K)
		
		if delta_old == 0.0:
			break
		else:
			beta_PRP = gTy / delta_old
		cg_beta = max(0.0, beta_PRP)	
		if isNaN(cg_beta):
			print "\n**************** NaN cg_beta, M ****************\n"
			break
		search_direction.prelims_slmqn(grad,
							grad_data, grad_indices, grad_indptr,
							m, diagP0, diagP0_indices, diagP0_indptr,
							diagP0_zero_indices, diagP0_zero_indptr,
							diagP1, diagP1_indices, diagP1_indptr,
							diagP1_zero_indices, diagP1_zero_indptr,
							diagP2_indices, diagP2_indptr,
							diagP3_indices, diagP3_indptr,
							eps, zero_eps, J, K, K, l, u)
		#P0
		for h in range(diagP0_indptr[1]):
			k = diagP0_indices[h]
			d[k] = -z[k] + (cg_beta * d[k])
		#P1
		for h in range(diagP1_indptr[1]):
			d[diagP1_indices[h]] = 0.0

		#P2
		for h in range(diagP2_indptr[1]):
			#n = diagP2_indices[h]
			d[diagP2_indices[h]] = -z[diagP2_indices[h]]
		#P3
		for h in range(diagP3_indptr[1]):
			n = diagP3_indices[h]
			if (l < m[n] <= l+eps) and (m[n] - z[n] <= l):
				#d[n] = -(m[n]/grad[n]) * grad[n]
				d[n] = -m[n]
			elif (u-eps <= m[n] < u) and (m[n] - z[n] >= u):
				#d[n] = -((m[n] - 1.0) / grad[n]) * grad[n]
				d[n] = -m[n] + 1.0
			else:
				d[n] = -z[n]
	
		sp.compress_flt_vec(d, d_data, d_indices, d_indptr, K)	
		gTd = 0.0
		for h in range(d_indptr[1]):
			gTd = gTd + d_data[h] * grad[d_indices[h]]		
		#print "cg_M ;", "cg_criterion =", cg_criterion
		#print "\t\t", itr_counter, ".  cg_M", "err diff =", "{:.12f}".format((prev_err_cg - error)/prev_err_cg)
		if isNaN(gTd):
			print "\n\n", "********************* CG M, gTd NaN *********************\n\n"
			break
		if (prev_err_cg - error)/prev_err_cg < 0.000000001:
			#print "\tbreak cg error"
			break
		if cg_i >= cg_max:
			#print "\tbreak cgi", "; K" + str(K)
			break
		cg_criterion = -gTd
		if cg_k == cg_n or cg_criterion <= 0.0: # r^T * d = 1 x K times K x 1 = 1 x 1
			cg_k = 0
			for h in range(diagP0_indptr[1]):
				d[diagP0_indices[h]] = -z[diagP0_indices[h]]
			for h in range(diagP1_indptr[1]):
				d[diagP1_indices[h]] = 0.0
			for h in range(diagP2_indptr[1]):
				d[diagP2_indices[h]] = -z[diagP2_indices[h]]
			for h in range(diagP3_indptr[1]):
				n = diagP3_indices[h]
				if (l < m[n] <= l+eps) and (m[n] - z[n] <= l):
					#d[n] = -(m[n]/grad[n]) * grad[n]
					d[n] = -m[n]
				elif (u-eps <= m[n] < u) and (m[n] - z[n] >= u):
					#d[n] = -((m[n] - 1.0) / grad[n]) * grad[n]
					d[n] = -m[n] + 1.0
				else:
					d[n] = -z[n]
			sp.compress_flt_vec(d, d_data, d_indices, d_indptr, K)
			
			gTd = 0.0
			for h in range(d_indptr[1]):
				k = d_indices[h]
				gTd = gTd + grad[k] * d[k]

	cg_itrs[0] = cg_i
	return error


cdef double cg_C(double** C, #double* vec_C, double* vec_C_old,
			#double** C_test, 
			double** M, #double* M_data, int* M_indices, int* M_indptr,
			double** X, double** R,
			#double** Grad, double* vec_Grad, #double* y_vec,
			#double* vec_D, #double* vec_D_data, int* vec_D_indices, int* vec_D_indptr,
			int I, int K, int J, double normConstant, #int* cg_itrs,
			double l, double u):
		# error = cg_C(C_ptr, vec_C, vec_C_old, C_test, 
		# 					M_ptr, M_data, M_indices, M_indptr,
		# 					X_ptr, R_ptr,
		# 					grad, vec_grad, #y_vecs[0],
		# 					vec_D, #vec_D_data, vec_D_indices, vec_D_indptr,
		# 					I, K, J, normConstant, cg_itrs_ptr,
		# 					lower, upper)
	# We need to partition the indices of the vectorized direction matrix.
	# That is, we need to put each d_i into one of 3 categories according to
	# the position of x_i (the i-th element of a given data point). 
	# These categories are L (for "lower bound"), F (for "Free variable"), 
	# and U (for "upper bound"). The constraint "l <= x <= u" is said to 
	# be active at the lower and upper bounds. To be more precise,
	#		L   =  indices i where x_i = l and the Gradient g_i(x_i) >= 0
	#		F1  =  indices i where l < x_i < u, and ||g_i(x_i)|| ~ 0
	#		F2  =  indices i where l < x_i < u, and ||g_i(x_i)|| > 0
	#		U   =  indices i where x_i = u, and g_i(x_i) <= 0
	# Note that F is divided into two subcategories, depending on the value 
	# of the Gradient.
	cdef int N = J*K
	cdef int cg_i = 0
	cdef double error, error_old
	cdef double alpha1 = 1.0
	cdef double alpha_max = 10000000.0
	cdef double c1 = 0.1
	cdef double eps = 0.001
	cdef double gTg = 0.0
	cdef double g_oldTg_old = 0.0
	cdef double gTd_old = 0.0
	cdef double gTy = 0.0
	cdef double gTd = 0.0
	cdef double Grad_norm = 0.0
	cdef double Grad_old_norm = 0.0
	cdef int a_iter = 0
	cdef int* a_iter_ptr = &a_iter
	cdef int n, j, k

	cdef double* M_data = <double *>calloc(I*K,sizeof(double))
	cdef int* M_indices = <int *>calloc(I*K,sizeof(int))
	cdef int* M_indptr  = <int *>calloc((I+1),sizeof(int))

	cdef double* vec_Grad = <double *>calloc(N,sizeof(double))
	cdef double* vec_Grad_old = <double *>calloc(N,sizeof(double))
	cdef double* y_vec = <double *>calloc(N,sizeof(double))
	cdef double* vec_D_old = <double *>calloc(N,sizeof(double))
	
	cdef double* vec_D = <double *>calloc(N,sizeof(double))
	cdef double* vec_D_data = <double *>calloc(N,sizeof(double))
	cdef int* vec_D_indices = <int *>calloc(N,sizeof(int))
	cdef int* vec_D_indptr  = <int *>calloc(2,sizeof(int))

	cdef double** C_test = <double**>malloc(J*sizeof(double*))
	for j in range(J):
		C_test[j] = <double *>malloc(K*sizeof(double))
		for k in range(K):
			C_test[j][k] = 0.0
	C_test = &C_test[0]	

	sp.compress_flt_mat(M, M_data, M_indices, M_indptr, I, K)
	#print "cg_C", 1
	#sys.stdout.flush()
	
	#matmath_nullptr.vec(Grad, vec_Grad, J, K)

	#error = predict.get_R_and_E_nsp_omp(R, M, C, X, I, J, K, normConstant)
	#Original error
	error = predict.get_R_E_and_Grad_C_nsp_omp(vec_Grad, M, C, X, R, I, J, K, normConstant)

	#print "cg_C", 2
	#sys.stdout.flush()

	#for n in range(N):
		#vec_D_old[n] = vec_D[n]
		#vec_Grad_old[n] = vec_Grad[n]
	vec_D_indptr[1] = 0
	for j in range(J):
		#GradFactor = (boundSum - 2.0*x[n]) * Grad[n]
		for k in range(K):
			n = j*K + k
			# in the case of descent to toward minimum, is the Grad positive or negative?
			# --> We want gTd to be negative, and d = -Grad initially. That is, d and Grad
			# point in opposing directions. When this is no longer true, the model
			# is moving away from its target.
			# However, d is not always going to be negative; its sign just needs to oppose
			# the Gradient's sign.
			if l < C[j][k] and C[j][k] < u:
				vec_D[n] = -vec_Grad[n]
				vec_D_indices[vec_D_indptr[1]] = n
				vec_D_data[vec_D_indptr[1]] = -vec_Grad[n]
				vec_D_indptr[1] += 1
			elif (C[j][k] == l and vec_Grad[n] >= 0.0) or (C[j][k] == u and vec_Grad[n] <= 0.0):
				vec_D[n] = 0.0
			#else:
			elif (C[j][k] == l and vec_Grad[n] < 0.0) or (C[j][k] == u and vec_Grad[n] > 0.0):
				# if vec_Grad[n] != 0.0:
				vec_D[n] = -vec_Grad[n]
				vec_D_indices[vec_D_indptr[1]] = n
				vec_D_data[vec_D_indptr[1]] = -vec_Grad[n]
				vec_D_indptr[1] += 1
				# else:
				# 	vec_D[n] = 0.0
			# else:
			# 	vec_D[n] = 0.0

	#print "cg_C", 5
	#sys.stdout.flush()
	gTd = 0.0
	for n in range(N):
		gTd += vec_Grad[n]*vec_D[n]
	#sp.compress_flt_vec(vec_D, vec_D_data, vec_D_indices, vec_D_indptr, N)
	#print "cg_C", 6
	#sys.stdout.flush()
	alpha1 = 1.0
	cg_alpha = linesearch.armijo2_C_nor(alpha1, alpha_max, c1, error, gTd, 
						C, C_test, 
						M, M_data, M_indices, M_indptr, 
						X, R, 
						vec_D, vec_D_data, vec_D_indices, vec_D_indptr,
						normConstant, I, K, J, a_iter_ptr, l, u)
	for n in range(N):
		vec_D_old[n] = vec_D[n]
	#print "cg_C", 10
	#sys.stdout.flush()
	for j in range(J):
		#for k_ptr in range(vec_D_indptr[1]):
		for k in range(K):
			#k = vec_D_indices[k_ptr]
			#C[j][k] += cg_alpha * vec_D_data[k_ptr]
			C[j][k] += cg_alpha * vec_D[j*K + k]
			if C[j][k] > u:
				C[j][k] = u
			elif C[j][k] < l:
				C[j][k] = l					
	#print "cg_C", 15
	#sys.stdout.flush()
	cdef double v = 0.0;
	error_old = error
	for n in range(N):
		vec_Grad_old[n] = vec_Grad[n]
	error = predict.get_R_E_and_Grad_C_nsp_omp(vec_Grad, M, C, X, R, I, J, K, normConstant)
	
	for n in range(N):
		gTg += vec_Grad[n]*vec_Grad[n]
		g_oldTg_old += vec_Grad_old[n]*vec_Grad_old[n]
		y_vec[n] = vec_Grad[n] - vec_Grad_old[n]
		gTd_old += vec_Grad[n] * vec_D_old[n]
	
	for n in range(N):
		gTy += vec_Grad[n] * y_vec[n]
		
	beta_PRP = gTy/(g_oldTg_old)
	eta = gTd_old/(g_oldTg_old)
	Grad_norm = sqrt(gTg)
	print "\t*** cgi", str(cg_i) + ";", 
	print "E:", "{:.7f}".format(error) + ";", 
	print "Edif:", "{:.8f}".format(error_old - error) + ";", 
	print "gTd_old =", "{:.8f}".format(gTd_old) + ";", 
	print "gn:", "{:.8f}".format(Grad_norm) + ";", 
	print "bPRP:", "{:.6f}".format(beta_PRP) + ";",
	#print "P0:", str(diagP0_indptr[1]) + "/" + str(K*J) + ";",
	print "K:", K

	while error_old - error >= 0.000001:
		cg_i += 1

		#print "cg_C", 20
		#sys.stdout.flush()

		for n in range(N):
			vec_D_old[n] = vec_D[n]
		vec_D_indptr[1] = 0
		for j in range(J):
			#GradFactor = (boundSum - 2.0*x[n]) * Grad[n]
			for k in range(K):
				n = j*K + k
				# in the case of descent to toward minimum, is the Grad positive or negative?
				# --> We want gTd to be negative, and d = -Grad initially. That is, d and Grad
				# point in opposing directions. When this is no longer true, the model
				# is moving away from its target.
				# However, d is not always going to be negative; its sign just needs to oppose
				# the Gradient's sign.
				if l < C[j][k] and C[j][k] < u:
					vec_D[n] = -vec_Grad[n]
					vec_D_indices[vec_D_indptr[1]] = n
					vec_D_data[vec_D_indptr[1]] = - vec_Grad[n]
					if vec_Grad[n]*vec_Grad[n] >= eps:
						v = beta_PRP*vec_D_old[n] - eta*y_vec[n]
						vec_D[n] += v
						vec_D_data[vec_D_indptr[1]] += v
					vec_D_indptr[1] += 1
				elif C[j][k] == l: 
					if vec_Grad[n] >= 0.0: vec_D[n] = 0.0
					else:
						vec_D[n] = -vec_Grad[n]
						vec_D_indices[vec_D_indptr[1]] = n
						vec_D_data[vec_D_indptr[1]] = -vec_Grad[n]
						vec_D_indptr[1] += 1
				elif C[j][k] == u: 
					if vec_Grad[n] <= 0.0: vec_D[n] = 0.0
					else:
						vec_D[n] = -vec_Grad[n]
						vec_D_indices[vec_D_indptr[1]] = n
						vec_D_data[vec_D_indptr[1]] = -vec_Grad[n]
						vec_D_indptr[1] += 1


				# or (C[j][k] == u and vec_Grad[n] <= 0.0):
				# 	vec_D[n] = 0.0
				# #else:
				# elif (C[j][k] == l and vec_Grad[n] < 0.0) or (C[j][k] == u and vec_Grad[n] > 0.0):
				# 	# if vec_Grad[n]*vec_Grad[n] > eps*eps:
				# 	vec_D[n] = -vec_Grad[n]
				# 	vec_D_indices[vec_D_indptr[1]] = n
				# 	vec_D_data[vec_D_indptr[1]] = -vec_Grad[n]
				# 	vec_D_indptr[1] += 1
				# else:
				# 	vec_D[n] = 0.0
				# else:
				# 	if vec_Grad[n]*vec_Grad[n] > eps*eps:
				# 		vec_D[n] = -vec_Grad[n]
				# 		vec_D_indices[vec_D_indptr[1]] = n
				# 		vec_D_data[vec_D_indptr[1]] = -vec_Grad[n]
				# 		vec_D_indptr[1] += 1
				# 	else:
				# 		vec_D[n] = 0.0
				
				# print "cg_C;", "vec_D[", n, "] =", vec_D[n], "\t",
				# #sys.stdout.flush()
				# if n%3==0: 
				# 	print ""
					
		# print "********************"
		# #sys.stdout.flush()
		# for h in range(vec_D_indptr[1]):
		# 	print "cg_C;", "vec_D_indptr[", h, "] =", vec_D_indptr[h], "\t",
		# 	#sys.stdout.flush()
		# 	if n%3==0: 
		# 		print ""
		# 		#sys.stdout.flush()
		# print "\n"
		#sys.stdout.flush()
		gTd = 0.0
		for n in range(N):
			gTd += vec_Grad[n]*vec_D[n]
		#print "cg_C", 30
		#sys.stdout.flush()	
		alpha1 = 1.0
		cg_alpha = linesearch.armijo2_C_nor(alpha1, alpha_max, 
					c1, error, gTd,
					C, C_test, M, M_data, M_indices, M_indptr,
					X, R,
					vec_D, vec_D_data, vec_D_indices, vec_D_indptr,
					normConstant, I, K, J, a_iter_ptr,
					l, u)
		#print "cg_C", 31
		#sys.stdout.flush()	
		if cg_alpha == 0.0:
			break
		else:	
			for j in range(J):
				#for k_ptr in range(vec_D_indptr[1]):
				for k in range(K):
					#k = vec_D_indices[k_ptr]
					#C[j][k] += cg_alpha * vec_D_data[k_ptr]
					print "a=", "{:.4f}".format(cg_alpha), "C[",j,",",k,"] (", "{:.6f}".format(C[j][k]), ") +=","{:.6f}".format(cg_alpha), "*", "{:.6f}".format(vec_D[j*K + k]), " = ",
					C[j][k] += cg_alpha * vec_D[j*K + k]
					print "*C[",j,",",k,"] (", "{:.6f}".format(C[j][k]), "); ^vec_Grad[", j*K + k, "] =", "{:.6f}".format(vec_Grad[j*K + k])
					if C[j][k] < 0.0 or C[j][k] > 1.0:
						print "\t************ C out of bounds!!! ************"
					if C[j][k] > u:
						C[j][k] = u
					elif C[j][k] < l:
						C[j][k] = l	
		
		#print "cg_C", 35
		#sys.stdout.flush()	

		error_old = error
		for n in range(N):
			vec_Grad_old[n] = vec_Grad[n]
		error = predict.get_R_E_and_Grad_C_nsp_omp(vec_Grad, M, C, X, R, I, J, K, normConstant)
		
		print "\t*** cgi", str(cg_i) + ";", 
		print "E:", "{:.7f}".format(error) + ";", 
		print "Edif:", "{:.8f}".format(error_old - error) + ";", 
		print "gTd_old =", "{:.8f}".format(gTd_old) + ";", 
		print "gn:", "{:.8f}".format(Grad_norm) + ";", 
		print "bPRP:", "{:.6f}".format(beta_PRP) + ";",
		#print "P0:", str(diagP0_indptr[1]) + "/" + str(K*J) + ";",
		print "K:", K
		#print "cg_C", 38
		#sys.stdout.flush()

		for n in range(N):
			gTg += vec_Grad[n]*vec_Grad[n]
			g_oldTg_old += vec_Grad_old[n]*vec_Grad_old[n]
			y_vec[n] = vec_Grad[n] - vec_Grad_old[n]
			gTd_old += vec_Grad[n] * vec_D_old[n]
		
		for n in range(N):
			gTy += vec_Grad[n] * y_vec[n]
		
		beta_PRP = gTy/(g_oldTg_old)
		eta = gTd_old/(g_oldTg_old)
		Grad_norm = sqrt(gTg)
		# print "\t*** cgi", str(cg_i) + ";", 
		# print "E:", "{:.7f}".format(error) + ";", 
		# print "Edif:", "{:.8f}".format(error_old - error) + ";", 
		# print "gTd_old =", "{:.8f}".format(gTd_old) + ";", 
		# print "gn: =", "{:.8f}".format(Grad_norm) + ";", 
		# print "bPRP:", beta_PRP, ";",
		# #print "P0:", str(diagP0_indptr[1]) + "/" + str(K*J) + ";",
		# print "K:", K
	
	dealloc_matrix_2(C_test, J)
	#print "cg_C", 50
	#sys.stdout.flush()
	dealloc_vector(M_data)
	#print "cg_C", 51
	#sys.stdout.flush()
	dealloc_vec_int(M_indices)
	#print "cg_C", 52
	#sys.stdout.flush()
	dealloc_vec_int(M_indptr)
	#print "cg_C", 53
	#sys.stdout.flush()
	dealloc_vector(y_vec)
	#print "cg_C", 54
	#sys.stdout.flush()
	dealloc_vector(vec_D_old)
	#print "cg_C", 55
	#sys.stdout.flush()
	dealloc_vector(vec_Grad_old)
	#print "cg_C", 56
	#sys.stdout.flush()
	dealloc_vector(vec_D)
	#print "cg_C", 64
	#sys.stdout.flush()
	dealloc_vector(vec_D_data)
	#print "cg_C", 65
	#sys.stdout.flush()
	dealloc_vec_int(vec_D_indices)
	#print "cg_C", 66
	#sys.stdout.flush()
	dealloc_vec_int(vec_D_indptr)
	#print "cg_C", 67
	#sys.stdout.flush()
	return error


cdef FLOAT cg_C_nor(FLOAT** C, FLOAT* vec_C, FLOAT* vec_C_old,
			FLOAT** C_test, 
			FLOAT** M, FLOAT* M_data, int* M_indices, int* M_indptr,
			FLOAT** X, FLOAT** R,
			FLOAT** grad, FLOAT* vec_grad,
			FLOAT* vec_grad_data, int* vec_grad_indices, int* vec_grad_indptr,
			FLOAT* vec_grad_old,
			FLOAT* vec_z, FLOAT* vec_z_data, int* vec_z_indices, int* vec_z_indptr,
			FLOAT* vec_z_old,
			FLOAT* s_vec, FLOAT* y_vec, FLOAT* Hy,
			FLOAT* vec_D, FLOAT* vec_D_data, int* vec_D_indices, int* vec_D_indptr,
			FLOAT* diagPre, FLOAT gTd,
			FLOAT* gamma, FLOAT error, int itr_max, int* cg_itrs, int* nr_itrs,
			int I, int K, int J,
			FLOAT normConstant, int objFunc,
			int precondition,
			FLOAT* diagP0, int* diagP0_indices, int* diagP0_indptr,
			int* diagP0_zero_indices, int* diagP0_zero_indptr,
			FLOAT* diagP1, int* diagP1_indices, int* diagP1_indptr,
			int* diagP1_zero_indices, int* diagP1_zero_indptr,
			int* diagP2_indices, int* diagP2_indptr,
			int* diagP3_indices, int* diagP3_indptr,
			FLOAT eps, FLOAT* distance, int* num_steps, FLOAT l, FLOAT u):
	eps = 0.00000001
	#print "\n\n\t********************** CG **********************\n"
	cdef FLOAT error0 = error
	cdef INT i,j,k,h,n,counter
	cdef INT N = K*J
	cdef bint init = 1
	cdef int beta_choice = -1
	cdef bint terminate = 0
	cdef bint nr_break = 0
	cdef bint cg_init = 1
	#cdn = 10  # n is the number of components in an M-vector; it could be larger than cg_max.
	####### cg variables #######
	cdef FLOAT eps_cg = 0.01
	cdef FLOAT eps_nr = 0.01
	cdef FLOAT zero_eps = 0.001
	cdef FLOAT eps_cg_sq = eps_cg*eps_cg
	cdef FLOAT eps_nr_sq = eps_nr*eps_nr
	cdef INT nr_i, cg_i, cg_k, 
	cg_k = 0
	cdef INT cg_n = <int>min(10, itr_max)
	cdef INT cg_max = <int>itr_max
	cdef FLOAT delta_0, delta_new, delta_d, chi
	cdef FLOAT grad_norm
	cdef FLOAT cg_alpha = 0.0
	cdef FLOAT cg_beta, beta_HS, beta_reg, beta_DY, beta_DYCD
	cdef FLOAT gTd_old = 0.0
	cdef FLOAT dTy = 0.0
	cdef FLOAT gTy = 0.0
	cdef FLOAT sTs = 0.0
	cdef FLOAT sTy = 0.0
	cdef FLOAT yTy = 0.0
	cdef FLOAT gTg = 0.0
	cdef FLOAT gTg_old = 0.0
	cdef FLOAT prev_err_cg = -0.1
	cdef FLOAT prev_err_nr = -0.1
	cdef FLOAT prev_err = 0.0
	cdef FLOAT g_diff_sum, nr_criterion_old, nr_criterion_new, cg_criterion
	cdef FLOAT alpha1 = 1.0
	cdef FLOAT alpha_max = 100000000000.0
	cdef FLOAT c1 = 0.0001
	cdef FLOAT c2 = 0.1
	cdef int a_iter = 1
	cdef int* a_iter_ptr = &a_iter
	cdef FLOAT numer = 0.0
	cdef FLOAT denom = 1.0
	cdef FLOAT rate = 1.0
	cdef FLOAT beta_numer = 1.0
	cdef FLOAT beta_denom = 1.0
	cdef FLOAT beta_PRP = 0.0
	cg_beta = 0.0
	cdef FLOAT old_c

	if precondition > 0:
		#as long as precondition is not 1 or 2, the gradient is 
		#multipilied by a preconditioner that is supplied to the 
		#program as a parameter. We use the diagonal of the 
		#preconditioner.
		for n in range(N):
			vec_z[n] = vec_grad[n] * diagPre[n]
	else:
		for n in range(N):
			vec_z[n] = vec_grad[n]
	
	sp.compress_flt_vec(vec_grad, vec_grad_data, vec_grad_indices, vec_grad_indptr, N)
	sp.compress_flt_vec(vec_z, vec_z_data, vec_z_indices, vec_z_indptr, N)

	search_direction.prelims_slmqn(vec_grad,
				vec_grad_data, vec_grad_indices, vec_grad_indptr,
				vec_C,
				diagP0, diagP0_indices, diagP0_indptr,
				diagP0_zero_indices, diagP0_zero_indptr,
				diagP1, diagP1_indices, diagP1_indptr,
				diagP1_zero_indices, diagP1_zero_indptr,
				diagP2_indices, diagP2_indptr,
				diagP3_indices, diagP3_indptr,
				eps, zero_eps, J, K, N, l, u)
	
	# Populating the "distance" vector, which specifies the size of the update step
	# in each dimension.
	for h in range(diagP0_indptr[1]):
		vec_D[diagP0_indices[h]] = -vec_z[diagP0_indices[h]]
		
	for h in range(diagP1_indptr[1]):
		vec_D[diagP1_indices[h]] = 0.0
	
	for h in range(diagP2_indptr[1]):
		vec_D[diagP2_indices[h]] = -vec_z[diagP2_indices[h]]

	for h in range(diagP3_indptr[1]):
		n = diagP3_indices[h]
		if (l < vec_C[n] <= l+eps) and (vec_C[n] - vec_z[n] <= l):
			vec_D[n] = -vec_C[n]
		elif (u-eps <= vec_C[n] < u) and (vec_C[n] - vec_z[n] >= u):
			vec_D[n] = -vec_C[n] + 1.0
		else:
			vec_D[n] = -vec_z[n]
			
	sp.compress_flt_vec(vec_D, vec_D_data, vec_D_indices, vec_D_indptr, N)

	gTg = 0.0
	for h in range(vec_grad_indptr[1]):
		gTg += vec_grad_data[h] * vec_z[vec_grad_indices[h]] * diagP0[vec_grad_indices[h]]
	grad_norm = sqrt(gTg)

	delta_0 = gTg
	cg_i = 0
	counter = 0

	gTd = 0.0
	for h in range(vec_D_indptr[1]):
		gTd += vec_grad[vec_D_indices[h]] * vec_D_data[h] 

	while cg_i <= cg_max:
		cg_k += 1
		cg_i += 1
		prev_err = prev_err_cg 
		prev_err_cg = error
		delta_d = 0.0
		for h in range(vec_D_indptr[1]):
			delta_d += vec_D_data[h] * vec_D_data[h]
		# Save current gradient and C as old gradient and C, respectively.
		for n in range(N):
			vec_C_old[n] = vec_C[n]
		for n in range(N):
			vec_grad_old[n] = vec_grad[n]

		gTd_old = gTd
		alpha1 = 1.0
		cg_alpha = linesearch.armijo2_C_nor(alpha1, alpha_max, 
					c1, error, gTd,
					C, C_test, M, M_data, M_indices, M_indptr,
					X, R,
					vec_D, vec_D_data, vec_D_indices, vec_D_indptr,
					normConstant, I, K, J, a_iter_ptr,
					l, u)

		for n in range(N):
			vec_C_old[n] = vec_C[n]

		for j in range(J):
			for k in range(K):
				old_c = C[j][k]
				C[j][k] += cg_alpha * vec_D[j*K + k]
				if C[j][k] > u:
					C[j][k] = u
				elif C[j][k] < l:
					C[j][k] = l
				distance[0] += fabs(C[j][k] - old_c)
				num_steps[0] += 1

		matmath_nullptr.vec(C, vec_C, J, K)

		if cg_init == 1:
			prev_err_cg = error
			cg_init = 0
		else:
			prev_err_cg = error	

		for n in xrange(N):
			vec_grad_old[n] = vec_grad[n]
		# error = predict_nor.R_E_and_Grad_C_omp_2(grad, C, M, M_data, M_indices, M_indptr,
		# 				X, R, error, I, J, K, normConstant, eta)
		error = predict.get_R_E_and_Grad_C_omp(grad, M_data, M_indices, M_indptr,
						C, X, R, I, J, K, normConstant)
		matmath_nullptr.vec(grad, vec_grad, J, K)	
		
		#The indices used in the Beta calculations should only be P0 indices
		#because Beta is only used to calculate vec_D at its P0 indices.
		gTg_old = gTg
		
		for n in xrange(N):
			s_vec[n] = vec_C[n] - vec_C_old[n]

		for n in xrange(N):
			y_vec[n] = vec_grad[n] - vec_grad_old[n]
		
		if precondition > 0:
			for n in range(N):
				Hy[n] = diagPre[n] * y_vec[n]
	
		if precondition == 2:
			#if precondition = 2, the preconditioner is updated with each iteration.
			#if precondition = 1, it is kept fixed.
			sTy = 0.0
			for h in range(diagP0_indptr[1]):
				sTy += s_vec[diagP0_indices[h]] * y_vec[diagP0_indices[h]]
			if sTy == 0.0:
				break
			predict.get_inv_diag_bfgs(diagPre, s_vec, y_vec, 
						Hy, sTy, N, diagP0)
		if precondition > 0:
			#the preconditioner is applied as long as precondition isn't 0.
			for n in range(N):
				vec_z[n] = vec_grad[n] * diagPre[n]
			gTy = 0.0
			for h in range(diagP0_indptr[1]):
				gTy += vec_grad[diagP0_indices[h]] * Hy[diagP0_indices[h]]
		else:
			for n in range(N):
				vec_z[n] = vec_grad[n]
			gTy = 0.0
			for h in range(diagP0_indptr[1]):
				gTy += vec_grad[diagP0_indices[h]] * y_vec[diagP0_indices[h]]

		sp.compress_flt_vec(vec_grad, vec_grad_data, vec_grad_indices, vec_grad_indptr, N)
		sp.compress_flt_vec(vec_z, vec_z_data, vec_z_indices, vec_z_indptr, N)		
		gTg_old = gTg
		gTg = 0.0
		for h in range(vec_grad_indptr[1]):
			gTg += vec_grad_data[h] * vec_z[vec_grad_indices[h]] * diagP0[vec_grad_indices[h]]
		grad_norm = sqrt(gTg)

		if gTg_old == 0.0:
			print "gTg_old == 0.0; BREAK!\n"
			break
		else:
			beta_PRP = gTy / gTg_old

		if isNaN(cg_beta):
			print "\n\n**************** NaN cg_beta, C ****************\n\n"
			break

		search_direction.prelims_slmqn(vec_grad,
						vec_grad_data, vec_grad_indices, vec_grad_indptr,
						vec_C,
						diagP0, diagP0_indices, diagP0_indptr,
						diagP0_zero_indices, diagP0_zero_indptr,
						diagP1, diagP1_indices, diagP1_indptr,
						diagP1_zero_indices, diagP1_zero_indptr,
						diagP2_indices, diagP2_indptr,
						diagP3_indices, diagP3_indptr,
						eps, zero_eps, J, K, N, l, u)

		for h in range(diagP0_indptr[0]):
			n = diagP0_indices[h]
			vec_D[n] = -vec_z[n] + (cg_beta * vec_D[n])
		for h in range(diagP1_indptr[1]):
			vec_D[diagP1_indices[h]] = 0.0
		for h in range(diagP2_indptr[1]):
			vec_D[diagP2_indices[h]] = -vec_z[diagP2_indices[h]]
		for h in range(diagP3_indptr[1]):
			n = diagP3_indices[h]
			if (l < vec_C[n] <= l+eps) and (vec_C[n] - vec_z[n] <= l):
				vec_D[n] = -vec_C[n]
			elif (u-eps <= vec_C[n] < u) and (vec_C[n] - vec_z[n] >= u):
				vec_D[n] = -vec_C[n] + 1.0
			else:
				vec_D[n] = -vec_z[n]
		
		sp.compress_flt_vec(vec_D, vec_D_data, vec_D_indices, vec_D_indptr, N)

		gTd = 0.0
		for h in range(vec_D_indptr[1]):
			gTd += vec_grad[vec_D_indices[h]] * vec_D_data[h] * diagP0[vec_D_indices[h]]
		
		print "\t*** cgi", str(cg_i) + ";", 
		print "E:", "{:.7f}".format(error) + ";", 
		print "Edif:", "{:.8f}".format(prev_err_cg - error) + ";", 
		print "gTd =", "{:.8f}".format(gTg) + ";", 
		print "gn: =", "{:.8f}".format(grad_norm) + ";", 
		print "B:", cg_beta, ";",
		print "P0:", str(diagP0_indptr[1]) + "/" + str(K*J) + ";",
		print "K:", K
		
		cg_criterion = -gTd	
		print "cg_criterion =", -gTd	

		if (prev_err_cg - error) / prev_err_cg < 0.0000000001:
			print "\tC CG; break",3, "; change in err_cg =", (prev_err_cg - error)/prev_err_cg, "; K" + str(K)
			break

		if cg_k == cg_n or cg_criterion <= 0.0: # r^T * d = 1 x K times K x 1 = 1 x 1
			print "\t!!! Restart CG; cg_criterion =", cg_criterion
			cg_k = 0

			for h in range(diagP0_indptr[1]):
				vec_D[diagP0_indices[h]] = -vec_z[diagP0_indices[h]]
		
			for h in range(diagP1_indptr[1]):
				vec_D[diagP1_indices[h]] = 0.0
	
			for h in range(diagP2_indptr[1]):
				vec_D[diagP2_indices[h]] = -vec_z[diagP2_indices[h]]

			for h in range(diagP3_indptr[1]):
				n = diagP3_indices[h]
				vec_D[n] = -vec_grad[n]
				if (l < vec_C[n] <= l+eps) and (vec_C[n] - vec_z[n] <= l):
					vec_D[n] = -vec_C[n]
				elif (u-eps <= vec_C[n] < u) and (vec_C[n] - vec_z[n] >= u):
					vec_D[n] = -vec_C[n] + 1.0
				else:
					vec_D[n] = -vec_z[n]
					
			sp.compress_flt_vec(vec_D, vec_D_data, vec_D_indices, vec_D_indptr, N)

			gTd = 0.0
			for h in range(vec_D_indptr[1]):
				gTd += vec_grad[vec_D_indices[h]] * vec_D_data[h] * diagP0[vec_D_indices[h]]	
		counter = counter + 1
	
	cg_itrs[0] = cg_i
	print "\tC CG :", "END; total error reduction =", (error0 - error)/error0, "\n"
	return error
