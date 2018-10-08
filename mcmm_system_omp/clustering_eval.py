#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os,sys,re, math, bisect
from analysisParser import *
from transliterate import heb2eng
from bcubed_eval import bcubed_prec, bcubed_rec
import numpy as np

analysesFile = sys.argv[1]
inputFile = sys.argv[2]

bermanAnalysesFile = sys.argv[1]
clustersFile = sys.argv[2]

def entropy(freqs, total_item_count):
	#cdef double H, a, b, N
	if total_item_count == 0:
		return 0.0
	N = float(total_item_count)
	H = 0.0
	prob = 0.0
	logProb = 0.0
	total_prob = 0.0
	for type in freqs:
		# freqs[type]
		prob = freqs[type]/N
		#sys.stderr.write("*** " + type + ": " + "{:.5f}".format(prob) + "\n")
		total_prob += prob
		try: logProb = math.log(prob, 2)
		except ValueError: continue
		else: H -= (prob * logProb)
	#sys.stderr.write("*** " + "SUM PROB = " + "{:.5f}".format(total_prob) + "\n")
	return H

def jointEntropy(X_freqs, Y_freqs, X_and_Y_freqs, numInstances):
	if numInstances == 0:
		return 0.0
	N = float(numInstances)
	joint_H = 0.0
	for x in X_freqs:
		for y in Y_freqs:
			if X_and_Y_freqs[x].has_key(y):
				prob_xy = X_and_Y_freqs[x][y] / N
				try: logProb = math.log(prob_xy , 2)
				except ValueError: continue
				else: joint_H -= (prob_xy * logProb)
	return joint_H 
	
def mutualInfo(X_freqs, Y_freqs, X_and_Y_freqs, numInstances):
	#cdef double H, a, b, N
	if numInstances == 0:
		return 0.0
	N = float(numInstances)
	Info = 0.0
	X_probs = {}
	Y_probs = {}
	for x in X_freqs:
		X_probs[x] = X_freqs[x] / N
	for y in Y_freqs:
		Y_probs[y] = Y_freqs[y] / N		
	for x in X_freqs:
		for y in Y_freqs:
			#if X_and_Y_freqs[x].has_key(y):
			try: prob_xy = X_and_Y_freqs[x][y] / N
			except KeyError: continue
			else:
				#sys.stderr.write("%%% " + x + ", " + y + ": " + "{:.5f}".format(prob_xy) + "\n")
				try: log_arg = prob_xy / (X_probs[x] * Y_probs[y])
				except ZeroDivisionError: 
					continue #log_arg = 0.0
				else:
					Info += prob_xy * math.log(log_arg, 2)
					#sys.stderr.write("   %%%%% " + x + "(" + "{:.5f}".format(X_probs[x]) + "), " + y + "(" + "{:.5f}".format(Y_probs[y]) + "): " + "{:.5f}".format(prob_xy) + "\n")				
	return Info
	
def keywithmaxval(d):
	""" a) create a list of the dict's keys and values; 
         b) return the key with the max value"""  
	v=list(d.values())
	k=list(d.keys())
	return k[v.index(max(v))]

#roots_db = getRootsDatabase("data/roots_db.txt")

#File names look like: 4_star_K-50_N-6888_2014-02-10_12-41.K@5.output_trans
#File name components (delimited by underscore): 
## [0] affix length
## [1] delta (precedence span) 
## [2] K-($K)
## [3] N-($N)
## [4] ETA-($ETA)
## [5] date
## [6] time
## The K evaluation checkpoint is preceded and followed by a dot (period).
#FILE FORMAT: /Users/anthonymeyer/Documents/qual_paper_2/code/mcmm-cython/mcmm_results/mcmm-out_N-6888_ETA-default_K-3_2015-10-16_23-17/3_3_0_K-3_N-6888_ETA-default_2015-10-16_23-17.K@3.transoutput

sys.stderr.write("%%%" + str(analysesFile) + "\n")
sys.stderr.write("*****************************\n")
items = analysesFile.split('/')
filename = items[-1]
name_chunks = filename.split('.')
mainFileName = name_chunks[0]
Ktag = name_chunks[1]
standard = name_chunks[2]
sys.stderr.write("%%% Ktag = " + str(Ktag) + "\n")
Kstr = Ktag.split("@")[-1]
Knum = int(Kstr.lstrip("0"))
sys.stderr.write("%%% Knum = " + str(Knum) + "\n")
Kval = "{0:04d}".format(Knum)
nameComponents = mainFileName.split("_")
affixlen = nameComponents[0]
delta = nameComponents[1]
bigrams = nameComponents[2]
bigK = nameComponents[3].split("-")[-1]
Ntag = nameComponents[4]
eta = nameComponents[5].split("-")[-1]
# mainFile = analysesFile.split(".")[2]
# Ktag = analysesFile.split(".")[3]
# sys.stderr.write("%%% Ktag = " + str(Ktag) + "\n")
# Kstr = Ktag.split("@")[-1]
# Knum = int(Kstr.lstrip("0"))
# sys.stderr.write("%%% Knum = " + str(Knum) + "\n")
# Kval = "{0:04d}".format(Knum)
# Ktag = "K@" + Kval
# mainFileName = mainFile.split("/")[3]
# sys.stderr.write("%%% mainFileName: " + str(mainFileName) + "\n")
# nameComponents = mainFileName.split("_")
# affixlen = nameComponents[0]
# delta = nameComponents[1]
# bigK = nameComponents[2].split("-")[-1]

affixlen = affixlen.replace("na","n/a")
delta = delta.replace("na","n/a")
delta = delta.replace("star", "*")

# if re.search("precedence", mainFileName):
# 	deltaSpec = nameComponents[4]
# 	delta = deltaSpec.split("-")[1]
# elif re.search("positional", mainFileName):
# 	affixlenSpec = nameComponents[3]
# 	affixlen = affixlenSpec.split("-")[-1]
# else:
# 	affixlenSpec = nameComponents[3]
# 	deltaSpec = nameComponents[4]
# 	affixlen = affixlenSpec.split("-")[-1]
# 	delta = deltaSpec.split("-")[1]
# delta = delta.replace("star", "*")
	
fileobj = open(analysesFile, 'r')
clusters = []
clusterLines = []
lines = fileobj.readlines()
fileName = lines.pop(0)
sys.stderr.write("\n\n")

# the UNIX 'ls' command puts the clusters in ascending order by file name.
# the file names include cluster ID.

for line in lines:
	if line[0] == "#":
		#sys.stderr.write(line)
		clusters.append(clusterLines)
		clusterLines = []
	else:
		if line != "\n":
			clusterLines.append(line)
	
fileobj.close()

wordsAndClassFreqs = dict() # Dict of dicts. The inner keys are classes,
							# and their values are the
							# joint frequencies of words and classes.
wordsAndJustClasses = dict() # We also want a version that omits frequencies, i.e., that is just a dict of lists. Each word will be associated with a simple list of classes.
clustersAndClasses = dict()
clusterFreqs = dict()
cluster_IDs = list()
classFreqs = dict()
clustersAndWords = dict()
wordsAndClusters = dict()
words = list()
allClasses = list()

#sys.stderr.write("\n\nlen(clusters): " + str(len(clusters)) + "\n\n")
for k in range(len(clusters)):
	str_k = "{0:04d}".format(k)
	cluster_IDs.append(str_k)
	bl_analyzer = BL_analyzer(bermanAnalysesFile)
	bl_analyzer.analyze_words(clusters[k], str_k)
	# Create an instance of AnalysisParser called 'my_parser';
	# the input arguments of its constructor in include a cluster (i.e.,
	# a list of words, a k value (i.e., a sort of cluster ID), and an
	# 'inputFile' containing analyses of words.
	#my_parser = AnalysisParser(clusters[k], str_k, inputFile)
	# The inputFile argument is actually a file of root annotations, which
	# we no longer need.
	my_parser = AnalysisParser(clusters[k], str_k)
	wordsAndClassFreqs.update(my_parser.getWordsAndClasses())
	clustersAndClasses.update(my_parser.getClustersAndClasses())
	clusterFreqs[str_k] = my_parser.getClusterCardinality()
	clustersAndWords.update(my_parser.getClustersAndWords())
	#sys.stderr.write("cluster " + str_k + " : " + str(clusterFreqs[str_k]) + "\n")
#print "words:", len(wordsAndClassFreqs)
#print "c and c:", len(clustersAndClasses)
#print "clusterFreqs:", len(clusterFreqs)
#sys.stderr.write("\n")

#sys.stderr.write(str(clusterFreqs) + "\n")

# wordsAndJustClasses is to be the sames as wordsAndClassFreqs, but without the frequencies.
for word in wordsAndClassFreqs:
	wordsAndJustClasses[word] = []
	for clss, freq in wordsAndClassFreqs[word].iteritems():
		if clss in wordsAndJustClasses[word]:
			pass
		else:
			wordsAndJustClasses[word].append(clss)
			
# populate lists allClasses and words as well as the dict classFreqs using wordsAndClassFreqs
for word in wordsAndClassFreqs:
	if word not in words:
		words.append(word)
	for clss, freq in wordsAndClassFreqs[word].iteritems():
		if classFreqs.has_key(clss):
			classFreqs[clss] += 1
		else:
			classFreqs[clss] = 1
			allClasses.append(clss)

N = len(words)
sys.stderr.write("Length of WordsAndClasses = " + str(N) + "\n")

words_sorted = sorted(words)
clusters_sorted = sorted(cluster_IDs)
classes_sorted = sorted(allClasses)

for word in wordsAndClassFreqs:
	#words.append(word)
	wordsAndClusters[word] = []
	for clusterID in clustersAndWords:
		# each clustersAndWords[clusterID] is a list of words,
		# namely the words belonging to the cluster identified by
		# clusterID.
		if word in clustersAndWords[clusterID]:
			wordsAndClusters[word].append(clusterID)

numClasses = len(classFreqs)
numClusters = len(cluster_IDs)
#wordsAndClusters_bin = np.zeros([len(words), len(clusters)], dtype=int)
#wordsAndClassFreqs_bin = np.zeros([len(words), numClasses])
clusters_sparse = [[]]*len(words)
#clusters_sparse = list()
classes_sparse = [[]]*len(words)
#classes_sparse = list()
clusters_lengths = [0]*len(words)
classes_lengths = [0]*len(words)
# sys.stderr.write("\n")
# sys.stderr.write("1 ************************\n")
# sys.stderr.write("\n")
for i in range(len(words_sorted)):
	word = words_sorted[i]
	indices = list()
	for cluster in wordsAndClusters[word]:
		#cluster = wordsAndClusters[word][k]
		#sys.stderr.write(cluster + " ")
		j = clusters_sorted.index(cluster)
		indices.append(j)
		#sys.stderr.write("[" + str(j) + "], ")
		#wordsAndClusters_bin[i,j] = 1
	clusters_sparse[i] = sorted(indices)
	clusters_lengths[i] = len(indices)
	
# sys.stderr.write("len(words_sorted) = " + str(len(words_sorted)) + "\n")
# sys.stderr.write("len(clusters_sparse) = " + str(len(clusters_sparse)) + "\n")
# 	sys.stderr.write("\n")
#for i in range(len(clusters_sparse)):
	#clusters_sparse[i].sort()
	#sys.stderr.write("\tlength of clusters_sparse[" + str(i) + "] = " + str(len(clusters_sparse[i])) + "\n")
# 	sys.stderr.write(str(clusters_sparse[i]) + "\n")
# sys.stderr.write("\n")
# sys.stderr.write("2 ************************\n")
# sys.stderr.write("\n")
for i in range(len(words_sorted)):
	word = words_sorted[i]
	indices = list()
	for clss in wordsAndJustClasses[word]:
		#sys.stderr.write(clss + " ")
		j = classes_sorted.index(clss)
		indices.append(j)
		#bisect.insort(indices, j)
		#sys.stderr.write("[" + str(j) + "], ")
		#wordsAndClassFreqs_bin[i,j] = 1
	classes_sparse[i] = sorted(indices)
	classes_lengths[i] = len(indices)
	
# for i in range(len(classes_sparse)):
# 	classes_sparse[i].sort()
	#sys.stderr.write("\n")
# sys.stderr.write("\n")
# sys.stderr.write("3 ************************\n")
# sys.stderr.write("\n")
#for clss in classFreqs:
#	sys.stderr.write(str(clss) + "  " + str(classFreqs[clss]) + "\n")
#sys.stderr.write(clss)

# sys.stderr.write(str(clusters_sparse) + "\n\n")
# 
# sys.stderr.write(str(classes_sparse) + "\n")
	
avg_prec, avg_recall = 0.0, 0.0
# avg_prec = bcubed_prec(wordsAndClusters, wordsAndJustClasses)
# avg_recall = bcubed_rec(wordsAndClusters, wordsAndJustClasses)
# print ""
# print "clusters"
# for i in range(20):
# 	print "\t", clusters_sparse[i]
# print ""
# print "classes"
# for i in range(20):
# 	print "\t", classes_sparse[i]
# print ""
# print "**************************"
# print ""
if N > 0:
	avg_prec = bcubed_prec(clusters_sparse, clusters_lengths, classes_sparse, classes_lengths, int(numClusters), int(numClasses))
	avg_recall = bcubed_rec(clusters_sparse, clusters_lengths, classes_sparse, classes_lengths, int(numClusters), int(numClasses))
else:
	avg_prec = 0.0
	avg_recall = 0.0
# calculate mutual information
# Info = 0.0
# if N > 0:
# 	invN = 1.0/float(N)
# 	for cluster in clusterFreqs:
# 		for clss in classFreqs:
# 			if clustersAndClasses[cluster].has_key(clss):
# 				try: log_arg = float(N*clustersAndClasses[cluster][clss]) / float(clusterFreqs[cluster]*classFreqs[clss])
# 				except ZeroDivisionError: log_arg = 0.0
# 				coef = clustersAndClasses[cluster][clss] * invN
# 				Info += coef * math.log(log_arg, 2)

Info = mutualInfo(clusterFreqs, classFreqs, clustersAndClasses, N)		
# calculate the entropy of the clusters
H_clusters = entropy(clusterFreqs, N)
# for k in range(len(clusters)):
# 	str_k = "{0:04d}".format(k)
# 	#sys.stderr.write(str(clusterFreqs[str_k]) + "\n")
# 	a = clusterFreqs[str_k]/float(N)
# 	#sys.stderr.write("a = " + str(a) + "\n")
# 	if a > 0.0:
# 		b = math.log(a,2)
# 	else:
# 		b = 0.0
# 	H_clusters = H_clusters - a*b
#sys.stderr.write("\n\nH_clusters = " + str(H_clusters))
# calculate the entropy of the classes
H_classes = entropy(classFreqs, N)
joint_H = jointEntropy(clusterFreqs, classFreqs, clustersAndClasses, N)	
#sys.stderr.write("\n\nH_classes = " + str(H_classes) + "\n\n") 	
# calculate normalized mutual information (NMI)
#NMI = 0.0
#try: NMI = Info / ((H_clusters + H_classes)/2.0)
try: NMI = (H_clusters + H_classes) / joint_H
except ZeroDivisionError: NMI = 0.0
    
# calculate purity for the set of clusters
sumPurity = 0.0
totalClusters = 0
numCorrect = 0.0
maxClasses = dict()
orderedClasses = dict()
clusterPurities = dict()
for cluster in clusterFreqs:
# classes in clustersAndClasses are distributed like word types.
	update = 0
	orderedClasses[cluster] = list()
	freqsAndClasses = list()
	classes = list()
	if len(clustersAndClasses[cluster]) > 0:
		totalClusters += 1
		classesAndFreqs = clustersAndClasses[cluster]
		for clss, freq in classesAndFreqs.items():
			freqsAndClasses.append((freq, clss))
		freqsAndClasses.sort(reverse=True)
		#sys.stderr.write(str(freqsAndClasses) + "\n\n")
		for freq, clss in freqsAndClasses:
			orderedClasses[cluster].append(clss + " (" + str(freq) + ")")
		maxClass = keywithmaxval(clustersAndClasses[cluster])
		#maxClass = orderedClasses[cluster][0]
		maxClasses[cluster] = maxClass
		clusterPurities[cluster] = clustersAndClasses[cluster][maxClass] / float(clusterFreqs[cluster])
		sumPurity += clusterPurities[cluster]
try: Purity = sumPurity/float(totalClusters)
except ZeroDivisionError: Purity = 0.0

# The following four figures are to be placed at the top of the report for 
# the purposes of easy automatic data extraction.
purity_out = "%.3f" % Purity
BP_out = "%.3f" % avg_prec
BR_out = "%.3f" % avg_recall
if  purity_out == "0.000":
	purity_out = "0"
if  BP_out == "0.000":
	BP_out = "0"
if  BR_out == "0.000":
	BR_out = "0"
cov_out = str(N)

# write results to stdout
output = "#" + mainFileName + "." + Ktag + "." + standard + "\n"
#output += "# $K$ & $\eta$ & $s$ & $\delta$ & purity & BP & BR & cov. \\\\\n"
#output += "#" + str(Kval) + " & " + eta + " & " + affixlen + " & " + delta + " & " + purity_out + " & " + BP_out + " & " + BR_out + " & " + cov_out + " & " + str(totalClusters) \\\\"
output += "#" + str(Kval) + " & " + affixlen + " & " + delta + " & " + purity_out + " & " + BP_out + " & " + BR_out + " & " + cov_out + " & " + str(totalClusters) + " \\\\"
output += "\n\nMCMM Clustering Evaluation\n\n\n"
output += "Definitions\n\n"
output += "U\t= the set of clusters induced by the MCMM\n"
output += "V\t= the set of morphological classes that compose MILA's output analyses\n"
output += "H clusters\t= entropy of the MCMM's clusters\n"
output += "H classes\t= entropy of the gold-standard classes\n"
output += "I\t= mutual information\n"
output += "NMI\t= normalized mutual information\n"
output += "Avg Prec\t= B-cubed precision averaged over all words\n"
output += "Avg Recall\t= B-cubed recall averaged over all words\n\n\n"

output += "Cluster Count (K) = " + str(len(clusters)) + "\n"
output += "Active Cluster Count = " + str(totalClusters) + "\n"
output += "Class Count = " + str(numClasses) + "\n\n"

output += "RESULTS\n\n"
output += "Word count = " + str(N) + "\n\n"
output += "Purity(U,V) = " + "%.5f" % Purity + "\n"
output += "H clusters = " + "%.5f" % H_clusters + "\n"
output += "H classes = " + "%.5f" % H_classes + "\n"
output += "I(U,V) = " + "%.5f" % Info + "\n"
output += "NMI(U,V) = " + "%.5f" % NMI + "\n\n"
output += "Avg Prec = " + "%.5f" % avg_prec + "\n"
output += "Avg Recall = " + "%.5f" % avg_recall + "\n\n\n"

# output += "Classes Present: = " + str(numClasses) + "\n"
# output += "\t" + allClasses_str + "\n"

words.sort()

output += "MOST FREQUENT CLASS IN EACH CLUSTER\n\n"
maxClassesItems = maxClasses.items()
maxClassesItems.sort()
for cluster, clss in maxClassesItems:
	try: item0 = orderedClasses[cluster][0]
	except IndexError:
		continue
	try: item1 = orderedClasses[cluster][1]
	except IndexError:
		item1 = "NULL"
	try: item2 = orderedClasses[cluster][2]
	except IndexError:
		item2 = "NULL"
	output += "Cluster " + cluster + ";  size: " + "%4d" % clusterFreqs[cluster] + ";  Purity: " + "%.4f" % clusterPurities[cluster] + ";   " + item0 + ", " + item1 + ", " + item2 + "\n"
output += "\n\n"

# maxClassesItems = maxClasses.items()
# maxClassesItems.sort()
# for cluster, clss in maxClassesItems:
# 	output += cluster + ": " + clss + ";  Size: " + str(clusterFreqs[cluster]) + ";  Purity: " + "%.5f" % clusterPurities[cluster] +  "\n"
# output += "\n\n"
output += "CLUSTER BREAKDOWN\n\n\n"


clusterItems = clustersAndWords.items()
clusterItems.sort()
for pair in clusterItems:
	cluster = pair[0]
	wordList = pair[1]
	try: label = maxClasses[cluster]
	except KeyError:
		label = "N/A"
	try: purity = "%.4f" % clusterPurities[cluster]
	except KeyError:
		purity = "N/A"
	output += "\n***********  Cluster " + cluster + ";  " + "Label: " + label + ";  Purity: " + purity + "  ***********" + "\n"
	#print wordList
	#clusterWords.sort()
	for word in wordList:
		classList = list()
		classStr = ""
		output += "\t" + word + "\n"
		#output += "\t\t" + ", ". join(wordsAndClusters[word]) + "\n"
		#classes = wordsAndJustClasses[word]
		#sys.stderr.write(str(wordsAndClassFreqs[word]) + "\n")
		for clss, freq in wordsAndClassFreqs[word].iteritems():
			classList.append((freq, clss))
		#sys.stderr.write(str(classList) + "\n")
		classList.sort()
		try: pair = classList[0]
		except IndexError:
			classStr = "NULL"
		else:
			classStr = pair[1]
			for k in range(1, len(classList)):
				pair = classList[k]
				#classStr = pair[1] + " (" + str(pair[0]) + "), " + classStr
				classStr = pair[1] + ", " + classStr
		output += "\t\t" + classStr + "\n"
	output += "\n"

output += "\nGOLD-STANDARD CLASSES PRESENT: " + str(numClasses) + "\n\n"	
allClasses.sort()
maxClssNameLen = 0

for clss in allClasses:
	if len(clss) > maxClssNameLen:
		maxClssNameLen = len(clss)
for i in range(len(allClasses)):
	#print allClasses[i] # = allClasses[i]
	allClasses[i] = allClasses[i].ljust(maxClssNameLen)
for clss in allClasses:
	output += "\t" + clss + "\n"

# numCols = 4
# sys.stderr.write("numClasses = " + str(numClasses) + "\n")
# numRows = int(math.ceil(numClasses/float(numCols)))
# sys.stderr.write(str(numClasses) + " yields " + str(numRows) + " rows " + str(numCols) + " columns" + "\n")
# classesTable = [[""]*numCols]*numRows
# for j in range(numCols):
# 	for i in range(numRows):
# 		sys.stderr.write("[" + str(i) + "," + str(j) + "]  =  " + str(j) + " * " + str(numRows) + " + " + str(i) + " = " + str(j*numRows + i) + "\n")
# 		try: classesTable[i][j] = allClasses[j*numRows + i]
# 		except IndexError: classesTable[i][j] = "".ljust(maxClssNameLen)
# 		sys.stderr.write("\t" + str(classesTable[i][j]) + "\n")
# for j in range(numCols):
# 	for i in range(numRows):
# 		output += "   [" + str(i) + "," + str(j) + "] " + classesTable[i][j]
# 	output += "\n"

sys.stdout.write(output)	