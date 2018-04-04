#cython: profile=True
#cython: boundscheck=False
#cython: wraparound=False
#cython: cdivision=True
import sys

cdef bint isNaN(FLOAT x):
	return x != x 

cdef FLOAT wolfe_M_nor(FLOAT alpha_new, FLOAT alpha_max, FLOAT c1, FLOAT c2,
				FLOAT phi_0, FLOAT der_phi_0,
				FLOAT* m0, FLOAT* m,
				FLOAT** C, FLOAT* C_data, int* C_indices, int* C_indptr,
				FLOAT* x, FLOAT* r,
				FLOAT* d, FLOAT* d_data, int* d_indices, int* d_indptr,
				FLOAT* grad, FLOAT* grad_data, int* grad_indices, int* grad_indptr,
				FLOAT normConstant, int J, int K, int* iterations,
				FLOAT l, FLOAT u):
	
	cdef INT k, h
	cdef bint computed_der_new = 0
	cdef FLOAT alpha_tmp = 1.0
	cdef FLOAT alpha_0 = 0.0
	cdef FLOAT alpha_old = alpha_0
	cdef FLOAT phi_old, phi_new, der_phi_old, der_phi_new, sTy, yTy, factor, a, b
	phi_old = phi_0
	phi_new = 0.0
	iterations[0] = 1
	der_phi_old = der_phi_0
	der_phi_new = der_phi_old

	while alpha_new < alpha_max:
		for h in range(d_indptr[1]):
			m[d_indices[h]] = m0[d_indices[h]] + alpha_new * d_data[h]
			if m[d_indices[h]] > u:
				m[d_indices[h]] = u
			elif m[d_indices[h]] < l:
				m[d_indices[h]] = l
		
		phi_old = phi_new
		#if K > 1:
			# phi_new = predict_nor.r_e_and_grad_m(grad, m,
			# 			C, C_data, C_indices, C_indptr,
			# 			x, r, J, K, normConstant, eta)
			# phi_new = predict.get_r_e_and_grad_m_omp(grad, m,
			# 			C, C_data, C_indices, C_indptr,
			# 			x, r, J, K, normConstant)
		# else:
		# 	phi_new = predict_nor.r_e_and_grad_m_one(grad, m,
		# 				C, x, r, J, normConstant, eta)
		phi_new = predict.get_r_e_and_grad_m_omp(grad, m,
						C_data, C_indices, C_indptr,
						x, r, J, K, normConstant)
		sp.compress_dbl_vec(grad, grad_data, grad_indices, grad_indptr, K)
		der_phi_old = der_phi_new 
		der_phi_new = matmath_sparse.mul_1d_1d(grad_data, 
								grad_indices, grad_indptr,
								d_data, d_indices, d_indptr)

		if phi_new > phi_0 + c1 * alpha_new * der_phi_0 or (phi_new >= phi_old and iterations[0] > 1):

			return zmnor.zoom_M_nor(alpha_old, phi_old, der_phi_old,
						alpha_new, phi_new, der_phi_new,
						phi_0, der_phi_0,
						c1, c2,
				 		m0, m, 
						C, C_data, C_indices, C_indptr,
				 		x, r, 
						d, d_data, d_indices, d_indptr,
						grad, grad_data, grad_indices, grad_indptr,
						normConstant,  J, K, iterations[0],
						l, u)

		########################################################
		# Evaluate the gradient (i.e., phi prime) of the error function with respect
		## to the i-th row of M.
		#print "LS_M", ";", 4
		sys.stdout.flush()

		#########################################################		
		#print "\t\t|der_phi_new| =", fabs(der_phi_new), " <= ", "-c2*der_phi_0 =", -c2*der_phi_0
		if der_phi_new >= c2*der_phi_0:
			#print "\t\twolfe M; WOLFE POINT FOUND! RETURN", alpha_new
			##sys.stdout.flush()
			return alpha_new
		#print "LS_M", ";", 5
		sys.stdout.flush()
		if der_phi_new >= 0.0:
			#print "\t\twolfe_M; zoom 2, der_phi_new =", der_phi_new
			return zmnor.zoom_M_nor(alpha_new, phi_new, der_phi_new,
						alpha_old, phi_old, der_phi_old,
						phi_0, der_phi_0,
						c1, c2,
						m0, m, 
						C, C_data, C_indices, C_indptr,
						x, r, 
						d, d_data, d_indices, d_indptr,
						grad, grad_data, grad_indices, grad_indptr,
						normConstant,  J, K, iterations[0],
						l, u)
		alpha_old = alpha_new
		alpha_new *= 5.0
		iterations[0] += 1
	return alpha_max


cdef FLOAT wolfe_C_nor(FLOAT alpha_new, FLOAT alpha_max, FLOAT c1, FLOAT c2,
				FLOAT phi_0, FLOAT der_phi_0,
				FLOAT** C0, FLOAT** C, 
				FLOAT** M, FLOAT** X, FLOAT** R,
				FLOAT* d, FLOAT* d_data, int* d_indices, int* d_indptr,
				FLOAT** grad, FLOAT* vec_grad, 
				FLOAT* vec_grad_data, int* vec_grad_indices, int* vec_grad_indptr,
				FLOAT normConstant, int I, int K, int J, int* iterations,
				FLOAT l, FLOAT u):
	cdef INT N = K*J
	cdef INT n, h, k, j
	cdef bint computed_der_new = 0
	cdef FLOAT alpha_min = 0.0
	cdef FLOAT alpha_old = alpha_min
	cdef FLOAT phi_old, phi_new, der_phi_old, der_phi_new, factor, a, b
	phi_old = phi_0
	cdef FLOAT numer, denom
	phi_new = 0.0
	iterations[0] = 1
	der_phi_old = der_phi_0
	der_phi_new = der_phi_old
	while alpha_new < alpha_max:
		print "\t\t** wolfe C itr", iterations[0], ";", "alpha_new =", alpha_new
		#print "\t\t** wolfe C itr", iterations[0], ";", "alpha_new =", alpha_new, ";",
		#sys.stdout.flush()
		for j in range(J):
			for k in range(K):
				C[j][k] = C0[j][k] + alpha_new * d[j*K + k]
				# clip values to ensure that they stay within [0,1].
				if C[j][k] > u:
					C[j][k] = u
				elif C[j][k] < l:
					C[j][k] = l
			
		phi_old = phi_new
		# if K > 1:
		# 	phi_new = predict_nor.R_E_and_grad_C(grad,
		# 				M, C, X, R, I, J, K, normConstant, eta)
		# else:
		# 	phi_new = predict_nor.R_E_and_grad_C_one(grad,
		# 				M, C, X, R, I, J, normConstant, eta)
		predict.get_R_E_and_Grad_C_nsp_omp(vec_grad, M, C, X, R, I, J, K, normConstant)
		if isNaN(phi_new):
			print "\n**************", "phi_new =", "NaN!!!!", "**************\n"
			return alpha_old
		matmath_nullptr.vec(grad, vec_grad, J, K)
		sp.compress_dbl_vec(vec_grad, vec_grad_data, vec_grad_indices, vec_grad_indptr, N)
		der_phi_old = der_phi_new 
		der_phi_new = matmath_sparse.mul_1d_1d(vec_grad_data, 
								vec_grad_indices, vec_grad_indptr,
								d_data, d_indices, d_indptr)
		if isNaN(der_phi_new):
			print "\n**************", "der_phi_new =", "NaN!!!!", "**************\n"
			return alpha_old								
		if phi_new > phi_0 + c1 * alpha_new * der_phi_0 or (phi_new >= phi_old and iterations[0] > 1):
			print "   ZOOM 1!!!", "; phi_new =", phi_new, "; phi_0 etc =", phi_0 + c1 * alpha_new * der_phi_0, "; phi_old =", phi_old
			return zmnor.zoom_C_nor(alpha_old, phi_old, der_phi_old,
						alpha_new, phi_new, der_phi_new,
						phi_0, der_phi_0,
						c1, c2, C0, C, M, X, R,
						d, d_data, d_indices, d_indptr,
						grad, vec_grad, vec_grad_data, vec_grad_indices, vec_grad_indptr,
						normConstant,  I, K, J, iterations[0], l, u)
		########################################################
		# Evaluate the gradient (i.e., phi prime) of the error function with respect
		## to C.
		#######################################################
		#print "\t\t|der_phi_new| =", fabs(der_phi_new), " <= ", "-c2*der_phi_0 =", -c2*der_phi_0
		if der_phi_new >= c2*der_phi_0:
			#print "wolfe C; WOLFE POINT FOUND! RETURN", alpha_new
			print "\nWOLFE POINT FOUND! RETURN", alpha_new
			return alpha_new
	
		if der_phi_new >= 0.0:
			#print "wolfe_C; zoom 2" #der_phi_new =", der_phi_new
			##sys.stdout.flush()
			print "   \nZOOM 2!!!"
			return zmnor.zoom_C_nor(alpha_new, phi_new, der_phi_new,
						alpha_old, phi_old, der_phi_old,
						phi_0, der_phi_0,
						c1, c2, C0, C, M, X, R,
						d, d_data, d_indices, d_indptr,
						grad, vec_grad, vec_grad_data, vec_grad_indices, vec_grad_indptr,
						normConstant,  I, K, J, iterations[0], l, u)
			
		alpha_old = alpha_new
		if alpha_new < 10.0:
			alpha_new *= 10.0
		else:
			alpha_new *= 5.0
		#print "wolfe C ; split alpha ; alpha_new =", alpha_new
		print "split alpha ; alpha_new =", alpha_new

		iterations[0] += 1
		#i += 1
	##sys.stdout.flush()
	print "failed search ; returning alpha_max =", alpha_max
	return alpha_max

######################################################

# cdef FLOAT wolfe_M_wwb(FLOAT alpha_new, FLOAT alpha_max, FLOAT c1, FLOAT c2,
# 				FLOAT phi_0, FLOAT der_phi_0,
# 				FLOAT* m0, FLOAT* m,
# 				FLOAT** C, FLOAT* C_lt0_data, int* C_lt0_indices, int* C_lt0_indptr,
# 				FLOAT* C_gt0_data, int* C_gt0_indices, int* C_gt0_indptr,
# 				FLOAT* x, FLOAT* r,
# 				FLOAT* d, FLOAT* d_data, int* d_indices, int* d_indptr,
# 				FLOAT* grad, FLOAT* grad_data, int* grad_indices, int* grad_indptr,
# 				FLOAT normConstant, int J, int K, int* iterations):
	
# # 	cdef int num_stored = num_str_ptr[0]
# 	cdef INT k, h
# 	cdef bint computed_der_new = 0
# 	cdef FLOAT alpha_tmp = 1.0
# 	cdef FLOAT alpha_0 = 0.0
# 	cdef FLOAT alpha_old = alpha_0
# 	cdef FLOAT phi_old, phi_new, der_phi_old, der_phi_new, sTy, yTy, factor, a, b
# 	phi_old = phi_0
# 	#phi_new = phi_old
# 	iterations[0] = 1
# 	der_phi_old = der_phi_0
# 	der_phi_new = der_phi_old
# 	#i = 1
# 	#while alpha_new <= 0.9999*alpha_max:
# 	while alpha_new < alpha_max:
# 		#print "\t\t** wolfe M itr", iterations[0], ";", "alpha_new =", alpha_new, ";"
# 		##sys.stdout.flush()
# 		for h in range(d_indptr[1]):
# 			m[d_indices[h]] = m0[d_indices[h]] + alpha_new * d_data[h]
# 			# clip values to ensure that they stay within [0,1].
# 			if m[d_indices[h]] > 1.0:
# 				m[d_indices[h]] = 1.0
# 				#print "  \t\tm[k] > 1.0;", "STOP"
# 				#return alpha_new
# 			elif m[d_indices[h]] < 0.0:
# 				m[d_indices[h]] = 0.0
# 				#print "  \t\tm[k] < 0.0;", "STOP"
# 				#return alpha_new
		
# 		#print "LS_M", ";", 1
# 		#sys.stdout.flush()
# 		if K > 1:
# 			phi_new = predict_wwb.r_e_and_grad_m(grad, m,
# 						C, C_lt0_data, C_lt0_indices, C_lt0_indptr,
# 						C_gt0_data, C_gt0_indices, C_gt0_indptr,
# 						x, r, J, K, normConstant, eta)
# 		else:
# 			phi_new = predict_wwb.r_e_and_grad_m_one(grad, m,
# 						C, x, r, J, normConstant, eta)
		
# 		sp.compress_dbl_vec(grad, grad_data, grad_indices, grad_indptr, K)
# 		der_phi_new = matmath_sparse.mul_1d_1d(grad_data, 
# 								grad_indices, grad_indptr,
# 								d_data, d_indices, d_indptr)
# # 		if objFunc == 1:
# # 			phi_new = predict_sp2.loss_one(x, r, J, normConstant)
# # 		else:
# # 			phi_new = predict_sp2.error_one(x, r, J, normConstant)
# #  
# 		#print "LS_M", ";", 2
# 		#sys.stdout.flush()
# 		if phi_new > phi_0 + c1 * alpha_new * der_phi_0 or (phi_new >= phi_old and iterations[0] > 1):

# 			return zmwwb.zoom_M_wwb(alpha_old, phi_old, der_phi_old,
# 						alpha_new, phi_new, der_phi_new,
# 						phi_0, der_phi_0,
# 						c1, c2,
# 				 		m0, m, 
# 						C, C_lt0_data, C_lt0_indices, C_lt0_indptr,
# 						C_gt0_data, C_gt0_indices, C_gt0_indptr,
# 				 		x, r, 
# 						d, d_data, d_indices, d_indptr,
# 						grad, grad_data, grad_indices, grad_indptr,
# 						normConstant,  J, K, iterations[0])
# 		########################################################
# 		# Evaluate the gradient (i.e., phi prime) of the error function with respect
# 		## to the i-th row of M.
# 		#print "LS_M", ";", 4
# 		#sys.stdout.flush()
# # 		der_phi_new = matmath_sparse.mul_1d_1d(grad_data, 
# # 								grad_indices, grad_indptr,
# # 								d_data, d_indices, d_indptr)
# 		#########################################################		
# 		#print "\t\t|der_phi_new| =", fabs(der_phi_new), " <= ", "-c2*der_phi_0 =", -c2*der_phi_0
# 		if der_phi_new >= c2*der_phi_0:
# 			#print "\t\twolfe M; WOLFE POINT FOUND! RETURN", alpha_new
# 			##sys.stdout.flush()
# 			return alpha_new
# 		#print "LS_M", ";", 5
# 		#sys.stdout.flush()
# 		if der_phi_new >= 0.0:
# 			#print "\t\twolfe_M; zoom 2, der_phi_new =", der_phi_new
# 			return zmwwb.zoom_M_wwb(alpha_new, phi_new, der_phi_new,
# 						alpha_old, phi_old, der_phi_old,
# 						phi_0, der_phi_0,
# 						c1, c2,
# 				 		m0, m, 
# 				 		C, C_lt0_data, C_lt0_indices, C_lt0_indptr,
# 						C_gt0_data, C_gt0_indices, C_gt0_indptr,
# 				 		x, r, 
# 						d, d_data, d_indices, d_indptr,
# 						grad, grad_data, grad_indices, grad_indptr,
# 						normConstant,  J, K, iterations[0])
			
# 		#print "LS_M", ";", 6
# 		#sys.stdout.flush()
# 		alpha_old = alpha_new
# 		alpha_new *= 5.0
# 		#print "\tALPHA_NEW =", alpha_new
# 		#alpha_old = alpha_tmp
# 		phi_old = phi_new
# 		der_phi_old = der_phi_new
		
# 		iterations[0] += 1
# 		#i += 1
# 	#print "failed search ; returning alpha_max =", alpha_max
# 	return alpha_max

# cdef FLOAT zoom_M_wwb(FLOAT alpha_lo, FLOAT phi_lo, FLOAT der_phi_lo,
# 				FLOAT alpha_hi, FLOAT phi_hi, FLOAT der_phi_hi,
# 				FLOAT phi_0, FLOAT der_phi_0,
# 				FLOAT c1, FLOAT c2,
# 				FLOAT* m0, FLOAT* m, #FLOAT* m_data, int* m_indices, int* m_indptr,
# 				FLOAT** C, FLOAT* C_lt0_data, int* C_lt0_indices, int* C_lt0_indptr,
# 				FLOAT* C_gt0_data, int* C_gt0_indices, int* C_gt0_indptr,
# 				FLOAT* x, FLOAT* r,
# 				FLOAT* d, FLOAT* d_data, int* d_indices, int* d_indptr,
# 				FLOAT* grad, FLOAT* grad_data, int* grad_indices, int* grad_indptr,
# 				FLOAT normConstant, int J, int K, int num_rounds)	:
# 
# 
# 	cdef FLOAT alpha_j, alpha_tmp, phi_j, der_phi_j, a, b, factor, sTy, yTy
# 	cdef FLOAT old_phi_j
# 	phi_j = phi_hi
# 	cdef INT n, h, k, j
# 	cdef INT N = K*J
# 	#cdef INT num_bisections = 0
# 	#cdef FLOAT delta = fabs(alpha_hi - alpha_lo)
# 	cdef FLOAT dalpha 
# 	cdef FLOAT numer, denom
# 	cdef int itr = 1
# 	cdef int maxitr = 15
# 	der_phi_j = 0.0
# 	alpha_j = 0.0
# 	#cdef FLOAT delta1 = 0.1 # ip.cubic interpolant check
# 	#cdef FLOAT delta2 = 0.05 # quadratic interpolant check
# 	cdef FLOAT alpha_0 = 0.0
# 	cdef FLOAT alpha_rec = alpha_0
# 	cdef FLOAT alpha_star # phi_star, der_phi_star, old_alpha_j
# 	cdef FLOAT phi_rec = phi_0
# 	#cdef FLOAT cchk, qchk
# 	#cdef FLOAT a_init
# # 	alpha_lo = alpha_0
# # 	phi_hi 
# # 	print "\t\tzoom C", "; der_phi_0 =", "{:.6f}".format(der_phi_0), 
# 	print "\t*** ZOOM C ***"
# 	print "\t\ta_lo =", "{:.4f}".format(alpha_lo), "; a_hi =", "{:.4f}".format(alpha_hi)
# 	print "\t\tphi_lo =", "{:.4f}".format(phi_lo), "; phi_hi =", "{:.4f}".format(phi_hi)
# 	print "\t\tder_phi_lo =", "{:.4f}".format(der_phi_lo), "; der_phi_hi =", "{:.4f}".format(der_phi_hi)
# 	print "\t\tphi_0 =", "{:.4f}".format(phi_0), "; der_phi_0 =", "{:.4f}".format(der_phi_0)
# 
# 	##sys.stdout.flush()
# 	##print "LS_C_Zoom", 10
# 	##sys.stdout.flush()
# 	if alpha_hi > alpha_lo:
# 		b = alpha_hi
# 		a = alpha_lo
# 	else: 
# 		b = alpha_lo
# 		a = alpha_hi
# 	alpha_star = a
# 	dalpha = b - a
# 	#old_alpha_j = alpha_j
# 	while dalpha > 0.0001 and itr < maxitr:
# 		print "  \t\titr", str(itr),
# 		#old_alpha_j = alpha_j
# 		if itr == 1:
# 	
# 			alpha_j = ip.quadratic_interpolate(phi_lo, der_phi_lo, alpha_hi, phi_hi)
# 			print "; quad (" + "{:.5f}".format(alpha_j) + ")",
# 			if (alpha_j == -1.0) or (alpha_j < a) or (alpha_j > b): 
# 			#if (alpha_j == -1.0): # or (alpha_j > b-qchk) or (alpha_j < a+qchk):
# 
# 				print "; bisect",	
# 				alpha_j = a + 0.5*(b-a)
# 				#print "; bisect (" + "{:.5f}".format(alpha_j) + ")",
# 					
# 		else:
# 			alpha_j = ip.cubicmin(alpha_lo, phi_lo, der_phi_lo, alpha_hi, 
# 								phi_hi, alpha_rec, phi_rec)
# 			print "; ip.cubic (" + "{:.5f}".format(alpha_j) + ")",
# 			if (alpha_j == -1.0) or (alpha_j < a) or (alpha_j > b):
# 				# or (alpha_j > b-cchk) or (alpha_j < a+cchk):
# 				#alpha_j = quadmin(alpha_lo, phi_lo, der_phi_lo, alpha_hi, phi_hi)
# 				alpha_j = ip.quadratic_interpolate(phi_lo, der_phi_lo, alpha_hi, phi_hi)
# 				print "; quad (" + "{:.5f}".format(alpha_j) + ")",
# 				if (alpha_j == -1.0) or (alpha_j < a) or (alpha_j > b): # 
# 				#if (alpha_j == -1.0): # or (alpha_j > b-qchk) or (alpha_j < a+qchk):
# 					print "; bisect",
# 					alpha_j = a + 0.5*(b-a)
# 
# 		if alpha_j == b or alpha_j == a: #or fabs(old_alpha_j - alpha_j) < 0.00001:
# 			alpha_star = alpha_j
# 			break			
# 		for h in range(d_indptr[1]):
# 			m[d_indices[h]] = m0[d_indices[h]] + alpha_j * d_data[h]
# 			# clip values to ensure that they stay within [0,1].
# 			if m[d_indices[h]] > 1.0:
# 				#print "  \t\tC[j][k] > 1.0", "; STOP" 
# 				m[d_indices[h]] = 1.0
# 				#return alpha_j
# 			elif m[d_indices[h]] < 0.0:
# 				#print "  \t\tC[j][k] < -1.0", "; STOP" 
# 				m[d_indices[h]] = 0.0
# 				#return alpha_j
# 				
# 		old_phi_j = phi_j
# 		if K > 1:
# 			phi_j = predict_wwb.r_e_and_grad_m(grad, m, 
# 						C, C_lt0_data, C_lt0_indices, C_lt0_indptr,
# 						C_gt0_data, C_gt0_indices, C_gt0_indptr,
# 						x, r, J, K, normConstant, eta)
# 		else:
# 			phi_j = predict_wwb.r_e_and_grad_m_one(grad,
# 						m, C, x, r, J, normConstant, eta)
# # 		print "\t\tphi_j = {:.7f}".format(phi_j)
# # 		print "\t\t{:.4f}".format(phi_j), ">", "{:.4f}".format(phi_0), "+", "{:.2f}".format(c1), "*", "{:.4f}".format(alpha_j), "*", "{:.5f}".format(der_phi_0), "?"
# # 		print "\t\t= {:.8f}".format(phi_j), ">", "{:.8f}".format(phi_0 + c1*alpha_j*der_phi_0), "?"
# # 		print "\t\told_phi_j =", "{:.7f}".format(old_phi_j) + ";",
# # 		print "old_phi_j - phi_j =", "{:.6f}".format(old_phi_j - phi_j), "\n"
# 		##print "LS_C_Zoom", "; Finished computing grad"
# 		##sys.stdout.flush()
# 
# 		if itr > 3 and old_phi_j - phi_j <= 0.0: #< 0.000000000001:
# 			if old_phi_j - phi_j < 0.0:
# 				print "\t\tInsufficient change in phi_j. alpha_star = alpha_lo. BREAK!"
# 				alpha_star = a
# 			else:
# 				print "\t\tInsufficient change in phi_j. alpha_star = alpha_j. BREAK!"
# 				alpha_star = a + 0.01*(alpha_j - a)
# 			break
# 		
# 		##sys.stdout.flush()
# 		##print "LS_C_Zoom", 50
# 		##sys.stdout.flush()
# 		if (phi_j > phi_0 + c1*alpha_j*der_phi_0) or (phi_j >= phi_lo):
# 			phi_rec = phi_hi
# 			alpha_rec = alpha_hi
# 			alpha_hi = alpha_j
# 			phi_hi = phi_j
# 		else:
# 			########################################################
# 			# Evaluate the gradient (i.e., phi prime) of the error function with respect
# 			## to alpha.
# 			der_phi_j = matmath_sparse.mul_1d_1d(grad_data, 
# 									grad_indices, grad_indptr,
# 									d_data, d_indices, d_indptr)
# 			#print "\t\t\t?? |der_phi_j| <= c2*|der_phi_0|",";",fabs(der_phi_j), "<=", c2, "*", fabs(der_phi_0)
# 			#########################################################
# 			##sys.stdout.flush()
# 			#print "LS_C_Zoom", 70
# 			##sys.stdout.flush()
# 			if der_phi_j >= c2*der_phi_0:
# 				return alpha_j
# 			if der_phi_j * (alpha_hi - alpha_lo) >= 0.0:
# 				#print "\t\t### zoom C;", "der_phi_j * (a_hi - a_lo)", ">=", der_phi_j * (alpha_hi - alpha_lo), ">= 0.0"
# 				#print "********* ping_1000! *********"
# 				phi_rec = phi_hi
# 				alpha_rec = alpha_hi
# 				alpha_hi = alpha_lo
# 				phi_hi = phi_lo
# 				der_phi_hi = der_phi_lo
# 			#print "********* ping_2222! *********"
# 			else:
# 				phi_rec = phi_lo
# 				alpha_rec = alpha_lo
# 			alpha_lo = alpha_j
# 			phi_lo = phi_j
# 			der_phi_lo = der_phi_j
# 		itr += 1
# 		num_rounds += 1
# 		#delta = fabs(alpha_hi - alpha_lo)
# # 		if itr >= maxitr:
# # 			alpha_star = 0.1*alpha_j #+ 0.1*fabs(alpha_j - alpha_lo)
# # 			break
# 		if alpha_hi >= alpha_lo:
# 			b = alpha_hi
# 			a = alpha_lo
# 		else:
# 			b = alpha_lo
# 			a = alpha_hi			
# 		dalpha = b - a
# 		alpha_star = a
# 
# 	print "\t\t***** Returning", alpha_star, " *****"
# 	return alpha_star
# 	
# 
# ###############################################################

# cdef FLOAT wolfe_C_wwb(FLOAT alpha_new, FLOAT alpha_max, FLOAT c1, FLOAT c2,
# 				FLOAT phi_0, FLOAT der_phi_0,
# 				FLOAT** C0, FLOAT** C, 
# 				FLOAT** M, FLOAT** X, FLOAT** R,
# 				FLOAT* d, FLOAT* d_data, int* d_indices, int* d_indptr,
# 				FLOAT** grad, FLOAT* vec_grad, 
# 				FLOAT* vec_grad_data, int* vec_grad_indices, int* vec_grad_indptr,
# 				FLOAT normConstant, int I, int K, int J, int* iterations):
	
# 	cdef INT N = K*J
# 	cdef INT n, h, k, j
# 	cdef bint computed_der_new = 0
# 	cdef FLOAT alpha_min = 0.0
# 	cdef FLOAT alpha_old = alpha_min
# 	cdef FLOAT phi_old, phi_new, der_phi_old, der_phi_new, factor, a, b
# 	phi_old = phi_0
# 	cdef FLOAT numer, denom
# 	iterations[0] = 1
# 	der_phi_old = der_phi_0
# 	der_phi_new = der_phi_old

# 	while alpha_new < alpha_max:
# 		print "\t\t** wolfe C itr", iterations[0], ";", "alpha_new =", alpha_new
# 		#print "\t\t** wolfe C itr", iterations[0], ";", "alpha_new =", alpha_new, ";",
# 		#sys.stdout.flush()
# 		for j in range(J):
# 			for k in range(K):
# 				C[j][k] = C0[j][k] + alpha_new * d[j*K + k]
# 				# clip values to ensure that they stay within [0,1].
# 				if C[j][k] > 1.0:
# 					C[j][k] = 1.0
# 					#print "  \t\tC[j][k] > 1.0;", "STOP"
# 					#return alpha_new
# 				elif C[j][k] < -1.0:
# 					C[j][k] = -1.0
# 					#print "  \t\tC[j][k] < -1.0;", "STOP"
# 					#return alpha_new
			
# 		#sp.compress_dbl_mat(C, C_data, C_indices, C_indptr, K, J)
# 		#matmath_nullptr.trans_2d(C, C_T, J, K)
# # 		predict_sp2.r_all_3(M_data, M_indices, M_indptr,
# # 							C_data, C_indices, C_indptr,
# # 							R, I, K, J, products)
# 		#sys.stdout.flush()
# 		#print "LS_C", 10
# 		#sys.stdout.flush()
# 		if K > 1:
# 			phi_new = predict_wwb.R_E_and_grad_C(grad,
# 						M, C, X, R, I, J, K, normConstant, eta)
# 		else:
# 			phi_new = predict_wwb.R_E_and_grad_C_one(grad,
# 						M, C, X, R, I, J, normConstant, eta)
# 		#print "LS_C", 12
# 		#sys.stdout.flush()
# 		if isNaN(phi_new):
# 			print "\n**************", "phi_new =", "NaN!!!!", "**************\n"
# 			return alpha_old
# 		matmath_nullptr.vec(grad, vec_grad, J, K)
# 		sp.compress_dbl_vec(vec_grad, vec_grad_data, vec_grad_indices, vec_grad_indptr, N)

# 		der_phi_new = matmath_sparse.mul_1d_1d(vec_grad_data, 
# 								vec_grad_indices, vec_grad_indptr,
# 								d_data, d_indices, d_indptr)
# 		if isNaN(der_phi_new):
# 			print "\n**************", "der_phi_new =", "NaN!!!!", "**************\n"
# 			return alpha_old								
# 		if phi_new > phi_0 + c1 * alpha_new * der_phi_0 or (phi_new >= phi_old and iterations[0] > 1):
# 			#sys.stdout.flush()
# 			##print "LS_C", 14
# 			#sys.stdout.flush()	
# 			print "   ZOOM 1!!!", "; phi_new =", phi_new, "; phi_0 etc =", phi_0 + c1 * alpha_new * der_phi_0, "; phi_old =", phi_old
# 			return zmwwb.zoom_C_wwb(alpha_old, phi_old, der_phi_old,
# 						alpha_new, phi_new, der_phi_new,
# 						phi_0, der_phi_0,
# 						c1, c2,
# 				 		C0, C, M, X, R,
# 						d, d_data, d_indices, d_indptr,
# 						grad, vec_grad, vec_grad_data, vec_grad_indices, vec_grad_indptr,
# 						normConstant,  I, K, J, iterations[0])
# 		########################################################
# 		# Evaluate the gradient (i.e., phi prime) of the error function with respect
# 		## to C.
# 		##sys.stdout.flush()
# 		##print "LS_C", 30
# 		##sys.stdout.flush()	
# 		#sp.compress_dbl_mat_col(C, C_T_data, C_T_indices, C_T_indptr, K, J)
# 		#matmath_nullptr.trans_2d(C, C_T, J, K)

# 		#######################################################
# 		#print "\t\t|der_phi_new| =", fabs(der_phi_new), " <= ", "-c2*der_phi_0 =", -c2*der_phi_0
# 		if der_phi_new >= c2*der_phi_0:
# 			#print "wolfe C; WOLFE POINT FOUND! RETURN", alpha_new
# 			print "\nWOLFE POINT FOUND! RETURN", alpha_new
# 			return alpha_new
# 		##sys.stdout.flush()
# 		##print "LS_C", 40
# 		##sys.stdout.flush()		
# 		if der_phi_new >= 0.0:
# 			#print "wolfe_C; zoom 2" #der_phi_new =", der_phi_new
# 			##sys.stdout.flush()
# 			print "   \nZOOM 2!!!"
# 			return zmwwb.zoom_C_wwb(alpha_new, phi_new, der_phi_new,
# 						alpha_old, phi_old, der_phi_old,
# 						phi_0, der_phi_0,
# 						c1, c2,
# 				 		C0, C, M, X, R,
# 						d, d_data, d_indices, d_indptr,
# 						grad, vec_grad, vec_grad_data, vec_grad_indices, vec_grad_indptr,
# 						normConstant,  I, K, J, iterations[0])
			
# 		alpha_old = alpha_new
# 		##sys.stdout.flush()
# 		##print "LS_C", 50
# 		##sys.stdout.flush()
# 		if alpha_new < 10.0:
# 			alpha_new *= 10.0
# 		else:
# 			alpha_new *= 5.0
# 		#print "wolfe C ; split alpha ; alpha_new =", alpha_new
# 		print "split alpha ; alpha_new =", alpha_new

# 		phi_old = phi_new
# 		der_phi_old = der_phi_new
		
# 		iterations[0] += 1
# 		#i += 1
# 	##sys.stdout.flush()
# 	print "failed search ; returning alpha_max =", alpha_max
# 	##sys.stdout.flush()
# 	return alpha_max

# cdef FLOAT zoom_C_wwb(FLOAT alpha_lo, FLOAT phi_lo, FLOAT der_phi_lo,
# 				FLOAT alpha_hi, FLOAT phi_hi, FLOAT der_phi_hi,
# 				FLOAT phi_0, FLOAT der_phi_0,
# 				FLOAT c1, FLOAT c2,
# 				FLOAT** C0, FLOAT** C,
# 				FLOAT** M, FLOAT** X, FLOAT** R,
# 				FLOAT* d, FLOAT* d_data, int* d_indices, int* d_indptr,
# 				FLOAT** grad, FLOAT* vec_grad, 
# 				FLOAT* vec_grad_data, int* vec_grad_indices, int* vec_grad_indptr,
# 				FLOAT normConstant, int I, int K, int J, int num_rounds):
# 	
# 	cdef FLOAT alpha_j, alpha_tmp, phi_j, der_phi_j, a, b, factor, sTy, yTy
# 	cdef FLOAT old_phi_j
# 	phi_j = phi_hi
# 	cdef INT n, h, k, j
# 	cdef INT N = K*J
# 	#cdef INT num_bisections = 0
# 	#cdef FLOAT delta = fabs(alpha_hi - alpha_lo)
# 	cdef FLOAT dalpha 
# 	cdef FLOAT numer, denom
# 	cdef int itr = 1
# 	cdef int maxitr = 15
# 	der_phi_j = 0.0
# 	alpha_j = 0.0
# 	#cdef FLOAT delta1 = 0.1 # ip.cubic interpolant check
# 	#cdef FLOAT delta2 = 0.05 # quadratic interpolant check
# 	cdef FLOAT alpha_0 = 0.0
# 	cdef FLOAT alpha_rec = alpha_0
# 	cdef FLOAT alpha_star # phi_star, der_phi_star, old_alpha_j
# 	cdef FLOAT phi_rec = phi_0
# 	#cdef FLOAT cchk, qchk
# 	#cdef FLOAT a_init
# # 	alpha_lo = alpha_0
# # 	phi_hi 
# # 	print "\t\tzoom C", "; der_phi_0 =", "{:.6f}".format(der_phi_0), 
# 	print "\t*** ZOOM C ***"
# 	print "\t\ta_lo =", "{:.4f}".format(alpha_lo), "; a_hi =", "{:.4f}".format(alpha_hi)
# 	print "\t\tphi_lo =", "{:.4f}".format(phi_lo), "; phi_hi =", "{:.4f}".format(phi_hi)
# 	print "\t\tder_phi_lo =", "{:.4f}".format(der_phi_lo), "; der_phi_hi =", "{:.4f}".format(der_phi_hi)
# 	print "\t\tphi_0 =", "{:.4f}".format(phi_0), "; der_phi_0 =", "{:.4f}".format(der_phi_0)
# 
# 	##sys.stdout.flush()
# 	##print "LS_C_Zoom", 10
# 	##sys.stdout.flush()
# 	if alpha_hi > alpha_lo:
# 		b = alpha_hi
# 		a = alpha_lo
# 	else: 
# 		b = alpha_lo
# 		a = alpha_hi
# 	alpha_star = a
# 	dalpha = b - a
# 	#old_alpha_j = alpha_j
# 	while dalpha > 0.0001 and itr < maxitr:
# 		print "  \t\titr", str(itr),
# 		#old_alpha_j = alpha_j
# 		if itr == 1:
# 	
# 			alpha_j = ip.quadratic_interpolate(phi_lo, der_phi_lo, alpha_hi, phi_hi)
# 			print "; quad (" + "{:.5f}".format(alpha_j) + ")",
# 			if (alpha_j == -1.0) or (alpha_j < a) or (alpha_j > b): 
# 			#if (alpha_j == -1.0): # or (alpha_j > b-qchk) or (alpha_j < a+qchk):
# 
# 				print "; bisect",	
# 				alpha_j = a + 0.5*(b-a)
# 				#print "; bisect (" + "{:.5f}".format(alpha_j) + ")",
# 					
# 		else:
# 			alpha_j = ip.cubicmin(alpha_lo, phi_lo, der_phi_lo, alpha_hi, 
# 								phi_hi, alpha_rec, phi_rec)
# 			print "; ip.cubic (" + "{:.5f}".format(alpha_j) + ")",
# 			if (alpha_j == -1.0) or (alpha_j < a) or (alpha_j > b):
# 				# or (alpha_j > b-cchk) or (alpha_j < a+cchk):
# 				#alpha_j = quadmin(alpha_lo, phi_lo, der_phi_lo, alpha_hi, phi_hi)
# 				alpha_j = ip.quadratic_interpolate(phi_lo, der_phi_lo, alpha_hi, phi_hi)
# 				print "; quad (" + "{:.5f}".format(alpha_j) + ")",
# 				if (alpha_j == -1.0) or (alpha_j < a) or (alpha_j > b): # 
# 				#if (alpha_j == -1.0): # or (alpha_j > b-qchk) or (alpha_j < a+qchk):
# 					print "; bisect",
# 					alpha_j = a + 0.5*(b-a)
# 		##sys.stdout.flush()
# 		##print "LS_C_Zoom", 35
# 		##sys.stdout.flush()
# 		print "; a_j =", "{:.4f}".format(alpha_j),
# 		print "from [{:.4f}".format(a) + ", {:.4f}".format(b) + "]"
# 
# 
# # 		if alpha_j - a_init < 0.001: #or fabs(alpha_j - old_alpha_j) < 0.0001:
# # 			alpha_star = alpha_j
# # 			break
# 		if alpha_j == b or alpha_j == a: #or fabs(old_alpha_j - alpha_j) < 0.00001:
# 			alpha_star = alpha_j
# 			print "\nalpha_j (", alpha_j, ")", "=", b, "or", a, "; BREAK!"
# 			break			
# 		for j in range(J):
# 			for k in range(K):
# 				C[j][k] = C0[j][k] + alpha_j * d[j*K + k]
# 				# clip values to ensure that they stay within [0,1].
# 				if C[j][k] > 1.0:
# 					#print "  \t\tC[j][k] > 1.0", "; STOP" 
# 					C[j][k] = 1.0
# 					#return alpha_j
# 				elif C[j][k] < -1.0:
# 					#print "  \t\tC[j][k] < -1.0", "; STOP" 
# 					C[j][k] = -1.0
# 					#return alpha_j
# 				
# 		old_phi_j = phi_j
# 		if K > 1:
# 			phi_j = predict_wwb.R_E_and_grad_C(grad,
# 						M, C, X, R, I, J, K, normConstant, eta)
# 		else:
# 			phi_j = predict_wwb.R_E_and_grad_C_one(grad,
# 						M, C, X, R, I, J, normConstant, eta)
# 		print "\t\tphi_j = {:.7f}".format(phi_j)
# 		print "\t\t{:.4f}".format(phi_j), ">", "{:.4f}".format(phi_0), "+", "{:.2f}".format(c1), "*", "{:.4f}".format(alpha_j), "*", "{:.5f}".format(der_phi_0), "?"
# 		print "\t\t= {:.8f}".format(phi_j), ">", "{:.8f}".format(phi_0 + c1*alpha_j*der_phi_0), "?"
# 		print "\t\told_phi_j =", "{:.7f}".format(old_phi_j) + ";",
# 		print "old_phi_j - phi_j =", "{:.6f}".format(old_phi_j - phi_j), "\n"
# 		##print "LS_C_Zoom", "; Finished computing grad"
# 		##sys.stdout.flush()
# 
# 		if itr > 3 and old_phi_j - phi_j <= 0.0: #< 0.000000000001:
# 			if old_phi_j - phi_j < 0.0:
# 				print "\t\tInsufficient change in phi_j. alpha_star = alpha_lo. BREAK!"
# 				alpha_star = a
# 			else:
# 				print "\t\tInsufficient change in phi_j. alpha_star = alpha_j. BREAK!"
# 				alpha_star = a + 0.01*(alpha_j - a)
# 			break
# 		
# 		##sys.stdout.flush()
# 		##print "LS_C_Zoom", 50
# 		##sys.stdout.flush()
# 		if (phi_j > phi_0 + c1*alpha_j*der_phi_0) or (phi_j >= phi_lo):
# 			phi_rec = phi_hi
# 			alpha_rec = alpha_hi
# 			alpha_hi = alpha_j
# 			phi_hi = phi_j
# 		else:
# 			########################################################
# 			# Evaluate the gradient (i.e., phi prime) of the error function with respect
# 			## to C.
# 			matmath_nullptr.vec(grad, vec_grad, J, K)
# 			sp.compress_dbl_vec(vec_grad, vec_grad_data, vec_grad_indices, vec_grad_indptr, N)
# 			der_phi_j = matmath_sparse.mul_1d_1d(vec_grad_data, 
# 									vec_grad_indices, vec_grad_indptr,
# 									d_data, d_indices, d_indptr)
# 			#print "\t\t\t?? |der_phi_j| <= c2*|der_phi_0|",";",fabs(der_phi_j), "<=", c2, "*", fabs(der_phi_0)
# 			#########################################################
# 			##sys.stdout.flush()
# 			#print "LS_C_Zoom", 70
# 			##sys.stdout.flush()
# 			if der_phi_j >= c2*der_phi_0:
# 				print "\t\t### zoom C;", fabs(der_phi_j), "<=", c2*fabs(der_phi_0), "WOLFE POINT FOUND!", "RETURN", alpha_j
# 				return alpha_j
# 			if der_phi_j * (alpha_hi - alpha_lo) >= 0.0:
# 				#print "\t\t### zoom C;", "der_phi_j * (a_hi - a_lo)", ">=", der_phi_j * (alpha_hi - alpha_lo), ">= 0.0"
# 				#print "********* ping_1000! *********"
# 				phi_rec = phi_hi
# 				alpha_rec = alpha_hi
# 				alpha_hi = alpha_lo
# 				phi_hi = phi_lo
# 				der_phi_hi = der_phi_lo
# 			#print "********* ping_2222! *********"
# 			else:
# 				phi_rec = phi_lo
# 				alpha_rec = alpha_lo
# 			alpha_lo = alpha_j
# 			phi_lo = phi_j
# 			der_phi_lo = der_phi_j
# 		itr += 1
# 		num_rounds += 1
# 		#delta = fabs(alpha_hi - alpha_lo)
# # 		if itr >= maxitr:
# # 			alpha_star = 0.1*alpha_j #+ 0.1*fabs(alpha_j - alpha_lo)
# # 			break
# 		if alpha_hi >= alpha_lo:
# 			b = alpha_hi
# 			a = alpha_lo
# 		else:
# 			b = alpha_lo
# 			a = alpha_hi			
# 		dalpha = b - a
# 		alpha_star = a
# 
# 	print "\t\t***** Returning", alpha_star, " *****"
# 	return alpha_star



# cdef FLOAT armijo_M(FLOAT a_new, FLOAT a_max, FLOAT c1,
# 							FLOAT phi_0, FLOAT der_phi_0,
# 							FLOAT* m0, FLOAT* m, 
# 							FLOAT** C, FLOAT* x, FLOAT* r,
# 							FLOAT* d, FLOAT* d_data, int* d_indices, int* d_indptr,
# 							FLOAT normConstant, int K, int J, int* itrs):
# 	itrs[0] = 0
# 	cdef FLOAT a_old = 0.0
# 	cdef int maxitr = 20
# 	cdef FLOAT phi_a_old = phi_0
# 	print "\n\t** Armijo linesearch M, INIT;", "a1 =", a_new, "f0 = {:.5f}".format(phi_0), "; der_phi_0 =", der_phi_0, "K =", K
# 	while itrs[0] < maxitr:
# 		itrs[0] += 1
# 		
# 
# 		for h in range(d_indptr[1]):
# 			m[d_indices[h]] = m0[d_indices[h]] + a_new * d_data[h]
# 			# clip values to ensure that they stay within [0,1].
# 			if m[d_indices[h]] > 1.0:
# 				m[d_indices[h]] = 1.0
# 			elif m[d_indices[h]] < 0.0:
# 				m[d_indices[h]] = 0.0
# 		
# 		if K > 1:
# 			phi_a_new = predict_wwb.r_and_e(C, m, x, r, J, K, normConstant, eta)
# 
# 		else:
# 			phi_a_new = predict_wwb.r_and_e_one(C, m, x, r, J, normConstant, eta)
# 		print "\t", "a_new =", itrs[0], ":", 
# 		print "f_new <= f0 + etc (", phi_a_new, "<=", phi_0 + c1 * a_new * der_phi_0,"); f_old =", phi_a_old
# 		sys.stdout.flush()
# # 		if phi_a_new <= phi_a_old and phi_a_new > phi_0 + c1 * a_new * der_phi_0:
# # 			a_old = a_new
# # 			a_new *= 2.0
# # 			continue
# 		
# 		if phi_a_new <= phi_0 + c1 * a_new * der_phi_0:
# 			print "\n************* WOLFE POINT FOUND (M)!!! *************\n"
# 			return a_new
# 		
# 		if phi_a_new > phi_0 + c1 * a_new * der_phi_0 or (phi_a_new >= phi_a_old and itrs[0] > 1):
# 			print "\t*** ZOOM M ***"
# 			return zm.armijo_zoom_M(a_old, phi_a_old,
# 									a_new, phi_a_new,
# 									phi_0, der_phi_0, c1, 
# 									m0, m, C, x, r,
# 									d, d_data, d_indices, d_indptr,
# 									normConstant,  K, J)
# 		phi_a_old = phi_a_new		
# 		a_old = a_new
# 		a_new *= 2.0
# 	return a_old


				
# 		return zm.armijo2_M_interpolate(a_new, phi_a_new,
# 				a_old, phi_a_old, phi_0, der_phi_0,
# 				c1, m0, m, C, x, r,
# 				d, d_data, d_indices, d_indptr,
# 				normConstant,  K, J)
				
# cdef FLOAT armijo_zoom_M(FLOAT a_old, FLOAT phi_a_old,
# 				FLOAT a_new, FLOAT phi_a_new,
# 				FLOAT phi_0, FLOAT der_phi_0,
# 				FLOAT c1,
# 				FLOAT* m0, FLOAT* m,
# 				FLOAT** C, FLOAT* x, FLOAT* r,
# 				FLOAT* d, FLOAT* d_data, int* d_indices, int* d_indptr,
# 				FLOAT normConstant, int K, int J):
# 	
# 	cdef FLOAT a_j = a_new
# 	cdef FLOAT phi_a_j = phi_a_new
# 	cdef FLOAT a_i = a_old
# 	cdef FLOAT phi_a_i = phi_a_old
# 	cdef INT h, k
# 	cdef FLOAT tau = (sqrt(5) - 1)/2.0
# 	cdef int itr = 1
# 	cdef int maxitr = 15
# 	print "\t", "Armijo Zoom M!", "f0 =", "{:.5f}".format(phi_0)
# 	while fabs(a_j - a_i) > 0.0001 and itr < maxitr:
# # 		if itr == 1:
# # 			a_j = a_lo + 0.5*fabs(a_hi - a_lo)
# # 		else:
# 		print "\t\t",
# 		if itr == 1:
# 			print "(quad)",
# 			a_j = ip.quadratic_interpolate(phi_0, der_phi_0, a_j, phi_a_j)
# 		else:
# 			print "(ip.cubic)",
# 			a_j = ip.cubic(phi_0, der_phi_0, phi_a_i, a_i, phi_a_j, a_j)
# 		if a_j == -1:
# 			a_j = a_i + tau*fabs(a_j - a_i)
# 			print "(bisect)",
# 		print "a_j =", "{:.4f}".format(a_j), "<- [{:.4f}".format(a_i) + ", " + "{:.4f}".format(a_j) + "]",	
# 
# 		for h in range(d_indptr[1]):
# 			m[d_indices[h]] = m0[d_indices[h]] + a_j * d_data[h]
# 			# clip values to ensure that they stay within [0,1].
# 			if m[d_indices[h]] > 1.0:
# 				m[d_indices[h]] = 1.0
# 			elif m[d_indices[h]] < 0.0:
# 				m[d_indices[h]] = 0.0
# 		
# 		if K > 1:
# 			phi_a_j = predict_wwb.r_and_e(C, m, x, r, J, K, normConstant, eta)
# 		else:
# 			phi_a_j = predict_wwb.r_and_e_one(C, m, x, r, J, normConstant, eta)
# 		print "\tf_aj - f0+etc =", (phi_a_j - (phi_0 + c1 * a_j * der_phi_0)), "; f_ai =", phi_a_i
# 		if phi_a_j <= phi_0 + c1 * a_j * der_phi_0:
# 			# a_j satisfies the Armijo condition
# 			print "\n************* WOLFE POINT FOUND (zoom M)!!! *************\n"
# 			return a_j
# 
# 			
# # 		if (phi_a_j > phi_0 + c1 * a_j * der_phi_0) or (phi_a_j >= phi_a_lo):
# # 			# Here, a_j is too large, since phi_cur is now increasing rather
# # 			# than decreasing
# # 			# We shorten the interval [alpha_lo, alpha_hi] by trimming off the high
# # 			# end. We make a_j the new alpha_hi, since the Armijo point must be
# # 			# less than a_j, but at the same time greater than alpha_lo.
# 		a_i = a_j
# 		phi_a_i = phi_a_j
# 		itr += 1
# 	return 0.1*a_j
	
	
# cdef FLOAT armijo_C(FLOAT a_new, FLOAT a_max, FLOAT c1,
# 							FLOAT phi_0, FLOAT der_phi_0,
# 							FLOAT** C0, FLOAT** C, 
# 							FLOAT** M, FLOAT** X, FLOAT** R,
# 							FLOAT* d, FLOAT* d_data, int* d_indices, int* d_indptr, 
# 							FLOAT normConstant, 
# 							int I, int K, int J, int* itrs):
# 	itrs[0] = 0
# 	cdef int maxitr = 20
# 	cdef FLOAT a_old = 0.0
# 	cdef FLOAT phi_a_new = phi_0
# 	cdef FLOAT phi_a_old = phi_0
# 	cdef INT k, j
# 	print "\t\t** Armijo linesearch C itr", itrs[0], ";", "alpha =", a_new, "K =", K
# 	sys.stdout.flush()
# 	while itrs[0] < maxitr:
# 		itrs[0] += 1
# 		for j in range(J):
# 			for k in range(K):
# 				C[j][k] = C0[j][k] + a_new * d[j*K + k]
# 				# clip values to ensure that they stay within [0,1].
# 				if C[j][k] > 1.0:
# 					C[j][k] = 1.0
# 				elif C[j][k] < -1.0:
# 					C[j][k] = -1.0
# 		
# 
# 		if K > 1:
# 			phi_a_new = predict_wwb.R_and_E(M, C, X, R, I, J, K, normConstant, eta)
# 		else:
# 			phi_a_new = predict_wwb.R_and_E_one(M, C, X, R, I, J, normConstant, eta)
# 
# 		print "\t", itrs[0], ":", 
# 		print "f_new <= f0 + etc (", phi_a_new, "<=", phi_0 + c1 * a_new * der_phi_0, "); f_old =", phi_a_old			
# # 		if phi_a_new <= phi_0 + c1 * a_new * der_phi_0:
# # 			# a_j satisfies the Armijo condition
# # 			print "\treturn a =", "{:.4f}".format(a_new)
# # 			return a_new
# 		
# # 		if phi_a_new <= phi_a_old and phi_a_new > phi_0 + c1 * a_new * der_phi_0:
# # 			a_old = a_new
# # 			a_new *= 2.0
# # 			continue
# 		
# 		if phi_a_new <= phi_0 + c1 * a_new * der_phi_0:
# 			print "\n\t************* WOLFE POINT FOUND (C)!!! *************\n"
# 			return a_new
# 		
# 		if phi_a_new > phi_0 + c1*a_new*der_phi_0 or (phi_a_new >= phi_a_old and itrs[0] > 1):
# 			print "\t*** ZOOM C ***"
# 			return zm.armijo_zoom_C(a_old, phi_a_old,
# 									a_new, phi_a_new, 
# 									phi_0, der_phi_0, c1, 
# 									C0, C, M, X, R,
# 									d, d_data, d_indices, d_indptr,
# 									normConstant,  I, K, J)
# 		phi_a_old = phi_a_new
# 		a_old = a_new
# 		a_new *= 2.0
# 	print "\n"
# 	return 0.1*a_new


# cdef FLOAT goldstein_armijo_M(FLOAT alpha0, 
# 					FLOAT phi_0, FLOAT der_phi_0,
# 					FLOAT c1, FLOAT c2,
# 					FLOAT* m0, FLOAT* m,
# 					FLOAT** C, FLOAT* x, FLOAT* r,
# 					FLOAT* d, FLOAT* d_data, int* d_indices, int* d_indptr,
# 					FLOAT normConstant, int K, int J, int* itrs):
# 	cdef int k, j, h
# 	cdef FLOAT alpha = alpha0
# 	cdef FLOAT phi_alpha
# 	itrs[0] = 0
# 	cdef int maxitr = 20
# 	cdef FLOAT rho1 = 1.0 - (sqrt(5) - 1)/2.0
# 	cdef FLOAT rho2 = 2.0
# 	c1 = 0.05
# 	c2 = 0.9
# 	# the idea is that with every step, the error (function value) decreases.
# 	while itrs[0] < maxitr:
# 		itrs[0] += 1	
# 		for h in range(d_indptr[1]):
# 			m[d_indices[h]] = m0[d_indices[h]] + alpha * d_data[h]
# 			# clip values to ensure that they stay within [0,1].
# 			if m[d_indices[h]] > 1.0:
# 				m[d_indices[h]] = 1.0
# 			elif m[d_indices[h]] < 0.0:
# 				m[d_indices[h]] = 0.0
# 		if K > 1:
# 			phi_alpha = predict_wwb.r_and_e(C, m, x, r, J, K, normConstant, eta)
# 		else:
# 			phi_alpha = predict_wwb.r_and_e_one(C, m, x, r, J, normConstant, eta)
# 		# grad_test
# 		# if alpha evades the following two conditions, the loop breaks,
# 		# and alpha is returned as THE alpha.
# 		if -alpha * c1 * der_phi_0 > phi_0 - phi_alpha:
# 			#count_dec += 1
# 			#itrs[0] += 1
# 			alpha = rho1 * alpha
# 			continue
		
# 		if phi_0 - phi_alpha > -alpha * c2 * der_phi_0:
# 			#count_inc += 1
# 			#itrs[0] += 1
# 			alpha = rho2 * alpha
# 			continue
# 		print "\t\tSuccess! a =", "{:.6f}".format(alpha) + ";", "phi =", "{:.6f}".format(phi_alpha) + " <= {:.6}".format(phi_0 + alpha * c1 * der_phi_0), "itrs: " + str(itrs[0])
# 		return alpha
		
# cdef FLOAT goldstein_armijo_C(FLOAT alpha0, FLOAT phi_0, FLOAT der_phi_0,
# 					FLOAT c1, FLOAT c2,
# 					FLOAT** C0, FLOAT** C,
# 					FLOAT** M, FLOAT** X, FLOAT** R,
# 					FLOAT* d, FLOAT normConstant, 
# 					int I, int K, int J, int* itrs):
# 	cdef int k, j #, count_dec, count_inc
# 	cdef FLOAT alpha = alpha0
# 	cdef FLOAT phi_alpha = phi_0
# 	#cdef FLOAT rho1, rho2
# 	cdef int maxitr = 20
# 	cdef FLOAT rho1 = 0.1
# 	cdef FLOAT rho2 = 5.0
# 	itrs[0] = 0
# 	c1 = 0.000001
# 	c2 = 0.9
# 	print "\t\t\ta " + str(itrs[0]), "; {:.6f}".format(alpha) + ";", "phi =", "{:.6f}".format(phi_alpha) + " <= {:.6}".format(phi_0 + alpha * c1 * der_phi_0)
# 	while itrs[0] < maxitr and alpha > 0.0000001:
# 		for j in range(J):
# 			for k in range(K):
# 				##print "alpha*d[j*K + k] =", alpha*d[j*K + k]
# 				C[j][k] = C0[k][j] + alpha * d[j*K + k]
# 				# clip values to ensure that they stay within [0,1].
# 				if C[j][k] > 1.0:
# 					C[j][k] = 1.0
# 				elif C[j][k] < -1.0:
# 					C[j][k] = -1.0
# 		if K > 1:
# 			phi_alpha = predict_wwb.R_and_E(M, C, X, R, I, J, K, normConstant, eta)
# 		else:
# 			phi_alpha = predict_wwb.R_and_E_one(M, C, X, R, I, J, normConstant, eta)
# 		# grad_test
# 		##print "-alpha * mu1 * der_phi_0 =", -alpha * mu1 * der_phi_0
# 		# if alpha evades the following two conditions, the loop breaks,
# 		# and alpha is returned as THE alpha.
# 		print "\t\t\ta " + str(itrs[0]) + " =", "{:.6f}".format(alpha) + ";", "phi =", "{:.6f}".format(phi_alpha) + " <= {:.6}".format(phi_0 + alpha * c1 * der_phi_0), "itrs: " + str(itrs[0]), "&& {:.6}".format(-alpha * c1 * der_phi_0), "< {:.6}".format(phi_0 - phi_alpha), "< {:.6}".format(-alpha * c2 * der_phi_0)
# # 		if -alpha * c1 * der_phi_0 <= (phi_0 - phi_alpha) <= -alpha * c2 * der_phi_0 and alpha > 0.0:
# # 			return alpha
# 		if -alpha * c1 * der_phi_0 > phi_0 - phi_alpha:
# 			#count_dec += 1
# 			alpha = rho1 * alpha
# 			itrs[0] += 1
# # 			print "\t\t\ta =", "{:.6f}".format(alpha) + ";", "phi =", "{:.6f}".format(phi_alpha) + " <= {:.6}".format(phi_0 + alpha * c1 * der_phi_0), "itrs: " + str(itrs[0])
# 			continue
		
# 		if phi_0 - phi_alpha > -alpha * c2 * der_phi_0:
# 			#count_inc += 1
# 			alpha = rho2 * alpha
# 			itrs[0] += 1
# # 			print "\t\t\ta =", "{:.6f}".format(alpha) + ";", "phi =", "{:.6f}".format(phi_alpha) + " <= {:.6}".format(phi_0 + alpha * c1 * der_phi_0), "itrs: " + str(itrs[0])
# 			continue
# 		print "\t\tSuccess! a =", "{:.6f}".format(alpha) + ";", "phi =", "{:.6f}".format(phi_alpha) + "<= {:.6}".format(phi_0 + alpha * c1 * der_phi_0), "itrs: " + str(itrs[0])
# 		return alpha
		
cdef FLOAT armijo2_M_nor(FLOAT a_new, FLOAT a_max, FLOAT c1,
							FLOAT phi_0, FLOAT der_phi_0,
							FLOAT* m0, FLOAT* m, 
							FLOAT** C, 
							FLOAT* C_data, int* C_indices, int* C_indptr,
							FLOAT* x, FLOAT* r,
							FLOAT* d, FLOAT* d_data, int* d_indices, int* d_indptr,
							FLOAT normConstant, 
							int K, int J, int* itrs,
							FLOAT lowerBound, FLOAT upperBound):
	itrs[0] = 0
	cdef int maxitr = 10
	cdef FLOAT phi_a_new = phi_0
	cdef FLOAT a_old = 0.0
	cdef FLOAT phi_a_old = phi_0
	cdef int h, k, j
	#print "\t\t** Armijo linesearch 2 M itr", itrs[0], ";", "alpha =", a_new, "K =", K
	#sys.stdout.flush()

	for h in range(d_indptr[1]):
		m[d_indices[h]] = m0[d_indices[h]] + a_new * d_data[h]
		# clip values to ensure that they stay within [0,1].
		if m[d_indices[h]] > upperBound:
			m[d_indices[h]] = upperBound
		elif m[d_indices[h]] < lowerBound:
			m[d_indices[h]] = lowerBound

	phi_a_new = predict.get_r_and_e_omp(r, m, 
					C_data, C_indices, C_indptr,
					x, J, K, normConstant)
					
	if phi_a_new <= phi_0 + c1 * a_new * der_phi_0: # or (phi_a_new < phi_a_old):

		return zmnor.armijo2_M_increase_alpha_nor(a_new, phi_a_new,
				a_old, phi_a_old,	
				phi_0, der_phi_0,
				c1, m0, m, C, 
				C_data, C_indices, C_indptr,
				x, r,
				d, d_data, d_indices, d_indptr,
				normConstant, K, J,
				lowerBound, upperBound)

	if phi_a_new > phi_0 + c1 * a_new * der_phi_0: # or (phi_a_new >= phi_a_old):
		return zmnor.armijo2_M_interpolate_nor(a_new, phi_a_new,
				a_old, phi_a_old, phi_0, der_phi_0,
				c1, m0, m, C, 
				C_data, C_indices, C_indptr,
				x, r,
				d, d_data, d_indices, d_indptr,
				normConstant, K, J,
				lowerBound, upperBound)


cdef FLOAT armijo2_C_nor(FLOAT a_new, FLOAT a_max, FLOAT c1,
							FLOAT phi_0, FLOAT der_phi_0,
							FLOAT** C0, FLOAT** C, 
							FLOAT** M,
							FLOAT* M_data, int* M_indices, int* M_indptr,
							FLOAT** X, FLOAT** R,
							FLOAT* d, FLOAT* d_data, int* d_indices, int* d_indptr, 
							FLOAT normConstant, 
							int I, int K, int J, int* itrs, 
							FLOAT lowerBound, FLOAT upperBound):
	itrs[0] = 0
	#cdef int maxitr = 20
	cdef FLOAT phi_a_new = phi_0
	cdef FLOAT a_old = 0.0
	cdef FLOAT phi_a_old = phi_0
	cdef INT k, j
	print "\t\t** Armijo linesearch 2 C itr", itrs[0], ";", "init a =", a_new, "K =", K
	sys.stdout.flush()
	for j in range(J):
		for k in range(K):
			print "C[", j, ",", k, "] =", C0[j][k], "+", a_new, "&*&", d[j*K + k], " ",
			sys.stdout.flush()
			C[j][k] = C0[j][k] + a_new * d[j*K + k]
			# clip values to ensure that they stay within [0,1].
			print "***C[", j, ",", k, "] "
			sys.stdout.flush()
			if C[j][k] > upperBound:
				C[j][k] = upperBound
			elif C[j][k] < lowerBound:
				C[j][k] = lowerBound
	print "\n\narmijo2_C_nor", 2
	sys.stdout.flush()
	# phi_a_new = predict.get_R_and_E_omp(R,
	# 			M_data, M_indices, M_indptr,
	# 			C, X, I, J, K,
	# 			normConstant)
	phi_a_new = predict.get_R_and_E_nsp_omp(R, M, C, X, I, J, K, normConstant)
	print "armijo2_C_nor", 3
	sys.stdout.flush()		
	if phi_a_new <= phi_0 + c1 * a_new * der_phi_0: # or (phi_a_old > phi_a_new):
		print "armijo2_C_nor", 4
		sys.stdout.flush()
		return zmnor.armijo2_C_increase_alpha_nor(a_new, phi_a_new, 
				a_old, phi_a_old,
				phi_0, der_phi_0,
				c1, C0, C, 
				M, M_data, M_indices, M_indptr, 
				X, R,
				d, d_data, d_indices, d_indptr,
				normConstant, I, K, J,
				lowerBound, upperBound)
	
	#elif phi_a_new > phi_0 + c1 * a_new * der_phi_0: # or (phi_a_new >= phi_a_old):
	print "armijo2_C_nor", 5
	sys.stdout.flush()
	return zmnor.armijo2_C_interpolate_nor(a_new, phi_a_new,
			a_old, phi_a_old,
			phi_0, der_phi_0,
			c1, C0, C, 
			M, M_data, M_indices, M_indptr, 
			X, R,
			d, d_data, d_indices, d_indptr,
			normConstant, I, K, J,
			lowerBound, upperBound)
