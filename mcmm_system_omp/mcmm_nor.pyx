import random,math,sys
from random import choice
import numpy as np
import time
import decode
from transliterate import *

#DOUBLE = np.FLOAT64

cpdef mila_preprocess(object clusterEntries, object tempDir, outputPrefix, int K, object standard):
    # mila_preprocess puts the clusters in a format that can be processed by MILA.
    # The tempDir files are overwritten whenever K is incremented (i.e., whenever a new cluster is added).
    # Each K valuation has its own round of evaluation, i.e., yields its own set of files for tempDir.
    cdef int k
    cdef object clusterStr = ""
    cdef object str_K = str(K)
    sys.stderr.write("mila_pre; clusterEntries = " + str(clusterEntries) + "\n")
    sys.stdout.flush()
    for k in range(len(clusterEntries)):
        str_k = "{0:04d}".format(k+1)
        #Filename format: /Users/anthonymeyer/Documents/qual_paper_2/code/mcmm-cython/mcmm_system/<filename>"
        #Filename format: /Users/anthonymeyer/Development/mcmm/mcmm_system_pyopencl/<filename>
        #outputPrefix = /Users/anthonymeyer/Development/mcmm//mcmm_results/
        #mcmm-out_N-6656_K-2_ETA-none_2017-01-01_18-34/3_3_0_K-2_N-6656_ETA-none_2017-01-01_18-34
        # 0
        # 1 Users
        # 2 anthonymeyer
        # 3 Documents
        # 4 qual_paper_2
        # 5 code
        # 6 mcmm-cython
        # 7 mcmm_results
        # 8 <DIR>
        # 9 <filename>
        clusterStr = eng2heb_2(eng2heb_1(clusterWords(clusterEntries[k])))
        clusterStr = clusterStr.rstrip("\n")
        sys.stderr.write("mila_pre; clusterStr = " + clusterStr + "\n")
        sys.stderr.write("OUTPUT PREFIX = " + outputPrefix + "\n")
        sys.stdout.flush()
        items = outputPrefix.split("/")
        fileName = items[7]
        print "FILENAME:", fileName 
        newName = tempDir + "/" + fileName + "." + str_k + "." + str_K + "." + standard + ".input"
        print "NEWNAME:", newName
        sys.stdout.flush()
        fileobj = open(newName, "w")
        fileobj.write(clusterStr)
        fileobj.close()
        
def isNaN(x):
    return x != x

cdef class MCMM:
        
    def __init__(self, object charSet, object wordList, FLOAT[:,::1] dataMatrix,
                 FLOAT[:,::1] init_M, FLOAT[:,::1] init_C, INT midpoint, INT init_K, 
                 INT max_K,
                 INT evalInterval, INT I, INT J, object outputPrefix, object tempDir,
                 INT objFunc, bint qn, bint cg, FLOAT thresh):
        self.initTime = <FLOAT>time.clock()
        self.timePrevious = <FLOAT>time.clock() 
        self.alphabet = np.asarray(charSet, dtype='S1')
        self.wordList = wordList
        self.midpoint = midpoint
        self.Xv = dataMatrix
        #self.Xptr = &dataMatrix[0,0]
        self.I = I
        self.J = J
        self.K = init_K
        self.max_K = max_K
        self.evalInterval = evalInterval
        self.Rv = np.empty([I, J])
        cdef INT i, j
        for i in range(self.I):
            for j in range(self.J):
                self.Rv[i,j] = random.uniform(0.0, 1.0)
        self.E = 0.0
        self.initFlag = 1
        self.splitSequence = np.empty([0], dtype='S1')
        self.numIters = 0
        print "mcmm boost", 0
        self.Mv = init_M
        self.Cv = init_C
        self.thresh = thresh
        print "mcmm self.Cv is", self.Cv.shape[0], "by", self.Cv.shape[1]
        self.outputPrefix = outputPrefix
        self.tempDir = tempDir
        self.objFunc = objFunc
        self.qn = qn
        self.cg = cg
        self.M_distance = 0.0
        self.C_distance = 0.0
        self.num_M_steps = 0
        self.num_C_steps = 0
        cdef INT negctr = 0
        cdef INT posctr = 0
        cdef FLOAT norm_factor = 100.0
        #self.normConstant should be universal. It should only depend on matrix size.
        self.normConstant = norm_factor / <FLOAT>(self.I*self.J)
        self.normConstant_M = norm_factor / <FLOAT>self.J
        
    cdef void split_cluster(self):
        print "split_cluster", 0
        sys.stdout.flush()
        cdef int num_new_clusters = 1
        cdef int k_to_shake
        cdef int k_to_split, k, h
        cdef object cluster_list, cluster
        if self.K == 0:
            self.K += 1
            pass
        elif self.K == 1:
            self.duplicate_cluster(0)
        else:
            #cluster_list = self.find_cluster_to_split()
            k_to_split = self.find_cluster_to_split()
            # k_to_split = mcmm_functions.get_cluster_to_split_nsp_omp(M_ptr_ct, C_ptr_ct, X_ptr_ct, 
            #                     R_ptr, self.I, self.J, self.K, self.normConstant)
            sys.stdout.write("Splitting cluster " + str(k_to_split) + "\n")
            sys.stdout.flush()
            self.duplicate_cluster(k_to_split)
            # for h in range(min(self.K,num_new_clusters)):
            #     k_to_split = cluster_list[h][1]
            #     sys.stdout.write("Splitting cluster " + str(k_to_split) + "\n")
            #     sys.stdout.flush()
            #     self.duplicate_cluster(k_to_split)
            #     print "split_cluster", 2, "; after duplicate"
            #     sys.stdout.flush()
           
    cdef int find_cluster_to_split(self):
                                                             
        #cdef int i, j, k, k_to_split, amount
        cdef int i, k
        cdef int k_to_split = 0
##        cdef FLOAT normConstant = 1.0/(<FLOAT>(self.I*self.J))
        cdef FLOAT ** X_ptr_ct = <FLOAT**>malloc(self.I*sizeof(FLOAT*))
        cdef FLOAT ** R_ptr_ct = <FLOAT**>malloc(self.I*sizeof(FLOAT*))
        cdef FLOAT ** M_ptr_ct = <FLOAT **>malloc(self.I*sizeof(FLOAT*))
        cdef FLOAT ** C_ptr_ct = <FLOAT**>malloc(self.J*sizeof(FLOAT*))
        #cdef FLOAT * vec_C_ptr_ct = <FLOAT*>malloc(self.J*self.K*sizeof(FLOAT))

        cdef FLOAT** M_ptr = <FLOAT**>malloc(self.I*sizeof(FLOAT*))
        for i in range(self.I):
            M_ptr_ct[i] = <FLOAT*>malloc((<int>max(1,self.K))*sizeof(FLOAT))
            for k in range(self.K):
                M_ptr_ct[i][k] = self.Mv[i,k]
        M_ptr_ct = &M_ptr_ct[0]
        print "fctsplit", 1
        sys.stdout.flush()
        # cdef FLOAT * M_data_ct = <FLOAT *>malloc( self.I*(<int>max(1,self.K)) * sizeof(FLOAT*))
        # cdef int * M_indices_ct = <int *>malloc( self.I*(<int>max(1,self.K)) * sizeof(int))
        # cdef int * M_indptr_ct = <int *>malloc( (self.I+1)*sizeof(int) )
        
        cdef object cluster_list = list()
        print "fctsplit", 2
        sys.stdout.flush()
        cdef object all_k_indices = []
        for i in range(self.I):
            X_ptr_ct[i] = &self.Xv[i,0]
            R_ptr_ct[i] = &self.Rv[i,0]
        # for j in range(self.J):
        #     for k in range(self.K): 
        #         vec_C_ptr_ct[j*K+k] = self.Cv[j,k]
        for j in range(self.J):
            C_ptr_ct[j] = &self.Cv[j,0]
        print "fctsplit", 2.5
        sys.stdout.flush()
        #sp.compress_dbl_mat(M_ptr_ct, M_data_ct, M_indices_ct, M_indptr_ct, self.I, <int>max(1,self.K))
        amount = max(1,self.K)
        print "fctsplit", 3
        sys.stdout.flush()
        print "\nRanking existing clusters...\n"
        # sys.stdout.flush()
        # cdef FLOAT lowestError = 0.0
        # cdef FLOAT error = 0.0
        # cdef int pastFirst = 0
        # cluster_list = []
        # for k in range(self.K):
        #     error = clustertest_nor.clustertest(M_ptr_ct,
        #         M_data_ct, M_indices_ct, M_indptr_ct,
        #         C_ptr_ct, X_ptr_ct, R_ptr_ct,
        #         self.I, self.J, self.K, k, self.normConstant)

        #     #cluster_list.append((error,k))
        #     print "...examining cluster ", k
        #     sys.stdout.flush()
        #     if error > max_error:
        #         k_to_split = k
        #cluster_list.sort()

        k_to_split = mcmm_functions.get_cluster_to_split(M_ptr_ct, C_ptr_ct, X_ptr_ct, R_ptr_ct, 
                                self.I, self.J, self.K, self.normConstant)

        dealloc_matrix(X_ptr_ct, self.I)
        dealloc_matrix(R_ptr_ct, self.I)
        dealloc_matrix(M_ptr_ct, self.I)
        dealloc_matrix(C_ptr_ct, self.J)
        # dealloc_vector(vec_C_ptr_ct)
        # dealloc_matrix_2(M_ptr_ct, self.I)
        # dealloc_vector(M_data_ct)
        # dealloc_vec_int(M_indices_ct)
        # dealloc_vec_int(M_indptr_ct)
        #return cluster_list
        return k_to_split

    cdef void shake(self, INT k, rate):
        for i in range(self.I):
            #print "\t", noise[i]
            self.Mv[i,k] += random.uniform(-1.0,1.0)*rate
            if self.Mv[i,k] > 1.0:
                self.Mv[i,k] = 1.0
            if self.Mv[i,k] < 0.0:
                self.Mv[i,k] = 0.0
        for j in range(self.J):
            self.Cv[j,k] += random.uniform(-1.0,1.0)*rate
            if self.Cv[j,k] > 1.0:
                self.Cv[j,k] = 1.0
            if self.Cv[j,k] < 0.0:
                self.Cv[j,k] = 0.0            
                
    cdef void duplicate_cluster(self, INT k):
        """
        This function duplicates a cluster. Cluster duplication is a two-part process:
        
    	1) A column k in the matrix M is copied and appended to M as column K + 1. Noise is added to
            both column k and the new column K + 1 (so that the two diverge as the algorithm continues to learn).
    	2) A row j in the matrix C is copied and appended to C as row J + 1. Noise is added to both row j and
            the new row J = 1
    		
    	Together, column K + 1 in M and row J + 1 in C identify the new cluster.
    	"""
        print "\nduplicating cluster\n"
        cdef unint i,j,h
        cdef FLOAT rate = 0.1
        cdef FLOAT avg_M_step = self.M_distance / <FLOAT>max(1, self.num_M_steps)
        cdef FLOAT avg_C_step = self.C_distance / <FLOAT>max(1, self.num_C_steps)
        self.M_distance = 0.0
        self.C_distance = 0.0
        self.num_M_steps = 0
        self.num_C_steps = 0
        # Increase the size of the M array pointer by one column
        ## (i.e., add a cell to each row pointer).
        timeElapsed_sec = <FLOAT>time.clock() - self.initTime
        timeElapsed_min = timeElapsed_sec/60.0
        timeElapsed_hrs = timeElapsed_min/60.0
        clusterTime_min = timeElapsed_min - self.timePrevious/60.0
        self.timePrevious = <FLOAT>time.clock()
        print "mcmm dup", 0
        sys.stdout.flush()
        writeString = "Split " + str(k) + ";  "
        writeString += "Clstr t: %.4f" % clusterTime_min + " (m);  "
        writeString += "Cum t: %.4f" % timeElapsed_min + " (m), %.4f" % timeElapsed_hrs + " (h);  "
        writeString += str(self.numIters) + " itrs;  "
        writeString += "E: %.5f" % self.E + ";  "
        writeString += "Avg st: M {:.8f}".format(avg_M_step) + ", C {:.8f}".format(avg_C_step) + "\n"
        #writeString += "Cstep: {:.5f}".format(avg_C_step) + ";  " +
        cdef INT newLength = self.splitSequence.shape[0] + 1
        cdef object dataType = '|S' + str(len(writeString) + 30)
        cdef np.ndarray sequence_temp = np.empty(newLength, dtype=dataType)
        for i in range(newLength-1):
            sequence_temp[i] = self.splitSequence[i]
        sequence_temp[newLength-1] = writeString
        self.splitSequence = sequence_temp
        print "mcmm dup 1"
        sys.stdout.flush()
        self.K += 1
        cdef np.ndarray[FLOAT, ndim=2] new_matrix_M = np.empty([self.I, self.K])
        cdef np.ndarray[FLOAT, ndim=2] new_matrix_C = np.empty([self.J, self.K])
        # Duplicate a cluster in the M matrix.
        ## Each column vector in the M matrix represents a cluster.
        ## "new_vector" temporarily holds the duplicated cluster.
        print "mcmm dup 1.1"
        sys.stdout.flush()
        for i in range(self.I):
            #print "mcmm dup 1.2." + str(i)
            sys.stdout.flush()
            for h in range(self.K-1):
                if h == k:
                    new_matrix_M[i,h] = self.Mv[i,h] + random.uniform(-1.0,1.0)*rate
                    #new_matrix_M[i,h] = 0.5 + noise[i]
                    if new_matrix_M[i,h] < 0.0:
                        new_matrix_M[i,h] = 0.0 + random.uniform(0.0,1.0)*rate
                    elif new_matrix_M[i,h] > 1.0:
                        new_matrix_M[i,h] = 1.0 - random.uniform(0.0,1.0)*rate
                else:
                    new_matrix_M[i,h] = self.Mv[i,h] #+ random.uniform(-1.0,1.0)*rate
##                    if new_matrix_M[i,h] < 0.0:
##                        new_matrix_M[i,h] = 0.0 + random.uniform(0.0,1.0)*rate
##                    elif new_matrix_M[i,h] > 1.0:
##                        new_matrix_M[i,h] = 1.0 - random.uniform(0.0,1.0)*rate
        # Create a new column for the M matrix.
        print "mcmm dup 1.5"
        sys.stdout.flush()
        for i in range(self.I):
            new_matrix_M[i,self.K-1] = self.Mv[i,k] + random.uniform(-1.0,1.0)*rate
            if new_matrix_M[i,self.K-1] < 0.0:
                new_matrix_M[i,self.K-1] = 0.0 + random.uniform(0.0,1.0)*rate
            elif new_matrix_M[i,self.K-1] > 1.0:
                new_matrix_M[i,self.K-1] = 1.0 - random.uniform(0.0,1.0)*rate

        # add new column to the M matrix
        self.Mv = new_matrix_M

        # Reshape the C matrix.       
        # add noise to old column
        ######################################
        # duplicate the corresponding centroid in the C matrix
        # make a 1-by-J row vector (a single-row matrix) copy of self.C[k,:]
        new_matrix_C = np.empty([self.J, self.K])
        print "mcmm dup 4"
        sys.stdout.flush()
        for j in range(self.J):
            for h in range(self.K-1):
                if h == k:
                    new_matrix_C[j,h] = self.Cv[j,h] + random.uniform(-1.0,1.0)*rate
                    #new_matrix_C[i,h] = 0.5 + noise[i]
                    if new_matrix_C[j,h] < 0.0:
                        new_matrix_C[j,h] = 0.0 + random.uniform(0.0,1.0)*rate
                    elif new_matrix_C[j,h] > 1.0:
                        new_matrix_C[j,h] = 1.0 - random.uniform(0.0,1.0)*rate
                else:
                    new_matrix_C[j,h] = self.Cv[j,h]
##                    if new_matrix_C[j,h] <= -1.0:
##                        new_matrix_C[j,h] = -0.9 + random.uniform(-1.0,1.0)*rate
##                    elif new_matrix_C[j,h] >= 1.0:
##                        new_matrix_C[j,h] = 0.9 + random.uniform(-1.0,1.0)*rate
	# Create a new column for the C matrix.
        for j in range(self.J):
            new_matrix_C[j,self.K-1] = self.Cv[j,k] + random.uniform(-1.0,1.0)*rate
            if new_matrix_C[j,self.K-1] < 0.0:
                new_matrix_C[j,self.K-1] = 0.0 + random.uniform(0.0,1.0)*rate
            elif new_matrix_C[j,self.K-1] > 1.0:
                new_matrix_C[j,self.K-1] = 1.0 - random.uniform(0.0,1.0)*rate
        self.Cv = new_matrix_C
        sys.stdout.flush()
        print "mcmm dup 5"
        sys.stdout.flush()
        
    cpdef run_MCMM(self):
        print "run_MCMM", 0
        sys.stdout.flush()
        cdef INT i,k,j, posctr, negctr
        cdef FLOAT end_thresh = 0.00001
        cdef FLOAT breakErr = 0.00001
        cdef FLOAT lower = 0.0
        cdef FLOAT upper = 1.0
        print "objFunc =", self.objFunc
        cdef FLOAT E_after_M = 0.0
        cdef FLOAT E_after_R = 0.0
        cdef FLOAT E_after_C = 0.0
        cdef FLOAT error
        cdef FLOAT db_I = <FLOAT>self.I
        cdef FLOAT db_J = <FLOAT>self.J
        cdef FLOAT Err_start, prev_E, diff, diff2, breakTest, end_condition
        #cdef object standards = ["m--", "m-r", "mc-", "mcr"]
        cdef object standards = ["mc-"]

        cdef INT flag = 0
        cdef INT size_max_C = 10
        cdef FLOAT ** X_ptr = <FLOAT **>malloc(self.I*sizeof(FLOAT*))
        cdef FLOAT ** R_ptr = <FLOAT **>malloc(self.I*sizeof(FLOAT*))
        cdef FLOAT ** M_ptr = <FLOAT **>malloc(self.I*sizeof(FLOAT*))
        cdef FLOAT ** C_ptr = <FLOAT **>malloc(self.J*sizeof(FLOAT*))
        #cdef FLOAT * vec_C = <FLOAT *>malloc(self.J*self.K*sizeof(FLOAT))
        #cdef FLOAT * etas_M = <FLOAT *>malloc(self.I*sizeof(FLOAT))
       # cdef FLOAT * normConstants_M = <FLOAT *>malloc(self.I*sizeof(FLOAT))
        # cdef INT negc
        # for i in range(self.I):
        #     normConstants_M[i] = 100.0 / db_J
        # if self.eta_raw == 0:
        #     for i in range(self.I):
        #         negctr = 0
        #         posctr = 0
        #         for j in range(self.J):
        #             if self.Xv[i,j] < 0:
        #                 negctr += 1
        #             elif self.Xv[i,j] >= 0:
        #                 posctr += 1
        #         etas_M[i] = <FLOAT>negctr / db_J
        # else:
        #     for i in range(self.I):
        #         etas_M[i] = self.eta
        C_ptr = &C_ptr[0]
        M_ptr = &M_ptr[0]
        #################
        print "run_MCMM", 2
        sys.stdout.flush()

        for i in range(self.I):
            X_ptr[i] = &self.Xv[i,0]
            R_ptr[i] = &self.Rv[i,0]
        R_ptr = &R_ptr[0]
        X_ptr = &X_ptr[0]
        cdef int p = 1
        while self.K < self.max_K:
            if self.initFlag == 1:
                self.initFlag = 0
                for i in range(self.I):
                    M_ptr[i] = &self.Mv[i,0]
                M_ptr = &M_ptr[0]
                for j in range(self.J):
                    C_ptr[j] = &self.Cv[j,0]
                C_ptr = &C_ptr[0]
                # for j in range(self.J):
                #     for k in range(self.K):
                #         vec_C[j*K + k] = self.Cv[j,k]
                #sp.compress_dbl_mat(M_ptr, M_data, M_indices, M_indptr, self.I, max(1,self.K))
                # self.E = predict_nor.R_and_E_one(M_ptr,
                #         C_ptr, X_ptr, R_ptr,
                #         self.I, self.J, self.normConstant, self.eta)
                self.E = mcmm_functions.R_and_E_2(R_ptr, M_ptr, C_ptr, X_ptr, 
                                            self.I, self.J, self.K, self.normConstant)
                self.original_E = self.E
            else:
                self.split_cluster()
                print "\n***** K =", self.K, "*****\n"
                #############
                print "mcmm H"
                sys.stdout.flush()
                for i in range(self.I):
                    #free(M_ptr[i])
                    M_ptr[i] = &self.Mv[i,0]
                print "mcmm H1"
                sys.stdout.flush()
                for j in range(self.J):
                    C_ptr[j] = &self.Cv[j,0]
                print "mcmm H2"
                sys.stdout.flush()
                M_ptr = &M_ptr[0]
                C_ptr = &C_ptr[0]
                # for j in range(self.J):
                #     for k in range(self.K):
                #         vec_C[j*K + k] = self.Cv[j,k]

            print "mcmm", "H4"
            sys.stdout.flush()
            flag = 1          
            print "\nself.E =", self.E, "  K =", self.K, "\n"
            sys.stdout.flush()
            # The following inner loop iteratively optimizes the M and C matrices while holding K fixed.
            # It stops when the M and C matrices cannot be optimized further.
            Err_start = self.E
            self.numIters = 1
            # self.E = predict_nor.R_and_E_3(C_ptr, M_ptr, X_ptr, R_ptr,
            #                         self.E, self.I, self.J, self.K, self.normConstant,
            #                         self.eta)
            self.E = mcmm_functions.R_and_E_2(R_ptr, M_ptr, C_ptr, X_ptr, 
                                    self.I, self.J, self.K, self.normConstant)
            print "\n@@@@@@ mcmm_cy", "self.I =", self.I
            sys.stdout.flush()
            while 1 == 1:
                print "\nIteration:", self.numIters
                print "################################################"
                prev_E = self.E
                # self.E = optimize_nor.optimize_M_nor(X_ptr, R_ptr, M_ptr, C_ptr,
                #         self.I, self.J, self.K, self.normConstants_M, self.numIters, self.qn, self.cg, 
                #         &self.M_distance, &self.num_M_steps, lower, upper)
                # mcmm_functions.optimize_M(X_ptr, R_ptr, M_ptr, C_ptr,
                #         self.I, self.J, self.K, self.normConstant_M, self.numIters, self.qn, self.cg, 
                #         &self.M_distance, &self.num_M_steps, lower, upper)
                self.E = mcmm_functions.cg_M(M_ptr, C_ptr, X_ptr, R_ptr, 
                        self.I, self.K, self.J, self.normConstant, lower, upper)
                #E_after_M = self.E
                #print "\nmcmm E from M", "=", E_after_M
                #sys.stdout.flush()

                self.E = mcmm_functions.R_and_E_2(R_ptr, M_ptr, C_ptr, X_ptr,
                                        self.I, self.J, self.K, self.normConstant)
                print "M, now R_and_E"
                E_after_R = self.E
                print "\nE after R", "=", self.E
                print "In iteration", self.numIters, "\n"
                print "YEESSSSS", 1
                sys.stdout.flush()
                # self.E = optimize_nor.optimize_C_nor(X_ptr, R_ptr, C_ptr, M_ptr,
                #     self.I, self.J, self.K, self.normConstant,
                #     self.numIters, self.objFunc, self.qn, self.cg,
                #     &self.C_distance, &self.num_C_steps, lower, upper)
                # E_after_C = self.E
                self.E = mcmm_functions.cg_C(C_ptr, M_ptr, X_ptr, R_ptr, 
                        self.I, self.K, self.J, self.normConstant,
                        lower, upper)
                # for j in range(self.J):
                #     for k in range(self.K):
                #         vec_C[J*K + k] = C_ptr[j][k]
                E_after_C = self.E
                print "\n@@@@@@ mcmm_cy", "self.I =", self.I
                sys.stdout.flush()
                print "\n@@@@@@ end optimize_C"
                sys.stdout.flush()
                print "\nE from C", "=", E_after_C
                sys.stdout.flush()
                self.E = mcmm_functions.R_and_E_2(R_ptr, M_ptr, C_ptr, X_ptr, 
                                    self.I, self.J, self.K, self.normConstant)

                print "mcmm M, now R_and_E"
                E_after_R = self.E

                sys.stdout.write("\n\n##################################################\n")
                sys.stdout.write("Err_new = " + "%.7f" % self.E  + "\n")
                sys.stdout.write("Err_prev = " + "%.7f" % prev_E + "\n")
                sys.stdout.write("Err_start = " + "%.7f" % Err_start + "\n")
                sys.stdout.write("\nErr_prev - Err_new = " + "%.7f" % (prev_E - self.E) + "\n")
                sys.stdout.write("Err_start - Err_new = " + "%.7f" % (Err_start - self.E) + "\n")
                sys.stdout.write("\nK = " + str(self.K) + "; J = " + str(self.J) + "\n")
                sys.stdout.write("Iteration: " + str(self.numIters) + "\n")
                sys.stdout.write("##################################################\n\n")
                ######################################
                # Break if there is no significant change in the error
                diff = prev_E - self.E
                breakTest = prev_E - self.E
                end_condition = self.E
                #sys.stdout.write("\n\n####################################################\n")
                sys.stdout.write("prev_E = %.7f" % prev_E + "; self.E = %.7f" % self.E + "; prev_E - self.E = %.7f" % diff + "\n\n")
                sys.stdout.write("prev_E - self.E = %.7f" % breakTest + "\n\n")
                print "To terminate: ", "{:.5f}".format(end_condition), " <= ", end_thresh
                #sys.stdout.write("####################################################\n\n")
                if isNaN(self.E):
                    break
                print "mcmm_nor; 1000"
                sys.stdout.flush()
                #if ((breakTest < 0.0001 or diff < 0.00001) and flag == 0) or numIters >= 40:
                if (breakTest < breakErr and flag == 0) or self.numIters >= 35:
                #if (breakTest < 0.000001 and flag == 0):
                    if self.K % self.evalInterval == 0 or end_condition < end_thresh:
                        print "mcmm_nor; activations decoder"
                        sys.stdout.flush()
                        # What is 'clusterEntries'? It is a list of all clusters (and their members) that presently exist.
                        # The clusterEntries list is constantly evolving, and its cardinality increases with K.
                        # What format does "alphabet" need to be in for activationsDecoder?
                        activationsDecoder = decode.ActivationsDecoder(self.Mv, self.Cv, self.Rv, 
                                                self.wordList, self.thresh)
                        for i in range(len(standards)):
                            mila_preprocess(activationsDecoder.getClusters(standards[i]), self.tempDir, 
                                                self.outputPrefix, self.K, standards[i])
                        print "mcmm_nor; 1003"
                        sys.stdout.flush()
                    break
                flag = 0
                self.numIters += 1
            if end_condition < end_thresh:
                break
        dealloc_matrix(X_ptr, self.I)
        #print "freed X", "\n\n"
        dealloc_matrix(R_ptr, self.I)
        #print "freed R", "\n\n"
        dealloc_matrix(M_ptr, self.I)
        #print "freed M", "\n\n"
        dealloc_matrix(C_ptr, self.J)
        #print "freed C", "\n\n"
        #dealloc_vector(vec_C)
        #dealloc_vector(normConstants_M) 
        
    cpdef INT get_K(self):
        return self.K
    
    cpdef INT get_I(self):
        return self.I
    
    cpdef INT get_J(self):
        return self.J
    
    cpdef FLOAT[:,::1] get_M(self):
        return self.Mv
    
    cpdef FLOAT[:,::1] get_C(self):
        print "mcmm_nor: self.Cv dim 1:", self.Cv.shape[0]
        print "mcmm_nor: self.Cv dim 2:", self.Cv.shape[1]
        return self.Cv

    cpdef FLOAT[:,::1] get_R(self):
        return self.Rv

    cpdef object get_splitSequence(self):
        return self.splitSequence

    cpdef FLOAT getError(self):
        return self.E
    
    cpdef FLOAT getOriginalError(self):
        return self.original_E
