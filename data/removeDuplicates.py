#!/usr/bin/env python
import sys, codecs
UTF8Writer = codecs.getwriter('utf8')
sys.stdout = UTF8Writer(sys.stdout)
sys.stderr = UTF8Writer(sys.stderr)
input_file = sys.argv[1]
fobj = codecs.open(input_file, 'r', encoding='utf-8')
lines = fobj.readlines()

attested = dict()

for line in lines:
	if attested.has_key(line):
		sys.stderr.write("Duplicate: " + line)
		pass
	else:
		attested[line] = 1
		sys.stdout.write(line)


