#!/usr/bin/env python
# -*- coding: utf-8 -*-
# encoding: utf-8
import os,sys, codecs
import numpy as np
#import regex as re
import random, math
from random import choice
from StringIO import StringIO
from numpy import *
from numpy.linalg import *
reload(sys)  
sys.setdefaultencoding('utf8')

UTF8Writer = codecs.getwriter('utf8')
sys.stdout = UTF8Writer(sys.stdout)

cpdef get_prec_subset(object prec_type, object vowels, object cons, object alphabet):
	if prec_type == 'CC': return ["C<C"]
	if prec_type == 'CV': return ["C<V"]
	if prec_type == 'Cc': return ["C" + "<" + c for c in cons]
	if prec_type == 'Cv': return ["C" + "<" + v for v in vowels]
	if prec_type == 'VC': return ["V<C"]
	if prec_type == 'VV': return ["V<V"]
	if prec_type == 'Vc': return ["V" + "<" + c for c in cons]
	if prec_type == 'Vv': return ["V" + "<" + v for v in vowels]
	if prec_type == 'cC': return [c + "<" + "C" for c in cons]
	if prec_type == 'cV': return [c + "<" + "V" for c in cons]
	if prec_type == 'cc': return [c1 + "<" + c2 for c1 in cons for c2 in cons]
	if prec_type == 'cv': return [c + "<" + v for c in cons for v in vowels]
	if prec_type == 'vC': return [v + "<" + "C" for v in vowels]
	if prec_type == 'vV': return [v + "<" + "V" for v in vowels]
	if prec_type == 'vc': return [v + "<" + c for v in vowels for c in cons]
	if prec_type == 'vv': return [v1 + "<" + v2 for v1 in vowels for v2 in vowels]
	if prec_type == 'basic': return [x + "<" + y for x in alphabet for y in alphabet]

cdef class FeatureEncoder:
	def __init__(self, corpusFile, affixlen, prec_span, prec_types, bigrams):
		self.affixlen = affixlen
		self.prec_span = 0
		self.positional = False
		self.precedence = False
		#self.vv_cc = False
		#self.bigrams = False
		if affixlen != "0":
			self.positional = True
			self.affixlen = int(affixlen)
		if prec_span != "0":
			self.precedence = True
		if prec_span == "star":
			self.prec_span = 1000
		else:
			self.prec_span = int(prec_span)
		# if bigrams == "1":
		# 	self.bigrams = True	
		#if vv_cc == "1"
			#self.vv_cc = True
		#fobj = open(corpusFile, 'r')

		self.prec_types = sorted(prec_types.split(","))
		#print "PRECEDENCE TYPES:", self.prec_types
		fobj = codecs.open(corpusFile, 'r', encoding='utf8')
		self.words = list()
		#self.vectors = list()
		self.alphabet = list()
		self.alphalen = 0
		self.numPosFeatures = 0
		self.numPrecFeatures = 0
		self.posFeatures = list()
		self.precFeatures = set()
		#self.bigramFeatures = list()
		self.allFeatures = list()
		#self.allFeaturesList = list()
		lines = fobj.readlines()
		self.V_set = list()
		self.C_set = list()
		cdef object word = ""
		cdef object vowel_str
		# if includeAccents:
		# 	self.V_set.extend(list(u"\u00FA\u00F3\u00ED\u00E9\u00E1"))
		# self.C_set = [c for c in self.alphabet if c not in self.V_set]

 	# 	#self.cons = u"\u1E6D\u1E33\u0161\u1E63\u017E"
 	# 	#self.C_set = u"\u1E6D\u1E33\u0161\u1E63\u017E\u0294\u0295\u00E7\u0234"
 	# 	self.C_set = [c for c in self.alphabet if c not in self.V_set]
 		#more_cons = "qwrtyplkhgfdszcvbnm"
		#vowels = ""
		#firstLine = lines[0].encode('utf-8')
		cdef object firstLine = lines[0]
		##print "first line type =", type(firstLine)
		##sys.stdout.flush()
		##print "FL:", firstLine.decode('utf-8')
		#firstLine = unicode(firstLine, 'utf-8')
		##print "FL:", type(firstLine)
		##sys.stdout.flush()
		if firstLine[0] == u"#":
			firstLine = lines.pop(0)
			firstLine = firstLine.replace("#", "")
			firstLine = firstLine.replace(u"\n",u"")
			firstLine = firstLine.replace(u"\r",u"")
			parts = firstLine.split()
			vowels = parts[0]
			consonants = parts[1]
			self.V_set = list(vowels)
			self.C_set = list(consonants)
			#print "ALPHABET:", firstLine
			self.alphabet = list(vowels + consonants)
			#self.alphabet = list(firstLine)
			self.alphalen = len(self.alphabet)
		else:
			self.C_set = list(u"qwrtyplkhgfdszcvbnm\u1E6D\u1E33\u0161\u1E63\u017E\u0294\u0295\u00E7\u0234")
			vowel_str = "uoiea"
			self.V_set = list(vowel_str)
			if includeAccents:
				self.V_set.extend(list(u"\u00FA\u00F3\u00ED\u00E9\u00E1"))
				vowel_str = u"uoiea\u00FA\u00F3\u00ED\u00E9\u00E1"
			self.V_string = vowel_str
			#self.V_pat = ur"^[uoiea\u00FA\u00F3\u00ED\u00E9\u00E1]$"
			#self.re_V = re.compile(self.V_pat, re.UNICODE)
			self.alphabet = []
			self.alphabet.extend(self.C_set)
			self.alphabet.extend(self.V_set)
			##print "ALPHABET:", firstLine
			##sys.stdout.flush()
			#new_alphabet = []
			#new_letter = u""
			# for letter in self.alphabet:
			# 	if isinstance(letter, (unicode)) == False:
			# 		letter = unicode(letter, 'utf8')

					#pass
				# elif isinstance(letter, (str)):
				# 	letter = unicode(letter, 'utf8')
				# else:
				# 	letter = unicode(letter, 'utf8')
					#new_letter = unicode(letter, 'utf8')
				#else: new_letter = letter
				#new_alphabet.append(new_letter)
				#self.alphabet.append(letter)
				##print "Type =", type(letter)
				##print "Letter =", letter
				###sys.stdout.flush()
			#self.alphabet = list(new_alphabet)
			##print "*** Alphabet letters, length, affixlen:"
			#print self.alphabet
			#print self.alphalen, self.affixlen 
		self.numV = len(self.V_set)
		self.numC = len(self.C_set)
		
		for line in lines:
			string = line  #.encode('utf-8')
			##sys.stdout.write(u"A1 " + repr(string) + u"\n")
			##print "Type of string:", type(string)
			##sys.stdout.flush()
			string = string.replace("\n","")
			string = string.replace("\r","")

			# if isinstance(string, (unicode)) == False:
			# 	string = unicode(string, 'utf8')
			#pat_quot = ur"\""
			#pat_hash = ur"^#.+"
			##print "Type of string 2:", type(string)
			#re_quot = re.compile(pat_quot, re.UNICODE)
			if string == "" or "\"" in string:
				continue
			#re_hash = re.compile(pat_hash, re.UNICODE)
			##sys.stdout.write(u"A2 " + string + u'\n')
			##print "Type of string 3:", type(string)
			##sys.stdout.flush()
			# if string == "":
			# 	break
			# if re_quot.search(string):
			# 	pass
			#if string[0] == u"#":
			# if re_hash.search(string):
			# 	#self.alphabet = list(string[1:].encode('utf_8'))
			# 	#print "STRING:"
			# 	self.alphabet = list(string[1:])
			# 	#print "ALPHABET:"
			# 	for letter in self.alphabet:
			# 		print letter, type(letter)
			# 	##sys.stdout.flush()
			# 	self.alphalen = len(self.alphabet)
			# 	print u"\n\n\n"
			# 	print u"*** Alphabet letters, length, affixlen:"
			# 	print repr(self.alphabet)
			# 	print self.alphalen, self.affixlen
			# 	print u"\n\n\n"
			# 	##sys.stdout.flush()
			# else:
			dataRow = string.split()
			word = dataRow[0]  #.encode('utf-8')
			#print u"word:", word, type(word)
			#prelimVector = []
			#if self.positional:
			#prelimVector = [0]*(self.affixlen*2*self.alphalen)
			#prelimVector.append(0) We don't need the "duplicate-letter "feature.
			#self.numPosFeatures = self.affixlen*2*self.alphalen
			# add feature slots for precedence features.
			## the number of prec. features is the length of the alphabet squared.
			#prelimVector.extend([0]*(self.alphalen*self.alphalen))
			self.words.append(word)
			#self.words.append(word.encode('utf_8'))
			#self.vectors.append(prelimVector)
		fobj.close()
		####print "encode", 7
		##sys.stdout.flush()
		if self.positional:
			# initialize positional features
			self.numPosFeatures = self.affixlen*2*self.alphalen
			# for prelimVector in self.vectors:
			# 	prelimVector.extend([0]*(self.numPosFeatures))
			for i in range(self.affixlen):
				for j in range(self.alphalen):
					#self.posFeatures.append(self.alphabet[j] + "@[" + str(i).encode('utf8') + "]")
					self.posFeatures.append(self.alphabet[j] + "@[" + unicode(i) + "]")
			for i in reversed(range(self.affixlen)):
				for j in range(self.alphalen):
					#self.posFeatures.append(self.alphabet[j] + "@[" + str(i-self.affixlen).encode('utf8') + "]")
					self.posFeatures.append(self.alphabet[j] + "@[" + unicode(i-self.affixlen) + "]")
			#self.allFeatures.update(self.posFeatures)
		###print "encode", 8
		##sys.stdout.flush()
		if self.precedence:
			# initialize positional features
			#self.numPrecFeatures = self.alphalen*self.alphalen
			# for prelimVector in self.vectors:
			# 	prelimVector.extend([0]*(self.numPrecFeatures))
			#self.precFeatures = set()
			#print "ENCODE Stg 1; prec_types:", self.prec_types
			#sys.stdout.flush()
			for prec_type in self.prec_types:
				#print "ENCODE Stg 1; this prec_type:", prec_type
				feat_subset = get_prec_subset(prec_type, self.V_set, self.C_set, self.alphabet)
				self.precFeatures.update(feat_subset)
				sys.stdout.write("Feature Subset: ")
				#for feat in feat_subset:
				#print ", ".join(feat_subset)
				#sys.stdout.flush()
			# if self.vv_cc:
			# 	for x in self.V_set:
			# 		for y in self.V_set:
			# 			self.precFeatures.append(x + "<" + y)
			# 	for x in self.C_set:
			# 		for y in self.C_set:
			# 			self.precFeatures.append(x + "<" + y)

				# for x in self.alphabet:
				# 	for y in self.alphabet:
				# 			if (x in self.V_set and y in self.V_set) or (x in self.C_set and y in self.C_set):
				# 				self.precFeatures.append(x + "<" + y)
			# if self.basicPrec:
			# 	for x in self.alphabet:
			# 		for y in self.alphabet:
			# 			self.precFeatures.append(x + "<" + y)
			# if self.vC_cV:
			# 	for v in self.V_set:
			# 		self.precFeatures.append(v + "<" + v)
			# 		self.precFeatures.append(v + "<" + "C")
			# 		self.precFeatures.append("C" + "<" + v)
			# 	for c in self.C_set:
			# 		self.precFeatures.append(c + "<" + "C")
			# 		self.precFeatures.append("C" + "<" + c)
			# 	for c in self.C_set:
			# 		for v in self.V_set:
			# 			self.precFeatures.append(c + "<" + v)
			# 			self.precFeatures.append(v + "<" + c)
			self.numPrecFeatures = len(self.precFeatures)
			self.allFeatures.extend(sorted(self.posFeatures))
			self.allFeatures.extend(sorted(list(self.precFeatures)))
			#self.allFeaturesList = list(self.allFeatures)

			# for prelimVector in self.vectors:
			# 	prelimVector.extend([0]*(self.numPrecFeatures))
			#numrows = len(self.words)
			#numcols = len(self.allFeatures)
			self.vectors = np.zeros((len(self.words),len(self.allFeatures)), dtype=np.float64, order='C')
			#print "self.vectors:", self.vectors.shape[0], "x", self.vectors.shape[1]
		# if self.bigrams:
		# 	# initialize bigram features
		# 	self.numBigramFeatures = self.alphalen*self.alphalen
		# 	for prelimVector in self.vectors:
		# 		prelimVector.extend([0]*(self.numBigramFeatures))
		# 	self.bigramFeatures = list()
		# 	for letter_x in self.alphabet:
		# 		for letter_y in self.alphabet:
		# 			self.bigramFeatures.append(letter_x + "+" + letter_y)
		# 	self.allFeatures.extend(self.bigramFeatures)
		#print "Finished initializing features."
##	def affixlenDuplication(self, string):
##		#sys.stderr.write(string + "\n")
##		if len(string) >= self.affixlen+1 and string[self.affixlen] == string[self.affixlen-1]:
##			return True
##		else:
##			return False
	cpdef bint isCons(self, object letter):
		# if x in self.V_set:
		# 	return False
		# return True
		cdef int i
		#cdef int I = self.numV
		# if self.re_V.search(x):
		# 	print x "is not a cons"
		# 	return 0
		# else: return 1
		#cdef int I = len(self.vowels)
		if letter in self.V_set: return 0
		# for i in range(self.numV):
		# 	if letter == self.V_set[i]: return 0
		return 1
	
	cpdef object C_or_V(self, object x):
		if x not in self.V_set: return "C"
		else: return "V"

	cpdef int encodeWords(self):
		# V_pat = ur"^[uoiea\u00FA\u00F3\u00ED\u00E9\u00E1]$"
		# C_pat = ur"^[^uoiea\u00FA\u00F3\u00ED\u00E9\u00E1]$"
		# re_V = re.compile(V_pat, re.UNICODE)
		# re_C = re.compile(C_pat, re.UNICODE)
		cdef int i,j,n,limit,numWords,feature_ndx,alpha_ndx
		cdef int right_edge, word_len
		cdef object letter_x, letter_y, letter
		cdef object feature, cat_x, cat_y
		cdef object cats = ("V", "C")
		numWords = len(self.words)
		##print "encode", 9, "   ", len(self.words)
		#sys.stdout.flush()
		#for n in range(len(self.words)):
		for n in range(numWords):
			if n%100 == 0:
				print "... Encoding word", n, "..."
				sys.stdout.flush()
			if self.positional:
				###################################################### encode positional featuree
				#limit = self.affixlen
				for i in range(<int>self.affixlen):
					try:
						if (len(self.words[n])-1) - i <= 0: continue
						letter = self.words[n][i]
						# 	letter = unicode(letter, 'utf8')
						#print "letter TYPE:", type(letter), "   self.alphabet:", "".join(self.alphabet)
						#sys.stdout.flush()
						alpha_ndx = self.alphabet.index(letter)
					except IndexError: continue
					else:
						# determine the index of the feature corresponding
						# to the letteracter
						feature_ndx = i*self.alphalen + alpha_ndx
						self.vectors[n,feature_ndx] = 1.0
						#feature = letter + "@" + "[" + str(i) + "]"
						#self.allFeatures[feature_ndx] = feature
				#print "encode", 10, "   n =", n
				#sys.stdout.flush()
				for i in reversed(range(<int>self.affixlen)):
					# for i = 3,2,1,0: (self.affixlen = 4)
					# i = 3 references the last letteracter
					try:
						if i-self.affixlen + len(self.words[n]) <= 0: continue
						letter = self.words[n][i-self.affixlen]
						alpha_ndx = self.alphabet.index(letter)
					except IndexError: 
						##print "INDEX ERROR"
						##sys.stdout.flush()
						continue
					else:
						# ((affixlen times two) - 1 - i) times number of slots per letteracter + alphabet index
						# for i = 2 and self.affixlen = 3:
						## (6 - 1 - 2) times 22 + position of letter in alphabet (alpha index)
						feature_ndx = (self.affixlen*2-1-i)*self.alphalen + alpha_ndx
						self.vectors[n,feature_ndx] = 1.0
						#self.allFeatures[feature_ndx] = feature
				###################################################
				###################################################
			#print "encode", 15
			#sys.stdout.flush()
			if self.precedence:                                               
				### encode precedence features
				# The value "len(self.words[n])" is the length (in letteracters) of the n-th word
# 				for i in range(len(self.words[n])-1):
# 					for j in range(i+2,len(self.words[n])):
# 						# self.words[n][i] is the i-th letteracter of the n-th word.
# 						# self.prec_span is the maximum separation allowed between i and j.
						# But why does j start at i+2? Shouldn't it start at the *next* letteracter following i-th letteracter, i.e., at index i+1?
# 						if j > i+2 + self.prec_span:
# 							break
# 						feature = self.words[n][i] + "<" + self.words[n][j]
# 						# find the feature index within the larger feature list
#						# since the precedence features are after the positional features,
# 						# we add the number of positional features minus one.
# 						feature_ndx = self.precFeatures.index(feature) + self.numPosFeatures
# 						self.vectors[n][feature_ndx] = 1.0
						#self.allFeatures[feature_ndx] = feature
				word_len = len(self.words[n])
				for i in range(word_len-1):
					#print "encode", 15.9, i
					#sys.stdout.flush()
					# i is the "left edge"
					left_edge = i
					left_letter = self.words[n][left_edge]
					right_edge = i+1+self.prec_span
					#if right_edge > len(self.words[n]):
					if right_edge > word_len:
						right_edge = word_len
					#else: right_edge = i+1+self.prec_span

					#print "encode", 16, i
					#sys.stdout.flush()
					for j in range(i+1, right_edge):
						##print "encode", 17
						##sys.stdout.flush()
						#features = []
						letter_x = self.words[n][i]
						letter_y = self.words[n][j]
						
						cat_x = cats[self.isCons(letter_x)]
						cat_y = cats[self.isCons(letter_y)]
						#sys.stdout.flush()
						##print "Cats:", cat_x, cat_y
						# re_V.sub("C"), letter_x) + "<" + re_C.sub("V", letter_y)
						# re_V.sub("V"), letter_x) + "<" + re_C.sub("C", letter_y)
						# re_C.sub("C", letter_x) + "<" + re_C.sub("C", letter_y)
						# re_C.sub("V", letter_x) + "<" + re_C.sub("V", letter_y)
						# if self.isCons(letter_x) == 0:
						# 	cat_x = "V"
						# else:
						# 	cat_x = "C"
						# if self.isCons(letter_y) == 0:
						# 	cat_y = "V"
						# else:
						# 	cat_y = "C"	
						# try: feature = letter_x + "<" + letter_y
						# except IndexError: continue

						# what are the labels? self,C,V
						# if self.words[n][i] = a and self.words[n][j] = g, then we have:
						# "V < C", "a < C", "V < g", "a < g"
						# 1.  self-left < self-right
						feature = letter_x + "<" + letter_y
						try: feature_ndx = self.allFeatures.index(feature)
						except ValueError: pass
						else: 
							self.vectors[n,feature_ndx] = 1.0
							#print "# 1. " +  letter_x + "<" + letter_y
							#sys.stdout.flush()
						#feature = letter_x + "<" + self.C_or_V(letter_y)
						feature = letter_x + "<" + cat_y
						try: feature_ndx = self.allFeatures.index(feature)
						except ValueError: pass
						else: 
							self.vectors[n,feature_ndx] = 1.0
							#print "# 2. " +  letter_x + "<" + cat_y
							#sys.stdout.flush()
						#feature = self.C_or_V(letter_x) + "<" + letter_y
						feature = cat_x + "<" + letter_y
						try: feature_ndx = self.allFeatures.index(feature)
						except ValueError: pass
						else: 
							self.vectors[n,feature_ndx] = 1.0
							#print "# 3. " + cat_x + "<" + letter_y
							#sys.stdout.flush()
						#feature = self.C_or_V(letter_x) + "<" + self.C_or_V(letter_y)
						feature = cat_x + "<" + cat_y
						try: feature_ndx = self.allFeatures.index(feature)
						except ValueError: pass
						else: 
							self.vectors[n,feature_ndx] = 1.0
							#print "# 4. " + cat_x + "<" + cat_y
							#sys.stdout.flush()
							#try: feature_ndx = self.precFeatures.index(feature) + self.numPosFeatures
						#sys.stdout.flush()
						
						#feature_ndx = self.precFeatures.index(feature) + self.numPosFeatures
						#self.vectors[n][feature_ndx] = 1.0
						#print "**ENCODE**", i, j, self.allFeatures[feature_ndx], unicode(self.words[n]), u"feature_ndx =", feature_ndx, unicode(self.vectors[n][feature_ndx])
						#sys.stdout.flush()
				##print "*end of word*"
				##sys.stdout.flush()
			
			# if self.bigrams:                                               
			# 	### encode precedence features
			# 	# The value "len(self.words[n])" is the length (in letteracters) of the n-th word
			# 	for i in range(len(self.words[n])-1):
			# 		for j in range(i+1,len(self.words[n])):
			# 			# self.words[n][i] is the i-th letteracter of the n-th word.
			# 			feature = self.words[n][i] + "+" + self.words[n][j]
			# 			feature_ndx = self.bigramFeatures.index(feature) + self.numPosFeatures + self.numPrecFeatures
			# 			self.vectors[n,feature_ndx] = 1.0
			
				##################################################
	cpdef object getFeatures(self):
		return self.allFeatures
                        
	cpdef np.ndarray[np.float64_t, ndim=2] getVectors(self):
		return self.vectors
	
	def getAlphabet(self):
		return self.alphabet
	
	# cpdef int writeVectorsToFile(self, object outputFile):
	# 	fobj = open(outputFile, 'w')
	# 	# the alphabet is printed on the first line
	# 	####print "encode", 19
	# 	##sys.stdout.flush()
	# 	alphaStr = "".join(self.alphabet)
	# 	#alpha_uni = alphaStr
	# 	##print "ALPHA_UNI_1* =", unicode(alpha_uni)
	# 	#if isinstance(alphaStr, (unicode)) == False:
	# 		# alpha_uni = unicode(alphaStr, 'utf-8')
	# 		# alpha_uni = alphaStr.decode('utf8')
	# 		#alpha_uni = unicode(alphaStr)
	# 	##print "ALPHA_UNI_2 =", alpha_uni  #alpha_uni.encode('utf8')
	# 	# if alpha_uni[0] != "#":
	# 	# 	alpha_uni += "#"
	# 	fobj.write("#" + alphaStr + "\n")
	# 	##sys.stdout.write("&&& alpha_uni = " + alpha_uni + "\n")
	# 	for i in range(len(self.vectors)):
	# 		for item in self.vectors[i]:
	# 			#print item
	# 			fobj.write(unicode(str(item), 'utf8'))
	# 			#fobj.write(str(item))
	# 			if self.vectors[i].index(item) < (len(self.vectors[i]) - 1):
	# 				fobj.write("  ")
	# 		##sys.stdout.flush()
	# 		fobj.write("\n")
	# 	####print "encode", 20
	# 	fobj.close()
	
def main(inputFile, outputFile):
	features = Features(inputFile)
	features.encodeWords()
	features.writeVectorsToFile(outputFile)
	
if __name__ == "__main__":
	inputFile = sys.argv[1]
	outputFile = sys.argv[2]
	main(inputFile, outputFile)
			
