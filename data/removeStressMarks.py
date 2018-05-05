#!/usr/bin/env python
import sys, codecs
UTF8Writer = codecs.getwriter('utf8')
sys.stdout = UTF8Writer(sys.stdout)

input_file = sys.argv[1]
fobj = codecs.open(input_file, 'r', encoding='utf-8')
lines = fobj.readlines()

for line in lines:
	#a-accent
	line = unicode(line.replace(u"\u00E1", u"\u0061"))
	#e-accent
	line = unicode(line.replace(u"\u00ED", u"\u0065"))
	#i-accent
	line = unicode(line.replace(u"\u00E9", u"\u0069"))
	#o-accent
	line = unicode(line.replace(u"\u00F3", u"\u006F"))
	#u-accent
	line = unicode(line.replace(u"\u00FA", u"\u0075"))
	sys.stdout.write(line)
