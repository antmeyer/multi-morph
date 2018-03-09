#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os,sys,re,math,pprint,random

def getRootsDatabase(path):
	roots = dict()
	fobj = open(path, "r")
	for line in fobj.readlines():
		string = line.replace("\n", "")
		string = string.replace("\r", "")
		items = string.split("\t")
		roots[items[0]] = items[1]
	fobj.close()
	return roots

def getRootless(path):
	rootlessWords = list()
	fobj = open(path, "r")
	for line in fobj.readlines():
		string = line.replace("\n", "")
		string = string.replace("\r", "")
		string = string.replace("\t", " ")
		items = string.split()
		#sys.stderr.write("items[0]: " + items[0] + "\n")
		if len(items) == 1:
			#sys.stderr.write("items[0]: " + items[0] + "\n")
			if items[0] not in rootlessWords:
				rootlessWords.append(items[0])
	fobj.close()
	return rootlessWords
	
class AnalysisParser:

	"""
	AnalysisParser processes the output of the Hebrew morphological analyzer MILA
	for a cluster of words.
	
	It goes through the words' analyses and compiles two dictionaries:
	
	1.) "self.wordsAndClasses", which is actually a dictionary of dictionaries. Its primary keys 
	are the words themselves.(Ordinarily we might be concerned about duplicating words, but this is 
	not a problem here, since every word occurrence in a cluster is unique.) Its secondary keys are the 
	morphological classes, or categories, that constitute an analysis. In the inner dictionaries, the value 
	of each class key is the frequency of that class. 
	** Note that this dictionary will be merged with the wordsAndClasses dictionaries of other clusters, 
	and when this happens, the duplicate-word issue will become relevant, since the same word may occur 
	in multiple clusters. But we will rely on the conflict-resolving behavior of python's "update" method to 
	handle this.
	
	2.) "self.clustersAndClasses": this is also a dictionary of dictionaries. The primary key is
	the ID of a cluster, and the secondary keys are the morphological features that are present in the
	cluster's analyses. Now, only a single cluster ID is given to AnalysisParser as input, so this 
	dictionary will have only one outer (or primary) key. However, in another module, this single-cluster 
	dictionary will be merged with the "clustersAndClasses" dictionaries of other clusters.
	
	In the MA's output, ambiguous words have multiple analyses, each occupying a separate line. 
	The ambiguous word in question is repeated at the beginning of each such line. 
	AnalysisParser handles the multiple analyses of an ambiguous word by combining them in a single 
	"self.wordsAndClasses" dictionary entry.
	"""

	def __init__(self, fileObjLines, clusterID, corpusFile):
		self.roots_db = getRootsDatabase("../data/roots_db.txt")
		#self.rootlessList = getRootless("../data/" + corpusFileName)
		self.rootlesslist = getRootless(corpusFile)
		self.hasRoot = False
		#print "\n\n\n*************************************\n\nRoot list:"
		#sys.stderr.write("\n\n\n" + str(self.rootlessList) + "\n\n\n") 
		self.prefixes = list("bklmew")
		self.prefixes.extend(["me", "ke"])
		self.numWords = 0
		analysisFeatures = list()
		self.nominals = ["noun","adjective","properName"]
		wordTypes = list()
		prevLineWord = None
		currentWord = ""
		unseenWord = False
		differentWord = False
		skipAnalysis = False
		analyses = dict()
		self.wordsAndClasses = dict()
		self.clustersAndClasses = dict()
		self.clustersAndClasses[clusterID] = dict()
		self.clustersAndWords = dict()
		self.clustersAndWords[clusterID] = list()
		posList = list()
		fileObjLines.append("#\t##")
		for line in fileObjLines:
			#analyses.append([]) #append a new (empty) feature list for the new line (i.e., analysis)
			if line[0] == "\n" or line[0] == "\r":
				continue
# 			if skipAnalysis:
# 				skipAnalysis = False
# 				continue
			string = line
			string = string.replace("\n", "")
			string = string.replace("\r", "")
			items = string.split("\t")
			prevLineWord = currentWord
			currentWord = items.pop(0)
			string = items.pop(0)
			if string == currentWord:
				#sys.stderr.write("\n\n******* " + currentWord + " = " + new_str + "\n\n")
				continue
			if currentWord != prevLineWord and prevLineWord != "":
				differentWord = True
			else:
				differentWord = False
			if differentWord:
				# Filter analyses
				for prefix in analyses:
					# initialize flags for parts of speech adj, noun, and particple.
					adjhere = list()
					nounhere = list()
					parthere = list()
					# analyses[prefix] is a list of analyses. It is a kind of "super" analysis.
					analyses[prefix].sort()
# 					sys.stderr.write("analyses[" + prefix + "]:" + str(analyses[prefix]) + "\n")
					for i in range(len(analyses[prefix])):
						# i is the index of an entire analysis.
						analysis = analyses[prefix][i]
						# each analysis is a list of categories, i.e., feature-value pairs.
						if re.match("adj", analysis[0]):
						#if analysis[0] == "pos:adjective":
							adjhere.append(analysis)
						if analysis[0] == "pos:noun":
							nounhere.append(analysis)
						if analysis[0] == "pos:participle":
							parthere.append(analysis)
					if len(parthere) > 0:
						#sys.stderr.write("\n*** participle present ***" + "\n")
						#if adjhere is not empty:
						for analysis in adjhere:
							analyses[prefix].remove(analysis) 
						#if nounhere is not empty:
						for analysis in nounhere:
							analyses[prefix].remove(analysis)
# 						sys.stderr.write("*analyses[" + prefix + "]:" + str(analyses[prefix]) + "\n\n")
				discardList = ["M%Sg", "adjective%M%Sg", "adjective%M%Sg%cstr", "M%Sg%cstr", "adjective%M%Pl", "F%Pl%cstr", "adjective%F%Pl", "adjective%F%Pl%cstr"]
				#keepList = ["pos:adverb", "pos:adjective", "pos:numeral_cardinal", "pos:numeral_ordinal"]
				keepList = ["pos:adverb", "pos:adjective", "pos:numeral_cardinal", "pos:numeral_ordinal"]
				for prefix in analyses:
					for a in range(len(analyses[prefix])):
						analysis = analyses[prefix][a]
						i = 0
						while i < len(analysis):
							if re.match("pos:", analysis[i]):
								if analysis[i] not in keepList:
									analysis.pop(i)  # This pops the i-th feature.
								else:
									i+=1
							elif analysis[i] in discardList:
								errout = "*** " + feature + " in discardList ***"
								#sys.stderr.write(errout + "\n")
								analysis.pop(i)
								errout = "\tnew analysis: " + str(analysis)
								#sys.stderr.write(errout + "\n")
# 								if "M%Sg" in analysis:
# 									sys.stderr.write("*** errant analysis: " + str(analysis) + "\n")	
							else:
								i+=1
							
				if self.wordsAndClasses.has_key(prevLineWord) == False:
					unseenWord = True
					self.numWords+=1
					self.wordsAndClasses[prevLineWord] = dict()
					self.clustersAndWords[clusterID].append(prevLineWord)
				else:
					unseenWord = False
				# Go through the analyses to tally categories
				#sys.stderr.write("\n\nWord to be added (previous word): " + str(prevLineWord))
# 				for prefix in analyses:
# 				for analysis in analyses[prefix]:
# 					if "M%Sg" in analysis:
# 						sys.stderr.write("*** errant analysis: " + str(analysis) + "\n")
				counter1 = 0
				for prefix in analyses:
					counter2=0
					counter1+=1
					#sys.stderr.write("\n" + prevLineWord)
					#sys.stderr.write("\n" + str(counter1))
					for analysis in analyses[prefix]:
						counter2+=1
						#sys.stderr.write("\n  " + str(counter1) + "." + str(counter2) + " " + str(analysis))
						#if "M%Sg" in analysis:
							#sys.stderr.write("\n%%%%%%%%%%%%%% errant analysis: " + str(analysis) + "\n")
					#sys.stderr.write("\n\nprefix: " + str(prefix))
					#sys.stderr.write("\n")
					for analysis in analyses[prefix]:
						# each analysis is a line. Therefore, with each new analysis, there is
						# a possibility that a feature will be duplicated.
						#runningTotal = 0
						#sys.stderr.write("\n***analysis: " + str(analysis))
						#sys.stderr.write("\n\tfeatures:")
						for featureSpec in analysis:
							#sys.stderr.write("\n\t" + str(featureSpec))
							#sys.stderr.write("  old count: " + str(self.wordsAndClasses[prevLineWord][featureSpec]) + "  ")
							# right now we are looping over the categories of a particular category list.
							#sys.stderr.write(str(self.wordsAndClasses[prevLineWord]) + "\n\n")
							#sys.stderr.write(self.wordsAndClasses[prevLineWord] + "\n")
							if self.wordsAndClasses[prevLineWord].has_key(featureSpec):
								#self.wordsAndClasses[currentWord][featureSpec] += 1
								# We don't want to count multiple occurrences of a feature for the same word.
								# we only want to count a feature once per word. 
								# Ambiguous words may contribute new (previously unseen) features,
								# but they cannot add more instances of a feature that has already been counted.
								# Note that "feature" = "class".
								pass
							else:
								self.wordsAndClasses[prevLineWord][featureSpec] = 1
							if unseenWord:
								if self.clustersAndClasses[clusterID].has_key(featureSpec):
									self.clustersAndClasses[clusterID][featureSpec] += 1
								else:
									self.clustersAndClasses[clusterID][featureSpec] = 1
							else:
								# if unseenWord is False, it means that the current word as already been seen.
								# in this case, we need to be careful not to increase the counts of previously
								# seen features (i.e., classes).
								if self.clustersAndClasses[clusterID].has_key(featureSpec):
									pass
								else:
									self.clustersAndClasses[clusterID][featureSpec] = 1
							#sys.stderr.write("  freq(" + prevLineWord + " & " + featureSpec + "): " + str(self.wordsAndClasses[prevLineWord][featureSpec]) + ";")   #+ " / " + str(self.numWords) + ";")
							#sys.stderr.write("  freq(" + featureSpec + " & " + clusterID  + "): " + str(self.clustersAndClasses[clusterID][featureSpec]))     #+ " / " + str(len(self.clustersAndClasses[clusterID])))
							#runningTotal += self.clustersAndClasses[clusterID][featureSpec]
						#sys.stderr.write("\n\t***total classes in cluster: " + str(runningTotal))
						#sys.stderr.write("\n")
						unseenWord = False
					# we now need to set unseenWord to False because, in going on to the next prefix entry,
					# we might count categories that we have already seen in the preceding prefix entry.
					#unseenWord = False	
				analyses = dict()
			posList = []
			#sys.stderr.write("\n\n")
			# begin collecting info for the currentWord
			if string == "##":
				break
			if string == "[":
				string = items.pop(0)
			#[+id]7449[+undotted]heib[+transliterated]heib
			pattern = "\[\+id\](.+)\[\+transliterated\]([a-z]+)"
			string = re.sub(pattern, "", string)
			features = string.split("[")
			if features[0] == '':
				features.pop(0)
			try: root = self.roots_db[currentWord]
			except KeyError:
				root = None
				self.hasRoot = False
			else:
				features.append("+realroot]" + root)
				self.hasRoot = True
			pos = ""
			person = ""
			number = ""
			gender = ""
			genderNumber = ""
			construct = ""
			binyan = ""
			tense = ""
			pgn = ""
			prefix = ""
			processedFeatures = list()
			#sys.stderr.write("Features of the current word: " + currentWord + "\n")
			for featureStr in features:
				#sys.stderr.write("\t" + featureStr + "\n")
				featureSpecs = list()
				featureStr = featureStr.lstrip()
				items = featureStr.split("]")
				feature = items[0].replace("+","")
				val = items[1].replace("+","")
				#sys.stderr.write(feature + " " + val + "\n")
				#sys.stderr.write(val + "\n")
				## Wait until very end to append pos feature.
				## pos will be stored in a variable that can be modified at any point in the process.
				#####################################
				# Absolute throw-aways
				#if feature == "id" or feature == "undotted" or feature == "transliterated":
				#	continue
				#if feature == "register" or feature == "root":
				if feature == "register":
					continue
				if feature == "definiteness" and val == "false":
					continue
				if feature == "construct":
					if val == "true":
						construct = "%cstr"
					continue
# 				if val == "-":  
# 					# MILA sometimes outputs only a plus or minus sign as a feature's value, but this is rare.
# 					# This is probably an error.
# 					continue
				#####################################
				val = val.replace(" and ", "")
				#####################################
				if feature == "definiteness" and val == "true":
					pattern = "^w?(e|m)?h"
					if re.search(pattern, currentWord):
						featureSpecs.append("prefix:h")
						prefix = "h"
				elif feature == "gender":
					val = val.replace("masculine", "M")
					val = val.replace("feminine", "F")
					if val == "unspecified":
						continue
					gender = val
# 					if re.search("adjective", pos):
# 						pos += "%" + gender
# 					if number != "":
# 						featureSpecs.append(pos)
					#continue	
				elif val == '':
					pos = feature
					posList.append(pos)
					featureSpecs.append("pos:" + pos)
				elif val in self.prefixes:
					prefix = val
					elems = list()
					if val == "me" or val == "ke":
						elems = list(val)
					else:
						elems = [val]
					for elem in elems:
						featureSpecs.append("prefix:" + elem)
				elif feature == "person":
					if val == "unspecified" or val == "any":
						continue
					person = val
					continue
				elif feature == "number":
					if val == "-" or val == "unspecified" or val == "singularplural":
						continue
					number = val
					number = number.replace("singular", "Sg")
					number = number.replace("plural", "Pl")
					number = number.replace("dualPl", "Pl")
					continue
# 					if re.search("adjective", pos):
# 						pos += "%" + number
# 						if gender != "":
# 							featureSpecs.append(pos)
				elif feature == "realroot" or feature == "root":
					root = val
					featureSpecs.append("root:" + val)
					self.hasRoot=True
				elif feature == "type":
				#adjust pos here according to info contained in the "type" feature.
					if pos == "numeral":
						#sys.stderr.write(processedFeatures[0] + ",  " + pos + "\n")
						if val == "ordinal":
							pos = "numeral_ordinal"
						else:
							pos = "numeral_cardinal"
					elif pos == "pronoun":
						pos = pos + "_" + val
					continue
				elif feature == "binyan":
					binyan = val
					continue
				elif feature == "tense":
					tense = val
					continue
				elif re.search("(^possessive)|(^pronomial)", feature):
					if val == "-":
						continue
					val = val.replace("/", "%")
					val = val.replace("MF%", "")
					val = val.replace("p", "")
					feature = feature.replace("possessiveS", "pro_s")
					feature = feature.replace("pronomialS", "pro_s")
					featureSpecs.append(feature + ":" + val)
					featureSpecs.append("pro_suffix_state")
				else:
					if val == "-":
						continue
					val = val.replace(" ", "_")
					if feature == "person/gender/number":
						pgn = val
						continue
# 					if feature == "definiteness":
# 						pass
					else:
						featureSpecs.append(feature + ":" + val)
				if len(featureSpecs) == 1 and re.match("pos:", featureSpecs[0]):
# 					if re.search("adjective", featureSpecs[0]):
# 						newFeature = featureSpecs[0][4:] 
# 						processedFeatures.insert(0, newFeature)
					processedFeatures.insert(0, featureSpecs[0])
				else:
					for featureSpec in featureSpecs:
						if featureSpec not in processedFeatures:
							processedFeatures.append(featureSpec)	
					#processedFeatures.extend(featureSpecs)
				featureSpecs = list()
			if re.search("adjective", processedFeatures[0]):
				#featureSpecs[0] = featureSpecs[0][4:]
				newFeature = "adjective"
				if gender != "":
					newFeature += "%" + gender
				if number != "":
					newFeature += "%" + number
				if newFeature != "adjective":
					processedFeatures.insert(1, newFeature)
			if processedFeatures[0] == "pos:numeral":
				#sys.stderr.write(processedFeatures[0] + ",  " + pos + "\n")
				processedFeatures[0] = "pos:" + pos

			if processedFeatures[0] == "pos:preposition" and pgn != "":
				val = pgn.replace("/", "%")
				val = val.replace("MF%", "")
				val = val.replace("p", "")
				processedFeatures.append("pro_suffix:" + val)
			genderNumberFeature = ""
			if person != "" and re.match("pronoun", pos) == True:
				processedFeatures.append("person:" + person)
				processedFeatures.append("gender:" + gender)
				processedFeatures.append("number:" + number)
			else: 
				if gender != "" and number != "":
					genderNumber = gender + "%" + number + construct
				else:
					genderNumber = ""
				if genderNumber != "":
					genderNumberFeature += genderNumber
				if genderNumberFeature != "":
					processedFeatures.append(genderNumberFeature)
			# binyan stem features
			if binyan != "":
				if tense == "beinoni":
					if binyan == "Pa'al":
						stemFeature = binyan + "%participle"
						processedFeatures.append(stemFeature)
					elif binyan == "Nif'al":
						stemFeature = binyan + "%suffix_stem"
						processedFeatures.append(stemFeature)
					else:
						stemFeature = binyan + "%prefix_stem"
						prefixFeature = "participle_prefix"
						processedFeatures.extend([stemFeature, prefixFeature])
				elif tense == "past":
					stemFeature = binyan + "%suffix_stem"
					processedFeatures.append(stemFeature)
				else:
					stemFeature = binyan + "%prefix_stem"
					processedFeatures.append(stemFeature)
				# inflection features
				if tense == "future":
					if pgn != "":
						items = pgn.split("/")
						#sys.stderr.write("****************" + pgn + "\n")
						try: p = items[0]
						except IndexError:
							p = ""
						try: g = items[1]
						except IndexError:
							g = ""
						try: n = items[2]
						except IndexError:
							n = ""
					#future%(2%M)|(2|3%F) 2.m. or (2.f or 3.f)
					# In the latter case, we have either 2.m/f.pl or 2.f.s.
					if (p == "2p" and (g == "M" or g == "MF")):
						processedFeatures.append("future%(2%M)|(2|3%F)")
						if n == "Pl":
							processedFeatures.append("(past%3%Pl)|(future%2|3%Pl)")
					elif (p == "3p" and g == "F"):
						processedFeatures.append("future%(2%M)|(2|3%F)")
						if n == "Sg":
							processedFeatures.append("future%(2%M)|(2|3%F)")
						if n == "Pl":
							processedFeatures.append("future%2|3%F%Pl")
							#\texttt{future\%2\%F\%Sg)}
					elif p == "3p" and g == "MF":
						processedFeatures.append("future%(2%M)|(2|3%F)")
						if n == "Pl":
							processedFeatures.append("(past%3%Pl)|(future%2|3%Pl)")
							#\texttt{future\%2\%F\%Sg)}
					elif p == "2p" and g == "F":
						processedFeatures.append("future%(2%M)|(2|3%F)")
						if n == "Sg":
							#\texttt{future\%2\%F\%Sg)}
							processedFeatures.append("future%2%F%Sg")
						elif n == "Pl":
							processedFeatures.append("future%2|3%F%Pl")
					# the following takes care of 3.m.sg and 3.m.pl
					elif p == "3p" and g == "M":
						processedFeatures.append("future%3%M")
						if n == "Pl":
							processedFeatures.append("(past%3%Pl)|(future%2|3%Pl)")	
					elif p == "1p":
						if n == "Sg":
							processedFeatures.append("future%1%Sg")
						elif n == "Pl":
							processedFeatures.append("future%1%Pl")
					else:
						p = p.replace("p", "")
						compositeFeature = (tense + "%" + p + "%" + g + "%" + n)
						compositeFeature = compositeFeature.replace("MF%", "")
						processedFeatures.append(compositeFeature) 
				elif tense == "past":
					if pgn != "":
						items = pgn.split("/")
						#sys.stderr.write("****************" + pgn + "\n")
						try: p = items[0]
						except IndexError:
							p = ""
						try: g = items[1]
						except IndexError:
							g = ""
						try: n = items[2]
						except IndexError:
							n = ""
					if p == "3p" and g == "M" and n == "Sg":
						pass
					elif p == "2p" and n == "Sg":
						processedFeatures.append("past%2%Sg")
					elif p == "3p" and n == "Pl":
						processedFeatures.append("(past%3%Pl)|(future%2|3%Pl)")
					else:
						p = p.replace("p", "")
						compositeFeature = (tense + "%" + p + "%" + g + "%" + n)
						compositeFeature = compositeFeature.replace("MF%", "")
						processedFeatures.append(compositeFeature)
				elif tense == "imperative":
					if pgn != "":
						items = pgn.split("/")
						#sys.stderr.write("****************" + pgn + "\n")
						try: p = items[0]
						except IndexError:
							p = ""
						try: g = items[1]
						except IndexError:
							g = ""
						try: n = items[2]
						except IndexError:
							n = ""
					if p == "2p" and g == "M" and n == "Sg":
						pass
					else:
						p = p.replace("p", "")
						compositeFeature = (tense + "%" + p + "%" + g + "%" + n)
						compositeFeature = compositeFeature.replace("MF%", "")
						compositeFeature = compositeFeature.replace("%%%", "")
						processedFeatures.append(compositeFeature)
				else:
					if tense != "beinoni":
						items = pgn.split("/")
						#sys.stderr.write("****************" + pgn + "\n")
						try: p = items[0]
						except IndexError:
							p = ""
						try: g = items[1]
						except IndexError:
							g = ""
						try: n = items[2]
						except IndexError:
							n = ""
						p = p.replace("p", "")
						compositeFeature = (tense + "%" + p + "%" + g + "%" + n)
						compositeFeature = compositeFeature.replace("MF%", "")
						compositeFeature = compositeFeature.replace("%%%", "")
						processedFeatures.append(compositeFeature)
# 			else:
# 				if pos == "adjective":
# 					processedFeatures.append("adjective%" + gender + "%" + number)
			if self.hasRoot == False:
				#sys.stderr.write("*****ROOTLESS\n")
				#rootlessFeature = "rootless"
				if pos in self.nominals:
					rootlessFeature = "rootless:nominal"
					processedFeatures.append(rootlessFeature)
			if skipAnalysis:
				skipAnalysis = False
				continue
			if analyses.has_key(prefix):
				# prefix is the empty string by default.
				# each entry in analyses[prefix] is a list.
				# analyses[prefix] is itself a list; in particular, it is a list of lists.
				analyses[prefix].append(processedFeatures)
			else:
				analyses[prefix] = list()
				analyses[prefix].append(processedFeatures)
		
# 			for prefix in analyses:
# 				# initialize flags for parts of speech adj, noun, and particple.
# 				adjhere = False
# 				nounhere = False
# 				parthere = False
# 				# analyses[prefix] is a list of analyses. It is a kind of "super" analysis.
# 				analyses[prefix].sort()
# 				for i in range(len(analyses[prefix])):
# 					analysis = analyses[prefix][i]
# 					# each analysis is a list of categories, i.e., feature-value pairs.
# 					if analysis[0] == "pos:adjective":
# 						adjhere = i
# 					if analysis[0] == "pos:noun":
# 						nounhere = i
# 					if analysis[0] == "pos:particple":
# 						parthere = i
# 				if parthere:
# 					if adjhere:
# 						analyses[prefix].pop(adjhere) 
# 					if nounhere:
# 						analyses[prefix].pop(nounhere)
# 			
# 			for prefix in analyses:
# 				for analysis in analyses[prefix]:
# 					for featureSpec in analysis:
# 						# right now we are looping over the categories of a particular category list.
# 						sys.stderr.write(str(self.wordsAndClasses[currentWord]) + "\n\n")
# 						if self.wordsAndClasses[currentWord].has_key(featureSpec):
# 							#self.wordsAndClasses[currentWord][featureSpec] += 1
# 							# We don't want to count multiple occurrences of a feature for the same word.
# 							# we only want to count a feature once per word. 
# 							# Ambiguous words may contribute new (previously unseen) features,
# 							# but they cannot add more instances of a feature that has already been counted.
# 							# Note that "feature" = "class".
# 							pass
# 						else:
# 							self.wordsAndClasses[currentWord][featureSpec] = 1
# 						if unseenWord:
# 							#unseenWord = False
# 							if self.clustersAndClasses[clusterID].has_key(featureSpec):
# 								self.clustersAndClasses[clusterID][featureSpec] += 1
# 							else:
# 								self.clustersAndClasses[clusterID][featureSpec] = 1
# 						else:
# 							# if unseenWord is False, it means that the current word as already been seen.
# 							# in this case, we need to be careful only to increase the counts of previously
# 							# unseen features (i.e., classes).
# 							if self.clustersAndClasses[clusterID].has_key(featureSpec):
# 								pass
# 							else:
# 								self.clustersAndClasses[clusterID][featureSpec] = 1
			
# 			if unseenWord:
# 				unseenWord = False
			#sys.stderr.write("\n")
		#pprint.pprint(str(self.clustersAndClasses))
							
	def getWordsAndClasses(self):
# 		for word in self.wordsAndClasses:
# 			if "M%Sg" in self.wordsAndClasses[word]:
# 				sys.stderr.write(word + ": " + str(self.wordsAndClasses[word]) + "\n")
		return self.wordsAndClasses
	
	def getClustersAndClasses(self):
		return self.clustersAndClasses
		
	def getClusterCardinality(self):
		return self.numWords
		
	def getClustersAndWords(self):
		return self.clustersAndWords
					
					
					
					
				