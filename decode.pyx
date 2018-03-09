# encoding: utf-8
# cython: profile=True
# filename: decode.pyx

import sys
import numpy as np

cpdef object sequenceMap(np.ndarray[FLOAT, ndim=1] valList, np.ndarray alphabet):
        output = ""
        cdef INT counter = 0
        cdef FLOAT maxval = 0.0
        cdef INT maxpos = 0
        cdef INT ndx
        for ndx in range(valList.shape[0]-1):
            if valList[ndx] > maxval:
                maxval = valList[ndx]
                maxpos = counter
            if counter == alphabet.shape[0]-1:
                # set activation threshold for characters
                if maxval < 0.7:
                        output += '-'
                else:
                        output += alphabet[maxpos]
                counter = 0
                maxval = 0.0
                maxpos = 0
            else:
                counter += 1
        output += str(valList[-1])
        return output

cpdef int greaterThanMin(FLOAT candidate, object valsAndIndices):
        minVal = valsAndIndices[0][0]
        for (val, index) in valsAndIndices:
                if val < minVal:
                        minVal = val
        if candidate > minVal:
                return 1
        else:
                return 0
                
cpdef object sorted_output_str(object memberList):
    if len(memberList) == 0:
        return "\n"
    a_and_w = list()
    outputs = list()
    output = ""
    cdef double activity 
    for j in range(len(memberList)):
        word = memberList[j][0]
        activity = float(memberList[j][1])
        a_and_w.append((activity, word))
    a_and_w.sort(reverse=True)
    try:
        activityStr = "{:.4f}".format(a_and_w[0][0])
        output = a_and_w[0][1] + " (" + activityStr  + ")"
    except IndexError:
        return "\n"
    else:
        outputs.append(output)
    # activities has n items for n words. Each item is a tuple consisting
    # of the word itself (index 0 in the tuple) and the activity value (index 1).
    for n in range(1, len(a_and_w)):
        activityStr = "{:.4f}".format(a_and_w[n][0])
        output = a_and_w[n][1] + " (" + activityStr  + ")"
        outputs.append(output)
    return  ", ".join(outputs) + "\n"
    
cdef class FeatureDecoder:
    def __init__(self, np.ndarray[FLOAT, ndim=1] valList, affixlen, prec_span, bigrams, np.ndarray alphabet):
        self.affixlen = int(affixlen)
        self.positional = False
        self.precedence = False
        self.bigrams = False
        #self.affixlen = 4
        self.joiner = "<"
        if self.affixlen > 0:
            self.positional = True
        if prec_span != "0":
            self.precedence = True
            if prec_span == "star":
                    self.prec_span = 1000000
            else: self.prec_span = int(prec_span)
        if bigrams != "0":
            self.bigrams = True
        self.featureVector = valList
        self.alphabet = np.asarray(alphabet, dtype='|S1')
        self.posFeatures = list()
        self.precFeatures = list()
        self.bigramFeatures = list()
        self.allFeatures = list()
        if self.positional:
            for i in range(self.affixlen):
                for j in range(len(self.alphabet)):
                    self.posFeatures.append(self.alphabet[j] + "@[" + str(i) + "]")
            for i in reversed(range(self.affixlen)):
                for j in range(len(self.alphabet)):
                    self.posFeatures.append(self.alphabet[j] + "@[" + str(i-self.affixlen) + "]")
            self.allFeatures.extend(self.posFeatures)
        if self.precedence:
            for char_x in self.alphabet:
                for char_y in self.alphabet:
                    self.precFeatures.append(char_x + "<" + char_y)
            self.allFeatures.extend(self.precFeatures)
        if self.bigrams:
            for char_x in self.alphabet:
                for char_y in self.alphabet:
                    self.bigramFeatures.append(char_x + "+" + char_y)
            self.allFeatures.extend(self.bigramFeatures)

##    cpdef object highestValsAndIndices(self, INT N):
##        mostActive = list()
##        #cdef FLOAT maxVal = 0.0
##        cdef int j
##        #mostActive.append((self.featureVector[0],0))
##        for j in range(len(self.featureVector)):
##            #if len(mostActive) < N or greaterThanMin(self.featureVector[j], mostActive) == 1:
##            mostActive.append((self.featureVector[j],j))
##            #maxVal = self.featureVector[j]
##            mostActive.sort(reverse=True)
##            if len(mostActive) > N:
##                mostActive.pop()
##        return mostActive

    cpdef object highestValsAndIndices(self, INT N):
        N_highest = list()
        cdef int j,n
        # make list of tuples (values, indices)
        vals_and_indices = list()
        for j in range(len(self.featureVector)):
            vals_and_indices.append((self.featureVector[j],j))
        # sort by value
        vals_and_indices.sort(reverse=True)
        for n in range(N):
            N_highest.append(vals_and_indices[n])
        N_highest.sort(reverse=True)
        return N_highest
    
    cpdef object lowestValsAndIndices(self, INT N):
        N_lowest = list()
        cdef int j,n
        # make list of tuples (indices and values)
        vals_and_indices = list()
        for j in range(len(self.featureVector)):
            vals_and_indices.append((self.featureVector[j],j))
        # sort by value
        vals_and_indices.sort()
        for n in range(N):
            N_lowest.append(vals_and_indices[n])
        N_lowest.sort()
        return N_lowest

    cpdef object decodedFeatures(self, object valsAndIndices):
        featuresAndVals = list()
        for (activity, index) in valsAndIndices:
                activityStr = "%.4f" % activity
                feature = self.allFeatures[index]
                featuresAndVals.append(feature + " (" + activityStr + ")")
        return featuresAndVals

    cpdef object tenMostActive(self):
        valsAndIndices = self.highestValsAndIndices(10)
        return self.decodedFeatures(valsAndIndices) 

    cpdef object tenLeastActive(self):
        valsAndIndices = self.lowestValsAndIndices(10)
        return self.decodedFeatures(valsAndIndices)
    
cdef class ActivationsDecoder:
    def __init__(self, FLOAT[:,::1] Mv, FLOAT[:,::1] Cv, FLOAT[:,::1] Rv, object wordList, FLOAT thresh):
                
        #This class's primary purpose is to assemble an inverted cluster
        #assignment matrix. Mv is a cluster
        #activity matrix. It is a typed memoryview.
        #The "v" in "Mv" stands for "view."

        #In the matrix Mv, which is the non-inverted (or "regular")
        #cluster activity matrix, the rows correspond 
        #to words. In particular, each row is a particular word's
        #cluster assignment vector. i.e., a vector indicating
        #which clusters the word in question is a member of. The columns
        #correspond to clusters. The k-th cell in 
        #the i-th contains 1 (if word i is a member of cluster k),
        #0 (if word i is not a member of cluster k), or 
        #some number between 0 and 1 indicate 
        #a degree of uncertainty.

        #Now, this class produces the inverse of such a matrix. I.e., the rows are now clusters, and the columns 
        #are words.
                
        #In this class, we don't care about cluster centroids, i.e., about particular labels for clusters.
        #What we care about is cluster membership.

        self.clusters_m_toPrint = []
        self.clusters_mr_toPrint = []
        self.clusters_mc_toPrint = []
        self.clusters_mcr_toPrint = []
        self.clusters_justWords = []
        self.Rv = Rv
        self.Mv = Mv
        self.Cv = Cv
        cdef INT i, k, j, n
        cdef INT I = self.Rv.shape[0]
        cdef INT K = self.Mv.shape[1]
        cdef INT J = self.Cv.shape[0]
        cdef object clusters_m, clusters_mr, clusters_mc, clusters_mcr
        clusters_m = [[] for k in range(K)]
        clusters_mr = [[] for k in range(K)]
        clusters_mc = [[] for k in range(K)]
        clusters_mcr = [[] for k in range(K)]
        self.clusters_justWords = [[] for k in range(K)]
        cdef bint membership = 0
        cdef object word_and_val
        cdef FLOAT mc = 0.0
        # "wordList" is a list of the text-formatted words corresponding to the datapoints (feature vectors).
        # the activations matrix M contains I rows (# of data points) and K columns (# of clusters).
        # the k-th column in M corresponds to the k-th column in C.
        for i in range(I):
            # Iterate over the row M[i], which is a row of k elements
            # Each k represents a cluster
            for k in range(K):
                # for each index k, find the corresponding kth column in the
                # J x K matrix C.
                # Then proceed down the j (row) indices in this column
                # until a [j,k] cell is found that meets the membership
                # criteria. Only one such cell is needed.

                if self.Mv[i,k] >= thresh:
                    word_and_val = (wordList[i], "{:.4f}".format(self.Mv[i,k]))
                    if word_and_val in clusters_m[k]:
                        pass
                    else:
                        clusters_mcr[k].append(word_and_val)
                    if wordList[i] in self.clusters_justWords[k]:
                        pass
                    else:
                        self.clusters_justWords[k].append(wordList[i])

                if self.Mv[i,k] >= thresh:
                    for j in range(J):
                        if (self.Rv[i,j] >= 0.5):
                            membership = 1
                            break
                if membership == 1:
                    membership = 0
                    word_and_val = (wordList[i], "{:.4f}".format(self.Mv[i,k]))
                    if word_and_val in clusters_mr[k]:
                        pass
                    else:
                        clusters_mr[k].append(word_and_val)
                    if wordList[i] in self.clusters_justWords[k]:
                        pass
                    else:
                        self.clusters_justWords[k].append(wordList[i])

                mc = 0.0
                for j in range(J):
                    mc = self.Mv[i,k]*self.Cv[j,k]
                    if (mc >= thresh):
                        membership = 1
                        break
                if membership == 1:
                    membership = 0
                    word_and_val = (wordList[i], "{:.4f}".format(mc))
                    if word_and_val in clusters_mc[k]:
                        pass
                    else:
                        clusters_mc[k].append(word_and_val)
                    if wordList[i] in self.clusters_justWords[k]:
                        pass
                    else:
                        self.clusters_justWords[k].append(wordList[i])

                mc = 0.0
                for j in range(J):
                    mc = self.Mv[i,k]*self.Cv[j,k]
                    if (mc >= thresh) and (self.Rv[i,j] >= 0.5):
                        membership = 1
                        break
                if membership == 1:
                    membership = 0
                    word_and_val = (wordList[i], "{:.4f}".format(mc))
                    if word_and_val in clusters_mcr[k]:
                        pass
                    else:
                        clusters_mcr[k].append(word_and_val)
                    if wordList[i] in self.clusters_justWords[k]:
                        pass
                    else:
                        self.clusters_justWords[k].append(wordList[i])
                    
        for k in range(len(clusters_m)):
            self.clusters_m_toPrint.append(sorted_output_str(clusters_m[k]))

        print str(clusters_mr)
        for k in range(len(clusters_mr)):
            self.clusters_mr_toPrint.append(sorted_output_str(clusters_mr[k]))

        for k in range(len(clusters_mc)):
            self.clusters_mc_toPrint.append(sorted_output_str(clusters_mc[k]))

        for k in range(len(clusters_mcr)):
            self.clusters_mcr_toPrint.append(sorted_output_str(clusters_mcr[k]))
            
    cpdef object getClusters(self, standard):
        if standard == "m--":
            return self.clusters_m_toPrint
        elif standard == "m-r":
            return self.clusters_mr_toPrint
        elif standard == "mc-":
            return self.clusters_mc_toPrint
        elif standard == "mcr":
            return self.clusters_mcr_toPrint
        else:
            return []

    cpdef object getClusters_justWords(self, standard):
        if standard == "m--":
            return self.clusters_justWords
        elif standard == "m-r":
            return self.clusters_justWords
        elif standard == "mc-":
            return self.clusters_justWords
        elif standard == "mcr":
            return self.clusters_justWords
        else:
            return []
