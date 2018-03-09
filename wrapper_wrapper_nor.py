#!/usr/bin/env python
# -*- coding: utf-8 -*-
import sys
import random
#from random import choice
from StringIO import StringIO
import numpy
from numpy import *
#import time
# import decode
# import encode
import wrapper_nor
import pstats, cProfile

inputFileName = sys.argv[1]
outputPrefix = sys.argv[2]
affixlen = int(sys.argv[3])
prec_span = sys.argv[4]
bigrams = int(sys.argv[5])
num_clusters = sys.argv[6]
k_interval = int(sys.argv[7])
tempDir = sys.argv[8]
experimentTitle = sys.argv[9]
init_M_file = sys.argv[10]
init_C_file = sys.argv[11]
if init_M_file == "0":
	init_M_file = False
if init_C_file == "0":
	init_C_file = False
useSQ = int(sys.argv[12])
objFunc = sys.argv[13]
qn = int(sys.argv[14])
cg = int(sys.argv[15])
mixingFunc = sys.argv[16]
# eta = sys.argv[17]
# if eta == "default":
#         eta = int(101)
# elif eta == "none":
# 		eta = int(102)
# else:
#         eta = int(eta)

sys.stderr.write("**********************\n")
sys.stderr.write("inputFileName: " + inputFileName + "\n")
sys.stderr.write("outputPrefix: " + outputPrefix + "\n")
sys.stderr.write("affixlen: " + str(affixlen) + "\n")
sys.stderr.write("prec_span: " + str(prec_span) + "\n")
sys.stderr.write("B I G R A M S: " + str(bigrams) + "\n")
sys.stderr.write("num_clusters: " + num_clusters + "\n")
sys.stderr.write("k_interval: " + str(k_interval) + "\n")
sys.stderr.write("tempDir: " + tempDir + "\n")
sys.stderr.write("experimentTitle: " + experimentTitle + "\n")
sys.stderr.write("use_SQ: " + str(useSQ) + "\n")
sys.stderr.write("objFunc: " + objFunc + "\n")
sys.stderr.write("mixingFunc: " + mixingFunc + "\n")
#sys.stderr.write("eta: " + str(eta) + "\n")
sys.stderr.write("\n")

# wrapper_nor.main(inputFileName, outputPrefix, init_M_file, init_C_file, affixlen, prec_span, bigrams, 
# 	num_clusters, k_interval, tempDir, experimentTitle, useSQ, objFunc, qn, cg, mixingFunc, eta)
wrapper_nor.main(inputFileName, outputPrefix, init_M_file, init_C_file, affixlen, prec_span, bigrams, 
	num_clusters, k_interval, tempDir, experimentTitle, useSQ, objFunc, qn, cg, mixingFunc)

cProfile.runctx('wrapper_nor.main(inputFileName, outputPrefix, init_M_file, init_C_file, affixlen, prec_span, bigrams, num_clusters, k_interval, tempDir, experimentTitle, useSQ, objFunc, qn, cg, mixingFunc)', globals(), locals())

#cProfile.runctx('wrapper_sp2.main(inputFileName, outputPrefix, init_M_file, init_C_file, 
	#affixlen, prec_span, bigrams, num_clusters, k_interval, tempDir, experimentTitle, useSQ, 
	#objFunc, qn, cg, mixingFunc, eta)', globals(), locals())
