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
		gTd += grad[d_indices[h]] * d_data[h] #* diagP0[d_indices[h]]
	#sp.compress_flt_vec(m, m_data, m_indices, m_indptr, K)

	delta_new = 0.0
	for h in range(grad_indptr[1]):
		delta_new += (grad_data[h] * z[grad_indices[h]]) * diagP0[grad_indices[h]]
	grad_norm = sqrt(delta_new)
	delta_0 = delta_new 
	
	cg_i = 0
	while cg_i <= cg_max:
		cg_k += 1
		cg_i += 1
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
			m[d_indices[h]] += cg_alpha * d_data[h]
			if m[d_indices[h]] > u:
				m[d_indices[h]] = u
			elif m[d_indices[h]] < l:
				m[d_indices[h]] = l
			distance[0] += fabs(m[d_indices[h]] - old_m)
			num_steps[0] += 1
		for k in range(K):
			s_vec[k] = m[k] - m_old[k]	
		prev_err_nr = error
		for k in range(K):
			grad_old[k] = grad[k]
		prev_err_cg = error
		# error = predict_nor.r_e_and_grad_m_2(grad, m, 
		# 		C, C_data, C_indices, C_indptr, 
		# 		x, r, error, J, K, normConstant, eta)
		error = predict.get_r_e_and_grad_m_omp(grad, m, 
				C_data, C_indices, C_indptr, 
				x, r, J, K, normConstant)	
		for k in range(K):
			s_vec[k] = m[k] - m_old[k]
			y_vec[k] = grad[k] - grad_old[k]	
		
		if precondition > 0:
			for k in range(K):
				Hy[k] = diagPre[k] * y_vec[k]
		if yTy <= 0.0000000001: 
			break
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
			gTd += d_data[h] * grad[d_indices[h]]		
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
				gTd += grad[k] * d[k]

	cg_itrs[0] = cg_i
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
			FLOAT normConstant,  int objFunc,
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
		print "B:", cg_beta, ";",
		print "P0:", str(diagP0_indptr[1]) + "/" + str(K*J) + ";",
		print "K:", K
		
		if (prev_err_cg - error) / prev_err_cg < 0.0000000001:
			print "\tC CG; break",3, "; change in err_cg =", (prev_err_cg - error)/prev_err_cg, "; K" + str(K)
			break

		cg_criterion = -gTd	
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
		counter += 1
	
	cg_itrs[0] = cg_i
	print "\tC CG :", "END; total error reduction =", (error0 - error)/error0, "\n"
	return error
