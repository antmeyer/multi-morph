#cython: profile=True
#cython: boundscheck=False
#cython: wraparound=False
#cython: cdivision=True
import sys

cdef bint isNaN(FLOAT x):
	return x != x 

cdef FLOAT zoom_M_nor(FLOAT alpha_lo, FLOAT phi_lo, FLOAT der_phi_lo,
				FLOAT alpha_hi, FLOAT phi_hi, FLOAT der_phi_hi,
				FLOAT phi_0, FLOAT der_phi_0,
				FLOAT c1, FLOAT c2,
				FLOAT* m0, FLOAT* m,
				FLOAT** C,FLOAT* C_data, int* C_indices, int* C_indptr,
				FLOAT* x, FLOAT* r,
				FLOAT* d, FLOAT* d_data, int* d_indices, int* d_indptr,
				FLOAT* grad, 
				FLOAT* grad_data, int* grad_indices, int* grad_indptr,
				FLOAT normConstant, int K, int J, int num_rounds,
				FLOAT l, FLOAT u):
	
	cdef FLOAT alpha_j, alpha_tmp, phi_j, der_phi_j, a, b, factor, sTy, yTy
	cdef FLOAT old_phi_j
	phi_j = 0.0
	cdef INT n, h, k, j
	cdef INT N = J*K
	cdef FLOAT dalpha 
	cdef FLOAT numer, denom
	cdef int itr = 1
	cdef int maxitr = 15
	der_phi_j= 0.0
	alpha_j = 0.0
	#cdef FLOAT delta1 = 0.1 # ip.cubic interpolant check
	#cdef FLOAT delta2 = 0.05 # quadratic interpolant check
	cdef FLOAT alpha_0 = 0.0
	cdef FLOAT alpha_rec = alpha_0
	cdef FLOAT alpha_star # phi_star, der_phi_star, old_alpha_j
	cdef FLOAT phi_rec = phi_0
	#cdef FLOAT cchk, qchk
	#cdef FLOAT a_init
# 	alpha_lo = alpha_0
# 	phi_hi 
# 	print "\t\tzoom C", "; der_phi_0 =", "{:.6f}".format(der_phi_0), 
# 	print "\t*** ZOOM M ***"
# 	print "\t\ta_lo =", "{:.4f}".format(alpha_lo), "; a_hi =", "{:.4f}".format(alpha_hi)
# 	print "\t\tphi_lo =", "{:.4f}".format(phi_lo), "; phi_hi =", "{:.4f}".format(phi_hi)
# 	print "\t\tder_phi_lo =", "{:.4f}".format(der_phi_lo), "; der_phi_hi =", "{:.4f}".format(der_phi_hi)
# 	print "\t\tphi_0 =", "{:.4f}".format(phi_0), "; der_phi_0 =", "{:.4f}".format(der_phi_0)

	###sys.stdout.flush()
	#print "ZM M;", 02
	#sys.stdout.flush()
	if alpha_hi > alpha_lo:
		b = alpha_hi
		a = alpha_lo
	else: 
		b = alpha_lo
		a = alpha_hi
	alpha_star = a
	dalpha = b - a
	#print "ZM M;", 10
	#sys.stdout.flush()
	#old_alpha_j = alpha_j
	while dalpha > 0.0001 and itr < maxitr:
		print "  \t\titr", str(itr),
		#old_alpha_j = alpha_j
		if itr == 1:
			#print "ZM M;", 12
			#sys.stdout.flush()
			alpha_j = ip.quadratic_interpolate(phi_lo, der_phi_lo, alpha_hi, phi_hi)
			print "; quad (" + "{:.5f}".format(alpha_j) + ")",
			if (alpha_j == -1.0) or (alpha_j < a) or (alpha_j > b): 
			#if (alpha_j == -1.0): # or (alpha_j > b-qchk) or (alpha_j < a+qchk):

				print "; bisect",	
				alpha_j = a + 0.5*(b-a)
				#print "; bisect (" + "{:.5f}".format(alpha_j) + ")",					
		else:
			#print "ZM M;", 25
			#sys.stdout.flush()	
			alpha_j = ip.cubicmin(alpha_lo, phi_lo, der_phi_lo, alpha_hi, 
								phi_hi, alpha_rec, phi_rec)
			print "; ip.cubic (" + "{:.5f}".format(alpha_j) + ")",
			if (alpha_j == -1.0) or (alpha_j < a) or (alpha_j > b):
				# or (alpha_j > b-cchk) or (alpha_j < a+cchk):
				#alpha_j = quadmin(alpha_lo, phi_lo, der_phi_lo, alpha_hi, phi_hi)
				alpha_j = ip.quadratic_interpolate(phi_lo, der_phi_lo, alpha_hi, phi_hi)
				print "; quad (" + "{:.5f}".format(alpha_j) + ")",
				if (alpha_j == -1.0) or (alpha_j < a) or (alpha_j > b): # 
				#if (alpha_j == -1.0): # or (alpha_j > b-qchk) or (alpha_j < a+qchk):
					print "; bisect",
					alpha_j = a + 0.5*(b-a)
		if alpha_j == b or alpha_j == a: #or fabs(old_alpha_j - alpha_j) < 0.00001:
			alpha_star = alpha_j
			break			
		for h in range(d_indptr[1]):
			m[d_indices[h]] = m0[d_indices[h]] + alpha_j * d_data[h]
			# clip values to ensure that they stay within [0,1].
			if m[d_indices[h]] > u:
				#print "  \t\tC[j][k] > u", "; STOP" 
				m[d_indices[h]] = u
				#return alpha_j
			elif m[d_indices[h]] < l:
				#print "  \t\tC[j][k] < l", "; STOP" 
				m[d_indices[h]]= l
				#return alpha_j
		#print "ZM M;", "\t\talpha_j =", alpha_j, "<- [", a, ",", b, "]"
		#sys.stdout.flush()
		old_phi_j = phi_j
		# if K > 1:
		# 	phi_j = predict.get_r_e_and_grad_m(grad, m,
		# 				C, C_data, C_indices, C_indptr,
		# 				x, r, phi_j, J, K, normConstant)
		# else:
		# 	phi_j = predict.get_r_e_and_grad_m_one(grad, m, C, x, r, phi_j, J, normConstant)

		phi_j = predict.get_r_e_and_grad_m_nsp_omp(grad, m, C, x, r, J, K, normConstant)		
		#print "ZM M;", 54
		#sys.stdout.flush()
# 		print "\t\tphi_j = {:.7f}".format(phi_j)
# 		print "\t\t{:.4f}".format(phi_j), ">", "{:.4f}".format(phi_0), "+", "{:.2f}".format(c1), "*", "{:.4f}".format(alpha_j), "*", "{:.5f}".format(der_phi_0), "?"
# 		print "\t\t= {:.8f}".format(phi_j), ">", "{:.8f}".format(phi_0 + c1*alpha_j*der_phi_0), "?"
# 		print "\t\told_phi_j =", "{:.7f}".format(old_phi_j) + ";",
# 		print "old_phi_j - phi_j =", "{:.6f}".format(old_phi_j - phi_j), "\n"
		##print "LS_M_Zoom", "; Finished computing grad"
		###sys.stdout.flush()

		if itr > 3 and old_phi_j - phi_j <= 0.0: #< 0.000000000001:
			if old_phi_j - phi_j < 0.0:
				#print "\t\tInsufficient change in phi_j. alpha_star = alpha_lo. BREAK!"
				alpha_star = a
			else:
				#print "\t\tInsufficient change in phi_j. alpha_star = alpha_j. BREAK!"
				alpha_star = a + 0.01*(alpha_j - a)
			break
		
		##sys.stdout.flush()
		##print "LS_C_Zoom", 50
		##sys.stdout.flush()
		if (phi_j > phi_0 + c1*alpha_j*der_phi_0) or (phi_j >= phi_lo):
			phi_rec = phi_hi
			alpha_rec = alpha_hi
			alpha_hi = alpha_j
			phi_hi = phi_j
			#print "ZM M;", 38
			#sys.stdout.flush()
		else:
			########################################################
			# Evaluate the gradient (i.e., phi prime) of the error function with respect
			## to C.
			der_phi_j= matmath_sparse.mul_1d_1d(grad_data, 
									grad_indices, grad_indptr,
									d_data, d_indices, d_indptr)
			#print "\t\t\t?? |der_phi_j| <= c2*|der_phi_0|",";",fabs(der_phi_j), "<=", c2, "*", fabs(der_phi_0)
			#print "ZM M;", 60
			#sys.stdout.flush()
			#########################################################
			if der_phi_j >= c2*der_phi_0:
				return alpha_j
			if der_phi_j* (alpha_hi - alpha_lo) >= 0.0:
				#print "\t\t### zoom C;", "der_phi_j* (a_hi - a_lo)", ">=", der_phi_j* (alpha_hi - alpha_lo), ">= 0.0"
				#print "********* ping_1000! *********"
				phi_rec = phi_hi
				alpha_rec = alpha_hi
				alpha_hi = alpha_lo
				phi_hi = phi_lo
				der_phi_hi = der_phi_lo
				#print "ZM M;", 68
				#sys.stdout.flush()
			else:
				phi_rec = phi_lo
				alpha_rec = alpha_lo
				#print "ZM M;", 72
				#sys.stdout.flush()
			alpha_lo = alpha_j
			phi_lo = phi_j
			der_phi_lo = der_phi_j
			#print "ZM M;", 75
			#sys.stdout.flush()
		itr += 1
		num_rounds += 1
		#delta = fabs(alpha_hi - alpha_lo)
		if alpha_hi >= alpha_lo:
			b = alpha_hi
			a = alpha_lo
		else:
			b = alpha_lo
			a = alpha_hi			
		dalpha = b - a
		alpha_star = a
		#print "ZM M;", 80
		#sys.stdout.flush()
	print "\t\t***** Returning", alpha_star, " *****"
	return alpha_star
	
	
cdef FLOAT zoom_C_nor(FLOAT alpha_lo, FLOAT phi_lo, FLOAT der_phi_lo,
				FLOAT alpha_hi, FLOAT phi_hi, FLOAT der_phi_hi,
				FLOAT phi_0, FLOAT der_phi_0,
				FLOAT c1, FLOAT c2,
				FLOAT** C0, FLOAT** C,
				FLOAT** M, FLOAT** X, FLOAT** R,
				FLOAT* d, FLOAT* d_data, int* d_indices, int* d_indptr,
				FLOAT** grad, FLOAT* vec_grad, 
				FLOAT* vec_grad_data, int* vec_grad_indices, int* vec_grad_indptr,
				FLOAT normConstant, int I, int K, int J, int num_rounds,
				FLOAT l, FLOAT u):
	
	cdef FLOAT alpha_j, alpha_tmp, phi_j, der_phi_j, a, b, factor, sTy, yTy
	cdef FLOAT old_phi_j
	phi_j = phi_hi
	#cdef FLOAT* phi_j = &phi_j 
	cdef INT n, h, k, j
	cdef INT N = K*J
	#cdef INT num_bisections = 0
	#cdef FLOAT delta = fabs(alpha_hi - alpha_lo)
	cdef FLOAT dalpha 
	cdef FLOAT numer, denom
	cdef int itr = 1
	cdef int maxitr = 15
	der_phi_j = 0.0
	alpha_j = 0.0
	cdef FLOAT alpha_0 = 0.0
	cdef FLOAT alpha_rec = alpha_0
	cdef FLOAT alpha_star # phi_star, der_phi_star, old_alpha_j
	cdef FLOAT phi_rec = phi_0
	print "\t*** ZOOM C ***"
	print "\t\ta_lo =", "{:.4f}".format(alpha_lo), "; a_hi =", "{:.4f}".format(alpha_hi)
	print "\t\tphi_lo =", "{:.4f}".format(phi_lo), "; phi_hi =", "{:.4f}".format(phi_hi)
	print "\t\tder_phi_lo =", "{:.4f}".format(der_phi_lo), "; der_phi_hi =", "{:.4f}".format(der_phi_hi)
	print "\t\tphi_0 =", "{:.4f}".format(phi_0), "; der_phi_0 =", "{:.4f}".format(der_phi_0)

	if alpha_hi > alpha_lo:
		b = alpha_hi
		a = alpha_lo
	else: 
		b = alpha_lo
		a = alpha_hi
	alpha_star = a
	dalpha = b - a
	#old_alpha_j = alpha_j
	while dalpha > 0.0001 and itr < maxitr:
		print "  \t\titr", str(itr),
		#old_alpha_j = alpha_j
		if itr == 1:
	
			alpha_j = ip.quadratic_interpolate(phi_lo, der_phi_lo, alpha_hi, phi_hi)
			print "; quad (" + "{:.5f}".format(alpha_j) + ")",
			if (alpha_j == -1.0) or (alpha_j < a) or (alpha_j > b): 
			#if (alpha_j == -1.0): # or (alpha_j > b-qchk) or (alpha_j < a+qchk):

				print "; bisect",	
				alpha_j = a + 0.5*(b-a)
				#print "; bisect (" + "{:.5f}".format(alpha_j) + ")",
					
		else:
			alpha_j = ip.cubicmin(alpha_lo, phi_lo, der_phi_lo, alpha_hi, 
								phi_hi, alpha_rec, phi_rec)
			print "; ip.cubic (" + "{:.5f}".format(alpha_j) + ")",
			if (alpha_j == -1.0) or (alpha_j < a) or (alpha_j > b):
				# or (alpha_j > b-cchk) or (alpha_j < a+cchk):
				#alpha_j = quadmin(alpha_lo, phi_lo, der_phi_lo, alpha_hi, phi_hi)
				alpha_j = ip.quadratic_interpolate(phi_lo, der_phi_lo, alpha_hi, phi_hi)
				print "; quad (" + "{:.5f}".format(alpha_j) + ")",
				if (alpha_j == -1.0) or (alpha_j < a) or (alpha_j > b): # 
				#if (alpha_j == -1.0): # or (alpha_j > b-qchk) or (alpha_j < a+qchk):
					print "; bisect",
					alpha_j = a + 0.5*(b-a)
		###sys.stdout.flush()
		##print "LS_C_Zoom", 35
		###sys.stdout.flush()
		print "; a_j =", "{:.4f}".format(alpha_j),
		print "from [{:.4f}".format(a) + ", {:.4f}".format(b) + "]"


# 		if alpha_j - a_init < 0.001: #or fabs(alpha_j - old_alpha_j) < 0.0001:
# 			alpha_star = alpha_j
# 			break
		if alpha_j == b or alpha_j == a: #or fabs(old_alpha_j - alpha_j) < 0.00001:
			alpha_star = alpha_j
			print "\nalpha_j (", alpha_j, ")", "=", b, "or", a, "; BREAK!"
			break			
		for j in range(J):
			for k in range(K):
				#C[j][k] = C0[j][k] + alpha_j * d[k*J + j]
				C[j][k] = C0[j][k] + alpha_j * d[j*K + k]
				# clip values to ensure that they stay within [0,1].
				if C[j][k] > u:
					#print "  \t\tC[j][k] > u", "; STOP" 
					C[j][k] = u
					#return alpha_j
				elif C[j][k] < l:
					#print "  \t\tC[j][k] < l", "; STOP" 
					C[j][k] = l
					#return alpha_j
				
		old_phi_j = phi_j
		# if K > 1:
		# 	phi_j = predict.get_R_E_and_grad_C(grad,
		# 				M, C, X, R, phi_j, I, J, K, normConstant)
		# else:
		# 	phi_j = predict.get_R_E_and_grad_C_one(grad,
		# 				M, C, X, R, phi_j, I, J, normConstant)
		phi_j = predict.get_R_E_and_Grad_C_nsp_omp(grad,
						M, C, X, R, I, J, K, normConstant)
		print "\t\tphi_j = {:.7f}".format(phi_j)
		print "\t\t{:.4f}".format(phi_j), ">", "{:.4f}".format(phi_0), "+", "{:.2f}".format(c1), "*", "{:.4f}".format(alpha_j), "*", "{:.5f}".format(der_phi_0), "?"
		print "\t\t= {:.8f}".format(phi_j), ">", "{:.8f}".format(phi_0 + c1*alpha_j*der_phi_0), "?"
		print "\t\told_phi_j =", "{:.7f}".format(old_phi_j) + ";",
		print "old_phi_j - phi_j =", "{:.6f}".format(old_phi_j - phi_j), "\n"
		##print "LS_C_Zoom", "; Finished computing grad"
		###sys.stdout.flush()

		if itr > 3 and old_phi_j - phi_j <= 0.0: #< 0.000000000001:
			if old_phi_j - phi_j < 0.0:
				print "\t\tInsufficient change in phi_j. alpha_star = alpha_lo. BREAK!"
				alpha_star = a
			else:
				print "\t\tInsufficient change in phi_j. alpha_star = alpha_j. BREAK!"
				alpha_star = a + 0.01*(alpha_j - a)
			break
		
		###sys.stdout.flush()
		##print "LS_C_Zoom", 50
		###sys.stdout.flush()
		if (phi_j > phi_0 + c1*alpha_j*der_phi_0) or (phi_j >= phi_lo):
			phi_rec = phi_hi
			alpha_rec = alpha_hi
			alpha_hi = alpha_j
			phi_hi = phi_j
		else:
			########################################################
			# Evaluate the gradient (i.e., phi prime) of the error function with respect
			## to C.
			matmath_nullptr.vec(grad, vec_grad, J, K)
			sp.compress_flt_vec(vec_grad, vec_grad_data, vec_grad_indices, vec_grad_indptr, N)
			der_phi_j = matmath_sparse.mul_1d_1d(vec_grad_data, 
									vec_grad_indices, vec_grad_indptr,
									d_data, d_indices, d_indptr)
			#print "\t\t\t?? |der_phi_j| <= c2*|der_phi_0|",";",fabs(der_phi_j), "<=", c2, "*", fabs(der_phi_0)
			#########################################################

			if der_phi_j >= c2*der_phi_0:
				print "\t\t### zoom C;", fabs(der_phi_j), "<=", c2*fabs(der_phi_0), "WOLFE POINT FOUND!", "RETURN", alpha_j
				return alpha_j
			if der_phi_j * (alpha_hi - alpha_lo) >= 0.0:
				#print "\t\t### zoom C;", "der_phi_j * (a_hi - a_lo)", ">=", der_phi_j * (alpha_hi - alpha_lo), ">= 0.0"
				#print "********* ping_1000! *********"
				phi_rec = phi_hi
				alpha_rec = alpha_hi
				alpha_hi = alpha_lo
				phi_hi = phi_lo
				der_phi_hi = der_phi_lo
			#print "********* ping_2222! *********"
			else:
				phi_rec = phi_lo
				alpha_rec = alpha_lo
			alpha_lo = alpha_j
			phi_lo = phi_j
			der_phi_lo = der_phi_j
		itr += 1
		num_rounds += 1

		if alpha_hi >= alpha_lo:
			b = alpha_hi
			a = alpha_lo
		else:
			b = alpha_lo
			a = alpha_hi			
		dalpha = b - a
		alpha_star = a

	print "\t\t***** Returning", alpha_star, " *****"
	return alpha_star



	
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
# 	#print "\t", "Armijo Zoom M!", "f0 =", "{:.5f}".format(phi_0)
# 	while fabs(a_j - a_i) > 0.0001 and itr < maxitr:
# # 		if itr == 1:
# # 			a_j = a_lo + 0.5*fabs(a_hi - a_lo)
# # 		else:
# 		#print "\t\t",
# 		if itr == 1:
# 			#print "(quad)",
# 			a_j = ip.quadratic_interpolate(phi_0, der_phi_0, a_j, phi_a_j)
# 		else:
# 			#print "(cubic)",
# 			a_j = ip.cubic(phi_0, der_phi_0, phi_a_i, a_i, phi_a_j, a_j)
# 		if a_j == -1:
# 			a_j = a_i + tau*fabs(a_j - a_i)
# 			#print "(bisect)",
# 		#print "a_j =", "{:.4f}".format(a_j), "<- [{:.4f}".format(a_i) + ", " + "{:.4f}".format(a_j) + "]",	
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
# 			phi_a_j = predict.get_r_and_e(C, m, x, r, J, K, normConstant)
# 		else:
# 			phi_a_j = predict.get_r_and_e_one(C, m, x, r, J, normConstant)
# 		#print "\tf_aj - f0+etc =", (phi_a_j - (phi_0 + c1 * a_j * der_phi_0)), "; f_ai =", phi_a_i
# 		if phi_a_j <= phi_0 + c1 * a_j * der_phi_0:
# 			# a_j satisfies the Armijo condition
# 			#print "\n************* WOLFE POINT FOUND (zoom M)!!! *************\n"
# 			return a_j
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
# 	
# cdef FLOAT armijo_zoom_C(FLOAT a_old, FLOAT phi_a_old,
# 				FLOAT a_new, FLOAT phi_a_new,
# 				FLOAT phi_0, FLOAT der_phi_0,
# 				FLOAT c1,
# 				FLOAT** C0, FLOAT** C,
# 				FLOAT** M, FLOAT** X, FLOAT** R,
# 				FLOAT* d, FLOAT* d_data, int* d_indices, int* d_indptr,
# 				FLOAT normConstant, int I, int K, int J):
# 
# 	cdef FLOAT a_j = a_new
# 	cdef FLOAT phi_a_j = phi_a_new
# 	cdef FLOAT a_i = a_old
# 	cdef FLOAT phi_a_i = phi_a_old
# 	cdef INT n, h, k, j
# 	cdef INT N = K*J
# 	cdef FLOAT tau = (sqrt(5) - 1)/2.0
# 	cdef int itr = 1
# 	cdef int maxitr = 15
# 	#print "\t*** ZOOM ARMIJO C ***"
# 	#print "\t\ta_i =", "{:.4f}".format(a_i), "; a_j =", "{:.4f}".format(a_j),
# 	#print "\t\tphi_i =", "{:.4f}".format(phi_a_i), "; phi_j =", "{:.4f}".format(phi_a_j),
# 	#print "\t\tphi_0 =", "{:.4f}".format(phi_0), "; der_phi_0 =", "{:.4f}".format(der_phi_0)
# 
# 	while fabs(a_j - a_i) > 0.0001 and itr < maxitr:
# # 		if itr == 1:
# # 			a_j = a_lo + 0.5*fabs(a_hi - a_lo)
# # 		else:
# 		#print "\t",
# 		if itr == 1:
# 			#print "(quad)",
# 			a_j = ip.quadratic_interpolate(phi_0, der_phi_0, a_j, phi_a_j)
# 		else:
# 			#print "(cubic)",
# 			a_j = ip.cubic(phi_0, der_phi_0, phi_a_i, a_i, phi_a_j, a_j)
# 		if a_j == -1:
# 			a_j = a_i + tau*fabs(a_j - a_i)
# 			#print "(bisect)",
# 		#print "a_j =", "{:.4f}".format(a_j), "<- [{:.4f}".format(a_i) + ", " + "{:.4f}".format(a_j) + "]",	
# 
# 		for j in range(J):
# 			for k in range(K):
# 				C[j][k] = C0[j][k] + a_j * d[k*J + j]
# 				if C[j][k] > 1.0: 
# 					C[j][k] = 1.0
# 				elif C[j][k] < -1.0: 
# 					C[j][k] = -1.0
# 		if K > 1:
# 			phi_a_j = predict.get_R_and_E(M, C, X, R, I, J, K, normConstant)
# 		else:
# 			phi_a_j = predict.get_R_and_E_one(M, C, X, R, I, J, normConstant)
# 		#print "\tf_aj - f0+etc =", phi_a_j - (phi_0 + c1 * a_j * der_phi_0), "; f_ai =", phi_a_i
# 
# 		if phi_a_j <= phi_0 + c1 * a_j * der_phi_0:
# 			#print "\n\t************* WOLFE POINT FOUND (zoom C)!!! *************\n"
# 			return a_j
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

cdef FLOAT armijo2_C_increase_alpha_nor(FLOAT a_higher, FLOAT phi_a_higher,
				FLOAT a_lower, FLOAT phi_a_lower,
				FLOAT phi_0, FLOAT der_phi_0,
				FLOAT c1,
				FLOAT** C0, FLOAT** C,
				FLOAT** M, 
				FLOAT* M_data, int* M_indices, int* M_indptr,
				FLOAT** X, FLOAT** R,
				FLOAT* d, FLOAT* d_data, int* d_indices, int* d_indptr,
				FLOAT normConstant, int I, int K, int J,
				FLOAT lowerBound, FLOAT upperBound):
	cdef int itr = 1
	cdef int maxitr = 20
	cdef int j,k
	while 1:
		for j in range(J):
			for k in range(K):
				C[j][k] = C0[j][k] + a_higher * d[j*K + k]
				# clip values to ensure that they stay within [0,1].
				if C[j][k] > upperBound:
					C[j][k] = upperBound
				elif C[j][k] < lowerBound:
					C[j][k] = lowerBound			
		
# 		if K > 1:
# 			phi_a_higher = predict.get_R_and_E(M, C, X, R, I, J, K, normConstant)
# 		else:
# 			phi_a_higher = predict.get_R_and_E_one(M, C, X, R, I, J, normConstant)
		phi_a_higher = predict.get_R_and_E_omp(R, M_data, M_indices, M_indptr, C, 
				X, I, J, K, normConstant)
		print "\tC INC; a_hi =", "{:.5f}".format(a_higher), "; f_a_hi=", "{:.4f}".format(phi_a_higher), "must be >", "{:.4f}".format(phi_0 + c1 * a_higher * der_phi_0)
		if phi_a_higher > phi_0 + c1 * a_higher * der_phi_0:
			##print "\tcorrect!"
			#print "\n\t###########\n"
			# armijo2_M_correct expects the first two args to be lowest in value.
			# Since we have been increasing, the latest alpha will be largest.
# 			return armijo2_C_correct_nor(a_lower, phi_a_lower, a_higher, phi_a_higher,
# 								phi_0, der_phi_0, c1, C0, C, M, X, R,
# 								d, d_data, d_indices, d_indptr,
# 								normConstant, I, K, J,
# 								upperBound, upperBound)
			print "\t***** ARMIJO POINT FOUND! a_lower =", a_lower, "*****"
			return a_lower
			# return armijo2_C_interpolate_nor(a_higher, phi_a_higher,
			# 					a_lower, phi_a_lower,
			# 					phi_0, der_phi_0,
			# 					c1, C0, C, M, X, R,
			# 					d, d_data, d_indices, d_indptr,
			# 					normConstant, I, K, J,
			# 					upperBound, upperBound)	
		if phi_a_higher == 1.0 and phi_a_lower == 1.0:
# 			a_higher = a_lower / 2.0
# 			#print "\tRESET"
			return a_higher
		phi_a_lower = phi_a_higher
		a_lower = a_higher
# 		if a_higher < 1500.0:
# 			#a_higher = (2.0**itr)
# 			a_higher = (10.0**(itr+1.2))
# 		else:
# 			#a_higher = a_higher*itr
# 			a_higher *= 10.0
		a_higher *= 10.0
# 		if phi_a_higher - phi_a_lower < 0.000001:
# 			#print "Duplicate phi value."
# 			return a_higher

		itr += 1
		if itr > maxitr:
			#print "itr > maxitr; returning a_lower =", "{:.6f}".format(a_lower),
			return a_lower
	
	print "Search failed; returning a_hi =", a_higher
	return a_higher
	
cdef FLOAT armijo2_C_decrease_alpha_nor(FLOAT a_higher, FLOAT phi_a_higher,
				FLOAT a_lower, FLOAT phi_a_lower,
				FLOAT phi_0, FLOAT der_phi_0,
				FLOAT c1,
				FLOAT** C0, FLOAT** C,
				FLOAT** M, 
				FLOAT* M_data, int* M_indices, int* M_indptr,
				FLOAT** X, FLOAT** R,
				FLOAT* d, FLOAT* d_data, int* d_indices, int* d_indptr,
				FLOAT normConstant, int I, int K, int J,
				FLOAT lowerBound, FLOAT upperBound):
	cdef int itr = 1
	cdef int maxitr = 20
	cdef int h,k,j
	while 1:
		for j in range(J):
			for k in range(K):
				C[j][k] = C0[j][k] + a_lower * d[j*K + k]
				# clip values to ensure that they stay within [0,1].
				if C[j][k] > upperBound:
					C[j][k] = upperBound
				elif C[j][k] < lowerBound:
					C[j][k] = lowerBound			
		phi_a_higher = phi_a_lower
# 		if K > 1:
# 			phi_a_lower = predict.get_R_and_E(M, C, X, R, I, J, K, normConstant)
# 		else:
# 			phi_a_lower = predict.get_R_and_E_one(M, C, X, R, I, J, normConstant)
		# phi_a_lower = predict.get_R_and_E_2(C, 
		# 		M, M_data, M_indices, M_indptr,
		# 		X, R, phi_a_lower, I, J, K, normConstant
		phi_a_lower = predict.get_R_and_E_omp(R, M_data, M_indices, M_indptr, C,
				X, I, J, K, normConstant)
		#print "\tZM C DEC; a_lo =", "{:.5f}".format(a_lower) + ", f_a_lo =", "{:.4f}".format(phi_a_lower), ">", "{:.4f}".format(phi_0 + c1 * a_lower * der_phi_0),
		#print "; f_a_hi =", "{:.5f}".format(a_higher)
		if phi_a_lower <= phi_0 + c1 * a_lower * der_phi_0:
			##print "\tcorrect!"
			#print "\n\t$$$$$$$$$\n --> Correction"
			# The first two args are going to be interpreted by
			# armijo2_M_correct as the smaller of the two alpha-phi pairs.
			# That is, the first and second args are supposed to be 
			# lower/smaller than the third and fourth args.
			# Because we are decreasing here, the most recent alpha
			# will be lowest.
			return armijo2_C_correct_nor(a_lower, phi_a_lower, a_higher, phi_a_higher,
								phi_0, der_phi_0, c1, C0, C, M, 
								M_data, M_indices, M_indptr, X, R,
								d, d_data, d_indices, d_indptr,
								normConstant, I, K, J,
								lowerBound, upperBound)
		a_higher = a_lower
		a_lower *= 2.0**(-itr)
		#phi_a_lower = phi_a_higher
		itr += 1
		if itr > maxitr:
			#print "itr > maxitr; returning a_lo =", "{:.6f}".format(a_lower)
			return a_lower
# 		if phi_a_higher == 1.0 and phi_a_lower == 1.0:
# 			return a_higher
# 		if phi_a_higher - phi_a_lower < 0.000001:
# 			#print "Duplicate phi value."
# 			return 0.0
		if a_lower < 0.0000001:
			return a_lower
	#print "Search failed; returning", a_lower
	return a_lower
# 
cdef FLOAT armijo2_C_correct_nor(FLOAT a1, FLOAT phi_a1,
				FLOAT a2, FLOAT phi_a2,
				FLOAT phi_0, FLOAT der_phi_0,
				FLOAT c1,
				FLOAT** C0, FLOAT** C,
				FLOAT** M, 
				FLOAT* M_data, int* M_indices, int* M_indptr,
				FLOAT** X, FLOAT** R,
				FLOAT* d, FLOAT* d_data, int* d_indices, int* d_indptr,
				FLOAT normConstant, int I, int K, int J,
				FLOAT lowerBound, FLOAT upperBound):

	cdef INT n, h, k, j
	cdef int itr = 1
	cdef int maxitr = 20
	cdef FLOAT tau = (sqrt(5) - 1.0)/2.0
	cdef int num_extremes = 0
	cdef FLOAT a0 = a1
	cdef FLOAT rate = 0.2
# 	#print "\t*** ZOOM ARMIJO C ***"
# 	#print "\t\ta_i =", "{:.4f}".format(a_i), "; a3 =", "{:.4f}".format(a3),
# 	#print "\t\tphi_i =", "{:.4f}".format(phi_a_i), "; phi_j =", "{:.4f}".format(phi_a3),
# 	#print "\t\tphi_0 =", "{:.4f}".format(phi_0), "; der_phi_0 =", "{:.4f}".format(der_phi_0)
	#print "ARM C COR;", 1
	cdef FLOAT a3, phi_a3
	while itr < maxitr:
		print "   COR;", # [" + "{:.3f}".format(a0) + ", {:.3f}".format(a2) + "]",
		#print "(cubic)",
		#a3 = ip.cubic(phi_0, der_phi_0, phi_a1, a1, phi_a2, a2)
		#if a3 < 0.0 or a3 < a0 or a3 > a2:
		# Interpolation is based on the magnitude of values, not on their their
		# order in time.
# 		a3 = ip.cubic(phi_0, der_phi_0, phi_a1, a1, phi_a2, a2)
# 		if a3 == -1:
			#print "(bisect)",
# 		if a2 <= 10.0:
# 			rate = 0.5
# 		else:
# 			rate = 0.2	
		a3 = a0 + rate*fabs(a0 - a2)
		#a3 = 0.2*a2
		#print "ARM C COR;", 2	
		print "a3 =", "{:.4f}".format(a3), "<- [{:.4f}".format(a0) + ", " + "{:.4f}".format(a2) + "]"	
		num_extremes = 0
		for j in range(J):
			for k in range(K):
				C[j][k] = C0[j][k] + a3 * d[j*K + k]
				if C[j][k] > upperBound: 
					C[j][k] = upperBound
					#num_extremes += 1
				elif C[j][k] < lowerBound:
					#num_extremes += 1
					C[j][k] = lowerBound
		#print "ARM C COR;", 3	
# 		if K > 1:
# 			phi_a3 = predict.get_R_and_E(M, C, X, R, I, J, K, normConstant)
# 		else:
# 			phi_a3 = predict.get_R_and_E_one(M, C, X, R, I, J, normConstant)
		phi_a3 = predict.get_R_and_E_omp(R, M_data, M_indices, M_indptr, C,
				X, I, J, K, normConstant)
		#print "f_aj-f0+etc =", "{:.5f}".format(phi_a3 - (phi_0 + c1 * a3 * der_phi_0)), "; f_aj =", "{:.5f}".format(phi_a3), "; f_a_last =", "{:.5f}".format(phi_a2), 
		##print "; #extr:", num_extremes, "/", J * K, "= {:.2f}".format(<FLOAT>num_extremes/<FLOAT>J*K)
		#print "ARM C COR;", 4			
		if phi_a3 <= phi_0 + c1 * a3 * der_phi_0:
			# a2 satisfies the Armijo condition
			print "\t**** ARMIJO POINT FOUND; a =", "{:.6f}".format(a3), "phi_a3 =", "{:.6f}".format(phi_a3) + "****\n"
			return a3
# 		if fabs(phi_a3 - phi_a1) <= 0.00001:
# 			print "\n\t**** Cyclic alternations; returning a3 =", a3, "\n"
# 			return a3
		#if (a2 - a3) > a2 / 2.0 or (1 - a3/a2) < 0.96:
			#a3 = a2 / 2.0
			##print "\tRESET"
		if phi_a2 == 1.0 and phi_a1 == 1.0:
# 			#a3 = a2 / 2.0
			print "\tOne City; returning a3 =", a3	
			return a3
		a1 = a2
		a2 = a3
		phi_a1 = phi_a2
		phi_a2 = phi_a3
		itr += 1

	#print "Search failed; returning a3 =", "{:.6f}".format(a3)
	return a3
# 	
cdef FLOAT armijo2_M_increase_alpha_nor(FLOAT a_higher, FLOAT phi_a_higher,
				FLOAT a_lower, FLOAT phi_a_lower,
				FLOAT phi_0, FLOAT der_phi_0,
				FLOAT c1,
				FLOAT* m0, FLOAT* m,
				FLOAT** C, FLOAT* C_data, int* C_indices, int* C_indptr,
				#FLOAT* prod,
				FLOAT* x, FLOAT* r,
				FLOAT* d, FLOAT* d_data, int* d_indices, int* d_indptr,
				FLOAT normConstant, int K, int J,
				FLOAT lowerBound, FLOAT upperBound):
	cdef int itr = 1
	cdef int maxitr = 20
	#cdef FLOAT a_higher
	#cdef FLOAT phi_a_higher
	cdef FLOAT a0
	cdef int h,k
	#print "\t(inc) f_lo, f_hi = {:.7f}".format(phi_a_lower), "{:.7f}".format(phi_a_higher)
	while 1:
		###print "a_j =", "{:.4f}".format(a_j), "<- [{:.4f}".format(a_i) + ", " + "{:.4f}".format(a_j) + "]",	
		for h in range(d_indptr[1]):
			m[d_indices[h]] = m0[d_indices[h]] + a_higher * d_data[h]
			# clip values to ensure that they stay within [0,1].
			if m[d_indices[h]] > upperBound:
				m[d_indices[h]] = upperBound
			elif m[d_indices[h]] < lowerBound:
				m[d_indices[h]] = lowerBound		
		
# 		if K > 1:
# 			phi_a_higher = predict.get_r_and_e(C, m, x, r, J, K, normConstant
# 		else:
# 			phi_a_higher = predict.get_r_and_e_one(C, m, x, r, J, normConstant
		phi_a_higher = predict.get_r_and_e_omp(r, m, 
					C_data, C_indices, C_indptr,
					x, J, K, normConstant)
		#print "\tZM M INC; a_hi =", "{:.4f}".format(a_higher), "; f_a_hi =", 
		#print "{:.4f}".format(phi_a_higher), "must be >", "{:.4f}".format(phi_0 + c1 * a_higher * der_phi_0), "; a_lo =", "{:.4f}".format(a_lower), "; phi_a_lo =", "{:.4f}".format(phi_a_lower)
		if phi_a_higher > phi_0 + c1 * a_higher * der_phi_0:
			###print "\tcorrect!"
			##print "\n\t###########\n"
			# armijo2_M_correct expects the first two args to be lowest in value.
			# Since we have been increasing, the latest alpha will be largest.
			return a_lower
# 			return armijo2_M_correct_nor(a_lower, phi_a_lower, a_higher, phi_a_higher,
# 								phi_0, der_phi_0, c1, m0, m, C, x, r,
# 								d, d_data, d_indices, d_indptr,
# 								normConstant, K, J, lowerBound, upperBound)
# 			return armijo2_M_interpolate_nor(a_higher, phi_a_higher, a_lower, phi_a_lower, 
# 								phi_0, der_phi_0, c1, m0, m, C, x, r,
# 								d, d_data, d_indices, d_indptr,
# 								normConstant, K, J, lowerBound, upperBound)	
# 		if phi_a_higher - phi_a_lower < 0.000001:
# 			##print "Duplicate phi_higher value."	
# 			return 0.0
		phi_a_lower = phi_a_higher
		a_lower = a_higher
		#a_higher *= 2.0**itr
		a_higher *= 5.0
		itr += 1
		if itr > maxitr:
			#print "\tToo many iterations; returning a_hi =", "{:.6f}".format(a_higher), "\n"
			return a_higher
		if phi_a_higher == 1.0 and phi_a_lower == 1.0:

			return a_higher
	print "*** Failed search; returning a_higher =", a_higher
	return a_higher

	
cdef FLOAT armijo2_M_decrease_alpha_nor(FLOAT a_higher, FLOAT phi_a_higher,
				FLOAT a_lower, FLOAT phi_a_lower,
				FLOAT phi_0, FLOAT der_phi_0,
				FLOAT c1, FLOAT* m0, FLOAT* m,
				FLOAT** C, FLOAT* C_data, int* C_indices, int* C_indptr,
				FLOAT* x, FLOAT* r,
				FLOAT* d, FLOAT* d_data, int* d_indices, int* d_indptr,
				FLOAT normConstant, int K, int J,
				FLOAT lowerBound, FLOAT upperBound):
	cdef int itr = 1
	cdef int h,k
	cdef int maxitr = 20
	while 1:
# 		#print "\t",
# 		#print "(cubic)",
# 		a_j = ip.cubic(phi_0, der_phi_0, phi_a_lo, a_lo, phi_a_hi, a_hi)
# 		if a_j == -1:
# 			a_j = a_lo + 0.5*fabs(a_lo - a_hi)
# 			#print "(bisect)",
# 		#print "a_j =", "{:.4f}".format(a_j), "<- [{:.4f}".format(a_lo) + ", " + "{:.4f}".format(a_hi) + "]",	
		for h in range(d_indptr[1]):
			m[d_indices[h]] = m0[d_indices[h]] + a_lower * d_data[h]
			# clip values to ensure that they stay within [0,1].
			if m[d_indices[h]] > upperBound:
				m[d_indices[h]] = upperBound
			elif m[d_indices[h]] < lowerBound:
				m[d_indices[h]] = lowerBound		
		
		
# 		if K > 1:
# 			phi_a_lower = predict.get_r_and_e(C, m, x, r, J, K, normConstant
# 		else:
# 			phi_a_lower = predict.get_r_and_e_one(C, m, x, r, J, normConstant
		phi_a_lower = predict.get_r_and_e_omp(r, m, 
					C_data, C_indices, C_indptr,
					x, J, K, normConstant)
		#print "\tZM M DEC; a_lo =", "{:.6f}".format(a_lower), "; f_lo =", "{:.6f}".format(phi_a_lower), "<=", phi_0 + c1 * a_lower * der_phi_0, ";",
		#print "f_lo - f0+etc =", "{:.5f}".format(phi_a_lower - (phi_0 + c1 * a_lower * der_phi_0)), "; f_a_hi =", "{:.5f}".format(phi_a_higher)
		if phi_a_lower <= phi_0 + c1 * a_lower * der_phi_0:
			##print "\tcorrect!"
			#print "\n\t$$$$$$$$$ -> to correction\n"
			# The first two args are going to be interpreted by
			# armijo2_M_correct as the smaller of the two alpha-phi pairs.
			# That is, the first and second args are supposed to be 
			# lower/smaller than the third and fourth args.
			# Because we are decreasing here, the most recent alpha
			# will be lowest.
			return armijo2_M_correct_nor(a_higher, phi_a_higher, a_lower, phi_a_lower, 
								phi_0, der_phi_0, c1, m0, m, 
								C, C_data, C_indices, C_indptr, 
								#prod, 
								x, r,
								d, d_data, d_indices, d_indptr,
								normConstant, K, J, lowerBound, upperBound)
# 		if phi_a_higher - phi_a_lower < 0.000001:
# 			#print "Duplicate phi_higher value."	
# 			return 0.0
		phi_a_lower = phi_a_higher		
		a_higher = a_lower
		a_lower *= 2.0**(-itr)
		itr += 1
		if itr > maxitr:
			#print "\t* itr > maxitr * returning a_hi =", "{:.6f}".format(a_higher), "\n"
			return a_lower
		if phi_a_higher == 1.0 and phi_a_lower == 1.0:
			return a_higher
	#print "\tSearch failed. Returning a =", a_lower, "\n"
	return a_lower	


cdef FLOAT armijo2_M_correct_nor(FLOAT a1, FLOAT phi_a1,
				FLOAT a2, FLOAT phi_a2,
				FLOAT phi_0, FLOAT der_phi_0,
				FLOAT c1,
				FLOAT* m0, FLOAT* m,
				FLOAT** C, FLOAT* C_data, int* C_indices, int* C_indptr,
				#FLOAT* prod,
				FLOAT* x, FLOAT* r,
				FLOAT* d, FLOAT* d_data, int* d_indices, int* d_indptr,
				FLOAT normConstant, int K, int J,
				FLOAT lowerBound, FLOAT upperBound):
	cdef FLOAT maxitr = 20
	cdef int h,k
	cdef FLOAT itr = 1
	cdef FLOAT a3, phi_a3
	cdef FLOAT tau = (sqrt(5) - 1.0)/2.0
	cdef int extremes = 0
	cdef int zeros = 0
	cdef FLOAT a0 = a1
	while  itr < maxitr:
		#print "    COR;", #[" + "{:.3f}".format(a0) + ", {:.3f}".format(a2) + "]",
		###print "(cubic)",
		# Interpolation is based on the magnitude of values, not on their their
		# order in time. No, don't think so.
		##print "(cubic)",
		a3 = a0 + (1.0 - tau)*fabs(a0 - a2)
# 		a3 = ip.cubic(phi_0, der_phi_0, phi_a1, a1, phi_a2, a2)
# 		if a3 < 0.0 or a3 < a0 or a3 > a2:
			##print "(bisect)",
			#a3 = a0 + 0.5*fabs(a0 - a2)
		if a2 == 0.0:
			##print "\n"
			break		
		#print "a3 =", "{:.4f}".format(a3), "<- [", "{:.4f}".format(a0) + ", " + "{:.4f}".format(a2), "]",
		extremes = 0
		zeros = 0
		for h in range(d_indptr[1]):
			m[d_indices[h]] = m0[d_indices[h]] + a3 * d_data[h]
			# clip values to ensure that they stay within [0,1].
			if m[d_indices[h]] >= upperBound:
				extremes+=1
				m[d_indices[h]] = upperBound
			elif m[d_indices[h]] <= lowerBound:
				extremes+=1
				zeros += 1
				m[d_indices[h]] = lowerBound
		if a2 == 0.0:
			##print "\n"
			break

# 		if K > 1:
# 			phi_a3 = predict.get_r_and_e(C, m, x, r, J, K, normConstant
# 		else:
# 			phi_a3 = predict.get_r_and_e_one(C, m, x, r, J, normConstant
		phi_a3 = predict.get_r_and_e_omp(r, m, 
					C_data, C_indices, C_indptr,
					x, J, K, normConstant)
		#print "; f_a3 - f0+etc =", "{:.5f}".format(phi_a3 - (phi_0 + c1 * a3 * der_phi_0)) + "; f_a3 =", "{:.5f}".format(phi_a3), "; f_a2 =", "{:.5f}".format(phi_a2) 
		#print "#extr:", extremes, "; #0:", zeros, zeros, "; {:.3f}".format(a2 - a3), "{:.3f}".format(a1 / 2.0 ), "{:.3f}".format(1-a3/a2), "gTd=","{:.1f}".format(der_phi_0)
		if phi_a3 <= phi_0 + c1 * a3 * der_phi_0:
			# a2 satisfies the Armijo condition
			#print "**** ARMIJO POINT FOUND; a3 =", "{:.6f}".format(a3), "phi_a3 =","{:.6f}".format(phi_a3) + "****\n";
			return a3
		if phi_a2 == 1.0 and phi_a1 == 1.0:
			return a3
		a1 = a2
		a2 = a3
		phi_a1 = phi_a2
		phi_a2 = phi_a3
		itr += 1

	#print "\tFailed search; Returning a3 =", "{:.6f}".format(a3), "\n"
	return a3

cdef FLOAT armijo2_M_interpolate_nor(FLOAT a2, FLOAT phi_a2,
				FLOAT a1, FLOAT phi_a1,
				FLOAT phi_0, FLOAT der_phi_0,
				FLOAT c1, FLOAT* m0, FLOAT* m,
				FLOAT** C, FLOAT* C_data, int* C_indices, int* C_indptr,
				#FLOAT* prod,
				FLOAT* x, FLOAT* r,
				FLOAT* d, FLOAT* d_data, int* d_indices, int* d_indptr,
				FLOAT normConstant, int K, int J,
				FLOAT lowerBound, FLOAT upperBound):
	cdef int itr = 1
	cdef int k,h
	cdef int maxitr = 20
	cdef FLOAT phi_a3 = 0.0
	cdef FLOAT a3 = 0.0
	cdef int extremes, zeros
	cdef FLOAT a0 = a1
	#cdef object m_vector = ""
	#cdef FLOAT phi_a0 = phi_a1
	# a2 is the latest alpha; a1 is the second-to-last alpha.
	#print "\t(inter) f_a0, f_a2 = {:.7f}".format(phi_0), "{:.7f}".format(phi_a2)
	while itr < maxitr:
# 		if itr == 1:
# 			a3 = a0 + 0.5*fabs(a0 - a2)
# 		else:
		#print "    INTER M;",

		if itr == 1:
			##print "(quad)",
			# a2 is the most recent alpha.
			a3 = ip.quadratic_interpolate(phi_0, der_phi_0, a2, phi_a2)
			if a3 < 0.0: #or a3 >= a2:
				##print "(bisect)",
				a3 = a0 + 0.5*fabs(a0 - a2)						
		else:
			##print "(cubic)",
			a3 = ip.cubic(phi_0, der_phi_0, phi_a1, a1, phi_a2, a2)
# 			if a3 < 0.0: #or a3 >= a2:
# 				##print "(quad)",
# 				a3 = ip.quadratic_interpolate(phi_0, der_phi_0, a2, phi_a2)
			if a3 < 0.0:
				##print "(bisect)",
				a3 = a0 + 0.5*fabs(a0 - a2)
# 		if a3 >= a2:
# 			a3 = a2/2.0			
		#print "a3 =", "{:.5f}".format(a3), "<- {:.5f}".format(a1) + ", " + "{:.5f}".format(a2),
		if a3 < 0.000000001:
			#print "\na3 = 0.0; returning 0.0"
			return 0.0
		extremes = 0
		zeros = 0
		for h in range(d_indptr[1]):
			m[d_indices[h]] = m0[d_indices[h]] + a3 * d_data[h]
			# clip values to ensure that they stay within [0,1].
			if m[d_indices[h]] >= upperBound:
				extremes+=1
				m[d_indices[h]] = upperBound
			elif m[d_indices[h]] <= lowerBound:
				extremes+=1
				zeros += 1
				m[d_indices[h]] = lowerBound

# 		if K > 1:
# 			phi_a3 = predict.get_r_and_e(C, m, x, r, J, K, normConstant
# 		else:
# 			phi_a3 = predict.get_r_and_e_one(C, m, x, r, J, normConstant
		phi_a3 = predict.get_r_and_e_nsp_omp(r, m, C, x, J, K, normConstant)
		if a2 == 0.0:
			return 0.0
		
		#print "; f_a3-f0&c =", "{:.1f}".format(phi_a3 - (phi_0 + c1 * a3 * der_phi_0)) + "; f_a3 =", "{:.5f}".format(phi_a3) + ";", "f_a2 = {:.5f}".format(phi_a2), 
		###print "; #extr:", extremes, "; #0:", zeros, 
		#print "f_a1 = {:.5f}".format(phi_a1)
		##print ";; {:.3f}".format(a2 - a3), "{:.3f}".format(a1 / 2.0 ),	"{:.3f}".format(1-a3/a2), ";df= {:.5f}".format(der_phi_0) + "; m =", m_vector
# 		if a2 <= a1:
# 			#print "a2 <= a1; returning", a3, "\n"
# 			return a3
		if phi_a3 <= phi_0 + c1 * a3 * der_phi_0:
			# a2 satisfies the Armijo condition
			#print "**** ARMIJO POINT FOUND; a3 =", "{:.6f}".format(a3), "phi_a3 =",   		
			#print "{:.6f}".format(phi_a3) + " ****\n"
			return a3
# 		elif (fabs(phi_a3 - phi_a1) <= 0.0000001 or a3 < 0.000001) and itr > 3:
# 			#print "\n\t**** Alternations; returning ", 0, "\n"
# 			##print "\tDifference too small, returning a3 =", a3
# 			##a3 = a2 / 2.0
# 			#return 0.0
# 			return a3	
# 		elif (a2 - a3) > a2 / 2.0 or (1 - a3/a2) < 0.96:
# 			#a3 = a2 / 2.0
# 			##print "\tRESET"
# 		if (a1 ‐ a2) > a1 / 2.0 or (1 ‐ a2/a1) < 0.96:
# 			#a3 = a2 / 2.0
# 			##print "\n\tRESET"
		elif phi_a2 == 1.0 and phi_a1 == 1.0:
# 			#a3 = a2 / 2.0
# 			##print "\n\tRESET"	
			#print "phi_a2 == 1.0 and phi_a1 == 1.0; returning a3 =", a3
			return a3
		a1 = a2
		a2 = a3
		phi_a1 = phi_a2
		phi_a2 = phi_a3

		itr += 1
	#print "\n\t**** Search failed; returning a3 =", a3, "\n"
	return a3

cdef FLOAT armijo2_C_interpolate_nor(FLOAT a2, FLOAT phi_a2,
				FLOAT a1, FLOAT phi_a1,
				FLOAT phi_0, FLOAT der_phi_0,
				FLOAT c1,
				FLOAT** C0, FLOAT** C,
				FLOAT** M, FLOAT* M_data, int* M_indices, int* M_indptr,
				FLOAT** X, FLOAT** R,
				FLOAT* d, FLOAT* d_data, int* d_indices, int* d_indptr,
				FLOAT normConstant, int I, int K, int J,
				FLOAT lowerBound, FLOAT upperBound):
	cdef int itr = 1
	cdef int maxitr = 20
	cdef int num_extremes
	cdef int h,j,k
	cdef FLOAT a3, phi_a3, a_lo, a_hi, phi_a_lo, phi_a_hi
	phi_a3 = 0.0
	cdef FLOAT a0 = 0.0
	while itr < maxitr:
		print "Armijo INTER C",
		if itr == 1:
			print "(quad)",
			a3 = ip.quadratic_interpolate(phi_0, der_phi_0, a2, phi_a2)
			if a3 < 0.0: #or a3 >= a2:
				print "(bisect)",
				a3 = a0 + 0.5*fabs(a0 - a2)	
		else:
			print "(cubic)",
			a3 = ip.cubic(phi_0, der_phi_0, phi_a1, a1, phi_a2, a2)
			if a3 < 0.0: #or a3 >= a2:
# 				print "(quad)",
# 				a3 = ip.quadratic_interpolate(phi_0, der_phi_0, a2, phi_a2)
# 				if a3 < 0.0: #or a3 >= a2:
				print "(bisect)",
				#a3 = 0.5*(fabs(a2) + fabs(a1))
				a3 = a0 + 0.5*fabs(a0 - a2)
		#print "Arm C Intr;", 3
# 		if a3 >= a2:
# 			a3 = a2/2.0
		#print "Arm C Intr;", 4
		print "a3 =", "{:.4f}".format(a3), "<- [{:.4f}".format(a1) + ", " + "{:.4f}".format(a2) + "] ;",	
		#print "Arm C Intr;", 5
		if a3 < 0.000000001:
			print "\na3 = 0.0; returning 0.0"
			return 0.0
		num_extremes = 0
		for j in range(J):
			for k in range(K):
				C[j][k] = C0[j][k] + a3 * d[j*K + k]
				if C[j][k] >= upperBound: 
					C[j][k] = upperBound
					num_extremes += 1
				elif C[j][k] <= lowerBound:
					num_extremes += 1
					C[j][k] = lowerBound
# 		if K > 1:
# 			phi_a3 = predict.get_R_and_E(M, C, X, R, I, J, K, normConstant)
# 		else:
# 			phi_a3 = predict.get_R_and_E_one(M, C, X, R, I, J, normConstant)
		phi_a3 = predict.get_R_and_E_omp(R, M_data, M_indices, M_indptr, C,
				X, I, J, K, normConstant)
		print "f_aj=", "{:.5f}".format(a3), "; f_aj-f0&c=", "{:.5f}".format(phi_a3-(phi_0 + c1 * a3 * der_phi_0)) + "; f_a2 =", "{:.5f}".format(phi_a2) + "; a1=", "{:.4f}".format(a1) + "; a2=", "{:.4f}".format(a2) + "; #extr:", num_extremes, "/", J * K, "=" "{:.2f}".format(<FLOAT>num_extremes/(<FLOAT>J*K))
		if phi_a3 <= phi_0 + c1 * a3 * der_phi_0:
			# a2 satisfies the Armijo condition		
			print "\n**** ARMIJO POINT FOUND; a3 =", "{:.6f}".format(a3), "phi_a3 =", "{:.6f}".format(phi_a3) + "****\n"
			return a3
		
		elif phi_a2 == 1.0 and phi_a1 == 1.0:
			return a3
		a1 = a2
		a2 = a3
		phi_a1 = phi_a2
		phi_a2 = phi_a3
		itr += 1
	print "\t**** Search failed; returning a3 =", a3, "\n"
	return a3