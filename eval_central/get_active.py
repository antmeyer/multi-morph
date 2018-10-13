#!/usr/bin/env python
# -*- coding: utf-8 -*-


import regex as re
import sys, codecs, math
#import activeCentroidFeatures as acf
import active_centroid_features as acf
reload(sys)  
sys.setdefaultencoding('utf8')
UTF8Writer = codecs.getwriter('utf8')
sys.stdout = UTF8Writer(sys.stdout)
sys.stderr = UTF8Writer(sys.stderr)

def partition_features(feat_wt_pairs, sort_partitions=True, just_features=True):
	pos_pre = []
	pos_suf = []
	prec = []
	for pair in feat_wt_pairs:
		feature = pair[0]
		weight = pair[1]
		if "@" in feature:
			if "-" in feature:
				pos_suf.append(pair)
			else:
				pos_pre.append(pair)
		elif "<" in feature:
			prec.append(pair)
	if sort_partitions:
		pos_pre.sort(key=lambda x: x[1], reverse=True)
		pos_suf.sort(key=lambda x: x[1], reverse=True)
		prec.sort(key=lambda x: x[1], reverse=True)
	if just_features:
		pos_pre_features = []
		pos_suf_features = []
		prec_features = []
		for pair in pos_pre:
			pos_pre_features.append(pair[0])
		for pair in pos_suf:
			pos_suf_features.append(pair[0])
		for pair in prec:
			prec_features.append(pair[0])
		return (pos_pre_features, pos_suf_features, prec_features)
	return (pos_pre, pos_suf, prec)

def partition_feat_objs(feature_objects, sort_partitions=True):
	pos_pre = []
	pos_suf = []
	prec = []
	temp_pre_pairs = []
	temp_stem_pairs = []
	temp_suf_pairs = []
	for fwp in feature_objects:
		feature = fwp.get_feature()
		weight = fwp.get_weight()
		if "@" in feature:
			if "-" in feature:
				print "found '-':", feature
				temp_suf_pairs.append((weight, fwp))
				print "tsp:", temp_suf_pairs
				#if len(pos_suf) > 0:
					
				# 	if weight <= pos_suf[0].get_weight():
				# 		pos_suf.insert(0, fwp)
				# 	else:
				# 		pos_suf.append(fwp)
				# else:
				# 	pos_suf.append(fwp)
			else:
				# if len(pos) > 0:
				# 	if weight <= pos_suf[0].get_weight():
				# 		pos_suf.insert(0, fwp)
				# 	else:
				# 		pos_suf.append(fwp)
				# else:
				# 	pos_suf.append(fwp)
				temp_pre_pairs.append((weight, fwp))
		elif "<" in feature:
			#prec.append(fwp)
			temp_stem_pairs.append((weight, fwp))
	if sort_partitions:
		temp_pre_pairs.sort(reverse=True)
		temp_stem_pairs.sort(reverse=True)
		temp_suf_pairs.sort(reverse=True)
	new_pre_objs = []
	new_stem_objs = []
	new_suf_objs = []
	for weight,fwp in temp_pre_pairs:
		new_pre_objs.append(fwp)
	for weight,fwp in temp_stem_pairs:
		new_stem_objs.append(fwp)
	for weight,fwp in temp_suf_pairs:
		new_suf_objs.append(fwp)

	# if just_features:
	# 	pos_pre_features = []
	# 	pos_suf_features = []
	# 	prec_features = []
	# 	for pair in pos_pre:
	# 		pos_pre_features.append(pair[0])
	# 	for pair in pos_suf:
	# 		pos_suf_features.append(pair[0])
	# 	for pair in prec:
	# 		prec_features.append(pair[0])
		# return (pos_pre_features, pos_suf_features, prec_features)
	all_objects_sorted = new_pre_objs
	print "aos:", all_objects_sorted
	all_objects_sorted.extend(new_suf_objs)
	print "*aos:", all_objects_sorted
	all_objects_sorted.extend(new_stem_objs)
	print "**aos:", all_objects_sorted

	return all_objects_sorted

# def read_symbol(raw_input, re_pos_front, re_pos_back, re_bi_elems, re_prec_elems):
# 	symbol = None
# 	#print re_pos_front.sub(ur"\1", raw_input)
# 	if re_pos_front.search(raw_input):
# 		#print "*****", re_pos_front.sub(ur"\2", raw_input)
# 		try: symbol = ("@", re_pos_front.sub(ur"\1", raw_input), int(re_pos_front.sub(ur"\2", raw_input)))
# 		except ValueError: return None
# 	elif re_pos_back.search(raw_input):
# 		try: symbol = ("@", re_pos_back.sub(ur"\1", raw_input), int(re_pos_back.sub(ur"\2", raw_input)))
# 		except ValueError: return None
# 	elif re_prec_elems.search(raw_input):
# 		#print "re_prec_elems", "match"
# 		try: symbol = ("<", re_prec_elems.sub(ur"\1", raw_input), re_prec_elems.sub(ur"\3", raw_input))
# 		except ValueError: return None
# 	elif re_bi_elems.search(raw_input):
# 		try: symbol = ("+", re_bi_elems.sub(ur"\1", raw_input), re_bi_elems.sub(ur"\3", raw_input))
# 		except ValueError: return None
# 	else:
# 		symbol = None
# 	return symbol
class MWP(object):
	# weight = ""
	def __init__(self, morph_str="", wt=1.0):
		self.morph = morph_str
		self.weight = wt
		self.fwp_list = []
	def set_morph(self,fwp):
		self.morph = new_str
	def get_fwp_list(self):
		return self.fwp_list
	def update_weight(self,wt2):
		self.weight = (self.weight + wt2)/2.0
	def get_morph(self):
		return self.morph
	def get_weight(self):
		return self.weight

class MWP_prefix(MWP):
	morph_type = "prefix"
	def __init__(self,init_fwp,morph_str="", wt=0.0):
		MWP.__init__(self,morph_str="",wt=0.0)
		if init_fwp.get_feature_type() != "pos_suf":
			self.first_fwp = init_fwp
			#print "FF:", self.first_fwp.get_feature()
			self.weight = self.first_fwp.get_weight()
			#print "FF weight:", self.weight
			self.fwp_list = [self.first_fwp]
			self.morph += self.first_fwp.get_letter()
	def update_weight(self):
		sum_wt = 0.0
		if len(self.fwp_list) > 1:
			for my_fwp in self.fwp_list:
				sum_wt += my_fwp.get_weight()
			self.weight = sum_wt/float(len(self.fwp_list))
	def update(self, fwp):

		# if self.morph == "":
		# 	self.morph += self.first_fwp.get_letter()
			#self.fwp_list.append(self.first_fwp)
			#self.fwp_list.append(fwp)
		#avg_wt = 0.0
		fwp_type = fwp.get_feature_type()
		if fwp_type == "pos_front":
			for my_fwp in self.fwp_list:
				#print "my_fwp:",my_fwp.get_feature()
				#print "fwp:", fwp.get_feature()
				#if my_fwp.get_feature_type() == "pos_front":
				if my_fwp.matches(fwp):
					#print "MATCH!"
					self.morph += fwp.get_letter()
					self.fwp_list.append(fwp)
		elif fwp_type == "prec":
			for my_fwp in self.fwp_list:
				if fwp.matches(my_fwp):
					self.morph = fwp.get_letter1() + self.morph
					self.fwp_list.append(fwp)
		self.update_weight()


class MWP_stem(MWP):
	
	def __init__(self, init_fwp, morph_str="",wt=0.0):
		MWP.__init__(self,morph_str,wt)
		#self.weight = init_fwp.get_weight()
		self.first_fwp = init_fwp
		self.chain = [self.first_fwp]
		self.morph_type = "stem"
	def update_chain(self,new_fwp):
		if (new_fwp.get_letter2() == self.chain[0].get_letter1()):
			self.chain.insert(0,new_fwp)
		for i in range(0,len(self.chain)-1):
			for j in range(1,len(self.chain)):
				if (new_fwp.get_letter1() == self.chain[i].get_letter2()) and new_fwp.get_letter2() == self.chain[j].get_letter1(): 
					self.chain.insert(j,new_fwp)
		if (new_fwp.get_letter1() == self.chain[-1].get_letter2()):
			self.chain.append(new_fwp)
	def get_letter_seq(self):
		if len(self.chain) < 2:
			return False
		sequence = ""
		for i in range(len(self.chain)-1):
			sequence += self.chain[i].get_letter1()
		sequence += self.chain[-1].get_letter1()
		sequence += self.chain[-1].get_letter2()
		return sequence
	def get_chain(self):
		#print "CHAIN:",
		return self.chain
		#for item in self.chain:
			#print item,
		#print ""
	# def attach_fwp(fwp):
	# 	if fwp_type = "prec":
	# 		if self.morph = "":
	# 			if fwp.matches(self.first_fwp):
	# 				self.update_prec_chain(fwp)
	# 				self.morph = self.get_letter_seq()

	# 				self.fwp_list.extend([self.first_fwp,fwp])
	# 				self.morph = self.first_fwp.get_letter1() + fwp.get_letter1() + fwp.get_letter2()
	# 		else:
	# 			for my_fwp in self.fwp_list:
	# 				if fwp.matches(my_fwp):
	# 					self.morph += myfwp.get_letter2()
	def update_weight(self):
		sum_wt = 0.0
		for my_fwp in self.chain:
			sum_wt += my_fwp.get_weight()
		self.weight = sum_wt/len(self.chain)
	
	def update(self, new_fwp):
		#print "NEW_FWP:", new_fwp
		self.update_chain(new_fwp)
		new_morph = self.get_letter_seq()
		if new_morph == False or new_morph == None:
			pass
		else:	
			self.morph = new_morph
			self.update_weight()

class MWP_suffix(MWP):
	morph_type = "suffix"
	# def __init__(self,morph_str="", wt=0.0):
	# 	MWP.__init__(self,morph_str="",wt=0.0)
	def __init__(self,init_fwp,morph_str="", wt=0.0):
		MWP.__init__(self,morph_str="",wt=0.0)
		self.first_fwp = init_fwp
		self.morph_type = "suffix"
		#print "FF:", self.first_fwp.get_feature()
		self.weight = self.first_fwp.get_weight()
		#print "FF weight:", self.weight
		self.fwp_list = [self.first_fwp]
		self.morph += self.first_fwp.get_letter()
	def update_weight(self):
		sum_wt = 0.0
		for my_fwp in self.fwp_list:
			sum_wt += my_fwp.get_weight()
		self.weight = sum_wt/len(self.fwp_list)
	def update(self,fwp):
		# if self.morph == "":
		# 	self.morph += self.first_fwp.get_letter()
		fwp_type = fwp.get_feature_type()
		if fwp_type == "pos_back":
			for my_fwp in self.fwp_list:
				#print "my_fwp:",my_fwp.get_feature()
				#print "fwp:", fwp.get_feature()
				#if my_fwp.get_feature_type() == "pos_front":
				if fwp.matches(my_fwp):
					#print "MATCH!"
					self.morph += fwp.get_letter()
					self.fwp_list.append(fwp)
		elif fwp_type == "prec":
			for my_fwp in self.fwp_list:
				if my_fwp.matches(fwp):
					self.morph += fwp.get_letter2()
					self.fwp_list.append(fwp)
		self.update_weight()

class FWP(object):
	# feature = ""
	# weight = 0.0
	def __init__(self, feat="", wt=0.0):
		self.feature = feat
		self.weight = wt
		# self.feature_type = ""
		# if "@" in feat:
		# 	if "-" in feat:
		# 		self.feature_type = "pos_front"
		# 	else: self.feature_type = "pos_back"
		# elif "<" in feat:
		# 	self.feature_type = "prec"
	def set_feature(self,feat):
		self.feature = feat
	def set_weight(self,wt):
		self.weight = wt
	def get_feature(self):
		return self.feature
	def get_weight(self):
		return self.weight
	# def matches(other_fwp):
	# 	other_weight = other_fwp.get_weight()
	# 	other_type = other_fwp.get_type()
	# 	if other_type == 

class FWP_pos(FWP):
	#feature_type = "pos"
	def __init__(self, feat="", wt=0.0):
		FWP.__init__(self, feat, wt)
		#self.pos = int(temp)
		self.feature = feat
		self.letter = self.feature.split("@")[0]
	def get_letter(self):
		return self.letter
	def get_pos(self):
		return self.pos
	# def get_feature(self):
	# 	return self.feature

class FWP_pos_front(FWP_pos):
	
	def __init__(self, feat="", wt=0.0):
		FWP_pos.__init__(self, feat, wt)
		#print "HELP",self.feature
		#print "HELP",self.weight
		self.feature_type = 'pos_front'
		#self.weight = wt
		sys.stderr.write("feat:" + feat + "\n")
		components = self.feature.split("@")
		#print components
		self.letter = components[0]
		temp = components[1]
		# #print "temp:" temp
		temp = temp.replace("[","")
		temp = temp.replace("]","")
		self.pos = int(temp)
		#print "POS:", self.pos
	def get_feature_type(self):
		return self.feature_type
	def matches(self, other_fwp):
		other_weight = other_fwp.get_weight()
		other_type = other_fwp.get_feature_type()
		other_feature = other_fwp.get_feature()
		other_letter = other_fwp.get_letter()
		if other_type == "pos_front":
			other_pos = other_fwp.get_pos()
			if other_pos == self.pos + 1: return True
				#return (self.weight + other_weight)/2.0
			return False
		elif other_type == "prec":
		# 	other_letter1 =  other_fwp.get_letter1()
		# 	other_letter2 = other_fwp.get_letter2()
			if self.letter == other_fwp.get_letter2(): return True
		return False

class FWP_pos_back(FWP_pos):
	#feature_type = "pos_back"
	def __init__(self, feat, wt):
		FWP_pos.__init__(self, feat, wt)
		#print "HELP",self.feature
		#print "HELP",self.weight
		self.feature_type = 'pos_back'
		#self.weight = wt
		sys.stderr.write("feat:" + feat + "\n")
		components = self.feature.split("@")
		#print components
		self.letter = components[0]
		temp = components[1]
		# #print "temp:" temp
		temp = temp.replace("[","")
		temp = temp.replace("]","")
		self.pos = int(temp)
		#print "POS:", self.pos
	def get_feature_type(self):
		return self.feature_type
	def matches(self,other_fwp):
		other_weight = other_fwp.get_weight()
		other_type = other_fwp.get_feature_type()
		other_feature = other_fwp.get_feature()
		#other_letter = other_fwp.get_letter()
		if other_type == "pos_back":
			other_pos = other_fwp.get_pos()
			other_letter = other_fwp.get_letter()
			if other_pos == self.pos - 1: return True
				#return (self.weight + other_weight)/2.0
		elif other_type == "prec":
			other_letter1 = other_fwp.get_letter1()
			if self.letter == other_letter1: return True
		return False

class FWP_prec(FWP):
	#feature_type = "pos"
	def __init__(self, feat="", wt=0.0):
		FWP.__init__(self, feat, wt)
		#self.pos = int(temp)
		self.feature = feat
		components = self.feature.split("<")
		self.letter1 = components[0]
		self.letter2 = components[1]
		self.feature_type = 'prec'
	def get_feature_type(self):
		return self.feature_type
	def get_letter1(self):
		return self.letter1
	def get_letter2(self):
		return self.letter2
	def matches(self,other_fwp):
		other_weight = other_fwp.get_weight()
		other_type = other_fwp.get_feature_type()
		other_feature = other_fwp.get_feature()
		other_letter1 = ""
		other_letter2 = ""
		other_letter = ""
		if other_type == "pos_front":
			#other_letter = other_fwp.get_letter()
			if self.letter2 == other_letter: return True
				#return (self.weight + other_weight)/2.0
		elif other_type == "pos_back":
			other_letter = other_fwp.get_letter()
			if self.letter1 == other_letter: return True
			#if other_pos == self.pos - 1: return True
				#return (self.weight + other_weight)/2.0
		elif other_type == "prec":
			other_letter1 = other_fwp.get_letter1()
			other_letter2 = other_fwp.get_letter2()
			if self.letter2 == other_letter1: return True# or self.letter1 == other_letter2: return True
		return False



def get_sortedKeys(featVal_pairs):
	features = []
	print "sortedKeys from get_sortedKeys:"
	for pair in sorted(featVal_pairs, key=lambda x: x[1], reverse=True):
		print pair[0], pair[1], ";", 
		features.append(pair[0])
	print ""
	return features

def get_sortedKeyValPairs(item_val_pairs):
	#output = []
	return sorted(item_val_pairs, key=lambda x: x[1], reverse=True)
	# 	output.append(pair)
	# return output


class FeatureLists:
	def __init__(self, feat_wt_lists):
		self.feature_lists = []
		#lists = acf.get_active_features(filename)
		#sys.stderr.write(str(lists))
		self.pat_pos = ur"@"
		self.re_pos = re.compile(self.pat_pos, re.UNICODE)

		self.pat_pos_front = ur"(\p{L}\p{M}*)(?:@\[)([0-9])(?:\])"
		self.pat_pos_back = ur"(\p{L}\p{M}*)(?:@\[)(\-[0-9])(?:\])"
		self.re_pos_front = re.compile(self.pat_pos_front, re.UNICODE)
		self.re_pos_back = re.compile(self.pat_pos_back, re.UNICODE)
		self.re_pos = re.compile(self.pat_pos, re.UNICODE)
		self.pat_prec_elems = ur"(\p{L}\p{M}*)(\<)(\p{L}\p{M}*)"
		self.re_prec_elems = re.compile(self.pat_prec_elems, re.UNICODE)
		
		self.pat_bi = ur"\+"
		self.re_bi = re.compile(self.pat_bi, re.UNICODE)

		self.pat_bi_elems = ur"(\p{L}\p{M}*)(\+)(\p{L}\p{M}*)"
		self.re_bi_elems = re.compile(self.pat_bi_elems, re.UNICODE)

		self.pat_prec_or_bi = ur"[+<]"
		self.re_prec_or_bi = re.compile(self.pat_prec_or_bi, re.UNICODE)


		for feat_wt_list in feat_wt_lists:
			print "OL:",feat_wt_list
			#sorted_features = get_sortedKeys(old_dict)
			sorted_feats_and_wts = get_sortedKeyValPairs(feat_wt_list)
			# print "Sorted Features:",
			# for feature in sorted_features:
			# 	#print key + " " + str(val),
			# 	print feature,
			# print ""
			#print "Original List:", " ".join(newish_list)
			#new_list = []
			# for feature in sorted_features:
			# 	parsed_feature = self.read_symbol(feature)
			# 	if parsed_feature[0] = 1
			# 	print "parsed_feature:", parsed_feature, print "  ",
			# 	if parsed_feature != None:
			# 		new_list.append(parsed_feature)
			# print ""
			#new_list.sort()

			# print "New List:",
			# for tup in newish_list:
			# 	print " ".join(list(tup)),
			# print ""
			pos_front,pos_back,prec = partition_features(sorted_feats_and_wts)
			features = pos_front
			features.extend(pos_back)
			features.extend(prec)
			self.feature_lists.append(features)
			# back_to_features_list = []
			# for parsed_feature in new_list:
			# 	#print parsed_feature, self.revert_to_feature(parsed_feature)
			# 	back_to_features_list.append(self.revert_to_feature(parsed_feature))
			# self.feature_lists.append(back_to_features_list)
			# print "Modified List:", " ".join(modified_list)

	def read_symbol(self, raw_input):
		symbol = None
		#print re_pos_front.sub(ur"\1", raw_input)
		if self.re_pos_front.search(raw_input):
			#print "*****", re_pos_front.sub(ur"\2", raw_input)
			try: symbol = (0, "@", self.re_pos_front.sub(ur"\1", raw_input), int(self.re_pos_front.sub(ur"\2", raw_input)))
			except ValueError: return None
		elif self.re_pos_back.search(raw_input):
			try: symbol = (1, "@", self.re_pos_back.sub(ur"\1", raw_input), int(self.re_pos_back.sub(ur"\2", raw_input)))
			except ValueError: return None
		elif self.re_prec_elems.search(raw_input):
			#print "re_prec_elems", "match"
			try: symbol = (2, "<", self.re_prec_elems.sub(ur"\1", raw_input), self.re_prec_elems.sub(ur"\3", raw_input))
			except ValueError: return None
		elif self.re_bi_elems.search(raw_input):
			try: symbol = (3, "+", self.re_bi_elems.sub(ur"\1", raw_input), self.re_bi_elems.sub(ur"\3", raw_input))
			except ValueError: return None
		else:
			symbol = None
		return symbol

	# def partition_features(feat_wt_pairs, sort_partitions=True, just_features=True):
	# 	pos_pre = []
	# 	pos_suf = []
	# 	prec = []
	# 	for pair in feat_wt_pairs:
	# 		feature = pair[0]
	# 		weight = pair[1]
	# 		if "@" in feature:
	# 			if "-" in feature:
	# 				pos_suf.append(pair)
	# 			else:
	# 				pos_pre.append(pair)
	# 		elif "<" in feature:
	# 			prec.append(pair)
	# 	if sort_partitions:
	# 		pos_pre.sort(key=lambda x: x[1], reverse=True)
	# 		pos_suf.sort(key=lambda x: x[1], reverse=True)
	# 		prec.sort(key=lambda x: x[1], reverse=True)
	# 	if just_features:
	# 		for pair in pos_pre:
	# 			pos_pre_features.append(pair[0])
	# 		for pair in pos_suf:
	# 			pos_suf_features.append(pair[0])
	# 		for pair in prec:
	# 			prec_features.append(pair[0])
	# 		return (pos_pre_features, pos_suf_features, prec_features)
	# 	return (pos_pre, pos_suf, prec)

	def decode_symbol(self,symbol_parts_tuple):
		output = ""
		s = symbol_parts_tuple[0]
		a = symbol_parts_tuple[1]
		b = symbol_parts_tuple[2]
		if s == "@":
			if b < 0:
				output = a + "@[-" + str(abs(b)) + "]"
			else:
				output = s + "@[" + str(b) + "]"
		elif s == "<":
			output = a + s + b
		elif s == "+":
			output = a + s + b
		return output

	def revert_to_feature(self, feature_triple):
		feature = ""
		if feature_triple[1] == "@":
			feature = feature_triple[2] + "@" + "[" + str(feature_triple[3]) + "]"
		else:
			feature = feature_triple[2] + feature_triple[1] + feature_triple[3]
		return feature

	# def sorted_features(self):
	# 	return self.feature_lists

	# # def sorted_feature_list(self, old_dict):
	# # 	print "OL:",old_dict
	# # 	newish_list = get_sortedKeys(old_dict)
	# # 	print "Original List:",
	# # 	for key in newish_list:
	# # 		#print key + " " + str(val),
	# # 		print key
	# # 	#print "Original List:", " ".join(newish_list)
	# # 	new_list = []
	# # 	parsed_pos_front = []
	# # 	parsed_pos_back = []
	# # 	parsed_prec = []
	# # 	for feature in newish_list:
	# # 		parsed_feature = self.read_symbol(feature)
	# # 		if parsed_feature[0] == 0:
	# # 		elif parsed_feature[0] == 1:
	# # 		else: parsed_feature[0] == 2:
	# # 			parsed_prec.append(parsed_feature[2] + "<" + parsed_feature[3])
	# # 		if parsed_feature != None:
	# # 			new_list.append(parsed_feature)
	# 	#new_list.sort()

	# 	print "New List:",
	# 	for tup in newish_list:
	# 		print " ".join(list(tup)),
	# 	print ""
	# 	modified_list = []
	# 	for parsed_feature in new_list:
	# 		#print parsed_feature, self.revert_to_feature(parsed_feature)
	# 		modified_list.append(self.revert_to_feature(parsed_feature))
	# 	#self.feature_lists.append(modified_list)
	# 	print "Modified List:", " ".join(modified_list)
	# 	return modified_list

if __name__ == "__main__":
	filename = sys.argv[1]
	
	myFeatureLists = FeatureLists(filename)
	active_feature_lists = myFeatureLists.sorted_features()
	n = 1
	for feature_list in active_feature_lists:
		print n, feature_list
		n += 1
