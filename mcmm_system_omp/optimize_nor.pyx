#cython: profile=True
#cython: boundscheck=False
#cython: wraparound=False
#cython: cdivision=True

import numpy as np
from cython.parallel import parallel, prange
import sys

def isNaN(FLOAT x):
	return x != x
	
cdef FLOAT optimize_C_nor(FLOAT** X_ptr, FLOAT** R_ptr, FLOAT** C_ptr,
					FLOAT** M_ptr,
					INT I, INT J, INT K, FLOAT normConstant,  
					INT numIters, INT objFunc, bint qn, bint cg, 
                    FLOAT* distance, INT* num_steps,
                    FLOAT lower, FLOAT upper):

	print "We're in optimize_C!\n"
	print "I =", I, "\n"
	cdef INT count, grad_nnz, grad_old_nnz
	#cdef INT memory_size
	cdef INT C_nnz = 0
	cdef INT i,j,k,k1,k2,n,n1,n2,h,h1,h2
	cdef FLOAT  grad_norm_diff, grad_norm, grad_norm_old, error_test, grad_sq_sum
	grad_norm = 0.0
	grad_sq_sum = 0.0
	cdef FLOAT gTd, gTd_old, sTy, sTs, yTy, dTy, sse
	yTy = 1.0
	sTy = 1.0
	sTs = 1.0
	gTd = 1000000000.0
	cdef FLOAT delta_err_1, delta_err_2
	cdef INT Z = 5
	cdef INT t = 0
	cdef INT t_max = 10
	cdef INT N = K*J
	cdef INT size_max = 20
	cdef FLOAT alpha1, alpha_max
	cdef FLOAT eps = 0.000001
	cdef FLOAT zero_eps = 0.001
	cdef FLOAT err_thresh = 0.000000001
	cdef FLOAT prev_err_global = 10000000000.0
	cdef INT a_iter = 0
	cdef INT* a_iter_ptr = &a_iter
	cdef INT cg_itrs = 0
	cdef INT* cg_itrs_ptr = &cg_itrs
	cdef INT nr_itrs = 0
	cdef INT* nr_itrs_ptr = &nr_itrs
	cdef INT num_stored = 0
	cdef INT* num_str_ptr = &num_stored
	cdef FLOAT gamma = 1.0
	cdef FLOAT* gamma_ptr = &gamma
	cdef FLOAT numer, denom, step_norm
	cdef FLOAT c1 = 0.0001
	cdef FLOAT c2 = 0.9
	cdef INT ndx
	cdef FLOAT gamma_numer, gamma_denom
	cdef FLOAT sign = -1.0
	cdef FLOAT rmx_sum = 0.0
	cdef int precondition = 0
	cdef FLOAT avg_m, avg_c, avg_mc, avg_x, avg_r, avg_xr
	cdef int c_num_near_0, m_num_near_0, mc_num_gt0, num_x_one
	cdef FLOAT vec_D_norm = 0.0
	cdef FLOAT gTd_thresh = -0.000000001
	cdef FLOAT prev_err_nr = 0.0
	cdef INT d_nnz = 0
	cdef INT counter = 0
	cdef FLOAT avg_step = 0.003
	cdef FLOAT q_val = 0.0
	cdef FLOAT u_val = 0.0
	cdef FLOAT old_c
	cdef FLOAT error = 0.0
	cdef INT cg_itr_max = 20
	cdef bint yTy_break = 0
	cdef bint sTy_break = 0
	cdef FLOAT P0_grad_norm, P0_grad_sq_sum
	
	######################################################################
	## Allocate memory_size to special poINTers

	cdef FLOAT** C_old = <FLOAT **>malloc(J*sizeof(FLOAT*))
	for j in range(J):
		C_old[j] = <FLOAT *>malloc(K*sizeof(FLOAT))
		for k in range(K):
			C_old[j][k] = 0.0
	C_old = &C_old[0]	
	
	cdef FLOAT** C_test = <FLOAT **>malloc(J*sizeof(FLOAT*))
	for j in range(J):
		C_test[j] = <FLOAT *>malloc(K*sizeof(FLOAT))
		for k in range(K):
			C_test[j][k] = 0.0
	C_test = &C_test[0]	

	cdef FLOAT* vec_C = <FLOAT *>calloc(N,sizeof(FLOAT))
	cdef FLOAT* vec_C_old = <FLOAT *>calloc(N,sizeof(FLOAT))
	# for n in range(N):
	# 	vec_C[n] = 0.0
	# 	vec_C_old[n] = 0.0

	cdef FLOAT* M_data = <FLOAT *>malloc(I*K*sizeof(FLOAT))
	cdef int* M_indices = <int *>malloc(I*K*sizeof(int))
	cdef int* M_indptr = <int *>malloc((I+1)*sizeof(int))
	sp.compress_dbl_mat(M_ptr, M_data, M_indices, M_indptr, I, K)

# 	cdef FLOAT* MC_data = <FLOAT *>malloc(J*K*sizeof(FLOAT))
# 	cdef int* MC_indices = <int *>malloc(J*K*sizeof(int))
# 	cdef int* MC_indptr = <int *>malloc((J+1)*sizeof(int))
	
	cdef FLOAT* Hy = <FLOAT *>calloc(N,sizeof(FLOAT))
	cdef FLOAT* diagH = <FLOAT *>calloc(N,sizeof(FLOAT))
	cdef FLOAT* diagPre = <FLOAT *>calloc(N,sizeof(FLOAT))
	# for n in range(N):
	# 	Hy[n] = 0.0
	# 	diagH[n] = 0.0
	# 	diagPre[n] = 0.0
		
	cdef FLOAT* rho = <FLOAT*>calloc(size_max, sizeof(FLOAT))
	# for i in range(size_max):
	# 	rho[i] = 0.0

	cdef FLOAT * diagP0 = <FLOAT*>calloc(N,sizeof(FLOAT))
	for n in range(N):
		diagP0[n] = 0.0
	cdef INT * diagP0_indices = <INT*>calloc(N,sizeof(INT))
	cdef INT * diagP0_indptr = <INT*>calloc(2,sizeof(INT))
	# diagP0_indptr[0] = 0
	# diagP0_indptr[1] = 0
	cdef INT * diagP0_zero_indices = <INT*>calloc(N,sizeof(INT))
	cdef INT * diagP0_zero_indptr = <INT*>calloc(2,sizeof(INT))
	# diagP0_zero_indptr[0] = 0
	# diagP0_zero_indptr[1] = 0
	
	cdef FLOAT * diagP1 = <FLOAT*>calloc(N,sizeof(FLOAT))
	# for n in range(N):
	# 	diagP1[n] = 0.0
	cdef INT * diagP1_indices = <INT*>calloc(N,sizeof(INT))
	cdef INT * diagP1_indptr = <INT*>calloc(2,sizeof(INT))
	# diagP1_indptr[0] = 0
	# diagP1_indptr[1] = 0	
	cdef INT * diagP1_zero_indices = <INT*>calloc(N,sizeof(INT))
	cdef INT * diagP1_zero_indptr = <INT*>calloc(2,sizeof(INT))
	# diagP1_zero_indptr[0] = 0
	# diagP1_zero_indptr[1] = 0	

	cdef INT * diagP2_indices = <INT*>calloc(N,sizeof(INT))
	# for n in range(N):
	# 	diagP2_indices[n] = 0
	cdef INT * diagP2_indptr = <INT*>calloc(2,sizeof(INT))
	# diagP2_indptr[0] = 0
	# diagP2_indptr[1] = 0

	cdef INT * diagP3_indices = <INT*>calloc(N,sizeof(INT))
	# for n in range(N):
	# 	diagP3_indices[n] = 0
	cdef INT * diagP3_indptr = <INT*>calloc(2,sizeof(INT))
	# diagP3_indptr[0] = 0
	# diagP3_indptr[1] = 0
	
	cdef FLOAT ** grad = <FLOAT **>malloc(J*sizeof(FLOAT*))
	for j in range(J):
		grad[j] = <FLOAT *>calloc(K,sizeof(FLOAT))
		# initialize the matrix's cells
		# for k in range(K):
		# 	grad[j][k] = 0.0
	grad = &grad[0]

	cdef FLOAT * vec_grad = <FLOAT *>malloc(N*sizeof(FLOAT))
	# for n in range(N):
	# 	vec_grad[n] = 0.0
	cdef FLOAT * vec_grad_old = <FLOAT *>malloc(N*sizeof(FLOAT))

	cdef FLOAT* vec_grad_data = <FLOAT*>malloc(N*sizeof(FLOAT))
	cdef INT* vec_grad_indices = <INT*>malloc(N*sizeof(INT))
	cdef INT* vec_grad_indptr = <INT*>malloc(2*sizeof(INT))

	cdef FLOAT * vec_z = <FLOAT *>malloc(N*sizeof(FLOAT))
	cdef FLOAT * vec_z_old = <FLOAT *>malloc(N*sizeof(FLOAT))
	cdef FLOAT* vec_z_data = <FLOAT*>malloc(N*sizeof(FLOAT))
	cdef INT* vec_z_indices = <INT*>malloc(N*sizeof(INT))
	cdef INT* vec_z_indptr = <INT*>malloc(2*sizeof(INT))
	
	cdef FLOAT * vec_D = <FLOAT *>calloc(N,sizeof(FLOAT))
	# for n in range(N):
	# 	vec_D[n] = 0.0
	cdef FLOAT* vec_D_data = <FLOAT *>calloc(N,sizeof(FLOAT))
	cdef INT* vec_D_indices = <INT*>calloc(N,sizeof(INT))
	cdef INT* vec_D_indptr = <INT*>calloc(2,sizeof(INT))
	# for n in range(N):
	# 	vec_D_data[n] = 0.0
	# 	vec_D_indices[n] = 0
	# vec_D_indptr[0] = 0
	# vec_D_indptr[1] = 0
	
	cdef FLOAT ** s_vecs = <FLOAT **>malloc(size_max*sizeof(FLOAT*))
	cdef FLOAT ** s_vecs_data = <FLOAT **>malloc(size_max*sizeof(FLOAT*))
	cdef INT ** s_vecs_indices = <INT **>malloc(size_max*sizeof(INT*))
	cdef INT ** s_vecs_indptr = <INT **>malloc(size_max*sizeof(INT*))
	cdef FLOAT ** y_vecs = <FLOAT **>malloc(size_max*sizeof(FLOAT*))
	cdef FLOAT ** y_vecs_data = <FLOAT **>malloc(size_max*sizeof(FLOAT*))
	cdef INT ** y_vecs_indices = <INT **>malloc(size_max*sizeof(INT*))
	cdef INT ** y_vecs_indptr = <INT **>malloc(size_max*sizeof(INT*))   

	for i in range(size_max):
		s_vecs[i] = <FLOAT *>malloc(N*sizeof(FLOAT))
		for k in range(N):
			s_vecs[i][k] = 0.0
	s_vecs = &s_vecs[0]

	for i in range(size_max):
		s_vecs_data[i] = <FLOAT *>malloc(N*sizeof(FLOAT))
		for k in range(N):
			s_vecs_data[i][k] = 0.0
	s_vecs_data = &s_vecs_data[0]

	for i in range(size_max):
		s_vecs_indices[i] = <INT *>malloc(N*sizeof(INT))
		for k in range(N):
			s_vecs_indices[i][k] = 0
	s_vecs_indices = &s_vecs_indices[0]

	for i in range(size_max):
		s_vecs_indptr[i] = <INT *>malloc(2*sizeof(INT))
		for k in range(2):
			s_vecs_indptr[i][k] = 0
	s_vecs_indptr = &s_vecs_indptr[0]

	for i in range(size_max):
		y_vecs[i] = <FLOAT *>malloc(N*sizeof(FLOAT))
		for k in range(N):
			y_vecs[i][k] = 0.0
	y_vecs = &y_vecs[0]

	for i in range(size_max):
		y_vecs_data[i] = <FLOAT *>malloc(N*sizeof(FLOAT))
		for k in range(N):
			y_vecs_data[i][k] = 0.0
	y_vecs_data = &y_vecs_data[0]

	for i in range(size_max):
		y_vecs_indices[i] = <INT *>malloc(N*sizeof(INT))
		for k in range(N):
			y_vecs_indices[i][k] = 0
	y_vecs_indices = &y_vecs_indices[0]

	for i in range(size_max):
		y_vecs_indptr[i] = <INT *>malloc(2*sizeof(INT))
		for k in range(2):
			y_vecs_indptr[i][k] = 0
	y_vecs_indptr = &y_vecs_indptr[0]

	if qn == 1:
		while prev_err_global - error >= 0.00000001 and counter < 5:

			avg_m = 0.0
			m_num_near_0 = 0
			for i in range(I):
				for k in range(K):
					avg_m += M_ptr[i][k]
					if M_ptr[i][k] < zero_eps:
						m_num_near_0 += 1
			avg_m = avg_m / <FLOAT>(I*K)
			
			avg_c = 0.0
			c_num_near_0 = 0
			for j in range(J):		
				for k in range(K):
					avg_c += C_ptr[j][k] + 1.0
					if -zero_eps < C_ptr[j][k] < zero_eps:
						c_num_near_0 += 1
			avg_c = (avg_c / <FLOAT>(J*K)) - 1.0
			
			mc_num_gt0 = 0
			avg_mc = 0.0
			for i in range(I):
				for j in range(J):
					for k in range(K):
						avg_mc += M_ptr[i][k]*C_ptr[j][k] + 1.0
						if M_ptr[i][k]*C_ptr[j][k] > 0.0:
							mc_num_gt0 += 1
			avg_mc = (avg_mc / <FLOAT>(I*J*K)) - 1.0
			
			avg_x = 0.0
			avg_r = 0.0
			avg_xr = 0.0
			num_x_one = 0
			for i in range(I):
				for j in range(J):
					avg_x += X_ptr[i][j]
					if X_ptr[i][j] == 1.0:
						num_x_one += 1
					avg_r += R_ptr[i][j]
					avg_xr += X_ptr[i][j]*R_ptr[i][j]
			avg_x = avg_x / <FLOAT>(I*J)
			avg_r = avg_r / <FLOAT>(I*J)
			avg_xr = avg_xr / <FLOAT>(I*J)

			print "***", "Percentage of x's equal to 1:", "{:.4f}".format(num_x_one / <FLOAT>(I*J))
			print "***", "Number of values near zero:"
			print "\tM:", m_num_near_0, "/", I*K, "; C:", c_num_near_0, "/", J*K
			print "***", "Average values:"
			print "\tM =", avg_m, "; C =", avg_c, "; MC =", avg_mc, "; MC_gt0 =", mc_num_gt0, "; R =", avg_r, "; X =", avg_x, "; XR =", avg_xr
			print ""
			
			prev_err_global = error
				
			error = predict.get_R_E_and_Grad_C_omp(grad,
						M_data, M_indices, M_indptr, C_ptr,
						X_ptr, R_ptr, I, J, K, 
						normConstant)	
			counter += 1
			num_stored = 0
			matmath_nullptr.vec(grad, vec_grad, J, K)
			# print "\n***********************"
			# print "OPT M; error =", error
			# print "***********************\n"
			sp.compress_dbl_vec(vec_grad, vec_grad_data, vec_grad_indices, vec_grad_indptr, N)

			C_nnz = nnz.matrixNonZeros(C_ptr, J, K)
			matmath_nullptr.vec(C_ptr, vec_C, J, K)
			
			prelims_slmqn(vec_grad,
						vec_grad_data, vec_grad_indices, vec_grad_indptr,
						vec_C,
						diagP0, diagP0_indices, diagP0_indptr,
						diagP0_zero_indices, diagP0_zero_indptr,
						diagP1, diagP1_indices, diagP1_indptr,
						diagP1_zero_indices, diagP1_zero_indptr,
						diagP2_indices, diagP2_indptr,
						diagP3_indices, diagP3_indptr,
						eps, zero_eps, J, K, N, lower, upper)		

			gamma_ptr[0] = 0.0
			step_norm = 0.0
			avg_step = 0.0
			grad_sq_sum = 0.0
			numer = 0.0
			gamma_numer = 100.0
			
			for h in range(diagP0_indptr[1]):
				grad_sq_sum += vec_grad[diagP0_indices[h]] * vec_grad[diagP0_indices[h]]
			
			grad_norm = sqrt(grad_sq_sum)
			gamma_denom = grad_norm
			gamma_ptr[0] = 1000.0

			#####################################################
			# Compute search direction
			# The function direction_slmqn computes the search direction.
			direction_slmqn(vec_D, 
						vec_D_data, vec_D_indices, vec_D_indptr,
						vec_C, vec_grad, vec_grad_data, vec_grad_indices, vec_grad_indptr,
						s_vecs, s_vecs_data, s_vecs_indices, s_vecs_indptr,
						y_vecs, y_vecs_data, y_vecs_indices, y_vecs_indptr,
						diagP0, diagP0_indices, diagP0_indptr,
						diagP0_zero_indices, diagP0_zero_indptr, 
						diagP1, diagP1_indices, diagP1_indptr,
						diagP1_zero_indices, diagP1_zero_indptr, 
						diagP2_indices, diagP2_indptr,
						diagP3_indices, diagP3_indptr,
						rho, gamma_ptr[0], Z, num_stored, eps, zero_eps,
						N, lower, upper, sign)

			gTd = 0.0
			for h in range(vec_D_indptr[1]):
				gTd += vec_D_data[h] * vec_grad[vec_D_indices[h]]

			print "\n######################################################"
			print "\nC MATRIX;", " K =", K
			#######################################################

			t = 0
# 			print "P0_nnz =", diagP0_indptr[1], "; P1_nnz:", diagP1_indptr[1], "; P2_nnz:", diagP2_indptr[1], "; P3_nnz =", diagP3_indptr[1], "; P4_nnz =", diagP4_indptr[1], "; P5_nnz =", diagP5_indptr[1]
			print "*** Total =", diagP0_indptr[1] + diagP1_indptr[1] + diagP2_indptr[1] + diagP3_indptr[1]
			print ""
			print "gamma_0 =", gamma
			#print "chi =", chi
			print "grad_norm_0 =", grad_norm
			###sys.stdout.flush()
			print ""
			print "***", "Percentage of x's equal to 1:", "{:.4f}".format(num_x_one / <FLOAT>(I*J))
			print "***", "Number of values near zero:"
			print "\tM:", m_num_near_0, "/", I*K, "; C:", c_num_near_0, "/", J*K
			print "***", "Average values:"
			print "\tM =", avg_m, "; C =", avg_c, "; MC =", avg_mc, "; MC_gt0 =", mc_num_gt0, "; R =", avg_r, "; X =", avg_x, "; XR =", avg_xr
			print ""

			print "\tt:", t, "; error:", "{:.9f}".format(error), "; K:", K, "; gTd =", gTd
			counter += 1
			
			while t < t_max:
				if isNaN(gTd):
					print "\n\t***" ,"gTd NaN !!!!!!!!!","***\n"
				if gTd >= gTd_thresh:
					break
				
				prev_err_nr = error
				#print "\n\tt:", t, "; start error =", prev_err_nr 

				for n in range(N):
					vec_grad_old[n] = vec_grad[n]
				for n in range(N):
					vec_C_old[n] = vec_C[n]

				alpha1 = 1.0
				alpha_max = 10000000.0
				a_iter_ptr[0] = 1

				alpha = linesearch.armijo2_C_nor(alpha1, alpha_max, c1,
							 error, gTd, C_ptr, C_test, 
							 M_ptr, M_data, M_indices, M_indptr,
							 X_ptr, R_ptr,
							 vec_D, vec_D_data, vec_D_indices, vec_D_indptr,
							 normConstant, I, K, J, a_iter_ptr, 
							 lower, upper)

				avg_step = 0.0
				for j in range(J):
					for k in range(K):
						old_c = C_ptr[j][k]
						C_ptr[j][k] += alpha * vec_D[j*K + k]
						avg_step += fabs(alpha * vec_D[j*K + k]) 
						if C_ptr[j][k] > upper:
							C_ptr[j][k] = upper
						elif C_ptr[j][k] < lower:
							C_ptr[j][k] = lower
						distance[0] += fabs(C_ptr[j][k] - old_c)
						num_steps[0] += 1

				avg_step = avg_step / <FLOAT>N
				# error = predict.get_R_E_and_grad_C_2(grad,
				# 			C_ptr, M_ptr, M_data, M_indices, M_indptr,
				# 			X_ptr, R_ptr, error, I, J, K, 
				# 			normConstant)
				error = predict.get_R_E_and_Grad_C_omp(grad,
							M_data, M_indices, M_indptr, C_ptr, 
							X_ptr, R_ptr, I, J, K, 
							normConstant)
				print "\t\t<<< step: " + str(t) + ";", "a:", "{:.4f}".format(alpha) + "; gam =", "{:.5f}".format(gamma) + ";", 
				print "avg_s =", "{:.5f}".format(avg_step) + "; tot_s =", "{:.5f}".format(avg_step*<FLOAT>N), "; #strd:", num_stored, "; yTy = {:.6f}".format(yTy), 
				print "; sTy = {:.6f}".format(sTy), ">>>"
				C_nnz = nnz.matrixNonZeros(C_ptr, J, K)
				matmath_nullptr.vec(C_ptr, vec_C, J, K)
				matmath_nullptr.vec(grad, vec_grad, J, K)
	
				sp.compress_dbl_vec(vec_grad, vec_grad_data, vec_grad_indices, vec_grad_indptr, N)
		
				prelims_slmqn(vec_grad,
							vec_grad_data, vec_grad_indices, vec_grad_indptr,
							vec_C,
							diagP0, diagP0_indices, diagP0_indptr,
							diagP0_zero_indices, diagP0_zero_indptr,
							diagP1, diagP1_indices, diagP1_indptr,
							diagP1_zero_indices, diagP1_zero_indptr,
							diagP2_indices, diagP2_indptr,
							diagP3_indices, diagP3_indptr,
							eps, zero_eps, J, K, N, lower, upper)	
				grad_sq_sum = 0.0
				for h in range(diagP0_indptr[1]):
					grad_sq_sum += vec_grad[diagP0_indices[h]] * vec_grad[diagP0_indices[h]]
				grad_norm = sqrt(grad_sq_sum)								
				
				# Discard s and y vectors if necessary
				if diagP0_indptr[1] > 0:
					if num_stored >= size_max:
						num_stored = Z-1
						#discard the oldest s vectors; store newest
						for h in range(Z-1):
							for k in range(K*J):
								s_vecs[h][k] = s_vecs[h+(size_max-Z+1)][k]
		
						#discard the oldest y vectors; store newest
						for h in range(Z-1):
							for k in range(K*J):
								y_vecs[h][k] = y_vecs[h+(size_max-Z+1)][k]

						#discard the oldest s_data vectors
						for h in range(Z-1):
							for k in range(K*J):
								s_vecs_data[h][k] = s_vecs_data[h+(size_max-Z+1)][k]

						#discard the oldest s_indices vectors
						for h in range(Z-1):
							for k in range(K*J):
								s_vecs_indices[h][k] = s_vecs_indices[h+(size_max-Z+1)][k]

						#discard the oldest s_indptr vectors
						for h in range(Z-1):
							for k in range(2):
								s_vecs_indptr[h][k] = s_vecs_indptr[h+(size_max-Z+1)][k]

						#discard the oldest y_data vectors
						for h in range(Z-1):
							for k in range(K*J):
								y_vecs_data[h][k] = y_vecs_data[h+(size_max-Z+1)][k]				

						#discard the oldest y_indices vectors
						for h in range(Z-1):
							for k in range(K*J):
								y_vecs_indices[h][k] = y_vecs_indices[h+(size_max-Z+1)][k]

						#discard the oldest y_indptr vectors
						for h in range(Z-1):
							for k in range(2):	
								y_vecs_indptr[h][k] = y_vecs_indptr[h+(size_max-Z+1)][k]
	
						#discard the oldest rho vectors
						for h in range(Z-1):
							rho[h] = rho[h+(size_max-Z+1)]
					
					for h in range(diagP0_zero_indptr[1]):
						y_vecs[num_stored][diagP0_zero_indices[h]] = 0.0
					for h in range(diagP0_indptr[1]):
						y_vecs[num_stored][diagP0_indices[h]] = vec_grad[diagP0_indices[h]] - vec_grad_old[diagP0_indices[h]]
					for h in range(diagP0_zero_indptr[1]):
						s_vecs[num_stored][diagP0_zero_indices[h]] = 0.0					
					for h in range(diagP0_indptr[1]):
						s_vecs[num_stored][diagP0_indices[h]] = fabs(vec_C[diagP0_indices[h]]) - fabs(vec_C_old[diagP0_indices[h]])

					sp.compress_dbl_vec(s_vecs[num_stored], s_vecs_data[num_stored], 
										s_vecs_indices[num_stored], 
										s_vecs_indptr[num_stored], N)
					sp.compress_dbl_vec(y_vecs[num_stored], y_vecs_data[num_stored], 
										y_vecs_indices[num_stored], 
										y_vecs_indptr[num_stored], N)		
					sTy = 0.0
					yTy = 0.0
					for h in range(s_vecs_indptr[num_stored][1]):
						#sTs += s_vecs_data[num_stored][h] * s_vecs_data[num_stored][h]
						sTy += y_vecs[num_stored][s_vecs_indices[num_stored][h]] * s_vecs_data[num_stored][h]
					for h in range(y_vecs_indptr[num_stored][1]):
						yTy += y_vecs_data[num_stored][h] * y_vecs_data[num_stored][h]
					if yTy == 0.0 or sTy == 0.0:
						#print "Opt C;", "yTy == 0.0 or sTy == 0.0"
						break
					else:
						gamma_numer = sTy
						gamma_denom = yTy
						gamma_ptr[0] = gamma_numer / gamma_denom
					#gamma_ptr[0] = gamma_denom / gamma_numer
						rho[num_stored] = 1.0/sTy
						num_stored += 1
							
				#####################################################
				# Compute search direction
				# The function direction_slmqn computes the search direction.
				#####print "Opt C", 240
				####sys.stdout.flush()
				direction_slmqn(vec_D, 
							vec_D_data, vec_D_indices, vec_D_indptr,
							vec_C, 
							vec_grad, vec_grad_data, vec_grad_indices, vec_grad_indptr,
							s_vecs, s_vecs_data, s_vecs_indices, s_vecs_indptr,
							y_vecs, y_vecs_data, y_vecs_indices, y_vecs_indptr,
							diagP0, diagP0_indices, diagP0_indptr,
							diagP0_zero_indices, diagP0_zero_indptr, 
							diagP1, diagP1_indices, diagP1_indptr,
							diagP1_zero_indices, diagP1_zero_indptr, 
							diagP2_indices, diagP2_indptr,
							diagP3_indices, diagP3_indptr,
							rho, gamma_ptr[0], Z, num_stored, eps, zero_eps,
							N, lower, upper, sign)
# 				gTd = matmath_sparse.mul_1d_1d(vec_grad_data, 
# 										vec_grad_indices, vec_grad_indptr,
# 										vec_D_data, vec_D_indices, vec_D_indptr)
				gTd = 0.0
				for h in range(vec_D_indptr[1]):
					gTd += vec_D_data[h] * vec_grad[vec_D_indices[h]]
				if (prev_err_nr - error)/prev_err_nr < err_thresh:
					print "\t*** break! (error diff too small) ***"

					print "\terror:", "{:.8f}".format(error), "; error diff:", "{:.10f}".format(fabs(prev_err_nr - error)), "; nnz:", C_nnz, "/", K*J, "; gn:", "{:.6f}".format(grad_norm), "; gTd:", "{:.8f}".format(gTd), "; K:", K, "; itr:", numIters
					break

				t += 1
				#######################################################
				######print "Opt C", "**** gTd =", gTd
				
		# 			print "\tt:", t, "; error:", "{:.5f}".format(error), "; error diff:", "{:.12f}".format(prev_err_nr - error), "; nnz:", C_nnz, "/", K*J, ";  gTd:","{:.6f}".format(gTd), "; c/g:","{:.3f}".format(c_norm) + "/" + "{:.3f}".format(grad_norm), "; s/y:", "{:.6f}".format(s_vec_norm) + "/" + "{:.6f}".format(y_vec_norm), "; K:", K, "; itr:", numIters
				print "\t  *** error:", "{:.8f}".format(error), "; error diff:", "{:.10f}".format((prev_err_nr - error)/prev_err_nr), "; nnz:", C_nnz, "/", K*J, "; gn:", "{:.6f}".format(grad_norm), "; gTd:", "{:.6f}".format(gTd), "; K:", K, "; itr:", numIters
				print "\t  *** P0:" + str(diagP0_indptr[1]),
				print "; P1:" + str(diagP1_indptr[1]),
				print "; P2:" + str(diagP2_indptr[1]), 
				print "; P3:" + str(diagP3_indptr[1]), 
				print "; num_stored =", num_stored
		# 		for n in range(N):
		# 			diagH[n] = 1.0/(vec_D[n]/(-vec_grad[n]))
		if cg == 1 and num_stored > 0 and gTd < 0.0:
			####sys.stdout.flush()
			#print "Opt C", 300
			#sys.stdout.flush()
			precondition = 1
			for n in range(N):
				diagPre[n] = gamma_ptr[0]
			error = cg_C_nor(C_ptr, vec_C, vec_C_old, C_test, 
					 M_ptr, M_data, M_indices, M_indptr,
					 X_ptr,  R_ptr, grad,  vec_grad,
					 vec_grad_data,  vec_grad_indices,  vec_grad_indptr,
					 vec_grad_old,
					 vec_z, vec_z_data, vec_z_indices, vec_z_indptr,
					 vec_z_old,
					 s_vecs[num_stored-1],  y_vecs[num_stored-1],  Hy,
					 vec_D,  vec_D_data,  vec_D_indices,  vec_D_indptr,
					 diagPre,  gTd,
					 gamma_ptr,  error,  cg_itr_max,  cg_itrs_ptr,  nr_itrs_ptr,
					 I,  K,  J, normConstant, objFunc, precondition,
					 diagP0,  diagP0_indices,  diagP0_indptr,
					 diagP0_zero_indices,  diagP0_zero_indptr,
					 diagP1,  diagP1_indices,  diagP1_indptr,
					 diagP1_zero_indices,  diagP1_zero_indptr,
					 diagP2_indices,  diagP2_indptr,
					 diagP3_indices,  diagP3_indptr,
					 eps,  distance,  num_steps,  lower,  upper)

			print "   %%% E:", "{:.8f}".format(error), "; E diff:", "{:.12f}".format(prev_err_nr - error), "; nnz:", C_nnz, "/", K*J, "; gn:", "{:.6f}".format(grad_norm), "; gTd:", "{:.6f}".format(gTd), "; K:", K, "; itr:", numIters	
# 		print "\n\n************** ",
# 		print "This round's error diff =", "{:.10f}".format(prev_err_global - error),
# 		print " **************\n"

	#####print "Opt C", 400
	print "\n######################################################"
	print "######################################################\n"
	####sys.stdout.flush()	
	if cg == 1 and qn == 0:
		precondition = 0
		matmath_nullptr.vec(C_ptr, vec_C, J, K)
# 		if K > 1:
# 			error = predict.get_R_E_and_grad_C(grad, M_ptr, C_ptr, 
# 					X_ptr, R_ptr, error, I, J, K, normConstant)
# 		else:
# 			error = predict.get_R_E_and_grad_C_one(grad, M_ptr, C_ptr, 
# 					X_ptr, R_ptr, error, I, J, normConstant)
# 		print "******** pre-pre-cg_C grad_sq_sum =", grad_sq_sum, "********"
# 		print "******** pre-pre-cg_C grad_norm =", grad_norm, "********"
		# error = predict.get_R_E_and_grad_C_2(grad,
		# 			C_ptr, M_ptr, M_data, M_indices, M_indptr,
		# 			X_ptr, R_ptr, error, I, J, K, 
		# 			normConstant)
		#print "\n######################################################"
		#print "######################################################\n"
		#print "******************************"
		print "OPT C; It's CG time!!!"
		error = predict.get_R_E_and_Grad_C_omp(grad,
					M_data, M_indices, M_indptr, C_ptr, 
					X_ptr, R_ptr, I, J, K, 
					normConstant)
		#grad_nnz = nnz.matrixNonZeros(grad, K, J)
		####sys.stdout.flush()
		matmath_nullptr.vec(grad, vec_grad, J, K)
		sp.compress_dbl_vec(vec_grad, vec_grad_data, vec_grad_indices, vec_grad_indptr, N)
		grad_sq_sum = 0.0
		for n in range(N):
			grad_sq_sum += vec_grad[n] * vec_grad[n]
		grad_norm = sqrt(grad_sq_sum)
# 		print "******** pre-cg_C Error =", error, "********"
# 		print "******** pre-cg_C grad_sq_sum =", grad_sq_sum, "********"
# 		print "******** pre-cg_C =", grad_norm, "********\n"
# 		print "******** pre-cg_C =", grad_norm, "********\n"
		#gamma_ptr[0] = 0.001 / grad_norm
		gamma_ptr[0] = 1000.0
		prev_err_nr = error
		#print "\n"
		#print "\n\n\n", "\t\t\t", "pre-error =", error, "\t\t\t", "\n\n\n"
		for n in range(N):
			diagPre[n] = gamma_ptr[0]
		error = cg_C_nor(C_ptr, vec_C, vec_C_old,
				C_test, M_ptr, M_data, M_indices, M_indptr, X_ptr, R_ptr,
				grad, vec_grad,
				vec_grad_data, vec_grad_indices, vec_grad_indptr,
				vec_grad_old,
				vec_z, vec_z_data, vec_z_indices, vec_z_indptr, vec_z_old,
				s_vecs[0], y_vecs[0], Hy,
				vec_D, vec_D_data, vec_D_indices, vec_D_indptr,
				diagPre, gTd,
				gamma_ptr, error, 20, cg_itrs_ptr, nr_itrs_ptr,
				I, K, J,
				normConstant, objFunc, precondition,
				diagP0, diagP0_indices, diagP0_indptr,
				diagP0_zero_indices, diagP0_zero_indptr,
				diagP1, diagP1_indices, diagP1_indptr,
				diagP1_zero_indices, diagP1_zero_indptr,
				diagP2_indices, diagP2_indptr,
				diagP3_indices, diagP3_indptr,
				eps, distance, num_steps, lower, upper)
		C_nnz = nnz.matrixNonZeros(C_ptr, J, K)
		print "$$$ E:", "{:.8f}".format(error), "; E diff:", "{:.12f}".format(prev_err_nr - error), "; nnz:", C_nnz, "/", K*J, "; gn:", "{:.9f}".format(grad_norm),
		"; K:", K, "; itr:", numIters
# 		print "\n****************** ",
# 		print "Global error diff =", "{:.7f}".format(prev_err_global - error),
	print "\n######################################################"
	#print "\nerror =", error, "; error diff =", original_error - error, "; K:", K, "\n"
	print "######################################################\n"
	
	#print "OC", 5
	#sys.stdout.flush()
	dealloc_matrix_2(C_old, J)	
	dealloc_matrix_2(C_test, J)
	
	dealloc_vector(vec_C)
	dealloc_vector(vec_C_old)

	dealloc_vector(M_data)
	dealloc_vec_int(M_indices)
	dealloc_vec_int(M_indptr)
	
	dealloc_vector(Hy)
	dealloc_vector(diagH)
	dealloc_vector(diagPre)
	dealloc_vector(rho)

	dealloc_matrix_2(grad, J)
	
	dealloc_vector(vec_grad)
	dealloc_vector(vec_grad_data)
	dealloc_vec_int(vec_grad_indices)
	dealloc_vec_int(vec_grad_indptr)
	dealloc_vector(vec_grad_old)
	
	dealloc_vector(vec_z)
	dealloc_vector(vec_z_data)
	dealloc_vec_int(vec_z_indices)
	dealloc_vec_int(vec_z_indptr)
	dealloc_vector(vec_z_old)
	
	dealloc_vector(vec_D)
	dealloc_vector(vec_D_data)
	dealloc_vec_int(vec_D_indices)
	dealloc_vec_int(vec_D_indptr)
	
	dealloc_vector(diagP0)
	dealloc_vec_int(diagP0_indices)
	dealloc_vec_int(diagP0_indptr)
	dealloc_vec_int(diagP0_zero_indices)
	dealloc_vec_int(diagP0_zero_indptr)
	###print "Opt C dealloc", 29
	dealloc_vector(diagP1)
	dealloc_vec_int(diagP1_indices)
	dealloc_vec_int(diagP1_indptr)
	dealloc_vec_int(diagP1_zero_indices)
	dealloc_vec_int(diagP1_zero_indptr)
# 	dealloc_vector(diagP2)
	###print "Opt C dealloc", 31
	dealloc_vec_int(diagP2_indices)
	dealloc_vec_int(diagP2_indptr)
	###print "Opt C dealloc", 32
	dealloc_vec_int(diagP3_indices)
	dealloc_vec_int(diagP3_indptr)

	dealloc_matrix_2(s_vecs, size_max)
	dealloc_matrix_2(s_vecs_data, size_max)
	dealloc_mat_2_int(s_vecs_indices, size_max)
	dealloc_mat_2_int(s_vecs_indptr, size_max)
	dealloc_matrix_2(y_vecs, size_max)
	dealloc_matrix_2(y_vecs_data, size_max)
	dealloc_mat_2_int(y_vecs_indices, size_max)
	dealloc_mat_2_int(y_vecs_indptr, size_max)
	return error
	
	
cdef FLOAT optimize_M_nor(FLOAT** X_ptr, FLOAT** R_ptr, FLOAT** M_ptr, 
					FLOAT** C_ptr,
					INT I, INT J, INT K, FLOAT* normConstants, 
					INT numIters, bint qn, bint cg, FLOAT* distance, INT* num_steps,
					FLOAT lower, FLOAT upper):
	print "We're in optimize_M!"
	cdef FLOAT E = 0.0
	cdef FLOAT error = 0.0
	print "Error:", error, "\n"
	cdef FLOAT initial_err, prev_err, alpha0 
	cdef INT NaN = 0
	cdef FLOAT delta = 1.0
	cdef unint i,j,k,k1,k2,h,h1,h2
	cdef INT Z = 5
	cdef INT t = 0
	cdef t_max = 10
	cdef INT size_max = 20
	cdef INT counter, counter_old
	cdef FLOAT gTd, s_vec_norm, numer, yTy, sTy, sTs, dTy
	yTy = 1000000.0
	sTy = 1.0
	sTs = 1.0
	gTd = 0.0
	s_vec_norm = 0.0
	cdef FLOAT alpha = 0.0
	cdef FLOAT eps = 0.0000001
	cdef FLOAT zero_eps = 0.001
	cdef FLOAT err_thresh = 0.0000001
	
	cdef FLOAT* C_data = <FLOAT *>malloc(J*K*sizeof(FLOAT))
	cdef INT* C_indices = <INT *>malloc(J*K*sizeof(INT))
	cdef INT* C_indptr = <INT *>malloc((J+1)*sizeof(INT))
	#sp.compress_dbl_mat(C_ptr, C_lt0_data, C_lt0_indices, C_lt0_indptr, J, K)
	C_indptr[0] = 0
	counter = 0
	cdef INT row_end = 0

	for j in range(J):
# 		C_lt0_indptr[j+1] = C_lt0_indptr[j]
# 		C_gt0_indptr[j+1] = C_gt0_indptr[j]
		row_end = 0
		for k in range(K):
			if C_ptr[j][k] != 0.0:
				C_data[counter] = C_ptr[j][k]
				C_indices[counter] = k
				counter += 1
				row_end += 1
		C_indptr[j+1] = C_indptr[j] + row_end

	cdef FLOAT* m_old = <FLOAT *>calloc(K,sizeof(FLOAT))
	cdef FLOAT * m_test = <FLOAT *>calloc(K,sizeof(FLOAT))
	# for k in range(K):
	# 	m_old[k] = 0.0
	# 	m_test[k] = 0.0

# 	cdef FLOAT * m_zero_data = <FLOAT *>malloc(K*sizeof(FLOAT))
# 	cdef FLOAT * m_zero_indices = <FLOAT *>malloc(K*sizeof(FLOAT))
# 	cdef FLOAT * m_zero_indptr = <FLOAT *>malloc(2*sizeof(FLOAT))
# 	for k in range(K):
# 		M_ptr[i][k] = 0.0
	
# 	cdef INT * C_zero_indices = <INT*>malloc(J*K*sizeof(INT))
# 	for k in range(J*K):
# 		C_zero_indices[k] = 0
# 	cdef INT * C_zero_indptr = <INT*>malloc(J*sizeof(INT))
# 	for k in range(J*K):
# 		C_zero_indptr[k] = 0
	
	#cdef FLOAT * prod = <FLOAT *>calloc(J*sizeof(FLOAT))
	# for j in range(J):
	# 	prod[j] = 0.0
	
# 	compress_dbl_mat_eq0(C_ptr, C_zero_indices, C_zero_indptr, J, K)
			
	cdef FLOAT * d = <FLOAT *>calloc(K,sizeof(FLOAT))
	cdef FLOAT * grad_old = <FLOAT *>calloc(K,sizeof(FLOAT))
	cdef FLOAT * grad = <FLOAT *>calloc(K,sizeof(FLOAT))
	# for k in range(K):
	# 	grad_old[k] = 0.0
	# 	grad[k] = 0.0
	# 	d[k] = 0.0
	#print "Opt M", 120
	#sys.stdout.flush()
	cdef FLOAT * d_data = <FLOAT *>calloc(K,sizeof(FLOAT))
	cdef INT * d_indices = <INT *>calloc(K,sizeof(INT))
	cdef INT * d_indptr = <INT *>calloc(2,sizeof(INT))
	# for k in range(K):
	# 	d_data[k] = 0.0
	# for k in range(K):
	# 	d_indices[k] = 0
	# d_indptr[0] = 0
	# d_indptr[1] = 0

	cdef INT grad_nnz = K
	
	cdef FLOAT * grad_data = <FLOAT *>calloc(K,sizeof(FLOAT))
	cdef INT * grad_indices = <INT *>calloc(K,sizeof(INT))
	cdef INT * grad_indptr = <INT *>calloc(2,sizeof(INT))
	# for k in range(K):
	# 	grad_data[k] = 0.0
	# for k in range(K):
	# 	grad_indices[k] = 0
	# grad_indptr[0] = 0
	# grad_indptr[1] = 0
	##print "Opt M", 126
	###sys.stdout.flush()
	cdef FLOAT * z = <FLOAT *>calloc(K,sizeof(FLOAT))
	cdef FLOAT * z_data = <FLOAT *>calloc(K,sizeof(FLOAT))
	cdef INT * z_indices = <INT *>calloc(K,sizeof(INT))
	cdef INT * z_indptr = <INT *>calloc(2,sizeof(INT))
	# for k in range(K):
	# 	z_data[k] = 0.0
	# for k in range(K):
	# 	z_indices[k] = 0
	# z_indptr[0] = 0
	# z_indptr[1] = 0
	cdef FLOAT * z_old = <FLOAT *>calloc(K,sizeof(FLOAT))
	# for k in range(K):
	# 	z_old[k] = 0.0
	##print "Opt M", 130
	##sys.stdout.flush()	

	cdef FLOAT* Hy = <FLOAT *>calloc(K,sizeof(FLOAT))
	# for k in range(K):
	# 	Hy[k] = 0.0
	cdef FLOAT * diagH = <FLOAT*>calloc(K,sizeof(FLOAT))
	# for k in range(K):
	# 	diagH[k] = 0.0
	cdef FLOAT * diagPre = <FLOAT*>calloc(K,sizeof(FLOAT))
	# for k in range(K):
	# 	diagPre[k] = 0.0	

	cdef FLOAT * diagP0 = <FLOAT*>calloc(K,sizeof(FLOAT))
	# for k in range(K):
	# 	diagP0[k] = 0.0
	cdef INT * diagP0_indices = <INT*>calloc(K,sizeof(INT))
	# for k in range(K):
	# 	diagP0_indices[k] = 0
	cdef INT * diagP0_indptr = <INT*>calloc(2,sizeof(INT))
	# diagP0_indptr[0] = 0
	# diagP0_indptr[1] = 0
	
	cdef INT * diagP0_zero_indices = <INT*>calloc(K,sizeof(INT))
	# for k in range(K):
	# 	diagP0_zero_indices[k] = 0
	cdef INT * diagP0_zero_indptr = <INT*>calloc(2,sizeof(INT))
	# diagP0_zero_indptr[0] = 0
	# diagP0_zero_indptr[1] = 0
	
	cdef FLOAT * diagP1 = <FLOAT*>calloc(K,sizeof(FLOAT))
	# for k in range(K):
	# 	diagP1[k] = 0.0
	cdef INT * diagP1_indices = <INT*>calloc(K,sizeof(INT))
	# for k in range(K):
	# 	diagP1_indices[k] = 0
	cdef INT * diagP1_indptr = <INT*>calloc(2,sizeof(INT))
	# diagP1_indptr[0] = 0
	# diagP1_indptr[1] = 0
	
	cdef INT * diagP1_zero_indices = <INT*>calloc(K,sizeof(INT))
	# for k in range(K):
	# 	diagP1_zero_indices[k] = 0
	cdef INT * diagP1_zero_indptr = <INT*>calloc(2,sizeof(INT))
	# diagP1_zero_indptr[0] = 0
	# diagP1_zero_indptr[1] = 0
	
# 	cdef FLOAT * diagP2 = <FLOAT*>malloc(K*sizeof(FLOAT))
# 	for n in range(K):
# 		diagP2[n] = 0.0
	cdef INT * diagP2_indices = <INT*>calloc(K,sizeof(INT))
	# for k in range(K):
	# 	diagP2_indices[k] = 0
	cdef INT * diagP2_indptr = <INT*>calloc(2,sizeof(INT))
	# diagP2_indptr[0] = 0
	# diagP2_indptr[1] = 0
# 	cdef INT * diagP2_zero_indices = <INT*>malloc(K*sizeof(INT))
# 	cdef INT * diagP2_zero_indptr = <INT*>malloc(2*sizeof(INT))
# 	diagP2_zero_indptr[0] = 0
# 	diagP2_zero_indptr[1] = 0
	
# 	cdef FLOAT * diagP3 = <FLOAT*>malloc(K*sizeof(FLOAT))
# 	for n in range(K):
# 		diagP3[n] = 0.0
	cdef INT * diagP3_indices = <INT*>calloc(K,sizeof(INT))
	# for k in range(K):
	# 	diagP3_indices[k] = 0
	cdef INT * diagP3_indptr = <INT*>calloc(2,sizeof(INT))
	# diagP3_indptr[0] = 0
	# diagP3_indptr[1] = 0

	
	cdef FLOAT * rho = <FLOAT *>calloc(size_max, sizeof(FLOAT))
	# for k in range(size_max):
	# 	rho[k] = 0.0	
	##sys.stdout.flush()
	#print "Opt M", 140
	#sys.stdout.flush()	
	###print "Opt M", 144
# 	cdef FLOAT * s_vec = <FLOAT*>malloc(K * sizeof(FLOAT))
# 	cdef FLOAT * y_vec = <FLOAT*>malloc(K * sizeof(FLOAT))
# 	for k in range(K):
# 		s_vec[k] = 0.0
# 		y_vec[k] = 0.0
# 	
# 	cdef FLOAT * s_vec_data = <FLOAT*>malloc(K * sizeof(FLOAT))
# 	cdef INT * s_vec_indices = <INT*>malloc(K * sizeof(INT))
# 	cdef INT * s_vec_indptr = <INT*>malloc(2 * sizeof(INT))
# 
# 	cdef FLOAT * y_vec_data = <FLOAT*>malloc(K * sizeof(FLOAT))
# 	cdef INT * y_vec_indices = <INT*>malloc(K * sizeof(INT))
# 	cdef INT * y_vec_indptr = <INT*>malloc(2 * sizeof(INT))

	
	cdef FLOAT ** s_vecs = <FLOAT **>malloc(size_max*sizeof(FLOAT*))
	for i in range(size_max):
		s_vecs[i] = <FLOAT *>calloc(K,sizeof(FLOAT))
		# for k in range(K):
		# 	s_vecs[i][k] = 0.0
	s_vecs = &s_vecs[0] 

	cdef FLOAT ** s_vecs_data = <FLOAT **>malloc(size_max*sizeof(FLOAT*))
	for i in range(size_max):
		s_vecs_data[i] = <FLOAT *>calloc(K,sizeof(FLOAT))
		# for k in range(K):
		# 	s_vecs_data[i][k] = 0.0
	s_vecs_data = &s_vecs_data[0] 

	cdef INT ** s_vecs_indices = <INT **>malloc(size_max*sizeof(INT*))
	for i in range(size_max):
		s_vecs_indices[i] = <INT *>calloc(K,sizeof(INT))
		# for k in range(K):
		# 	s_vecs_indices[i][k] = 0
	s_vecs_indices = &s_vecs_indices[0]
	##sys.stdout.flush()
	##print "Opt M", 160
	##sys.stdout.flush()	
	cdef INT ** s_vecs_indptr = <INT **>malloc(size_max*sizeof(INT*))
	for i in range(size_max):
		s_vecs_indptr[i] = <INT *>calloc(2,sizeof(INT))
		# for k in range(2):
		# 	s_vecs_indptr[i][k] = 0
	s_vecs_indptr = &s_vecs_indptr[0]	
	##sys.stdout.flush()
	#print "Opt M", 170
	#sys.stdout.flush()	
	cdef FLOAT ** y_vecs = <FLOAT **>malloc(size_max*sizeof(FLOAT*))
	for i in range(size_max):
		y_vecs[i] = <FLOAT *>calloc(K,sizeof(FLOAT))
		# for k in range(K):
		# 	y_vecs[i][k] = 0.0
	y_vecs = &y_vecs[0] 

	cdef FLOAT ** y_vecs_data = <FLOAT **>malloc(size_max*sizeof(FLOAT*))
	for i in range(size_max):
		y_vecs_data[i] = <FLOAT *>calloc(K,sizeof(FLOAT))
		# for k in range(K):
		# 	y_vecs_data[i][k] = 0.0
	y_vecs_data = &y_vecs_data[0] 
	##sys.stdout.flush()
	#print "Opt M", 184
	#sys.stdout.flush()	
	cdef INT ** y_vecs_indices = <INT **>malloc(size_max * sizeof(INT*))
	for i in range(size_max):
		y_vecs_indices[i] = <INT *>calloc(K,sizeof(INT))
		# for k in range(K):
		# 	y_vecs_indices[i][k] = 0
	y_vecs_indices = &y_vecs_indices[0]

	cdef INT ** y_vecs_indptr = <INT **>malloc(size_max*sizeof(INT*))
	for i in range(size_max):
		y_vecs_indptr[i] = <INT *>calloc(2,sizeof(INT))
		# for k in range(2):
		# 	y_vecs_indptr[i][k] = 0
	y_vecs_indptr = &y_vecs_indptr[0]
	##sys.stdout.flush()
	#print "Opt M", 190
	#sys.stdout.flush()		

# 	cdef FLOAT* S_data = <FLOAT*>malloc(K*J*sizeof(FLOAT))
# 	cdef INT* S_indices = <INT*>malloc(K*J*sizeof(INT))
# 	cdef INT* S_indptr = <INT*>malloc((K+1)*sizeof(INT))	

# 	cdef FLOAT* mi_data = <FLOAT*>calloc(K, sizeof(FLOAT))
# 	cdef INT* mi_indices = <INT*>calloc(K, sizeof(INT))
# 	cdef INT* mi_indptr = <INT*>malloc(2*sizeof(INT))
	
# 	cdef FLOAT* mi_eq0_data = <FLOAT*>calloc(K, sizeof(FLOAT))
# 	cdef INT* mi_eq0_indices = <INT*>calloc(K, sizeof(INT))
# 	cdef INT* mi_eq0_indptr = <INT*>malloc(2*sizeof(INT))
# 
# 	cdef FLOAT* cj_data = <FLOAT*>calloc(K, sizeof(FLOAT))
# 	cdef INT* cj_indices = <INT*>calloc(K, sizeof(INT))
# 	cdef INT* cj_indptr = <INT*>malloc(2*sizeof(INT))
# 	
# 	cdef FLOAT* cj_lt0_data = <FLOAT*>calloc(K, sizeof(FLOAT))
# 	cdef INT* cj_lt0_indices = <INT*>calloc(K, sizeof(INT))
# 	cdef INT* cj_lt0_indptr = <INT*>malloc(2*sizeof(INT))
# 	
# 	cdef FLOAT* cj_gt0_data = <FLOAT*>calloc(K, sizeof(FLOAT))
# 	cdef INT* cj_gt0_indices = <INT*>calloc(K, sizeof(INT))
# 	cdef INT* cj_gt0_indptr = <INT*>malloc(2*sizeof(INT))
# 
# 	cdef FLOAT* cj_eq0_data = <FLOAT*>calloc(K, sizeof(FLOAT))
# 	cdef INT* cj_eq0_indices = <INT*>calloc(K, sizeof(INT))
# 	cdef INT* cj_eq0_indptr = <INT*>malloc(2*sizeof(INT))
# 
# 	cdef FLOAT* mc_lt0 = <FLOAT*>calloc(K, sizeof(FLOAT))
# 	cdef FLOAT* mc_lt0_data = <FLOAT*>calloc(K, sizeof(FLOAT))
# 	cdef INT* mc_lt0_indices = <INT*>calloc(K, sizeof(INT))
# 	cdef INT* mc_lt0_indptr = <INT*>malloc(2*sizeof(INT))
# 
# 	cdef FLOAT* mc_gt0 = <FLOAT*>calloc(K, sizeof(FLOAT))
# 	cdef FLOAT* mc_gt0_data = <FLOAT*>calloc(K, sizeof(FLOAT))
# 	cdef INT* mc_gt0_indices = <INT*>calloc(K, sizeof(INT))
# 	cdef INT* mc_gt0_indptr = <INT*>malloc(2*sizeof(INT))
# 	
# 	cdef FLOAT* col_data = <FLOAT*>calloc(K, sizeof(FLOAT))
# 	cdef FLOAT* col_indices = <INT*>calloc(K, sizeof(INT))
# 	cdef FLOAT* col_indptr = <INT*>malloc(2*sizeof(INT))

	
	cdef FLOAT beta = 0.0
	cdef INT a_iter = 0
	cdef INT num_alphas = 0
	cdef INT* a_iter_ptr = &a_iter
	cdef FLOAT avg_a_iters = 0.0
	cdef INT num_stored = 0
	 
	cdef FLOAT gamma = 1.0
	cdef FLOAT* gamma_ptr = &gamma
	cdef FLOAT grad_sq_sum, q_val, avg_step, step_norm
	cdef FLOAT grad_len = 0.0
	cdef FLOAT grad_old_len = 0.0
	q_val = 0.0
	cdef FLOAT denom = 1.0
	cdef FLOAT c1 = 0.00001
	cdef FLOAT c2 = 0.9
	cdef FLOAT x_ratio = 1.0
	cdef FLOAT g_ratio = 1.0
	cdef FLOAT alpha1 = 1.0
	cdef FLOAT alpha_max = 10000000000.0
	cdef FLOAT prev_err_global = 1000000000000.0
	cdef FLOAT err_before_cg = 0.0
	cdef FLOAT sum_cg_err_diffs = 0.0
	cdef FLOAT y_norm, m_norm, init_gamma, max_grad, max_m
	cdef FLOAT total_avg_step = 0.0
	cdef FLOAT alpha_sum = 0.0
	cdef bint grad_break = 0
	cdef bint gTd_break = 0
	cdef FLOAT sign = -1.0
	cdef INT cg_itrs = 0
	cdef INT* cg_itrs_ptr = &cg_itrs
	cdef INT cg_itrs_sum = 0
	cdef INT nr_itrs = 0
	cdef INT* nr_itrs_ptr = &nr_itrs
	cdef INT precondition = 0
	cdef FLOAT old_m
	cdef FLOAT P0_grad_norm = 0.0
	cdef FLOAT P0_grad_sq_sum = 0.0
	cdef INT t_sum = 0
	cdef FLOAT original_err = 0.0
	cdef INT cg_itr_max = 40
	cdef FLOAT avg_mc = 0.0
	cdef FLOAT avg_m = 0.0
	cdef FLOAT avg_c = 0.0
	cdef FLOAT avg_x = 0.0
	cdef FLOAT avg_r = 0.0
	cdef bint m_nan = 0
	
	#with nogil, parallel():
	for i in range(I):
		alpha_sum = 0.0
		num_alphas = 0
		avg_a_iters = 0.0
		counter = 0
		t_sum = 0
		cg_itrs_sum = 0
		sum_cg_err_diffs = 0.0
		prev_err_global = 1000000000000.0
		
		precondition = 0
		##print "Opt M;", 1999
		if qn == 1:
			#Quasi-Newton Part
			while counter < 1:
				if grad_break == 1:
					grad_break = 0
					#print "\t*** grad_break ***"
					break
				if gTd_break == 1:
					gTd_break = 0
					#print "\t*** gtd_break ***"
					break
				if m_nan == 1:
					m_nan = 0
					break
				counter_old = counter
				prev_err_global = error
				# error = predict.r_e_and_grad_m_2(grad, M_ptr[i], C_ptr,
				# 		C_data, C_indices, C_indptr, X_ptr[i], R_ptr[i], 
				# 		error, J, K, normConstants[i])
				error = predict.get_r_e_and_grad_m_omp(grad, M_ptr[i],
						C_data, C_indices, C_indptr, X_ptr[i], R_ptr[i],
						J, K, normConstants[i])

# 				if K > 1:
# 					error = predict.r_e_and_grad_m(grad, M_ptr[i], 
# 							C_ptr, C_data, C_indices, C_indptr,  
# 							X_ptr[i], R_ptr[i], error, J, K, normConstants[i])
# 				else:
# 					error = predict.r_e_and_grad_m_one(grad, M_ptr[i], C_ptr,
# 							X_ptr[i], R_ptr[i], error, J, normConstants[i])	
# 				error = predict.r_e_and_grad_m(grad, C_ptr,
# 						cj_lt0_data, cj_lt0_indices, cj_lt0_indptr,
# 						cj_gt0_data, cj_gt0_indices, cj_gt0_indptr,
# 						cj_eq0_data, cj_eq0_indices, cj_eq0_indptr,
# 						M_ptr[i],
# 						mi_eq0_data, mi_eq0_indices, mi_eq0_indptr,
# 						mc_lt0, mc_lt0_data, mc_lt0_indices, mc_lt0_indptr,
# 						mc_gt0, mc_gt0_data, mc_gt0_indices, mc_gt0_indptr,
# 						col_data, col_indices, col_indptr,
# 						prod_lt0_frwd, prod_lt0_bkwd,
# 						prod_gt0_frwd, prod_gt0_bkwd,
# 						X_ptr[i], R_ptr[i],
# 						J, K, normConstant)
				if counter == 0:
					original_err = error
				
				counter += 1
				if prev_err_global - error <= 0.00000001 and counter > 1:
					break
										
				sp.compress_dbl_vec(grad, grad_data, grad_indices, grad_indptr, K)

				prelims_slmqn(grad, grad_data, grad_indices, grad_indptr,
							M_ptr[i],
							diagP0, diagP0_indices, diagP0_indptr,
							diagP0_zero_indices, diagP0_zero_indptr,
							diagP1, diagP1_indices, diagP1_indptr,
							diagP1_zero_indices, diagP1_zero_indptr,
							diagP2_indices, diagP2_indptr,
							diagP3_indices, diagP3_indptr,
							eps, zero_eps, J, K, K, lower, upper)

				gamma_ptr[0] = 0.0
				numer = 0.0
				grad_sq_sum = 0.0
				q_val = 0.0
				step_norm = 0.0
				gamma_ptr[0] = 1.0
				direction_slmqn(d, d_data, d_indices, d_indptr,
							M_ptr[i], grad, grad_data, grad_indices, grad_indptr,
							s_vecs, s_vecs_data, s_vecs_indices, s_vecs_indptr,
							y_vecs, y_vecs_data, y_vecs_indices, y_vecs_indptr,
							diagP0, diagP0_indices, diagP0_indptr,
							diagP0_zero_indices, diagP0_zero_indptr, 
							diagP1, diagP1_indices, diagP1_indptr,
							diagP1_zero_indices, diagP1_zero_indptr, 
							diagP2_indices, diagP2_indptr,
							diagP3_indices, diagP3_indptr,
							rho, gamma_ptr[0], Z, num_stored, 
							eps, zero_eps, K, lower, upper, sign)
				gTd = 0.0
				for h in range(d_indptr[1]):
					gTd += d_data[h] * grad[d_indices[h]]
					
				#######################################################

				t = 0
				num_stored = 0
				total_avg_step = 0.0
				while t < t_max:
					prev_err = error
					for k in range(K): 
						m_old[k] = M_ptr[i][k]
						m_test[k] = M_ptr[i][k]
					for k in range(K):
						grad_old[k] = grad[k]
					if isNaN(gTd):
						m_nan = 1
						break
						
					if gTd >= 0.0:
						gTd_break = 1
						break
					a_iter_ptr[0] = 0
					alpha = linesearch.armijo2_M_nor(alpha1, alpha_max, 
								c1, error, gTd,
								M_ptr[i], m_test, C_ptr, C_data, C_indices, C_indptr, 
								X_ptr[i], R_ptr[i],
								d, d_data, d_indices, d_indptr,
								normConstants[i], K, J, a_iter_ptr,
								lower, upper)
					num_alphas += 1
					alpha_sum += alpha
					avg_a_iters += <FLOAT>a_iter_ptr[0]
					avg_step = 0.0
					
					for h in range(d_indptr[1]):
						old_m = M_ptr[i][d_indices[h]]
						if M_ptr[i][d_indices[h]] > upper:
							M_ptr[i][d_indices[h]] = upper
						elif M_ptr[i][d_indices[h]] < lower:
							M_ptr[i][d_indices[h]] = lower
						avg_step += fabs(old_m - M_ptr[i][d_indices[h]])
						distance[0] += fabs(old_m - M_ptr[i][d_indices[h]])
						num_steps[0] += 1
					
					avg_step = avg_step / d_indptr[1]
					total_avg_step += avg_step

					error = predict.get_r_e_and_grad_m_omp(grad, M_ptr[i], 
							C_data, C_indices, C_indptr,
							X_ptr[i], R_ptr[i], J, K, normConstants[i])

					if (prev_err - error)/prev_err < 0.00001:
						break

					if isNaN(error):
						#print "M error is NaN!!!!!"
						m_nan = 1
						break

					sp.compress_dbl_vec(grad, grad_data, grad_indices, grad_indptr, K)
					prelims_slmqn(grad, grad_data, grad_indices, grad_indptr,
										M_ptr[i],
										diagP0, diagP0_indices, diagP0_indptr,
										diagP0_zero_indices, diagP0_zero_indptr,
										diagP1, diagP1_indices, diagP1_indptr,
										diagP1_zero_indices, diagP1_zero_indptr,
										diagP2_indices, diagP2_indptr,
										diagP3_indices, diagP3_indptr,
										eps, zero_eps, J, K, K, lower, upper)
					grad_sq_sum = 0.0
					for h in range(diagP0_indptr[1]):
						grad_sq_sum += grad[diagP0_indices[h]] * grad[diagP0_indices[h]]
					grad_len = sqrt(grad_sq_sum)				

					if diagP0_indptr[1] > 0:
						if num_stored >= size_max:
							num_stored = Z-1
							####print "Opt M", 100001, 0
							#discard the oldest s vectors; store newest
							for h in range(Z-1):
								for k in range(K):
									s_vecs[h][k] = s_vecs[h+(size_max-Z+1)][k]
							####print "Opt M", 100001, 1	
							#discard the oldest y vectors; store newest
							for h in range(Z-1):
								for k in range(K):
									y_vecs[h][k] = y_vecs[h+(size_max-Z+1)][k]
							####print "Opt M", 100001, 2
							#discard the oldest s_data vectors
							for h in range(Z-1):
								for k in range(K):
									s_vecs_data[h][k] = s_vecs_data[h+(size_max-Z+1)][k]
							####print "Opt M", 100001, 3
							#discard the oldest s_indices vectors
							for h in range(Z-1):
								for k in range(K):
									s_vecs_indices[h][k] = s_vecs_indices[h+(size_max-Z+1)][k]
							####print "Opt M", 100001, 4
							#discard the oldest s_indptr vectors
							for h in range(Z-1):
								for k in range(2):
									s_vecs_indptr[h][2] = s_vecs_indptr[h+(size_max-Z+1)][k]
							####print "Opt M", 100001, 5
							#discard the oldest y_data vectors
							for h in range(Z-1):
								for k in range(K):
									y_vecs_data[h][k] = y_vecs_data[h+(size_max-Z+1)][k]				
							####print "Opt M", 100001, 6
							#discard the oldest y_indices vectors
							for h in range(Z-1):
								for k in range(K):
									y_vecs_indices[h][k] = y_vecs_indices[h+(size_max-Z+1)][k]
							####print "Opt M", 100001, 7
							#discard the oldest y_indptr vectors
							for h in range(Z-1):
								for k in range(2):
									y_vecs_indptr[h][k] = y_vecs_indptr[h+(size_max-Z+1)][k]

							for h in range(Z-1):
								rho[h] = rho[h+(size_max-Z+1)]

						for h in range(diagP0_zero_indptr[1]):
							y_vecs[num_stored][diagP0_zero_indices[h]] = 0.0
						for h in range(diagP0_indptr[1]):
							y_vecs[num_stored][diagP0_indices[h]] = grad[diagP0_indices[h]] - grad_old[diagP0_indices[h]]

						for h in range(diagP0_zero_indptr[1]):
							s_vecs[num_stored][diagP0_zero_indices[h]] = 0.0
						for h in range(diagP0_indptr[1]):
							s_vecs[num_stored][diagP0_indices[h]] = M_ptr[i][diagP0_indices[h]] - m_old[diagP0_indices[h]]

						sp.compress_dbl_vec(s_vecs[num_stored], 		
								s_vecs_data[num_stored], 
								s_vecs_indices[num_stored], 
								s_vecs_indptr[num_stored], K)
						sp.compress_dbl_vec(y_vecs[num_stored], 
								y_vecs_data[num_stored], 
								y_vecs_indices[num_stored], 
								y_vecs_indptr[num_stored], K)

						sTy = 0.0
						#sTs = 0.0
						yTy = 0.0

						for h in range(s_vecs_indptr[num_stored][1]):
							sTy += y_vecs[num_stored][s_vecs_indices[num_stored][h]] * s_vecs_data[num_stored][h]
						for h in range(y_vecs_indptr[num_stored][1]):
							yTy += y_vecs_data[num_stored][h] * y_vecs_data[num_stored][h]
						if yTy == 0.0 or sTy == 0.0:
							grad_break = 1
							break
						else:
							rho[num_stored] = 1.0 / sTy
							gamma_ptr[0] = sTy / yTy
							num_stored += 1
					
					#####################################################
					# Compute search direction
					# The function direction_slmqn computes the search direction.
					direction_slmqn(d, d_data, d_indices, d_indptr,
								M_ptr[i], grad, grad_data, grad_indices, grad_indptr,
								s_vecs, s_vecs_data, s_vecs_indices, s_vecs_indptr,
								y_vecs, y_vecs_data, y_vecs_indices, y_vecs_indptr,
								diagP0, diagP0_indices, diagP0_indptr,
								diagP0_zero_indices, diagP0_zero_indptr, 
								diagP1, diagP1_indices, diagP1_indptr,
								diagP1_zero_indices, diagP1_zero_indptr, 
								diagP2_indices, diagP2_indptr,
								diagP3_indices, diagP3_indptr,
								rho, gamma_ptr[0], Z, num_stored, eps, zero_eps,
								K, lower, upper, sign)

					gTd = 0.0
					for h in range(d_indptr[1]):
						gTd += d_data[h] * grad[d_indices[h]]
					if (prev_err - error) / prev_err < err_thresh:
						#print "**** error diff too small; BRerrorAK!!! *****"
						###print "Opt M", 698.1
						break

					t += 1

				if cg == 1 and num_stored > 0 and gTd < -0.000001:
					precondition = 1
					for k in range(K):
						diagPre[k] = gamma_ptr[0]
					err_before_cg = error
					error = cg_M_nor(M_ptr[i], m_old, m_test,
								 C_ptr, C_data, C_indices, C_indptr,  
								 X_ptr[i],  R_ptr[i],
								 grad, grad_data, grad_indices, grad_indptr,
								 grad_old,
								 z,  z_data,  z_indices,  z_indptr,
								 z_old,
								 s_vecs[num_stored],  y_vecs[num_stored],  Hy,
								 d,  d_data,  d_indices,  d_indptr,
								 diagPre,  gTd,
								 gamma_ptr, error, cg_itr_max, cg_itrs_ptr, 		
								 nr_itrs_ptr,
								 K, J, 
								 normConstants[i],
								 precondition,
								 diagP0,  diagP0_indices,  diagP0_indptr,
								 diagP0_zero_indices,  diagP0_zero_indptr,
								 diagP1,  diagP1_indices,  diagP1_indptr,
								 diagP1_zero_indices,  diagP1_zero_indptr,
								 diagP2_indices,  diagP2_indptr,
								 diagP3_indices,  diagP3_indptr,
								 eps,  distance,  num_steps,  lower,  upper)
	
					sum_cg_err_diffs += (err_before_cg - error)
					cg_itrs_sum += cg_itrs_ptr[0]
			
				t_sum += t
				counter += 1 
				
			if i%10==0:
				print "M[" + str(i) + "]; e: {:.6f}".format(error) + "; dif: {:.6f}".format(original_err - error) + ";", 
				print "g:", "{:.5f}".format(grad_len) + "; gd:", "{:.6f}".format(gTd) + "; a:" + "{:.4f}".format(alpha_sum/(<FLOAT>max(1, num_alphas))) + "; q: {:.4f}".format(q_val) + "; t:" + str(t_sum) + ";", 
				print "pc:" + str(precondition) + ";",
				print "cgd:{:.6f}".format(sum_cg_err_diffs) + ";",
				print "cgi:" + "{:.1f}".format(cg_itrs_sum/(<FLOAT>max(1,counter))) +  ";", 
				print "c:" + str(counter) + "; ni:" + str(numIters) + ";", 
				print "P0:" + str(diagP0_indptr[1]) + ";", 
				print "P1:" + str(diagP1_indptr[1]) + ";", 
				print "P2:" + str(diagP2_indptr[1]) + ";", 
				print "P3:" + str(diagP3_indptr[1]) + ";", 
				
				print "; K:" + str(K)
		
		if cg == 1 and qn == 0:
			precondition = 0

			error = predict.get_r_e_and_grad_m_omp(grad, M_ptr[i], 
					C_data, C_indices, C_indptr, 
					X_ptr[i], R_ptr[i], J, K, normConstants[i])
			grad_sq_sum = 0.0
			for k in range(K):
				grad_sq_sum += grad[k] * grad[k]
			grad_len = sqrt(grad_sq_sum)

			prev_err = error
			cg_itrs_ptr[0] = 0
			nr_itrs_ptr[0] = 0
			gamma_ptr[0] = 1.0
			
			for k in range(K):
				diagPre[k] = gamma_ptr[0]
			#print "***********************"
			#print "OPT M; pre-cg  error =", error
			#print "***********************"
			error = cg_M_nor(M_ptr[i], m_old,
						 m_test,
						 C_ptr, C_data, C_indices, C_indptr,
						 X_ptr[i],  R_ptr[i],
						 grad, grad_data, grad_indices, grad_indptr,
						 grad_old,
						 z, z_data, z_indices, z_indptr, z_old,
						 s_vecs[num_stored],  y_vecs[num_stored],  Hy,
						 d,  d_data,  d_indices,  d_indptr,
						 diagPre,  gTd,
						 gamma_ptr, error, cg_itr_max, cg_itrs_ptr, nr_itrs_ptr,
						 K, J, 
						 normConstants[i],
						 precondition,
						 diagP0,  diagP0_indices,  diagP0_indptr,
						 diagP0_zero_indices,  diagP0_zero_indptr,
						 diagP1,  diagP1_indices,  diagP1_indptr,
						 diagP1_zero_indices,  diagP1_zero_indptr,
						 diagP2_indices,  diagP2_indptr,
						 diagP3_indices,  diagP3_indptr,
						 eps,  distance,  num_steps,  lower,  upper)
			#print "***********************"
			#print "OPT M; post-cg error =", error
			#print "***********************"
			M_i_nnz = nnz.vectorNonZeros(M_ptr[i], K)
			for k in range(K):
				grad_sq_sum += grad[k] * grad[k]
			grad_len = sqrt(grad_sq_sum)
			if i%10==0:
				print "*** M", str(i), "; e: {:.5f}".format(error), "; dif: {:.10f}".format(prev_err - error), 
				print "; nz: " + str(M_i_nnz) + "/" + str(K) + "; gn =", grad_len, 
				prrint "; cgi: " + str(cg_itrs_ptr[0]) + ";",
				print "ni: " + str(numIters) + "; K: " + str(K)								
		E += error
	#E = E/<FLOAT>I
	
	dealloc_vector(C_data)
	dealloc_vec_int(C_indices)
	dealloc_vec_int(C_indptr)
	
	#dealloc_vector(prod)
	
	dealloc_matrix_2(s_vecs, size_max)
	dealloc_matrix_2(s_vecs_data, size_max)
	dealloc_mat_2_int(s_vecs_indices, size_max)
	dealloc_mat_2_int(s_vecs_indptr, size_max)
	dealloc_matrix_2(y_vecs, size_max)
	dealloc_matrix_2(y_vecs_data, size_max)
	dealloc_mat_2_int(y_vecs_indices, size_max)
	dealloc_mat_2_int(y_vecs_indptr, size_max)

	dealloc_vector(m_old)
	dealloc_vector(m_test)
	dealloc_vector(grad_old)
	
	dealloc_vector(grad)
	dealloc_vector(grad_data)
	dealloc_vec_int(grad_indices)
	dealloc_vec_int(grad_indptr)
	
	dealloc_vector(z)
	dealloc_vector(z_data)
	dealloc_vec_int(z_indices)
	dealloc_vec_int(z_indptr)
	dealloc_vector(z_old)

	dealloc_vector(d)
	dealloc_vector(d_data)
	dealloc_vec_int(d_indices)
	dealloc_vec_int(d_indptr)

	dealloc_vector(rho)
	dealloc_vector(diagH)
	dealloc_vector(diagPre)
	dealloc_vector(Hy)
	
	dealloc_vector(diagP0)
	dealloc_vec_int(diagP0_indices)
	dealloc_vec_int(diagP0_indptr)
	dealloc_vec_int(diagP0_zero_indices)
	dealloc_vec_int(diagP0_zero_indptr)
	
	dealloc_vector(diagP1)
	dealloc_vec_int(diagP1_indices)
	dealloc_vec_int(diagP1_indptr)
	dealloc_vec_int(diagP1_zero_indices)
	dealloc_vec_int(diagP1_zero_indptr)

	dealloc_vec_int(diagP2_indices)
	dealloc_vec_int(diagP2_indptr)

	dealloc_vec_int(diagP3_indices)
	dealloc_vec_int(diagP3_indptr)

	return E
