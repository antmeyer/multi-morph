#cython: boundscheck=False
#cython: wraparound=False
#cython: cdivision=True
#encoding: utf-8
#filename: bcubed_eval.pyx

#import os,sys,re,math,pprint,random,time
import time,sys
#from sets import Set
#cimport set_ops as so
#cimport sparsement as sp
# ctypedef np.int32_t INT_t
# ctypedef unsigned int unint
# we need 2 dictionaries:
# wordsAndClusters: the keys are words, and each value is a list of the clusters
### to which the word belongs.
# wordsAndClasses: the keys are again words; the value associated with each word is
### a list of the classes to which the word belongs.

# How do we find the intersection of the cluster lists of two words, w1 and w2?
### We look up wordsAndClusters[w1] and wordsAndClusters[w2]. These are lists. We need to
#### compare these lists and count how many items are the same.
# The intersection of class lists is found in the same way.

# def isNaN(x):
# 	return x != x
	
cpdef double bcubed_rec(object wordsAndClusters, object clusters_lengths, 
						object wordsAndClasses, object classes_lengths,
						int numClusters, int numClasses):
	cdef double t1,t2
	t1 = time.clock()
	#cdef object wcpairs, averages, avgPairs, wupairs, wvpairs
	cdef INT_t u_intersect_len, v_intersect_len
	cdef INT_t u1_nnz, v1_nnz, u2_nnz, v2_nnz
	
	averages = dict()
	cdef unint i, n, w1, w2
	cdef double N, M, avg, avg_global, denom, elapsedTime

	cdef INT_t numWords = len(wordsAndClasses)
# 	cdef INT_t numClasses = wordsAndClasses.shape[1]
# 	cdef INT_t numClusters = wordsAndClusters.shape[1]
	
	cdef int* u1 = <int *>malloc(numClusters * sizeof(int))
	cdef int* u2 = <int *>malloc(numClusters * sizeof(int))
	for n in range(numClusters):
		u1[n] = 0
		u2[n] = 0
	
	cdef int* v1 = <int *>malloc(numClasses * sizeof(int))
	cdef int* v2 = <int *>malloc(numClasses * sizeof(int))
	for n in range(numClasses):
		v1[n] = 0
		v2[n] = 0
# 	sys.stderr.write("bcubed ; numWords = " + str(numWords) + "\n")
# 	sys.stderr.write("bcubed ; numClusters = " + str(numClusters) + "\n")
# 	sys.stderr.write("bcubed ; numClasses = " + str(numClasses) + "\n")
	N = 0.0
	avg_global = 0.0
	#cdef int* clusters = <int *>malloc(numClusters * sizeof(int))
	#for w1 in wordsAndClusters:
	for w1 in range(numWords):
		avg = 0.0
		M = 0.0
		u1_nnz = <INT_t>clusters_lengths[w1]
		v1_nnz = <INT_t>classes_lengths[w1]
# 		if w1 < 21:
# 			sys.stderr.write("u1_nnz = " + str(u1_nnz) + " ; v1_nnz = " + str(v1_nnz) + "\n")
		#sys.stderr.write("u1 = ")
		for i in range(u1_nnz):
			u1[i] = wordsAndClusters[w1][i]
			#sys.stderr.write(str(u1[i]) + " ")
		#sys.stderr.write("\n") 
		#sys.stderr.write("v1 = ")
		for i in range(v1_nnz):
			v1[i] = wordsAndClasses[w1][i]
			#sys.stderr.write(str(v1[i]) + " ")
		#sys.stderr.write("\n") 
		#u1 = np.asarray(wupairs[i][1])
		#v1 = np.asarray(wvpairs[i][1])
		for w2 in range(numWords):
# 			kissy = 0.0
			u2_nnz = <INT_t>clusters_lengths[w2]
			v2_nnz = <INT_t>classes_lengths[w2]
			for i in range(u2_nnz):
				u2[i] = wordsAndClusters[w2][i]
			for i in range(v2_nnz):
				v2[i] = wordsAndClasses[w2][i]
			#u2 = np.asarray(wupairs[j][1])
			#v2 = np.asarray(wvpairs[j][1])
			u_intersect_len = so.intersect_size(u1, u1_nnz, u2, u2_nnz)
			v_intersect_len = so.intersect_size(v1, v1_nnz, v2, v2_nnz)
			#u_intersect = np.intersect1d(u1, u2)
			#v_intersect = np.intersect1d(v1, v2)
			#u_intersect_len = u_intersect.shape[0]
			#v_intersect_len = v_intersect.shape[0]
			denom = <double>v_intersect_len
			if denom == 0.0:
				continue
			avg += min(u_intersect_len, v_intersect_len) / denom
			M += 1.0
			#if avg > 0.0:
			#averages[wupairs[i][0]] = avg / M
		if M > 0.0:
			avg_global += (avg / M)
			N += 1.0
	#avg_global = 0.0
	#avgPairs = averages.items()
	#total = len(avgPairs)
	#N = <double>len(avgPairs)
# 	for i in range(total):
# 		avg_global += avgPairs[i][1]
	avg_global = avg_global / N
	t2 = time.clock()
	elapsedTime = (t2 - t1)/60.0
	elapsedTimeStr = "%.4f" % elapsedTime
	sys.stderr.write("\nRecall elapsed time: " + "%.4f" % elapsedTime + " min.\n")
	
	dealloc_vec_int(u1)
	dealloc_vec_int(u2)
	dealloc_vec_int(v1)
	dealloc_vec_int(v2)
	
	#return avg_global/N
	return avg_global
	
cpdef double bcubed_prec(object wordsAndClusters, object clusters_lengths, 
						object wordsAndClasses, object classes_lengths,
						int numClusters, int numClasses):
	cdef double t1,t2
	t1 = time.clock()
	#cdef object wcpairs, averages, avgPairs, wupairs, wvpairs
	cdef INT_t u_intersect_len, v_intersect_len, 
	cdef INT_t u1_nnz, v1_nnz, u2_nnz, v2_nnz, N, M
	
	#averages = dict()
	cdef unint i, n, w1, w2
	cdef double avg, avg_global, denom, elapsedTime

	cdef INT_t numWords = len(wordsAndClasses)
# 	cdef INT_t numClasses = wordsAndClasses.shape[1]
# 	cdef INT_t numClusters = wordsAndClusters.shape[1]
	
	cdef int* u1 = <int *>malloc(numClusters * sizeof(int))
	cdef int* u2 = <int *>malloc(numClusters * sizeof(int))
	for n in range(numClusters):
		u1[n] = 0
		u2[n] = 0
	
	cdef int* v1 = <int *>malloc(numClasses * sizeof(int))
	cdef int* v2 = <int *>malloc(numClasses * sizeof(int))
	for n in range(numClasses):
		v1[n] = 0
		v2[n] = 0
	
	avg_global = 0.0
	N = 0
	#cdef int* clusters = <int *>malloc(numClusters * sizeof(int))
	# what is in a wu_pair?
	
	# w1 and w2 represent words.
	# 'u' denotes 'cluster', and 'v' indicates 'class'
	for w1 in range(numWords):
		avg = 0.0
		M = 0
		#counter = 0
		u1_nnz = <INT_t>clusters_lengths[w1]
		v1_nnz = <INT_t>classes_lengths[w1]
		#v1_nnz = len(wordsAndClasses[w1])
		for i in range(u1_nnz):
			u1[i] = wordsAndClusters[w1][i]
		for i in range(v1_nnz):
			v1[i] = wordsAndClasses[w1][i]
		#u1 = np.asarray(wupairs[i][1])
		#v1 = np.asarray(wvpairs[i][1])
		for w2 in range(numWords):
# 			kissy = 0.0
# 			u2_nnz = len(wordsAndClusters[w2])
# 			v2_nnz = len(wordsAndClasses[w2])
			u2_nnz = <INT_t>clusters_lengths[w2]
			v2_nnz = <INT_t>classes_lengths[w2]
			for i in range(u2_nnz):
				u2[i] = wordsAndClusters[w2][i]
			for i in range(v2_nnz):
				v2[i] = wordsAndClasses[w2][i]
			#u2 = np.asarray(wupairs[j][1])
			u_intersect_len = so.intersect_size(u1, u1_nnz, u2, u2_nnz)
			v_intersect_len = so.intersect_size(v1, v1_nnz, v2, v2_nnz)
# 			u_intersect = np.intersect1d(u1, u2)
# 			v_intersect = np.intersect1d(v1, v2)
# 			u_intersect_len = u_intersect.shape[0]
# 			v_intersect_len = v_intersect.shape[0]
			denom = <double>u_intersect_len
			if denom == 0.0:
				continue
			avg += min(u_intersect_len, v_intersect_len) / denom
			M += 1
			#if avg > 0.0:
			#averages[w1] = avg / N
		if M > 0:
			avg_global += (avg/(<double>M))
			N += 1
	#avg_global = 0.0
	#avgPairs = averages.items()
	#N = <double>len(avgPairs)
# 	for i in range(total):
# 		avg_global += avgPairs[i][1]
	avg_global = avg_global / (<double>N)
	t2 = time.clock()
	elapsedTime = (t2 - t1)/60.0
	elapsedTimeStr = "%.4f" % elapsedTime
	sys.stderr.write("\nPrecision elapsed time: " + "%.4f" % elapsedTime + " min.\n")
	
	dealloc_vec_int(u1)
	dealloc_vec_int(u2)
	dealloc_vec_int(v1)
	dealloc_vec_int(v2)
	
	return avg_global