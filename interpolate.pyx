#cython: profile=True
#cython: boundscheck=False
#cython: wraparound=False
#cython: cdivision=True
#import sys
def isNaN(FLOAT x):
	return x != x
	
cdef FLOAT cubicmin(FLOAT a, FLOAT fa, FLOAT fpa, FLOAT b, FLOAT fb, 
					FLOAT c, FLOAT fc):
# finds the minimizer for a cubic polynomial that goes through the
# points (a,fa), (b,fb), and (c,fc) with derivative at a of fpa.
# if no minimizer can be found return None
	cdef FLOAT A, B, C, D, db, dc, dfb, dfc, denom, radical
	if a == b:
		return -1.0
	if b == c:
		return -1.0
	if a == c:
		return -1.0
	C = fpa
	D = fa
	db = b-a
	dc = c-a
	dfb = fb-fa
	dfc = fc-fa
	denom = (db*dc)**2 * (db-dc)
	A = (dc**2)*(dfb-C*db) + (-db**2)*(dfc-C*dc)
	if denom == 0.0:
		#print "\t\t\tdenom = 0; RETURN -1.0"
		#print "return -1.0"
		return -1.0
	B = (-dc**3)*(dfb-C*db) + (db**3)*(dfc-C*dc)
	if A == 0.0:
		#print "\t\t\tA = 0; RETURN -1.0"
		return -1.0
	A = A / denom
	B = B / denom
	radical = (B*B)-(3.0*A*C)
	if radical < 0.0:
		#print "\t\t\tradical < 0; RETURN -1.0"
		return -1.0		
	#print "*** return alpha_j =",  a + (-B + sqrt(radical))/(3.0*A)
	return a + (-B + sqrt(radical))/(3.0*A)


cdef FLOAT quadmin(FLOAT a, FLOAT fa, FLOAT fpa, FLOAT b, FLOAT fb):
	# finds the minimizer for a quadratic polynomial that goes through
	# the points (a,fa), (b,fb) with derivative at a of fpa
	# f(x) = B*(x-a)^2 + C*(x-a) + D
	#print "\t\t\tquad min;",
	cdef FLOAT B, db
	db = b - a*1.0
	if (db*db==0.0): 
		#print "return -1.0"
		return -1.0
	B = (fb-fa-fpa*db)/(db*db)
	if B == 0.0:
		#print "return -1.0"
		return -1.0
	return a - fpa / (2.0*B)

cdef FLOAT quadratic_interpolate(FLOAT phi_0, FLOAT der_phi_0, FLOAT a_cur, FLOAT phi_cur):
	cdef FLOAT top, bottom, dfcur
	dfcur = phi_cur - phi_0
	#print "quad:", "phi_cur", "-", "phi_0 =", phi_cur - phi_0
	top = der_phi_0 * (a_cur**2)
	bottom = 2.0*(phi_cur - phi_0 - der_phi_0*a_cur)
	if bottom == 0.0:
		#print "\t\t\tbottom = 0; RETURN -1.0"
		return -1.0
	#print "\t>>> QUAD ; bottom =", "{:.7f}".format(bottom), "; phi_lo =", "{:.7f}".format(phi_lo), "; phi_0 =", "{:.7f}".format(phi_0), "; der_phi_0 =", "{:.7f}".format(der_phi_0), "; a_lo =", "{:.7f}".format(a_lo)
	return -(top / bottom)


cdef FLOAT cubic_interpolate(FLOAT ai_old, FLOAT phi_old, FLOAT phi_prime_old, 
							FLOAT ai, FLOAT phi, FLOAT phi_prime):
	#Cubic interpolation.
	#Formula 3.43, page 57, from 'Numerical Optimization' 
	#by Jorge Nocedal and Stephen J. Wright, 1999
	cdef FLOAT d1, d2, denom
	d1 = phi_prime_old + phi_prime - 3.0 * ((phi_old - phi) / (ai_old - ai))
	d2 = sqrt(fabs(d1**2 - phi_prime_old*phi_prime))
	#print "\t>>> CUBIC ; d1 =", d1, "; d2 =", d2, "; denom =", "{:.10f}".format(phi_prime - phi_prime_old + 2.0*d2) 
	denom = phi_prime - phi_prime_old + 2.0*d2
	if denom == 0.0:
		return -1
	return ai - (ai - ai_old) * ((phi_prime + d2 - d1) / denom)
	
# cdef FLOAT span(FLOAT eta, FLOAT a, FLOAT b):
# 	if eta < a:
# 		return a
# 	elif eta > b:
# 		return b
# 	else:
# 		return eta

cdef FLOAT cubic(FLOAT phi0, FLOAT phi0_prime, 
				FLOAT phi_alpha0, FLOAT alpha0,
				FLOAT phi_alpha1, FLOAT alpha1): 	
	cdef FLOAT factor, a, b, d
	factor = alpha0**2 * alpha1**2 * (alpha1 - alpha0)
	if factor == 0.0:
		return -1.0
	a = alpha0**2 * (phi_alpha1 - phi0 - phi0_prime * alpha1) - alpha1**2 * (phi_alpha0 - phi0 - phi0_prime * alpha0)
	a = a / factor
	b = -alpha0**3 * (phi_alpha1 - phi0 - phi0_prime * alpha1) + alpha1**3 * (phi_alpha0 - phi0 - phi0_prime * alpha0)
	b = b / factor
	if a == 0.0:
		return -1.0
	else:
		d = b**2 - 3.0 * a * phi0_prime   #discriminant
		if d < 0.0:
			return -1.0
		else:
			return (-b + sqrt(d)) / (3.0*a)