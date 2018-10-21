#!/usr/bin/env python
# -*- coding: utf-8 -*-


#import regex as re
import re
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
	# for fwp1 in feature_objects:
	# 	feature1 = fwp1.get_feature()
	# 	if fwp1.get_feature_type() == 'prec':
	# 		for fwp2 in feature_objects:
	# 			if fwp2.get_feature_type == 'prec'
	# 				feature2 = fwp1.get_feature()
	# 				fwp1.get_letter1() == fwp2.get_letter2() and fwp2.get_letter1() == fwp1.get_letter2:
	
	for fwp in feature_objects:
		feature = fwp.get_feature()
		weight = fwp.get_weight()
		if "@" in feature:
			letter,pos_str = feature.split("@")
			pos_str = pos_str.replace("[", "")
			pos_str = pos_str.replace("]", "")
			pos = int(pos_str)
			pos_letter_pair = (pos, letter)
			if "-" in feature:
				##print "found '-':", feature
				temp_suf_pairs.append((pos_letter_pair, weight, fwp))
				# letter,pos_str = feature.split("@")
				# pos_str = pos_str.replace("[", "")
				# pos_str = pos_str.replace("]", "")
				# pos = int(pos_str)
				# pair = (pos, letter)

				##print "tsp:", temp_suf_pairs
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
				temp_pre_pairs.append((pos_letter_pair, weight, fwp))
		elif "<" in feature:
			#prec.append(fwp)
			if fwp.left_equals_right():
				#triple = (1, weight, fwp)
				#We want any feature in wich the left-side letter is the same as the right side to
				# put at/near the end of the list.
				temp_stem_pairs.append((1, weight, fwp))
			else:
				temp_stem_pairs.append((2, weight, fwp))
	if sort_partitions:
		temp_pre_pairs.sort(reverse=False)
		temp_stem_pairs.sort(reverse=True)
		temp_suf_pairs.sort(reverse=False)
	new_pre_objs = []
	new_stem_objs = []
	new_suf_objs = []
	for pos_letter_pair,weight,fwp in temp_pre_pairs:
		new_pre_objs.append(fwp)
	print "^^ IN PART_FEATS:",
	for num,weight,fwp in temp_stem_pairs:
		print num, weight, fwp.get_feature(),";",
		new_stem_objs.append(fwp)
	print ""
	for pos_letter_pair,weight,fwp in temp_suf_pairs:
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
	all_objects_sorted = list(new_pre_objs)
	###print "aos:", all_objects_sorted
	all_objects_sorted.extend(new_suf_objs)
	###print "*aos:", all_objects_sorted
	all_objects_sorted.extend(new_stem_objs)
	###print "**aos:", all_objects_sorted

	#return all_objects_sorted 
	return (new_pre_objs, new_suf_objs, new_stem_objs)

# def read_symbol(raw_input, re_pos_front, re_pos_back, re_bi_elems, re_prec_elems):
# 	symbol = None
# 	###print re_pos_front.sub(ur"\1", raw_input)
# 	if re_pos_front.search(raw_input):
# 		###print "*****", re_pos_front.sub(ur"\2", raw_input)
# 		try: symbol = ("@", re_pos_front.sub(ur"\1", raw_input), int(re_pos_front.sub(ur"\2", raw_input)))
# 		except ValueError: return None
# 	elif re_pos_back.search(raw_input):
# 		try: symbol = ("@", re_pos_back.sub(ur"\1", raw_input), int(re_pos_back.sub(ur"\2", raw_input)))
# 		except ValueError: return None
# 	elif re_prec_elems.search(raw_input):
# 		###print "re_prec_elems", "match"
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
	def __init__(self, pattern, wt=0.0):
		#self.morph = morph_str
		self.pattern = pattern
		self.weight = wt
		#self.fwp_list = []
		self.letters = []

	def set_letters(self, letters):
		self.letters = letters

	def get_letters(self):
		return self.letters

	def set_morph(self,new_str):
		self.morph = new_str

	def get_fwp_list(self):
		return self.fwp_list
	# def update_weight(self,wt2):
	# 	self.weight = (self.weight + wt2)/2.0
	def set_weight(self, wt):
		self.weight = wt

	def get_morph(self):
		return self.morph

	def get_weight(self):
		return self.weight

class MWP_prefix:
	#morph_type = "prefix"
	#def __init__(self,init_fwp,morph_str="", wt=0.0):
	def __init__(self, init_fwp, max_pos):
		#MWP.__init__(self,morph_str="",wt=0.0)
		#super(MWP_prefix, self).__init__(morph_str, wt)
		#super(MWP_prefix, self).__init__()
		# if init_fwp.get_feature_type() == "pos_front":
		# 	return None
		
		assert init_fwp.get_feature_type() == "pos_front"
		print "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& MWP_prefix! ", "init_fwp feature:", init_fwp.get_feature()
		# self.letters = []
		# self.positions = []
		self.index_offset = 0
		feature = init_fwp.get_feature()
		letter,pos_str = feature.split("@")
		pos_str = pos_str.replace("[", "")
		pos_str = pos_str.replace("]", "")
		self.letters = [letter]
		self.positions = [int(pos_str)]
		self.min_index = min(self.positions)
		self.max_index = max(self.positions)
		#self.parse_pos_feature(feature)
		# letter,pos_str = feature.split("@")
		# position = abs(int(pos_str))
		# self.positions = [position]
		# self.letters = [letter]
		self.max_pos = int(max_pos)
		#super(MWP_prefix, self).__init__()
		self.first_fwp = init_fwp
		###print "FF:", self.first_fwp.get_feature()
		self.weight = self.first_fwp.get_weight()
		###print "FF weight:", self.weight
		self.fwp_list = [self.first_fwp]
		self.morph = self.first_fwp.get_letter()
		self.filler = ""
	
	def parse_pos_feature(self, pos_feature):
		#pos_feature = init_fwp.get_feature()
		letter,pos_str = pos_feature.split("@")
		pos_str = pos_str.replace("[", "")
		pos_str = pos_str.replace("]", "")
		self.letters.append(letter)
		self.positions.append(int(pos_str))
		self.min_index = min(self.positions)
		self.max_index = max(self.positions)
	
	def get_min_index(self):
		return self.min_index
	def get_max_index(self):
		return self.max_index	

	def get_indices(self):
		return self.positions

	def set_morph(self,fwp):
		self.morph = new_str
	# def update_weight(self,wt2):
	# 	self.weight = (self.weight + wt2)/2.0
	def set_weight(self, wt):
		self.weight = wt

	def get_letters(self):
		return self.letters

	def get_num_letters(self):
		return len(letters)

	def get_max_pos(self):
		return self.max_pos

	def get_fwp_list(self):
		return self.fwp_list
	
	def get_morph(self):
		return self.morph
	
	def get_weight(self):
		return self.weight

	def get_pattern(self):
		assert len(self.letters) > 0
		groups = []
		prev_letter = ""
		# for i in range(len(self.letters)):
		# 	for j in range(len(self.letters))
		group_members = []
		print "Prefix letters please:", self.letters
		for n in range(len(self.letters)):
			letter = self.letters[n]
			if letter in group_members and letter + "+" not in group_members:
				grp_idx = group_members.index(letter)
				group_members.pop(grp_idx)
				group_members.insert(grp_idx, letter + "+")
			elif letter + "+" in group_members:
				pass
			else:
				group_members.append(letter)
			# for x in reversed(range(n)):
			# 	#print n, letters[n], ";", x, letters[x]
			# 	if letters[n] == letters[x]:
			# for j in range(i, 0):
			# 	self.letters[i] = self.letters[j]
		# for letter in self.letters:
		# 	#item = letter
		# 	if letter != prev_letter:
		# 		#item = ur"(" + item + ur")"
		# 		group_members.append(letter)
		# 	else:
		# 		last = group_members.pop()
		# 		print "^^^&&&***()()()  LLAASSTT:", last
		# 		if "+" in last:
		# 			group_members.append(last)
		# 		else:
		# 			group_members.append(last + "+")
		# 	prev_letter = letter
		# group_str = ur""
		group_str = ""
		print "******** GROUP_STR:",
		for group_member in group_members:
			group_str += "(" + group_member + ")"
			print group_str,
		print ""
		return group_str
		#self.morph_regex = re.compile(self.pattern, re.UNICODE)
		#return pattern

	def update_weight(self):
		sum_wt = 0.0
		#if len(self.fwp_list) > 1:
		for my_fwp in self.fwp_list:
			sum_wt += my_fwp.get_weight()
		try: self.weight = sum_wt/float(len(self.fwp_list))
		except ZeroDivisionError: self.weight = 0.0
	
	def update(self, new_fwp):
		assert new_fwp != None
		assert new_fwp.get_feature_type() == 'pos_front' or new_fwp.get_feature_type() == 'prec'
		# if self.morph == "":
		# 	self.morph += self.first_fwp.get_letter()
			#self.fwp_list.append(self.first_fwp)
			#self.fwp_list.append(fwp)
		#avg_wt = 0.0
		conflict = False
		# if self.morph == "":
		# 	self.morph += self.first_fwp.get_letter()
		#print "In UPDATE:", new_fwp.get_feature(),
		other_fwp_type = new_fwp.get_feature_type()
		#print "TYPE:", other_fwp_type 
		if other_fwp_type == "pos_back":
			for i in range(len(self.fwp_list)):
				print "self.fwp_list[i]:",self.fwp_list[i].get_feature(), "; new feature:", new_fwp.get_feature()
				###print "fwp:", fwp.get_feature()
				#if my_fwp.get_feature_type() == "pos_front":
				if self.fwp_list[i].conflictsWith(new_fwp):
					print "!!!!**** CONFLICT ****!!!!"
					conflict = True
					break
				if new_fwp.matches(self.fwp_list[i]):
					###print "MATCH!"
					self.morph += new_fwp.get_letter()
					self.fwp_list.append(new_fwp)
					self.parse_pos_feature(new_fwp.get_feature())
					break
		
		# for i in range(len(self.fwp_list)):
		# 	print "^ & * # $ fwp_list[i]:", self.fwp_list[i].get_feature(), "; new_fwp feature:", new_fwp.get_feature()
		# 	print "\tFWP_LIST[i]:", self.fwp_list[i].get_feature()
		# 	if self.fwp_list[i].conflictsWith(new_fwp):
		# 		print "!!!! CONFLICT !!!!"
		# 		conflict = True
		# 		break
		if conflict:
			if new_fwp.get_weight() > self.fwp_list[i].get_weight():
				letter_to_remove = self.fwp_list[i].get_letter()
				self.fwp_list.pop(i)
				#self.fwp_list.insert(i, new_fwp)
				self.letters.remove(letter_to_remove)
			#else:
				#letter_to_remove = new_fwp.get_letter()
				#self.fwp_list.pop()
				#self.fwp_list.insert(i, new_fwp)
				#self.letters.remove(letter_to_remove)


		# fwp_type = new_fwp.get_feature_type()
		# if fwp_type == "pos_front":
		# 	for my_fwp in self.fwp_list:
		# 		###print "my_fwp:",my_fwp.get_feature()
		# 		###print "fwp:", fwp.get_feature()
		# 		#if my_fwp.get_feature_type() == "pos_front":
		# 		if my_fwp.matches(new_fwp):
		# 			###print "MATCH!"
		# 			self.morph += new_fwp.get_letter()
		# 			self.fwp_list.append(new_fwp)
		# 			self.parse_pos_feature(new_fwp.get_feature())
		# 			break
		# 	conflict = False
		# 	for i in range(len(self.fwp_list)):
		# 		if self.fwp_list[i].conflictsWith(new_fwp):
		# 			conflict = True
		# 			break
		# 	if conflict:
		# 		if new_fwp.get_weight() > self.fwp_list[i].get_weight():
		# 			self.fwp_list.pop(i)
		# 			self.fwp_list.insert(i, new_fwp)
		elif other_fwp_type == "prec":
			for my_fwp in self.fwp_list:
				if new_fwp.matches(my_fwp) and self.index_offset < self.min_index:
					self.morph = new_fwp.get_letter1() + self.morph
					self.fwp_list.append(new_fwp)
					#self.parse_pos_feature(new_fwp.get_feature())
					self.index_offset += 1
					break
		self.update_weight()

	def get_features(self, asString=True):
		###print "CHAIN:",
		features = []
		for item in self.fwp_list:
			features.append(item.get_feature())
		if asString:
			return " ".join(_features)
		return features

class MWP_prefix2:
	def __init__(self, init_fwp, prec_span):
		#MWP.__init__(self,morph_str="",wt=0.0)
		assert init_fwp.get_feature_type() == 'prec' 
		#super(MWP_suffix, self).__init__()
		self.first_fwp = init_fwp
		self.morph_type = "prefix"
		###print "FF:", self.first_fwp.get_feature()
		#self.weight = self.first_fwp.get_weight()
		self.weight = 0.0
		###print "FF weight:", self.weight
		self.fwp_list = [self.first_fwp]
		self.letters = []
		# if prec_span > 1:
		# 	self.filler = ur"."
		self.prec_span = int(prec_span)
		self.filler = ur"".join([ur".?" for n in range(1,self.prec_span)])
		# self.morph_pattern = ur""
		# self.morph_regex 
		#self.morph = self.first_fwp.get_letter()

	def get_letters(self):
		assert len(self.fwp_list) > 1
		return self.letters
	
	def get_num_letters(self):
		assert len(self.fwp_list) > 1
		return len(self.letters)

	def get_fwp_list(self):
		return self.fwp_list
	# def update_weight(self,wt2):
	# 	self.weight = (self.weight + wt2)/2.0
	def update_weight(self):
		sum_wt = 0.0
		for fwp in self.fwp_list:
			sum_wt += fwp.get_weight()
		try: self.weight = sum_wt/len(self.fwp_list)
		except ZeroDivisionError: self.weight = 0.0
	
	def get_morph(self):
		assert len(self.fwp_list) > 1
		return self.morph
	
	def get_pattern(self):
		assert len(self.letters) > 0
		groups = []
		for letter in self.letters:
			groups.append(ur"(" + letter + ur")")
		pattern = self.filler.join(groups)
		#self.morph_regex = re.compile(self.pattern, re.UNICODE)
		return pattern

	def get_pattern(self):
		assert len(self.letters) > 0
		groups = []
		for letter in self.letters:
			groups.append(ur"(" + letter + ur")")
		return self.filler.join(groups)


	def get_weight(self):
		groups = []
		for letter in self.letters:
			groups.append(ur"(" + letter + ur")")
		self.pattern = self.filler.join(groups)
		return self.weight

	def update(self,other_fwp):
		assert other_fwp != None
		assert other_fwp.get_feature_type() == 'prec'
		# if self.morph == "":
		# 	self.morph += self.first_fwp.get_letter()
		##print "In UPDATE:", other_fwp.get_feature(),
		#other_letter1 = other_fwp.get_letter1()
		other_letter1 = other_fwp.get_letter1()
		other_fwp_type = other_fwp.get_feature_type()
		##print "TYPE:", other_fwp_type 
		# if other_fwp_type == "pos_back":
		# 	for my_fwp in self.fwp_list:
		# 		###print "my_fwp:",my_fwp.get_feature()
		# 		###print "fwp:", fwp.get_feature()
		# 		#if my_fwp.get_feature_type() == "pos_front":
		# 		if other_fwp.matches(my_fwp): # or maybe this should be the other way around.
		# 			###print "MATCH!"
		# 			self.morph += fwp.get_letter()
		# 			self.fwp_list.append(fwp)
		#elif other_fwp_type == "prec":
		#print "((((((((((((((((((((( fwp_type:", other_fwp_type
		for my_fwp in self.fwp_list:
			##print my_fwp.get_feature(),
			if my_fwp.matches_prec_front(other_fwp) and len(self.letters) > 0:
				# if len(self.letters) == 0:
				# 	self.letters.append(other_letter2)
				print "MATCH!", my_fwp.get_features(), other_fwp.get_features()
				if other_letter1 not in self.letters:
					self.letters.insert(0,other_letter1)
				#self.morph += other_fwp.get_letter2()
				self.fwp_list.append(other_fwp)
				self.update_weight()
				break
			##print ""
		

#class MWP_stem(MWP):
class MWP_stem:	
	#def __init__(self, init_fwp, morph_str="",wt=0.0):
	def __init__(self, init_fwp, prec_span):
		#MWP.__init__(self,morph_str,wt)
		#super(MWP_stem, self).__init__(morph_str, wt)
		#super(MWP_stem, self).__init__()
		#self.weight = init_fwp.get_weight()
		#assert init_fwp.get_feature_type() == 'prec'
		#super(MWP_stem, self).__init__()
		assert init_fwp.get_feature_type() == 'prec'
		self.first_fwp = init_fwp
		# self.fwp_list = [self.first_fwp]
		# if self.first_fwp.get_feature_type() == "prec":
		# 	self.chain = [self.first_fwp]
		# if self.is_mirror_image(init_fwp):
		# 	self.mirror_images = [init_fwp]
		self.chain = [self.first_fwp]
		#self.sequence = self.first_fwp.get_letter1()
		#self.sequence += self.first_fwp.get_letter2()
		self.morph = self.extract_letter_seq()
		#self.letters = list(self.extract_letter_seq())
		print "init letters:", self.letters
		#print "init morph =",self.morph
		self.morph_type = "stem"
		#self.morph = ""
		#self.morph = self.sequence
		#self.weight = wt
		self.weight = self.first_fwp.get_weight()
		self.prec_span = int(prec_span)
		if self.prec_span < 2:
			self.filler = u""
		else:
			self.filler = u".?"
		self.filler += u"".join([u".?" for n in range(1,self.prec_span)])
		self.reflection_pairs = []


	# def update_weight(self,wt2):
	# 	self.weight = (self.weight + wt2)/2.0
	def set_weight(self, wt):
		self.weight = wt
	def get_morph(self):
		return self.morph
	def get_weight(self):
		return self.weight

	# def get_letter_seq(self):
	# 	return self.sequence

	#def update_list(self,new_fwp):
	def get_index_in_chain(self, letter1, letter2):
		assert len(self.chain) > 0
		featureToFind = letter1 + "<" + letter2
		found = False
		for i in range(len(self.chain)):
			if self.chain[i].get_feature() == featureToFind:
				found = True
				break
		if found:
			return i
		return None

	def get_indices_x_precedes_x(self):
		indices = []
		for i in range(len(self.chain)):
			if self.chain[i].get_letter1 == self.chain[i].get_letter2():
				indices.append(i)
		return indices
	
	def get_reflection_pairs(self):
		return self.reflection_pairs
	# def get_mirror_images(self):
	# 	return self.mirror_images()
	# def is_mirror_image(self, fwp):
	# 	if fwp.get_letter1() == fwp.get_letter2():
	# 		return True
	# 	return False

	# def find_circularity_counterparts():
	# def detect_circularity(self, a_b, a_a):
	# 	if letter1 == letter2:

	# 		featuresToFind = [letter1 + "<" + letter2, letter2 + "<" + letter1]
	# 		for featureToFind in featuresToFind:
	# 			letter1,letter2 = featureToFind.split("<")
	# 			feature_idx = self.get_index_in_chain(letter1,letter2)
	# 			if feature_idx != None
	# 				continue
	# 			else:
	# 				return False
	# 		return True
	# 	else:
	# 		featuresToFind = [letter1 + "<" + letter2, letter2 + "<" + letter1]
	# 		for featureToFind in featuresToFind:
	# 			letter1,letter2 = featureToFind.split("<")
	# 			feature_idx = self.get_index_in_chain(letter1,letter2)
	# 			if feature_idx != None
	# 				continue
	# 			else:
	# 				return False
	# 		return True


	def update_chain(self,new_fwp):
		assert new_fwp.get_feature_type() == "prec"
		breakFlag = False
		#old_length = len(self.chain)
		#new_candidates = []
		update_feasible = False
		print "IN UPDATE CHAIN", "self.chain[0]:", self.chain[0].get_letter1(), self.chain[0].get_letter2()
		print "IN UPDATE CHAIN", "new_fwp:", unicode(new_fwp.get_feature()) #unicode(new_fwp.get_letter1()), unicode(new_fwp.get_letter2())
		if new_fwp.get_letter2() == self.chain[0].get_letter1():
			self.chain.insert(0,new_fwp)
			print "SCENARIO 1 is TRUE"
			return True
		#if len(self.chain) > 1:
			#update_feasible = True
		for i in range(0,len(self.chain)-1):
			if breakFlag: break
			for j in range(i+1,len(self.chain)):
				print i, j, self.chain[i].get_feature(), self.chain[j].get_feature(), " / ", new_fwp.get_feature()
				if (new_fwp.get_letter1() == self.chain[i].get_letter2()) and new_fwp.get_letter2() == self.chain[j].get_letter1(): 
					self.chain.insert(i,new_fwp)
					breakFlag = True
					print "SCENARIO 2 is TRUE"
					update_feasible = True
					break
		print self.chain[-1].get_letter2(), new_fwp.get_letter1(), self.chain[-1].get_letter2() == new_fwp.get_letter1()
		if new_fwp.get_letter1() == self.chain[-1].get_letter2():
			print "SCENARIO 3 is TRUE"
			self.chain.append(new_fwp)
		#len(self.chain) = len(self.chain)
		#self.extract_letter_seq()

	def extract_letter_seq(self):
		# if len(self.chain) < 2:
		# 	return False
		self.letters = []
		temp_seq = ""
		#print "LENGTH:",len(self.chain)
		#print "temp_seq:","$", temp_seq
		# temp_seq = self.chain[0].get_letter1()
		# temp_seq += self.chain[0].get_letter2()
		# self.letters.append(self.chain[0].get_letter1())
		# self.letters.append(self.chain[0].get_letter2())

		temp_chain = list(self.chain)
		#try: sequence += self.chain[1].get_letter2() 
		#except IndexError:
			#pass
		#else:
		first_link = temp_chain.pop(0)
		temp_seq = first_link.get_letter1()
		self.letters.append(first_link.get_letter1())
		#self.letters.append(self.chain[0].get_letter2())
		#print "temp_seq:","first_link 0:", temp_seq
		temp_seq += first_link.get_letter2()
		self.letters.append(first_link.get_letter2())
		#print "temp_seq:","first_link 1:", temp_seq
		
		while len(temp_chain) > 0:
		#for i in range(1,len(self.chain)):
			link = temp_chain.pop(0)
			new_letter = link.get_letter2()
			temp_seq += new_letter
			self.letters.append(new_letter)
		#print "S T E M LETTERS:", self.letters
			#temp_seq += self.chain[i].get_letter2()
			#print "temp_seq:",link, temp_seq
		#sequence += self.chain[-1].get_letter1()
		#sequence += self.chain[-1].get_letter2()
		#self.sequence = temp_seq
		
		# for character in temp_seq
		# 	self.letters.append(character)
		# self.letters = list(temp_seq)
		return temp_seq
	
	def get_letters(self):
		morph = self.extract_letter_seq()
		return self.letters
	
	def get_num_letters(self):
		return len(self.letters)
	
	def get_chain(self):
		###print "CHAIN:",
		return self.chain
	def get_chain_features(self, asString=True):
		###print "CHAIN:",
		chain_features = []
		for item in self.chain:
			chain_features.append(item.get_feature())
		if asString:
			return " ".join(chain_features)
		return chain_features
	
	# def get_morph_regex(self):
	# 	morph = self.extract_letter_seq()
	# 	groups = []
	# 	for letter in self.letters:
	# 		groups.append(u"(" + letter + u")")
	# 	pattern = self.filler.join(groups)
	# 	return re.compile(pattern, re.UNICODE)

	# def get_morph_regex(self):
	# 	groups = []
	# 	morph = self.extract_letter_seq()
	# 	for letter in self.letters:
	# 		groups.append(ur"(" + letter + ur")")
	# 	pattern = self.filler.join(groups)
	# 	return re.compile(pattern, re.UNICODE)
	def get_pattern(self):
		groups = []
		morph = self.extract_letter_seq()
		for letter in self.letters:
			groups.append(ur"(" + letter + ur")")
		#pattern = self.filler.join(groups)
		#return re.compile(pattern, re.UNICODE)
		return self.filler.join(groups)
		###print ""
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
		try: self.weight = sum_wt/len(self.chain)
		except ZeroDivisionError: self.weight = 0.0
	
	def update(self, new_fwp):
		print "IN UPDATE"
		###print "NEW_FWP:", new_fwp
		temp_chain = list(self.chain)
		#new_chain = []
		if new_fwp.left_equals_right():
			for reflection_pair in self.reflection_pairs:
				fwp1 = reflection_pair[0]
				fwp2 = reflection_pair[1]
				if new_fwp.get_letter1() == fwp1.get_letter1():
					pass
				elif new_fwp.get_letter1() == fwp2.get_letter2():
					temp_chain.remove(fwp1)
					temp_chain.remove(fwp2)
					self.chain = [fwp2, fwp1]
					#self.chain = new_chain
					for fwp in temp_chain:
						self.update_chain(fwp)
		else:
			reflection = False
			assert len(self.chain) > 0
			assert new_fwp.get_feature_type() == 'prec'
			for my_fwp in self.chain:
				if my_fwp.is_reflection_of(new_fwp):
					reflection = (my_fwp, new_fwp)
			
			#if new_fwp.get_feature_type() == 'pos_front':
			#elif new_fwp.get_feature_type() == 'prec':
			if self.update_chain(new_fwp):
				#new_morph = self.get_letter_seq()
				self.morph = self.extract_letter_seq()
				if reflection:
					self.reflection_pairs.append(reflection)
				if new_fwp.left_equals_right():
					self.identities.append(new_fwp)
		#print "get_letter_seq =", self.morph
		#elif new_fwp.get_feature_type() == 'pos_back':
		#assert new_morph != None
		# if new_morph == False or new_morph == None:
		# 	pass
		#else:	
		#self.morph = new_morph

		self.update_weight()


#class MWP_suffix(MWP):
class MWP_suffix:
	#morph_type = "suffix"
	# def __init__(self,morph_str="", wt=0.0):
	# 	MWP.__init__(self,morph_str="",wt=0.0)
	#def __init__(self,init_fwp,morph_str="", wt=0.0):
	def __init__(self, init_fwp, max_pos):
		#MWP.__init__(self,morph_str="",wt=0.0)
		assert init_fwp.get_feature_type() == 'pos_back' 
		print "//////&&&&&&&&&&&&&&&&&&&&&&////// MWP_suffix! ", "init_fwp feature:", init_fwp.get_feature()
		self.index_offset = 0
		feature = init_fwp.get_feature()
		letter,pos_str = feature.split("@")
		pos_str = pos_str.replace("[", "")
		pos_str = pos_str.replace("]", "")
		self.letters = [letter]
		self.positions = [int(pos_str)]
		self.min_index = min(self.positions)
		self.max_index = max(self.positions)
		# self.min_index = 0
		# self.max_index = 0
		# self.index_offset = 0
		# self.letters = []
		# self.positions = []
		#self.parse_pos_feature(feature)
		self.max_pos = int(abs(max_pos))
		#super(MWP_suffix, self).__init__()
		self.first_fwp = init_fwp
		#self.letters = [init_fwp.get_letter()]
		#self.positions.append(int(pos_str))
		#self.min_index = min(self.positions)
		#self.max_index = max(self.positions)
		self.morph_type = "suffix"
		###print "FF:", self.first_fwp.get_feature()
		self.weight = self.first_fwp.get_weight()
		###print "FF weight:", self.weight
		self.fwp_list = [self.first_fwp]
		self.morph = self.first_fwp.get_letter()
		self.filler = ""

	def get_letters(self):
		return self.letters
	def get_num_letters(self):
		return len(self.letters)
	def get_fwp_list(self):
		return self.fwp_list
	def set_weight(self, wt):
		self.weight = wt
	def get_morph(self):
		return self.morph
	def get_weight(self):
		return self.weight
	def get_max_pos(self):
		return self.max_pos
	def get_min_index(self):
		return self.min_index
	def get_max_index(self):
		return self.max_index	
	def update_weight(self):
		sum_wt = 0.0
		for my_fwp in self.fwp_list:
			sum_wt += my_fwp.get_weight()
		try: self.weight = sum_wt/len(self.fwp_list)
		except ZeroDivisionError: self.weight = 0.0
	
	# def get_morph_regex(self):
	# 	groups = []
	# 	for letter in self.letters:
	# 		groups.append(ur"(" + letter + ur")")
	# 	#pattern = self.filler.join(groups)
	# 	#return re.compile(pattern, re.UNICODE)
	# 	return self.filler.join(groups)

	def parse_pos_feature(self, pos_feature):
		#pos_feature = init_fwp.get_feature()
		letter,pos_str = pos_feature.split("@")
		pos_str = pos_str.replace("[", "")
		pos_str = pos_str.replace("]", "")
		self.letters.append(letter)
		self.positions.append(int(pos_str))
		self.min_index = min(self.positions)
		self.max_index = max(self.positions)

	def get_pattern (self):
		groups = []
		group_members = []

		print "GS:", group_members
		#print "TRY (POP) THIS:", group_members.pop()
		print "Suffix letters please:", self.letters

		for n in range(len(self.letters)):
			letter = self.letters[n]
			if letter in group_members and letter + "+" not in group_members:
				grp_idx = group_members.index(letter)
				group_members.pop(grp_idx)
				group_members.insert(grp_idx, letter + "+")
			elif letter + "+" in group_members:
				pass
			else:
				group_members.append(letter)
			# for x in reversed(range(n)):
			# 	#print n, letters[n], ";", x, letters[x]
			# 	if letters[n] == letters[x]:
			# for j in range(i, 0):
			# 	self.letters[i] = self.letters[j]
		# for letter in self.letters:
		# 	#item = letter
		# 	if letter != prev_letter:
		# 		#item = ur"(" + item + ur")"
		# 		group_members.append(letter)
		# 	else:
		# 		last = group_members.pop()
		# 		print "^^^&&&***()()()  LLAASSTT:", last
		# 		if "+" in last:
		# 			group_members.append(last)
		# 		else:
		# 			group_members.append(last + "+")
		# 	prev_letter = letter
		# group_str = ur""
		group_str = ""
		print "******** GROUP_STR:",
		for group_member in group_members:
			group_str += "(" + group_member + ")"
			print group_str,
		print ""
		return group_str

	def update(self,new_fwp):
		assert new_fwp != None
		assert new_fwp.get_feature_type() != 'pos_front' # or fwp.get_feature_type() == 'prec'
		conflict = False
		# if self.morph == "":
		# 	self.morph += self.first_fwp.get_letter()
		#print "In UPDATE:", new_fwp.get_feature(),
		other_fwp_type = new_fwp.get_feature_type()
		#print "TYPE:", other_fwp_type 
		if other_fwp_type == "pos_back":
			for i in range(len(self.fwp_list)):
				print "self.fwp_list[i]:",self.fwp_list[i].get_feature(), "; new feature:", new_fwp.get_feature()
				###print "fwp:", fwp.get_feature()
				#if my_fwp.get_feature_type() == "pos_front":
				if self.fwp_list[i].conflictsWith(new_fwp):
					print "!!!!**** CONFLICT ****!!!!"
					conflict = True
					break
				if new_fwp.matches(self.fwp_list[i]):
					###print "MATCH!"
					self.morph += new_fwp.get_letter()
					self.fwp_list.append(new_fwp)
					self.parse_pos_feature(new_fwp.get_feature())
					break
		
		# for i in range(len(self.fwp_list)):
		# 	print "^ & * # $ fwp_list[i]:", self.fwp_list[i].get_feature(), "; new_fwp feature:", new_fwp.get_feature()
		# 	print "\tFWP_LIST[i]:", self.fwp_list[i].get_feature()
		# 	if self.fwp_list[i].conflictsWith(new_fwp):
		# 		print "!!!! CONFLICT !!!!"
		# 		conflict = True
		# 		break
		if conflict:
			if new_fwp.get_weight() > self.fwp_list[i].get_weight():
				letter_to_remove = self.fwp_list[i].get_letter()
				self.fwp_list.pop(i)
				#self.fwp_list.insert(i, new_fwp)
				self.letters.remove(letter_to_remove)
			#else:
				#letter_to_remove = new_fwp.get_letter()
				#self.fwp_list.pop()
				#self.fwp_list.insert(i, new_fwp)
				#self.letters.remove(letter_to_remove)

		elif other_fwp_type == "prec":
			#print "((((((((((((((((((((( fwp_type:", other_fwp_type
			for my_fwp in self.fwp_list:
				##print my_fwp.get_feature(),
				if my_fwp.matches(new_fwp) and self.index_offset < abs(self.max_index) - 1:
					self.morph += new_fwp.get_letter2()
					self.fwp_list.append(new_fwp)
					#self.parse_pos_feature(new_fwp.get_feature())
					self.index_offset += 1
					break
			##print ""
		self.update_weight()

	def get_features(self, asString=True):
		###print "CHAIN:",
		features = []
		for item in self.fwp_list:
			features.append(item.get_feature())
		if asString:
			return " ".join(_features)
		return features

class MWP_suffix2:
	def __init__(self, init_fwp, prec_span):
		#MWP.__init__(self,morph_str="",wt=0.0)
		assert init_fwp.get_feature_type() == 'prec' 
		#super(MWP_suffix, self).__init__()
		self.first_fwp = init_fwp
		self.morph_type = "suffix"
		###print "FF:", self.first_fwp.get_feature()
		#self.weight = self.first_fwp.get_weight()
		self.weight = 0.0
		###print "FF weight:", self.weight
		self.fwp_list = [self.first_fwp]
		self.letters = []
		# if prec_span > 1:
		# 	self.filler = ur"."
		self.prec_span = int(prec_span)
		self.filler = ur"".join([ur".?" for n in range(1,self.prec_span)])
		# self.morph_pattern = ur""
		# self.morph_regex 
		#self.morph = self.first_fwp.get_letter()

	def get_fwp_list(self):
		return self.fwp_list
	# def update_weight(self,wt2):
	# 	self.weight = (self.weight + wt2)/2.0

	def update_weight(self):
		sum_wt = 0.0
		for fwp in self.fwp_list:
			sum_wt += fwp.get_weight()
		try: self.weight = sum_wt/len(self.fwp_list)
		except ZeroDivisionError: self.weight = 0.0

	def get_morph(self):
		assert len(self.fwp_list) > 1
		return self.morph
	
	def get_pattern(self):
		groups = []
		for letter in self.letters:
			groups.append(ur"(" + letter + ur")")
		#pattern = self.filler.join(groups)
		#return re.compile(pattern, re.UNICODE)
		return self.filler.join(groups)
		#prev_letter = ""
		# print "GS:", group_members
		# #print "TRY (POP) THIS:", group_members.pop()
		# print "Suffix letters please:", self.letters

		# for n in range(len(self.letters)):
		# 	letter = self.letters[n]
		# 	if letter in group_members and letter + "+" not in group_members:
		# 		grp_idx = group_members.index(letter)
		# 		group_members.pop(grp_idx)
		# 		group_members.insert(grp_idx, letter + "+")
		# 	elif letter + "+" in group_members:
		# 		pass
		# 	else:
		# 		group_members.append(letter)
			# for x in reversed(range(n)):
			# 	#print n, letters[n], ";", x, letters[x]
			# 	if letters[n] == letters[x]:
			# for j in range(i, 0):
			# 	self.letters[i] = self.letters[j]
		# for letter in self.letters:
		# 	#item = letter
		# 	if letter != prev_letter:
		# 		#item = ur"(" + item + ur")"
		# 		group_members.append(letter)
		# 	else:
		# 		last = group_members.pop()
		# 		print "^^^&&&***()()()  LLAASSTT:", last
		# 		if "+" in last:
		# 			group_members.append(last)
		# 		else:
		# 			group_members.append(last + "+")
		# 	prev_letter = letter
		# group_str = ur""
		# group_str = ""
		# print "******** GROUP_STR:",
		# for group_member in group_members:
		# 	group_str += "(" + group_member + ")"
		# 	print group_str,
		# print ""
		# return group_str
		
		# for n in range(len(self.letters)):
		# 	letter = self.letters[n]
		# 	for 
		# 	print "TRY (POP) THIS;" #, group_members.pop()
		# 	if letter == prev_letter:
		# 		#print "TRY (POP) THIS:", group_members.pop()
		# 		group_members.pop()
		# 		group_members.append(letter + "+")
		# 	elif letter == prev_letter + "+": pass
		# 		# grp_idx = group_members.index(letter)
		# 		# group_members.pop(grp_idx)
		# 		# group_members.insert(grp_idx, letter + "+")
		# 	else: group_members.append(letter)			
		# 	# if letter in group_members and letter + "+" not in group_members:
		# 	# 	grp_idx = group_members.index(letter)
		# 	# 	group_members.pop(grp_idx)
		# 	# 	group_members.insert(grp_idx, letter + "+")
		# 	# elif letter + "+" in group_members:
		# 	# 	pass
		# 	# else:
		# 	# 	group_members.append(letter)
		# 	prev_letter = letter
		# for gm in group_members:
		# 	groups.append(ur"(" + gm + ur")")
		# print "GS:", group_members
		# return self.filler.join(groups)

	def get_weight(self):
		return self.weight

	def update(self ,other_fwp):
		assert other_fwp != None
		other_fwp_type = other_fwp.get_feature_type()
		assert other_fwp_type == 'prec'
		# if self.morph == "":
		# 	self.morph += self.first_fwp.get_letter()
		##print "In UPDATE:", other_fwp.get_feature(),
		#other_letter1 = other_fwp.get_letter1()
		other_letter2 = other_fwp.get_letter2()
		#other_fwp_type = other_fwp.get_feature_type()
		##print "TYPE:", other_fwp_type 
		# if other_fwp_type == "pos_back":
		# 	for my_fwp in self.fwp_list:
		# 		###print "my_fwp:",my_fwp.get_feature()
		# 		###print "fwp:", fwp.get_feature()
		# 		#if my_fwp.get_feature_type() == "pos_front":
		# 		if other_fwp.matches(my_fwp): # or maybe this should be the other way around.
		# 			###print "MATCH!"
		# 			self.morph += fwp.get_letter()
		# 			self.fwp_list.append(fwp)
		#elif other_fwp_type == "prec":
		#print "((((((((((((((((((((( fwp_type:", other_fwp_type
		for my_fwp in self.fwp_list:
			##print my_fwp.get_feature(),
			if my_fwp.matches_prec_back(other_fwp) and len(self.letters) > 0:
				# if len(self.letters) == 0:
				# 	self.letters.append(other_letter2)
				print "SELF.LETTERS:", self.letters, "OTHER_LETTER2:", other_letter2
				if other_letter2 not in self.letters:
					self.letters.append(other_letter2)
				#self.morph += other_fwp.get_letter2()
				self.fwp_list.append(other_fwp)
				break
			##print ""
		self.update_weight()
	
	def get_letters(self):
		assert len(self.fwp_list) > 1
		return self.letters
	
	def get_num_letters(self):
		#assert len(self.fwp_list) > 1
		return len(self.letters)


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
		#FWP.__init__(self, feat, wt)
		super(FWP_pos, self).__init__(feat, wt)
		#self.pos = int(temp)
		self.feature = feat
		self.letter = self.feature.split("@")[0]

	def get_letter(self):
		return self.letter
	def get_pos(self):
		return self.pos

	# def get_feature(self):
	# 	return self.feature

#class FWP_pos_front(FWP_pos):
class FWP_pos_front:
	def __init__(self, feat="", wt=0.0):
		#super(FWP_pos_front, self).__init__(feat, wt)
		#FWP_pos.__init__(self, feat, wt)
		###print "HELP",self.feature
		###print "HELP",self.weight
		self.feature = feat
		self.feature_type = 'pos_front'
		#self.weight = wt
		#sys.stderr.write("feat:" + feat + "\n")
		components = self.feature.split("@")
		###print components
		self.letter = components[0]
		temp = components[1]
		# ###print "temp:" temp
		temp = temp.replace("[","")
		temp = temp.replace("]","")
		self.pos = int(temp)
		self.letter = self.feature.split("@")[0]
		self.weight = wt

	def set_feature(self,feat):
		self.feature = feat
	
	def set_weight(self,wt):
		self.weight = wt
	
	def get_feature(self):
		return self.feature
	
	def get_weight(self):
		return self.weight
	
	def get_letter(self):
		return self.letter
	
	def get_pos(self):
		return self.pos
		###print "POS:", self.pos
	
	def get_feature_type(self):
		return self.feature_type
	
	def matches(self, other_fwp):
		other_weight = other_fwp.get_weight()
		other_type = other_fwp.get_feature_type()
		other_feature = other_fwp.get_feature()
		other_letter = other_fwp.get_letter()
		if other_type == "pos_front":
			other_pos = other_fwp.get_pos()
			print ">> other feature's letter:", other_letter, "; my_letter:", self.letter
			print ">> other feature's position:", other_pos, "; my_position:", self.pos
			if other_pos == self.pos + 1: 
				print "return TRUE!!! FRONT-door match!!!"
				if other_letter == self.letter:
					print "\t\t(But the letters are the same.)"
				return True
				#return (self.weight + other_weight)/2.0
			return False
		elif other_type == "prec":
		# 	other_letter1 =  other_fwp.get_letter1()
		# 	other_letter2 = other_fwp.get_letter2()
			if self.letter == other_fwp.get_letter2(): return True
		return False
	def conflictsWith(self, other_fwp):
		assert other_fwp.get_feature_type() == "pos_front"
		other_letter = other_fwp.get_letter()
		other_pos = other_fwp.get_letter()
		if self.pos == other_fwp.get_pos():
			return True
		return False

#class FWP_pos_back(FWP_pos):
class FWP_pos_back:
	#feature_type = "pos_back"
	def __init__(self, feat="", wt=0.0):
		#FWP_pos.__init__(self, feat, wt)
		#super(FWP_pos_back, self).__init__(feat, wt)
		###print "HELP",self.feature
		###print "HELP",self.weight
		#assert self.feature_type == 'pos_back'
		#self.weight = wt
		#sys.stderr.write("feat:" + feat + "\n")
		self.feature = feat
		components = self.feature.split("@")
		###print components
		self.letter = components[0]
		temp = components[1]
		self.feature_type = "pos_back"
		# ###print "temp:" temp
		temp = temp.replace("[","")
		temp = temp.replace("]","")
		self.pos = int(temp)
		
		#self.letter = self.feature.split("@")[0]
		self.weight = wt

	def set_feature(self,feat):
		self.feature = feat
	def set_weight(self,wt):
		self.weight = wt
	def get_feature(self):
		return self.feature
	def get_weight(self):
		return self.weight
	def get_letter(self):
		return self.letter
	def get_pos(self):
		return self.pos
		###print "POS:", self.pos
	def get_feature_type(self):
		return self.feature_type
	def matches(self,other_fwp):
		other_weight = other_fwp.get_weight()
		other_type = other_fwp.get_feature_type()
		other_feature = other_fwp.get_feature()
		assert other_type != "pos_front"
		#other_letter = other_fwp.get_letter()
		print "OTHER_TYPE:", other_type
		if other_type == "pos_back":
			other_pos = other_fwp.get_pos()
			other_letter = other_fwp.get_letter()
			print ">> other feature's letter:", other_letter, "; my_letter:", self.letter
			print ">> other feature's position:", other_pos, "; my_position:", self.pos
			#print "other feature's letter:", other_pos, "my_letter:", self.letter
			if other_pos == self.pos - 1:
				print "return TRUE!!! BACK-door match!!!"
				if other_letter == self.letter:
					print "\t\t(But the letters are the same.)"
				return True
				#return (self.weight + other_weight)/2.0
		elif other_type == "prec":
			other_letter1 = other_fwp.get_letter1()
			print "((((((((((((((((((((( other_letter1:", other_letter1
			if self.letter == other_letter1: return True
		return False
	def conflictsWith(self, other_fwp):
		assert other_fwp.get_feature_type() == "pos_back"
		other_letter = other_fwp.get_letter()
		other_pos = other_fwp.get_letter()
		if self.pos == other_fwp.get_pos():
			return True
		return False

#class FWP_prec(FWP):
class FWP_prec:
	#feature_type = "pos"
	def __init__(self, feat="", wt=0.0):
		#FWP.__init__(self, feat, wt)
		#super(FWP_prec, self).__init__(feat, wt)
		#super(FWP_prec, self).__init__(feat, wt)
		#self.pos = int(temp)
		self.feature = feat
		components = self.feature.split("<")
		self.letter1 = components[0]
		self.letter2 = components[1]
		self.feature_type = 'prec'
		self.weight = wt

	def set_feature(self,feat):
		self.feature = feat
	def set_weight(self,wt):
		self.weight = wt
	def get_feature(self):
		return self.feature
	def get_weight(self):
		return self.weight
	def get_feature_type(self):
		return self.feature_type
	def get_letter1(self):
		return self.letter1
	def get_letter2(self):
		return self.letter2
	# def matches_front(self,other_fwp):
	# 	other_weight = other_fwp.get_weight()
	# 	other_type = other_fwp.get_feature_type()
	# 	other_feature = other_fwp.get_feature()
	# 	##print "other_feature:", other_feature, ";"
	# 	assert other_type == "prec"
	# 	other_letter2 = other_fwp.get_letter1()
	# 	if self.letter1 == other_letter1: return True
			#other_letter = other_fwp.get_letter()
		# 	if self.letter2 == other_letter: return True
		# 		#return (self.weight + other_weight)/2.0
		# elif other_type == "pos_back":
		# 	other_letter = other_fwp.get_letter()
		# 	if self.letter1 == other_letter: return True
		# 	#if other_pos == self.pos - 1: return True
		# 		#return (self.weight + other_weight)/2.0
		# elif other_type == "prec":
		# 	other_letter1 = other_fwp.get_letter1()
		# 	other_letter2 = other_fwp.get_letter2()
		# 	##print "to_match:",self.feature,self.letter2,  ";", other_fwp.get_feature(), other_letter1
		# 	if self.letter2 == other_letter1: return True# or self.letter1 == other_letter2: return True
	def left_equals_right(self):
		assert self.feature_type == 'prec'
		if self.letter1 == self.letter2:
			return True
		return False

	def is_reflection_of(self, other_fwp):
		assert other_fwp.get_feature_type() == 'prec'
		if self.letter2 == other_fwp.get_letter1() and self.letter1 == other_fwp.get_letter2():
			return True
		else: return False

	# def reduction(self,other_fwp):
	# 	assert other_fwp.get_feature_type() == 'prec'
	# 	output = ""
	# 	if self.letter2 == other_fwp.get_letter1() and self.letter1 == other_fwp.get_letter2():
	# 		return 

	def matches(self,other_fwp):
		#other_weight = other_fwp.get_weight()
		other_type = other_fwp.get_feature_type()
		#other_feature = other_fwp.get_feature()
		##print "other_feature:", other_feature, ";"
		other_letter1 = ""
		other_letter2 = ""
		other_letter = ""
		if other_type == "pos_front":
			other_letter = other_fwp.get_letter()
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
			##print "to_match:",self.feature,self.letter2,  ";", other_fwp.get_feature(), other_letter1
			if self.letter2 == other_letter1: return True # or self.letter1 == other_letter2: return True

	def matches_prec_front(self,other_fwp):
		assert other_fwp.get_feature_type() == "prec"
		other_letter1 = other_fwp.get_letter1()
		print "my feature and other feature:", self.feature, other_fwp.get_feature()
		if self.letter1 == other_letter1:
			print "return True" 
			return True# or self.letter1 == other_letter2: return True
		else:
			print "FALSE"
			return False

	def matches_prec_back(self,other_fwp):
		assert other_fwp.get_feature_type() == "prec"
		other_letter2 = other_fwp.get_letter2()
		if self.letter2 == other_letter2: return True# or self.letter1 == other_letter2: return True
		return False


def get_sortedKeys(featVal_pairs):
	features = []
	##print "sortedKeys from get_sortedKeys:"
	for pair in sorted(featVal_pairs, key=lambda x: x[1], reverse=True):
		##print pair[0], pair[1], ";", 
		features.append(pair[0])
	##print ""
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
		##sys.stderr.write(str(lists))
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
			##print "OL:",feat_wt_list
			#sorted_features = get_sortedKeys(old_dict)
			sorted_feats_and_wts = get_sortedKeyValPairs(feat_wt_list)
			# ##print "Sorted Features:",
			# for feature in sorted_features:
			# 	###print key + " " + str(val),
			# 	##print feature,
			# ##print ""
			###print "Original List:", " ".join(newish_list)
			#new_list = []
			# for feature in sorted_features:
			# 	parsed_feature = self.read_symbol(feature)
			# 	if parsed_feature[0] = 1
			# 	##print "parsed_feature:", parsed_feature, ##print "  ",
			# 	if parsed_feature != None:
			# 		new_list.append(parsed_feature)
			# ##print ""
			#new_list.sort()

			# ##print "New List:",
			# for tup in newish_list:
			# 	##print " ".join(list(tup)),
			# ##print ""
			pos_front,pos_back,prec = partition_features(sorted_feats_and_wts)
			features = pos_front
			features.extend(pos_back)
			features.extend(prec)
			self.feature_lists.append(features)
			# back_to_features_list = []
			# for parsed_feature in new_list:
			# 	###print parsed_feature, self.revert_to_feature(parsed_feature)
			# 	back_to_features_list.append(self.revert_to_feature(parsed_feature))
			# self.feature_lists.append(back_to_features_list)
			# ##print "Modified List:", " ".join(modified_list)

	def read_symbol(self, raw_input):
		symbol = None
		###print re_pos_front.sub(ur"\1", raw_input)
		if self.re_pos_front.search(raw_input):
			###print "*****", re_pos_front.sub(ur"\2", raw_input)
			try: symbol = (0, "@", self.re_pos_front.sub(ur"\1", raw_input), int(self.re_pos_front.sub(ur"\2", raw_input)))
			except ValueError: return None
		elif self.re_pos_back.search(raw_input):
			try: symbol = (1, "@", self.re_pos_back.sub(ur"\1", raw_input), int(self.re_pos_back.sub(ur"\2", raw_input)))
			except ValueError: return None
		elif self.re_prec_elems.search(raw_input):
			###print "re_prec_elems", "match"
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
	# # 	##print "OL:",old_dict
	# # 	newish_list = get_sortedKeys(old_dict)
	# # 	##print "Original List:",
	# # 	for key in newish_list:
	# # 		###print key + " " + str(val),
	# # 		##print key
	# # 	###print "Original List:", " ".join(newish_list)
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

	# 	##print "New List:",
	# 	for tup in newish_list:
	# 		##print " ".join(list(tup)),
	# 	##print ""
	# 	modified_list = []
	# 	for parsed_feature in new_list:
	# 		###print parsed_feature, self.revert_to_feature(parsed_feature)
	# 		modified_list.append(self.revert_to_feature(parsed_feature))
	# 	#self.feature_lists.append(modified_list)
	# 	##print "Modified List:", " ".join(modified_list)
	# 	return modified_list

if __name__ == "__main__":
	filename = sys.argv[1]
	
	myFeatureLists = FeatureLists(filename)
	active_feature_lists = myFeatureLists.sorted_features()
	n = 1
	for feature_list in active_feature_lists:
		#print n, feature_list
		n += 1
