#!/usr/bin/env python
import sys, codecs
UTF8Writer = codecs.getwriter('utf8')
sys.stdout = UTF8Writer(sys.stdout)

input_file = sys.argv[1]
#fobj = open(input_file, "r")
fobj = codecs.open(input_file, 'r', encoding='utf-8')
lines = fobj.readlines()
alphabet = unicode(lines.pop(0))
#print alphabet
alphabet = alphabet.replace("\n", "")
alphabet = alphabet.replace("\r", "")
alphabet = alphabet.lstrip()
words = []
for line in lines:
	#print line
	word = unicode(line.replace("\n", ""))
	word = word.replace("\r", "")
	word = word.lstrip()
	words.append(word)
if alphabet[0] == unicode("#"): pass
else: alphabet = "#" + alphabet
sys.stdout.write(alphabet + "\n")
words.sort()
for word in words:
	sys.stdout.write(word + "\n")

