import math,pprint,random
import regex as re
import sys, codecs
reload(sys)  
sys.setdefaultencoding('utf8')
UTF8Writer = codecs.getwriter('utf8')
sys.stdout = UTF8Writer(sys.stdout)
sys.stderr = UTF8Writer(sys.stderr)

#pat = ur"(pos:n[^\s]*)(root:[^&][y][^&y]&ptn:CaC)(&)"
pat = ur"(\t[^vo\s\t\n]*pos:n[^\s]*)(root:[^&]y[^&y]&ptn:CaC)(&)"
re_IIy = re.compile(pat, re.UNICODE)
filename = sys.argv[1]
fobj = codecs.open(filename,'r',encoding='utf8')
lines = fobj.readlines()
pat = ur"(pos:(?:v)|(?:part))[^\s]*(root:)(byn)(ptn:)(CaC)"
new_lines = []
for line in lines:
	line = re_IIy.sub(ur"\1\3", line)
	#byn&ptn:CaC
	new_lines.append(line)

for line in new_lines:
	sys.stdout.write(line)


