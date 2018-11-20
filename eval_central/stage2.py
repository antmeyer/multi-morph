import sys, codecs, unicodedata, re
#import pathfinder
from get_active import *
import stage1_alt as stage1
from best_path import *
reload(sys)  
sys.setdefaultencoding('utf8')
UTF8Writer = codecs.getwriter('utf8')
sys.stdout = UTF8Writer(sys.stdout)
sys.stderr = UTF8Writer(sys.stderr)

# Goal: Assemble words_and_morphs dictionary
# Required:
	# clusterIDs_and_words file  -> clusterIDs_and_words dict
	# clusterIDs_and_morphs file -> clusterIDs_and_morphs_dict
	## However,the clusterIDs_and_morphs data will probably be 
	## passed to this module directly.
# Read in clusters file.
# Build clusters_and_words dictionary
# Read in morphs, i.e., a file mapping cluster IDs to morphs (clusters_and_morphs?)
# Iterate over cluster indices, and then over words, appending 
	# unseen words to the value of words_and_morphs[word], which is a list.
morphs_ex = {u"0":u"k", u"1":u"klb", u"2":u"lb", u"3":u"i"}
words_and_morphIDs_ex = {u"klbi":[u"0",u"1",u"2",u"3"]}

cluster_dict = {u"0":[u"klbi"],
				u"1":[u"klbi"],
				u"2":[u"klbi"],
				u"3":[u"klbi"]}

cluster_dict2 = {u"0":[u"d\u00E9let", u"\u0294om\u00E9ret"],
				u"1":[u"had\u00E9let"],
				u"2":[u"bad\u00E9let"],
				u"3":[u"bed\u00E9let"]}

mapping_ex = {(u"k",0):[u"0",u"1"], (u"l",1):[u"1",u"2"], (u"b",2):[u"1",u"2"], (u"i",3):[u"3"]}
UTF8Writer = codecs.getwriter('utf8')
sys.stdout = UTF8Writer(sys.stdout)

pat1 = ur"^aa&"  # The "^aa&" abd "^zz&" markers (or tags) are assigned in stage1. The
# former indicates a prefix, the latter a suffix.
re_prefixTag = re.compile(pat1, re.UNICODE)
pat2 = ur"^zz&"
re_suffixTag  = re.compile(pat2, re.UNICODE)

# def morph_validity_test(word_chars_available, morph):
# 	# Make sure that each character in the morph is present in the word itself.
# 	# Moreover, make sure that each word character corresponds to one and only morph.
# 	# For example, given the word 'klbi', ther morphs 'k' and 'klb' cannot be present in 
# 	# the same analysis, since there is only one 'k' in 'klbi'. However, these morphs 
# 	# may be present in different analyses.
# 	word_chars = list(word_chars_available)
# 	for morph_char in morph:
# 		if morph_char in word_chars:
# 			try: index = word_chars.index(morph_char)
# 			except IndexError: continue
# 			word_chars.pop(index)
# 		else:
# 			return False
# 	return True

# def morph_validity_test(word_chars, morph):
# 	# Make sure that each character in the morph is present in the word itself.
# 	# Moreover, make sure that each word character corresponds to one and only morph.
# 	# For example, given the word 'klbi', ther morphs 'k' and 'klb' cannot be present in 
# 	# the same analysis, since there is only one 'k' in 'klbi'. However, these morphs 
# 	# may be present in different analyses.
# 	#word_chars = list(word_chars_available)
# 	for morph_char in morph:
# 		if morph_char in word_chars:
# 			try: index = word_chars.index(morph_char)
# 			except IndexError: continue
# 			word_chars.pop(index)
# 		else:
# 			return False
# 	return True

# def morph_validity_test(word_chars_available, morph):
# 	# Make sure that each character in the morph is present in the word itself.
# 	# Moreover, make sure that each word character corresponds to one and only morph.
# 	# For example, given the word 'klbi', ther morphs 'k' and 'klb' cannot be present in 
# 	# the same analysis, since there is only one 'k' in 'klbi'. However, these morphs 
# 	# may be present in different analyses.
# 	#word_chars = list(word_chars_available)
# 	for morph_char in morph:
# 		if morph_char in word_chars_available: return False
# 	return True

# def morph_validity_test(word_chars_available, morph):
# 	word_chars = list(word_chars_available)
# 	for morph_char in morph:
# 		if morph_char in word_chars:
# 			try: index = word_chars.index(morph_char)
# 			except IndexError: continue
# 			word_chars.pop(index)
# 		else:
# 			return False
# 	return True

# def morph_is_good(morph, avail_chars):
# 	for morph_char in list(morph):
# 		if morph_char not in avail_chars: 
# 			return False
# 	return True

def morph_is_good(regex_match_obj, avail_chars):
	#for morph_char in list(morph):
	# The equivalent to morph (a string) and its characters is 
	# the morph object and its regex attribute, which contains characters.
	# However, if the regex has a disjunction, its characters can vary.
	# Consider, e.g., the regex "(d|h).?(i)". It would match both s1 = "diber" and s2 = "hiqtil".
	# The former yields groups (d, i), while the latter yields groups (h,i).
	# What about something like "dahir"? The word "dahir" matches, but it yields
	# groups (h,i). The "d" is not a matching character because it does not
	# precede the "i" by one or fewer intervening characters and thuse fails to
	# meet the requirement imposed by the ".?" part of the regex "(d|h).?(i)".
	# if the 'd' feature is "d@[0]", then d should precede h in every word belonging
	# to the cluster in question. But this is usually not true. Whenever positional
	# and precedence features are both active for a given word, the two types of 
	# features often--maybe even usually--contradict each other. Perhaps we should
	# always prefer one type to another when both are present. Perhaps we should
	# as a rule prefer the precedence type. 
	# The following words come from a cluster among whose features the precedence
	# feature "t<a" (delta = 2) was most active:
	# Aakalta (0.9817), webakta (0.9816), Aitah (0.9815), tagiYi (0.9815), 
	# racita (0.9815), lehabayta (0.9815), heknasta (0.9815), hafakta (0.9815), 
	# bakta (0.9815)
	# These words are highly typical of this cluster's members. Notice the tendency
	# for the "t<a" precedence relation to correspond to suffixes and prefixes.
	# Clearly, precedence features are flexible; they can encode prefixal and suffixal
	# morphs as well as (components of) nonconcatenative morphs.
	# Precedence features arguably convey more information that positional features 
	# (or perhaps better information). 
	#pat = morph_object.get_pattern()
	#re_morph = re.compile(pat, re.UNICODE)
	#regex_match_obj = re_morph.search(word)
	for group in regex_match_obj.groups():
		if group not in avail_chars: 
			return False
	return True

# def make_chars_unavailable(morph, avail_chars):
# 	char_list = list(morph)
# 	for letter in char_list:
# 		avail_chars.remove(letter)
# 	return avail_chars

def make_chars_unavailable(regex_match_obj, avail_chars):
	for group in regex_match_obj.groups():
		avail_chars.remove(group)
	return avail_chars

def morph_validity_test(word_chars_available, morph):
	word_chars = list(word_chars_available)
	for morph_char in morph:
		if morph_char in word_chars:
			try: index = word_chars.index(morph_char)
			except IndexError: continue
			word_chars.pop(index)
		else:
			return False
	return True

def remove_chars(word_chars_available, valid_morph):
	# Once a word character has been linked to a morph character, that word_char must
	## be removed from consideration. That is, it cannot be linked to another morph char
	## character (not in the present morph or in another morph).
	for morph_char in valid_morph:
		try: index = word_chars_available.index(morph_char)
		except ValueError: continue
		word_chars_available.pop(index)
	return word_chars_available

# def get_clusterIDs_and_words(filename):
# 	fobj = open(filename, 'r')
# 	for line in fobj.readlines()
# def segment_example(words_and_morphIDs, mapping):
# 	for word in words_and_morphIDs.keys():
# 		#mapping = map_morphChars_to_wordChars(word):
# 		working_segmentations = [""]
# 		for key, morphID_list in mapping.items():  # equivalent to "for char in word"
# 			# key is a pair of items, i.e., a 2-lenght tuple.
# 			letter = key[0]
# 			index = key[1]
# 			if letter_freqs.has_key(letter):
# 				letter_freqs[letter] += 1
# 			else:
# 				letter_freqs[letter] = 0
# 			new_segmentations = []
# 			for morphID in mapping[key]:
# 				morph = morphs[morphID]
# 				for n in range(len(working_segmentations)):
# 					seg_str = working_segmentations[n]
# 					if (seg_str[-1] == morph[0] and word[n] != morph[0]) or re.search(unicode(morph)) + ur"$", seg_str):
# 						pass
# 					else:
# 						working_segmentations[n] += "+" + morph
# 					new_segmentations.append(working_segmentations[n])
# 				working_segmentations = list(new_segmentations)


# def map_morphChars_to_wordChars(word, cluster_assignment_dict, morph_dict):
# 	# What is 'morph_dict'? Should it in fact be a dict? Or will a list suffice,
# 	## i.e., a list of mophID-morph pairs for a given word?
# 	## The morphs, of course, are clusters in which the word in question belongs.
# 	# Now, the list of clusters (= morphs), are interpreted as likely "causes" of
# 	## "surface properties" in the word. There is no ranking among the clusters in
# 	## a list. Therefore, if two or more ambiguous readings are present in the list,
# 	## there is no indication of which morph goes with which reading. This will be
# 	## sorted out later.
# 	mapping = {}
# 	prefixes = []
# 	stem_components = []
# 	suffixes = []
# 	morphs_by_type = [[], [], []]
# 	pat1 = ur"^aa&"
# 	morphs = []
# 	morphIDs = []
# 	# get the current word's morphs
# 	morphIDs = cluster_assignment_dict[word]
# 	re_prefixTag = re.compile(pat1, re.UNICODE)
# 	pat2 = ur"^zz&"
# 	re_suffixTag  = re.compile(pat2, re.UNICODE)
# 	for morphID, morph in morph_dict.items():
# 		if re_pre.search(morph):
# 			morphs_by_type[0].append((re_pre.sub(u"", morph), morphID))
# 		elif re_suffixTag .search(morph):
# 			morphs_by_type[2].append((re_suffixTag .sub(u"", morph), morphID))
# 		else:
# 			morphs_by_type[1].append((morph, morphID))
# 	# klbi = (1) "my dog", (2) "as my heart"
# 	# In (1), the 'k' is a prefix, and will be marked as such in the morphs dict,
# 	# whereas in (2), the 'k' is part of the stem (in particular, the root).
# 	# The ambiguity will consist mainly of this: a letter near the beginning
# 	# of the may be a prefix or a stem letter.
# 	for n in range(len(morphs_by_type)):
# 		for morph, morphID in morphs_by_type[n]:
# 			for i in range(len(morph)):
# 				for j in range(len(word)):
# 					if morph[i] == word[j]:
# 						word_char_tuple = (word[j],j)
# 						if mapping.has_key(word_char_tuple):
# 							mapping[word_char_tuple].append(morphID)
# 						else:
# 							mapping[word_char_tuple] = [morphID]
# 	return mapping

def process_clustering_file(cluster_file):
	cfobj = codecs.open(cluster_file, encoding='utf8')
	pat = ur"\s\([0-9]\.[0-9]{4}\)"  # This is the pattern for activity values.
	re_activity = re.compile(pat, re.UNICODE)
	pat = ur"##\s"
	re_ID_marker = re.compile(pat2, re.UNICODE)
	pat = ur"%%"
	re_end_marker = re.compile(pat, re.UNICODE)
	WORDS = False
	clusters = dict()
	lines = cfobj.readlines()[1:]
	n = 0
	prev_line = ""
	for line in lines:
		string = line.replace("\n", "")
		####print string
		if string == "": continue
		elif "##" in string:

			WORDS = True
			###print string
			#clusterID = unicode(int(re_delimeter1.sub(u"", string)))
			#clusterID = int(string.split()[-1])
			####print clusterID, string
			#continue
			items = string.split()
			clusterID = int(items[-1])
			#clusterID = n
			continue
		#elif re_end_marker.match(string):
		elif "%%" in string:
			WORDS = False
			####print string
		if WORDS == True:		
			WORDS = False
			# Split first by the comma delimiter, then 
			# Replace paranthses-enclosed values with empty string
			#string = line.replace("\n", "")
			####print string
			#string = re_activity.sub(u"", string) # Removes activity. But what about the parentheses?
			#words = string.split(u",")
			items = string.split(",")
			words = []
			for item in items:
				words.append(item.split()[0])
			# if self.clusters.has_key(clusterID):
			# 	self.clusters[clusterID].append(words)
			# else: self.clusters[clusterID] = words
			clusters[clusterID] = list(words)
		#n += 1
	# for key,val in clusters.items():
	# 	#print key, ":", ", ".join(val)
	return clusters

class Stage2:

	#def __init__(self, output_of_stage1, cluster_file):
	#def __init__(self, output_of_stage1, clusters_and_words_dict, clusters_file_name, word_list):
	def __init__(self, output_of_stage1, clusters_and_words_dict, clusters_file_name):
		# output_of_stage1 is a dict: Keys are clusterIDs. Values are morphs.
		# In this dict, each clusterID should correspond to one and only one morph.
		# We will set the attribute 'self.morph_dict' equal to output_of_stage1.
		#print "STAGE 2, CLUSTERS FILE:",clusters_file_name, "-->", clusters_file_name.split(".")
		self.morph_dict = output_of_stage1
		#self.clusters = {}
		basename,suffix = clusters_file_name.split(".")
		self.base_file_name = basename
		self.clusters = clusters_and_words_dict
		self.seg_dict = {}
		self.seg_dict_morphIDs = {}
		#self.alignments = dict()
		self.clusters_file_name = clusters_file_name
		#self.aux_outputfile = clusters_file_name.split(".")[0]
		#self.aux_outputfile += "_morphStrings.txt"
		self.charToMorphAlignments = {}
		alphabet = u"\u1E33\u1E6D\u1E63\u0161\u0294\u0295\u00E1\u00E2\u00E9\u00F3\u00FA\u00E7\u029D\u017E"
		alphabet += u"abcdefghijklmnopqrstuvwxyz"
		alpha_list = list(alphabet)
		#self.words_to_morphIDs_to_charIndices_dict = {}
		self.morphToCharAlignments_allWords = {}
		#self.wordlist = word_list
		self.covered_words = []
		# 'self.clusters' will be a dict; keys = cluster_IDs,
		# and values = lists of words. It will thus say, for each cluster, which
		# words are members of that cluster.
		# 'self.words_and_morphIDs' will be a dict whose keys are words. The value of 
		# each key will be a list of morph_IDs (= cluster_IDs)
		# In others words, self.words_and_morphIDs will be the same as a dict named
		## self.words_and_clusterIDs, or even self.words_and_clusters.
		self.words_and_morphIDs = {}
		#self.segmentations = {}
		self.exception_words = []
		self.compressed_morph_seqs = {}
		self.index_bundles = {}
		# cfobj = codecs.open(cluster_file, encoding='utf-8')
		# pat = ur"\([0-9]\.[0-9]{4}\)"  # This is the pattern for activity values.
		# re_activity = re.compile(pat, re.UNICODE)
		# pat = ur"\#{2}\s"
		# re_delimeter1 = re.compile(pat2, re.UNICODE)
		# pat = ur"\%{2}"
		# re_delimeter2 = re.compile(pat, re.UNICODE)
		# Define 'WORDS' flag to keep track of whether or not the next line contains words to extract.
		# WORDS = False
		# self.clusters = dict()
		# for line in cfobj.readlines():
		# 	string = line.replace("\n", "")
		# 	if re_delimeter1.match(string): #if line[0] == u"#":
		# 		WORDS = True
		# 		clusterID = unicode(str(int(re_delimeter1.sub(u"", string))))
		# 		####print clusterID, string
		# 		continue
		# 	if re_delimeter2.match(string):
		# 		WORDS = False
		# 		####print string
		# 	if WORDS == True:
				#WORDS = False
				# Split first by the comma delimiter, then 
				# Replace paranthses-enclosed values with empty string
				#string = line.replace("\n", "")
				# string = re_activity.sub(u"", string) # Removes activity. But what about the parentheses?
				# words = string.split(u",")
				# if self.clusters.has_key(clusterID):
				# 	self.clusters[clusterID].append(words)
				# else: self.clusters[clusterID] = words

		# Invert clusters dict to obtain words_and_morphIDs dict. Remember that
		# morphIDs are equivalent to clusterIDs.
		# How "active" are these clusters?
		for clusterID, word_list in sorted(self.clusters.items()):
			###print clusterID, ",".join(word_list[0:10])
			for word in word_list:
				#sys.stderr.write(word + "\n")
				##print word, word_list[0:2]
				# clusterID = morphID
				#self.alignments[word] = {}
				if self.words_and_morphIDs.has_key(word):
					self.words_and_morphIDs[word].append(clusterID)
					# if clusterID < 10:
					# 	#print "==========================================================", clusterID
				else:
					self.words_and_morphIDs[word] = [clusterID]
					# if clusterID < 10:
					# 	#print "+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+", clusterID
				###print 
	# def assign_words_to_morphs(self, clusterIDs_and_morphs):
	# 	"""Returns a dictionary wherein each unique word is a key, the value of which
	# 	is the list of morphs associated with the word in question."""
	# 	words_and_morphs = dict()
	# 	for k in range(len(self.clusters)):
	# 	#for cluster in clusterIDs_and_words:
	# 		for word in clusterIDs_and_words[k]:
	# 			# the index k points to the corresponding morph in the list clusterIDs_and_morphs.
	# 			morph = clusterIDs_and_morphs[k]
	# 			if self.words_and_morphIDs.has_key(word):
	# 				words_and_morphs[word].append(morph)
	# 			else:
	# 				words_and_morphs[word] = [morph]
	# 	return words_and_morphs

	def map_morphChars_to_wordChars(self, word):
		# What is 'morph_dict'? Should it in fact be a dict? Or would a list suffice,
		## i.e., a list of mophID-morph pairs for a given word?
		## The morphs, of course, are clusters in which the word in question belongs.
		# Now, the list of clusters (= morphs), are interpreted as likely "causes" of
		## "surface properties" in the word. There is no ranking among the clusters in
		## a list. Therefore, if two or more ambiguous readings are present in the list,
		## there will be no indication of which morph goes with which reading. This will be
		## sorted out later.

		# pat1 = ur"^aa&"  # The "^aa&" abd "^zz&" markers (or tags) are assigned in stage1. The
		# # former indicates a prefix, the latter a suffix.
		# re_prefixTag = re.compile(pat1, re.UNICODE)
		# pat2 = ur"^zz&"
		# re_suffixTag  = re.compile(pat2, re.UNICODE)
		#self.alignments[word] = {}
		###print "*********************************", "\n", word, 
		#for item in self.words_and_morphIDs[word]:
			###print str(item) + " "
		###print "*********************************"
		mapping = {}
		for i in range(len(word)):
			#mapping[i] = self.letter_dict(word[i])
			mapping[i] = word[i]
		#mapping[word] = {}
		#morphs_by_type = [[], [], []]
		morph_tuples = []
		# Get the current word's morphs from 'self.morph_dict', which is the dictionary 
		# of morphs obtained from stage 1.
		#morphIDs = self.words_and_morphIDs[word]
		#sys.stdout.write(word + "\t")
		for morphID in self.words_and_morphIDs[word]:
			#if morphID < 10: #print "***********************************************", morphID
			#sys.stdout.write(":" + str(morphID) + ",")
			try: morph_weight_pair = self.morph_dict[morphID]
			except KeyError:
				self.exception_words.append(word)
				continue
			morph_object = morph_weight_pair[-1]
			morph_tuples.append((morphID, morph_object))
		#sys.stdout.write("\n")
		# sys.stdout.write(word + "\t")
		# for morphID in self.words_and_morphIDs[word]:
		# 	sys.stdout.write(":" + str(morphID) + ",")
		# sys.stdout.write("\n")
		####print "morph_tuples:", morph_tuples
		# The 'morph_types' are prefix, stem, and suffix.
		## They are the three subgroups in 'morphs_by_type'.
		## They have a certain order: 'n' below is the variable
		## that corresponds to this ordering.
		# for morphID, morph in morph_tuples:
		# 	if re_prefixTag.search(morph):
		# 		morphs_by_type[0].append((re_prefixTag.sub(ur"", morph), morphID))
		# 	elif re_suffixTag.search(morph):
		# 		morphs_by_type[2].append((re_suffixTag.sub(ur"", morph), morphID))
		# 	else: # the morph is of the stem type.
		# 		morphs_by_type[1].append((morph, morphID))
		
		# for morphID, morph_object in morph_tuples:
		# 	if morph_object.get_morph_type() == "prefix":
		# 		morphs_by_type[0].append((morph_object, morphID))
		# 	elif morph_object.get_morph_type() == "stem":
		# 		morphs_by_type[1].append((morph_object, morphID))
		# 	# elif morph_object.get_morph_type() == "suffix2":
		# 	# 	morphs_by_type[2].append((morph_object, morphID))
		# 	elif morph_object.get_morph_type() == "suffix":
		# 		morphs_by_type[3].append((morph_object, morphID))
			# if re_prefixTag.search(morph):
			# 	morphs_by_type[0].append((re_prefixTag.sub(ur"", morph), morphID))
			# elif re_suffixTag .search(morph):
			# 	morphs_by_type[2].append((re_suffixTag.sub(ur"", morph), morphID))
			# else: # the morph is of the stem type.
			# 	morphs_by_type[1].append((morph, morphID))
		####print "morphs_by_type:", morphs_by_type
		# klbi = (1) "my dog", (2) "as my heart"
		# In (1), the 'k' is a prefix, and will be marked as such in the morphs dict,
		# whereas in (2), the 'k' is part of the stem (in particular, the root).
		# The ambiguity consists mainly in this: a letter near the beginning
		# of the may be a prefix or a stem letter.
		for morphID, morph_object in morph_tuples:
			#if morphID < 10:

			#print "MORPH_ID:", morphID, "; MORPH_OBJ PAT =", morph_object.get_pattern(), "; WORD =", word,
			##print word, morph_object.get_pattern(),
			#if morphID < 10: #print "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& ", morphID
			re_morph = re.compile(morph_object.get_pattern(), re.UNICODE)
			#print "MORPH PATTERN:", morph_object.get_pattern()
			try: match_obj = re_morph.search(word)
			except AttributeError: 
				
				continue
			#num_letters = morph_object.get_num_letters()
			#if match_obj.groups() != None:
			if match_obj == None:
				#print ">>> NO MATCH!", "continue;"
				continue
			try: 
				my_groups = match_obj.groups()
				##print my_groups,
				#my_span = match_obj.span()
			except AttributeError:
				#print ">> NO GROUPS!", "continue;",
				##print ""
				continue

			# else:
			#print "\t",
			for i in range(len(my_groups)):
				letter = my_groups[i]
				#print letter,
				# try: idx_in_word = word.index(letter)
				# except IndexError:
				# 	##print "!!! INDEX ERROR !!!" 
				# 	continue
				try: 
					idx = match_obj.span(i+1)[0]
					#print idx,
				except AttributeError:
					#print "NO SPAN!", "continue;",

					continue
					#start_idx = index_range[0]
					#end_idx = index_range[1]
					#if end_idx - start_idx < 2:
					# if self.alignments[word].has_key(start_idx):
					# 	self.alignments[word][start_idx].append(morph_ID)
					# self.alignments[word][start_idx] = [morph_ID]
					#sys.stderr.write("Start and End Indices: " + str(start_idx) + " " + str(end_idx) + "\n")
					# if mapping.has_key(idx):
					# 	mapping[idx].append(morphID)
					# mapping[idx] = [morphID]
				#else:
				try: mapping[idx].append(morphID)
				except AttributeError:
					#print "Can't append to", type(mapping[idx]), "!"
					mapping[idx] = [morphID]
			#print ""
						# else:
						# 	avail_chars.remove()
				# for i in range(len(match_obj.groups())):
				# 	letter = my_groups([i])
				# 	try: idx_in_word = word.index(letter)
				# 	except IndexError:
				# 		###print "!!! INDEX ERROR !!!" 
				# 		continue
				# 	else:
						#wordChar_index_pair = (idx_in_word, word[idx_in_word]) # This is a pair containing a letter and its index in the word,
						# but with the index coming first (before the letter) in the pair.
						# For a given word, the 'mapping' dict maps each such pair (essentially each letter in the
						# target word) to a list of morphs (morph IDs).
						# The reason the values are lists instead of single morph IDs is that there could 
						# be ambiguity.
						# But would the ambiguity be real or the result of erroneous processing?
						# The mapping dict is constructed on a word-by-word basis in the function 'segment'.
					# if mapping.has_key(wordChar_index_pair):
					# 	mapping[wordChar_index_pair].append(morphID)
					# else:
					# 	mapping[wordChar_index_pair] = [morphID]
				#print "  ",
			#print ""	
		# for n in range(len(morphs_by_type)):
		# 	for morph_object, morphID in self.words_and_morphIDs[word]:
		# 		# #re_morph = morph_object.get_regex()
		# 		# groups = re_morph.search(word)
		# 		# num_letters = morph_object.get_num_letters()
		# 		# if groups != None:
		# 		for i in range(len(morph)):
		# 			for j in range(len(word)): # For each morph letter, visit all word letters.
		# 				if morph[i] == word[j]:
		# 					wordChar_index_pair = (j, word[j]) # This is a pair containing a letter and its index in the word,
		# 					# but with the index coming first (before the letter) in the pair.
		# 					# For a given word, the 'mapping' dict maps each such pair (essentially each letter in the
		# 					# target word) to a list of morphs (morph IDs).
		# 					# The reason the values are lists instead of single morph IDs is that there could 
		# 					# be ambiguity.
		# 					# But would the ambiguity be real or the result of erroneous processing?
		# 					# The mapping dict is constructed on a word-by-word basis in the function 'segment'.
		# 					if mapping.has_key(wordChar_index_pair):
		# 						mapping[wordChar_index_pair].append(morphID)
		# 					else:
		# 						mapping[wordChar_index_pair] = [morphID]			
			# for morph, morphID in morphs_by_type[n]:
			# 	for i in range(len(morph)): # Iterate over the letters of the morph
			# 		for j in range(len(word)): # For each morph letter, visit all word letters.
			# 			if morph[i] == word[j]:
			# 				# This is a pair containing a letter and its index in the word.
			# 				# wordChar_index_pair = (word[j],j)
			# 				wordChar_index_pair = (j, word[j])
			# 				# For a given word, 'mapping' dict maps each such pair to a list of morphs (morph IDs).
			# 				# The reason the values are lists instead of single morph IDs is that there could 
			# 				# be ambiguity.
			# 				# But would the ambiguity be real or the result of erroneous processing?
			# 				# The mapping dict is constructed on a word-by-word basis in the function 'segment'.
			# 				if mapping.has_key(wordChar_index_pair):
			# 					mapping[wordChar_index_pair].append(morphID)
			# 				else:
			# 					mapping[wordChar_index_pair] = [morphID]
		##print ""
		# print "stage2: MAPPING:"
		# for pair,lst in mapping.items():
		# # 	###print pair, ": ", ", ".join(lst) 
		# 	print "stg2; pair,list =", pair, lst
		return mapping

	
	def segment(self):

		"""
		[I think 'words and morphs' should contain lists of morph-IDs rather than actual morphs 
		in string form. But then we would also need a list of morphs to access indices for IDs.
		But then the morph-IDs would simply be the cluster-IDs--except that some clusters will not
		be associated to morphs. I guess we just skip these.]
		This function takes as input 'words_and_morphs', which is a dictionary whose keys are words,
		and the each key's value is a list of morphIDs.
		Each word is thus associated with a (single?) list of morphs. 
		*** Each list is sorted so that any/all prefixes precede 
		any/all stem components, which precede any/all suffixes. ***
		1. Pop morph.
		2. Match each character in the morph to a character in the word.
		3. Somehow designate each paired-off character in the word as now unavailable.
		   Maybe pop the character from the word and put in the dictionary.
		4. Repeat Steps 1-3 for the next morph.
		* Create a temporary dictionary in which each letter in a given word is mapped 
		to a morph-ID until either the word runs out of letters or the morph(s) 
		(and their letters) are exhausted. Keys: Morph-IDs. Values: Lists of characters
		"""
		self.seg_dict = {}
		#new_morph_dict = {}
		# for morphID,morph in self.morph_dict.items():
		# 	new_morph = re_prefixTag.sub(ur"", morph)
		# 	new_morph = re_suffixTag.sub(ur"", new_morph)
		# 	new_morph_dict[morphID] = new_morph
		#for morphID, morph_object in self.morph_dict.items():

		# segments = []
		# mapping = {}
		# letter_freqs = dict{}
		# for word in self.words_and_morphIDs.keys(): 
		# 	mapping = self.map_morphChars_to_wordChars(word):
		# 	working_segmentations = [""]
		# 	for key, morphID_list in mapping.items():  # equivalent to "for char in word"
		# 		# key is a pair of items, i.e., a 2-lenght tuple.
		# 		letter = key[0]
		# 		index = key[1]
		# 		if letter_freqs.has_key(letter):
		# 			letter_freqs[letter] += 1
		# 		else:
		# 			letter_freqs[letter] = 0
		# 		new_segmentations = []
		# 		for morphID in mapping[key]:
		# 			morph = self.morph_dict[morphID]
		# 			for n in range(len(working_segmentations)):
		# 				seg_str = working_segmentations[n]
		# 				if (seg_str[-1] == morph[0] and word[n] != morph[0]) or re.search(unicode(morph) + ur"$", unicode(seg_str)):
		# 					pass
		# 				else:
		# 					working_segmentations[n] += "+" + morph
		# 				new_segmentations.append(working_segmentations[n])
		# 			working_segmentations = list(new_segmentations)

	#def segment_example(words_and_morphIDs, mapping, morphs):
		#sys.stderr.write(str(words_and_morphIDs) + "\n\n")
		#sys.stderr.write(str(mapping) + "\n\n")
		#sys.stderr.write(str(morphs) + "\n\n")
		# word_chars_available = []
		# for word in self.words_and_morphIDs.keys():
		# 	word_chars = list(word)
		# 	sys.stderr.write("word = " + word + "\n\n")
		# 	#mapping = map_morphChars_to_wordChars(word):
		# 	working_segmentations = []
		# 	mapping = self.map_morphChars_to_wordChars(word)
		# 	mapping_items = mapping.items()
		# 	###print "Mapping Items:",mapping_items
		# 	###print "new_morph_dict:", new_morph_dict
		# 	####print "0", mapping_items
		# 	#for key, morphID_list in mapping.items():  # equivalent to "for char in word"
		# 	morphID_list = mapping_items[0][1] # the 1st morph-ID list (probably associated with the word's 1st letter)
		# 	###print "'mapping_items[0][1]':", morphID_list
		# 	###print "'words_and_morphIDs[", word, "]':", self.words_and_morphIDs[word]
		# 	char_index_pair = mapping_items[0][0]
		# 	letter = char_index_pair[0]
		# 	index = char_index_pair[1]
		# 	#word_chars_available = [list(word) for n in range(len(morphID_list))]
			
		# 	#word_chars_available = []
		# 	# Within a *particular* segmentation hypothesis, each word char can only be linked to one morph.
		# 	# That is, within a given segmentation, the 'k' in 'klbi' can be associated with either the morph
		# 	# 'k' or the morph 'klb', but not both.
			
		# 	# for m in range(len(morphID_list)):
		# 	# 	word_chars_available[m] = list(word_chars)
		# 	# ###print "WCA:", word_chars_available
		# 	# morph_list = []
		# 	# for morphID,morph in new_morph_dict:
		# 	# 	new_morph = re_prefixTag.sub(ur"", morph)
		# 	# 	new_morph = re_suffixTag.sub(ur"", new_morph)
		# 	# 	morph_list.append(new_morph)
		# 	#working_segmentations = [[] for morph_ID in morphID_list]
		# 	#word_chars_available = [list(word_chars) for morph_ID in morphID_list] 
		# 	prestars = "*"

		# 	for m in range(len(morphID_list)):
		# 		###print prestars, morphID_list[m]
		# 		word_chars_available[m] = list(word_chars)
		# 		###print prestars, "WCA:", word_chars_available
		# 		morphID = morphID_list[m]
		# 		morph = new_morph_dict[morphID]
		# 		####print "00", morph, "m =", m
		# 		# morph = re_prefixTag.sub(ur"", morph)
		# 		# morph = re_suffixTag.sub(ur"", morph)
		# 		working_segmentations.append([morph])
				
		# 		#working_segmentations.append([])

		# 		# Each item in working segmentations is a distinct segmentation hypothesis. Each segmentation
		# 		# hypothesis can grow as the analysis proceeds.
		# 		word_chars_available[m] = list(remove_chars(word_chars_available[m], morph))
		# 		###print prestars, "WORKING SEGS:", working_segmentations
		# 		prestars += "*"
		# 		####print "00", morph, "***", m, word_chars_available[m], "& seg =", working_segmentations[m]
		# 		####print "000", morphID, morph, "***", m, word_chars_available[m], "& seg =", working_segmentations[m]
		# 	####print ""
		# 		####print "WCA:", word_chars_available
			
		# 	for m in range(1, len(mapping_items)):
		# 	#for word_char_and_index,morphID_list in mapping_items:
		# 		morphID_list = mapping_items[m][1]
		# 		###print "^", mapping_items[m], "morphID_list:", morphID_list
		# 		word_char_and_index = mapping_items[m][0]
		# 		letter = word_char_and_index[0]
		# 		index = word_char_and_index[1]
		# 		new_segmentations = []
		# 		for morphID in morphID_list:
		# 			###print ""
		# 			morph = new_morph_dict[morphID]
		# 			###print "MORPH:", morph 
		# 			# morph = re_prefixTag.sub(ur"", morph)
		# 			# morph = re_suffixTag.sub(ur"", morph)
		# 			#new_segmentations = []
		# 			prestars = "*"
		# 			for n in range(len(working_segmentations)):
		# 				#working_segmentations[n].append(morph)
		# 				###print ""
		# 				####print prestars, "Working Segmentation:", working_segmentations[n]
		# 				# chars_in_morph = list(morph)
		# 				# ####print "work_segs =", working_segmentations
		# 				for n in range(len(working_segmentations)):
		# 					if word_chars_available.has_key(n):
		# 						pass
		# 					else:
		# 						word_chars_available[n] = word_chars
		# 				###print prestars, morph, "; n:"+str(n), "; WCA_"+str(n)+":", word_chars_available[n], "; WSegs:", working_segmentations
		# 				####print prestars, "word_chars_available:", word_chars_available[n] 
		# 				#if morph_validity_test(word_chars, morph):
		# 				if morph_validity_test(word_chars_available[n], morph):
		# 					###print prestars, morph, "is a valid morph!!!"
		# 					working_segmentations[n].append(morph)
		# 					new_segmentations.append(working_segmentations[n])
		# 					###print prestars, "WCA:", word_chars_available[n]
		# 					word_chars_available[n] = list(remove_chars(word_chars_available[n], morph))
		# 					####print prestars, morphID, morph, "***", n, word_chars_available[n], "& seg =", working_segmentations[n]
		# 					###print prestars, morph, "; n:"+str(n), "; WCA_"+str(n)+":", word_chars_available[n], "; WSegs_"+str(n)+":", working_segmentations[n], "; Nsegs_"+str(n)+":", new_segmentations[n]
		# 			working_segmentations = list(new_segmentations)
		# 			prestars += "*"

		# 	self.segmentations[word] = working_segmentations
		#####print "final segmentations =", working_segmentations
		#return working_segmentations



		# For our purposes, a segmentation is a mapping from word characters (or indices) to morph IDs.
		# We need to "distangle" (potentially nonconcatenative) morphs associated with a given word and 
		# present them as though they were strictly concatenative. The Chinese chars are each going to be (for
		# our purposes) monotholithic.
		output_lines = []
		n = 0
		for word in self.words_and_morphIDs.keys():
			self.covered_words.append(word)
			#sys.stderr.write("In segment(); word: " + word + "\n")
			###print "$$$$$$$$$$$$$$&$%^^^ words_and_morphID[", word, "]:", self.words_and_morphIDs[word]
			# word_chars = list(word)
			# sys.stderr.write("word = " + word + "\n\n")
			# working_segmentations = []
			# charToMorphAlignment = self.map_morphChars_to_wordChars(word).items()
			# alignedPairs = charToMorphAlignment.items()
			# ###print "Mapping Items:",mapping_items
			# ###print "new_morph_dict:", new_morph_dict
			# ####print "0", mapping_items
			# #for key, morphID_list in mapping.items():  # equivalent to "for char in word"
			# char_index_pair,initMorphIDList = charToMorphAlignment[0] # the 1st morph-ID list (probably associated with the word's 1st letter)
			# ###print "'mapping_items[0][1]':", morphID_list
			# ###print "'words_and_morphIDs[", word, "]':", self.words_and_morphIDs[word]
			# #char_index_pair = charToMorphAlignment[0][0]
			# #char_index_pair,initMorphList = charToMorphAlignment[0]
			# letter = char_index_pair[0]
			# index = char_index_pair[1]

			# prestars = "*"

		# for m in range(len(morphID_list)):
		# 	###print prestars, morphID_list[m]
		# 	word_chars_available[m] = list(word_chars)
		# 	###print prestars, "WCA:", word_chars_available
		# 	morphID = morphID_list[m]
		# 	morph = new_morph_dict[morphID]
		# 	####print "00", morph, "m =", m
		# 	# morph = re_prefixTag.sub(ur"", morph)
		# 	# morph = re_suffixTag.sub(ur"", morph)
		# 	working_segmentations.append([morph])
	# 	word_chars = list(word)
	# 	sys.stderr.write("word = " + word + "\n\n")
	# 	#working_segmentations = []
			# charToMorphAlignment = self.map_morphChars_to_wordChars(word)
			# alignedCharMorphPairs = sorted(charToMorphAlignment.items())
		# 	###print "Sorted alignedCharMorphPairs:", alignedCharMorphPairs
			# char_index_pair,initMorphIDList = alignedCharMorphPairs[0]
			# segmentations = [[morphID] for morphID in initMorphIDList]
			# numSegmentations = len(segmentations)
		# 	avail_chars = [list(word) for n in range(numSegmentations)]
		# 	###print "avail_chars (source):", avail_chars
		# 	# for n in range(numSegmentations):
		# 	# 	morph = segmentations[n][0] 
		# 	# 	for morph_char in list(morph):
		# 	# 		avail_chars[n].remove(morph_char)
		# 	for n in range(numSegmentations):
		# 		morphID = segmentations[n][0]
		# 		#morph = new_morph_dict[morphID]
		# 		morph_letters = morph_object.get_letters()
		# 		###print "0:", morph
		# 		###print "segs[n]:", segmentations[n]
		# 		#for morph_char in list(morph): 
		# 		for morph_char in morph_letters:
		# 			try: 
		# 				avail_chars[n].remove(morph_char)
		# 			#except ValueError: continue
		# 				###print "avail_chars-- (n:" + str(n) + ") :",avail_chars
		# 			except ValueError: continue		
		# 	###print "\n"
			# We now expand each segmentation in parallel.
			#numSegmentations = len(segmentations)
			#charToMorphAlignment = self.map_morphChars_to_wordChars(word)
			##print "charToMorphAlignment:", charToMorphAlignment
			#self.charToMorphAlignments[word] = charToMorphAlignment
 			self.charToMorphAlignments[word] = self.map_morphChars_to_wordChars(word)
			if len(self.charToMorphAlignments[word]) == 0:
				if word not in self.exception_words.append(word):
					continue
			#self.morphIDs = self.get_compressed_path()
			#print "\n\n\n word:", word, n, "\n\n\n"
			n += 1
			compression = Compression(self.morph_dict, self.charToMorphAlignments[word], word)
			self.compressed_morph_seqs[word] = compression.get_compressed_path()
			
			
			#self.words_to_morphIDs_to_charIndices_dict[word] = compression.get_morphIDs_to_charIndices_map()
			self.morphToCharAlignments_allWords[word] = compression.get_morphIDs_to_charIndices_map()
			# self.index_bundles[word] = compression.compute_index_bundles()

			# my_pathfinder = pathfinder.Pathfinder(charToMorphAlignment, self.morph_dict, word)
			# my_pathfinder.compute_paths()
			# self.seg_dict_morphIDs[word] = my_pathfinder.get_paths()
			# if self.seg_dict_morphIDs[word] == [[]]:
			# 	print "NOTHING HONEY!"
			# print "PATHS FROM PATHFINDER [", word,"]:", my_pathfinder.get_paths()
			# print "STG2: PATHS FROM PATHFINDER:", self.seg_dict_morphIDs[word]
			# output_lines.append(word + "\t" + my_pathfinder.get_morph_strings() + "\n")
		
		# fobj_strings = codecs.open(self.aux_outputfile, 'w', encoding='utf8')
		# for line in output_lines:
		# 	fobj_strings.write(line)
		# fobj_strings.close()	
			#fobj_strings.write(output_line)
			#sys.stderr.write(output_line)
			#fobj_strings.close()
			#sys.stderr.write("I'm here!\n")
			##print "SEG_DICT" + "[" + word + "]:", self.seg_dict_morphIDs[word]
			# alignedCharMorphPairs = sorted(charToMorphAlignment.items())
			# ###print "ACMPs:",
			# # for pair in alignedCharMorphPairs.items():
			# # 	###print pair[0], pair[1], ";"
			# # ###print ""
			# sys.stderr.write("***" + str(alignedCharMorphPairs) + "\n")
			# ###print "+++===", alignedCharMorphPairs[0], len(alignedCharMorphPairs[0])
			# schar_index_pair,initMorphIDList = alignedCharMorphPairs[0]
			# ###print initMorphIDList
			# segmentations = [[morph_ID] for morph_ID in initMorphIDList]
			# numSegmentations = len(segmentations)
			# avail_chars = [list(word) for n in range(numSegmentations)]
			# #alignedCharMorphPairs.sort()
			# ###print "length ACMPs:", len(alignedCharMorphPairs)
			# for m in range(1,len(alignedCharMorphPairs)):
			# 	#alignedCharMorphPairs.sort()
			# 	#char_index_pair,morphIDList = alignedCharMorphPairs[m]
			# 	char_index_pair,morph_ID_list = alignedCharMorphPairs[m]
			# 	###print "********** aligned[1:]:", alignedCharMorphPairs[1:]
			# 	#morphIDList = alignedCharMorphPairs[m][1]
			# 	###print "char_index_pair:", char_index_pair
			# 	###print "morph_ID LIST:", alignedCharMorphPairs[m][1]
			# 	morph_ID_list = alignedCharMorphPairs[m][1]
			# 	for n in range(numSegmentations):
			# 		#for morphID in morphIDList:
			# 			#morph = new_morph_dict[morphID]
			# 		for morph_ID in morph_ID_list:
			# 			#morph_object = wt_morph_pair[1]
			# 			###print "MORPH_DICT[ID]:", self.morph_dict[morph_ID]
			# 			morph_object = self.morph_dict[morph_ID][1]
			# 			####print "morph_object features:", morph_object.get_fwp_list()
			# 			###print "morph_object pattern:", morph_object.get_pattern()
			# 			###print "self.morph_dict[morph_ID]:", self.morph_dict[morph_ID]
			# 			###print "self.morph_dict[morph_ID][1]:", self.morph_dict[morph_ID][1]
			# 			morph_object = self.morph_dict[morph_ID][1]
			# 			#morph_object = self.morph_dict[morph_ID]
			# 			###print "LETTERS:", morph_object.get_letters(),
			# 			pat = morph_object.get_pattern()
			# 			###print "; PATTERN:", pat
			# 			re_morph = re.compile(pat, re.UNICODE)
			# 			match_obj = re_morph.search(word)
			# 			###print "avail_chars+ (n:" + str(n) + "):",avail_chars
			# 			if morph_is_good(match_obj, avail_chars[n]):
			# 				###print "segmentations[n]:",segmentations[n]
			# 				segmentations[n].append(morph_ID)
			# 				###print "segmentations*[n]:",segmentations[n]
			# 				###print "all segmentations:", segmentations, "; all avail_chars:", avail_chars
			# 				###print "avail_chars[n]:", avail_chars[n]
			# 				avail_chars[n] = make_chars_unavailable(match_obj, avail_chars[n])
			# 				###print "avail_chars*[n]:", avail_chars[n]
			# 			else:
			# 				###print "MORPH IS BAD!"
			# 				continue

						# ###print "avail_chars+ (n:" + str(n) + "):",avail_chars
						# if morph_is_good(morph, avail_chars[n]):
						# 	###print "segmentations[n]:",segmentations[n]
						# 	segmentations[n].append(morphID)
						# 	###print "segmentations*[n]:",segmentations[n]
						# 	###print "avail_chars[n]:", avail_chars[n]
						# 	avail_chars[n] = make_chars_unavailable(morph, avail_chars[n])
						# 	###print "avail_chars[n]:", avail_chars[n]
						# else: continue
						# for morph_char in list(morph):
						# 	if morph_char not in avail_chars[n]: 
						# 		continue
						# 	else:
						# 		###print "potential morph:", morph
						# 		for morph_char in list(morph):
						# 			###print "morph_char- :", morph_char
						# 			try:
						# 				avail_chars[n].remove(morph_char)
						# 				###print "avail_chars-- :",avail_chars
						# 			except ValueError:
						# 				###print "SKIP!"
						# 				continue
						# 		segmentations[n].append(morphID)
									# else:
									# 	###print "avail_chars- :",avail_chars
			# segs_with_morphs = [[] for n in range(len(segmentations))]
			# for n in range(len(segmentations)):
			# 	#segs_with_morphs.append([])
			# 	for morphID in segmentations[n]:
			# 		#segs_with_morphs[n].append(new_morph_dict[morphID])
			# 		segs_with_morphs.append(morphID)
			# 		####print "&&", new_morph_dict[morphID]
			# 		###print "&&&", "segs_with_morphs[n]:", segs_with_morphs[n]
			# self.seg_dict[word] = segs_with_morphs
			# self.seg_dict_morphIDs[word] = segmentations
			#segs_with_morphs = {}
			# for seg in segmentations:
			# 	###print seg
		#return segmentations
		#return self.seg_dict
	# def compute(self):
	# 	self.segment()

	# def get_segmentations(self):
	# 	#self.segment()
	# 	#return self.seg_dict
	# 	return self.seg_dict_morphIDs
		
	def get_alignments(self):
		#self.segment()
		return self.charToMorphAlignments

	def print_compressed_paths(self):
		fobj = codecs.open("compressed_paths.txt", 'w', encoding='utf8')
		for word,path in self.compressed_morph_seqs.items():
			path_str = ""
			for morphID in path:
				path_str += str(morphID) + " "
			path_str = path_str.rstrip()
			outstring = word + "\t" + path_str + "\n"
			fobj.write(outstring + "\n")
		fobj.close()

	# def print_index_bundles(self):
	# 	fobj = codecs.open("index_bundles.txt", 'w', encoding='utf8')
	# 	for word,index_bundles in self.index_bundles.items():
	# 		str_index_bundles = []
	# 		for index_bundle in index_bundles:
	# 			bundle_of_strings = [str(x) for x in index_set]
	# 			str_index_bundle = ",".join(index_str_set)
	# 			str_index_bundles.append(str_index_bundle)
	# 		outstring = word "\t" + " ".join(str_index_bundles)
	# 		fobj.write(outstring + "\n")
	# 	fobj.close()
	def get_compressed_morph_seqs(self):
		return self.compressed_morph_seqs

	def print_morphID_toCharIdx_maps(self, filename):
		fobj = codecs.open(filename, 'w', encoding='utf8')
		for word, M2C_dict in self.morphToCharAlignments_allWords.items():
			items = []
			for morphID, index_list in M2C_dict.items():
				str_indices = [str(idx) for idx in index_list]
				idx_str = ",".join(str_indices)
				M2C_str = str(morphID) + ":" + idx_str
				items.append(M2C_str)
			fobj.write(word + "\t" + " ".join(items) + "\n")
			#self.words.append(word)
		fobj.close()

	def print_covered_words(self, filename):
		fobj = codecs.open(filename, 'w', encoding='utf8')
		for word in self.covered_words:
			fobj.write(word + "\n")
		fobj.close()

	def get_covered_words(self):
		return self.covered_words
	# def print_morph_char_maps(self):
	# 	fobj = codecs.open("index_maps.txt", 'w', encoding='utf8')
	# 	for word, morph_to_indices_dict in self.index_bundles.items():
	# 		morphs_and_indices = []
	# 		for morphID, index_list in morph_to_indices_dict.items():
	# 			indices_str = ",".join([str(x) for x in index_list])
	# 			morphs_and_indices.append(str(morphID) + ":" + indices_str)
	# 			" ".join(morph_and_indices)
	# 		str_index_bundles = []
	# 		for index_bundle in index_bundles:
	# 			bundle_of_strings = [str(x) for x in index_set]
	# 			str_index_bundle = ",".join(index_str_set)
	# 			str_index_bundles.append(str_index_bundle)
	# 		outstring = word + "\t" + " ".join(str_index_bundles)
	# 		fobj.write(outstring + "\n")
	# 	fobj.close()

def main(output_of_stage1, clustersAndWords_file):
	"""returns a dictionary comprising words as keys and segmentations 
	(one per word) as values. Basically, this--the "main"--function returns segmentations."""
	#clusterIDs_and_words = get_clusterIDs_and_words(cluster_file)
	#words_and_morphs = get_words_and_morphs(output_of_stage1, clusterIDs_and_words)
	#return words_and_morphs
	###print "IN_MAIN!"
	clustersAndWords_dict = process_clustering_file(clustersAndWords_file)
	morph_IDs = output_of_stage1.keys() ####print clustersAndWords_dict
	#print "TYPE OF FIRST MORPH_ID:", type(morph_IDs[0])
	my_stage2 = Stage2(output_of_stage1, clustersAndWords_dict, clustersAndWords_file)
	my_stage2.segment()
	#word_segmentations = dict()
	#word_segmentations = my_stage2.get_segmentations()
	#charToMorphAlignments = my_stage2.get_alignments()
	basename = clustersAndWords_file.split(".")[0]
	#my_stage_2.print_morphID_toCharIdx_maps(basename + "." + )
	#return 
	my_stage2.print_compressed_paths()
	#compressed_paths = my_stage_2.get_compressed_morph_seqs()
	####print "FINAL SEGMENTATIONS:"
	####print word_segmentations
	# for word,segmentation_list in word_segmentations.items():
	# 	###print word, ":", segmentation_list
	#return word_segmentations
	#return charToMorphAlignments

if __name__=="__main__":
	#morph_dict_
	cvals_filename = sys.argv[1]
	morph_dict = stage1.main(cvals_filename)
	clusters_filename = sys.argv[2]
	#morphID_toCharIdx_file = sys.argv[3]
	#cluster_dict = process_clustering_file(cluster_file)
	#output_of_stage1 = morphs_ex
	#main(output_of_stage1, cluster_file)
	main(morph_dict, clusters_filename)
	# ###print "******************"
	# ###print d

