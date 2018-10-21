#!/usr/bin/env python
# -*- coding: utf-8 -*-

import math,pprint,random
#import regex as re
import re
import sys, codecs

reload(sys)  
sys.setdefaultencoding('utf8')
UTF8Writer = codecs.getwriter('utf8')
sys.stdout = UTF8Writer(sys.stdout)
sys.stderr = UTF8Writer(sys.stderr)

def get_active_features(filename):
	fobj = codecs.open(filename, "r", encoding='utf8')
	lines = fobj.readlines()
	feature_labels = list()
	temp = lines[0].rstrip("\n")
	items_temp = temp.split()
	K = len(items_temp) - 1
	#features_and_values = [[] for k in range(K)]
	active_feature_lists = [[] for k in range(K)]
	# Now, initiate list of list of lists for centroids.
	# We also need to compile an *ordered* list of feature labels.
	# We will compile this list and the centroid vectors in parallel.
	for line in lines:
		#print line
		line = line.rstrip("\n")
		items = line.split()
		#print items
		feature_label = items.pop(0)
		#print feature_label, len(items), K
		for k in range(K):
			#print items[k],
			if float(items[k]) > 0.7:
				active_feature_lists[k].append(feature_label)
				#features_and_values[k].append((feature_label + "//" + items[k]))
		feature_labels.append(feature_label)
		#print ""
	fobj.close()
	#return (feature_labels, active_feature_lists)
	return active_feature_lists
	#return features_and_values

def get_active_features_and_values(filename):
	threshold = 0.9
	fobj = codecs.open(filename, "r",encoding='utf8')
	lines = fobj.readlines()
	feature_labels = list()
	temp = lines[0].rstrip("\n")
	# Each column (except the first one) is a cluster activity. The first column specifies a word.
	items_temp = temp.split()
	K = len(items_temp) - 1
	#features_and_values = [[] for k in range(K)]
	#active_feature_lists = [[] for k in range(K)]
	active_features = {}
	features_and_values = {}
	# Now, initiate list of list of lists for centroids.
	# We also need to compile an *ordered* list of feature labels.
	# We will compile this list and the centroid vectors in parallel.
	for line in lines:
		#sys.stderr.write("*** from acf: " + line)
		line = line.rstrip("\n")
		items = line.split()
		#print items
		feature_label = items.pop(0)
		#print feature_label, len(items), K
		for k in range(K):
			#print items[k],
			active_features[k] = {}
			if float(items[k]) > threshold:
				#active_feature_lists[k].append(feature_label)
				#active_features[k] = {}
				active_features[k][feature_label] = 1.0
				# if active_features.has_key(k):
				# 	active_features[k][feature_label] = items[k]
				# else:
				# 	active_features[k] = {}
				# 	active_features[k][feature_label] = items[k]
				#features_and_values[k].append(feature_label + "//" + items[k])
				if features_and_values.has_key(k):
					features_and_values[k][feature_label] = float(items[k])
				else:
					features_and_values[k] = {}
					features_and_values[k][feature_label] = float(items[k])
				
		feature_labels.append(feature_label)
		#print ""
	fobj.close()
	#return (feature_labels, active_feature_lists)
	#return active_feature_lists
	return features_and_values