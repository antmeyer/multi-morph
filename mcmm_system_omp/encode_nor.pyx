#!/usr/bin/env python
# -*- coding: utf-8 -*-
# encoding: utf-8
import os,sys, codecs
import regex as re
import random, math
from random import choice
from StringIO import StringIO
from numpy import *
from numpy.linalg import *
reload(sys)  
#sys.setdefaultencoding('utf8')

UTF8Writer = codecs.getwriter('utf8')
#sys.stdout = UTF8Writer(#sys.stdout)

cdef class FeatureEncoder:
	def __init__(self, corpusFile, affixlen, prec_span, bigrams):
		self.affixlen = affixlen
		self.prec_span = 0
		self.positional = False
		self.precedence = False
		self.bigrams = False
		if affixlen != "0":
			self.positional = True
			self.affixlen = int(affixlen)
		if prec_span != "0":
			self.precedence = True
		if prec_span == "star":
			self.prec_span = 1000
		else:
			self.prec_span = int(prec_span)
		if bigrams == "1":
			self.bigrams = True	
		#fobj = open(corpusFile, 'r')
		fobj = codecs.open(corpusFile, 'r', encoding='utf8')
		self.words = list()
		self.vectors = list()
		self.alphabet = list()
		self.alphalen = 0
		self.numPosFeatures = 0
		self.numPrecFeatures = 0
		self.posFeatures = list()
		self.precFeatures = list()
		self.bigramFeatures = list()
		self.allFeatures = list()
		lines = fobj.readlines()
		#firstLine = lines[0]
		#firstLine = lines[0].encode('utf-8')
		firstLine = lines[0]
		#print "first line type =", type(firstLine)
		#sys.stdout.flush()
		#print "FL:", firstLine.decode('utf-8')
		#firstLine = unicode(firstLine, 'utf-8')
		#print "FL:", type(firstLine)
		#sys.stdout.flush()
		if firstLine[0] == u"#":
			firstLine = lines.pop(0)
			firstLine = firstLine.replace("#", "")
			firstLine = firstLine.replace(u"\n",u"")
			firstLine = firstLine.replace(u"\r",u"")
			print "ALPHABET:", firstLine
			self.alphabet = list(firstLine)
			self.alphalen = len(self.alphabet)
			#print "ALPHABET:", firstLine
			#sys.stdout.flush()
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
				#print "Type =", type(letter)
				#print "Letter =", letter
				##sys.stdout.flush()
			#self.alphabet = list(new_alphabet)
			#print "*** Alphabet chars, length, affixlen:"
			#print self.alphabet
			#print self.alphalen, self.affixlen 

		for line in lines:
			string = line  #.encode('utf-8')
			##sys.stdout.write(u"A1 " + repr(string) + u"\n")
			#print "Type of string:", type(string)
			#sys.stdout.flush()
			string = string.replace("\n","")
			string = string.replace("\r","")

			#if type(string) != "<type 'unicode'>":
			if isinstance(string, (unicode)) == False:
				#string = string.decode('utf8')
				string = unicode(string, 'utf8')
			pat_quot = ur"\""
			#pat_hash = ur"^#.+"
			#print "Type of string 2:", type(string)
			re_quot = re.compile(pat_quot, re.UNICODE)
			#re_hash = re.compile(pat_hash, re.UNICODE)
			##sys.stdout.write(u"A2 " + string + u'\n')
			#print "Type of string 3:", type(string)
			#sys.stdout.flush()
			if string == u"":
				break
			if re_quot.search(string):
				pass
			#if string[0] == u"#":
			# if re_hash.search(string):
			# 	#self.alphabet = list(string[1:].encode('utf_8'))
			# 	print "STRING:"
			# 	self.alphabet = list(string[1:])
			# 	print "ALPHABET:"
			# 	for letter in self.alphabet:
			# 		print letter, type(letter)
			# 	#sys.stdout.flush()
			# 	self.alphalen = len(self.alphabet)
			# 	print u"\n\n\n"
			# 	print u"*** Alphabet chars, length, affixlen:"
			# 	print repr(self.alphabet)
			# 	print self.alphalen, self.affixlen
			# 	print u"\n\n\n"
			# 	#sys.stdout.flush()
			# else:
			dataRow = string.split()
			word = dataRow[0]  #.encode('utf-8')
			#print u"word:", word, type(word)
			prelimVector = []
			#if self.positional:
			#prelimVector = [0]*(self.affixlen*2*self.alphalen)
			#prelimVector.append(0) We don't need the "duplicate-char "feature.
			#self.numPosFeatures = self.affixlen*2*self.alphalen
			# add feature slots for precedence features.
			## the number of prec. features is the length of the alphabet squared.
			#prelimVector.extend([0]*(self.alphalen*self.alphalen))
			self.words.append(word)
			#self.words.append(word.encode('utf_8'))
			self.vectors.append(prelimVector)
		fobj.close()
		##print "encode", 7
		#sys.stdout.flush()
		if self.positional:
			# initialize positional features
			self.numPosFeatures = self.affixlen*2*self.alphalen
			for prelimVector in self.vectors:
				prelimVector.extend([0]*(self.numPosFeatures))
			for i in range(self.affixlen):
				for j in range(self.alphalen):
					#self.posFeatures.append(self.alphabet[j] + "@[" + str(i).encode('utf8') + "]")
					self.posFeatures.append(self.alphabet[j] + u"@[" + unicode(i) + u"]")
			for i in reversed(range(self.affixlen)):
				for j in range(self.alphalen):
					#self.posFeatures.append(self.alphabet[j] + "@[" + str(i-self.affixlen).encode('utf8') + "]")
					self.posFeatures.append(self.alphabet[j] + u"@[" + unicode(i-self.affixlen) + u"]")
			self.allFeatures.extend(self.posFeatures)
		#print "encode", 8
		#sys.stdout.flush()
		if self.precedence:
			# initialize positional features
			self.numPrecFeatures = self.alphalen*self.alphalen
			for prelimVector in self.vectors:
				prelimVector.extend([0]*(self.numPrecFeatures))
			self.precFeatures = list()
			for char_x in self.alphabet:
				for char_y in self.alphabet:
					#self.precFeatures.append(unicode(char_x) + u"<" + unicode(char_y)
					self.precFeatures.append(char_x + "<" + char_y)
			self.allFeatures.extend(self.precFeatures)
		if self.bigrams:
			# initialize positional features
			self.numBigramFeatures = self.alphalen*self.alphalen
			for prelimVector in self.vectors:
				prelimVector.extend([0]*(self.numBigramFeatures))
			self.bigramFeatures = list()
			for char_x in self.alphabet:
				for char_y in self.alphabet:
					#self.bigramFeatures.append(unicode(char_x) + u"+" + unicode(char_y)
					self.bigramFeatures.append(char_x + "+" + char_y)
			self.allFeatures.extend(self.bigramFeatures)
        #self.alphabet = list("abgdhwzxviklmnsypcqret")

##	def affixlenDuplication(self, string):
##		#sys.stderr.write(string + "\n")
##		if len(string) >= self.affixlen+1 and string[self.affixlen] == string[self.affixlen-1]:
##			return True
##		else:
##			return False
		
	cpdef int encodeWords(self):
		#print "encode", 9, "   ", len(self.words)
		#sys.stdout.flush()
		for n in range(len(self.words)):
			if self.positional:
				###################################################### encode positional featuree
				for i in range(self.affixlen):
					try:
						if (len(self.words[n])-1) - i <= 0:
							continue
						char = self.words[n][i]
						if isinstance(char, (unicode)) == False:
							char = unicode(char, 'utf8')
						#print "char TYPE:", type(char), "   self.alphabet:", "".join(self.alphabet)
						#sys.stdout.flush()
						alpha_ndx = self.alphabet.index(char)
					except IndexError: continue
					else:
						# determine the index of the feature corresponding
						# to the character
						feature_ndx = i*self.alphalen + alpha_ndx
						self.vectors[n][feature_ndx] = 1.0
						#feature = char + "@" + "[" + str(i) + "]"
						#self.allFeatures[feature_ndx] = feature
				#print "encode", 10, "   n =", n
				#sys.stdout.flush()
				for i in reversed(range(self.affixlen)):
					# for i = 3,2,1,0: (self.affixlen = 4)
					# i = 3 references the last character
					try:
						if i-self.affixlen + len(self.words[n]) <= 0:
							continue
						char = self.words[n][i-self.affixlen]
						if isinstance(char, (unicode)) == False:
							char = unicode(char, 'utf8')
						alpha_ndx = self.alphabet.index(char)
					except IndexError: 
						#print "INDEX ERROR"
						#sys.stdout.flush()
						continue
					else:
						# ((affixlen times two) - 1 - i) times number of slots per character + alphabet index
						# for i = 2 and self.affixlen = 3:
						## (6 - 1 - 2) times 22 + position of char in alphabet (alpha index)
						feature_ndx = (self.affixlen*2-1-i)*self.alphalen + alpha_ndx
						self.vectors[n][feature_ndx] = 1.0
						#feature = char + "@" + "[" + str(i-self.affixlen) + "]"
						#self.allFeatures[feature_ndx] = feature
				###################################################
				###################################################
			#print "encode", 15
			#sys.stdout.flush()
			if self.precedence:                                               
				### encode precedence features
				# The value "len(self.words[n])" is the length (in characters) of the n-th word
# 				for i in range(len(self.words[n])-1):
# 					for j in range(i+2,len(self.words[n])):
# 						# self.words[n][i] is the i-th character of the n-th word.
# 						# self.prec_span is the maximum separation allowed between i and j.
						# But why does j start at i+2? Shouldn't it start at the *next* character following i-th character, i.e., at index i+1?
# 						if j > i+2 + self.prec_span:
# 							break
# 						feature = self.words[n][i] + "<" + self.words[n][j]
# 						# find the feature index within the larger feature list
#						# since the precedence features are after the positional features,
# 						# we add the number of positional features minus one.
# 						feature_ndx = self.precFeatures.index(feature) + self.numPosFeatures
# 						self.vectors[n][feature_ndx] = 1.0
						#self.allFeatures[feature_ndx] = feature
# def prec_features(word, prec_span):
# 	features = []
# 	for i in range(len(word)-1):
# 		right_edge = i+1+prec_span
# 		if right_edge > len(word):
# 			right_edge = len(word)
# 		for j in range(i+1, right_edge):
# 			print "i =", i, "; j =", j, ";", word[i], ",", word[j]
# 			try: feature = word[i] + "<" + word[j]
# 			except IndexError: break
# 			#print "*", feature
# 			#feature_ndx = self.precFeatures.index(feature) + self.numPosFeatures
# 			features.append(feature)
# 		print "*features =", features
# 	return features
				for i in range(len(self.words[n]) -1):
					right_edge = i+1+self.prec_span
					if right_edge > len(self.words[n]):
						right_edge = len(self.words[n])
					#print "encode", 16, i
					#sys.stdout.flush()
					for j in range(i+1, right_edge):
						#print "encode", 17
						#sys.stdout.flush()
						try: feature = self.words[n][i] + "<" + self.words[n][j]
						except IndexError: continue
						if isinstance(feature, (unicode)) == False:
							feature = unicode(feature, 'utf8')
						#print "encode", 17.5
						#sys.stdout.flush()
						feature_ndx = self.precFeatures.index(feature) + self.numPosFeatures
						self.vectors[n][feature_ndx] = 1.0
						#print "**ENCODE**", i, j, feature, unicode(self.words[n]), u"feature_ndx =", feature_ndx, unicode(self.vectors[n][feature_ndx])
						#print "**ENCODE**"
						#sys.stdout.flush()
				#print "*end of word*"
				#sys.stdout.flush()
			
			if self.bigrams:                                               
				### encode precedence features
				# The value "len(self.words[n])" is the length (in characters) of the n-th word
				for i in range(len(self.words[n])-1):
					for j in range(i+1,len(self.words[n])):
						# self.words[n][i] is the i-th character of the n-th word.
						feature = self.words[n][i] + "+" + self.words[n][j]
						feature_ndx = self.bigramFeatures.index(feature) + self.numPosFeatures + self.numPrecFeatures
						self.vectors[n][feature_ndx] = 1.0
						#self.allFeatures[feature_ndx] = feature
				##################################################
	cpdef object getFeatures(self):
		return self.allFeatures
                        
	cpdef object getVectors(self):
		return self.vectors

	cpdef int writeVectorsToFile(self, object outputFile):
		fobj = codecs.open(outputFile, 'w', encoding='utf-8')
		# the alphabet is printed on the first line
		##print "encode", 19
		#sys.stdout.flush()
		alphaStr = "".join(self.alphabet)
		#alpha_uni = alphaStr
		#print "ALPHA_UNI_1* =", unicode(alpha_uni)
		#if isinstance(alphaStr, (unicode)) == False:
			# alpha_uni = unicode(alphaStr, 'utf-8')
			# alpha_uni = alphaStr.decode('utf8')
			#alpha_uni = unicode(alphaStr)
		#print "ALPHA_UNI_2 =", alpha_uni  #alpha_uni.encode('utf8')
		# if alpha_uni[0] != "#":
		# 	alpha_uni += "#"
		fobj.write("#" + alphaStr + "\n")
		##sys.stdout.write("&&& alpha_uni = " + alpha_uni + "\n")
		for i in range(len(self.vectors)):
			for item in self.vectors[i]:
				#print item
				fobj.write(unicode(str(item), 'utf8'))
				#fobj.write(str(item))
				if self.vectors[i].index(item) < (len(self.vectors[i]) - 1):
					fobj.write("  ")
			#sys.stdout.flush()
			fobj.write("\n")
		##print "encode", 20
		fobj.close()
	
def main(inputFile, outputFile):
	features = Features(inputFile)
	features.encodeWords()
	features.writeVectorsToFile(outputFile)
	
if __name__ == "__main__":
	inputFile = sys.argv[1]
	outputFile = sys.argv[2]
	main(inputFile, outputFile)
			
