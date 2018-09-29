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
morphs_ex = {u"0":u"k", u"1":u"klb", u"2":u"lb", u"3":u"i"}
words_and_morphIDs_ex = {u"klbi":[u"0",u"1",u"2",u"3"]}
mapping_ex = {
					(u"k",0):[u"0",u"1"],
					(u"l",1):[u"1",u"2"],
					(u"b",2):[u"1",u"2"],
					(u"i",3):[u"3"]
					}
UTF8Writer = codecs.getwriter('utf8')
sys.stdout = UTF8Writer(sys.stdout)

def morph_validity_test(word_chars_available, morph):
	# Make sure that each character in the morph is present in the word itself.
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
	# Once a morph character has been associated with a word_char, the word_char must
	## be removed from consideration. That is, it cannot be associated with any other morph 
	## character (neither in the present morph, nor in other morphs).
	for morph_char in valid_morph:
		try: index = word_chars_available.index(morph_char)
		except IndexError: continue
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
# 	re_pre = re.compile(pat1, re.UNICODE)
# 	pat2 = ur"^zz&"
# 	re_suf = re.compile(pat2, re.UNICODE)
# 	for morphID, morph in morph_dict.items():
# 		if re_pre.search(morph):
# 			morphs_by_type[0].append((re_pre.sub(u"", morph), morphID))
# 		elif re_suf.search(morph):
# 			morphs_by_type[2].append((re_suf.sub(u"", morph), morphID))
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

class Stage2:

	def __init__(self, output_from_stage1, cluster_file):
		# output_from_stage1 is a dict: Keys are clusterIDs. Values are morphs.
		# In this dict, each clusterID should correspond to only one morph.
		# We will set the attribute 'self.morphs' equal to output_from_stage1.
		self.morphs = output_from_stage1
		self.clusters = {}
		# 'self.clusters' will be a dict; keys = cluster_IDs,
		# and values = lists of words. It will thus say, for each cluster, which
		# words are members of that cluster.
		# 'self.words_and_morphIDs' will be a dict whose keys are words. The value of 
		# each key will be a list of morph_IDs (= cluster_IDs)
		# In others words, self.words_and_morphIDs will be the same as a dict named
		## self.words_and_clusterIDs, or even self.words_and_clusters.
		self.words_and_morphIDs = {}
		self.segmentations = {}
		cfobj = codecs.open(cluster_file, encoding='utf-8')
		pat1 = ur"\([0-9]\.[0-9]{4}\)"
		re1 = re.compile(pat1, re.UNICODE)
		pat2 = ur"\#{2}\s"
		re2 = re.compile(pat2, re.UNICODE)
		pat3 = ur"\%{2}"
		re3 = re.compile(pat3, re.UNICODE)
		# Define 'WORDS' flag to keep track of whether or not the next line contains words to extract.
		WORDS = False
		self.clusters = dict()
		for line in cfobj.readlines():
			string = line.replace("\n", "")
			if re2.match(string):
			#if line[0] == u"#":
				WORDS = True
				#string = line.replace("\n", "")
				clusterID = unicode(str(int(re2.sub(u"", string))))
				print clusterID, string
				continue
			if re3.match(string):
				WORDS = False
				print string
			if WORDS == True:
				#WORDS = False
				# Split first by the comma delimiter, then 
				# Replace paranthses-enclosed values with empty string
				#string = line.replace("\n", "")
				string = re1.sub(u"", string)
				words = string.split(u",")
				if self.clusters.has_key(clusterID):
					self.clusters[clusterID].append(words)
				else: self.clusters[clusterID] = words
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
		## there is no indication of which morph goes with which reading. This will be
		## sorted out later.
		mapping = {}
		morphs_by_type = [[], [], []]
		pat1 = ur"^aa&"
		morph_tuples = []
		# get the current word's morphs
		morphIDs = self.words_and_morphIDs[word]
		for morphID in morphIDs:
			morph_tuples.append((morphID, self.morphs[morphID]))
		re_pre = re.compile(pat1, re.UNICODE)
		pat2 = ur"^zz&"
		re_suf = re.compile(pat2, re.UNICODE)
		# the 'morph_types' are prefix, stem, and suffix.
		## They are the three subgroups in 'morphs_by_type'.
		## They have a certain order: 'n' below is the variable
		## that corresponds to this ordering.
		for morphID, morph in morph_tuples:
			if re_pre.search(morph):
				morphs_by_type[0].append((re_pre.sub(u"", morph), morphID))
			elif re_suf.search(morph):
				morphs_by_type[2].append((re_suf.sub(u"", morph), morphID))
			else:
				morphs_by_type[1].append((morph, morphID))
		# klbi = (1) "my dog", (2) "as my heart"
		# In (1), the 'k' is a prefix, and will be marked as such in the morphs dict,
		# whereas in (2), the 'k' is part of the stem (in particular, the root).
		# The ambiguity will consist mainly of this: a letter near the beginning
		# of the may be a prefix or a stem letter.
		for n in range(len(morphs_by_type)):
			for morph, morphID in morphs_by_type[n]:
				for i in range(len(morph)):
					for j in range(len(word)):
						if morph[i] == word[j]:
							word_char_tuple = (word[j],j)
							if mapping.has_key(word_char_tuple):
								mapping[word_char_tuple].append(morphID)
							else:
								mapping[word_char_tuple] = [morphID]
		return mapping

	
	def segment(self):
		"""
		[I think 'words and morphs' should contain lists of morph-IDs rather than actual morphs 
		in string form. But then we would also need a list of morphs to access indices for IDs.
		But then the morph-IDs would simply be the cluster-IDs--except that some clusters will not
		correspond to morphs. I guess we just skip these.]
		Takes as input 'words_and_morphs', which is a dictionary whose keys are words,
		and the values of the keys are lists of morphs. Each word is thus associated with 
		a (single?) list of morphs. Each list is sorted so that any/all prefixes precede 
		any/all stem components, which precede any/all suffixes.
		1. Pop morph.
		2. match each character in the morph to a character in the word.
		3. Somehow designate each paired-off character in the word as now unavailable.
		   Maybe pop the character from the word and put in the dictionary.
		4. Repeat Steps 1-3 for the next morph.
		* Create a temporary dictionary in which each letter in a given word is mapped 
		to a morph-ID until either the word runs out of letters or the morph(s) 
		(and their letters) are exhausted. Keys: Morph-IDs. Values: Lists of characters
		"""
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
		word_chars_available = {}
		for word in self.words_and_morphIDs.keys():
			#word_chars_available = list(word)
			word_chars = list(word)
			sys.stderr.write("word = " + word + "\n\n")
			#mapping = map_morphChars_to_wordChars(word):
			working_segmentations = []
			mapping = self.map_morphChars_to_wordChars(word)
			mapping_items = mapping.items()
			print "0", mapping_items
			#for key, morphID_list in mapping.items():  # equivalent to "for char in word"
			morphID_list = mapping_items[0][1]
			key = mapping_items[0][0]
			letter = key[0]
			index = key[1]
			for m in range(len(morphID_list)):
				word_chars_available[m] = list(word_chars)
				morphID = morphID_list[m]
				morph = self.morphs[morphID]
				print "00", morph, "m =", m
				working_segmentations.append([morph])
				word_chars_available[m] = list(remove_chars(word_chars_available[m], morph))
				print "00", morph, "***", m, word_chars_available[m], "& seg =", working_segmentations[m]
				print "000", morphID, morph, "***", m, word_chars_available[m], "& seg =", working_segmentations[m]
			print ""
			
			for m in range(1, len(mapping_items)):
				morphID_list = mapping_items[m][1]
				key = mapping_items[m][0]
				letter = key[0]
				index = key[1]
				new_segmentations = []
				for morphID in morphID_list:
					morph = self.morphs[morphID]
					for n in range(len(working_segmentations)):
						# chars_in_morph = list(morph)
						# print "work_segs =", working_segmentations
						#for n in range(len(working_segmentations)):
						if word_chars_available.has_key(n):
							pass
						else:
							word_chars_available[n] = word_chars
						print "***", morphID, morph, "***", n, word_chars_available[n]
						if morph_validity_test(word_chars_available[n], morph):
							print "  *****", morph, "is a valid morph!!!"
							new_segmentations.append(working_segmentations[n].append(morph))
							word_chars_available[n] = list(remove_chars(word_chars_available[n], morph))
							#print "  *****", morphID, morph, "***", n, word_chars_available[n], "& seg =", working_segmentations[n]
							print "  *****", morphID, morph, "***", n, word_chars_available[n], "& seg =", new_segmentations
				working_segmentations = list(new_segmentations)
			self.segmentations[word] = working_segmentations
		#print "final segmentations =", working_segmentations
		#return working_segmentations

	def get_segmentations(self):
		self.segment()
		return self.segmentations


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
	for word,segmentation_list in word_segmentations.items():
		print word, ":", segmentation_list
	return word_segmentations

if __name__=="__main__":
	cluster_file = sys.argv[1]
	output_of_stage1 = morphs_ex
	main(output_of_stage1, cluster_file)

