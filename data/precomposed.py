import regex as re
import sys, os, codecs, random, numpy as np
#Path: /Users/anthonymeyer/Documents/CHILDES_Hebrew/Transcripts/BermanLong/hagar 
UTF8Writer = codecs.getwriter('utf8')
sys.stdout = UTF8Writer(sys.stdout)
p1 = ur"[:*<=>'%]|[0-9]"
r1 = re.compile(p1, re.UNICODE)
#def map_to_precomposed(string, keep_acute_accents=True)

def main(inputfile, sample_size, same_length_str):
	# create two lists, when from which accents are removed and one in which they are retained.
	# create a single list with accents. From these, remove accents to get the second list.
	same_length = False
	if same_length_str == "same_length":
		same_length = True
	print "***", "same_length =", same_length
	withAccents = []
	withAccents_dict = {}
	no_dups = []
	letters = dict()
	letters_withAccents = dict()
	new_lines = list()
	fobj = codecs.open(inputfile, 'r', encoding='utf-8')

	lines = fobj.readlines()
	for line in lines:
		string = line
		string = unicode(string.replace(u"\n",u""))
		string = unicode(string.replace(u"\r",u""))
		if string not in no_dups:
			no_dups.append(string)
	sys.stderr.write("len no_dups = " + str(len(no_dups)) + "\n")
	sys.stderr.write("sample size = " + str(sample_size) + "\n")
	if len(no_dups) >= sample_size:
		withAccents = random.sample(no_dups, sample_size)
	else:
		withAccents = random.sample(no_dups, len(no_dups))
	withoutAccents = []
	for item in withAccents:
		withoutAccents.append(item)
	letters = {}
	# write file with accents
	new_string = u""
	duplicates = []
	accentless_string = ""
	letters = {}
	withoutAccents_dict = {}
	new_string = u""
	for string in withAccents:
		#string = line
		# string = unicode(string.replace(u"\n",u""))
		# string = unicode(string.replace(u"\r",u""))
		#if r1.search(string):
			#continue
		#t-dot
		new_string = unicode(string.replace(u"\u0074\u0323", u"\u1E6D"))
		#k-dot
		new_string = unicode(new_string.replace(u"\u006B\u0323", u"\u1E33"))
		#s-v
		new_string = unicode(new_string.replace(u"\u0073\u030C", u"\u0161"))
		#s-dot
		new_string= unicode(new_string.replace(u"\u0073\u0323", u"\u1E63"))
		#z-v
		new_string = unicode(new_string.replace(u"\u007A\u030C", u"\u017E"))
		#a-accent
		new_string = unicode(new_string.replace(u"\u0061\u0304", u"\u00E1"))
		#e-accent
		#new_string= unicode(new_string.replace(u"\u0065\u0304", u"\u00ED"))
		new_string = unicode(new_string.replace(u"\u0069\u0304", u"\u00E9"))
		#i-accent
		#new_string = unicode(new_string.replace(u"\u0069\u0304", u"\u00E9"))
		new_string= unicode(new_string.replace(u"\u0065\u0304", u"\u00ED"))
		#o-accent
		new_string = unicode(new_string.replace(u"\u006F\u0304", u"\u00F3"))
		#u-accent
		new_string = unicode(new_string.replace(u"\u0075\u0304", u"\u00FA"))
		# if string not in new_lines:
		# 	new_lines.append(string)

		accented_string = unicode(new_string)

		withAccents_dict[original_string] = 1
		#a-accent
		accentless_string = unicode(new_string.replace(u"\u00E1", u"\u0061"))
		#e-accent
		accentless_string = unicode(accentless_string.replace(u"\u00ED", u"\u0065"))
		#i-accent
		accentless_string = unicode(accentless_string.replace(u"\u00E9", u"\u0069"))
		#o-accent
		accentless_string = unicode(accentless_string.replace(u"\u00F3", u"\u006F"))
		#u-accent
		accentless_string = unicode(accentless_string.replace(u"\u00FA", u"\u0075"))
		# Okay. Now we have an accentless string derived from from the accented string
		## (by replacing accented precomposed chars with theri accentless counterparts.)
		## But this is a loss of information, and thus it may result in a loss of disntiction
		## between strings (words), thereby creating potential duplicates in the new
		## wordlist. We could remove one of the duplicates in the accentless wordlist, but this
		## would make the accentless wordlist shorter than the accented one, since each mapping
		## is one-to-one.
		## If we want both wordlists to be the same length, we mustn't add either duplicate
		## to the accentless wordlist, and moreover, we must deleted delete accented words
		## from the accented wordlist that gave rise to the accentless duplicates.
		if withoutAccents_dict.has_key(accentless_string):
			del withAccents_dict[accented_string]
		else:
			withoutAccents_dict[accentless_string] = 1
			for c in accentless_string:
				#sys.stderr.write(c)
				letters[c] = 1
	# 	for c in new_string:
	# 		#sys.stderr.write(c)
	# 		letters_withAccents[c] = 1
	# alphabet_list_withAccents = []
	# alphabet_list_withAccents = letters_withAccents.keys()
	# # for key in letters:
	# # 	alphabet_list.append(key)
	# alphabet_list.sort()
	# sys.stderr.write("alphabet length = " + str(len(alphabet_list_withAccents)) + "\n")
	# filename = "hbwrds" + "_" + str(len(alphabet_list_withAccents)) + "_" + str(len(withAccents_dict)) + ".txt"
	# fout_withAccents = codecs.open(filename, 'w', encoding='utf-8')
	# #fout_withAccents = UTF8Writer(fout_withAccents)
	# alphabet_withAccents = unicode("".join(alphabet_list_withAccents))
	# fout_withAccents.write(unicode(alphabet_withAccents) + u"\n")
	# # for string in withAccents:
	# # 	fout_withAccents.write(unicode(string) + u"\n")
	# for key, value in withAccents_dict.iteritems():
	# 	fout_withAccents.write(key + u"\n")
	# fout_withAccents.close()
	#new_lines.append(string + u"\n")
	# if sting not in new_lines:
	# 	new_lines.append(string)
	# write file without accents
	# letters = {}
	# withoutAccents_dict = {}
	# new_string = u""
	# #for n in range(len(withoutAccents)):
	# duplicates = []
	# for string in withoutAccents:
	# 	#string = line
	# 	#string = unicode(string.replace(u"\n",u""))
	# 	#string = unicode(string.replace(u"\r",u""))
	# 	#if r1.search(string):
	# 		#continue
	# 	#t-dot

	# 	new_string = unicode(string.replace(u"\u0074\u0323", u"\u1E6D"))
	# 	#k-dot
	# 	new_string = unicode(new_string.replace(u"\u006B\u0323", u"\u1E33"))
	# 	#s-v
	# 	new_string = unicode(new_string.replace(u"\u0073\u030C", u"\u0161"))
	# 	#s-dot
	# 	new_string= unicode(new_string.replace(u"\u0073\u0323", u"\u1E63"))
	# 	#z-v
	# 	new_string = unicode(new_string.replace(u"\u007A\u030C", u"\u017E"))
	# 	### Vowels
	# 	#a-accent
	# 	new_string = unicode(new_string.replace(u"\u0061\u0304", u"\u00E1"))
	# 	#e-accent
	# 	new_string= unicode(new_string.replace(u"\u0065\u0304", u"\u00ED"))
	# 	#i-accent
	# 	new_string = unicode(new_string.replace(u"\u0069\u0304", u"\u00E9"))
	# 	#o-accent
	# 	new_string = unicode(new_string.replace(u"\u006F\u0304", u"\u00F3"))
	# 	#u-accent
	# 	new_string = unicode(new_string.replace(u"\u0075\u0304", u"\u00FA"))

	# 	###
	# 	#a-accent
	# 	original_string = new_string
	# 	withAccents_dict[original_string] = 1
	# 	new_string = unicode(new_string.replace(u"\u00E1", u"\u0061"))
	# 	#e-accent
	# 	new_string = unicode(new_string.replace(u"\u00ED", u"\u0065"))
	# 	#i-accent
	# 	new_string = unicode(new_string.replace(u"\u00E9", u"\u0069"))
	# 	#o-accent
	# 	new_string = unicode(new_string.replace(u"\u00F3", u"\u006F"))
	# 	#u-accent
	# 	new_string = unicode(new_string.replace(u"\u00FA", u"\u0075"))
	# 	if withoutAccents_dict.has_key(new_string):
	# 		withAccents_dict.pop(original_string)
	# 	else:
	# 		withAccents_dict[new_string] = 1
		# #a-accent
		# original_string = new_string
		# new_string = unicode(new_string.replace(u"\u0061\u0304", u"\u0061"))
		# #e-accent
		# new_string = unicode(new_string.replace(u"\u0065\u0304", u"\u0065"))
		# #i-accent
		# new_string = unicode(new_string.replace(u"\u0069\u0304", u"\u0069"))
		# #o-accent
		# new_string = unicode(new_string.replace(u"\u006F\u0304", u"\u006F"))
		# #u-accent
		# new_string = unicode(new_string.replace(u"\u0075\u0304", u"\u0075"))
			#string = unicode(string)
		# if accent removal makes two words the same, save the *original* second word
		# to a list, namely 'duplicates'. The items of this list can then be 
		# found in the list "withAccents" and removed, so that len(withAccents) =
		# len(withoutAccents)
		# if withoutAccents_dict.has_key(new_string) == True and withAccents_dict.has_key(original_string) == True:
		# 	duplicates.append(original_string)
		# else:
		# 	withoutAccents_dict[new_string] = 1
		#sys.stderr.write(unicode(withoutAccents_dict[new_string]))
			# for c in new_string:
			# 	#sys.stderr.write(c)
			# 	letters[c] = 1
	sys.stdout.write("DUPLICATES =\n")
	for duplicate in duplicates:
		#sys.stdout.write("DUPLICATES = " + unicode(str(duplicates)) + "\n")
		sys.stdout.write(unicode(duplicate) + u"\t" + unicode(withAccents_dict.has_key(duplicate)) + u"\t" + unicode(same_length)+ u"\n" )
	sys.stdout.write(u"\n")
	if same_length:
		letters_withAccents = {}
		for word in duplicates:
			sys.stdout.write("DUPLICATE = " + unicode(duplicate) + "\n")
			del withAccents_dict[unicode(duplicate)]

	for key, value in withAccents_dict.iteritems():
		for c in key:
			letters_withAccents[unicode(c)] = 1

	alphabet_list_withAccents = []
	alphabet_list_withAccents = letters_withAccents.keys()
	alphabet_list_withAccents.sort()
	sys.stderr.write("alphabet length = " + str(len(alphabet_list_withAccents)) + "\n")
	filename = "hbwrds" + "_" + str(len(alphabet_list_withAccents)) + "_" + str(len(withAccents_dict)) + ".txt"
	fout_withAccents = codecs.open(filename, 'w', encoding='utf-8')
	alphabet_withAccents = unicode("".join(alphabet_list_withAccents))
	fout_withAccents.write(unicode(alphabet_withAccents) + u"\n")
	for key, value in withAccents_dict.iteritems():
		fout_withAccents.write(key + u"\n")
	fout_withAccents.close()

	alphabet_list = []
	alphabet_list = letters.keys()
	# for key in letters:
	# 	alphabet_list.append(key)
	alphabet_list.sort()
	sys.stderr.write("alphabet length = " + str(len(alphabet_list)) + "\n")
	filename = "hbwrds" + "_" + str(len(alphabet_list)) + "_" + str(len(withoutAccents_dict)) + ".txt"
	fout_withoutAccents = codecs.open(filename, 'w', encoding='utf-8')
	alphabet = unicode("".join(alphabet_list))
	#fout_withoutAccents = UTF8Writer(fout_withoutAccents)
	fout_withoutAccents.write(alphabet + u"\n")
	for key, value in withoutAccents_dict.iteritems():
		fout_withoutAccents.write(unicode(key) + u"\n")
	fout_withoutAccents.close()
	fobj.close()

if __name__ == '__main__':
	inputfile = sys.argv[1]
	sample_size = int(sys.argv[2])
	print "argv[3] =", sys.argv[3], "\n\n\n"
	sample_size = 12288
	main(inputfile, sample_size, sys.argv[3])
	# if sys.argv[3] == "removeAccents" or sys.argv[3] == "RemoveAccents":
	# 	main(inputfile, sample_size, keep_acute_accents=False)
	# else:
	# 	main(inputfile, sample_size, keep_acute_accents=True)