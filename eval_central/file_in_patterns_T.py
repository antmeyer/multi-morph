import math,pprint,random
import regex as re
import sys, codecs
reload(sys)  
sys.setdefaultencoding('utf8')
UTF8Writer = codecs.getwriter('utf8')
sys.stdout = UTF8Writer(sys.stdout)
sys.stderr = UTF8Writer(sys.stderr)
#"\u1e6d" t with dot below
#"\u1e63" s with dot below
#pat = ur"(pos:n[^\s]*)(root:[^&][y][^&y]&ptn:CaC)(&)"
pat = ur"o.(([\u00E9])|(.?[\u00E2\u00E1\u00F3]))"
re_partqal = re.compile(pat, re.UNICODE)
pat = ur"me.a"
re_partpiel = re.compile(pat, re.UNICODE)
pat = ur"ma..[i\u00E2]"
re_parthifil = re.compile(pat, re.UNICODE)
pat = ur"ni..."
re_partnifal = re.compile(pat, re.UNICODE)
pat = ur"[ytnhm]((it)|(i[\u1E63\u0160s][t\u1E6D])|(izd))"
re_hitpael = re.compile(pat, re.UNICODE)
pat = ur"u.\u00E1"
re_pual = re.compile(pat, re.UNICODE)
pat = ur"i..[\u00F3\u00E1]"
re_futqal = re.compile(pat, re.UNICODE)
pat = ur"a.\u00E1."
re_pastqal = re.compile(pat, re.UNICODE)
pat = ur"(([mtyn\u00294]a)|(hi))..\u00E2"
re_hifil = re.compile(pat, re.UNICODE)
filename = sys.argv[1]
fobj = codecs.open(filename,'r',encoding='utf8')
lines = fobj.readlines()

new_lines = []
for line in lines:
	if "pos:part" in line and "ptn:&" in line:
		if re_partqal.search(line) != None:
			line = line.replace("ptn:&", "ptn:qal&")
		if re_parthifil.search(line) != None:
			line = line.replace("ptn:&", "ptn:hifil&")
		if re_partpiel.search(line) != None:
			line = line.replace("ptn:&", "ptn:piel&")
		if re_partnifal.search(line) != None:
			line = line.replace("ptn:&", "ptn:nifal&")

	if re_futqal.search(line) != None:
		line = line.replace("ptn:&", "ptn:qal&")

	if re_hifil.search(line) != None:
		line = line.replace("ptn:&", "ptn:hifil&")

	if re_hitpael.search(line) != None:
		line = line.replace("ptn:&", "ptn:hitpael&")
	new_lines.append(line)

for line in new_lines:
	sys.stdout.write(line)


