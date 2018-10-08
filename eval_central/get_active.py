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

class FeatureLists:
	def __init__(self, lists):
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

		for old_list in lists:
			print "OL:", " ".join(old_list)
			new_list = []
			for feature in old_list:
				parsed_feature = self.read_symbol(feature)
				if parsed_feature != None:
					new_list.append(parsed_feature)
			print "NL:", new_list

			new_list.sort()
			#print new_list
			modified_list = []
			for parsed_feature in new_list:
				#print parsed_feature, self.revert_to_feature(parsed_feature)
				modified_list.append(self.revert_to_feature(parsed_feature))
			self.feature_lists.append(modified_list)
			print "ML:", " ".join(modified_list)

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

	def sorted_features(self):
		return self.feature_lists

if __name__ == "__main__":
	filename = sys.argv[1]
	
	myFeatureLists = FeatureLists(filename)
	active_feature_lists = myFeatureLists.sorted_features()
	n = 1
	for feature_list in active_feature_lists:
		print n, feature_list
		n += 1
