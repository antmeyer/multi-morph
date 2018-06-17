#cython: profile=True
#cython: cdivision=True
#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os,sys,math
import random, codecs, unicodedata
from random import choice
#import regex as re
from StringIO import StringIO
#import numpy
#from numpy import *
cimport numpy as np
import numpy as np
import time
import decode
cimport decode
import encode_nor
cimport encode_nor
#from n_best import get_n_best
import mcmm_nor
#from common_subsequences import common_subsequences
cimport mcmm_nor
from transliterate import *
reload(sys)  
sys.setdefaultencoding('utf8')
UTF8Writer = codecs.getwriter('utf-8')
sys.stdout = UTF8Writer(sys.stdout)
sys.stderr = UTF8Writer(sys.stderr)
def generateData(numExamples, width):
    choices = [0]*(width-1)
    choices.append(1)
    data = list()
    for x in range(int(numExamples)):
        vector = list()
        rows = list()
        cols = list()
        for i in range(width):
            c1 = choice(choices)
            c2 = choice(choices)
            rows.append(c1)
            cols.append(c2)
        for i in range(len(rows)):
            value = rows[i]
            row = [value]*width
            vector.extend(row)
        for j in range(len(cols)):
            k = j
            while k < len(vector):
                if cols[j] != 0:
                    vector[k] = cols[j]
                k += len(cols)
        data.append(vector)
    return data

def writeMatrixToFile(data, numRows, numColumns, filename, width, x_by_y=False, addendum=False):
    fobj = codecs.open(filename, 'w', encoding='utf8')
    for i in range(numRows):
        for j in range(numColumns):
            if x_by_y:    
                if (j + 1) % width == 0:
                    fobj.write("%.4f" % data[i,j] + "\n")
                else:
                    fobj.write("%.4f" % data[i,j] + "  ")
            else:
                fobj.write("%.4f" % data[i,j] + "  ")
        fobj.write("\n")
    if addendum:
        fobj.write("\n\n" + addendum)
    fobj.close()
    
def writeDataToFile(data, filename, width, x_by_y=False):
    fobj = codecs.open(filename, 'w', encoding='utf8')
    for i in range(len(data)):
        for j in range(len(data[i])):
            if x_by_y:    
                if (j + 1) % width == 0:
                    fobj.write(str(data[i][j]) + "\n")
                else:
                    fobj.write(str(data[i][j]) + "  ")
            else:
                pass
                #fobj.write("%%%%%%%%%%%%%%%%%%%%%%%%%%%%")
    ##    #print"%%%%% OUTPUT PREFIX:(str(data[i][j]) + "  ")
        fobj.write("\n")
    fobj.close()

def writeOutput(dataStrings, filename):
    fobj = codecs.open(filename, 'w', encoding='utf8')
    for string in dataStrings:
        fobj.write(str(string) + "\n")
    fobj.close()
        
def processFile(filename):
    fobj = codecs.open(filename, 'r', encoding='utf8')
    dataMatrix = list()
    for line in fobj.readlines():
        string = string.replace("\n","")
        string = string.replace("\r","")
        dataRow = string.split()
        intList = [int(value) for value in dataRow]
        dataMatrix.append(intList)
    fobj.close()
    return dataMatrix

def getHomogeneousColumns(matrix):
    cdef int i,j
    cdef int I = matrix.shape[0]
    cdef int J = matrix.shape[1]
    if I <= 1:
        return matrix
    # cdef object trivial_cols = []
    # all_same = False
    # prev_val = 0.0
    # for j in range(J):
    #     all_same = True
    #     prev_val = matrix[0,j]
    #     for i in range(1,I):
    #         if prev_val != matrix[i,j]:
    #             all_same = False
    #             break
    #         prev_val = matrix[i,j]
    #     if all_same:
    #         trivial_cols.append((j, prev_val))
    cdef object trivial_cols = []
    cdef np.ndarray matT = np.copy(matrix).T
    cdef double s = 0.0
    #cdef double val = 0.0
    trivial_cols
    for j in range(J):
        s = np.sum(matT[j,:])
        if s == J: 
            trivial_cols.append((j, 1.0))
        elif s == 0.0:
            trivial_cols.append((j, 0.0))
    return trivial_cols

def getFeatureFreqs(matrix, featureList):
    cdef int i,j
    cdef int I = matrix.shape[0]
    cdef int J = matrix.shape[1]
    matT = np.copy(matrix.T)
    featureFreqs = {}
    for j in range(J):
        featureFreqs[featureList[j]] = np.sum(matT[j,:])
    # for j in range(J):
    #     feature_str = featureList[j]
    #     featureFreqs[feature_str] = 0
    #     for i in range(I):
    #         featureFreqs[feature_str] += matrix[i,j]
    return featureFreqs


def alphabetAndData(filename):
    fobj = codecs.open(filename, 'r', encoding='utf8')
    dataMatrix = list()
    alphabet = ""
    for line in fobj.readlines():
        string = line
        string = string.replace("\n","")
        string = string.replace("\r","")
        if isinstance(string, (unicode)) == False:
            string = unicode(string, 'utf8')
        # pat_quot = ur"\""
        # re_quot = re.compile(pat_quot, re.UNICODE)
        # if string == u"" or re_quot.search(string):
        #     break
        if string == u"" or "\"" in string: continue
        if string[0] == "#":
            alphabet = string.replace("#", "")
        else:
            dataRow = string.split()
            valList = [float(value) for value in dataRow]
            dataMatrix.append(valList)
    fobj.close()
    return (alphabet, dataMatrix)

def wordsFromFile(filename):
    fobj = codecs.open(filename, 'r', encoding='utf8')
    dataMatrix = list()
    alphabet = ur""
    for line in fobj.readlines():
        string = line 
        string = string.replace("\n","")
        string = string.replace("\r","")
        string = string.replace("'","")
        if isinstance(string, (unicode)) == False:
            string = unicode(string, 'utf8')
        # pat_quot = ur"\""
        # re_quot = re.compile(pat_quot, re.UNICODE)
        # if string == u"" or re_quot.search(string):
        #     break
        # if string[0] == u"#":
        #     alphabet = string[1:]
        if string =="" or "\"" in string: continue
        if string[0] == "#":
            alphabet = string.replace("#", "")
            # if isinstance(alphabet, (unicode)) == False:
            #     alphabet = unicode(alphabet, 'utf8')
        else:
            words = string.split()
            dataMatrix.append(words[0])
    fobj.close()
    return (alphabet, dataMatrix)

def longestLength(wordList):
    maxLength = 0
    for word in wordList:
        if len(word) > maxLength:
            maxLength = len(word)
    return maxLength
    ##    #print"%%%%% OUTPUT PREFIX:

def inverseDiag(squareMatrix, size):
    diagM = zeros((size,size))
    for n in range(size):
        sys.stdout.write("squareMatrix[" + str(n) + "," + str(n) + "] = " + "%.5f" % squareMatrix[n,n] + "\n")
        try:
            val = 1.0/squareMatrix[n,n]
        except ZeroDivisionError:
            diagM = pinv(squareMatrix)
            sys.stdout.write("\n*** PINV of diagM:\n")
            #printdiagM
            sys.stdout.write("\n")
            break
        else:
             diagM[n,n] = val
    return diagM

def diagMatrix(squareMatrix, size):
    diagM = zeros((size,size))
    for n in range(size):
        diagM[n,n] = squareMatrix[n,n]
    return diagM
    
def import_M(filename, words):
    fobj = codecs.open(filename, 'r', encoding='utf8')
    data_from_file = list()
    words_from_file = list()
    for line in fobj.readlines():
        line = line.replace("\n", "")
        line = line.replace("\r", "")
        items = line.split()
        words_from_file.append(items[0])
        data_row = list() 
        for item in items[1:]:
            data_row.append(float(item))
        data_from_file.append(data_row)
    I = len(words)
    #K = len(data_from_file[0]) + 1
    K = len(data_from_file[0])
    M = np.empty([I,K])
    for i in range(I):
        #for k in range(K-1):
        for k in range(K):
            #M[i][k] = random.choice([0.0, random.uniform(0.0,0.2)])
            M[i][k] = 0.5
        #M[i][K-1] = random.uniform(0.8,1.0)
    for h in range(len(words_from_file)):
        try: i = words.index(words_from_file[h])
        except ValueError: continue
##            for k in range(K):
##                M[i][k] = 0.5
        else:
            for k in range(K-1):
                M[i][k] = data_from_file[h][k]
    return M
    
def import_C(filename, features):
    fobj = codecs.open(filename, 'r', encoding='utf8')
    data_from_file = list()
    features_from_file = list()
    for line in fobj.readlines():
        line = line.replace("\n", "")
        line = line.replace("\r", "")
        items = line.split()
        features_from_file.append(items[0])
        data_row = list() 
        for item in items[1:]:
            data_row.append(float(item))
        data_from_file.append(data_row)
    J = len(features)
    #K = len(data_from_file[0]) + 1
    K = len(data_from_file[0])
    C = np.empty([J,K])
    for j in range(J):
        for k in range(K):
            C[j,k] = random.uniform(-1.0,1.0)
    for h in range(len(words_from_file)):
        try: j = features.index(features_from_file[h])
        except ValueError: continue
        else:
            for k in range(K):
                C[j][k] = data_from_file[j][h]
##    C = np.empty([K,J])
##    for h in range(len(features_from_file)):
##        try: j = features.index(features_from_file[h])
##        except ValueError: continue
##            for k in range(K):
##                C_T[j][k] = random.uniform(0.0,1.0)
##        else:
        #for k in range(K-1):
##        for k in range(K):
##            C_T[j][k] = data_from_file[h][k]
##    for k in range(K):
##        for j in range(J):
##            C[k,j] = C_T[j,k]
    return C
    
def format_M(M, words):
    strings = list()
    for i in range(M.shape[0]):
        activityStr = words[i]
        for k in range(M.shape[1]):
            activityStr += "  " + "{:.7f}".format(M[i][k])
        strings.append(activityStr + "\n")
    return strings

def format_C(C, features):
    strings = list()
    for j in range(C.shape[0]):
        activityStr = features[j]
        for k in range(C.shape[1]):
            activityStr += "  " + "{:.7f}".format(C[j][k])
        strings.append(activityStr + "\n")
    return strings

# def mila_preprocess(clusterEntries, tempDir, outputPrefix):
#     cdef int k
#     clusterStr = ""
#     for k in range(len(clusterEntries)):
#         str_k = "{0:03d}".format(k)
#         items = outputPrefix.split("/")
#         fileName = items[1]
#         fileobj = open(tempDir + "/" + fileName + "." + str_k + ".input", "w")
#         clusterStr = eng2heb_2(eng2heb_1(clusterWords(clusterEntries[k])))
#         clusterStr = clusterStr.rstrip("\n")
#         fileobj.write(clusterStr)
#         fileobj.close()
    
# def main(inputFile, outputPrefix, init_M_file, init_C_file, affixlen, prec_span, bigrams,
#                          max_K, k_interval, tempDir, experimentTitle, useSQ, objFunc,
#                          qn, cg, mixingFunc, eta_raw):

def writeOutputFiles(M, C, R, error, originalErr, affixlen, prec_span, prec_types, alphabet, wordList, 
                    featureList, thresh, I, J, K, outputPrefix, experimentTitle, deletedFeatures_str):
    clusterEntries = list()
    splitSequence = list()
    formatted_M_strings = format_M(M, wordList)
    formatted_C_strings = format_C(C, featureList)
    bigrams = 0
    ######################################
    cdef double M_1 = 0.0
    cdef double M_0 = 0.0
    cdef double M_other = 0.0
    cdef double M_1_ratio = 0.0
    cdef double M_0_ratio = 0.0
    cdef double M_other_ratio = 0.0
    cdef double avg_C_other = 0.0
    cdef double avg_c = 0.0
    cdef double avg_m = 0.0
    cdef double avg_m_per_i = 0.0
    for i in range(I):
        avg_m = 0.0
        for k in range(K):
            avg_m += M[i,k]
            if M[i,k] == 0.0:
                M_0+=1
            elif M[i,k] == 1.0:
                M_1+=1
            else:
                M_other+=1
        avg_m_per_i += avg_m/float(K)
    avg_m_per_i = avg_m_per_i/float(I)
    M_1_ratio = M_1/float(I*K)
    M_0_ratio = M_0/float(I*K)
    M_other_ratio = M_other/float(I*K)
    ##print"wrapper_nor", 15
    ##sys.stdout.flush()
    cdef double C_1 = 0.0
    cdef double C_0 = 0.0
    cdef double C_neg1 = 0.0
    cdef double C_other = 0.0
    cdef double avg_C_1 = 0.0
    cdef double avg_C_0 = 0.0
    #cdef double avg_C_neg1 = 0.0
    avg_C_other = 0.0
    avg_c = 0.0
    for j in range(J):
        for k in range(K):
            avg_c += C[j,k]
            if C[j,k] == 0.0:
                C_0 += 1.0
            elif C[j,k] == 1.0:
                C_1 += 1.0
            # elif C[j,k] == -1.0:
            #     C_neg1 += 1
            else:
                C_other += 1.0
    avg_c = avg_c/float(J*K)
    avg_C_1 = float(C_1)/float(J*K)
    avg_C_0 = float(C_0)/float(J*K)
    #avg_C_neg1 = C_neg1/float(J*K)
    avg_C_other = float(C_other)/float(J*K)
    ###print"wrapper_nor", 20
    ##sys.stdout.flush()
    cdef double avg_mc = 0.0
    cdef double avg_mc_per_i = 0.0
    for i in range(I):
        avg_mc = 0.0
        for j in range(J):
            for k in range(K):
                avg_mc += M[i,k]*C[j,k]
        avg_mc_per_i += avg_mc/float(J*K)
    avg_mc_per_i = avg_mc_per_i/float(I)

    cdef double avg_r = 0.0
    cdef double avg_r_per_i = 0.0
    for i in range(I):
        avg_r = 0.0
        for j in range(J):
            avg_r += R[i,j]
        avg_r_per_i += avg_r/float(J)
    avg_r_per_i = avg_r_per_i/float(I)
    #print"wrapper_nor", 30
    #sys.stdout.flush()
    sparsity_stats = "M\tm = 0\t" + "{:.6f}".format(M_0_ratio) + "\n"
    sparsity_stats += "M\tm = 1\t" + "{:.6f}".format(M_1_ratio) + "\n"
    sparsity_stats += "M\tm other\t" + "{:.6f}".format(M_other_ratio) + "\n"
    sparsity_stats += "M\tavg m\t" + "{:.6f}".format(avg_m_per_i) + "\n\n"
    sparsity_stats += "C\tc = 0\t" + "{:.6f}".format(avg_C_0) + "\n"
    sparsity_stats += "C\tc = 1\t" + "{:.6f}".format(avg_C_1) + "\n"
    #sparsity_stats += "C\tc = -1\t" + "{:.6f}".format(avg_C_neg1) + "\n"
    sparsity_stats += "C\tc other\t" + "{:.6f}".format(avg_C_other) + "\n"
    sparsity_stats += "C\tavg c\t" + "{:.6f}".format(avg_c) + "\n\n"
    sparsity_stats += "MC\tavg m*c\t" + "{:.6f}".format(avg_mc_per_i) + "\n"
    sparsity_stats += "R\tavg r\t" + "{:.6f}".format(avg_r_per_i) + "\n"
    ######################################
    
    #cdef double t2 = time.clock()
    #cdef double total_min = (t2 - t1)/60.0
    #cdef double total_hrs = total_min/60.0
    words = list()
    activationsDecoder = decode.ActivationsDecoder(M, C, R, wordList, thresh)
    #std = "mc-"
    std=""
    outputName = outputPrefix + "." + std
    clusterEntries = activationsDecoder.getClusters(std)
    clusterEntries_justWords = activationsDecoder.getClusters_justWords(std)
    #print"Number of Cluster Entries =", len(clusterEntries_justWords)
    #sys.stdout.flush()
    #outputName = 
    #print"Output Name =", outputName
    ##print"\nclusterEntries:\n", clusterEntries
    #print"len(clusterEntries) =", len(clusterEntries)
    #sys.stdout.flush()
    #print"OriginalErr =", originalErr
    #sys.stdout.flush()
    if float(originalErr) > 0.0:
        percentErrReduction = ((originalErr - error)/float(originalErr))*100.0
    else:
        percentErrReduction = 0.0
    #print"PercentErrReduction = ", percentErrReduction
    #sys.stdout.flush()
    #Open files for writing the numerical contents of the M and C matrices
    fobj_M = codecs.open(outputName + ".M_vals", 'w', encoding='utf-8')
    for string in formatted_M_strings:
       fobj_M.write(string)
    fobj_M.close()
    fobj_C = codecs.open(outputName + ".C_vals", 'w', encoding='utf-8')
    for string in formatted_C_strings:
       fobj_C.write(string)
    fobj_C.close()
    #sys.stdout.flush()

    fobj_Clusters = codecs.open(outputName + ".clusters", 'w', encoding='utf8')
    fobj_Clusters_justWords = codecs.open(outputName + ".clusters_justWords", 'w', encoding='utf8')
    fobj_Features = codecs.open(outputName + ".features", 'w', encoding='utf8')
    fobj_Clusters.write("#" + outputPrefix.split("/")[-1] + "\n")
    fobj_Clusters_justWords.write("#" + outputPrefix.split("/")[-1] + "\n")
    fobj_Clusters.write("#" + "%.3f" % percentErrReduction + "\n") #" & " + "%.3f" % total_min + " min (%.3f" % total_hrs + " hrs)\n")
    fobj_Clusters.write("\n\n")
    fobj_Clusters.write("MCMM CLUSTERING RESULTS (" + std + ")\n")
    fobj_Clusters.write(experimentTitle)
    fobj_Clusters.write("\n\n")
    fobj_Clusters.write(str(I) + " data points were processed.\n")
    fobj_Clusters.write("Each data point comprised " + str(J) + " features.\n")
    fobj_Clusters.write("Deleted Features: " + deletedFeatures_str + "\n\n")
    # fobj_Clusters.write("\nElapsed time:  %.3f" % total_min + " min  (%.3f" % total_hrs + " hrs)\n")
    fobj_Clusters.write("\nOriginal Error:  %.5f" % originalErr)
    fobj_Clusters.write("\nFinal Error:  " + "%.5f" % error + "\nFinal Cluster Count:  " + str(K))
    fobj_Clusters.write("\n\nSparsity Stats:\n" + sparsity_stats + "\n")
    ##print"new_wrapper", 28, "; len(clusterEntries_justWords) =", len(clusterEntries_justWords)
    #sys.stdout.flush()
    cluster_str = ""
    for k in range(len(clusterEntries_justWords)):
        cluster_str = ""
        for word in clusterEntries_justWords[k]:
            cluster_str += word + " "
        cluster_str.rstrip()
        fobj_Clusters_justWords.write(cluster_str + "\n")
    fobj_Clusters_justWords.close()        

    fobj_Clusters.write("\n\nCLUSTERS:\n\n")
    fobj_Features.write("\nSparsity Stats:\n" + sparsity_stats + "\n")
    fobj_Features.write("MOST ACTIVE FEATURES FOR EACH CLUSTER\n")
    fobj_Features.write(experimentTitle)
    fobj_Features.write("\n\n")
    fobj_Features.write("Deleted Features: " + deletedFeatures_str + "\n\n")
    
    sys.stderr.write("K = " + str(K) + "\n")
    sys.stderr.write("There are " + str(len(clusterEntries)) + " cluster entries.\n")
    string = ""
    #sys.stdout.flush()
    for k in range(len(clusterEntries)):
        ##print"new_wrapper", 31, "; std =", std, "; k =", k
        numParen = 0
        #count words by counting parentheses. Each word has activity value enclosed in parens.
        for char in clusterEntries[k]:
            if char == ")":
                numParen += 1
        string = str(numParen) + " word"
        if numParen > 1 or numParen == 0:
            string += "s"
        sys.stderr.write("   Cluster " + str(k) + " has " + string + ".\n")
        sys.stderr.write("\t" + clusterEntries[k][:50] + "\n")
    ##print"new_wrapper", 32, "; len(clusterEntries) =", len(clusterEntries)
    #sys.stdout.flush()
    for k in range(K):
        ##print"new_wrapper", 36, "; std =", std, "; k =", k 
        fobj_Clusters.write("## " + str(k) + "\n")
        fobj_Clusters.write(clusterEntries[k])
        fobj_Clusters.write("%%\n\n")
        ###
        my_decoder = decode.FeatureDecoder(C.T[k], affixlen, prec_span, <bint>bigrams, sorted(alphabet), featureList) 
        featureStr = "Most Active\n"
        featureStr += ', '.join(my_decoder.tenMostActive())
        featureStr += "\n\nLeast Active\n"
        featureStr += ', '.join(my_decoder.tenLeastActive())
        fobj_Features.write("## " + str(k) + "\n")
        fobj_Features.write(featureStr + "\n\n")

    # write cluster split sequence to Cluster file.
    fobj_Clusters.write("\n\nCLUSTER SPLIT SEQUENCE:\n\n")
    for i in range(len(splitSequence)):
        fobj_Clusters.write(str(i+1) + ". " + splitSequence[i])
    fobj_Clusters.close()
    fobj_Features.close()


def main(inputFile, outputPrefix, init_M_file, init_C_file, affixlen, prec_span, prec_types, bigrams,
                         max_K, k_interval, tempDir, experimentTitle, objFunc,
                         qn, cg, mixingFunc):
    # #print"TEMPDIR:", tempDir
    # #print""
    cdef int i,j,k,I,J,K,init_K
    cdef double thresh = 0.5
    affixlen = int(affixlen)
    alphabet, wordList = wordsFromFile(inputFile + ".txt")
    #useSQ = int(useSQ)
    wordList.sort()
    cdef int maxLength = longestLength(wordList)
    alphabet = np.array(sorted(list(alphabet)), dtype='S1')
    #cdef object standards = ["m--", "m-r", "mc-", "mcr"]
    ##print"wrapper_nor", 2
    #sys.stdout.flush()
    max_K = int(max_K)
    k_interval = int(k_interval)
    #precFeatureTypes = prec_types.split(",")
    my_encoder = encode_nor.FeatureEncoder(inputFile + ".txt", <int>affixlen, prec_span, prec_types, <bint>bigrams)
    ##print"wrapper_nor", "2.1"
    ##sys.stdout.flush()
    my_encoder.encodeWords()
    ##print"wrapper_nor 2.1"
    ##sys.stdout.flush()
    dataMatrix = my_encoder.getVectors()
    
    ##print"wrapper_nor 2.2"
    #print"\nDATAMATRIX SUM 1 =", np.sum(dataMatrix), "\n"
    ##sys.stdout.flush()
    #my_encoder.writeVectorsToFile(inputFile + "_in.txt")
    featureList = my_encoder.getFeatures()
    #t1 = time.clock()
    #alphabet, data = alphabetAndData(inputFile + "_in.txt")
    #sys.stderr.write("**************** DATA:\n")
    #sys.stderr.write(str(data) + "\n")
    ##print"********* DATA:"
    ##printdata
    #dataMatrix = np.array(data, dtype=np.float64)
    ##print"wrapper_nor", "2.3"
    ##sys.stdout.flush()
    homogenousColumns = []
    homogenousColumns = getHomogeneousColumns(dataMatrix)
    homogenousColumns.sort(reverse=True)
    ##print"homogenousColumns =", homogenousColumns
    featuresSharedByAll = []
    #features_uni = u""
    cdef object colsToDelete = []
    for col,val in homogenousColumns:
        colsToDelete.append(col)
        features_str = str(col) + ":" + featureList[col] + ":{:.1f}".format(val)
        featuresSharedByAll.append(features_str)
    featureFreqs = {}
    featureFreqs = getFeatureFreqs(dataMatrix, featureList)
    ##print"dataMatrix dims =", dataMatrix.shape[0], dataMatrix.shape[1]
    ##print"num featuresSharedByAll =", len(featuresSharedByAll)
    ##printu"deletedFeatures_str:", ", ".join(featuresSharedByAll)
    ##sys.stdout.flush()
    ##print"wrapper_nor", 3
    #sys.stdout.flush()
    # for col,val in homogenousColumns:
    #     colsToDelete.append(col)
    #     #print"  col =", col
    #print"\nDATAMATRIX SUM 2 =", np.sum(dataMatrix), "\n"
    #print"Before deleting homogenous columns:"
    #print"dataMatrix Size: ", dataMatrix.shape[0], "x", dataMatrix.shape[1]
    #     #print"  dataMatrix dims =", dataMatrix.shape[0], dataMatrix.shape[1]
    dataMatrix = np.delete(dataMatrix,colsToDelete,1)
    dataMatrix = np.ascontiguousarray(dataMatrix, dtype=np.float64)
    cdef double[:,::1] dm_view = np.asarray(dataMatrix,dtype='double',order='C')
    #printdm_view
    deletedFeatures_str = ", ".join(featuresSharedByAll)
    #print"Afterwards:"
    #print"dataMatrix Size: ", dataMatrix.shape[0], "x", dataMatrix.shape[1]
    #deletedFeatures_uni = deletedFeatures_str 
    #sys.stdout.flush()
    fobj_unused = codecs.open(outputPrefix + ".featfreqs", 'w', encoding='utf8')
    unused = []
    #print"wrapper_nor", 3.5
    #sys.stdout.flush()
    for index in colsToDelete:
        feature = featureList.pop(index)
        unused.append(feature)
    for feature in sorted(unused):
        fobj_unused.write(feature + "\n")
    fobj_unused.write("\n#FEATURE FREQUENCIES\n\n#Feature\tFreq.\n")
    for feature,freq in sorted(featureFreqs.items()):
        fobj_unused.write(feature + "\t" + str(freq) + "\n")
    fobj_unused.close()
    # Perhaps we can send a list of max_K values to mcmm_multiK
    # Then the mcmm would be responsible for outputing data to files
    # Is this possible?
    I = dataMatrix.shape[0]
    J = dataMatrix.shape[1]

    if init_M_file and init_C_file:
        init_M_matrix = import_M(init_M_file, wordList)
        init_K = init_M_matrix.shape[1]
        init_C_matrix = import_C(init_C_file, wordList)
    else:
        init_K = 1
        init_M_matrix = np.empty([I,1])
        for i in range(I):
            init_M_matrix[i,0] = 0.5
        init_C_matrix = np.empty([J,1])
        for j in range(J):
            init_C_matrix[j,0] = random.uniform(0.0, 1.0)
            #init_C_matrix[j,0] = random.uniform(-0.999, 0.999)
            #init_C_matrix[j,0] = 0.0
    #print"Initial Dimensions:"
    #print"M:", init_M_matrix.shape[0], "x", init_M_matrix.shape[1]
    #print"C:", init_C_matrix.shape[0], "x", init_C_matrix.shape[1]
    
    objFunc_int = 0
    if objFunc == "log":
        objFunc_int = 1
    elif objFunc == "sse":
        objFunc_int = 0
    ##print"wrapper_nor", 4
    #sys.stdout.flush()
    # if mixingFunc == "wwb":	
    #     my_mcmm = mcmm_wwb.MCMM(alphabet, wordList, dataMatrix, init_M_matrix, init_C_matrix,
    #                             affixlen, init_K, max_K, k_interval, I, J, outputPrefix, tempDir,
    #                             objFunc_int, qn, cg, thresh) #, eta_raw)
    #if mixingFunc == "nor":
    my_mcmm = mcmm_nor.MCMM(alphabet, wordList, featureList, dm_view, init_M_matrix, init_C_matrix,
                            int(affixlen), int(prec_span), prec_types, init_K, max_K, k_interval, I, J, 
                            outputPrefix, tempDir,
                            objFunc_int, qn, cg, thresh, experimentTitle, deletedFeatures_str) #, eta_raw)

        # def __init__(self, object charSet, object wordList, object featureList, 
        #         FLOAT[:,::1] dataMatrix,
        #         FLOAT[:,::1] init_M, FLOAT[:,::1] init_C, INT midpoint, 
        #         INT prec_span, object prec_types,
        #         INT init_K, INT max_K,
        #         INT evalInterval, INT I, INT J, INT K, object outputPrefix, object tempDir,
        #         INT objFunc, bint qn, bint cg, FLOAT thresh, object experimentTitle)
    my_mcmm.run_MCMM()
    ##print"new_wrapper", 5
    K = my_mcmm.get_K()
    if K%k_interval != 0:
        M = np.asarray(my_mcmm.get_M())
        # ##print"new_wrapper", 6
        C = np.asarray(my_mcmm.get_C())
        # ##print"new_wrapper", 7
        # ##sys.stdout.flush()
        R = np.asarray(my_mcmm.get_R())
        error = my_mcmm.getError()
        originalErr = my_mcmm.getOriginalError()
        K = my_mcmm.get_K()
        I = my_mcmm.get_I()
        J = my_mcmm.get_J()

        writeOutputFiles(M, C, R, error, originalErr, affixlen, prec_span, prec_types, alphabet, wordList, featureList, 
                         thresh, I, J, K, outputPrefix + "_k-" + str(K), experimentTitle, deletedFeatures_str)
    # wrp.writeOutputFiles(np.asarray(self.Mv), 
    #                                     np.asarray(self.Cv), 
    #                                     np.asarray(self.Rv), self.E, self.original_E, self.midpoint, 
    #                                     self.prec_span, self.prec_types, self.alphabet, self.wordList, 
    #                                     self.featureList, self.thresh, self.I, self.J, self.K, 
    #                                     self.outputPrefix + "_k-" + str(self.K), self.experimentTitle,
    #                                     self.deletedFeatures_str)
    # def writeOutputFiles(M, C, R, error, originalErr, affixlen, prec_span, prec_types, alphabet, wordList, 
    #                 featureList, thresh, I, J, K, outputPrefix, experimentTitle, deletedFeatures_str):

    ##print"new_wrapper", 8
    ##sys.stdout.flush()
    # clusterEntries = list()
    # splitSequence = list()
    # ##sys.stdout.flush()
    # formatted_M_strings = format_M(M, wordList)
    # ##print"new_wrapper", 10
    # ##sys.stdout.flush()
    # formatted_C_strings = format_C(C, featureList)
    # ##print"new_wrapper", 11
    # ##sys.stdout.flush()
    # K = my_mcmm.get_K()
    # I = my_mcmm.get_I()
    # J = my_mcmm.get_J()
    # ##print"new_wrapper", 14
    # ##sys.stdout.flush()
    # error = my_mcmm.getError()

    # ######################################
    # cdef double M_1 = 0.0
    # cdef double M_0 = 0.0
    # cdef double M_other = 0.0
    # cdef double M_1_ratio = 0.0
    # cdef double M_0_ratio = 0.0
    # cdef double M_other_ratio = 0.0
    # cdef double avg_C_other = 0.0
    # cdef double avg_c = 0.0
    # cdef double avg_m = 0.0
    # cdef double avg_m_per_i = 0.0
    # for i in range(I):
    #     avg_m = 0.0
    #     for k in range(K):
    #         avg_m += M[i,k]
    #         if M[i,k] == 0.0:
    #             M_0+=1
    #         elif M[i,k] == 1.0:
    #             M_1+=1
    #         else:
    #             M_other+=1
    #     avg_m_per_i += avg_m/float(K)
    # avg_m_per_i = avg_m_per_i/float(I)
    # M_1_ratio = M_1/float(I*K)
    # M_0_ratio = M_0/float(I*K)
    # M_other_ratio = M_other/float(I*K)
    # ##print"wrapper_nor", 15
    # ##sys.stdout.flush()
    # cdef double C_1 = 0.0
    # cdef double C_0 = 0.0
    # cdef double C_neg1 = 0.0
    # cdef double C_other = 0.0
    # cdef double avg_C_1 = 0.0
    # cdef double avg_C_0 = 0.0
    # #cdef double avg_C_neg1 = 0.0
    # avg_C_other = 0.0
    # avg_c = 0.0
    # for j in range(J):
    #     for k in range(K):
    #         avg_c += C[j,k]
    #         if C[j,k] == 0.0:
    #             C_0 += 1.0
    #         elif C[j,k] == 1.0:
    #             C_1 += 1.0
    #         # elif C[j,k] == -1.0:
    #         #     C_neg1 += 1
    #         else:
    #             C_other += 1.0
    # avg_c = avg_c/float(J*K)
    # avg_C_1 = float(C_1)/float(J*K)
    # avg_C_0 = float(C_0)/float(J*K)
    # #avg_C_neg1 = C_neg1/float(J*K)
    # avg_C_other = float(C_other)/float(J*K)
    # ###print"wrapper_nor", 20
    # ##sys.stdout.flush()
    # cdef double avg_mc = 0.0
    # cdef double avg_mc_per_i = 0.0
    # for i in range(I):
    #     avg_mc = 0.0
    #     for j in range(J):
    #         for k in range(K):
    #             avg_mc += M[i,k]*C[j,k]
    #     avg_mc_per_i += avg_mc/float(J*K)
    # avg_mc_per_i = avg_mc_per_i/float(I)

    # cdef double avg_r = 0.0
    # cdef double avg_r_per_i = 0.0
    # for i in range(I):
    #     avg_r = 0.0
    #     for j in range(J):
    #         avg_r += R[i,j]
    #     avg_r_per_i += avg_r/float(J)
    # avg_r_per_i = avg_r_per_i/float(I)
    # #print"wrapper_nor", 30
    # #sys.stdout.flush()
    # sparsity_stats = "M\tm = 0\t" + "{:.6f}".format(M_0_ratio) + "\n"
    # sparsity_stats += "M\tm = 1\t" + "{:.6f}".format(M_1_ratio) + "\n"
    # sparsity_stats += "M\tm other\t" + "{:.6f}".format(M_other_ratio) + "\n"
    # sparsity_stats += "M\tavg m\t" + "{:.6f}".format(avg_m_per_i) + "\n\n"
    # sparsity_stats += "C\tc = 0\t" + "{:.6f}".format(avg_C_0) + "\n"
    # sparsity_stats += "C\tc = 1\t" + "{:.6f}".format(avg_C_1) + "\n"
    # #sparsity_stats += "C\tc = -1\t" + "{:.6f}".format(avg_C_neg1) + "\n"
    # sparsity_stats += "C\tc other\t" + "{:.6f}".format(avg_C_other) + "\n"
    # sparsity_stats += "C\tavg c\t" + "{:.6f}".format(avg_c) + "\n\n"
    # sparsity_stats += "MC\tavg m*c\t" + "{:.6f}".format(avg_mc_per_i) + "\n"
    # sparsity_stats += "R\tavg r\t" + "{:.6f}".format(avg_r_per_i) + "\n"
    # ######################################
    
    # #cdef double t2 = time.clock()
    # #cdef double total_min = (t2 - t1)/60.0
    # #cdef double total_hrs = total_min/60.0
    # words = list()
    # ##print"wrapper_nor", 30.5
    # ##sys.stdout.flush()
    # activationsDecoder = decode.ActivationsDecoder(M, C, R, wordList, thresh)

    # cdef object standards = ["mc-"]
    # for std in standards:
    #     outputName = ""
    #     clusterEntries = activationsDecoder.getClusters(std)
    #     clusterEntries_justWords = activationsDecoder.getClusters_justWords(std)
    #     ##print"new_wrapper", 16.7, "std =", std
    #     #print"Number of Cluster Entries =", len(clusterEntries_justWords)
    #     #sys.stdout.flush()
    #     outputName = outputPrefix + "." + std
    #     #print"Output Name =", outputName
    #     ##print"\nclusterEntries:\n", clusterEntries
    #     #print"len(clusterEntries) =", len(clusterEntries)
    #     #sys.stdout.flush()
    #     originalErr = my_mcmm.getOriginalErr()
    #     #print"OriginalErr =", originalErr
    #     #sys.stdout.flush()
    #     if float(originalErr) > 0.0:
    #         percentErrReduction = ((originalErr - error)/float(originalErr))*100.0
    #     else:
    #         percentErrReduction = 0.0
    #     #print"PercentErrReduction = ", percentErrReduction
    #     #sys.stdout.flush()
    #     #Open files for writing the numerical contents of the M and C matrices
    #     fobj_M = codecs.open(outputName + ".M_vals", 'w', encoding='utf-8')
    #     for string in formatted_M_strings:
    #        fobj_M.write(string)
    #     fobj_M.close()
    #     ##print"new_wrapper", 20
    #     ##sys.stdout.flush()
    #     fobj_C = codecs.open(outputName + ".C_vals", 'w', encoding='utf-8')
    #     for string in formatted_C_strings:
    #        fobj_C.write(string)
    #     fobj_C.close()
    #     #sys.stdout.flush()

    #     fobj_Clusters = codecs.open(outputName + ".clusters", 'w', encoding='utf8')
    #     fobj_Clusters_justWords = codecs.open(outputName + ".clusters_justWords", 'w', encoding='utf8')
    #     fobj_Features = codecs.open(outputName + ".features", 'w', encoding='utf8')
    #     fobj_Clusters.write("#" + outputPrefix.split("/")[-1] + "\n")
    #     fobj_Clusters_justWords.write("#" + outputPrefix.split("/")[-1] + "\n")
    #     fobj_Clusters.write("#" + "%.3f" % percentErrReduction + "\n") #" & " + "%.3f" % total_min + " min (%.3f" % total_hrs + " hrs)\n")
    #     fobj_Clusters.write("\n\n")
    #     fobj_Clusters.write("MCMM CLUSTERING RESULTS (" + std + ")\n")
    #     fobj_Clusters.write(experimentTitle)
    #     fobj_Clusters.write("\n\n")
    #     fobj_Clusters.write(str(I) + " data points were processed.\n")
    #     fobj_Clusters.write("Each data point comprised " + str(J) + " features.\n")
    #     fobj_Clusters.write("Deleted Features: " + deletedFeatures_str + "\n\n")
    #     # fobj_Clusters.write("\nElapsed time:  %.3f" % total_min + " min  (%.3f" % total_hrs + " hrs)\n")
    #     fobj_Clusters.write("\nOriginal Error:  %.5f" % originalErr)
    #     fobj_Clusters.write("\nFinal Error:  " + "%.5f" % error + "\nFinal Cluster Count:  " + str(K))
    #     fobj_Clusters.write("\n\nSparsity Stats:\n" + sparsity_stats + "\n")
    #     ##print"new_wrapper", 28, "; len(clusterEntries_justWords) =", len(clusterEntries_justWords)
    #     #sys.stdout.flush()
    #     cluster_str = ""
    #     for k in range(len(clusterEntries_justWords)):
    #         cluster_str = ""
    #         for word in clusterEntries_justWords[k]:
    #             cluster_str += word + " "
    #         cluster_str.rstrip()
    #         fobj_Clusters_justWords.write(cluster_str + "\n")
    #     fobj_Clusters_justWords.close()        

    #     fobj_Clusters.write("\n\nCLUSTERS:\n\n")
    #     fobj_Features.write("\nSparsity Stats:\n" + sparsity_stats + "\n")
    #     fobj_Features.write("MOST ACTIVE FEATURES FOR EACH CLUSTER\n")
    #     fobj_Features.write(experimentTitle)
    #     fobj_Features.write("\n\n")
    #     fobj_Features.write("Deleted Features: " + deletedFeatures_str + "\n\n")
        
    #     sys.stderr.write("K = " + str(K) + "\n")
    #     sys.stderr.write("There are " + str(len(clusterEntries)) + " cluster entries.\n")
    #     string = ""
    #     #sys.stdout.flush()
    #     for k in range(len(clusterEntries)):
    #         ##print"new_wrapper", 31, "; std =", std, "; k =", k
    #         numParen = 0
    #         #count words by counting parentheses. Each word has activity value enclosed in parens.
    #         for char in clusterEntries[k]:
    #             if char == ")":
    #                 numParen += 1
    #         string = str(numParen) + " word"
    #         if numParen > 1 or numParen == 0:
    #             string += "s"
    #         sys.stderr.write("   Cluster " + str(k) + " has " + string + ".\n")
    #         sys.stderr.write("\t" + clusterEntries[k][:50] + "\n")
    #     ##print"new_wrapper", 32, "; len(clusterEntries) =", len(clusterEntries)
    #     #sys.stdout.flush()
    #     for k in range(K):
    #         ##print"new_wrapper", 36, "; std =", std, "; k =", k 
    #         fobj_Clusters.write("## " + str(k) + "\n")
    #         fobj_Clusters.write(clusterEntries[k])
    #         fobj_Clusters.write("%%\n\n")
    #         ###
    #         my_decoder = decode.FeatureDecoder(C.T[k], affixlen, prec_span, <bint>bigrams, sorted(alphabet), featureList) 
    #         featureStr = "Most Active\n"
    #         featureStr += ', '.join(my_decoder.tenMostActive())
    #         featureStr += "\n\nLeast Active\n"
    #         featureStr += ', '.join(my_decoder.tenLeastActive())
    #         fobj_Features.write("## " + str(k) + "\n")
    #         fobj_Features.write(featureStr + "\n\n")

    #     # write cluster split sequence to Cluster file.
    #     fobj_Clusters.write("\n\nCLUSTER SPLIT SEQUENCE:\n\n")
    #     for i in range(len(splitSequence)):
    #         fobj_Clusters.write(str(i+1) + ". " + splitSequence[i])
    # fobj_Clusters.close()
    # fobj_Features.close()

    
if __name__ == "__main__":
    # program_name  input-type  input-file-name  output-file-name  splitSequence-file-name
    # wb_in_cg6-3.txt
    inputFileName = sys.argv[1]
    outputPrefix = sys.argv[2]
    affixlen = sys.argv[3]
    prec_span = sys.argv[4]
    prec_types = sys.argv[5]
    bigrams = sys.argv[6]
    num_clusters = sys.argv[7]
    feature_type = sys.argv[8]
    tempDir = sys.argv[9]
    experimentTitle = sys.argv[10]
    init_M_file = sys.argv[11]
    init_C_file = sys.argv[12]
    #useSQ = int(sys.argv[12])
    objFunc = sys.argv[13]
    qn = int(sys.argv[14])
    cg = sys.argv[15]
    mixingFunc = sys.argv[16]

    #print"^^^Now in wrapper. Prec_types =", prec_types
    #eta_raw = sys.argv[16]
    # main(inputFileName, outputPrefix, init_M_file, init_C_file, affixlen, prec_span, bigrams,
    #     num_clusters, k_interval, feature_type, tempDir, experimentTitle,
    #     useSQ, objFunc, qn, cg, mixingFunc, eta_raw)
    # main(inputFileName, outputPrefix, init_M_file, init_C_file, affixlen, prec_span, bigrams,
    #     num_clusters, k_interval, feature_type, tempDir, experimentTitle,
    #     useSQ, objFunc, qn, cg, mixingFunc)
    main(inputFileName, outputPrefix, init_M_file, init_C_file, affixlen, prec_span, prec_types, bigrams,
        num_clusters, k_interval, feature_type, tempDir, experimentTitle,
        objFunc, qn, cg, mixingFunc)
