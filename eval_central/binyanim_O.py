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

#[^ieoua\u00FA\u00F3\u00ED\u00E9\u00E1]
filename = sys.argv[1]
fobj = codecs.open(filename,'r',encoding='utf8')
lines = fobj.readlines()
#pat=ur"(^k?e?[a-z]i[a-z]{2}.*\t.*pos:v&.*&ptn:)(CiC[ae]C)(&tense:past)"

pat=ur"(pos:v&.*&ptn:)(CiC[ae]C)(&tense:past)"
re_piel1 = re.compile(pat, re.UNICODE)
#pat=ur"(pos:v&.*&ptn:)(CaCeC)"
pat=ur"(pos:v&.*&ptn:)(CaCeC)(&(?:form:imp)|(?:tense:fut)|(?:form:inf))"
re_piel2 = re.compile(pat, re.UNICODE)
#pat=ur"(^.*[litmna].(?:[^iw](?:(?:ww)|(?:ii))[a-z]).*\t.*pos:v&.*&ptn:)(CaCeC)(&)"
#pat=ur"(^.*[litmna][a-z][a-z][a-z]?[a-z].*\t.*pos:v&.*&ptn:)(CaCeC)(&)"
pat = ur"([^h]i..*\t.*pos:v&root:[^\s]*&ptn:)(CiCaC)(&tense:past)"
re_piel3 = re.compile(pat, re.UNICODE)

pat=ur"([ltmna][a-z][a-z][a-z]?[a-z].*\t.*pos:v&.*&ptn:)(CaCeC)(&)"
re_pielpre = re.compile(pat, re.UNICODE)
#pat=ur"(^.hi[a-z](?:[^iw](?:(?:ww)|(?:ii))[a-z])*\t.*pos:v&.*&ptn:)(CaCeC)(.*&form:inf)"
pat = ur"(h...*\t.*pos:v[^\s]*&ptn:)(CCaC)(&tense:past)"
re_hifil = re.compile(pat, re.UNICODE)
pat=ur"(le...*\t[^\s]*pos:v&[^\s]*&ptn:)(CaCeC)([^\s]*)(&form:inf)"
re_pielinf = re.compile(pat, re.UNICODE)
pat=ur"(lhi[a-z][a-z][a-z]\t.*pos:v&.*&ptn:)((?:CaCeC)|(?:piel))(&[^\s]*form:inf)"
re_nifalinf = re.compile(pat, re.UNICODE)
pat=ur"(lh[tvdezs][a-z][a-z][a-z]?[a-z]\t.*pos:v&.*&ptn:)((?:CaCeC)|(?:piel))(&[^\s]*form:inf)"
re_hitpaelinf = re.compile(pat, re.UNICODE)
pat=ur"(pre:sh&pos:v&.+&ptn:)(Ce?C[aoe]C&(?:pre:sh)?&ptn:qal)"
re_qalsh = re.compile(pat, re.UNICODE)
#pat = ur"(&?)(root:[^&]+&ptn:CoCaC&)(root:[^&]+&.+&ptn:nifal&)"
pat = ur"(&root:.*&ptn:CoCaC)(&.*)(&.*root:.*&ptn:nifal)"
re_CoCaC = re.compile(pat, re.UNICODE)
pat=ur"(pos:v&[^\s]*&ptn:)(CC[ao]C)(&[^\s]*tense:fut)"
re_qalfut = re.compile(pat, re.UNICODE)
pat=ur"(pos:v&[^\s]*&ptn:)(CC[ao]C)(&[^\s]*form:imp)"
re_qalimp = re.compile(pat, re.UNICODE)
pat=ur"([itn]..*\t.*pos:v[^\s]*ptn:)(CCeC)(&tense:fut)"
re_qalfut2 = re.compile(pat, re.UNICODE)

# pat = ur"[ieaou\u00E1\u00E9\u00F3\u00FA\u00ED]"
# re_vowel = re.compile(pat, re.UNICODE)
pat = ur"(&?root:.*&ptn:[Ca-z]+)((?:&.*$)|$)"
re_rootptn = re.compile(pat, re.UNICODE)
pat=ur"(pos:)([a-z:]+)((?:&.*$)|$)"
re_getpos = re.compile(pat, re.UNICODE)

pat = ur"(pos:v[^\s]*ptn:)(CC[ao]C)(&[^\s]*form:inf)"
re_qalinf = re.compile(pat, re.UNICODE)
pat = ur"(pos:v&.*&ptn:)(CaCa)((?:&.*$)|$)"
re_CaCa = re.compile(pat, re.UNICODE)
pat = ur"(pos:v&[^\s]*ptn:)(CCaC)(&tense:fut)"
#pat = ur"([^h]i..[a\u00E1].*\t.*ptn:)(CCaC)(&tense:fut)"
re_CCaC = re.compile(pat, re.UNICODE)
#pat = ur"(ptn:Ce?C[aoe]C&root:[^&]+&)(ptn:qal&root:[^&]+&)"

# pat = ur"(&root:[^&]+&ptn:[^&]+)([]*)(&root:[^&]+&ptn:(?:(?:qal)|(?:piel)|(?:hitpael)|(?:nifal)|(?:hufal)|(?:hifil)|(?:pual)))"
# re_slice = re.compile(pat, re.UNICODE)
# for line in lines:
# 	line = line.replace("\n","")
# 	word,analyses_str = line.split("\t")
# 	analyses = analyses_str.split()
# 	new_analyses = []
# 	#sys.stdout.write("%%%%%% LINE: " + line + "\n")
# 	for analysis in analyses:
# 	#for line in lines:
# 		if re_nifalinf.search(analysis):
# 			#sys.stdout.write(word + "\t" + analysis + "\n")
# 			analysis = re_nifalinf.sub(ur"\1nifal\3", analysis)
# 			#sys.stdout.write("**nifalinf\tword\t" + analysis + "\n")
# 		if re_piel1.search(analysis):
# 			#sys.stdout.write(word + "\t" + analysis + "\n")
# 			analysis = re_piel1.sub(ur"\1piel\3", analysis)
# 			#sys.stdout.write("**piel1\tword" + "\t" + analysis + "\n")
# 		# if re_piel2.search(analysis):
# 		# 	##sys.stdout.write(analysis)
# 		# 	analysis = re_piel2.sub(ur"\1piel", analysis)
# 		# 	##sys.stdout.write("**piel2  " + analysis)
# 		if re_pielpre.search(analysis):
# 			#sys.stdout.write(word + "\t" + analysis + "\n")
# 			analysis = re_pielpre.sub(ur"\1piel\3", analysis)
# 			#sys.stdout.write("**pielpre\tword" + "\t" + analysis + "\n")
# 		# if re_nifalinf.search(analysis):
# 		# 	#sys.stdout.write(word + "\t" + analysis + "\n")
# 		# 	analysis = re_nifalinf.sub(ur"\1nifal\3", analysis)
# 		# 	#sys.stdout.write("**nifalinf\tword\t" + analysis + "\n")
# 		if re_hitpaelinf.search(analysis):
# 			#sys.stdout.write(word + "\t" + analysis + "\n")
# 			analysis = re_hitpaelinf.sub(ur"\1nifal\3", analysis)
# 			#sys.stdout.write("**hitpaelinf\tword\t" + analysis + "\n")
# 		if re_qalsh.search(analysis):
# 			#sys.stdout.write(word + "\t" + analysis + "\n")
# 			analysis = re_qalsh.sub(ur"\1qal", analysis)
# 			#sys.stdout.write("**qalsh\tword\t" + analysis + "\n")
# 		if re_CoCaC.search(analysis):
# 			#sys.stdout.write(word + "\t" + analysis + "\n")
# 			analysis = re_CoCaC.sub(ur"\2\3", analysis)
# 			#sys.stdout.write("**oCa\tword\t" + analysis + "\n")
# 		new_analyses.append(analysis)
# 	new_line = word + "\t" + " ".join(new_analyses) + "\n"
pat=ur"(pos:)([a-z]+)(&[^\s]*&ptn:)(meCaCeC)(&|$)"
re_pielnadj = re.compile(pat, re.UNICODE)

pat = ur"(gen:)([a-z]+)(&num:pl)(&pl:(?:(?:fem)|(?:masc)):bio)(&|$)"
re_fbio = re.compile(pat, re.UNICODE)
# pat = ur"(&root:[^&]+&ptn:[^&]+)([]*)(&root:[^&]+&ptn:(?:(?:qal)|(?:piel)|(?:hitpael)|(?:nifal)|(?:hufal)|(?:hifil)|(?:pual)))"
# re_slice = re.compile(pat, re.UNICODE)
pat = ur"(gen:)([a-z]+)(&num:pl)(&pl:)([a-z]+)(:mis)(&|$)"
re_genmis = re.compile(pat, re.UNICODE)

# pat = ur"(&root:[^&]+&ptn:[^&]+)([]*)(&root:[^&]+&ptn:(?:(?:qal)|(?:piel)|(?:hitpael)|(?:nifal)|(?:hufal)|(?:hifil)|(?:pual)))"
# re_slice = re.compile(pat, re.UNICODE)
for line in lines:
	line = re_genmis.sub(ur"\1\5\3\7", line)
	line = re_fbio.sub(ur"\1\2\3\5", line)
	line = line.replace("\n","")
	word,analyses_str = line.split("\t")
	#print"****", word + "\t" + analyses_str
	analyses = analyses_str.split()
	new_analyses = []
	#sys.stdout.write("%%%%%% LINE: " + line + "\n")
	temp_line = ""

	for analysis in analyses:
#for line in lines:
		
		temp_line = word + "\t" + analysis
		new_analysis = analysis
		pos = re_getpos.sub(ur"\2", new_analysis)
		#print "POS:", pos
		if len(word) < 3 and pos != "v" and pos != "part":
			new_analysis = re_rootptn.sub(ur"\2", new_analysis)
		#if re_piel1.search(temp_line):
			#print"piel1", " #",
			#sys.stdout.write(line)
		# temp_line = re_piel1.sub(ur"\1piel\3", temp_line)
		# 	#print"&", temp_line
		# 	#temp_word,new_analysis = temp_line.split("\t")
		# 	#print"temp_word:\t", temp_word
		# 	#print"new_analysis:\t", new_analysis
		# 	#new_analyses.append(analysis)
		# 	#sys.stdout.write("**piel1  " + line)
		# # if re_piel2.search(line):
		# # 	#sys.stdout.write(line)
		# # 	line = re_piel2.sub(ur"\1piel", line)
		# # 	#sys.stdout.write("**piel2  " + line)
		# temp_line = re_piel2.sub(ur"\1piel\3", temp_line)
		# #if re_pielpre.search(temp_line):
		# 	#sys.stdout.write(line)
		# #temp_line = re_pielpre.sub(ur"\1piel\3", temp_line)
		# 	#temp_word,new_analysis = temp_line.split("\t")
		# 	#print"2 temp_word:\t", temp_word
		# 	#print"2 new_analysis:\t", new_analysis
		# 	#new_analyses.append(analysis)
		# 	#sys.stdout.write("**pielpre   " + line)
		# #if re_nifalinf.search(temp_line):
		# 	#sys.stdout.write(line)
		# temp_line = re_nifalinf.sub(ur"\1nifal\3", temp_line)
		# 	#temp_word,new_analysis = temp_line.split("\t")
		# 	#print"3 new_analysis:\t", new_analysis
		# 	#sys.stdout.write("**nifalinf   " + line)
		# 	#new_analyses.append(analysis)
		# #if re_hitpaelinf.search(temp_line):
		# 	#sys.stdout.write(line)
		# temp_line = re_hitpaelinf.sub(ur"\1hitpael\3", temp_line)
		# 	#temp_word,new_analysis = temp_line.split("\t")
		# 	#print"4 new_analysis:\t", new_analysis
		# 	#sys.stdout.write("**hitpaelinf   " + line)
		# 	#new_analyses.append(analysis)
		# #if re_qalsh.search(temp_line):
		# 	#sys.stdout.write(line)
		# temp_line = re_qalsh.sub(ur"\1qal", temp_line)
		# 	#temp_word,new_analysis = temp_line.split("\t")
		# 	#sys.stdout.write("**qalsh " + line)
		# 	#new_analyses.append(analysis)
		# #if re_CoCaC.search(temp_line):
		# 	#sys.stdout.write(line)
		# temp_line = re_CoCaC.sub(ur"\2\3", temp_line)
		#temp_word,new_analysis = temp_line.split("\t")
			#sys.stdout.write("**oCa   " + line)
			#new_analyses.append(analysis)
		#print"<<", word + "\t" + new_analysis

		temp_line = re_piel1.sub(ur"\1piel\3", temp_line)
		temp_line = re_piel2.sub(ur"\1piel\3", temp_line)
		temp_line = re_piel3.sub(ur"\1piel\3", temp_line)
		temp_line = re_pielnadj.sub(ur"\1part\3piel\5", temp_line)
			#print"&", temp_line
		#temp_word,new_analysis = temp_line.split("\t")
			#print"temp_word:\t", temp_word
			#print"new_analysis:\t", new_analysis
			#new_analyses.append(analysis)
			#sys.stdout.write("**piel1  " + line)
		# if re_piel2.search(line):
		# 	#sys.stdout.write(line)
		# 	line = re_piel2.sub(ur"\1piel", line)
		# 	#sys.stdout.write("**piel2  " + line)

		# if re_pielpre.search(temp_line):
		# 	#sys.stdout.write(line)
		# 	temp_line = re_pielpre.sub(ur"\1piel\3", temp_line)
		# 	temp_word,new_analysis = temp_line.split("\t")
			#print"2 temp_word:\t", temp_word
			#print"2 new_analysis:\t", new_analysis
			#new_analyses.append(analysis)
			#sys.stdout.write("**pielpre   " + line)
		#if re_nifalinf.search(temp_line):
			#sys.stdout.write(line)
		temp_line = re_nifalinf.sub(ur"\1nifal\3", temp_line)
		#temp_word,new_analysis = temp_line.split("\t")
			#print"3 new_analysis:\t", new_analysis
			#sys.stdout.write("**nifalinf   " + line)
			#new_analyses.append(analysis)
		#if re_hitpaelinf.search(temp_line)
			#sys.stdout.write(line)
		temp_line = re_hitpaelinf.sub(ur"\1hitpael\3", temp_line)
		temp_line = re_pielinf.sub(ur"\1piel\3", temp_line)
		#temp_word,new_analysis = temp_line.split("\t")
			#print"4 new_analysis:\t", new_analysis
			#sys.stdout.write("**hitpaelinf   " + line)
			#new_analyses.append(analysis)
		#if re_qalfut.search(temp_line):
		temp_line = re_hifil.sub(ur"\1hifil\3", temp_line)
		temp_line = re_qalfut.sub(ur"\1qal\3", temp_line)
		temp_line = re_qalfut2.sub(ur"\1qal\3", temp_line)
			#temp_word,new_analysis = temp_line.split("\t")


		temp_line = re_CaCa.sub(ur"\1qal\3", temp_line)
		temp_line = re_CCaC.sub(ur"\1qal\3", temp_line)
		temp_line = re_qalinf.sub(ur"\1qal\3", temp_line)
		temp_line = re_qalimp.sub(ur"\1qal\3", temp_line)
		if "pos:v" in temp_line:
			temp_line = temp_line.replace("ptn:meCaCeC", "ptn:piel")
		#if re_qalsh.search(temp_line):
			#sys.stdout.write(line)
		#temp_line = re_qalsh.sub(ur"\1qal", temp_line)
			#temp_word,new_analysis = temp_line.split("\t")
			#sys.stdout.write("**qalsh " + line)
			#new_analyses.append(analysis)
		#if re_CoCaC.search(temp_line):
			#sys.stdout.write(line)
		#temp_line = re_CoCaC.sub(ur"\2\3", temp_line)
			#temp_word,new_analysis = temp_line.split("\t")
			#sys.stdout.write("**oCa   " + line)
			#new_analyses.append(analysis)
		#print"<<", word + "\t" + new_analysis
		#print "<<" + temp_line
		items = temp_line.split("\t")
	 	#if len(items) < 2: print "SHORT", temp_line
		word,new_analysis = temp_line.split("\t")
		new_analyses.append(new_analysis)


		word,new_analysis = temp_line.split("\t")
		new_analyses.append(new_analysis)
		#print"new_analyses:", new_analyses
	new_line = word + "\t" + " ".join(new_analyses) + "\n"	

	pat = ur"(&root:[^&:\s]*)(f)([^&:\s]*&ptn:)"
	re_rootf = re.compile(pat, re.UNICODE)
	new_line = re_rootf.sub(ur"\1p\3", new_line)
	pat = ur"(&root:[^&:\s]*)(\u1E33)([^&:\s]*&ptn:)"
	re_rootk = re.compile(pat, re.UNICODE)
	new_line = re_rootk.sub(ur"\1k\3", new_line)
	pat = ur"(&root:[^&:\s]*)(v)([^&:\s]*&ptn:)"
	re_rootb = re.compile(pat, re.UNICODE)
	new_line = re_rootb.sub(ur"\1b\3", new_line)

	pat = ur"(&root:[^&:\s]*&ptn:[Caoiue]+)(&[^\s]*pre:sh[^\s]*)(&root:[^&:\s]*&ptn:[Caoiue]+)(&|$)"
	re_shptn = re.compile(pat, re.UNICODE)
	new_line = re_shptn.sub(ur"\3\4", new_line)

	pat = ur"(&root:[^\s&]+)(&ptn:[^\s&]+)[\s]*(&root:[^\s&]+)(&ptn:[^\s&]+)(&|$)"
	re_dblptn = re.compile(pat, re.UNICODE)
	new_line = re_dblptn.sub(ur"\3\4\5", new_line)
	new_line = new_line.replace("&mass:yes&","&")
	new_line = new_line.replace("&a:dim&","&pos:adj&dim&")
	new_line = new_line.replace("dim:yes", "dim")
	sys.stdout.write(new_line)
		# analysis = re_piel1.sub(ur"\1piel\3", analysis)
		# analysis = re_piel2.sub(ur"\1piel", analysis)
		# analysis = re_qalsh.sub(ur"\1qal", analysis)
		# #sys.stdout.write(analysis)
	
