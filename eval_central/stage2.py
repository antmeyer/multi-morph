import sys, codecs, unicodedata, regex as re

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
morphs_ex = {u"0":u"aa&k", u"1":u"klb", u"2":u"lb", u"3":u"zz&i"}
words_and_morphIDs_ex = {u"klbi":[u"0",u"1",u"2",u"3"]}

cluster_dict = {u"0":[u"klbi"],
				u"1":[u"klbi"],
				u"2":[u"klbi"],
				u"3":[u"klbi"]}

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

def morph_is_good(morph,avail_chars):
	for morph_char in list(morph):
		if morph_char not in avail_chars: 
			return False
	return True

def make_chars_unavailable(morph, avail_chars):
	char_list = list(morph)
	for letter in char_list:
		avail_chars.remove(letter)
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
	cfobj = codecs.open(cluster_file, encoding='utf-8')
	pat = ur"\([0-9]\.[0-9]{4}\)"  # This is the pattern for activity values.
	re_activity = re.compile(pat, re.UNICODE)
	pat = ur"\#{2}\s"
	re_ID_marker = re.compile(pat2, re.UNICODE)
	pat = ur"\%{2}"
	re_end_arker= re.compile(pat, re.UNICODE)
	WORDS = False
	clusters = dict()
	for line in cfobj.readlines():
		string = line.replace("\n", "")
		if re_ID_marker.match(string): #if line[0] == u"#":
			WORDS = True
			clusterID = unicode(int(re_delimeter1.sub(u"", string)))
			#print clusterID, string
			continue
		if re_end_marker.match(string):
			WORDS = False
			#print string
		if WORDS == True:		
			#WORDS = False
			# Split first by the comma delimiter, then 
			# Replace paranthses-enclosed values with empty string
			#string = line.replace("\n", "")
			string = re_activity.sub(u"", string) # Removes activity. But what about the parentheses?
			words = string.split(u",")
			# if self.clusters.has_key(clusterID):
			# 	self.clusters[clusterID].append(words)
			# else: self.clusters[clusterID] = words
			clusters[clusterID] = words
	return clusters

class Stage2:

	#def __init__(self, output_from_stage1, cluster_file):
	def __init__(self, output_from_stage1, cluster_dict):
		# output_from_stage1 is a dict: Keys are clusterIDs. Values are morphs.
		# In this dict, each clusterID should correspond to one and only one morph.
		# We will set the attribute 'self.morphs' equal to output_from_stage1.
		self.morphs = output_from_stage1
		#self.clusters = {}
		self.clusters = cluster_dict
		self.segDice = {}
		# 'self.clusters' will be a dict; keys = cluster_IDs,
		# and values = lists of words. It will thus say, for each cluster, which
		# words are members of that cluster.
		# 'self.words_and_morphIDs' will be a dict whose keys are words. The value of 
		# each key will be a list of morph_IDs (= cluster_IDs)
		# In others words, self.words_and_morphIDs will be the same as a dict named
		## self.words_and_clusterIDs, or even self.words_and_clusters.
		self.words_and_morphIDs = {}
		self.segmentations = {}
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
		# 		#print clusterID, string
		# 		continue
		# 	if re_delimeter2.match(string):
		# 		WORDS = False
		# 		#print string
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
		for clusterID, word_list in self.clusters.items():
			for word in word_list:
				# clusterID = morphID
				if self.words_and_morphIDs.has_key(word):
					self.words_and_morphIDs[word].append(clusterID)
				else:
					self.words_and_morphIDs[word] = [clusterID]


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
		# What is 'morph_dict'? Should it in fact be a dict? Or will a list suffice,
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
		
		mapping = {}
		morphs_by_type = [[], [], []]
		morph_tuples = []
		# Get the current word's morphs from the dictionary obtained from stage 1.
		morphIDs = self.words_and_morphIDs[word]
		for morphID in morphIDs:
			morph_tuples.append((morphID, self.morphs[morphID]))
		print "morph_tuples:", morph_tuples
		# The 'morph_types' are prefix, stem, and suffix.
		## They are the three subgroups in 'morphs_by_type'.
		## They have a certain order: 'n' below is the variable
		## that corresponds to this ordering.
		for morphID, morph in morph_tuples:
			if re_prefixTag.search(morph):
				morphs_by_type[0].append((re_prefixTag.sub(ur"", morph), morphID))
			elif re_suffixTag .search(morph):
				morphs_by_type[2].append((re_suffixTag.sub(ur"", morph), morphID))
			else: # the morph is of the stem type.
				morphs_by_type[1].append((morph, morphID))
		print "morphs_by_type:", morphs_by_type
		# klbi = (1) "my dog", (2) "as my heart"
		# In (1), the 'k' is a prefix, and will be marked as such in the morphs dict,
		# whereas in (2), the 'k' is part of the stem (in particular, the root).
		# The ambiguity consists mainly in this: a letter near the beginning
		# of the may be a prefix or a stem letter.
		for n in range(len(morphs_by_type)):
			for morph, morphID in morphs_by_type[n]:
				for i in range(len(morph)): # Iterate over the letters of the morph
					for j in range(len(word)): # For each morph letter, visit all word letters.
						if morph[i] == word[j]:
							# This is a pair containing a letter and its index in the word.
							# wordChar_wordIndex_pair = (word[j],j)
							wordChar_wordIndex_pair = (j, word[j])
							# For a given word, 'mapping' dict maps each such pair to a list of morphs (morph IDs).
							# The reason the values are lists instead of single morph IDs is that there could 
							# be ambiguity.
							# But would the ambiguity be real or the result of erroneous processing?
							# The mapping dict is constructed on a word-by-word basis in the function 'segment'.
							if mapping.has_key(wordChar_wordIndex_pair):
								mapping[wordChar_wordIndex_pair].append(morphID)
							else:
								mapping[wordChar_wordIndex_pair] = [morphID]
		print "MAPPING:"
		for pair,lst in mapping.items():
			print pair, ": ", ", ".join(lst) 
		
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
		new_morph_dict = {}
		for morphID,morph in self.morphs.items():
			new_morph = re_prefixTag.sub(ur"", morph)
			new_morph = re_suffixTag.sub(ur"", new_morph)
			new_morph_dict[morphID] = new_morph
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
		# 			morph = self.morphs[morphID]
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
		# 	print "Mapping Items:",mapping_items
		# 	print "new_morph_dict:", new_morph_dict
		# 	#print "0", mapping_items
		# 	#for key, morphID_list in mapping.items():  # equivalent to "for char in word"
		# 	morphID_list = mapping_items[0][1] # the 1st morph-ID list (probably associated with the word's 1st letter)
		# 	print "'mapping_items[0][1]':", morphID_list
		# 	print "'words_and_morphIDs[", word, "]':", self.words_and_morphIDs[word]
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
		# 	# print "WCA:", word_chars_available
		# 	# morph_list = []
		# 	# for morphID,morph in new_morph_dict:
		# 	# 	new_morph = re_prefixTag.sub(ur"", morph)
		# 	# 	new_morph = re_suffixTag.sub(ur"", new_morph)
		# 	# 	morph_list.append(new_morph)
		# 	#working_segmentations = [[] for morph_ID in morphID_list]
		# 	#word_chars_available = [list(word_chars) for morph_ID in morphID_list] 
		# 	prestars = "*"

		# 	for m in range(len(morphID_list)):
		# 		print prestars, morphID_list[m]
		# 		word_chars_available[m] = list(word_chars)
		# 		print prestars, "WCA:", word_chars_available
		# 		morphID = morphID_list[m]
		# 		morph = new_morph_dict[morphID]
		# 		#print "00", morph, "m =", m
		# 		# morph = re_prefixTag.sub(ur"", morph)
		# 		# morph = re_suffixTag.sub(ur"", morph)
		# 		working_segmentations.append([morph])
				
		# 		#working_segmentations.append([])

		# 		# Each item in working segmentations is a distinct segmentation hypothesis. Each segmentation
		# 		# hypothesis can grow as the analysis proceeds.
		# 		word_chars_available[m] = list(remove_chars(word_chars_available[m], morph))
		# 		print prestars, "WORKING SEGS:", working_segmentations
		# 		prestars += "*"
		# 		#print "00", morph, "***", m, word_chars_available[m], "& seg =", working_segmentations[m]
		# 		#print "000", morphID, morph, "***", m, word_chars_available[m], "& seg =", working_segmentations[m]
		# 	#print ""
		# 		#print "WCA:", word_chars_available
			
		# 	for m in range(1, len(mapping_items)):
		# 	#for word_char_and_index,morphID_list in mapping_items:
		# 		morphID_list = mapping_items[m][1]
		# 		print "^", mapping_items[m], "morphID_list:", morphID_list
		# 		word_char_and_index = mapping_items[m][0]
		# 		letter = word_char_and_index[0]
		# 		index = word_char_and_index[1]
		# 		new_segmentations = []
		# 		for morphID in morphID_list:
		# 			print ""
		# 			morph = new_morph_dict[morphID]
		# 			print "MORPH:", morph 
		# 			# morph = re_prefixTag.sub(ur"", morph)
		# 			# morph = re_suffixTag.sub(ur"", morph)
		# 			#new_segmentations = []
		# 			prestars = "*"
		# 			for n in range(len(working_segmentations)):
		# 				#working_segmentations[n].append(morph)
		# 				print ""
		# 				#print prestars, "Working Segmentation:", working_segmentations[n]
		# 				# chars_in_morph = list(morph)
		# 				# #print "work_segs =", working_segmentations
		# 				for n in range(len(working_segmentations)):
		# 					if word_chars_available.has_key(n):
		# 						pass
		# 					else:
		# 						word_chars_available[n] = word_chars
		# 				print prestars, morph, "; n:"+str(n), "; WCA_"+str(n)+":", word_chars_available[n], "; WSegs:", working_segmentations
		# 				#print prestars, "word_chars_available:", word_chars_available[n] 
		# 				#if morph_validity_test(word_chars, morph):
		# 				if morph_validity_test(word_chars_available[n], morph):
		# 					print prestars, morph, "is a valid morph!!!"
		# 					working_segmentations[n].append(morph)
		# 					new_segmentations.append(working_segmentations[n])
		# 					print prestars, "WCA:", word_chars_available[n]
		# 					word_chars_available[n] = list(remove_chars(word_chars_available[n], morph))
		# 					#print prestars, morphID, morph, "***", n, word_chars_available[n], "& seg =", working_segmentations[n]
		# 					print prestars, morph, "; n:"+str(n), "; WCA_"+str(n)+":", word_chars_available[n], "; WSegs_"+str(n)+":", working_segmentations[n], "; Nsegs_"+str(n)+":", new_segmentations[n]
		# 			working_segmentations = list(new_segmentations)
		# 			prestars += "*"

		# 	self.segmentations[word] = working_segmentations
		##print "final segmentations =", working_segmentations
		#return working_segmentations
		self.segDict = {}
		for word in self.words_and_morphIDs.keys():
			# word_chars = list(word)
			# sys.stderr.write("word = " + word + "\n\n")
			# working_segmentations = []
			# charToMorphAlignment = self.map_morphChars_to_wordChars(word).items()
			# alignedPairs = charToMorphAlignment.items()
			# print "Mapping Items:",mapping_items
			# print "new_morph_dict:", new_morph_dict
			# #print "0", mapping_items
			# #for key, morphID_list in mapping.items():  # equivalent to "for char in word"
			# char_index_pair,initMorphIDList = charToMorphAlignment[0] # the 1st morph-ID list (probably associated with the word's 1st letter)
			# print "'mapping_items[0][1]':", morphID_list
			# print "'words_and_morphIDs[", word, "]':", self.words_and_morphIDs[word]
			# #char_index_pair = charToMorphAlignment[0][0]
			# #char_index_pair,initMorphList = charToMorphAlignment[0]
			# letter = char_index_pair[0]
			# index = char_index_pair[1]

			# prestars = "*"

			# for m in range(len(morphID_list)):
			# 	print prestars, morphID_list[m]
			# 	word_chars_available[m] = list(word_chars)
			# 	print prestars, "WCA:", word_chars_available
			# 	morphID = morphID_list[m]
			# 	morph = new_morph_dict[morphID]
			# 	#print "00", morph, "m =", m
			# 	# morph = re_prefixTag.sub(ur"", morph)
			# 	# morph = re_suffixTag.sub(ur"", morph)
			# 	working_segmentations.append([morph])
			word_chars = list(word)
			sys.stderr.write("word = " + word + "\n\n")
			#working_segmentations = []
			charToMorphAlignment = self.map_morphChars_to_wordChars(word)
			alignedCharMorphPairs = sorted(charToMorphAlignment.items())
			print "Sorted alignedCharMorphPairs:", alignedCharMorphPairs
			char_index_pair,initMorphIDList = alignedCharMorphPairs[0]
			segmentations = [[morphID] for morphID in initMorphIDList]
			numSegmentations = len(segmentations)
			avail_chars = [list(word) for n in range(numSegmentations)]
			print "avail_chars (source):", avail_chars
			# for n in range(numSegmentations):
			# 	morph = segmentations[n][0] 
			# 	for morph_char in list(morph):
			# 		avail_chars[n].remove(morph_char)
			for n in range(numSegmentations):
				morphID = segmentations[n][0]
				morph = new_morph_dict[morphID]
				print "0:", morph
				print "segs[n]:", segmentations[n]
				for morph_char in list(morph): 
					try: 
						avail_chars[n].remove(morph_char)
					#except ValueError: continue
						print "avail_chars-- (n:" + str(n) + ") :",avail_chars
					except ValueError: continue		
			print "\n"
			# We now expand each segmentation in parallel.		
			for m in range(1,len(alignedCharMorphPairs)):
				alignedCharMorphPairs.sort()
				char_index_pair,morphIDList = alignedCharMorphPairs[m]
				print "********** aligned[1:]:", alignedCharMorphPairs[1:]
				morphIDList = alignedCharMorphPairs[m][1]
				for n in range(numSegmentations):
					for morphID in morphIDList:
						morph = new_morph_dict[morphID]
						print "avail_chars+ (n:" + str(n) + "):",avail_chars
						if morph_is_good(morph, avail_chars[n]):
							print "segmentations[n]:",segmentations[n]
							segmentations[n].append(morphID)
							print "segmentations*[n]:",segmentations[n]
							print "avail_chars[n]:", avail_chars[n]
							avail_chars[n] = make_chars_unavailable(morph, avail_chars[n])
							print "avail_chars[n]:", avail_chars[n]
						else: continue

						# for morph_char in list(morph):
						# 	if morph_char not in avail_chars[n]: 
						# 		continue
						# 	else:
						# 		print "potential morph:", morph
						# 		for morph_char in list(morph):
						# 			print "morph_char- :", morph_char
						# 			try:
						# 				avail_chars[n].remove(morph_char)
						# 				print "avail_chars-- :",avail_chars
						# 			except ValueError:
						# 				print "SKIP!"
						# 				continue
						# 		segmentations[n].append(morphID)
									# else:
									# 	print "avail_chars- :",avail_chars
			segs_with_morphs = [[] for n in range(len(segmentations))]
			for n in range(len(segmentations)):
				#segs_with_morphs.append([])
				for morphID in segmentations[n]:
					segs_with_morphs[n].append(new_morph_dict[morphID])
					print "&&", new_morph_dict[morphID]
					print "&&&", "segs_with_morphs[n]:", segs_with_morphs[n]
			self.segDict[word] = segs_with_morphs
			#segs_with_morphs = {}
			# for seg in segmentations:
			# 	print seg
		#return segmentations


	def get_segmentations(self):
		self.segment()
		return self.segDict


def main(output_of_stage1, cluster_file):
	"""returns a dictionary comprising words as keys and segmentations 
	(one per word) as values. Basically, this function returns segmentation."""
	#clusterIDs_and_words = get_clusterIDs_and_words(cluster_file)
	#words_and_morphs = get_words_and_morphs(output_of_stage1, clusterIDs_and_words)
	#return words_and_morphs
	my_stage2 = Stage2(output_of_stage1, cluster_file)
	my_stage2.segment()
	word_segmentations = dict()
	word_segmentations = my_stage2.get_segmentations()
	print "FINAL SEGMENTATIONS:"
	print word_segmentations
	# for word,segmentation_list in word_segmentations.items():
	# 	print word, ":", segmentation_list
	# return word_segmentations

if __name__=="__main__":
	#cluster_file = sys.argv[1]
	#cluster_dict = process_clustering_file(cluster_file)
	output_of_stage1 = morphs_ex
	#main(output_of_stage1, cluster_file)
	main(output_of_stage1, cluster_dict)
	# print "******************"
	# print d

