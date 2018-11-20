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
pat = ur".w.."
re_partqal = re.compile(pat, re.UNICODE)
pat = ur"m[^w].."
re_partpiel = re.compile(pat, re.UNICODE)
pat = ur"n[^w].."
re_partnifal = re.compile(pat, re.UNICODE)
pat = ur"m[^w].i."
re_parthifil = re.compile(pat, re.UNICODE)
pat = ur"[itnhm]((t)|([se][tv])|(zd))"
re_hitpael = re.compile(pat, re.UNICODE)
# pat = ur"u.\u00E1"
# re_pual = re.compile(pat, re.UNICODE)
pat = ur"[itna]..w."
re_futqal = re.compile(pat, re.UNICODE)
# pat = ur"a.\u00E1."
# re_pastqal = re.compile(pat, re.UNICODE)
pat = ur"(([imtna])|(h))..i"
re_hifil = re.compile(pat, re.UNICODE)
filename = sys.argv[1]
fobj = codecs.open(filename,'r',encoding='utf8')
lines = fobj.readlines()
pat = ur"(pos:)(v|(?:part))([^\s]*)(ptn:)(CaC)(&|$)"
re_CaC = re.compile(pat, re.UNICODE)

new_lines = []
for line in lines:
	line = re_CaC.sub(ur"\1\2\3\4qal\6", line)
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
	# line = re_IIy.sub(ur"\1\3", line)
	# new_lines.append(line)

for line in new_lines:
	sys.stdout.write(line)


