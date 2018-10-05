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
pat=ur"(pos:v&.*&ptn:)(CiC[ae]C)(&tense:past)"
re_piel1 = re.compile(pat, re.UNICODE)
pat=ur"(pos:v&.*&ptn:)(CaCeC)"
re_piel2 = re.compile(pat, re.UNICODE)
pat=ur"(^.*[lytmn\u0294]e.[a\u00E1].[e\u00E9].*\t.*pos:v&.*&ptn:)(CaCeC)(&)"
re_pielpre = re.compile(pat, re.UNICODE)
pat=ur"(^.ehi.[a\u00E1].[e\u00E9].*\t.*pos:v&.*&ptn:)(CaCeC)(.*&form:inf)"
re_nifalinf = re.compile(pat, re.UNICODE)
pat=ur"(^.ehi.{2}[a\u00E1].[e\u00E9].*\t.*pos:v&.*&ptn:)(CaCeC)(.*&form:inf)"
re_hitpaelinf = re.compile(pat, re.UNICODE)
pat=ur"(pre:sh&pos:v&.+&ptn:)(Ce?C[aoe]C&(?:pre:sh)?&ptn:qal)"
re_qalsh = re.compile(pat, re.UNICODE)
#pat = ur"(&?)(root:[^&]+&ptn:CoCaC&)(root:[^&]+&.+&ptn:nifal&)"
pat = ur"(root:.+ptn:CoCaC)(&.*root:.+ptn:nifal)"
re_CoCaC = re.compile(pat, re.UNICODE)
pat = ur"(ptn:Ce?C[aoe]C&root:[^&]+&)(ptn:qal&root:[^&]+&)"

pat = ur"(&root:[^&]+&ptn:[^&]+)([]*)(&root:[^&]+&ptn:(?:(?:qal)|(?:piel)|(?:hitpael)|(?:nifal)|(?:hufal)|(?:hifil)|(?:pual)))"
re_slice = re.compile(pat, re.UNICODE)

for line in lines:
	line
	if re_piel1.search(line):
		sys.stdout.write(line)
		line = re_piel1.sub(ur"\1piel\3", line)
		sys.stdout.write("**piel1  " + line)
	# if re_piel2.search(line):
	# 	sys.stdout.write(line)
	# 	line = re_piel2.sub(ur"\1piel", line)
	# 	sys.stdout.write("**piel2  " + line)
	if re_pielpre.search(line):
		sys.stdout.write(line)
		line = re_pielpre.sub(ur"\1piel\3", line)
		sys.stdout.write("**pielpre   " + line)
	if re_nifalinf.search(line):
		sys.stdout.write(line)
		line = re_nifalinf.sub(ur"\1nifal\3", line)
		sys.stdout.write("**nifalinf   " + line)
	if re_qalsh.search(line):
		sys.stdout.write(line)
		line = re_qalsh.sub(ur"\1qal", line)
		sys.stdout.write("**qalsh " + line)
	if re_CoCaC.search(line):
		sys.stdout.write(line)
		line = re_CoCaC.sub(ur"\2", line)
		sys.stdout.write("**oCa   " + line)


	# line = re_piel1.sub(ur"\1piel\3", line)
	# line = re_piel2.sub(ur"\1piel", line)
	# line = re_qalsh.sub(ur"\1qal", line)
	# sys.stdout.write(line)
	
