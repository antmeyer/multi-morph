#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os,sys,re,math,pprint
import random
from random import choice
from StringIO import StringIO
from numpy import *
from numpy.linalg import *

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
		fobj = open(corpusFile, 'r')
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
                
		for line in fobj.readlines():
			string = line
			string = string.replace("\n","")
			string = string.replace("\r","")
			if string == "" or re.search("\"", string):
				break 
			if string[0] == "#":
				self.alphabet = list(string[1:])
				self.alphalen = len(self.alphabet)
##				print "Alphabet length, affixlen:"
##				print self.alphalen, self.affixlen
##				print "\n\n\n"
			else:
				dataRow = string.split()
				word = dataRow[0]
				prelimVector = []
				#if self.positional:
				#prelimVector = [0]*(self.affixlen*2*self.alphalen)
				#prelimVector.append(0) We don't need the "duplicate-char "feature.
				#self.numPosFeatures = self.affixlen*2*self.alphalen
				# add feature slots for precedence features.
				## the number of prec. features is the length of the alphabet squared.
				#prelimVector.extend([0]*(self.alphalen*self.alphalen))
				self.words.append(word)
				self.vectors.append(prelimVector)
		fobj.close()
		if self.positional:
			# initialize positional features
			self.numPosFeatures = self.affixlen*2*self.alphalen
			for prelimVector in self.vectors:
				prelimVector.extend([0]*(self.numPosFeatures))
			for i in range(self.affixlen):
				for j in range(self.alphalen):
					self.posFeatures.append(self.alphabet[j] + "@[" + str(i) + "]")
			for i in reversed(range(self.affixlen)):
				for j in range(self.alphalen):
					self.posFeatures.append(self.alphabet[j] + "@[" + str(i-self.affixlen) + "]")
			self.allFeatures.extend(self.posFeatures)
		if self.precedence:
			# initialize positional features
			self.numPrecFeatures = self.alphalen*self.alphalen
			for prelimVector in self.vectors:
				prelimVector.extend([0]*(self.numPrecFeatures))
			self.precFeatures = list()
			for char_x in self.alphabet:
				for char_y in self.alphabet:
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
					self.bigramFeatures.append(char_x + "+" + char_y)
			self.allFeatures.extend(self.bigramFeatures)
        #self.alphabet = list("abgdhwzxviklmnsypcqret")

##	def affixlenDuplication(self, string):
##		sys.stderr.write(string + "\n")
##		if len(string) >= self.affixlen+1 and string[self.affixlen] == string[self.affixlen-1]:
##			return True
##		else:
##			return False
		
	cpdef int encodeWords(self):
		for n in range(len(self.words)):
			if self.positional:
				###################################################### encode positional featuree
				for i in range(self.affixlen):
					try:
						if (len(self.words[n])-1) - i <= 0:
							continue
						char = self.words[n][i]
						alpha_ndx = self.alphabet.index(char)
					except IndexError: continue
					else:
						# determine the index of the feature corresponding
						# to the character
						feature_ndx = i*self.alphalen + alpha_ndx
						self.vectors[n][feature_ndx] = 1.0
						#feature = char + "@" + "[" + str(i) + "]"
						#self.allFeatures[feature_ndx] = feature
				for i in reversed(range(self.affixlen)):
					# for i = 3,2,1,0: (self.affixlen = 4)
					# i = 3 references the last character
					try:
						if i-self.affixlen + len(self.words[n]) <= 0:
							continue
						char = self.words[n][i-self.affixlen]
						alpha_ndx = self.alphabet.index(char)
					except IndexError: continue
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
					for j in range(i+1, right_edge):
						try: feature = self.words[n][i] + "<" + self.words[n][j]
						except IndexError: continue
						feature_ndx = self.precFeatures.index(feature) + self.numPosFeatures
						self.vectors[n][feature_ndx] = 1.0
						print "encode", i, j, feature, self.words[n], "feature_ndx =", feature_ndx, self.vectors[n][feature_ndx]
						sys.stdout.flush()
				print "*end of word*"
				sys.stdout.flush()
			
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
		fobj = open(outputFile, 'w')
		# the alphabet is printed on the first line
		fobj.write("#" + "".join(self.alphabet) + "\n")
		for i in range(len(self.vectors)):
			for item in self.vectors[i]:
				#print item
				fobj.write(str(item))
				if self.vectors[i].index(item) < (len(self.vectors[i]) - 1):
					fobj.write("  ")
			fobj.write("\n")
		fobj.close()
	
def main(inputFile, outputFile):
	features = Features(inputFile)
	features.encodeWords()
	features.writeVectorsToFile(outputFile)
	
if __name__ == "__main__":
	inputFile = sys.argv[1]
	outputFile = sys.argv[2]
	main(inputFile, outputFile)
			
