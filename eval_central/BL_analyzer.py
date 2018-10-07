#!/usr/bin/env python
# -*- coding: utf-8 -*-

import math,pprint,random
import regex as re
import sys, codecs
reload(sys)  
sys.setdefaultencoding('utf8')
UTF8Writer = codecs.getwriter('utf8')
sys.stdout = UTF8Writer(sys.stdout)
sys.stderr = UTF8Writer(sys.stderr)

def analysisFilter(analyses_str):
	new_analyses = list()
	analyses=analyses_str.split()
	#print "*",analyses
	if "pos:part" in analyses_str:
		#print "**",analyses_str
		for analysis in analyses:
			if "pos:v" in analysis:
				continue
			elif "pos:adj" in analysis:
				continue
			elif "pos:n" in analysis:
				continue
			else: new_analyses.append(analysis)
		#print "***", "new_analyses:",new_analyses
		return new_analyses
	else:
		return analyses
	

def categoryFilter(analysis):
	isNominal = False
	isVerb = False
	isFreePronoun = False
	root = ""
	ptn = ""
	genNum = ""
	persGenNum = ""
	tense = ""
	tense_form = ""
	form = ""

	pat=ur"(qal)|(piel)|(hitpael)|(nifal)|(hufal)|(pual)|(hifil)"
	re_binyan = re.compile(pat, re.UNICODE)

	pat=ur"(pers:)([123][123]*)(&gen:)([mfu])(&num:)([sgplun]+)(&|$)"
	re_getpgn = re.compile(pat, re.UNICODE)

	#pat=ur"(fut)|(past)|(pres)"
	#pat=ur"(fut)|(past)"
	#re_tense = re.compile(pat, re.UNICODE)
	pat=ur"(pos:)([a-z:_]+)(&)"
	re_getpos = re.compile(pat, re.UNICODE)
	pat = ur"pos:v"
	re_verb = re.compile(pat, re.UNICODE)
	pat = ur"pos:part"
	re_part = re.compile(pat, re.UNICODE)
	pat=ur"qal"
	re_qal = re.compile(pat, re.UNICODE)
	pat = ur"(pers:)([123][123]?)(&|$)"
	re_pers = re.compile(pat, re.UNICODE)
	pat = ur"(gen:)([mf][mf]?)(&|$)"
	re_gen = re.compile(pat, re.UNICODE)
	pat = ur"(num:)((?:sg)|(?:pl))(&|$)"
	re_num = re.compile(pat, re.UNICODE)
	pat = ur"(tense:)([a-z]+)(&|$)"
	re_tns = re.compile(pat, re.UNICODE)
	pat = ur"(root:)([^&]+)(&|$)"
	re_getroot = re.compile(pat, re.UNICODE)
	pat = ur"(pro:)([^&]+)(&|$)"
	re_protype = re.compile(pat, re.UNICODE)
	#tense:fut&pers:23&gen:mf&num:sg
	#"future%(2%M)|(2|3%F)"
	# if tense == "future":
	# 	if p == "3p" and g == "F" and n = "Sg": "future%(2%M)|(2|3%F)"
	# 	elif p == "3p" and g == "F" and n = "Pl": "future%2|3%F%Pl"
	# 	elif p == "3p" and (g == "M" or g == "MF") and n == "Sg": "future%3%M"
	# 	elif p == "3p" and (g == "M" or g == "MF") and n == "Pl": "(past%3%Pl)|(future%2|3%Pl)"
	# 	elif p == "2p" and (g == "M" or g == "MF"): "future%(2%M)|(2|3%F)"
	# 	elif p == "2p" and g == "F" and n = "Sg": "future%2%F%Sg" and "future%(2%M)|(2|3%F)"
	# 	elif p == "2p" and g == "F" and n = "Pl": "future%2|3%F%Pl" and "future%(2%M)|(2|3%F)"
	# 	elif p == "1p" and n = "Sg": "future%1%Sg"
	# 	elif p == "1p" and n = "Pl": "future%1%Pl"
		
	# pat = ur"tense:fut&pers:3&gen:fm&num:sg" -> "future%(2%M)|(2|3%F)"
	# pat = ur"tense:fut&pers:3&gen:fm&num:pl" -> "future%2|3%F%Pl"
	# pat = ur"tense:fut&pers:3&gen:unsp&num:sg" -> "future%3%M"
	# pat = ur"tense:fut&pers:3&gen:unsp&num:pl" -> "(past%3%Pl)|(future%2|3%Pl)"
	# pat = ur"tense:fut&pers:2&gen:mf?" -> "future%(2%M)|(2|3%F)" 
	# pat = ur"tense:fut&pers:2&gen:fm&n:sg" -> "future%2%F%Sg&future%(2%M)|(2|3%F)"
	# pat = ur"tense:fut&pers:2&gen:fm&n:pl" -> "future%2|3%F%Pl&future%(2%M)|(2|3%F)"
	# pat = ur"tense:fut&pers:1&n:sg" -> "future%1%Sg"
	# pat = ur"tense:fut&pers:1&n:pl" -> "future%1%Pl"
	
	# pat = ur"(ptn:)([a-z]+)(&tense:)(fut)(&pers:3&gen:f&num:sg)" -> "future%(2%M)|(2|3%F)"
	# ur"\2%\4&\4%(2%M)|(23%F)"
	#pat = ur"(tense:fut&pers:)(2&gen:unsp&num:)((?:sg)|(?:pl)))|(3&gen:fm&num:sg)" -> "future%(2%M)|(2|3%F)" 
	#pat = ur"(tense:fut&pers:)(2&gen:unsp&num:)((?:sg)|(?:pl)|(?:unsp)))|(3&gen:fm&num:sg)" -> "future%(2%M)|(2|3%F)"
	pat = ur"(ptn:)([a-zC]+)(&tense:)(fut)(&pers:)((?:2&gen:[mu]&num:[sgplu]+)|(?:3&gen:f&num:sg))(&|$)" #-> "future%(2%M)|(2|3%F)" 
	re_comp1 = re.compile(pat, re.UNICODE) 
	#analysis=re_comp1.sub(ur"\2%\4&\4%(2%M)|(23%F)", analysis)
	pat = ur"(ptn:)([a-zC]+)(&tense:)(fut)(&pers:3&gen:f&num:pl)(&|$)" #-> "future%2|3%F%Pl"
	re_comp2 = re.compile(pat, re.UNICODE) 
	#analysis=re_comp2.sub(ur"\2%\4&\4%23%F%Pl",analysis)
	pat = ur"(ptn:)([a-zC]+)(&tense:)(fut)(&pers:3&gen:m&num:sg)(&|$)" #-> "future%3%M"
	re_comp3 = re.compile(pat, re.UNICODE) 
	#analysis=re_comp3.sub(ur"\2%\4&\4%3%M",analysis)
	pat = ur"(ptn:)([a-zC]+)(&tense:)(fut)(&pers:3&gen:u&num:pl)(&|$)" #-> "(past%3%Pl)|(future%2|3%Pl)"
	re_comp4 = re.compile(pat, re.UNICODE) 
	#analysis=re_comp4.sub(ur"\2%\4&(past%3%Pl)|(future%23%Pl)", analysis)
	pat = ur"(ptn:)([a-zC]+)(&tense:)(fut)(&pers:2&gen:f&num:sg)(&|$)" #-> "future%2%F%Sg&future%(2%M)|(2|3%F)"
	re_comp5 = re.compile(pat, re.UNICODE) 
	# analysis=re_comp5.sub(ur"\2%\4&future%2%F%Sg&future%(2%M)|(23%F)", analysis)
	pat = ur"(ptn:)([a-zC]+)(&tense:)(fut)(&pers:2&gen:f&num:pl)(&|$)" #-> "future%2|3%F%Pl&future%(2%M)|(2|3%F)"
	re_comp6 = re.compile(pat, re.UNICODE) 
	#ur"\2%\4&future%2|3%F%Pl&future%(2%M)|(23%F)"
	# analysis=re_comp6.sub(ur"\2%\4&future%2|3%F%Pl&future%(2%M)|(23%F)", analysis)
	pat = ur"(ptn:)([a-zC]+)(&tense:)(fut)(&pers:1&gen:u&num:sg)(&|$)" #-> "future%1%Sg"
	re_comp7 = re.compile(pat, re.UNICODE) 
	# analysis=re_comp7.sub(ur"\2%\4&\4%1%Sg", analysis)
	pat = ur"(ptn:)([a-zC]+)(&tense:)(fut)(&pers:1&gen:u&num:pl)(&|$)" #-> "future%1%Pl"
	re_comp8 = re.compile(pat, re.UNICODE)

	# PAST-TENSE FORMS
	pat = ur"(ptn:)([a-zC]+)(&tense:)(past)(&pers:3&gen:m&num:sg)(&|$)"
	re_3_m_sg = re.compile(pat, re.UNICODE)
	pat = ur"(ptn:)([a-zC]+)(&tense:)(past)(&pers:3&gen:f&num:sg)(&|$)"
	re_3_f_sg = re.compile(pat, re.UNICODE)
	pat = ur"(ptn:)([a-zC]+)(&tense:)(past)(&pers:2&gen:m&num:sg)(&|$)"
	re_2_m_sg = re.compile(pat, re.UNICODE)
	pat = ur"(ptn:)([a-zC]+)(&tense:)(past)(&pers:2&gen:f&num:sg)(&|$)"
	re_2_f_sg = re.compile(pat, re.UNICODE)
	pat = ur"(ptn:)([a-zC]+)(&tense:)(past)(&pers:3&gen:[mfu]&num:pl)(&|$)"
	re_3_pl = re.compile(pat, re.UNICODE) 
	pat = ur"(ptn:)([a-zC]+)(&tense:)(past)(&pers:1&gen:[mfu]&num:sg)(&|$)"
	re_1_sg = re.compile(pat, re.UNICODE) 
	pat = ur"(ptn:)([a-zC]+)(&tense:)(past)(&pers:1&gen:[mfu]&num:pl)(&|$)"
	re_1_pl = re.compile(pat, re.UNICODE) 

				# elif tense == "past":
				# 	if pgn != "":
				# 		items = pgn.split("/")
				# 		#sys.stderr.write("****************" + pgn + "\n")
				# 		try: p = items[0]
				# 		except IndexError:
				# 			p = ""
				# 		try: g = items[1]
				# 		except IndexError:
				# 			g = ""
				# 		try: n = items[2]
				# 		except IndexError:
				# 			n = ""
				# 	if p == "3p" and g == "M" and n == "Sg":
				# 		#pat = ur"(ptn:)([a-zC]+)(&tense:)(past)(&pers:3&gen:m&num:sg)(&|$)"
				# 		#re_comp9 = re.compile(pat, re.UNICODE)
				# 		pass
				# 	elif p == "2p" and n == "Sg":
				# 		#pat = ur"(ptn:)([a-zC]+)(&tense:)(past)(&pers:2&gen:[mfu]&num:sg)(&|$)"
				# 		#re_comp10 = re.compile(pat, re.UNICODE)
				# 		processedFeatures.append("past%2%Sg")

				# 	elif p == "3p" and n == "Pl":
				# 		#pat = ur"(ptn:)([a-zC]+)(&tense:)(past)(&pers:3&gen:[mfu]&num:pl)(&|$)"
				# 		#re_comp11 = re.compile(pat, re.UNICODE)
				# 		processedFeatures.append("(past%3%pl)|(future%23%pl)")
				# 	else:
				# 		p = p.replace("p", "")
				# 		compositeFeature = (tense + "%" + p + "%" + g + "%" + n)
				# 		compositeFeature = compositeFeature.replace("MF%", "")
				# 		processedFeatures.append(compositeFeature)
	# analysis=re_comp8.sub(ur"\2%\4&\4%1%Pl", analysis)

	# PAST-TENSE FORMS

	tense = re_tns.sub(ur"\2",analysis)
	pers = re_pers.sub(ur"\2", analysis)
	gen = re_gen.sub(ur"\2", analysis)
	num = re_num.sub(ur"\2", analysis)
	pos = re_getpos.sub(ur"\2", analysis)
	root = re_getroot.sub(ur"\2", analysis)
	pro_type = re_protype.sub(ur"\2", analysis)
	if "pos:pro" in analysis:
		isFreePronoun = True
		isNominal = False
		isVerb = False
		genNum = gen + "%" + num
		persNum = pers + "%" + num
		persGenNum = pers + "%" + num + "%" + gen

	if pos == "adj" or pos == "n":
		isNominal = True
		isVerb = False
		genNum = gen + "%" + num
		persGenNum = ""
	elif pos == "v" or pos == "part":
		isVerb = True
		isNominal = False
		genNum = ""
		persGenNum = pers + "%" + num + "%" + gen
	#compositeFeature = (tense + "%" + pers + "%" + gen + "%" + num)
	#pat = ur"(\s|&)(tense:)(fut)(&)(pers:)(2|3|(?:23))(&)(gen:)((?:ms)|(?:unsp))(&)(num:)(sg)"
	# re_comp1 = re.compile(pat, re.UNICODE)
	# #analysis = analysis=re_comp1.sub(ur"\3(2%M)|(2|3%F)", analysis)
	# pat = ur"(\s|&)(tense:)(fut)(&)(pers:)(2|3|(?:23))(&)(gen:)((?:ms)|(?:unsp))(&)(num:)(pl)"
	# re_comp2 = re.compile(pat, re.UNICODE)
	# pat = ur"(\s|&)(tense:)(fut)(&)(pers:)(2|3|(?:23))(&)(gen:)(f)(&)(num:)((?:sg)|(?:pl))"
	# re_comp3 = re.compile(pat, re.UNICODE)
	pat = ur"(pers:[123]+)(&)"
	re_pers0 = re.compile(pat, re.UNICODE)
	pat = ur"(num:[a-z]+)(&)"
	re_num0 = re.compile(pat, re.UNICODE)
	pat = ur"(gen:[a-z]+)(&)"
	re_gen0 = re.compile(pat, re.UNICODE)
	pat = ur"(tense:[a-z]+)(&)"
	re_tns0 = re.compile(pat, re.UNICODE)
	# pat = ur"(pos:)([a-z]+)(&)"
	# re_pos =  re.compile(pat, re.UNICODE)
	pat = ur"(ptn:)([a-z]+)(&)"
	re_ptn = re.compile(pat, re.UNICODE)
	
	if "tense" in analysis and pos != "part":
		# FUTURE
		analysis=re_comp1.sub(ur"\2%prefix_stem&\4%(2%M)|(23%F)", analysis)
		analysis=re_comp2.sub(ur"\2%prefix_stem&\4%23%F%Pl",analysis)
		analysis=re_comp3.sub(ur"\2%prefix_stem&\4%3%M",analysis)
		analysis=re_comp4.sub(ur"\2%prefix_stem&(past%3%Pl)|(fut%23%Pl)", analysis)
		analysis=re_comp5.sub(ur"\2%prefix_stem&\4%2%F%Sg&fut%(2%M)|(23%F)", analysis)
		analysis=re_comp6.sub(ur"\2%prefix_stem&\4%23%F%Pl&fut%(2%M)|(23%F)", analysis)
		analysis=re_comp7.sub(ur"\2%prefix_stem&\4%1%Sg", analysis)
		analysis=re_comp8.sub(ur"\2%prefix_stem&\4%1%Pl", analysis)

		#PAST
		#pat = ur"(ptn:)([a-zC]+)(&tense:)(past)(&pers:3&gen:m&num:sg)(&|$)"
		analysis = re_3_m_sg.sub(ur"\2%suffix_stem&\4%3%M%Sg", analysis)
		#pat = ur"(ptn:)([a-zC]+)(&tense:)(past)(&pers:3&gen:f&num:sg)(&|$)"
		analysis = re_3_f_sg.sub(ur"\2%suffix_stem&\4%3%F%Sg", analysis)
		#pat = ur"(ptn:)([a-zC]+)(&tense:)(past)(&pers:2&gen:m&num:sg)(&|$)"
		analysis = re_2_m_sg.sub(ur"\2%suffix_stem&\4%2%M%Sg", analysis)
		#pat = ur"(ptn:)([a-zC]+)(&tense:)(past)(&pers:2&gen:m&num:sg)(&|$)"
		#re_2_f_sg = re.compile(pat, re.UNICODE)
		analysis = re_2_f_sg.sub(ur"\2%suffix_stem&\4%2%F%Sg", analysis)
		#pat = ur"(ptn:)([a-zC]+)(&tense:)(past)(&pers:3&gen:[mfu]&num:pl)(&|$)"
		analysis = re_3_pl.sub(ur"\2%suffix_stem&\4%3%Pl", analysis)
		#pat = ur"(ptn:)([a-zC]+)(&tense:)(past)(&pers:1&gen:[mfu]&num:sg)(&|$)"
		analysis = re_1_sg.sub(ur"\2%suffix_stem&\4%1%Sg", analysis)
		#pat = ur"(ptn:)([a-zC]+)(&tense:)(past)(&pers:1&gen:[mfu]&num:pl)(&|$)"
		analysis = re_1_pl.sub(ur"\2%suffix_stem&\4%1%Pl", analysis) 

	elif pos == "part":
		#pat = ur"(ptn:)([a-zC]+)(&tense:)(past)(&pers:3&gen:f&num:sg)(&|$)"
		pat = ur"(pos:)(part)(&.*)(&ptn:)([a-zC]+)(&.*)(&gen:)([mf])(&num:)([sgplun]+)(&|$)"
		re_part = re.compile(pat, re.UNICODE)
		#analysis = re_part.sub(ur"\5%prefix_stem&\8%\10\11\6", analysis)
		if ptn == "qal":
			analysis = re_part.sub(ur"\5%participle&\8%\10\11\6", analysis)
			# stemFeature = binyan + "%participle"
			# processedFeatures.append(stemFeature)
		elif binyan == "nifal":
			analysis = re_part.sub(ur"\5%suffix_stem&\8%\10\11\6", analysis)
			# stemFeature = binyan + "%suffix_stem"
			# processedFeatures.append(stemFeature)
		else:
			analysis = re_part.sub(ur"\5%prefix_stem&\8%\10\11\6", analysis)
			# stemFeature = binyan + "%prefix_stem"
			# prefixFeature = "participle_prefix"
			# processedFeatures.extend([stemFeature, prefixFeature])
		# pat = ur"(ptn:)([a-zC]+)(&.*)(&gen:f&num:sg)(&|$)"
		# re_part_f_sg = re.compile(pat, re.UNICODE)
		# analysis = re_part_f_sg.sub(ur"\5%\2&F%Sg", analysis)
		
		# pat = ur"(ptn:)([a-zC]+)(&.*)(&gen:m&num:pl)(&|$)"
		# re_part_m_pl = re.compile(pat, re.UNICODE)
		# analysis = re_part_m_pl.sub(ur"\2%\4&M%Pl", analysis)
		
		# pat = ur"(ptn:)([a-zC]+)(&.*)(&gen:f&num:pl)(&|$)"
		# re_part_f_pl = re.compile(pat, re.UNICODE)
		# analysis = re_part_f_pl.sub(ur"\2%\4&F%Pl", analysis)
		#pat = ur"(ptn:)([a-zC]+)(&tense:)(past)(&pers:3&gen:[mfu]&num:pl)(&|$)"
		# pat = ur"(ptn:)([a-zC]+)(&.*)(&gen:m&num:pl)(&|$)"
		# analysis = re_part_f_pl.sub(ur"\2%\4&\4%3%Pl", analysis)
		# pat = ur"(ptn:)([a-zC]+)(&tense:)(past)(&pers:2&gen:f&num:pl)(&|$)"
		# re_part_f_pl = re.compile(pat, re.UNICODE)
		#pat = ur"(ptn:)([a-zC]+)(&tense:)(past)(&pers:1&gen:[mfu]&num:sg)(&|$)"
		#analysis = re_1_sg.sub(ur"\2%\4&\4%1%Sg", analysis)
		#pat = ur"(ptn:)([a-zC]+)(&tense:)(past)(&pers:1&gen:[mfu]&num:pl)(&|$)"
		#analysis = re_1_pl.sub(ur"\2%\4&\4%1%Pl", analysis) 
		#pass
	# Non-participle nominals
	## construct forms
	if isNominal:
		pat = ur"(pos:)(n|(?:adj))([^\s]*)(&gen:)([fmu])(&num:)([spglundo]+)(&stat:)(cstr)"
		re_cstr = re.compile(pat, re.UNICODE)
		#if (gen = "m" and num = "sg") or (gen = "f" and num = "pl")
		if gen = "f" and num = "pl":
			analysis=re_cstr.sub(ur"\2%\5%\7&\3", analysis)
		else:
			analysis=re_cstr.sub(ur"\2%\9%\5%\7&\3", analysis)

		## absolute (or non-construct) forms
		pat = ur"(pos:)(n|(?:adj))([^\s]*)(&gen:)([fmunsp]+)(&num:)([spglundo]+)"
		re_abs = re.compile(pat, re.UNICODE)
		analysis=re_abs.sub(ur"\2%\5%\7&\3", analysis)
		### get rid of the masc.sg feature, since masc.sg forms are (usually) unmarked
		pat = ur"(n|(?:adj))(\%[mu]\%sg)"
		re_msg = re.compile(pat, re.UNICODE)
		analysis = re_msg.sub(ur"", analysis)

		analysis = analysis.replace("poss:", "xxxxxxxxxx:")
		analysis = analysis.replace("suf:," "xxxxxxxxxx:")
		analysis = analysis.replace("xxxxxxxxxx:", "pro_suf_state&pro_suf:")
		if root == "":
			analysis += "&rootless_nominal"


	# if "poss:" in analysis or "suf:" in analysis:
	# #elif re.search("(^possessive)|(^pronomial)", feature):
	# 	if val == "-":
	# 		continue
	# 	val = val.replace("/", "%")
	# 	val = val.replace("MF%", "")
	# 	val = val.replace("p", "")
	# 	feature = feature.replace("possessiveS", "pro_s")
	# 	feature = feature.replace("pronomialS", "pro_s")
	# 	featureSpecs.append(feature + ":" + val)
	# 	featureSpecs.append("pro_suffix_state")
	return analysis


class BL_Analyzer:
	def __init__(self, bermanAnalysesFile):
		fobj = codecs.open(bermanAnalysesFile,'r',encoding='utf8')
		self.lines = fobj.readlines()
		self.analysisDict = {}
		for line in self.lines:
			line = line.replace("gen:ms", "gen:m")
			line = line.replace("gen:fm", "gen:f")
			line = line.replace("unsp", "u")
			line = line.replace("mf","u")
			line = line.replace("fm","u")
			word,analyses_str = line.split("\t")
			self.analysisDict[word] = dict()
			self.wordsAndClasses = dict()
			self.clustersAndWords = dict()
			self.clustersAndClasses = dict()
			self.numWords = 0
			#analyses = analyses_str.split()
			analyses = analysisFilter(analyses_str)
			#print analyses
			#tempList = []
			for analysis in analyses:
				#cats = analysis.split("&")
				#cats.sort()
				new_analysis = categoryFilter(analysis)
				
				# if "fut" in analysis:
				# 	print new_analysis
				cats = new_analysis.split("&")
				for cat in cats:
					self.analysisDict[word][cat] = 1
			self.clustersAndWords[clusterID].append(word)

	def analyze_words(self, cluster_words, cluster_ID):
		#wordsAndClasses = dict()
		#analyzed_words = list()
		self.clustersAndWords = dict()
		self.clustersAndClasses = dict()
		self.wordsAndClasses = dict()
		self.numWords = len(cluster_words)
		seen_words = []
		unseenWord = True
		for word in cluster_words:
			if word in seen_words: 
				unseenWord = True
			else: 
				seen_words.append(word)
				unseenWord = False

			self.clustersAndWords[clusterID].append(word)
			self.clustersAndClasses[clusterID]
			if self.wordsAndClasses.has_key(word):
				classes = self.self.analysisDict[word].keys()
				self.wordsAndClasses[word].extend(classes)
			else:
				self.wordsAndClasses[word] = classes
				#self.wordsAndClasses[word].extend(self.self.analysisDict[word].keys())
			for feature in classes:
				if unseenWord:
					if self.clustersAndClasses[clusterID].has_key(feature):
						self.clustersAndClasses[clusterID][feature] += 1
					else:
						self.clustersAndClasses[clusterID][feature] = 1
				else:
					# if unseenWord is False, it means that the current word as already been seen.
					# in this case, we need to be careful not to increase the counts of previously
					# seen features (i.e., classes).
					if self.clustersAndClasses[clusterID].has_key(feature):
						pass
					else:
						self.clustersAndClasses[clusterID][feature] = 1
				#sys.stderr.write("  freq(" + prevLineWord + " & " + feature

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


def main(bermanAnalysesFile, clusterWordsFile):
	my_bl_analyzer = BL_Analyzer(bermanAnalysesFile)
	fobj = open(clusterWordsFile, 'r')
	lines = fobj.readlines()
	for line in lines:
		if line[0] == "#":
			#sys.stderr.write(line)
			clusters.append(clusterLines)
			clusterLines = []
		else:
			if line != "\n":
				clusterLines.append(line)
	wordsAndClasses = dict()
	for k in range(len(clusters)):
		str_k = "{0:04d}".format(k)
		#cluster_IDs.append(str_k)
		#my_bl_analyzer = BL_analyzer(bermanAnalysesFile)
		my_bl_analyzer.analyze_words(clusters[str_k], str_k)
		wordsAndClasses.update(my_bl_analyzer.getWordsAndClasses())
	for word in wordsAndClasses.keys()
		features = wordsAndClasses[word].keys()
		sys.stdout.write(word + "\t" + " ".join(features) + "\n")

if __name__ == '__main__':
	main(sys.argv[1], sys.argv[2])


