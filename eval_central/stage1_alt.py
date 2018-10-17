import regex as re
#import sys, codecs
import sys
#import activeCentroidFeatures as acf
import active_centroid_features as acf
from get_active import *
#from get_active import read_lists
from stage1_pda import *
reload(sys)  
sys.setdefaultencoding('utf8')
UTF8Writer = codecs.getwriter('utf8')
sys.stdout = UTF8Writer(sys.stdout)
sys.stderr = UTF8Writer(sys.stderr)

pat_pos = ur"\@"
re_pos = re.compile(pat_pos, re.UNICODE)
pat_pos_pre = ur"@\[[0-9]\]"
pat_pos_suf = ur"@\[\-[0-9]\]"
re_pos_pre = re.compile(pat_pos_pre, re.UNICODE)
re_pos_suf = re.compile(pat_pos_suf, re.UNICODE)
pat_prec = ur"\<"
re_prec = re.compile(pat_prec, re.UNICODE)
pat_bi = ur"\+"
re_bi = re.compile(pat_bi, re.UNICODE)
pat_seq = ur"[<+]"
re_seq = re.compile(pat_seq, re.UNICODE)

def main(Cval_filename, outputWeights=False):
	outputDict = {}
	#centroids_featuresAndValues = acf.get_active_features_and_values(Cval_filename)
	
	# centroids_featuresAndValues = {0: {"k<t":1.0, "k<a":0.9, "t<b":1, "a<b":0.8},
	# 	1 : {"d@[-4]":1, "i@[0]":1, "i@[-2]":1, "m@[-1]":1},
	# 	#1: {"a<i":1, "i<t":1, "i@[-2]":1}}
	# 	2: {"i<t":1.0, "i@[-2]":1.0, "t<i":1.0},
	# 	3: {"a<n":0.8, "n<u":1, "a@[-3]":1}}
	## 2
	#Most Active
	# centroids_featuresAndValues = {0: {"e<t":1.0000, "z@[0]":1.0000, "x@[0]":1.0000, "\u0294@[3]":0.9477, "\u00E9<e":0.9450, "a<\u00F3":0.1597},
	# 	1: {"e<a":1.0000, "f@[-1]":1.0000, "p@[1]":0.9721},
	# 	2: {"\u00E1<y":1.0000, "\u00E1<i":1.0000, "y<i":1.0000, "\u0294@[2]":1.0000, "\u017E@[2]":1.0000, "z@[1]":1.0000, "y<m":(0.8178), "i<m":(0.8034), "w@[2]":0.6886, "n<y":0.1512},
	# 	3: {"b@[-3]":0.0000, "b@[-4]":0.0000, "b@[0]":0.0000, "b@[1]":0.0000, "b@[2]":0.0000, "b@[3]":0.0000, "c@[-2]":0.0000, "c@[-3]":0.0000, "c@[-4]":0.0000, "c@[0]":0.0000},
	# 	4: {"\u00F3<t":1.0000, "x@[0]":1.0000, "\u00E1@[-4]":0.9891, "u<\u00F3":0.0895, "r<t":0.0832, "i<\u00F3":0.0828, "o<\u00F3":0.0749, "r<\u00F3":0.0739, "n<\u00F3":0.0660, "e<\u00F3":0.0493}}
	centroids_featuresAndValues = {0: {"e<t":1.0000, "\u00E9<e":0.9450}}
		# 1: {"e<a":1.0000, "f@[-1]":1.0000, "p@[1]":0.9721},
		# 2: {"\u00E1<y":1.0000, "\u00E1<i":1.0000, "y<i":1.0000, "\u0294@[2]":1.0000, "\u017E@[2]":1.0000, "z@[1]":1.0000, "y<m":(0.8178), "i<m":(0.8034), "w@[2]":0.6886, "n<y":0.1512},
		# 3: {"b@[-3]":0.0000, "b@[-4]":0.0000, "b@[0]":0.0000, "b@[1]":0.0000, "b@[2]":0.0000, "b@[3]":0.0000, "c@[-2]":0.0000, "c@[-3]":0.0000, "c@[-4]":0.0000, "c@[0]":0.0000},
		# 4: {"\u00F3<t":1.0000, "x@[0]":1.0000, "\u00E1@[-4]":0.9891, "u<\u00F3":0.0895, "r<t":0.0832, "i<\u00F3":0.0828, "o<\u00F3":0.0749, "r<\u00F3":0.0739, "n<\u00F3":0.0660, "e<\u00F3":0.0493}}
	print centroids_featuresAndValues
	# centroids_featuresAndValues = {
	# 	#0: {"i<t":1.0, "i@[-2]":1.0, "t<i":1.0}}
	# 	#0: {"k<e":1.0, "e@[1]":1.0, "e<k":1.0}}
	# 	0: {"k<e":1.0, "e<k":0.9, "k<t":0.9}}
	for cluster_ID,cluster_dict in centroids_featuresAndValues.items():
		fw_objects = []
		candidate_morphs = []
		###print "fw_pairs:",
		for feature,weight in sorted(cluster_dict.items(), key=lambda x: x[1], reverse=True):
	#for feature,weight in sorted(centroids_featuresAndValues.items()):
			###print feature,weight, ";",
			if re_pos_pre.search(feature):
				fwp = FWP_pos_front(feature,weight)
				fw_objects .append(fwp)
			elif re_pos_suf.search(feature):
				fwp = FWP_pos_back(feature,weight)
				fw_objects.append(fwp)
			elif re_prec.search(feature):
				fwp = FWP_prec(feature,weight)
				fw_objects.append(fwp)
		###print ""
		fw_front_srtd,fw_back_srtd,fw_prec_srtd = partition_feat_objs(fw_objects)
		
		# print "^^^^^^^^^^^^^^^^^^^ fw_front_srtd:",
		# for f in fw_front_srtd:
		# 	print f.get_feature(),
		# print ""
		
		# print "^^^^^^^^^^^^^^^^^^^ fw_back_srtd:",
		# for f in fw_back_srtd:
		# 	print f.get_feature(),
		# print ""
		
		# print "^^^^^^^^^^^^^^^^^^^ fw_prec_srtd:", 
		# for f in fw_prec_srtd:
		# 	print f.get_feature(),
		# print ""
		
		fw_objs_srtd = fw_front_srtd
		fw_objs_srtd.extend(fw_back_srtd)
		fw_objs_srtd.extend(fw_prec_srtd)
		# ##print "fw_objs_srtd:",
		# for obj in fw_objs_srtd:
		# 	##print obj.get_feature(), obj.get_weight(), ";",
		# ##print ""
		# Each vector of fw_objects is a centroid vector. That is, it corresponds to exactly one cluster.
		# There, each such vector corresponds to exactly one morph. Initially, however, we do not know
		# the morph's type. That is, we don't know wheter it is a prefix morph, a stem morph, or a suffix morph.
		# We therefore develop all three types, and select the one with the higest average weight.

		# Initialize all three morph objects on the first feature-weight object:
		###print "FWPs categorized:",
		morph_prefix = None
		morph_suffix = None
		morph_stem = None
		# print "*****%%%%%^^^^^ fwp_objs_srtd:",
		# for fwp in fw_objs_srtd:
		# 	print fwp.get_feature(),
		# print ""
		# # print "^^^^^^^^^^^^^^^^^^^ f_objs:",
		# # for f in fw_objs_srtd:
		# # 	print f.get_feature(),
		# # print ""
		# fwp = fw_objs_srtd.pop(0)
		# print "^^^^^^^^^^^^^^^^^^^ f_objs after pop:",
		# for f in fw_objs_srtd:
		# 	print f.get_feature(),
		# print ""

		# We need to inialize our morph_objects with the first fwp.
		# which is popped from the fw_obj_srtd list.
		# Unfortunately, feature objects have types, and not every type
		# can be incorporated into every type of morph object. For example,
		# MWP_prefix(fwp) with generate an error if fwp is a back (or suffix)
		# positional feature object.
		# feature object.
		#
		# The required initial feature type for the morph types are as follows:
		# MWP_prefix: pos_front 
		# MWP_stem: prec
		# MWP_stem: pos_back
		
		feature_type = fwp.get_feature_type()
		# if feature_type == "pos_front":
		# 	morph_prefix = MWP_prefix(fwp)
		# 	#stack.append(morph_prefix)
		# elif feature_type == "pos_back":
		# 	morph_suffix = MWP_prefix(fwp)
		# 	#stack.append(morph_suffix)
		# elif feature_type == "prec":
		# 	#morph_prefix = MWP_prefix(fwp)
		# 	#morph_suffix = MWP_suffix(fwp)
		# 	morph_stem = MWP_stem(fwp)
			#stack.append(morph_prefix)
			#stack.append(morph_suffix)
			#stack.append(morph_stem)
		# try: morph_prefix = MWP_prefix(fwp)
		# except AssertionError: pass
		# try: morph_suffix = MWP_suffix(fwp)
		# except AssertionError: pass
		# try: morph_stem = MWP_stem(fwp)
		# except AssertionError: pass
		print "%%%% MORPH_STEM:", morph_stem
		for fwp in fw_objs_srtd:
			print "*************************************************************"
			print "FWP FEATURE OBJ:", fwp.get_feature()
			print "*************************************************************"
			if morph_prefix == None:
				# if fwp.get_feature_type() == 'pos_front':
				# 	morph_prefix = MWP_prefix(fwp)
				try: morph_prefix = MWP_prefix(fwp)
				except AssertionError: pass
				else: continue
			if morph_suffix == None:
				# if fwp.get_feature_type() == 'pos_back':
				# 	morph_suffix = MWP_suffix(fwp)
				try: morph_suffix = MWP_suffix(fwp)
				except AssertionError: pass
				else: continue
			if morph_stem == None:
				# if fwp.get_feature_type() == 'pos_prec':
				# 	morph_stem = MWP_stem(fwp)
				try:
					print "++++++++ try: init morph_stem ++++++++++"
					print morph_stem
					morph_stem = MWP_stem(fwp)
					#print print "chain new:", morph_stem.get_chain_features()
				except AssertionError: pass
				else:
					print "new_morph:", morph_stem.get_morph()
					print "chain new:", morph_stem.get_chain_features()
					continue
			
			if morph_prefix != None:
				print "+++++++++ try: morph_prefix ++++++++++"
				print "feature:", fwp.get_feature(), "; morph:", morph_prefix.get_morph(), ";",
				try:
					morph_prefix.update(fwp)
					fwp_list = morph_prefix.get_fwp_list()
					for h in fwp_list:
						print h.get_feature(),
					#print "chain:", morph_stem.get
					print "; final pre:", morph_prefix.get_morph()
				except AssertionError: pass
				
			if morph_suffix != None:
				print "++++++++ try: morph_suffix ++++++++++"
				print "feature:", fwp.get_feature(), "; morph:", morph_suffix.get_morph()
				try:
					print "f list old:",
					fwp_list = morph_suffix.get_fwp_list()
					for f in fwp_list:
						print fwp.get_feature(),
					morph_suffix.update(fwp)
					fwp_list = morph_suffix.get_fwp_list()
					print ""
					print "f list new:",
					for g in fwp_list:
						print g.get_feature(),
					print ""
					#print "suf:", morph_suffix.get_morph()
					#morph_suffix.update(fwp)
					print "final suf:", morph_suffix.get_morph()
				except AssertionError: pass
				
			if morph_stem != None:
				print "++++++++ try: morph_stem ++++++++++"
				print "feature:", fwp.get_feature(), "; morph:", morph_stem.get_morph() #, "; chain:",
				try:
					chain = morph_stem.get_chain()
					print "chain old:", morph_stem.get_chain_features()
					# for j in chain:
					# 	print j.get_feature(),
					# print ""
					morph_stem.update(fwp)
					
					# print "chain new:",
					# for j in chain:
					# 	print j.get_feature(),
					# print ""
					#print "chain:", morph_stem.get_chain()
					print "chain new:", morph_stem.get_chain_features()
					print "final stem:", morph_stem.get_morph()
				except AssertionError:
					print "AssertionError"
					pass
				


		# ##print fwp.get_feature()
		# if fwp.get_feature_type() != "pos_back":
		# 	try: morph_prefix = MWP_prefix(fwp)
		# 	except AttributeError: pass
		# 	else:
		# 		try: morph_prefix.update(fwp)
		# 		except AttributeError: pass
		# try: morph_stem = MWP_stem(fwp)
		# except AttributeError: pass
		# else:
		# 	try: morph_stem.update(fwp)
		# 	except AttributeError: pass
		# if fwp.get_feature_type() != "pos_front":
		# 	try: morph_suffix = MWP_suffix(fwp)
		# 	except AttributeError: pass
		# 	else:
		# 		try: morph_suffix.update(fwp)
		# 		except AttributeError: pass

		# candidate_morphs = []
		# for fwp in fw_objs_srtd:
		# 	##print fwp.get_feature(),
		# 	try: morph_prefix.update(fwp)
		# 	except AttributeError: pass
		# 	try: morph_stem.update(fwp)
		# 	except AttributeError: pass
		# 	try: morph_suffix.update(fwp)
		# 	except AttributeError: pass
		# candidate_morphs.append((morph_prefix.get_weight(), "aa&" + morph_prefix.get_morph()))
		# candidate_morphs.append((morph_stem.get_weight(), morph_stem.get_morph()))
		# candidate_morphs.append((morph_suffix.get_weight(), "zz&" + morph_suffix.get_morph()))
		if morph_prefix != None:
			candidate_morphs.append((morph_prefix.get_weight(), "aa&" + morph_prefix.get_morph()))
			##print "morph_prefix:", morph_prefix.get_morph()
		if morph_suffix != None:
			candidate_morphs.append((morph_suffix.get_weight(), "zz&" + morph_suffix.get_morph()))
			##print "morph_suffix:", morph_suffix.get_morph()
		if morph_stem != None:
			candidate_morphs.append((morph_stem.get_weight(), morph_stem.get_morph()))
			##print "morph_stem:", morph_stem.get_morph()
		candidate_morphs.sort(reverse=True)		
		
		#Assign highest-weighted morph to cluster
		##print "cluster_ID:", cluster_ID
		if outputWeights:
			outputDict[cluster_ID] = candidate_morphs.pop(0)
		else:
			outputDict[cluster_ID] = candidate_morphs.pop(0)[1]
	return outputDict

if __name__ == "__main__":
	filename = sys.argv[1]
	morph_dict = main(filename, outputWeights=True)
	##print "MORPH_DICT:"
	for cluster_ID in morph_dict.keys():
		print cluster_ID, morph_dict[cluster_ID]