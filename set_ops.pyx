#cython: profile=True
#cython: boundscheck=False
#cython: wraparound=False
#cython: cdivision=True
# encoding: utf-8

cdef int intersect_size(int* a_indices, int a_nnz,
							int* b_indices, int b_nnz):
					
	cdef int count = 0
	cdef int a_pointer, b_pointer, a_index, b_index
# 	cdef int a_nnz = a_indptr[1]
# 	cdef int b_nnz = b_indptr[1]
	cdef bint increase_a, increase_b, exhausted_b
	b_pointer = 0
	increase_b = 0
	exhausted_b = 0
	
	b_index = b_indices[b_pointer]
	
	for a_pointer in range(a_nnz):
		if exhausted_b == 1:
			exhausted_b = 0
			break
		
		increase_a = 0
		while increase_a == 0:
			if increase_b == 1:
				b_pointer += 1
				if b_pointer >= b_nnz:
					exhausted_b = 1
					break
				b_index = b_indices[b_pointer]
				increase_b = 0
			
			a_index = a_indices[a_pointer]

			if a_index < b_index:
				increase_a = 1
				continue

			elif a_index == b_index:
				count += 1
				#print "MATCH! (" + str(count) + "),",
				increase_b = 1
				increase_a = 1

			elif a_index > b_index:
				increase_b = 1
	#print ""
	return count
	