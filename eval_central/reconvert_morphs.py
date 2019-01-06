#!/usr/bin/env python
import sys,codecs
from best_path import *
from format_for_latex import *
reload(sys)  
sys.setdefaultencoding('utf8')
UTF8Writer = codecs.getwriter('utf8')
sys.stdout = UTF8Writer(sys.stdout)
sys.stderr = UTF8Writer(sys.stderr)

sys.stderr.write("args: " + "\n".join(sys.argv) + "\n")
sys.stderr.write("NUM ARGS: " + str(len(sys.argv)) + "\n")
ch_segs_filename = sys.argv[1]
morph_char_map_filename = sys.argv[2]
#words_filename = sys.argv[3]
gldstd_filename = sys.argv[3]
original_words_filename = sys.argv[4]
outFileName = sys.argv[5]
chinese_to_id_file = sys.argv[6]

#def process_morphID_to_charIndex_map():
def get_chinese_char(i):
	# The integer '19968' marks the starting point of the unicode Chinese character block.
	return unichr(i + 19968)

# def get_unicode_number(string):
# 	return ord(string) - 19968
# def process_index_bundles(word): 
# 	return index_bundles

# def read_words(filename):
# 	fobj = codecs.open(filename, 'r', encoding='utf8')
# 	lines = fobj.readlines()
# 	words_dict = {}
# 	if len(lines) > 0:
# 		if "#" in lines[0]:
# 			first = lines.pop(0)	
# 	#if lines[0][0] == "#": lines.pop(0)
# 	#print "read_symbol_key; lines:", lines
# 	#sys.stdout.flush()
# 	# first = lines[0][0]
# 	# while first != "#":
# 	# 	lines.pop(0)
# 	# 	first = lines[0][0]
# 	for n in range(len(lines)):
# 		#words[append(line.replace("\n", ""))
# 		words_dict[n] = lines[n].replace("\n", "")
# 	fobj.close()
# 	return words_dict

# def read_gldstd_words(filename):
# 	#all_words_dict = read_words(trn_filename)
# 	#word_to_idx_dict = {}
# 	fobj = codecs.open(filename, 'r', encoding='utf8')
# 	lines = fobj.readlines()
# 	gldstd_words_dict = {}
# 	if len(lines) > 0:
# 		if "#" in lines[0]:
# 			first = lines.pop(0)	
# 	for n in range(len(lines)):
# 		gldstd_analysis = lines[n].replace("\n", "")
# 		items = gldstd_analysis.split()
# 		word = items.pop(0)
# 		gldstd_words_dict[n] = word
# 	fobj.close()
# 	return gldstd_words_dict

def original_test_words(filename):
	#all_words_dict = read_words(trn_filename)
	#word_to_idx_dict = {}
	#print "^&*$    555     $%     $#%   ", "original_test_words"
	fobj = codecs.open(filename, 'r', encoding='utf8')
	lines = fobj.readlines()
	#print "LINES 555:", "num LINES:", len(lines)
	original_words = {}
	if len(lines) > 0:
		if "#" in lines[0]:
			first = lines.pop(0)	
	for n in range(len(lines)):
		string = lines[n].replace("\n", "")
		#print "555", string
		encoded_word,index,ori_word = string.split("\t")
		original_words[encoded_word] = ori_word
		# gldstd_analysis = lines[n].replace("\n", "")
		# items = gldstd_analysis.split()
		# word = items.pop(0)
		# gldstd_words_dict[n] = word
	fobj.close()
	return original_words

def encoded_ordered_originals(filename):
	#all_words_dict = read_words(trn_filename)
	#word_to_idx_dict = {}
	#print "^&*$    888     $%     $#%   ", "encoded_ordered_originals"
	fobj = codecs.open(filename, 'r', encoding='utf8')
	lines = fobj.readlines()
	#print "LINES 888:", "num LINES:", len(lines)
	original_words = {}
	if len(lines) > 0:
		if "#" in lines[0]:
			first = lines.pop(0)	
	for n in range(len(lines)):
		string = lines[n].replace("\n", "")

		#print "888", string
		encoded_word,index,ori_word = string.split("\t")
		original_words[n] = ori_word
		# gldstd_analysis = lines[n].replace("\n", "")
		# items = gldstd_analysis.split()
		# word = items.pop(0)
		# gldstd_words_dict[n] = word
	fobj.close()
	return original_words

def encoded_words_by_index(filename):
	#print "^&*$    %^#     $%     $#%   ", "encoded_words_by_index"
	fobj = codecs.open(filename, 'r', encoding='utf8')
	lines = fobj.readlines()
	#print "LINES %^#:", "num_lines:", len(lines)
	fobj.close()
	encoded_words = {}
	if len(lines) > 0:
		if "#" in lines[0]:
			first = lines.pop(0)	
	for n in range(len(lines)):
		string = lines[n].replace("\n", "")
		encoded_word,index,ori_word = string.split("\t")
		encoded_words[encoded_word] = n
	return encoded_words


def read_morph_char_map(filename):
	fobj = codecs.open(filename, 'r', encoding='utf8')
	lines = fobj.readlines()
	#print "read_morph_char_map; lines:", lines
	# first = lines[0][0]
	# while first != "#":
	# 	lines.pop(0)
	# 	first = lines[0][0]
	indices_dict = {}
	for line in lines:
		line = line.replace("\n", "")
		word,index_lists_str = line.split("\t")
		ids_and_indices = index_lists_str.split()
		indices_dict[word] = {}
		for item in ids_and_indices:
			morphID,indices_str = item.split(":")
			try: morphID = int(morphID)
			except TypeError: morphID = morphID
			except ValueError: morphID = morphID
			indices = [int(x) for x in indices_str.split(",")]
			indices_dict[word][morphID] = indices
	fobj.close()
	return indices_dict 

def read_ch_symbolKey(filename):
	fobj_symbolKey = codecs.open(filename, 'r', encoding='utf8')
	lines = fobj_symbolKey.readlines()
	#print "read_symbol_key; lines:", lines
	sys.stdout.flush()
	#first = lines[0][0]
	# while first != "#":
	# 	lines.pop(0)
	# 	first = lines[0][0]
	ch_symbolKey = {}
	for line in lines:
		line = line.replace("\n", "")
		items = line.split("\t")
		ch_symbolKey[items[0]] = items[1]
	fobj_symbolKey.close()
	return ch_symbolKey

def read_chinese_segm_file(filename):
	fobj = codecs.open(filename, 'r', encoding='utf8')
	lines = fobj.readlines()
	#print "read_chinese_segm_file;", lines
	if "#" in lines[0]:
		morfessor_header = lines.pop(0)
	# while first != "#":
	# 	lines.pop(0)
	# 	first = lines[0][0]
	segmentations= []
	for line in lines:
		string = line.replace("\n", "")
		if len(string) == 0:
			segmentations.append([])
			continue
		#string = string.replace(" ", "")
		items = string.split()[1:]
		new_string = " ".join(items)
		#print "rec 1; items =", items,
		#segmentations.append(new_string.split(" + "))
		segmentations.append(new_string)
		#print "\tsegmentations[-1] =", segmentations[-1]
		#segs.append(line.replace("\n", ""))
		#segmentations.insert(0, morfessor_header)
	return (morfessor_header,segmentations)

def morphIDs_from_ch_chars(ch_seq, ch_char_to_morphID_map):
	morphIDs = []
	for ch_char in list(ch_seq):
		# try: morphID = get_unicode_number(i)
		# except 
		#morphID = ch_char_to_morphID_map[ch_char] 
		try: morphID = ch_char_to_morphID_map[ch_char]
		except KeyError: 
			#print "KEY_ERROR: ch_char to morphID", ch_char
			morphIDs.append(ch_char)
			#pass
		else:
			try: int_ID = int(morphID)
			except TypeError: pass
			except ValueError: pass
			morphIDs.append(int_ID)
			#pass
	return morphIDs
# Key[items[0]] = items[1]
# fobj.close()

# def strictly_ordered(index_bundle_1, index_bundle_2):
# 	#indices_1 = self.morphIDs_to_charIndices(morphID_1)
# 	#indices_2 = self.morphIDs_to_charIndices(morphID_2)
# 	for i in index_bundle_1:
# 		for j in index_bundle_2:
# 			if i >= j: return False
# 	return True	

# def interweave_bundles(index_bundle_1, index_bundle_2, word):
# 	#indices_1 = self.morphIDs_to_charIndices(morphID_1)
# 	#indices_2 = self.morphIDs_to_charIndices(morphID_2)
# 	#for i,j, in zip(indices_1, indices_2):
# 	comp_morph_indices = list(indices_1)
# 	comp_morph_indices.extend(list(indices_2))
# 	comp_seg = u""
# 	for idx in comp_morph_indices:
# 		comp_seg += word[idx]
# 	#index_span = (min(comp_morph_indices), max(comp_morph_indices))
# 	#self.segments.append(comp_morph_indices)
# 	return comp_morph_indices

# def process_index_bundles(path, morphIDs_to_charIndices, word):
# 	index_bundles = []
# 	if len(path) > 0:
# 		morphID = path[0]
# 		index_bundle = list(morphIDs_to_charIndices[morphID])
# 		index_bundles.append(index_bundle)
# 	for i in range(1, len(path)):
# 		index_bundle_1 = list(index_bundles[-1])
# 		index_bundle_2 = list(morphIDs_to_charIndices(path[i]))
# 		if strictly_ordered(index_bundle_1, index_bundle_2):
# 			index_bundles.append(index_bundle_2)
# 		else:
# 			index_bundles[-1] = interweave_bundles(index_bundle_1, index_bundle_2, word)
# 	return index_bundles

# def compute_index_bundles(self):
# 	index_bundles = []
# 	if len(self.morphIDs) > 0:
# 		morphID = self.morphIDs[0]
# 		index_bundle = list(self.morphIDs_to_charIndices[morphID])
# 		index_bundles.append(index_bundle)
# 	for i in range(1, len(self.morphIDs)):
# 		index_bundle_1 = list(index_bundles[-1])
# 		index_bundle_2 = list(self.morphIDs_to_charIndices[self.morphIDs[i]])
# 		if self.strictly_ordered(index_bundle_1, index_bundle_2):
# 			index_bundles.append(index_bundle_2)
# 		else:
# 			index_bundles[-1] = self.interweave(index_bundle_1, index_bundle_2)
# 	return index_bundles

#gldstd_words = []

chinese_to_id_dict = read_ch_symbolKey(chinese_to_id_file)
morfessor_header,ch_segmentations = read_chinese_segm_file(ch_segs_filename)

word_morphID_charIdx_dict = read_morph_char_map(morph_char_map_filename)
#words_dict = read_words(words_filename)
#gldstd_words_dict = read_gldstd_words(gldstd_filename)

ordered_originals_dict = encoded_ordered_originals(original_words_filename)
original_words_dict = original_test_words(original_words_filename)
encoded_words_dict = encoded_words_by_index(original_words_filename)
#encoded_ordered_originals = encoded_words_by_index(original_words_filename)
# print "ENCODED_WORDS_DICT:"
# for key,value in encoded_words_dict.items():
# 	print "\t", key, "\t", value
# ch_segmentations is the file containing the segmented strings
# of Chinese characters. Now we need to convert these characters to
# morphIDs and then to 'bundles' of word indices.
decoded_segmentations = {}
index_bundles = []
#ch_segmentations.sort()
for n in range(len(ch_segmentations)):
	encoded_seg_str = ch_segmentations[n] #.replace(" + ", "")
	#print "\nrec 3.4; encoded_seg_str:", encoded_seg_str  #, " ~ ", ori_word
	morfessor_segments = encoded_seg_str.split(" + ")
	encoded_word = encoded_seg_str.replace(" + ", "")

	#print "rec 3.45; ndx:", encoded_words_dict[encoded_word]
	#ndx = encoded_words_dict[encoded_word]
	#ori_word = ordered_originals_dict[n]
	ori_word = original_words_dict[encoded_word] 
	#ori_word = original_words_dict[encoded_word]
	#print "rec 3.4; encoded/original:", encoded_word, " ~ ", ori_word
	#morfessor_segments = ch_segmentations[n]
	print "\nrec 3.5; ori_word =", format_string(ori_word), "; encoded_seg_str:", encoded_seg_str, "; encoded_word =", encoded_word
	print "rec 3.6; morfessor segments:", morfessor_segments
	temp_segments = []
	print "rec 4; word_morphID_charIdx_dict[", ori_word, "] =", word_morphID_charIdx_dict[ori_word]
	super_bundles = []
	for morfessor_segment in morfessor_segments:
		#paths = morphIDs_from_ch_chars(morfessor_segment, word_morphID_charIdx_dict[ori_word])
		segment_elements = morphIDs_from_ch_chars(morfessor_segment, chinese_to_id_dict)
		print "\n\trec 5; morfessor segment:", morfessor_segment, "; morphIDs_from_ch_chars =", segment_elements 
		#my_compression = Compression
		index_bundle = []
		for segment_element in segment_elements:
			#print "    *", "morphID:", item   # "*", word_morphID_charIdx_dict[ori_word][morphID], "*",
			try: 
				int_ID = int(segment_element)
				segment_element = int_ID
				#print "\trec 5.0*", "segment_element:", segment_element
			except TypeError:
				#print "\t5.1",
				indices = word_morphID_charIdx_dict[ori_word][segment_element]
				index_bundle.extend(indices)
				#print "indices:", indices,
				#print "\t5.1.1", index_bundle
			except ValueError:
				print "\t5.2",
				indices = word_morphID_charIdx_dict[ori_word][segment_element]
				index_bundle.extend(indices)
				#print "indices:", indices,
				#print "\t5.2.1", index_bundle
			else:
				#print ">>> rec 5.5; morphID =", morphID
				#try:
				#print "\t5.3",
				#morphIDs = [pair[1] for pair in word_morphID_charIdx_dict[ori_word].items()]
				#print "\tmorphIDs:", morphIDs
				indices = word_morphID_charIdx_dict[ori_word][segment_element]
				#except KeyError: indices = word_morphID_charIdx_dict[ori_word][unicode(morphID)]
				#print "indices:", indices,
			index_bundle.extend(indices)
			#print ""
			#print "\t5.3.1 index_bundle", index_bundle
		index_set = set(index_bundle)
		index_bundle = list(index_set)
		print "\tWORKING IDX BUNDLE:", index_bundle,
		super_bundles.append(sorted(index_bundle))
		#print "\n\n******************^%&*", "morphIDs:", morphIDs, "\n\n"
		#for morphID in morphIDs:
		#index_bundles[ori_word] = process_index_bundles(morphIDs, 
		#index_bundles[ori_word] = word_morphID_charIdx_dict[ori_word], ori_word)
		print "rec 6; index bundles in", format_string(ori_word), ":", super_bundles
		#for index_bundle in index_bundles[ori_word]:
	for index_bundle in super_bundles:
		print "rec 7 ... Assembling segment ... ",
		segment = u""
		for idx in index_bundle:
			try: int_ID = int(idx)
			except TypeError:
				print "TYPE_ERROR", letter, idx, "*->",
				letter = idx
				segment += letter
			except ValueError:
				print "VALUE_ERROR", letter, idx, "*->",
				letter = idx
				segment += letter
			else:
				print "-->",
				letter = ori_word[int_ID]
				segment += letter
			print segment,
		print ""
		print "\n >><<>><<  ori_word:", format_string(ori_word), " ; encoded_word:", encoded_word, "\n"
		temp_segments.append(segment)
	segments_str = " + ".join(temp_segments)
	print format_string(segments_str), "\n\n"
	decoded_segmentations[ori_word]	= segments_str

fobj = codecs.open(outFileName, 'w', encoding='utf8')
# for n in range(len(ch_segmentations)):
# 	encoded_word = "".join(ch_segmentations[n])
# 	#cur_word = original_words_dict[n]
# 	cur_word = original_words_dict[encoded_word]
# 	print "**********&&&&&&&&&$R$R$T$T$Y$YIUO)-", cur_word, decoded_segmentations[cur_word]
# 	fobj.write(decoded_segmentations[cur_word] + "\n")
# fobj.close()
#fobj.write(morfessor_header + "\n")
for ori_word,seg in decoded_segmentations.items():
	fobj.write(str(1) + " " + seg + "\n")
	#print "**********&&&&&&&&&$R$R$T$T$Y$YIUO)-", "\t", seg, "\t", ori_word
#fobj.write(decoded_segmentations[seg] + "\n")
fobj.close()
#segments.append([word[index] for index in index_bundle])
#morphID_to_charIdx_map = word_morphID_charIdx_dict[word]
	
# fobj_seg = codecs.open(segmentedFileName , 'r', encoding='utf8')
# seg_lines = fobj.readlines()
# fobj_seg.close()

# morph_dict = {}
# chinese_to_id_dict = {}

# indices_dict = read_morph_char_map("morphID_charIndex_map.txt")
# lines = fobj_readmorphs.readlines()
# indices_dict = {}
# for line in lines:
# 	line = line.replace("\n", "")
# 	word,index_lists_str = line.split("\t")
# 	ids_and_indices = index_lists_str.split()
# 	indices_dict[word] = {}
# 	for item in ids_and_indices:
# 		morphID,indices_str = item.split(":")
# 		indices = [int(x) for x in indices_str.split(",")]
# 		indices_dict[word][morphID] = indices
# fobj_readmorphs.close()	

# 	morph_dict[items[0]] = items[1]
# fobj_readmorphs.close()

# for line in seg_lines:
# 	line = line.replace("\n", "")
# 	symbols = list(line)
# 	converted_line = ""
# 	for symbol in symbols:
# 		# if symbol == "+":
# 		# 	converted_line += "+"
# 		# 	continue
# 		try: 
# 			morphID = chinese_to_id_dict[symbol]
# 		except KeyError:
# 			converted_line += symbol
# 			continue
# 		try: letter_str = morph_dict[morphID]
# 		except KeyError: continue
# 		converted_line += letter_str
# 	sys.stdout.write(converted_line + "\n")
