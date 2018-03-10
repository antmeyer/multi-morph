import regex as re
import sys, os, codecs, random
#Path: /Users/anthonymeyer/Documents/CHILDES_Hebrew/Transcripts/BermanLong/hagar 
UTF8Writer = codecs.getwriter('utf8')
sys.stdout = UTF8Writer(sys.stdout)
p1 = ur"[:*<=>'%]|[0-9]"
r1 = re.compile(p1, re.UNICODE)
#def map_to_precomposed(string, keep_acute_accents=True)
def main(inputfile, sample_size, keep_acute_accents=False):
	# create two lists, when from which accents are removed and one in which they are retained.
	letters = dict()
	new_lines = list()
	fobj = codecs.open(inputfile, 'r', encoding='utf-8')
	fobj_w = codecs.open(outputfile, 'w', encoding='utf-8')
	for line in fobj.readlines():
		string = line
		string = unicode(string.replace(u"\n",u""))
		string = unicode(string.replace(u"\r",u""))
		if r1.search(string):
			continue
		#t-dot
		string = unicode(string.replace(u"\u0074\u0323", u"\u1E6D"))
		#k-dot
		string = unicode(string.replace(u"\u006B\u0323", u"\u1E33"))
		#s-v
		string = unicode(string.replace(u"\u0073\u030C", u"\u0161"))
		#s-dot
		string = unicode(string.replace(u"\u0073\u0323", u"\u1E63"))
		#z-v
		string = unicode(string.replace(u"\u007A\u030C", u"\u017E"))
		### Vowels
		if keep_acute_accents == True:
			#a-accent
			string = unicode(string.replace(u"\u0061\u0304", u"\u00E1"))
			#e-accent
			string = unicode(string.replace(u"\u0065\u0304", u"\u00ED"))
			#i-accent
			string = unicode(string.replace(u"\u0069\u0304", u"\u00E9"))
			#o-accent
			string = unicode(string.replace(u"\u006F\u0304", u"\u00F3"))
			#u-accent
			string = unicode(string.replace(u"\u0075\u0304", u"\u00FA"))
			#string = unicode(string)
		elif keep_acute_accents == False:
			#general: will remove accents from all vowels
			string = unicode(string.replace(u"\u0061\u0304", u"\u0061"))
			#e-accent
			string = unicode(string.replace(u"\u0065\u0304", u"\u0065"))
			#i-accent
			string = unicode(string.replace(u"\u0069\u0304", u"\u0069"))
			#o-accent
			string = unicode(string.replace(u"\u006F\u0304", u"\u006F"))
			#u-accent
			string = unicode(string.replace(u"\u0075\u0304", u"\u0075"))
			#string = unicode(string)
		if string not in new_lines:
			new_lines.append(string)
			for c in string:
				#sys.stderr.write(c)
				letters[c] = 1
		#new_lines.append(string + u"\n")
		# if sting not in new_lines:
		# 	new_lines.append(string)
	alphabet_list = []
	for key in letters:
		alphabet_list.append(key)
	alphabet_list.sort()
	sys.stderr.write("keep_acute_accents = " + str(keep_acute_accents) + "; alphabet length = " + str(len(alphabet_list)) + "\n")
	alphabet = unicode("".join(alphabet_list))
	sys.stdout.write(alphabet + "\n")
	if len(new_lines) >= sample_size:
		random.sample(new_lines, sample_size)
	new_lines.sort()
	for line in new_lines:
		fobj_w.write(unicode(line) + u"\n")
	fobj.close()
		#sys.stdout.write(string + u"\n")

if __name__ == '__main__':
	inputfile = sys.argv[1]
	sample_size = int(sys.argv[2])
	if sys.argv[3] == "removeAccents" or sys.argv[3] == "RemoveAccents":
		main(inputfile, sample_size, keep_acute_accents=False)
	else:
		main(inputfile, sample_size, keep_acute_accents=True)