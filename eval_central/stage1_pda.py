#!/usr/bin/env python
# -*- coding: utf-8 -*-

import regex as re
#import sys, codecs
import sys
#import activeCentroidFeatures as acf
import active_centroid_features as acf
from get_active import FeatureLists
#from get_active import read_lists

reload(sys)  
sys.setdefaultencoding('utf8')
# UTF8Writer = codecs.getwriter('utf8')
# sys.stdout = UTF8Writer(sys.stdout)
# sys.stderr = UTF8Writer(#sys.stderr)

class PDA(object):

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
	morph_elements = []
	def __init__(self, input_list):
		""" The argument input_list is a list of features, of which
		there are two types: positional and precedence.
		"""
		self.cur_state = "q0"
		self.stack = []
		self.morph = ""
		self.tape = list(input_list)
		self.original_tape = list(input_list)
		self.remainder = []
		self.output = ""
		self.cursor = 0

	def consec_pos(self, pos1, pos2):
		""" Return "True" if the two given positions are consecutive (i.e., adjacent),
		and False if they are not.
		The positions (pos1 and pos1) are each in the form "x@[i]", where x is
		a character and i is a (positive) integer
		"""
		###print "     pos1, pos2 =", pos1, pos2
		items_pos1 = pos1.split("@")
		items_pos2 = pos2.split("@")
		x_str = ""
		y_str = ""
		x = None
		y = None
		try: 
			x_str = items_pos1[1]
			x_str = x_str.lstrip("[")
			x_str  = x_str.rstrip("]")
			x = int(x_str)
			
			y_str = items_pos2[1]
			y_str = y_str.lstrip("[")
			y_str = y_str.rstrip("]")
			y = int(y_str)
		except IndexError: return False
		else:
			if x+1 == y: return True
			else: return False

	def consec_pos_suf(self, pos1, pos2):
		items_pos1 = pos1.split("@")
		items_pos2 = pos2.split("@")
		item1 = items_pos1[1].lstrip("[")
		item1 = item1.rstrip("]")
		item2 = items_pos2[1].lstrip("[")
		item2 = item2.rstrip("]")
		##print "\n\n", "consec_pos_suf;", "item1 =", item1, "; item2 =", item2, "\n\n"
		try: 
			x = int(item1)
			y = int(item2)

		except IndexError: return False
		else:
			if x+1 == y: return True
			else: return False

	def get_pos_char(self, pos):
		try: item = pos.split("@")[0]
		except IndexError:
			return None
		else:
			return item

	def consec_bigram(self, bigram1, bigram2):
		# If true, will ultimately result in the writing of a three-character string, 
		# where the first character = items_bigram1[0],
		# the second character = items_bigram2[0], and
		# the third character = items_bigram2[1]
		bigram1 = bigram1.replace("<", "+")
		bigram2 = bigram1.replace("<", "+")
		items_bigram1 = bigram1.split("+")
		items_bigram2 = bigram2.split("+")
		try: 
			b1 = items_bigram1[1]
			b2 = items_bigram2[0]
		except IndexError: return False
		else:
			if b1 == b2: return True
			else: return False

	# def consec_prec(self, prec1, prec2):
	# 	prec1 = prec1.replace("+", "<")
	# 	prec2 = prec1.replace("+", "<")
	# 	items_prec1 = prec1.split("<")
	# 	items_prec2 = prec2.split("<")
	# 	try: 
	# 		b1 = items_prec1[1]
	# 		b2 = items_prec2[0]
	# 	except IndexError: return False
	# 	else:
	# 		if b1 == b2: return True
	# 		else: return False

	def consec_pair(self, item1, item2):
		item1 = item1.replace("+", "<")
		item2 = item2.replace("+", "<")
		items1 = item1.split("<")
		items2 = item2.split("<")
		try: 
			b1 = items1[1]
			b2 = items2[0]
		except IndexError: return False
		else:
			if b1 == b2: return True
			else: return False

	def para_prec(self, prec1, prec2):
		# If true, will ultimately result in the writing of a single character,
		# namely items_prec1[1] (or items_prec2[1]).
		# Both prec1 and prec2 will have to be popped from the stack.
		##print "para_prec; ", "prec1 =", prec1, "; prec2 =", prec2
		items_prec1 = prec1.split("<")
		items_prec2 = prec2.split("<")
		try: 
			a1 = items_prec1[0]
			a2 = items_prec2[0]
		except IndexError: return False
		else:
			##print "A1 =", a1, "; A2 =", a2
			if a1 == a2:
				##print "    * * * * tRuE"
				return True
			else: return False

	def para_prec_suf(self, prec1, prec2):
		# If true, will ultimately result in the writing of a single character,
		# namely items_prec1[1] (or items_prec2[1]).
		# Both prec1 and prec2 will have to be popped from the stack.
		##print "para_prec_suf; ", "prec1 =", prec1, "; prec2 =", prec2
		items_prec1 = prec1.split("<")
		items_prec2 = prec2.split("<")
		try: 
			d1 = items_prec1[1]
			d2 = items_prec2[1]
		except IndexError: return False
		else:
			if d1 == d2: return True
			else: return False

	def search_consec_pos_pre(self, pos2):
		"""	Test if pos2 immediately succedes the preceding positional feature
		in the stack, i.e., if there is a preceding positional feature in the stack.
		In other words, see if pos2 has an immediate predecessor in the stack.
			Note:
			  self.pat_pos = ur"\@"
			  self.re_pos = re.compile(pat_pos, re.UNICODE)
		"""
		if self.re_pos.search(pos2) == False:
			return False
		for n in range(len(self.stack)):
			if self.re_pos.search(self.stack[n]):
				pos1 = self.stack[n]
				if self.consec_pos(pos1, pos2):
					return True
		return False

	def search_consec_pos_suf(self, pos2):
		""" See if pos2 (x@[-i]) has an immediate predecessor in the stack, i.e.,
		a feature y@[-j] such that -j+1 = -i (or i+1 < j).
		"""
		if self.re_pos.search(pos2) == False:
			##print "re_pos =", "FALSE"
			return False
		for pos1 in self.stack:
			if self.re_pos.search(pos1):
				if self.consec_pos_suf(pos1, pos2):
					return True
		return False

	def search_consec_pair(self, item2):
		##print "!!!!! SEARCHING CONSEC PAIR !!!!!", "(", "item2 =", item2, ")"
		item2_1 = item2.replace("+", "<")
		##print "item2_1 =", item2_1
		if self.re_seq.search(item2) == False:
			return False
		for n in range(len(self.stack)):
			##print "***", "stack item", n, "=", self.stack[n]
			if self.re_seq.search(self.stack[n]):
				item1 = self.stack[n]
				##print "    item1 =", item1
				item1_1 = item1.replace("+", "<")
				if self.consec_pair(item1_1, item2_1):
					##print "         M A T C H", " ", item1_1, item2_1
					for item in [item1, item2]:
						if item not in self.morph_elements:
							self.morph_elements.append(item)
					#self.stack.remove(item1)
					#char1 = item1.split("<")[0]
					#self.stack.insert(0, item2)
					#self.output += char1 + chars2and3
					return True
				elif self.consec_pair(item2_1, item1_1):
					##print "         M A T C H", ":", "item2_1 =", item2_1, "==", "item1_1 =", item1_1
					for item in [item1, item2]:
						if item not in self.morph_elements:
							self.morph_elements.append(item)
					#self.stack.remove(item1)
					#char1 = item1.split("<")[0]
					#self.stack.insert(0, item2)
					#self.output += char1 + chars2and3
					return True
		#self.stack.append(item2)
		return False

	def consec_pair_action(self, item2):
		char1 =  ""
		##print "WILL IT FAIL?"
		item2_1 = item2.replace("+", "<")
		if self.re_pos.search(item2_1):
			##print "FAIL"
			return "fail"
		chars2and3 = item2_1.split("<")[0] + item2_1.split("<")[1]
		##print "CPA; ITEM2 =", item2, "; ITEM2_1 =", item2_1 
		if not self.re_seq.search(item2_1): # == False:
			##print "NOT SEQ"
			return False
		for n in range(len(self.stack)):
			if self.re_seq.search(self.stack[n]):
				item1 = self.stack[n]
				##print "CPA; ***ITEM1 =", item1
				item1_1 = item1.replace("+", "<")
				if self.consec_pair(item1_1, item2_1):
					##print "^** CPA;", "MATCH:", "ITEM2_1 =", item2_1, ", ITEM1_1 =", item1_1, ", ITEM1 =", item1
					self.stack.remove(item1)
					char1 = item1_1.split("<")[0]
					#self.stack.insert(0, item2)
					##print "  * CPA; CHAR1 =", char1, "; CHARS2AND3=",chars2and3, "; OUTPUT =", self.output
					# if len(self.output) > 0:
					# 	if self.output[-1] == char1:
					# 		self.output += char1 + chars2and3
					# 	else: pass
					# else:
					# 	self.output += char1 + chars2and3
					###print "CPA; OUTPUT =", self.output
					return char1 + chars2and3
				elif self.consec_pair(item2_1, item1_1):
					##print "!!! CPA;", "MATCH:", "ITEM2_1 =", item2_1, ", ITEM1_1 =", item1_1, ", ITEM1 =", item1
					self.stack.remove(item1)
					char1 = item2_1.split("<")[0]
					chars2and3 = item1_1.split("<")[0] + item1_1.split("<")[1]
					#self.stack.insert(0, item2)
					##print "  ! CPA; CHAR1 =", char1, "; CHARS2AND3=",chars2and3, "; OUTPUT =", self.output
					# if len(self.output) > 0:
					# 	if self.output[-1] == char1:
					# 		self.output += char1 + chars2and3
					# 	else: pass
					# else:
					# 	self.output += char1 + chars2and3
					###print "CPA; OUTPUT =", self.output
					#print " CPA ^*^*^*^ R E T U R N ", char1 + chars2and3
					return char1 + chars2and3
				#else:
					#self.stack.append(item2)

	def remove_first_of_pair(self, item2):
		item2_1 = item2.replace("+", "<")
		chars2and3 = item2_1.split("<")[0] + item2_1.split("<")[1]
		for n in range(len(self.stack)):
			if self.re_seq.search(self.stack[n]):
				item1 = self.stack[n]
				item1_1 = item1.replace("+", "<")
				if self.consec_pair(item1_1, item2_1):
					self.stack.remove(item1)
					#item1_1 = item1.replace("+", "<")
					#char1 = item1_1.split("<")[0]
					#self.output += char1 + chars2and3

	def purge_all_pos_pre(self):
		n = 0
		##print "PPP", "; n =", n, "len stack =", len(self.stack)
		#while 1 == 1: #n < len(self.stack):
		while n < len(self.stack):
			if self.re_pos_pre.search(self.stack[n]):
				item1 = self.stack.pop(n)
				##print "PPP; STACK =", self.stack
				##print "  PPP > POPPING", self.stack.pop(n)
				##print "PP; POST-POP STACK =", self.stack, "n =", n
			else: n += 1
				##print "PPP", "n =", n, "; NOT POPPING", self.stack[n], "; STACK =", self.stack
				

	def purge_all_pos_suf(self):
		n = 0
		##print "PPS", "; n =", n, "len stack =", len(self.stack)
		#while 1 == 1: #n < len(self.stack):
		while n < len(self.stack):
			if self.re_pos_suf.search(self.stack[n]):
				#item1 = self.stack[n]
				##print "STACK =", self.stack
				self.stack.pop(n)
				##print "POST-POP STACK =", self.stack, "n =", n
			else:
				##print "PPS", "n =", n, "; NOT POPPING", self.stack[n], "; STACK =", self.stack
				n += 1

	def remove_pos_pre(self, item2):
	 	"""Remove from the stack all prefix positional features."""
		#item2_1 = item2.replace("+", "<")
		#chars2and3 = item2_1.split("<")[0] + item2_1.split("<")[1]
		n = 0
		##print "RPP", "; n =", n, len(self.stack)
		#while 1 == 1: #n < len(self.stack):
		while n < len(self.stack):
			if self.re_pos_pre.search(self.stack[n]):
				#item1 = self.stack[n]
				##print "STACK =", self.stack
				self.stack.pop(n)
				##print "POST-POP STACK =", self.stack, "n =", n
			else:
				##print "RPP", "n =", n, "; NOT POPPING", self.stack[n], "; STACK =", self.stack
				n += 1

	def remove_pos_suf(self, item2):
		"""Remove from the stack all suffix positional features."""
		#item2_1 = item2.replace("+", "<")
		#chars2and3 = item2_1.split("<")[0] + item2_1.split("<")[1]
		n = 0
		##print "RPS", "; n =", n, len(self.stack)
		#while 1 == 1: #n < len(self.stack):
		while n < len(self.stack):
			if self.re_pos_suf.search(self.stack[n]):
				#item1 = self.stack[n]
				##print "STACK =", self.stack
				self.stack.pop(n)
				##print "POST-POP STACK =", self.stack, "n =", n
			else:
				##print "RPS", "n =", n, "; NOT POPPING", self.stack[n], "; STACK =", self.stack
				n += 1


	def search_consec_prec(self, prec2):
		char1 =  ""
		#char2 = prec2.split("<")[0]
		chars2and3 = prec2.split("<")[0] + prec2.split("<")[1]
		##print "CHARS2AND3 =", chars2and3
		if self.re_prec.search(prec2) == False:
			return False
		for n in range(len(self.stack)):
			if self.re_prec.search(self.stack[n]):
				prec1 = self.stack[n]
				if self.consec_prec(prec1, prec2):
					# ##print "WELL, KISSY, IS IT?"
					# self.stack.remove(prec1)
					# char1 = prec1.split("<")[0]
					# #self.stack.insert(0, prec2)
					# self.output += char1 + chars2and3
					return True
		return False

	def search_consec_bigram(self, bi2):
		char1 =  ""
		#char2 = prec2.split("<")[0]
		chars2and3 = bi2.split("+")[0] + bi2.split("+")[1]
		##print "CHARS2AND3 =", chars2and3
		if self.re_bi.search(bi2) == False:
			return False
		for n in range(len(self.stack)):
			if self.re_bi.search(self.stack[n]):
				bi1 = self.stack[n]
				if self.consec_bigram(bi1, bi2):
					# ##print "WELL, KISSY, IS IT?"
					# self.stack.remove(prec1)
					# char1 = bi1.split("+")[0]
					# #self.stack.insert(0, prec2)
					# self.output += char1 + chars2and3
					return True
		return False

	def remove_para_prec(self, prec2):
		n = 0
		##print "REMOVE PARA PREC PRE"
		while n < len(self.stack):
		#for n in range(len(self.stack)):
			##print "REMOVE PARA PREC"
			##print "* * * *", "n =", n, "; STACK:", self.stack
			if self.re_prec.search(self.stack[n]):
				prec1 = self.stack[n]
				if self.para_prec(prec1, prec2):
					self.stack.pop(n)
					continue
			n += 1

	def remove_para_prec_suf(self, prec2):
		n = 0
		#while n < len(self.stack):
		##print "RPPS;", "prec2 =", prec2
		while self.search_para_prec_suf(prec2):
		#for n in range(len(self.stack)):
			##print "* * * *", "n =", n, "; STACK[", n, "]:", self.stack[n]
			if self.re_prec.search(self.stack[n]):
				prec1 = self.stack[n]
				if self.para_prec_suf(prec1, prec2):
					self.stack.remove(prec1)
					continue
			n += 1
	
	def search_para_prec(self, prec2):
		if self.re_prec.search(prec2) == False:
			return False
		for n in range(len(self.stack)):
			##print "* * * SPP", "; STACK[", n, "]:", self.stack[n], "; STACK =", self.stack
			if self.re_prec.search(self.stack[n]):
				prec1 = self.stack[n]
				if self.para_prec(prec1, prec2):
					return True
		return False
	
	def search_para_prec_suf(self, prec2):
		##print "SPPS;", "prec2 =", prec2
		if not self.re_prec.search(prec2):
			return False
		for prec1 in self.stack:
			##print "* * * SPPS", "; prec1 =", prec1, "; STACK =", self.stack
			###print prec1,
			if self.re_prec.search(prec1):
				##print "SPPS; ", "prec2", "YES!"
				if self.para_prec_suf(prec1, prec2):
					##print "     SPPS * * * * TT RR UU EE"
					return True
		return False

	def enqueu_suffix_feature(self, input_item):
		# if the feature is a suffix positional feature, i.e., of the form "a@[-1],"
		# and there are no more features to be read, we do not need to enqueu it; 
		# it will not be needed in the future.
		##print "ESF;", "input_item =", input_item, "; pos?", self.re_pos_suf.search(input_item) == True, "; len =", len(self.tape)
		if self.re_pos_suf.search(input_item) == True:
			##print "ESF;", "re_pos_suf.search(input_item) == True"
			if len(self.tape) == 0:
				##print "ESF;", "PASSING"
				pass 
			else:
				self.stack.append(input_item)
		else:
			self.stack.append(input_item)

	def expand_suffix(self, input_item):
		bigram_items = input_item.split("+")
		if bigram_items[0] == self.output[-1]:
			self.output += bigram_items[1]
		elif bigram_items[1] == self.output[-1]:
			try: string = self.output[:-1]
			except IndexError: string = ""
			last_char = self.output[-1]
			self.output = string + bigram_items[0] + last_char

	def expand_prefix(self, input_item):
		bigram_items = input_item.split("+")
		try: last_char = self.output[-1]
		except IndexError: last_char = ""
		try: first_char = self.output[-1]
		except IndexError: first_char = ""
		if bigram_items[0] == last_char:
			self.output += bigram_items[1]
		elif bigram_items[1] == first_char:
			self.output = bigram_items[0] + self.output

	def bigram_reprieve(self, input_item):
		bigram_items = input_item.split("+")
		if bigram_items[0] == self.output[-1]:
			return True
		elif bigram_items[1] == self.output[-1]:
			return True 
		else:
			return False

	def get_morph(self):
		##print "> self.get_morph()  THIS IS THE OUPUT:", self.output
		return self.output

	def get_used_features(self):
		used_features = list(self.original_tape)
		##print "original_features:", " ".join(used_features)
		##print "self.stack:", " ".join(self.stack)
		for item in self.stack:
			if item in self.original_tape:
				used_features.remove(item)
		##print "used_features:", " ".join(used_features)
		return used_features

	def get_remaining_input(self):
		##print "> self.get_remaining_input()"
		return self.stack

class PrefixPDA(PDA):
	def __init__(self, input_list):
		"""
			pat_pos_pre = ur"@\[[0-9]\]"
			pat_pos_suf = ur"@\[\-[0-9]\]"
			re_pos_pre = re.compile(pat_pos_pre, re.UNICODE)
			re_pos_suf = re.compile(pat_pos_suf, re.UNICODE)
		"""
		PDA.__init__(self, input_list)
		self.cursor = 0
		self.cur_state = "q0"
		self.tape = input_list
		##print self.tape

	def run_prefix_pda(self):
		""" States: q0, q1, q3, q4, q6
		Start state: q0;  End state = q6
		Transitions:
				q0		     q1            q3           q4           q6
		q0              x@[i]/x@[i]                            x@[-i]/x@[-i]
		Q1                             x@[i]/x@[i]             x@[i]/x@[i]    
		Q3          	
		"""
		##print "\nP R E F I X",
		##print "** TAPE **", self.tape, "; SELF.OUTPUT =", self.output, "STATE:", self.cur_state,
		while len(self.tape) > 0: #and self.cur_state != "q6":
			
			input_item = self.tape.pop(0)  #Each iteration removes an element from self.tape.
			#sys.stderr.write(input_item + "\n")
			##print u"STATE:", self.cur_state, u"; input_item:", input_item, u"; TAPE:", self.tape, u"; SELF.OUTPUT:", self.output
			#is_pos = False
			if self.re_pos_suf.search(input_item) and self.cur_state != "q6":
				#self.cur_state = "q7"
				if self.cur_state == "q0":
					self.stack.append(input_item)
					self.cur_state = "q6"
					##print u"I'm HEEEERE!", u"; STACK =", self.stack
				elif self.cur_state == "q1":
					#self.remove_pos_pre(input_item)
					self.stack.append(input_item)
					self.cur_state = "q6"
					##print u"I'm HEEEERE!", u"; STACK =", self.stack
				continue
			if self.re_pos_pre.search(input_item): #
			# and self.cur_state != "q6":
				#is_pos = True
				if self.cur_state == "q0": # and len(self.stack) == 0: #not self.search_consec_pos_pre(input_item):
					#self.stack.insert(0, input_item)
					self.stack.append(input_item)
					self.output += self.get_pos_char(input_item)
					#self.output = "--------"
					self.cur_state = "q1"
					##print u"STACK =", self.stack
				elif self.cur_state == "q1":
					##print "**************"
					if self.search_consec_pos_pre(input_item):
						##print "$ cur_state:", self.cur_state, "; input_item:", input_item, ";", self.search_consec_pos_pre(input_item) == True
						#self.stack.insert(0, input_item)
						self.stack.append(input_item)
						self.output += self.get_pos_char(input_item)
						self.cur_state = "q3"
						##print ">>> STACK =", self.stack, "; OUTPUT =", self.output
						# Remove from the stack all prefix positional features
						self.remove_pos_pre(input_item)
						##print "&&& STACK =", self.stack
					elif not self.search_consec_pos_pre(input_item):
						##print "*-*", self.cur_state, "; input_item:", input_item, "; consec?:", self.search_consec_pos_pre(input_item) == True
						#self.stack.insert(0, input_item)
						self.stack.append(input_item)
						#self.output += self.get_pos_char(input_item)
						#self.cur_state = "q2"
						self.cur_state = "q6"
						##print ">*> STACK =", self.stack, "; OUTPUT =", self.output
						#self.remove_pos_pre(input_item)
						###print "&*& STACK =", self.stack
				else:
					self.stack.append(input_item)
					self.cur_state = "q6"
				# elif self.cur_state == "q2" and not self.search_consec_pos_pre(input_item):
				# 	##print "***", self.cur_state, self.search_consec_pos_pre(input_item) == True
				# 	#self.stack.pop(0)
				# 	self.cur_state = "q2"
				# 	#self.stack.insert(0, input_item)
				# 	self.stack.append(input_item)
				# 	self.remove_pos_pre(input_item)
				# 	##print "STACK =", self.stack
				# else:
				# 	self.cur_state = "q6"
				# 	if self.re_pos_pre.search(input_item):
				# 		self.cur_state = "q0"
				# 	##print "666 STACK =", self.stack, "; OUTPUT =", self.output
				# 	self.remove_pos_pre(input_item)
				# 	##print "&*& STACK =", self.stack
			elif self.re_prec.search(input_item): # and self.cur_state != "q6":
				# Here we encounter a precedence feature for the first time.
				# We thus remove all prefix positional features from the stack.
				# The era of prefix positional features has passed.
				self.purge_all_pos_pre()
				if self.cur_state == "q0": # and len(self.stack) == 0:
					self.cur_state = "q1"
					##print "re_prec", self.cur_state, self.search_consec_pos_pre(input_item) == True
					#self.stack.insert(0, input_item)
					self.stack.append(input_item) # save precedence feature for later, for the 
					# stem-component PDA.
					##print "post-purge STACK =", self.stack
				# elif self.cur_state == "q1":
				# 	##print "Khj"
				# 	self.remove_pos_pre(input_item)	
				# 	self.stack.append(input_item)
				# 	self.cur_state = "q3"
				# elif self.cur_state == "q2":
				# 	##print "---", self.cur_state, self.search_consec_pos_pre(input_item) == True
				# 	self.cur_state = "q6"
				# 	self.remove_pos_pre(input_item)
				# 	#self.stack.insert(0, input_item)	
				# 	self.stack.append(input_item)
				# 	##print "STACK =", self.stack
				elif self.cur_state == "q1":
					###print "S  T  A  T  E   =   Q  3      *  *  *  *  *"
					if self.search_para_prec(input_item): 
						# if True, we know that there currently exists a precedence feature in the stack
						# that can merge with input_item.
						##print " %$#$ search_para_prec(input_item) =  T R U E"
						#self.stack.insert(0, input_item)
						#self.stack.append(input_item)
						self.output += input_item.split("<")[0]
						self.remove_para_prec(input_item)
						self.cur_state = "q3"
						##print "STACK =", self.stack, "; state =", self.cur_state 
					else:
						#self.stack.insert(0, input_item)
						#self.output += input_item.split("<")[0]
						#self.remove_para_prec(input_item)
						self.stack.append(input_item)
						self.cur_state = "q3"
						##print "STACK =", self.stack, "; state =", self.cur_state

				elif self.cur_state == "q6":
					self.stack.append(input_item)
					self.cur_state = "q6"
			elif self.re_bi.search(input_item): #and self.cur_state != "q6":
				# if self.cur_state == "q4":
				# 	self.stack.insert(0, input_item)
				# 	self.output += input_item.split("+")[0]
				# 	self.cur_state = "q5"
				self.purge_all_pos_pre()
				if self.cur_state == "q3":
					if self.search_consec_bigram(input_item):
						##print "bigram; post-purge STATE", self.cur_state
						#self.stack.insert(0, input_item)
						self.stack.append(input_item)
						self.expand_prefix(input_item)
						##print "XXXXXXXXXXX", "OUTPUT =", self.output
					# bigram_items = input_item.split("+")
					# try: last_char = self.output[-1]
					# except IndexError: last_char = ""
					# try: first_char = self.output[-1]
					# except IndexError: first_char = ""
					# if bigram_items[0] == last_char:
					# 	self.output += bigram_items[1]
					# elif bigram_items[1] == first_char:
					# 	self.output = bigram_items[0] + self.output
						# try: string = self.output[:-1]
						# except IndexError: string = ""
						# last_char = self.output[-1]
						# self.output = bigram_items[0] + last_char
					###print "AT Q4 SUFFIX. GOING TO Q5",
					###print "; STACK =", self.stack
						self.cur_state = "q4"
					#self.search_consec_bigram(input_item):
					else:
						#self.stack.insert(0, input_item)
						self.stack.append(input_item)
						# self.remove_first_of_pair(input_item)
						# self.output += input_item.spit("+")[1]
						# self.cur_state = "q4"
						self.cur_state = "q4"
				elif self.cur_state == "q4":
					if self.search_consec_bigram(input_item):
						#self.stack.pop(0)
						self.cur_state = "q4"
						#self.stack.insert(0, input_item)
						self.expand_prefix(input_item)
						#self.stack.append(input_item)
					else:
						self.stack.append(input_item)
						self.cur_state = "q4"
				elif self.cur_state == "q6":
					self.stack.append(input_item)
					self.cur_state = "q6"
			# elif self.cur_state == "q7":
			# 	##print "&&&&&& 777777777"
			# 	self.cur_state = "q6"
			# 	self.remove_pos_pre(input_item)
			# 	#self.stack.insert(0, input_item)	
			# 	self.stack.append(input_item)
			elif self.cur_state == "q6":
				##print "*** cur_state =", self.cur_state, "; input_item =", input_item, "; tape:", self.tape, "; stack:", self.stack
				self.purge_all_pos_pre()
				self.cur_state = "q6"
				#self.stack.insert(0, input_item)
				self.stack.append(input_item)


			##print "\n^^ TRANSITION; cur_state =", self.cur_state, "; input_item =", input_item, "; tape:", self.tape, "; stack:", self.stack, "; output:", self.output, "^^\n"

	def get_morph(self):
		"""This method just returns whatever has accumulated in self.output"""
		if len(self.output) > 0:
			self.output += "+"
			temp = self.output 
			self.output = "aa&" + temp
		return self.output
				


class StemComponentPDA(PDA):
	def __init__(self, input_list):
		PDA.__init__(self, input_list)
		self.cursor = 0
		self.cur_state = "q0"
		self.tape = input_list
		self.morph_elements = []

	def run_stem_pda(self):
		##print "run   S  T  E  M   pda"
		while len(self.tape) > 0:
			# *****************************************************
			input_item = self.tape.pop(0)
			# *****************************************************
			##print "tape =", self.tape, ";RI =", input_item, "; STACK/STEM:", self.stack, "* STATE =", self.cur_state
			###print "IN STEM *** TAPE =", self.tape, "; input_item =", input_item
			if self.re_pos.search(input_item) and self.cur_state != "q6":
				###print "G O  T O  Q 6   STEM"
				#self.stack.insert(0,input_item)
				self.stack.append(input_item)
				self.cur_state = "q6"
			#elif not self.re_pos.search(input_item): #and self.cur_state != "q6":
			elif self.re_pos.search(input_item) == None:
				##print "RI = ** =", input_item
				#if self.cur_state == "q6":
				if self.cur_state == "q0" or self.cur_state == "q6":
					#self.stack.insert(0, input_item)
					self.stack.append(input_item)
					self.cur_state = "q1"
				#elif self.cur_state == "q1": # and 
				elif self.cur_state == "q1":
					###print "ELSE, ELSE, ELSE"
					if self.search_consec_pair(input_item):
						##print "  % RAW_INPUT =",input_item
						triple = self.consec_pair_action(input_item)
						##print "  %% TRIPLE =", triple
						# if len(self.output) > 0:
						# 	##print "  TRIPLE =", triple
						# 	if self.output[-1] == triple[0]: self.output += triple
						# 	else: pass
						# else: self.output += triple

						if 0 < len(self.output) < 3:
							if self.output[-1] == triple[0]:
								##print "; OUTPUT =", self.output, "; TRIPLE =", triple,
								self.output += char1 + chars2and3
							else: pass
							##print "&& STACK =", self.stack
							#self.cur_state = "q6"
						elif len(self.output) == 0:
							self.output += triple
							##print "&- STACK =", self.stack
							#self.cur_state = "q6"
						else:
							##print "O   H     N   O    !   !   !   !", "  STACK =", self.stack
							self.stack.append(input_item)
							##print "   ^   ^   STACK =", self.stack
							self.cur_state = "q6"
						##print "CPA; OUTPUT =", self.output
						##print "; STATE =", self.cur_state, "-->", 
						self.cur_state = "q1"
						##print self.cur_state
					else:
						#triple = self.consec_pair_action(input_item)
						###print "  %% TRIPLE =", triple
						self.cur_state = "q1"
						self.stack.append(input_item)
					# else:
					# 	##print "  %% RAW_INPUT =", input_item, "; STATE =", self.cur_state, "-->", 
					# 	##print "     ", self.stack
					# 	#self.stack.insert(0,input_item)
					# 	self.stack.append(input_item)
					# 	##print "    *", self.stack
					# 	self.cur_state = "q1"
				# elif self.cur_state == "q1" and not self.search_consec_pair(input_item):
				# 	#self.cur_state = "q3"
				# 	##print "  % STATE =", self.cur_state, "-->", 
					#self.stack.insert(0, input_item)
					###print "CUR_STATE =", self.cur_state
			# elif self.cur_state == "q6" and not self.re_pos.search(input_item):
			# 	#self.stack.insert(0,input_item)
			# 	#self.stack.append(input_item)
			# 	##print "  % RAW_INPUT =",input_item
			# 	triple = self.consec_pair_action(input_item)
			# 	##print "  %% TRIPLE =", triple
			# 	# if len(self.output) > 0:
			# 	# 	##print "  TRIPLE =", triple
			# 	# 	if self.output[-1] == triple[0]: self.output += triple
			# 	# 	else: pass
			# 	# else: self.output += triple

			# 	if 0 < len(self.output) < 3:
			# 		if self.output[-1] == triple[0]:
			# 			##print "; OUTPUT =", self.output, "; TRIPLE =", triple,
			# 			self.output += char1 + chars2and3
			# 		else: pass
			# 		##print "&& STACK =", self.stack
			# 		self.cur_state = "q6"
			# 	elif len(self.output) == 0:
			# 		self.output += triple
			# 		##print "&- STACK =", self.stack
			# 		self.cur_state = "q6"
			# 	else:
			# 		##print "O   H     N   O    !   !   !   !", "  STACK =", self.stack
			# 		self.stack.append(input_item)
			# 		##print "   ^   ^   STACK =", self.stack
			# 		self.cur_state = "q6"
			# 	self.cur_state = "q6"
			else:
				self.stack.append(input_item)
				self.cur_state = "q6"


class SuffixPDA(PDA):
	def __init__(self, input_list):
		PDA.__init__(self, input_list)
		self.cur_state = "q0"
		##print "\n\n", "INIT SUFFIX . . . . ", "  STATE =", self.cur_state
		self.cursor = 0
		self.cur_state = "q0"
		##print "TAPE =", self.tape
		self.output = ""


	def run_suffix_pda(self):
		while len(self.tape) > 0: #and self.cur_state != "q6":
			input_item = self.tape.pop(0)
			##print "input_item =", input_item
			#is_pos = False
			if self.re_pos_suf.search(input_item): # and self.cur_state != "q6":
				#is_pos = True
				#self.output += self.get_pos_char(input_item)
				# if self.cur_state == "q0" and len(self.tape) == 0:
				# 	# in this case, the tape is at its end, and we don't need to anticipate additional chars.
				# 	# we therefore go to state q6 after appending the current char to the output.
				# 	##print "^ % &", "; Output =", self.output, "; Stack =", self.stack, "; State =", self.cur_state, "-->",
				# 	self.cur_state = "q6"
				# 	##print self.cur_state
				# elif self.cur_state == "q0" and len(self.tape) > 0:
				# 	##print "$$0", self.cur_state, self.search_consec_pos_suf(input_item) == True
				# 	# in this case, we need to keep a look-out for additional characters. We therefore go to state q1.
				# 	#self.output = self.get_pos_char(input_item) + self.output
				# 	self.stack.append(input_item)
				# 	##print "- - &", "; Output =", self.output, "; State =", self.cur_state
				# 	self.cur_state = "q1"
				# 	##print "STACK =", self.stack
				if self.cur_state == "q0":
					self.output += self.get_pos_char(input_item) #+ self.output
					self.enqueu_suffix_feature(input_item)
					##print "^ % &", "; Output =", self.output, "; Stack =", self.stack, "; State =", self.cur_state, "-->",
					self.cur_state = "q1"
					##print self.cur_state
				elif self.cur_state == "q1":
					if self.search_consec_pos_suf(input_item):
						self.output += self.get_pos_char(input_item)
						# dequeu the feature representing the preceding position
						self.remove_pos_suf(input_item)
						##print "> Q1 M >> STACK =", self.stack, "; OUTPUT =", self.output, "; STATE =", self.cur_state, "-->",
						self.cur_state = "q1"
						##print self.cur_state
					elif not self.search_consec_pos_suf(input_item):
						#self.enqueu_suffix_feature(input_item)
						self.purge_all_pos_suf()
						self.enqueu_suffix_feature(input_item)
						##print "> Q1 NM >> STACK =", self.stack, "; OUTPUT =", self.output, "; STATE =", self.cur_state, "-->",
						#if len(self.tape) == 0:
						self.cur_state = "q6"
						#else:
						#self.cur_state = "q0"
						##print self.cur_state
					# dequeu the feature representing the preceding position
				else:
					self.cur_state = "q6"
					self.enqueu_suffix_feature(input_item)
				# elif self.cur_state == "q1" and len(self.tape) == 0:
				# 	##print "$$1", self.cur_state, self.search_consec_pos_suf(input_item) == True
				# 	if self.search_consec_pos_suf(input_item):
				# 		self.output += self.get_pos_char(input_item) 
				# 		##print "> Q1 M =0 >> STACK =", self.stack, "; OUTPUT =", self.output, "; STATE =", self.cur_state
				# 		self.remove_pos_suf(input_item)
				# 		  # Why go to state q2 here?
				# 		self.cur_state == "q6"
				# 	elif not self.search_consec_pos_suf(input_item):
				# 	 	self.remove_pos_suf(input_item)
				# 	# 	##print "> Q1 NM =0 >> STACK =", self.stack, "; OUTPUT =", self.output, "; STATE =", self.cur_state
				# 		#self.cur_state == "q6"
				# 		self.stack.append(input_item)
				# 		self.cur_state = "q6"
				# elif self.cur_state == "q1" and len(self.tape) > 0:
				# 	##print "anticipating", "$$2.5"
				# 	##print "O U T P U T  0 : ", self.output
				# 	if self.search_consec_pos_suf(input_item):
				# 		###print "O U T P U T 1 : ", self.output
				# 		##print "$$2.5", self.cur_state, self.search_consec_pos_suf(input_item) == True
				# 		##print "O U T P U T  1 : ", self.output
				# 		self.remove_pos_suf(input_item)
				# 		self.output += self.get_pos_char(input_item) 
				# 		##print "> Q1 M >0 >> STACK =", self.stack, "; OUTPUT =", self.output, "; STATE =", self.cur_state
				# 		self.cur_state = "q1"
				# 		self.stack.append(input_item)
				
				# 		##print "&&& STACK =", self.stack
					# elif not self.search_consec_pos_suf(input_item):
					# 	self.remove_pos_suf(input_item)
					# 	#self.purge_all_pos_suf()
					# 	##print "> Q1 NM >0 >> STACK =", self.stack, "; OUTPUT =", self.output, "; STATE =", self.cur_state
					# 	##print "&&& STACK =", self.stack
					# 	self.cur_state = "q6"
				# elif self.cur_state == "q3":
				# 	self.stack.append(input_item)
				# 	self.output += input_item.split("@")[0]
				# 	self.cur_state = "q6"
				# elif self.cur_state == "q6":
				# 	self.enqueu_suffix_feature(input_item)
				# 	#self.stack.append(input_item)
				# 	##print "6 6 &", "; Output =", self.output, "; Stack =", self.stack, "; State =", self.cur_state, "-->"
				# 	if len(self.tape) == 0:
				# 		self.purge_all_pos_suf()
				# 	##print "^ % &", "; Output =", self.output, "; Stack =", self.stack, "; State =", self.cur_state, "-->",
				# 	self.cur_state = "q6"
				# 	##print self.cur_state
			elif self.re_prec.search(input_item):
				#self.enqueu_suffix_feature(input_item)
				#self.stack.append(input_item)
				##print "6 7 &", "; Output =", self.output, "; Stack =", self.stack, "; State =", self.cur_state
				##print "PURGING POS..."
				self.purge_all_pos_suf()
				##print "^ 7.5 &", "; Output =", self.output, "; Stack =", self.stack, "; State =", self.cur_state, "-->",
				#self.cur_state = "q6"
				##print self.cur_state
				if self.cur_state == "q0":
					self.enqueu_suffix_feature(input_item)
					##print "STATE =", self.cur_state, "; STACK =", self.stack
					self.cur_state = "q1"
				elif self.cur_state == "q1":
					#self.enqueu_suffix_feature(input_item)
					if self.search_para_prec_suf(input_item):
						self.output += input_item.split("<")[1] + self.output 
						self.remove_para_prec_suf(input_item)
						##print "^ 7.6 &", "; Output =", self.output, "; Stack =", self.stack, "; State =", self.cur_state, "-->",
						self.cur_state = "q3"
						##print self.cur_state
					elif not self.search_para_prec_suf(input_item):
						self.enqueu_suffix_feature(input_item)
						##print "^ 7.75 &", "; Output =", self.output, "; Stack =", self.stack, "; State =", self.cur_state, "-->",
						self.cur_state = "q6"
						##print self.cur_state
				elif self.cur_state == "q6":
					self.enqueu_suffix_feature(input_item)
					##print "^ 7.8 &", "; Output =", self.output, "; Stack =", self.stack, "; State =", self.cur_state, "-->",
					self.cur_state = "q6"
					##print self.cur_state 
				#else:
					#self.cur_state ==  "q6":
					#self.enqueu_suffix_feature(input_item)

			# elif self.re_prec.search(input_item):
			# 	if self.cur_state == "q0":
			# 		#self.enqueu_suffix_feature(input_item)
			# 		self.stack.append(input_item)
			# 		self.cur_state = "q3"
			# 		##print "STATE =", self.cur_state, "; STACK =", self.stack
			# 	elif self.cur_state == "q3" and self.search_para_prec_suf(input_item):
			# 		#self.stack.insert(0, input_item)
			# 		self.output = input_item.split("<")[1] + self.output 
			# 		self.remove_para_prec_suf(input_item)
			# 		#self.stack.insert(0, input_item)
			# 		self.stack.append(input_item)
			# 		self.cur_state = "q4"
			# 		##print "STATE =", self.cur_state, "; STACK =", self.stack
			# 	elif self.cur_state == "q4":
			# 		#self.stack.pop()
			# 		self.remove_para_prec_suf(input_item)
			# 		self.cur_state = "q6"
			# 	elif self.cur_state == "q6":
			# 		self.cur_state = "q6"
			# 		#self.stack.insert(0, input_item)	
			# 		self.stack.append(input_item)
			# 		#self.purge_all_pos_suf()
			# 		##print "STATE =", self.cur_state, "; STACK =", self.stack
			elif self.re_bi.search(input_item):
				#self.enqueu_suffix_feature(input_item)
				#self.stack.append(input_item)
				##print "6 8 &", "; Output =", self.output, "; Stack =", self.stack, "; State =", self.cur_state
				##print "PURGING POS..."
				self.purge_all_pos_suf()
				##print "^ % &", "; Output =", self.output, "; Stack =", self.stack, "; State =", self.cur_state, "-->",
				#self.cur_state = "q6"
				##print self.cur_state
				if self.cur_state == "q3":
					#self.enqueu_suffix_feature(input_item)
					#if self.search_consec_bigram(input_item):
					if self.bigram_reprieve(input_item):
						##print "BI REP = TRUE !!!"
						self.expand_suffix(input_item)
						self.cur_state = "q4"
				elif self.cur_state == "q4":
					self.enqueu_suffix_feature(input_item)
					if self.search_consec_bigram(input_item):
						self.expand_suffix(input_item)
						self.cur_state = "q4"
					elif not self.search_consec_bigram(input_item):
						self.cur_state = "q6"

			# elif self.re_bi.search(input_item): # and self.cur_state != "q6":
			# 	if self.cur_state == "q4":
			# 		self.stack.insert(0, input_item)
			# 		bigram_items = input_item.split("+")
			# 		if bigram_items[0] == self.output[-1]:
			# 			self.output += bigram_items[1]
			# 		elif bigram_items[1] == self.output[-1]:
			# 			try: string = self.output[:-1]
			# 			except IndexError: string = ""
			# 			last_char = self.output[-1]
			# 			self.output = string + bigram_items[0] + last_char
			# 		##print "AT Q4 SUFFIX. GOING TO Q5",
			# 		##print "; STACK =", self.stack
			# 		self.cur_state = "q5"
			# 	elif self.cur_state == "q5" and self.search_consec_bigram(input_item):
			# 		self.remove_first_of_pair(input_item)
			# 		#self.stack.insert(0, input_item)
			# 		self.stack.append(input_item)
			# 		##print "AT Q5 SUFFIX"
			# 		self.output = input_item.spit("+")[1] + self.output
			# 		self.cur_state = "q5"
			# 	else:
			# 		#self.stack.pop(0)
			# 		self.cur_state = "q6"
			# 		#self.stack.insert(0, input_item)
			# 		self.stack.append(input_item)
			# elif self.cur_state == "q6":
			# 	self.cur_state = "q6"
			# 	#if len(self.tape) > 0:
			# 		#self.stack.insert(0, input_item)
			# 	#self.stack.append(input_item)
			# 	self.purge_all_pos_suf()
				# 	self.purge_all_pos_suf()
				# else:
				# 	self.purge_all_pos_suf()

			# if len(self.output) > 0:
			# 	self.output = "-" + self.output
			##print "\n^^ TRANSITION; cur_state =", self.cur_state, "; input_item =", input_item, "; tape:", self.tape, "; stack:", self.stack, "; output:", self.output, "^^\n"
	
	def get_morph(self):
		if len(self.output) > 0:
			self.output = "zz&" + self.output
		return self.output


def main(filename):
	morph_dict = {}
	morphs = []
	prefixes = []
	remaining_input = []
	active_feature_lists = acf.get_active_features(filename)
	for i in range(len(active_feature_lists)):
		print str(i) + ". ", " ".join(active_feature_lists[i])
	#print "active_feature_lists:", active_feature_lists
	#centroids = acf.get_active_features_and_values(filename)
	#centroids_featuresAndValues = centroids.items()
	centroids_featuresAndValues = acf.get_active_features_and_values(filename)

	temp_feature_list = ["a<d", "a<e", "d<h", "a+b", "b+c", "m@[-1]"]
	tfl2 = ["d<b", "a<b", "b<c", "b<d", "d<c", "m@[-1]"]
	tfl3 = ["t@[0]", "i@[1]", "a<c", "e<d", "a<d", "m@[-1]"]
	tfl4 = ["t@[0]", "i@[1]", "a<e", "e<d", "a<d", "i@[-2]", "m@[-1]"]
	tfl5 = ["i@[-3]", "i@[-2]", "m@[-1]"]
	tfl6 = ["d@[-4]", "i@[-3]", "i@[-2]", "m@[-1]"]
	tfl7 = ["t@[0]", "d@[-4]", "i@[-3]", "i@[-2]", "i+m"]
	tfl8 = ["t@[0]", "i@[1]", "d@[-4]", "i@[-3]", "i@[-2]", "i+m"]
	tfl9 = ["b<i", "a<i", "i+m"]
	tfl9 = ["b<m", "a<m", "i+m"]
	tfl10 = ["b<i", "b<m", "i+m"]
	tfl11 = ["b<u", "b<m", "b+i"]
	tfl12 = ["b<u", "b<m", "i+b"]
	tfl13 = ["t@[0]", "i@[1]", "b<m", "i+b"]
	tfl14 = ["a<b", "b<d", "a<c", "a<d", "i+c"]
	tfl15 = ["a+b", "b<d", "a<c", "a<d", "i+c"]
	tfl16 = ["b<d", "a<c", "a<d", "a+b", "i+c"]
	tfl17 = ["b<d", "a<j", "h<d", "a+b", "i+c"]
	tfl18 = ["b<d", "a<j", "h<d", "a+b", "d+c"]
	tfl19 = ["b<d", "a<j", "h<d", "a+b", "d+c"]
	#active_feature_lists = [["b<d", "a<j", "h<d", "a+b", "d+c"], 
							# ["d@[-4]", "i@[-3]", "i@[-2]", "m@[-1]"], 
							# ["b<i", "a<i", "i+m", "t@[-1]"]]
	#active_feature_lists = [["a<j", "h<d", "a+b", "d+c"], 
							#["d@[-4]", "i@[0]", "i@[-2]", "m@[-1]"], 
							#["b<i", "a<i", "i+m", "i@[-2]", "t@[-1]"]]
	myFeatureLists = FeatureLists(active_feature_lists)
	input_lists = myFeatureLists.sorted_features()
	#print "INPUT_LISTS:", input_lists
	#for input_list in input_lists:
		#sys.stderr.write(str(input_list) + "\n")
	# The above code sets up the input "tapes," as it were.
	#######################################################################
	#######################################################################
	#######################################################################
	morph_lists = []
	words_and_clusterIDs = {}
	#input_list = tfl19
	#input_list = active_feature_lists
	used_symbols = []
	#for i in range(len(input_lists[i])):
	for i in range(len(input_lists)):
		##print input_lists[i]
		###print "MORPHS =", morphs
		#old_input_list = []
		counter = 0
		cycle_max = 3
		morphs = []
		avg_feature_values = []
		remaining = input_lists[i]
		while counter < cycle_max: #len(input_lists[i]):

			##print "\n<<   N  E  W    C  Y  C  L  E   >>\n"
			##print "MORPHS =", morphs, "; COUNTER =", counter, "; len =" , len(input_lists[i]), "; tape =", input_lists[i]
			###print"length =", len(new_morph)
			#prefixPDA = PrefixPDA(input_lists[i])
			prefixPDA = PrefixPDA(remaining)
			###print isinstance(prefixPDA, PDA)
			###print isinstance(prefixPDA, PrefixPDA)
			prefixPDA.run_prefix_pda()
			new_morph = prefixPDA.get_morph()
			#print "NEW_MORPH =", new_morph, "; length =", len(new_morph)
			###print "\n  N   E   W\n"
			#old_input_list = input_lists[i]
			#input_lists[i] = prefixPDA.get_remaining_input()
			remaining = prefixPDA.get_remaining_input()

			##print "REMAINING: ", " ".join(remaining)
			#######
			#used_features = []
			#used_features_list = []
			#used_symbols = list(prefixPDA.get_used_features())
			#used_symbols = prefixPDA.get_used_features()
			used_features = prefixPDA.get_used_features()
			#sys.stderr.write("USED_SYMBOLS: ")
			##print used_symbols
			#"Symbols," which are based on features, will each be unique, since each feature is unique.
			#used_symbols.extend(list(set(old_input_list)-set(input_lists[i])))
			# for symbol in used_symbols:
			# 	used_features.append(myFeatureLists.decode_symbol(symbol))
			#used_symbols = list(prefixPDA.get_used_features())
			#sys.stderr.write("USED_FEATURES: ")	
			##print used_features
			sum_value = 0.0
			#for feature in used_symbols:
			for feature in used_features:
				 #sum_value += centroids[str(i)][feature]
				 #sys.stderr.write("Fs_and_Vs: ")
				 ##print float(centroids_featuresAndValues[i][feature])
				 #feature_and_value = centroids_featuresAndValues[i]
				 #value = feature_and_values.split("//")[1]
				 value = float(centroids_featuresAndValues[i][feature])
				 sum_value += value
				 #sum_value += centroids_featuresAndValues[i][feature]
			#avg_feature_values.append((sum_value/float(len(used_features)), new_morph))
			#######
			#feature_value_pairs = avg_feature_values.get_items()
			#sorted_pairs = sorted(feature_value_pairs, key = lambda pair: pair[1])
			#strongest_feature = sorted_pairs[-1][0], lambda = student: student[1]
			###print "  NEW_MORPH =", new_morph, "; length =", len(new_morph)
			###print "> prefix > INPUT LIST =", input_lists[i]
			# try: avg_val = sum_value/float(len(used_features))
			# except ZeroDivisionError: pass #avg_val = 0.0
			# avg_feature_values.append((avg_val, new_morph))
			# #avg_feature_values.append((sum_value/float(len(used_symbols)), new_morph))
			# morphs.append(new_morph)
			###print "> stem >> MORPHS =", morphs
			if len(new_morph) > 0 and new_morph not in morphs:
			#if new_morph not in morphs:
				#avg_feature_values.append((sum_value/float(len(used_features)), new_morph))
			# 	try: avg_val = sum_value/float(len(used_symbols))
				try: avg_val = sum_value/float(len(used_features))
				except ZeroDivisionError: pass #avg_val = 0.0
				else:
					avg_feature_values.append((avg_val, new_morph))
					morphs.append(new_morph)
			# 	##print ">", counter, "> prefix > MORPHS =", morphs, "; COUNTER =", counter
			# 	###print "\n"
			# else: 
			# 	###print "I'll pass"
			# 	pass
				#break
			###print "COUNTER =", counter, "-->",
			counter += 1
			###print "COUNTER =", counter
			###print counter
		
		counter = 0
		while counter < cycle_max:
			##print "\n## STEM;", input_lists[i]
			##print "###", counter
			#stemPDA = StemComponentPDA(input_lists[i])
			stemPDA = StemComponentPDA(remaining)
			stemPDA.run_stem_pda()
			###print isinstance(stemPDA, PDA)
			###print isinstance(stemPDA, StemComponentPDA)
			new_morph = stemPDA.get_morph()
			#print " NEW_MORPH =", new_morph, "; length =", len(new_morph)
			#if new_morph in morphs: break
			#input_lists[i] = stemPDA.get_remaining_input()
			remaining = stemPDA.get_remaining_input()
			#######
			used_features = []
			# used_symbols = list(stemPDA.get_used_features())
			used_features = stemPDA.get_used_features()
			#sys.stderr.write("USED_SYMBOLS: ")
			##print used_symbols
			#"Symbols," which are based on features, will each be unique, since each feature is unique.
			#used_symbols.extend(list(set(old_input_list)-set(input_lists[i])))
			# for symbol in used_symbols:
			# 	used_features.append(myFeatureLists.decode_symbol(symbol))
			
			sum_value = 0.0
			# for feature in used_features:
			# 	 #sum_value += centroids[str(i)][feature]
			# 	 #sum_value += centroids_featuresAndValues[i][feature]
			# 	 #sys.stderr.write(" ".join(centroids_featuresAndValues[i]) + "\n")
			# 	 # feature_and_value = centroids_featuresAndValues[i]
			# 	 # value = feature_and_value.split("//")[1]
			# 	 # sum_value += value
			# 	 value = centroids_featuresAndValues[i][feature]
			# 	 sum_value += value
			for feature in used_features:
				 #sum_value += centroids[str(i)][feature]
				 #sys.stderr.write("Fs_and_Vs: ")
				 ##print float(centroids_featuresAndValues[i][feature])
				 #feature_and_value = centroids_featuresAndValues[i]
				 #value = feature_and_values.split("//")[1]
				 value = float(centroids_featuresAndValues[i][feature])
				 sum_value += value	 
			#avg_feature_values.append((sum_value/float(len(used_features)), new_morph))
			#######
			###print ">", counter, "> stem >> INPUT LIST =", input_lists[i]
			# if len(new_morph) == 0: break
			# if new_morph not in morphs:
			if len(new_morph) > 0 and new_morph not in morphs:
				#avg_feature_values.append((sum_value/float(len(used_features)), new_morph))
				try: avg_val = sum_value/float(len(used_features))
				except ZeroDivisionError: pass #avg_val = 0.0
				else:
					avg_feature_values.append((avg_val, new_morph))
					#avg_feature_values.append((sum_value/float(len(used_symbols)), new_morph))
					morphs.append(new_morph)
			###print "> stem >> MORPHS =", morphs
			#else: pass
			# if len(new_morph) > 0 and new_morph not in morphs:
			# 	#avg_feature_values.append((sum_value/float(len(used_features)), new_morph))
			# 	try: avg_val = sum_value/float(len(used_symbols))
			# 	except ZeroDivisionError: avg_val = 0.0
			# 	avg_feature_values.append((avg_val, new_morph))
			# 	#avg_feature_values.append((sum_value/float(len(used_symbols)), new_morph))
			# 	morphs.append(new_morph)
			# 	##print "> stem >> MORPHS =", morphs
			# else: pass
			###print "CTR =", counter, "-->",
			###print "MORPHS =", morphs
			counter += 1
			##print counter
		
		counter = 0
		while counter < cycle_max:
			##print "\n## SUFFIX;", input_lists[i]
			##print "###", counter
			#suffixPDA = SuffixPDA(input_lists[i])
			suffixPDA = SuffixPDA(remaining)
			suffixPDA.run_suffix_pda()
			###print isinstance(suffixPDA, PDA)
			###print isinstance(suffixPDA, SuffixPDA)
			new_morph = suffixPDA.get_morph()
			#print "new_morph:", new_morph
			# if new_morph in morphs: break
			# if len(new_morph) > 0: morphs.append(new_morph)
			# else: break
			remaining = suffixPDA.get_remaining_input()
			#######
			# used_features = []
			# used_symbols = list(suffixPDA.get_used_features())
			used_features = suffixPDA.get_used_features()
			#"Symbols," which are based on features, will each be unique, since each feature is unique.
			#used_symbols.extend(list(set(old_input_list)-set(input_lists[i])))
			# for symbol in used_symbols:
			# 	used_features.append(myFeatureLists.decode_symbol(symbol))
			sum_value = 0.0
			# for feature in used_features:
			# 	 #sum_value += centroids[str(i)][feature]
			# 	 #sum_value += centroids_featuresAndValues[i][feature]
			# 	 # feature_and_value = centroids_featuresAndValues[i]
			# 	 # value = feature_and_value.split("//")[1]
			# 	 # sum_value += value
			# 	 value = centroids_featuresAndValues[i][feature]
			# 	 sum_value += value
			#for feature in used_symbols:
			for feature in used_features:
				 #sum_value += centroids[str(i)][feature]
				 #sys.stderr.write("Fs_and_Vs: ")
				 ##print float(centroids_featuresAndValues[i][feature])
				 #feature_and_value = centroids_featuresAndValues[i]
				 #value = feature_and_values.split("//")[1]
				 value = float(centroids_featuresAndValues[i][feature])
				 sum_value += value
			#avg_feature_values.append()
			#avg_feature_values.append((sum_value/float(len(used_features)), new_morph))
			#######
			##print ">", counter, "> suffix > INPUT LIST =", input_lists[i]
			# if len(new_morph) == 0: break
			# if new_morph not in morphs: 
				# morphs.append(new_morph)
			if len(new_morph) > 0 and new_morph not in morphs:
				#avg_feature_values.append((sum_value/float(len(used_features)), new_morph))
				try: avg_val = sum_value/float(len(used_features))
				except ZeroDivisionError: pass
				else:
					avg_feature_values.append((avg_val, new_morph))
				#avg_feature_values.append((sum_value/float(len(used_symbols)), new_morph))
					morphs.append(new_morph)
			##print "> suffix > MORPHS =", morphs
			#else: pass

			###print "MORPHS =", morphs
			
			###print "CTR =", counter, "-->",
			counter += 1
			###print counter
		
		counter = 0
		#print "MORPHS:", " ".join(morphs)
		morph_lists.append(morphs)
		avg_feature_values.sort()
		#print "avg_f_vals:", avg_feature_values
		##print "morph_lists:", morph_lists
		if len(avg_feature_values) > 0:
			morph_with_max_value = avg_feature_values[0][1]
			morph_dict[str(i)] = morph_with_max_value
	#return morph_lists
	return morph_dict
	# for input_list in input_lists:
	# 	##print input_list
	# 	###print "MORPHS =", morphs
	# 	old_input_list = []
	# 	counter = 0
	# 	cycle_max = 3
	# 	morphs = []
	# 	avg_feature_activities = []
	# 	while counter < cycle_max: #len(input_list):
	# 		##print "\n<<   N  E  W    C  Y  C  L  E   >>\n"
	# 		##print "MORPHS =", morphs, "; COUNTER =", counter, "; len =" , len(input_list), "; tape =", input_list
	# 		###print"length =", len(new_morph)
	# 		prefixPDA = PrefixPDA(input_list)
	# 		###print isinstance(prefixPDA, PDA)
	# 		###print isinstance(prefixPDA, PrefixPDA)
	# 		prefixPDA.run_prefix_pda()
	# 		new_morph = prefixPDA.get_morph()
	# 		###print "\n  N   E   W\n"
	# 		old_input_list = input_list
	# 		input_list = prefixPDA.get_remaining_input()
	# 		used_features.extend(list(set(old_input_list)-set(input_list)))
	# 		for used_feature in used_features:
	# 		##print "  NEW_MORPH =", new_morph, "; length =", len(new_morph)
	# 		##print "> prefix > INPUT LIST =", input_list
	# 		if len(new_morph) > 0 and new_morph not in morphs:
	# 		#if new_morph not in morphs:
	# 			morphs.append(new_morph)
	# 			##print ">", counter, "> prefix > MORPHS =", morphs, "; COUNTER =", counter
	# 			###print "\n"
	# 		else: 
	# 			###print "I'll pass"
	# 			pass
	# 			#break
	# 		##print "COUNTER =", counter, "-->",
	# 		counter += 1
	# 		###print "COUNTER =", counter
	# 		##print counter
		
	# 	counter = 0
	# 	while counter < cycle_max:
	# 		##print "\n## STEM;", input_list
	# 		##print "###", counter
	# 		stemPDA = StemComponentPDA(input_list)
	# 		stemPDA.run_stem_pda()
	# 		###print isinstance(stemPDA, PDA)
	# 		###print isinstance(stemPDA, StemComponentPDA)
	# 		new_morph = stemPDA.get_morph()
	# 		##print "  NEW_MORPH =", new_morph, "; length =", len(new_morph)
	# 		#if new_morph in morphs: break
	# 		input_list = stemPDA.get_remaining_input()
	# 		##print ">", counter, "> stem >> INPUT LIST =", input_list
	# 		# if len(new_morph) == 0: break
	# 		# if new_morph not in morphs: 
	# 		if len(new_morph) > 0 and new_morph not in morphs:
	# 			morphs.append(new_morph)
	# 			##print "> stem >> MORPHS =", morphs
	# 		else: pass
	# 		##print "CTR =", counter, "-->",
	# 		##print "MORPHS =", morphs
	# 		counter += 1
	# 		##print counter
		
	# 	counter = 0
	# 	while counter < cycle_max:
	# 		##print "\n## SUFFIX;", input_list
	# 		##print "###", counter
	# 		suffixPDA = SuffixPDA(input_list)
	# 		suffixPDA.run_suffix_pda()
	# 		###print isinstance(suffixPDA, PDA)
	# 		###print isinstance(suffixPDA, SuffixPDA)
	# 		new_morph = suffixPDA.get_morph()
	# 		# if new_morph in morphs: break
	# 		# if len(new_morph) > 0: morphs.append(new_morph)
	# 		# else: break
	# 		input_list = suffixPDA.get_remaining_input()
	# 		##print ">", counter, "> suffix > INPUT LIST =", input_list
	# 		# if len(new_morph) == 0: break
	# 		# if new_morph not in morphs: 
	# 			# morphs.append(new_morph)
	# 		if len(new_morph) > 0 and new_morph not in morphs:
	# 			morphs.append(new_morph)
	# 			##print "> suffix > MORPHS =", morphs
	# 		else: pass

	# 		##print "MORPHS =", morphs
			
	# 		##print "CTR =", counter, "-->",
	# 		counter += 1
	# 		##print counter
		
	# 	counter = 0
	# 	morph_lists.append(morphs)
	# return morph_lists

if __name__ == "__main__":
	filename = sys.argv[1]
	morph_dict = main(filename)
	#for cluster_ID in morph_dict.keys():
		#print cluster_ID, morph_dict[cluster_ID]
	###print "ORIGINAL LISTS =", active_feature_lists
	##print "MORPH LISTS =", morph_dict


