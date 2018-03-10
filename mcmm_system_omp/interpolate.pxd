#cython: profile=True
#cython: boundscheck=False
#cython: wraparound=False
#cython: cdivision=True
#import sys

from libc.math cimport sqrt, fabs, log
ctypedef double FLOAT

cdef FLOAT cubicmin(FLOAT a, FLOAT fa, FLOAT fpa, FLOAT b, FLOAT fb, 
					FLOAT c, FLOAT fc)
					
cdef FLOAT quadmin(FLOAT a, FLOAT fa, FLOAT fpa, FLOAT b, FLOAT fb)

cdef FLOAT quadratic_interpolate(FLOAT phi_0, FLOAT der_phi_0, FLOAT a_lo, FLOAT phi_lo)

cdef FLOAT cubic_interpolate(FLOAT ai_old, FLOAT phi_old, FLOAT phi_prime_old, 
							FLOAT ai, FLOAT phi, FLOAT phi_prime)

#cdef FLOAT span(FLOAT eta, FLOAT a, FLOAT b)

cdef FLOAT cubic(FLOAT phi0, FLOAT phi0_prime, 
				FLOAT phi_alpha_last, FLOAT alpha_last,
				FLOAT phi_alpha_cur, FLOAT alpha_cur)
