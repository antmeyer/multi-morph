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

filename = sys.argv[1]
fobj = codecs.open(filename,'r',encoding='utf8')
lines = fobj.readlines()
pat=ur"(pos:v&.*&ptn:)(CiC[ae]C)(&tense:past)"
re_piel1 = re.compile(pat, re.UNICODE)
pat=ur"(pos:v&.*&ptn:)(CaCeC)"
re_piel2 = re.compile(pat, re.UNICODE)
pat=ur"(pre:sh&pos:v&.+&ptn:)(Ce?C[aoe]C&(?:pre:sh)?&ptn:qal)"
re_qalsh = re.compile(pat, re.UNICODE)
for line in lines:
	if re_piel1.search(line):
		
	line = re_piel1.sub(ur"\1piel\3", line)
	line = re_piel2.sub(ur"\1piel", line)
	line = re_qalsh.sub(ur"\1qal", line)
	sys.stdout.write(line)
	
