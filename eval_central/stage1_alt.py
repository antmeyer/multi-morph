#import sys, codecs
import sys, codecs, re
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

#def main(cvals_filename, max_pos, prec_span, outputWeights=False):
def main(cvals_filename, outputWeights=False):
	name_components = cvals_filename.split("_")
	# max_pos = int(name_components[0])
	# prec_span = int(name_components[1])
	max_pos = 2
	prec_span = 2
	##print "MAX_POS:", max_pos, "; PREC_SPAN:", prec_span
	outputDict = {}
	threshold = 0.9
	centroids_featuresAndValues = acf.get_active_features_and_values(cvals_filename, threshold)
	for cluster_ID,cluster_dict in centroids_featuresAndValues.items():
		#sys.stdout.write(str(cluster_ID) + "\t")
		out_str = ""
		for key,val in cluster_dict.items():
			out_str += str(key) + ":" + str(val) + "; "
			#sys.stdout.write(str(key) + ":" + str(val) + "; ")
		#sys.stdout.write(out_str[:-2] + "\n")
	#sys.stdout.write("\n")
	#centroids_featuresAndValues = {0: {u"\u0294<\u0294":1.0, u"\u0294<a":0.95, u"a<\u0294":0.95}}
	# centroids_featuresAndValues = {0: {"k<t":1.0, "k<a":0.9, "t<b":1, "a<b":0.8},
	# 	1 : {"d@[-4]":1, "i@[0]":1, "i@[-2]":1, "m@[-1]":1},
	# 	#1: {"a<i":1, "i<t":1, "i@[-2]":1}}
	# 	2: {"i<t":1.0, "i@[-2]":1.0, "t<i":1.0},
	# 	3: {"a<n":0.8, "n<u":1, "a@[-3]":1}}
	## 2
	#Most Active
	#centroids_featuresAndValues = {0: {"e<t":1.0000, "z@[0]":1.0000, "x@[0]":1.0000, "\u0294@[3]":0.9477, "\u00E9<e":0.9450}} # "a<\u00F3":0.1597}}
	# 	1: {"e<a":1.0000, "f@[-1]":1.0000, "p@[1]":0.9721},
	# 	2: {"\u00E1<y":1.0000, "\u00E1<i":1.0000, "y<i":1.0000, "\u0294@[2]":1.0000, "\u017E@[2]":1.0000, "z@[1]":1.0000, "y<m":(0.8178), "i<m":(0.8034), "w@[2]":0.6886, "n<y":0.1512},
	# 	3: {"b@[-3]":0.0000, "b@[-4]":0.0000, "b@[0]":0.0000, "b@[1]":0.0000, "b@[2]":0.0000, "b@[3]":0.0000, "c@[-2]":0.0000, "c@[-3]":0.0000, "c@[-4]":0.0000, "c@[0]":0.0000},
	# 	4: {"\u00F3<t":1.0000, "x@[0]":1.0000, "\u00E1@[-4]":0.9891, "u<\u00F3":0.0895, "r<t":0.0832, "i<\u00F3":0.0828, "o<\u00F3":0.0749, "r<\u00F3":0.0739, "n<\u00F3":0.0660, "e<\u00F3":0.0493}}
	# centroids_featuresAndValues = {0: {u"e<t":1.0000, u"\u00E9<e":0.9450},
	# 	#1: {"e<a":1.0000, "f@[-1]":1.0000, "p@[1]":0.9721}}
	# 	# 2: {"\u00E1<y":1.0000, "\u00E1<i":1.0000, "y<i":1.0000, "\u0294@[2]":1.0000, "\u017E@[2]":1.0000, "z@[1]":1.0000, "y<m":(0.8178), "i<m":(0.8034), "w@[2]":0.6886, "n<y":0.1512},
	# 	1: {"b@[-3]":0.0000, "b@[-4]":0.0000, "b@[0]":1.0000, "b@[1]":1.0000, "b@[2]":1.0000, "b@[3]":1.0000, "c@[-2]":1.0000, "c@[-3]":1.0000, "c@[-4]":1.0000, "c@[0]":1.0000}}
		# 2: {"\u00F3<t":1.0000, "x@[0]":1.0000, "\u00E1@[-4]":0.9891, "u<\u00F3":0.0895, 
		# 	"r<t":0.0832, "i<\u00F3":0.0828, "o<\u00F3":0.0749, "r<\u00F3":0.0739, 
		# 	"n<\u00F3":0.0660}} #, "e<\u00F3":0.0493}}
		#2: {"\u00F3<t":1.0000, "x@[0]":1.0000, "\u00E1@[-4]":0.9891}}
	###print centroids_featuresAndValues
	# centroids_featuresAndValues = {
	# 	#0: {"i<t":1.0, "i@[-2]":1.0, "t<i":1.0}}
	# 	#0: {"k<e":1.0, "e@[1]":1.0, "e<k":1.0}}
	# 	0: {"k<e":1.0, "e<k":0.9, "k<t":0.9}}
	for cluster_ID,cluster_dict in centroids_featuresAndValues.items():
		##print cluster_ID
		fw_objects = []
		candidate_morphs = []
		#####print "fw_pairs:",
		for feature,weight in sorted(cluster_dict.items(), key=lambda x: x[1], reverse=True):
	#for feature,weight in sorted(centroids_featuresAndValues.items()):
			#####print feature,weight, ";",
			try: 
				fwp = FWP_pos_front(feature,weight)
				#fw_objects.append(fwp)
			except AssertionError: pass
			else: fw_objects.append(fwp)
			try: 
				fwp = FWP_pos_back(feature,weight)
				#fw_objects.append(fwp)
			except AssertionError: pass
			else: fw_objects.append(fwp)
			try: 
				fwp = FWP_prec(feature,weight)
				#fw_objects.append(fwp)
			except AssertionError: pass
			else: fw_objects.append(fwp)
			# if re_pos_pre.search(feature):
			# 	fwp = FWP_pos_front(feature,weight)
			# 	fw_objects .append(fwp)
			# elif re_pos_suf.search(feature):
			# 	fwp = FWP_pos_back(feature,weight)
			# 	fw_objects.append(fwp)
			# elif re_prec.search(feature):
			# 	fwp = FWP_prec(feature,weight)
			# 	fw_objects.append(fwp)
		#####print ""
		fw_front_srtd,fw_back_srtd,fw_prec_srtd = partition_feat_objs(fw_objects)
		
		# ##print "^^^^^^^^^^^^^^^^^^^ fw_front_srtd:",
		# for f in fw_front_srtd:
		# 	##print f.get_feature(),
		# ##print ""
		
		# ##print "^^^^^^^^^^^^^^^^^^^ fw_back_srtd:",
		# for f in fw_back_srtd:
		# 	##print f.get_feature(),
		# ##print ""
		
		# ##print "^^^^^^^^^^^^^^^^^^^ fw_prec_srtd:", 
		# for f in fw_prec_srtd:
		# 	##print f.get_feature(),
		# ##print ""
		
		fw_objs_srtd = fw_front_srtd
		fw_objs_srtd.extend(fw_back_srtd)
		fw_objs_srtd.extend(fw_prec_srtd)
		# We put the pos_back features before the prec_features because it would be redundant to attach
		# a pos_back feature to a chain of prec features, e.g., a<e, e<t, t@[-1]. The t in the pos_back
		# feature would have to match the t in the feater e<t in order to justify the merger (or attachement),
		# but if the t's match, no new info is contributed by the merger. On the other hand, a prec feature can
		# contribute info when attached to a pos_back feature.

		# Similaray, a prec feature can help build a prefix (or front field) morph by attaching to the left
		# of a pos_front feature, but nothing is achieved by attaching it to the right of a pos_front feature 
		# (or, equivalently, by attaching the pos_front feature to the lefthand side of a prec-feature chain).

		# We therefore put the pos_features at the very end, behind the prec features.



		# ####print "fw_objs_srtd:",
		# for obj in fw_objs_srtd:
		# 	####print obj.get_feature(), obj.get_weight(), ";",
		# ####print ""
		# Each vector of fw_objects is a centroid vector. That is, it corresponds to exactly one cluster.
		# There, each such vector corresponds to exactl# 331y one morph. Initially, however, we do not know
		# the morph's type. That is, we don't know wheter it is a prefix morph, a stem morph, or a suffix morph.
		# We therefore develop all three types, and select the one with the higest average weight.

		# Initialize all three morph objects on the first feature-weight object:
		#####print "FWPs categorized:",
		morph_prefix = None
		morph_prefix2 = None
		morph_suffix = None
		morph_suffix2 = None
		morph_stem = None

		# ##print "*****%%%%%^^^^^ fwp_objs_srtd:",
		# for fwp in fw_objs_srtd:
		# 	##print fwp.get_feature(),
		# ##print ""
		# # ##print "^^^^^^^^^^^^^^^^^^^ f_objs:",
		# # for f in fw_objs_srtd:
		# # 	##print f.get_feature(),
		# # ##print ""
		# fwp = fw_objs_srtd.pop(0)
		# ##print "^^^^^^^^^^^^^^^^^^^ f_objs after pop:",
		# for f in fw_objs_srtd:
		# 	##print f.get_feature(),
		# ##print ""

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
		##print "%%%% MORPH_STEM:", morph_stem
		
		fw_objs_srtd_copy = list(fw_objs_srtd)
		i = 0
		while len(fw_objs_srtd_copy) > 0 and i < len(fw_objs_srtd_copy):
			##print i
			fwp = fw_objs_srtd_copy[i]
		#for fwp in fw_objs_srtd_copy:
			##print "*************************************************************"
			##print "FWP FEATURE OBJ:", fwp.get_feature()
			##print "*************************************************************"
			if morph_suffix == None:
			#if len(front_morphs) == 0:
				# if fwp.get_feature_type() == 'pos_front':
				# 	morph_suffix = MWP_prefix(fwp)
				##print "+++++++++ try: morph_suffix ++++++++++"
				try:
					morph_suffix = MWP_suffix(fwp, max_pos)
				#except AssertionError: pass
				except AssertionError:
					##print "$$$ SUFFIX Assertion Error"
					pass
				else:
					fw_objs_srtd_copy.pop(i)
					##print "updated letters:", " ".join(morph_suffix.get_letters())
					continue	#continue in any case
			else:
				letters = []
				##print "+++++++++ try: morph_suffix ++++++++++"
				##print "new feature:", fwp.get_feature() #, "; existing front morph:", morph_suffix.get_morph(), ";"
				letters = morph_suffix.get_letters()
				try: morph_suffix.update(fwp)
				except AssertionError:
					##print "ASSERTION ERROR"
					pass
				else:
					##print "existing letters:", " ".join(letters)
					##print "updated letters:", " ".join(morph_suffix.get_letters())
					fw_objs_srtd_copy.pop(i)
					continue
			i += 1

		i = 0
		while len(fw_objs_srtd_copy) > 0 and i < len(fw_objs_srtd_copy):
			fwp = fw_objs_srtd_copy[i]
			##print "*************************************************************"
			##print "FWP FEATURE OBJ:", fwp.get_feature()
			##print "*************************************************************"
			if morph_suffix2 == None:
			#if len(front_morphs) == 0:
				# if fwp.get_feature_type() == 'pos_front':
				# 	morph_prefix = MWP_prefix(fwp)
				##print "+++++++++ try: morph_suffix2 ++++++++++"
				try: morph_suffix2 = MWP_suffix2(fwp, prec_span)
				#except AssertionError: pass
				except AssertionError: pass
				else:
					fw_objs_srtd_copy.pop(i) 
					continue	#continue in any case
			else:
				letters = []
				##print "+++++++++ try: morph_suffix2 ++++++++++"
				##print "new feature:", fwp.get_feature() #"; existing letters:", morph_suffix2.get_morph(), ";"
				
				try: 
					morph_suffix2.update(fwp)
					letters = morph_suffix2.get_letters()
				except AssertionError:
					##print "ASSERTION ERROR"
					pass
				else:
					#fw_objs_srtd_copy.pop(i)
					##print "existing letters:", " ".join(letters)
					##print "updated letters:", " ".join(morph_suffix2.get_letters())
					fw_objs_srtd_copy.pop(i)
					continue
			i += 1

		i = 0
		fw_objs_srtd_copy = list(fw_objs_srtd)

		while len(fw_objs_srtd_copy) > 0 and i < len(fw_objs_srtd_copy):
			##print "FW OBJS:",
			# for fwp_temp in fw_objs_srtd_copy:
			# 	#print fwp_temp.get_feature(),
			# #print ""
			fwp = fw_objs_srtd_copy[i]
			##print "*************************************************************"
			##print "FWP FEATURE OBJ:", fwp.get_feature()
			##print "*************************************************************"
			if morph_stem == None:
			#if len(front_morphs) == 0:
				# if fwp.get_feature_type() == 'pos_front':
				# 	morph_prefix = MWP_prefix(fwp)
				##print "+++++++++ try: morph_stem ++++++++++"
				try: morph_stem = MWP_stem(fwp, prec_span)
				#except AssertionError: pass
				except AssertionError: pass
				else:
					fw_objs_srtd_copy.pop(i) 
					continue	#continue in any case
			else:
				letters = []
				##print "+++++++++ try: morph_stem ++++++++++"
				##print "new feature:", fwp.get_feature() #"; existing letters:", morph_suffix2.get_morph(), ";"
				

				try:
					letters = morph_stem.get_letters()
					morph_stem.update(fwp)
				except AssertionError:
					##print "ASSERTION ERROR"
					pass
				else:
					##print "existing letters:", " ".join(letters)
					##print "updated letters:", " ".join(morph_stem.get_letters())
					fw_objs_srtd_copy.pop(i)
					continue
			i += 1

		i = 0
		fw_objs_srtd_copy = list(fw_objs_srtd)
		while len(fw_objs_srtd_copy) > 0 and i < len(fw_objs_srtd_copy):
			fwp = fw_objs_srtd_copy[i]
		#for fwp in fw_objs_srtd_copy:
			if morph_prefix == None:
				##print "+++++++++ try: morph_prefix ++++++++++"
				try: morph_prefix = MWP_prefix(fwp, max_pos)
					#except AssertionError: pass
				except AssertionError: pass
				else:
					fw_objs_srtd_copy.pop(i)
					##print "updated letters:", " ".join(morph_prefix.get_letters())
					continue
			else:
				letters = []
				##print "+++++++++ try: morph_prefix ++++++++++"
				##print "new feature:", fwp.get_feature(), "; existing front morph:", morph_prefix.get_morph(), ";"
				#letters = []
				try: 
					letters = morph_prefix.get_letters()
					morph_prefix.update(fwp)
				except AssertionError:
					##print "ASSERTION ERROR"
					pass
				else:
					##print "existing letters:", " ".join(letters)
					##print "updated letters:", " ".join(morph_prefix.get_letters())
					fw_objs_srtd_copy.pop(i)
					continue
			i += 1

		i = 0
		while len(fw_objs_srtd_copy) > 0 and i < len(fw_objs_srtd_copy):
			fwp = fw_objs_srtd_copy[i]
			##print "*************************************************************"
			##print "FWP FEATURE OBJ:", fwp.get_feature()
			##print "*************************************************************"
			if morph_prefix2 == None:
				##print "+++++++++ try: morph_prefix2 ++++++++++"
			#if len(front_morphs) == 0:
				# if fwp.get_feature_type() == 'pos_front':
				# 	morph_prefix = MWP_prefix(fwp)
				try: morph_prefix2 = MWP_prefix2(fwp, prec_span)
				#except AssertionError: pass
				except AssertionError: pass
				else:
					fw_objs_srtd_copy.pop(i)
					continue	#continue in any case
			else:
				letters = []
				##print "+++++++++ try: morph_prefix2 ++++++++++"
				##print "new feature:", fwp.get_feature() #"; existing letters:", morph_suffix2.get_morph(), ";"
				#try: letters = morph_prefix2.get_letters()
				#except AssertionError: pass

				try:
					morph_prefix2.update(fwp)
					letters = morph_prefix2.get_letters()
				except AssertionError:
					##print "ASSERTION ERROR *"
					pass
				else:
					##print "existing letters:", " ".join(letters)
					##print "updated letters:", " ".join(morph_prefix2.get_letters())
					fw_objs_srtd_copy.pop(i)
					continue
			i += 1
			# if morph_suffix == None:
			# 	# if fwp.get_feature_type() == 'pos_back':
			# 	# 	morph_suffix = MWP_suffix(fwp)
			# 	try: morph_suffix = MWP_suffix(fwp)
			# 	except AssertionError: pass
			# 	else: continue
			# if morph_stem == None:
			# 	# if fwp.get_feature_type() == 'pos_prec':
			# 	# 	morph_stem = MWP_stem(fwp)
			# 	try:
			# 		##print "++++++++ try: init morph_stem ++++++++++"
			# 		##print morph_stem
			# 		morph_stem = MWP_stem(fwp)
			# 		###print ##print "chain new:", morph_stem.get_chain_features()
			# 	except AssertionError: pass
			# 	else:
			# 		##print "new_morph:", morph_stem.get_morph()
			# 		##print "chain new:", morph_stem.get_chain_features()
			# 		continue
			
			# if morph_prefix != None:
			# 	##print "+++++++++ try: morph_prefix ++++++++++"
			# 	##print "feature:", fwp.get_feature(), "; morph:", morph_prefix.get_morph(), ";",
			# 	try:
			# 		morph_prefix.update(fwp)
			# 		fwp_list = morph_prefix.get_fwp_list()
			# 		for h in fwp_list:
			# 			##print h.get_feature(),
			# 		###print "chain:", morph_stem.get
			# 		##print "; final pre:", morph_prefix.get_morph()
			# 	except AssertionError: pass
				
			# if morph_suffix != None:
			# 	##print "++++++++ try: morph_suffix ++++++++++"
			# 	##print "feature:", fwp.get_feature(), "; morph:", morph_suffix.get_morph()
			# 	try:
			# 		##print "f list old:",
			# 		fwp_list = morph_suffix.get_fwp_list()
			# 		for f in fwp_list:
			# 			##print fwp.get_feature(),
			# 		morph_suffix.update(fwp)
			# 		fwp_list = morph_suffix.get_fwp_list()
			# 		##print ""
			# 		##print "f list new:",
			# 		for g in fwp_list:
			# 			##print g.get_feature(),
			# 		##print ""
			# 		###print "suf:", morph_suffix.get_morph()
			# 		#morph_suffix.update(fwp)
			# 		##print "final suf:", morph_suffix.get_morph()
			# 	except AssertionError: pass
				
			# if morph_stem != None:
			# 	##print "++++++++ try: morph_stem ++++++++++"
			# 	##print "feature:", fwp.get_feature(), "; morph:", morph_stem.get_morph() #, "; chain:",
			# 	try:
			# 		chain = morph_stem.get_chain()
			# 		##print "chain old:", morph_stem.get_chain_features()
			# 		# for j in chain:
			# 		# 	##print j.get_feature(),
			# 		# ##print ""
			# 		morph_stem.update(fwp)
					
			# 		# ##print "chain new:",
			# 		# for j in chain:
			# 		# 	##print j.get_feature(),
			# 		# ##print ""
			# 		###print "chain:", morph_stem.get_chain()
			# 		##print "chain new:", morph_stem.get_chain_features()
			# 		##print "final stem:", morph_stem.get_morph()
			# 	except AssertionError:
			# 		##print "AssertionError"
			# 		pass
				


		# ####print fwp.get_feature()
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
		# 	####print fwp.get_feature(),
		# 	try: morph_prefix.update(fwp)
		# 	except AttributeError: pass
		# 	try: morph_stem.update(fwp)
		# 	except AttributeError: pass
		# 	try: morph_suffix.update(fwp)
		# 	except AttributeError: pass
		# candidate_morphs.append((morph_prefix.get_weight(), "aa&" + morph_prefix.get_morph()))
		# candidate_morphs.append((morph_stem.get_weight(), morph_stem.get_morph()))
		# candidate_morphs.append((morph_suffix.get_weight(), "zz&" + morph_suffix.get_morph()))
		prefix_ptn = ""
		suffix_ptn = ""
		patterns = []
		overall_ptn = ""
		overall_weight = 0.0
		all_letters = []
		weighted_morph_objects = []
		# front_morphs = []
		# middle_morphs = []
		# back_morphs = []
		max_back_index = 1
		min_front_index = -2
		if morph_prefix != None:
			#candidate_morphs.append((morph_prefix.get_weight(),  morph_prefix))
			#max_pos = morph_prefix.get_max_pos()
			##print "morph_prefix:", morph_prefix.get_letters()
			##print "Index range:", morph_prefix.get_min_index(), morph_prefix.get_max_index()
			weighted_morph_objects.append((morph_prefix.get_weight(), morph_prefix))
			all_letters.extend(morph_prefix.get_letters())
			morph_prefix.compute_pattern()
			prefix_ptn += morph_prefix.get_pattern() + ".*"
			patterns.append(morph_prefix.get_pattern())
			min_front_index = morph_prefix.get_min_index()
		if morph_prefix2 != None:
			##print morph_prefix2.get_letters()
			#candidate_morphs.append((morph_prefix2.get_weight(), morph_prefix2))
			#weighted_morph_objects.append((morph_prefix2.get_weight(), morph_prefix2))
			letters = []
			try: 
				letters = morph_prefix2.get_letters()
				all_letters.extend(morph_prefix2.get_letters())
				#print morph_prefix2.get_letters()
			except AssertionError: pass
			else:
				morph_prefix2.compute_pattern()
				prefix_ptn = patterns.pop()
				patterns.append(ur"(?:(?:" + prefix_ptn + ur")|(?:" + morph_prefix2.get_pattern() + ur"))")
				weighted_morph_objects.append((morph_prefix2.get_weight(), morph_prefix2))
			##print "morph_prefix2:", letters
		
		if morph_stem != None:
			#prec_span = morph_prefix.get_prec_span()
			#candidate_morphs.append((morph_stem.get_weight(), morph_stem))
			pair = (morph_stem.get_weight()*1.000001, morph_stem)
			weighted_morph_objects.append(pair)
			all_letters.extend(morph_stem.get_letters())
			##print "morph_stem:", "*" + " ".join(morph_stem.get_letters()) + "*"
			#stem_ptn += ".*".join(patterns)
			morph_stem.compute_pattern()
			#patterns.append(".*" + morph_stem.get_pattern())
			patterns.append(morph_stem.get_pattern())
			#morph_objects.append(morph_stem)
		
		if morph_suffix != None:
			#candidate_morphs.append((morph_suffix.get_weight(), morph_suffix))
			#morph_objects.append(morph_suffix)
			morph_suffix.compute_pattern()
			weighted_morph_objects.append((morph_suffix.get_weight(), morph_suffix))
			max_back_index = morph_suffix.get_max_index()
			##print "morph_suffix:", morph_suffix.get_letters()
			##print "SUF_WT:", morph_suffix.get_weight()
			if morph_stem != None:
				morph_suffix.compute_pattern()
				##print "STEM_WT:", morph_stem.get_weight(), "; SUF_WT:", morph_suffix.get_weight()
				##print "SUF MAX INDEX:", morph_suffix.get_max_index()
				if morph_suffix.get_max_index() < -1:
					if morph_stem.get_weight() < morph_suffix.get_weight():
					#stem_ptn = morph_stem.get_pattern()
						stem_ptn = patterns.pop()
						morph_suffix.compute_pattern()
						patterns.append(morph_suffix.get_pattern())
						all_letters.extend(morph_suffix.get_letters())
						#weighted_morph_objects.append((morph_suffix.get_weight(), morph_suffix))
						#max_back_index = -2
					#morph_length = morph_suffix.get_num_letters()	
					else: pass
						#patterns.append(morph_suffix.get_pattern())
						#all_letters.extend(morph_suffix.get_letters())
						#max_back_index = morph_suffix.get_max_index()
				#patterns.append(ur"(?:(?:" + stem_ptn + ur")|(?:" + morph_suffix.get_pattern() + ur"))")
				else:
					morph_suffix.compute_pattern()
					patterns.append(morph_suffix.get_pattern())
					all_letters.extend(morph_suffix.get_letters())
					#weighted_morph_objects.append((morph_suffix.get_weight(), morph_suffix))
					#max_back_index = morph_suffix.get_max_index()
			else:
				morph_suffix.compute_pattern()
				patterns.append(morph_suffix.get_pattern())
				all_letters.extend(morph_suffix.get_letters())
				#weighted_morph_objects.append((morph_suffix.get_weight(), morph_suffix))
				#max_back_index = morph_suffix.get_max_index()

		if morph_suffix2 != None and len(morph_suffix2.get_pattern()) > 0:
			#candidate_morphs.append((morph_suffix2.get_weight(), morph_suffix2))
			###print "morph_suffix2:", morph_suffix2.get_letters()
			#suffix_ptn = morph_suffix2
			morph_suffix2.compute_pattern()
			weighted_morph_objects.append(morph_suffix2.get_weight(), morph_suffix2)
			all_letters.extend(morph_suffix2.get_letters())
			suffix_ptn = patterns.pop()
			##print "morph_suffix2:", "*" + " ".join(morph_suffix2.get_pattern()) + "*"
			patterns.append(ur"(?:(?:" + suffix_ptn + ur")|(?:" + morph_suffix2.get_pattern() + ur"))")
			# letters = []
			# try: letters = morph_suffix2.get_letters()
			# except AssertionError: pass
			# else:
				
			###print "morph_suffix2:", letters
		###print "HERE!" ###print "morph_suffix2:", morph_suffix2.get_letters()
		# if morph_stem != None:
		# 	overall_ptn = ur".*" + morph_stem.get_pattern() +  ur".*" 
		# 	overall_ptn = overall_ptn.replace(".*.*.*", ".*")
		# 	overall_ptn = overall_ptn.replace(".*.*", ".*")
		# 	outputDict[cluster_ID] = (weight, overall_ptn)
		# 	##print morph_stem.get_pattern()
		# 	#print overall_ptn
		# 	continue

		weighted_morph_objects.sort(reverse=True)
		best_pair = weighted_morph_objects[0]
		best_weight, best_morph_object = best_pair[0], best_pair[1]
		#print cluster_ID, ";", best_weight, best_morph_object.get_pattern(), ",".join(best_morph_object.get_letters()), best_morph_object.get_morph_type()
		#overall_ptn = ur".*".join(patterns)
		overall_ptn = best_morph_object.get_pattern()
		overall_ptn = overall_ptn.replace(".*.*.*", ".*")
		overall_ptn = overall_ptn.replace(".*.*", ".*")
		best_morph_object.set_pattern(overall_ptn)
		# if min_front_index != None: # and min_front_index > 0:
		# 	front_offset = ur""
		# 	for n in range(min_front_index):
		# 		front_offset += ur"."
		# 	overall_ptn = front_offset + overall_ptn
		# #if min_front_index > 0:
		# 	#overall_ptn = ur".*" + overall_ptn
		# if max_back_index != None: #and max_back_index  < -1:
		# 	back_offset = ur""
		# 	for n in range(abs(max_back_index)-1):
		# 		back_offset += ur"."
		# 	#overall_ptn += ur".*"
		# 	overall_ptn += back_offset
		# overall_ptn = overall_ptn.replace(".*.*.*", ".*")
		# overall_ptn = overall_ptn.replace(".*.*", ".*")
		# #print overall_ptn
		# morph_obj = MWP(overall_ptn)
		# morph_obj.set_weight(overall_weight)
		# morph_obj.set_letters(all_letters)
		

		#morph_objects = []
		##print morph_obj.get_letters()
		#stem_ptn + suffix_ptn + ".*"
				####print "morph_stem:", morph_stem.get_morph()		
			# if morph_prefix != None:
			# 	candidate_morphs.append((morph_prefixget_weight(), "aa&" + morph_prefix.get_morph()))
			# 	####print "morph_prefix:", morph_prefix.get_morph()
			# if morph_suffix != None:
			# 	candidate_morphs.append((morph_suffix.get_weight(), "zz&" + morph_suffix.get_morph()))
			# 	####print "morph_suffix:", morph_suffix.get_morph()
			# if morph_stem != None:
			# 	candidate_morphs.append((morph_stem.get_weight(), morph_stem.get_morph()))

		# 	candidate_morphs.sort(reverse=True)
		# 	#Assign highest-weighted morph to cluster
		# 	####print "cluster_ID:", cluster_ID
		# 	if outputWeights:
		# 		outputDict[cluster_ID] = candidate_morphs.pop(0)
		# 	else:
		# 		outputDict[cluster_ID] = candidate_morphs.pop(0)[1]
		outputDict[cluster_ID] = (weight, best_morph_object)
		#outputDict[cluster_ID] = (weight, overall_ptn)
	#stoppingPoint = 10
	#n = 0
	# for cluster_ID in outputDict.keys():
	# 	pair = outputDict[cluster_ID]
	# 	print n, ";", cluster_ID, ";", pair[0], pair[1]
	# 	#if n == stoppingPoint: break
	# 	n += 1 
	return outputDict

if __name__ == "__main__":
	cvals_filename = sys.argv[1]
	# max_pos = int(sys.argv[2])
	# prec_span = int(sys.argv[3])
	# name_components = cvals_filename.split("_")
	# max_pos = int(name_components[0])
	# prec_span = int(name_components[1])
	#morph_dict = main(cvals_filename, max_pos, prec_span, outputWeights=True)
	morph_dict = main(cvals_filename, outputWeights=True)
	#print "MORPH_DICT:"
	#print morph_dict
	stoppingPoint = 10
	n = 0
	for cluster_ID in morph_dict.keys():
		pair = morph_dict[cluster_ID]
		#print n, ";", cluster_ID, ";", pair[0], pair[1]
		#if n == stoppingPoint: break
		n += 1 