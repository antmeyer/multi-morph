#!/usr/bin/env python
# -*- coding: utf-8 -*-

import math
import re
import sys, codecs
reload(sys)  
sys.setdefaultencoding('utf8')
UTF8Writer = codecs.getwriter('utf8')
sys.stdout = UTF8Writer(sys.stdout)
sys.stderr = UTF8Writer(sys.stderr)

def analysisFilter(analyses_str):
	new_analyses = list()
	analyses=analyses_str.split()
	####print "*",analyses
	if "pos:part" in analyses_str:
		####print "**",analyses_str
		for analysis in analyses:
			if "pos:v" in analysis:
				continue
			elif "pos:adj" in analysis:
				continue
			elif "pos:n" in analysis:
				continue
			else: new_analyses.append(analysis)
		####print "***", "new_analyses:",new_analyses
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
	pos = ""
	state = ""
	num = ""
	gen = ""
	#tense_form = ""
	form = ""
	##print "\n\n\n\n******* NEW ANALYSIS:", analysis
	# analysis = analysis.replace("&en:u", "&gen:u")
	# analysis = analysis.replace("&src:tbd&", "&")
	# analysis = analysis.replace("&src:tbd", "")
	pat=ur"(qal)|(piel)|(hitpael)|(nifal)|(hufal)|(pual)|(hifil)"
	re_binyan = re.compile(pat, re.UNICODE)

	pat=ur"(pers:)([123][123]*)(&gen:)([mfu])(&num:)([sgplundoma]+)(&|$)"
	re_getpgn = re.compile(pat, re.UNICODE)

	#pat=ur"(fut)|(past)|(pres)"
	#pat=ur"(fut)|(past)"
	#re_tense = re.compile(pat, re.UNICODE)
	#pat = ur"(\t[^\s]*ptn:)([Cauioe]+)((?:&[^\s]*$)|$)"
	pat = ur"(^.*&ptn:)([Ca-z]+)((?:&[^\s]*$)|$)"
	re_getptn = re.compile(pat, re.UNICODE)
	pat=ur"(^.*)(pos:)([a-z]+)(&)((?:&[^\s]*$)|$)"
	re_getpos = re.compile(pat, re.UNICODE)
	pat = ur"pos:v"
	re_verb = re.compile(pat, re.UNICODE)
	pat = ur"pos:part"
	re_part = re.compile(pat, re.UNICODE)
	pat=ur"qal"
	re_qal = re.compile(pat, re.UNICODE)
	pat = ur"(^.*)(&pers:)([123][123]?)((?:&[^\s]*$)|$)"
	re_getpers = re.compile(pat, re.UNICODE)
	pat = ur"(^.*)(&gen:)([mfu])((?:&[^\s]*$)|$)"  #(?:&[^\s]*$)|$)"
	re_getgen = re.compile(pat, re.UNICODE)
	pat = ur"(^.*)(&num:)((?:sg)|(?:pl)|(?:duo))((?:&[^\s]*$)|$)"
	re_getnum = re.compile(pat, re.UNICODE)
	pat = ur"(^.*)(form:)([a-z]+)((?:&[^\s]*$)|$)"
	re_getform = re.compile(pat, re.UNICODE)
	pat = ur"(^.*)(tense:)([^&]+)((?:&[^\s]*$)|$)"
	re_gettns = re.compile(pat, re.UNICODE)
	pat = ur"(^.*)(root:)([^&]+)((?:&[^\s]*$)|$)"
	re_getroot = re.compile(pat, re.UNICODE)
	pat = ur"(^.*)(pro:)([^&]+)(&|$)((?:&[^\s]*$)|$)"
	re_protype = re.compile(pat, re.UNICODE)
	pat = ur"(^.*)(stat:)([^&]+)((?:&[^\s]*$)|$)"
	re_getstat = re.compile(pat, re.UNICODE)
	pat = ur"(^.*)(pos:)([^&]+)((?:&[^\s]*$)|$)"
	re_getpos = re.compile(pat, re.UNICODE)
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
	pat = ur"(ptn:)([a-zC]+)(&tense:)(fut)(&pers:)((?:2&gen:[mu]&num:[sgpldoun]+)|(?:3&gen:f&num:sg))(&|$)" #-> "future%(2%M)|(2|3%F)" 
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
	
	#re_getptn = re.compile(pat, re.UNICODE)
	#if re_getform.search(analysis) != None:
	if "form:" in analysis:
		form = re_getform.sub(ur"\3",analysis)
	if "tense:" in analysis:
		tense = re_gettns.sub(ur"\3",analysis)
	#if re_getpers.search(analysis) != None:
	if "pers:" in analysis:
		pers = re_getpers.sub(ur"\3", analysis)
	if "gen:" in analysis:
		gen = re_getgen.sub(ur"\3", analysis)
	#if re_getnum.search(analysis) != None:
	if "num:" in analysis:
		num = re_getnum.sub(ur"\3", analysis)
	if "pos:" in analysis:
		pos = re_getpos.sub(ur"\3", analysis)
	#print "Preamble 20; pos =", pos
	#if re_getroot.search(analysis) != None:
	if "root:" in analysis:
		root = re_getroot.sub(ur"\3", analysis)
	if "ptn:" in analysis:
	#if re_getptn.search(analysis) != None:
		ptn = re_getptn.sub(ur"\2", analysis)
		##print "ptn:", ptn
	if re_protype.search(analysis) != None and re_protype.search(analysis) != "":
		pro_type = re_protype.sub(ur"\3", analysis)
	# if "pos:pro" in analysis:
	# 	isFreePronoun = True
	# 	isNominal = False
	# 	isVerb = False
	# 	genNum = gen + "%" + num
	# 	persNum = pers + "%" + num
	# 	persGenNum = pers + "%" + num + "%" + gen
	##print "*** pos:", pos
	#print "&&&&&", "pos:", pos
	if "pro" in analysis:
		#print "pro analysis:", analysis
		#pat = ur"(&pos:)([a-z:_]+)(&[^\s]*)(&pers:)([123u]+)(&gen:)([fmu])(&num:)([spglundo]+)(&|$)"
		pat = ur"(\t|&)(pos:)([^\s]*pro[^\s]*)(&[^\s]*pers:)([123]+)(&gen:)([fsemunsp]+)(&num:)([sgplduoun]+)(&|$)"
		re_pro = re.compile(pat, re.UNICODE)
		# 1.
		# 2. actual pos
		# 3.
		# 4.
		# 5. actual person
		# 6.
		# 7. actual gender
		# 8.
		# 9. actual number
		# 10.
		#analysis = re_pro.sub(ur"\2%\5&\2%\5%\7&\2%\5%\9\3", analysis)
		#analysis = re_pro.sub(ur"\1\3%\5%\7&\3%\5%\9&\3%\7%\9", analysis)
		analysis = re_pro.sub(ur"\1\3%\5%\7&\3%\5%\7%\9\10", analysis)
		#print "*pro analysis:", analysis
	if pos == "adj" or pos == "n":
		isNominal = True
		###print "isNominal 0:", isNominal
		isVerb = False
		genNum = gen + "%" + num
		persGenNum = ""
	elif pos == "part":
		isVerb = True
		genNum = gen + "%" + num
		persGenNum = gen + "%" + num
	elif pos == "v":
		if "pers:" in analysis:
			persGenNum = pers + "%" + gen + "%" + num
		else:
			if "gen:" in analysis or "num:" in analysis:
				if "gen:" in analysis:
					persGenNum = gen
				if "num:" in analysis:
					persNumGen += "%" + num
			else:
				persNumGen = "-"
		isVerb = True
		isNominal = False
		#genNum = ""
		#persGenNum = pers + "%" + gen + "%" + num
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

	#if isVerb:
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
		##print "analysis", 1, ": ", analysis
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
		##print "analysis", 2, ": ", analysis
	elif pos == "part":
		#pat = ur"(ptn:)([a-zC]+)(&tense:)(past)(&pers:3&gen:f&num:sg)(&|$)"
		#pat = ur"(pos:)(part)(&[^\s]*)(&ptn:)([a-zC]*)(&[^\s]*)(&gen:)([mfu])(&num:)([sgplundoma]+)(&|$)"
		#pat = ur"(pos:)(part)(&root:[^\s]+&ptn:)([a-zC]*)(&[^\s]*)(gen:)([mascfemunsp]+)(&num:)([sgplundoma]+)(&|$)"
		pat = ur"(pos:)(part)([^\s]*&root:[^\s]+)(&ptn:)([a-zC]*)(&[^\s]*)(gen:)([mascfemunsp]+)(&num:)([sgplundoma]+)(&|$)"
		re_part = re.compile(pat, re.UNICODE)
		#analysis = re_part.sub(ur"\5%prefix_stem&\8%\10\11\6", analysis)
		if ptn == "qal":
			#1 (pos:)
			#2 (part)
			#3 ([^\s]*&ptn:)
			#4 ([a-zC]*) the actual pattern
			#5 (&[^\s]*)
			#6 (gen:) 
			#7 ([mascfemunsp]+)  # gender val
			#8 (&num:)
			#9 ([sgplundoma]+)    # number val
			#10(&|$)
			analysis = re_part.sub(ur"\3&\5%participle&\8%\10\6", analysis)
			# stemFeature = binyan + "%participle"
			# processedFeatures.append(stemFeature)
		elif ptn == "nifal":
			analysis = re_part.sub(ur"\3&\5%suffix_stem&\8%\10\6", analysis)
			# stemFeature = binyan + "%suffix_stem"
			# processedFeatures.append(stemFeature)
		else:
			analysis = re_part.sub(ur"\3&\5%prefix_stem&\8%\10\6", analysis)
		# analysis = analysis.replace("&pos:v&", "&")
		# analysis = analysis.replace("pos:v&", "")
	# #print "analysis", 3, ": ", analysis
	# #print "*** ptn:", ptn
	# #print "*** form:", form
	# #print "*** root:", root
	if form != "" and form != None:
		analysis += "&" + ptn + "%" + form
	##print "analysis", 4, ": ", analysis
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
		#return analysis
	if isNominal:
		##print "analysis nominal", 0, ": ", analysis
		pat = ur"(^.*&)(pl:[a-z]+:[a-z]+)((?:&[^\s]*$)|$)"
		re_plsupl = re.compile(pat, re.UNICODE)
		#new_analysis = []
		if re_getstat.search(analysis) != None:
			state = re_getstat.sub(ur"\3", analysis)
		# new_components = []
		# raw_components = analysis.split("&")
		# for component in raw_components:
		# 	if component == "pos:n": continue
		# 	elif "gen:" in component: continue
		# 	elif "num:" in component: continue
		# 	elif "stat" in component: continue
		# 	else: new_components.append(component)
		# #state = re_getstat.sub(ur"\1\3", analysis)
		# new_analysis = new_components
		# new_analysis.append(genNum)
		
		# pl_supl_info = ""
		# if re_plsupl.search() != None:
		# 	pl_supl_info = re_plsupl.sub(ur"\2", analysis)
		# 	genNum += "%" + pl_supl_info
		# feature = genNum
		# if genNum != "f%pl" and state == "cstr":
		# 	feature += "%" + state
		# # if pos == "adj":
		# # 	feature = pos + "%" + feature
		# new_analysis.append(feature)
		###print "isNominal"
		# pat = ur"(^.*)(&pos:n)[^\s]*$)"
		# re_removenoun = re.compile(pat, re.UNICODE)
		# pat = ur"(^.*)(gen:[fmu])((?:&[^\s]*$)|$)"
		# re_removegen = re.compile(pat, re.UNICODE)
		# #pat = ur"(^.*)(&num:[sgplunspdo]+)(&[^\s]*$)"
		# pat = ur"(^.*)(num:(?:(?:sg)|(?:pl)|(?:duo))((?:&[^\s]*$)|$)"
		# re_removenum = re.compile(pat, re.UNICODE)
		# pat = ur"(\t[^\s]*&)(pl:[a-z]+:[a-z]+)(&[^\s]*$)"
		# re_plsupl = re.compile(pat, re.UNICODE)
		pat = ur"(&)(num:)(pl&)(pl:[a-z]+:[a-z]+)(&|$)"
		re_plpl = re.compile(pat, re.UNICODE)
		analysis = re_plpl.sub(ur"\1\2\4\5", analysis)

		pat = ur"(pos:)(n)([^\s]*)(&gen:)([fmu])(&num:)([a-z:]+)(&stat:)(cstr)"
		re_cstr = re.compile(pat, re.UNICODE)
		# #if (gen = "m" and num = "sg") or (gen = "f" and num = "pl")
		pl_supl_info = ""
		if re_plsupl.search(analysis) != None:
			pl_supl_info = re_plsupl.sub(ur"\2", analysis)
			
		
		if gen == "f" and num == "pl":
			analysis=re_cstr.sub(ur"\5%\7\3", analysis)
			analysis=re_cstr.sub(ur"\5%\7\3", analysis)
		else:
			analysis=re_cstr.sub(ur"\9%\5%\7\3", analysis)
			analysis=re_cstr.sub(ur"\9%\5%\7\3", analysis)
		#print "analysis nominal", 1, ": ", analysis

		#pat = ur"(pos:)(adj)([^\s]*)(&gen:)([fmu])(&num:)([spglundo]+)(&stat:)(cstr)"
		pat = ur"(pos:)(adj)([^\s]*)(&gen:)([fmu])(&num:)([a-z:]+)(&stat:)(cstr)"
		re_cstr = re.compile(pat, re.UNICODE)
		# #if (gen = "m" and num = "sg") or (gen = "f" and num = "pl")
		# pl_supl_info = ""
		# if re_plsupl.search(analysis) != None:
		# 	pl_supl_info = re_plsupl.sub(ur"\2", analysis)
			
		
		if gen == "f" and num == "pl":
			analysis=re_cstr.sub(ur"\2&\5%\7\3", analysis)
			analysis=re_cstr.sub(ur"\2&\5%\7\3", analysis)
		else:
			analysis=re_cstr.sub(ur"\2&\9%\5%\7\3", analysis)
			analysis=re_cstr.sub(ur"\2&\9%\5%\7\3", analysis)
		#print "analysis nominal", 1, ": ", analysis
		# ###print "Just after re_cstr:", analysis
		# ## absolute (or non-construct) forms
		#pat = ur"(pos:)(n|(?:adj))([^\s]*)(&gen:)([fmunsp]+)(&num:)([spglundo]+)(&stat:)((?:free)|u)"
		#pre:be~pre:ha&pos:adj&root:kxl&ptn:CaCoC&gen:m&num:sg
		pat = ur"(pos:)(n)([^\s]*)(&gen:)([fmunsp]+)(&num:)([a-z:]+)(&stat:u)?"
		# 1: (pos:)
		# 2: (n|(?:adj))
		# 3: ([^\s]*)
		# 4: (&gen:)
		# 5: ([fmunsp]+)
		# 6: (&num:)
		# 7: ([spglundo]+)
		# 8: (&stat:u)
		re_abs = re.compile(pat, re.UNICODE)
		analysis=re_abs.sub(ur"\5%\7\3", analysis)
		#print "analysis nominal", 2, ": ", analysis
		pat = ur"(pos:)(adj)([^\s]*)(&gen:)([fmunsp]+)(&num:)([a-z:]+)(&stat:u)?"
		# 1: (pos:)
		# 2: (n|(?:adj))
		# 3: ([^\s]*)
		# 4: (&gen:)
		# 5: ([fmunsp]+)
		# 6: (&num:)
		# 7: ([spglundo]+)
		# 8: (&stat:u)
		re_abs = re.compile(pat, re.UNICODE)
		analysis=re_abs.sub(ur"\2&\5%\7\3", analysis)
		#print "analysis nominal", 2, ": ", analysis
		### get rid of the masc.sg feature, since masc.sg forms are (usually) unmarked
		# pat = ur"(n|(?:adj))(\%[mu]\%sg)"
		# re_msg = re.compile(pat, re.UNICODE)
		# analysis = re_msg.sub(ur"", analysis)
		###print "genNum:", genNum
		#analysis = analysis.replace("&&", "&")
		# ##print "analysis nominal", 2, ": ", analysis	
		# pl_supl_info = ""
		# if re_plsupl.search(analysis) != None:
		# 	pl_supl_info = re_plsupl.sub(ur"\2", analysis)
		# 	genNum += "%" + pl_supl_info
		# analysis += genNum
		##print "analysis nominal", 3, ": ", analysis
		# if pos == "adj":
		# 	analysis += pos

		# analysis = analysis.replace("&pos:n&", "&")
		# analysis = analysis.replace("pos:n&", "")
		# analysis = analysis.replace("&stat:cstr&", "&")
		# analysis = analysis.replace("stat:cstr&", "")
		# analysis = re_removegen(ur"\1\3", analysis)
		# analysis = re_removenum(ur"\1\3", analysis)
		#analysis = "&".join(new_analysis)
		# if root == "":
		# 	analysis += "&rootless_nominal"
	analysis = analysis.replace("poss:", "xxxxxxxxxx:")
	##print "analysis nominal", 4, ": ", analysis
	analysis = analysis.replace("suf:", "xxxxxxxxxx:")
	##print "analysis nominal", 5, ": ", analysis
	analysis = analysis.replace("xxxxxxxxxx:", "pro_suf_state&pro_suf:")
	##print "analysis nominal", 6, ": ", analysis

	##print "analysis nominal", 7, ": ", analysis
		#new_analysis.append("&rootless_nominal")

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
	# if "(pre:we)" in analysis:
	# 	analysis = analysis.replace("(pre:we)", "pre:we")
		#return analysis
		#return "&".join(new_analysis)
	#else:
	# pat = ur"(&num:)([spglundo]+)(&)(pl:[a-z]+:[a-z]+)(&|$)"
	# re_plpl = re.compile(pat, re.UNICODE)
	#analysis = re_plpl.sub(ur"\1%\4\5", analysis)
	pat = ur"(gen:)([fmu])(&num:)([a-z:]+)(&|$)" #(&pl:[a-z]+:[a-z]+)(&|$)"
	re_gennum = re.compile(pat, re.UNICODE)
	analysis = re_gennum.sub(ur"&\2%\4\5", analysis)
	pat = ur"(gen:)([fmu])(&num:)([a-z:]+)(&|$)"
	re_gennum = re.compile(pat, re.UNICODE)
	analysis = re_gennum.sub(ur"&\2%\4\5", analysis)
	analysis = analysis.replace("&u%u&", "&")
	analysis = analysis.replace("&m%sg&", "&")
	analysis = analysis.replace("&m%pl", "&M%Pl")
	analysis = analysis.replace("&f%pl", "&F%Pl")
	analysis = analysis.replace("&f%sg", "&F%Sg")
	analysis = analysis.replace("%m%sg", "%M%Sg")
	analysis = analysis.replace("%m%pl", "%M%Pl")
	analysis = analysis.replace("%f%pl", "%F%Pl")
	analysis = analysis.replace("%f%sg", "%F%Sg")
	analysis = analysis.replace("%u&", "&")
	analysis = analysis.replace("%u%", "%")
	analysis = analysis.replace("&u%", "&")
	analysis = analysis.replace("&u&", "&")
	analysis = analysis.replace("&&&", "&")
	analysis = analysis.replace("&&", "&")
	#analysis = analysis.replace("&u%pl&", "&pl&")
	return analysis


class BL_Analyzer:
	def __init__(self, bermanAnalysesFile):
		fobj = codecs.open(bermanAnalysesFile,'r',encoding='utf8')
		self.lines = fobj.readlines()
		self.analysisDict = {}
		self.clustersAndWords = {}
		self.clustersAndClasses = {}
		self.numWords = 0
		self.wordsAndClasses = {}
		for line in self.lines:
			line = line.replace("gen:ms", "gen:m")
			line = line.replace("gen:masc", "gen:m")
			line = line.replace("gen:fm", "gen:f")
			line = line.replace("gen:fem", "gen:f")
			line = line.replace("unsp", "u")
			line = line.replace("mf","u")
			# line = line.replace("fm","u")
			word,analyses_str = line.split("\t")
			####print "WORD:",word
			self.analysisDict[word] = {}
			#self.analysisDict[word] = []
			#self.clustersAndWords = dict()
			#self.clustersAndClasses = dict()
			
			#analyses = analyses_str.split()
			analyses = analysisFilter(analyses_str)
			####print analyses
			#tempList = []

			for analysis in analyses:
				#self.analysisDict[word] = dict()
				#cats = analysis.split("&")
				#cats.sort()
				###print "# old:", analysis
				new_analysis = categoryFilter(analysis)
				###print "   *** new:", new_analysis
				###print new_analy
				# if "fut" in analysis:
				# 	###print new_analysis
				#cats = new_analysis.split("&")
				# if self.analysisDict.has_key(word):
				# 	self.analysisDict[word].extend(cats)
				# else:
				# 	self.analysisDict[word] = [cats]
				cats = new_analysis.split("&")
				if "pos:v" in cats:
					cats.remove("pos:v")
				if "stat:u" in cats:
					cats.remove("stat:u")
				###print cats
				for cat in cats:
					self.analysisDict[word][cat] = 1

			#self.clustersAndWords[clusterID].append(word)

	def analyze_words(self, cluster_words, clusterID):
		#wordsAndClasses = dict()
		#analyzed_words = list()
		#self.clustersAndWords = dict()
		#self.clustersAndClasses = dict()
		#self.wordsAndClasses = dict()
		#self.numWords = len(cluster_words)
		self.clustersAndWords = {}
		self.clustersAndClasses = {}
		self.numWords = 0
		self.wordsAndClasses = {}
		#seen_words = []
		#unseenWord = True
		self.clustersAndWords[clusterID] = []
		self.clustersAndClasses[clusterID] = dict()
		num_passes = 0
		for word in cluster_words:
			classes = []
			####print word
			self.wordsAndClasses[word] = {}
			# if word not in seen_words: 
			# 	unseenWord = True
			# 	seen_words.append(word)
			# else: 
			# 	unseenWord = False
			#if word == u"te\u1E32asi":
				###print word + "!!!!!!!"
			#if word == u"lehabayit":
				###print word + "!!!!!!!"
			if self.analysisDict.has_key(word):
				classes = self.analysisDict[word].keys()
				#classes = self.analysisDict[word]
			else:
				num_passes += 1
				continue
			#self.analysisDict = {}
			####print "&^%", self.analysisDict[word]
			#if word == u"lehabayit":
				###print word + ",", classes, "!!!!!!!"
			
			if self.wordsAndClasses.has_key(word) == False:
				self.wordsAndClasses[word] = {}
			for feature in classes:
				if self.wordsAndClasses[word].has_key(feature):
				
					self.wordsAndClasses[word][feature] += 1 #.extend(classes)
					####print "wordsAndClasses:", self.wordsAndClasses[word]
				else:
					self.wordsAndClasses[word][feature] = 1
			self.clustersAndWords[clusterID].append(word)
			self.numWords += 1
				####print "&&&", self.wordsAndClasses[word]
				#self.wordsAndClasses[word].extend(self.self.analysisDict[word].keys())
			####print "wordsAndClasses[", word, "]:", self.wordsAndClasses[word]
			####print "classes:",classes
			for feature in classes:
				#if unseenWord:
				if self.clustersAndClasses[clusterID].has_key(feature):
					self.clustersAndClasses[clusterID][feature] += 1
				else:
					self.clustersAndClasses[clusterID][feature] = 1
				#else:
					# if unseenWord is False, it means that the current word as already been seen.
					# in this case, we need to be careful not to increase the counts of previously
					# seen features (i.e., classes).
					# if self.clustersAndClasses[clusterID].has_key(feature):
					# 	pass
					# else:
					# self.clustersAndClasses[clusterID][feature] = 1
				#sys.stderr.write("  freq(" + prevLineWord + " & " + feature
			####print "num_passes:", num_passes

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
	#sys.stderr.write("+++\n")
	my_bl_analyzer = BL_Analyzer(bermanAnalysesFile)
	fobj = codecs.open(clusterWordsFile, 'r', encoding='utf8')
	clusterLines = fobj.readlines()
	####print lines[0]
	clusters=[]
	#clusterLines=[]
	clusterLines.pop(0)
	####print "first:",lines[0]
	for line in clusterLines:
		####print "clusterLine:",line
		cluster = line.split()
		clusters.append(cluster)
		####print "LINE:", line
		# if line[0] == "#":
		# 	#sys.stderr.write(line)
		# 	clusters.append(clusterLines)
		# 	clusterLines = []
		# else:
		# 	if line != "\n":
		# 		clusterLines.append(line)
	####print "clusters:",clusters
	wordsAndClasses = dict()
	###print "NUM_CLUSTERS:", len(clusters)
	k = 0
	str_k = "{0:04d}".format(k)
	my_bl_analyzer.analyze_words(clusters[k], str_k)
	wordsAndClasses = my_bl_analyzer.getWordsAndClasses()
	###print "WANDCS", k, ":", "len:", len(wordsAndClasses.keys())
	# for key,val in wordsAndClasses.items():
	# 	##print key,val
	for k in range(1, 2):
		str_k = "{0:04d}".format(k)
		#cluster_IDs.append(str_k)
		#my_bl_analyzer = BL_analyzer(bermanAnalysesFile)
		my_bl_analyzer.analyze_words(clusters[k], str_k)
		
		wordsAndClasses.update(my_bl_analyzer.getWordsAndClasses())
		#temp = my_bl_analyzer.getWordsAndClasses()
		# ##print "TEMP:"
		# for key,val in temp.items():
		# 	##print key,val
		#wordsAndClasses.update(temp)
		###print "WANDCS", k, ":", "len:", len(wordsAndClasses.keys())
		# for key,val in wordsAndClasses.items():
		# 	##print key,val
		####print wordsAndClasses
	for word in wordsAndClasses.keys():
		features = wordsAndClasses[word]
		#sys.stderr.write("***" +  " ".join(features) + "\n")
		#sys.stdout.write(word + "\t" + " ".join(features) + "\n")

if __name__ == '__main__':
	main(sys.argv[1], sys.argv[2])


