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
	pat=ur"(qal)|(piel)|(hitpael)|(nifal)|(hufal)|(pual)|(hifil)"
	re_binyan = re.compile(pat, re.UNICODE)
	#pat=ur"(fut)|(past)|(pres)"
	#pat=ur"(fut)|(past)"
	#re_tense = re.compile(pat, re.UNICODE)
	pat=ur"(pos:)([a-z]+)(&)"
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
	# analysis=re_comp8.sub(ur"\2%\4&\4%1%Pl", analysis)
	tense = re_tns.sub(ur"\2",analysis)
	pers = re_pers.sub(ur"\2", analysis)
	gen = re_gen.sub(ur"\2", analysis)
	num = re_num.sub(ur"\2", analysis)
	compositeFeature = (tense + "%" + pers + "%" + gen + "%" + num)
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
	pos = re_getpos.sub(ur"\2", analysis)
	if "tense" in analysis and pos != "part":
		analysis=re_comp1.sub(ur"\2%\4&\4%(2%M)|(23%F)", analysis)
		analysis=re_comp2.sub(ur"\2%\4&\4%23%F%Pl",analysis)
		analysis=re_comp3.sub(ur"\2%\4&\4%3%M",analysis)
		analysis=re_comp4.sub(ur"\2%\4&(past%3%Pl)|(fut%23%Pl)", analysis)
		analysis=re_comp5.sub(ur"\2%\4&fut%2%F%Sg&fut%(2%M)|(23%F)", analysis)
		analysis=re_comp6.sub(ur"\2%\4&fut%2|3%F%Pl&fut%(2%M)|(23%F)", analysis)
		analysis=re_comp7.sub(ur"\2%\4&\4%1%Sg", analysis)
		analysis=re_comp8.sub(ur"\2%\4&\4%1%Pl", analysis)
	elif pos == "part":
		pass
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
			word,analyses_str = line.split("\t")
			self.analysisDict[word] = list()
			#analyses = analyses_str.split()
			analyses = analysisFilter(analyses_str)
			#print analyses
			#tempList = []
			for analysis in analyses:
				#cats = analysis.split("&")
				#cats.sort()
				new_analysis = categoryFilter(analysis)
				#cats = new_analysis.split("&")
				if "fut" in analysis:
					print new_analysis
				# for cat in cats:
				# 	self.analysisDict[word] = cats

def main(fileName):
	my_bl_analyzer = BL_Analyzer(fileName)

if __name__ == '__main__':
	main(sys.argv[1])

