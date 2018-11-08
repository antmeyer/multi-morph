#!/usr/bin/env python

import sys, re, codecs

def list_of_morph_objs(self, morphIDs, morph_dict):
	morph_objs = []
	for morphID in morphIDs:
		morph_objs.append(morph_dict[morphID])
	return morph_objs

def dict_to_list(self, index_dict):
	items = []
	for index,item in sorted(index_dict.items())
		items.append(item)
	return item

def avg_wt(morphID_list):
	s = 0.0
	morph_objs = list_of_morph_objs(morphID_list)
	for morph_obj in morph_objs:
		s += morph_obj.get_weight()
	return s/float(len(morph_objs))

def get_chinese_char(i):
	# The integer '19968' marks the starting point of the unicode Chinese character block.
	return unichr(i + 19968)

#class Segmentation:
class CompressedPath:
	#def __init__(self, morphID_list, morph_dict, charIndex_to_morphID_dict, word):
	def __init__(self, morph_dict, charIndex_to_morphID_dict, word):
		self.charIndices_to_morphIDs = charIndex_to_morphID_dict
		self.morph_dict = morph_dict
		self.paths = []
		self.word = word
		steps = self.charIndices_to_morphIDs.items()
		options = steps[0]
		init_morph_objs = list_of_morph_objs(options)
		for init_morph in init_morph_objs: 
			self.paths.append(avg_wt([init_morph]), [init_morph])
		for index,morphID_list in steps[1:]: 
			morph_obj = morph_dict[morphID]
			self.paths = expand(self.paths, list_of_morph_objs(morphID_list, morph_dict))
		
		# at this point, all the paths, i.e., self.paths, will have been computed. 
		self.paths.sort(reverse=True)
		best_path_wt = self.paths[0][0]	
		self.best_raw_path = self.paths[0][1]
		
		self.index_bundles = []
		
		#self.compressed_path = []
		self.morphIDs = self.get_compressed_path()
		self.encodedMorphIDs = self.encode_morphs(self.morphIDs)
		# for morphID in self.best_raw_path:
		# 	if morphID not in self.compressed_best_path:
		# 		self.compressed_best_path.append(morphID)
		self.morphIDs_to_charIndices = self.map_morphID_to_charIndices()
		self.segments = []
		self.index_bundles = self.compute_index_bundles(self.morphIDs)

	
	def get_char_indices(self, morphID):
		return self.morphIDs_to_charIndices[morphID]
	
	def compute_segments(self): 
		"""This method returns the (merged) index bundles."""
		for bundle in self.index_bundles:
			segment = u""
			for index in bundle:
				segment += self.word[index]
			self.segments.append(segment)
		#return self.segments 
	
	def get_segments(self):
		return self.segments
	
	def get_compressed_path(self, ):
		"""Removes duplicate instances of morph IDs (i.e. morphs, basically). Any morph that consists
		of more that one character will manifest as multiple instances of the same morph ID
		in a given path."""
		compressed_sequence = []
		for morphID in self.best_raw_path:
			if morphID in compressed_sequence: pass
			else: compressed_sequence.append(morphID)
		return compressed_sequence

	def compute_index_bundles(self, compressed_path):
		index_bundles = []
		if len(compressed_path) > 0:
			morphID = compressed_path[0]
			index_bundle = list(self.morphIDs_to_charIndices[morphID])
			index_bundles.append(index_bundle)
		for i in range(1, len(compressed_path)):
			index_bundle_1 = list(index_bundles[-1])
			index_bundle_2 = list(self.morphIDs_to_charIndices(compressed_path[i]))
			if self.strictly_ordered(index_bundle_1, index_bundle_2):
				index_bundles.append(index_bundle_2)
			else:
				index_bundles[-1] = self.interweave(index_bundle_1, index_bundle_2)
		return index_bundles
		
	def strictly_ordered(self, index_bundle_1, index_bundle_2):
		#indices_1 = self.morphIDs_to_charIndices(morphID_1)
		#indices_2 = self.morphIDs_to_charIndices(morphID_2)
		for i in index_bundle_1:
			for j in index_bundle_2:
				if i >= j: return False
		return True

	def interweave(self, index_bundle_1, index_bundle_2):
		#indices_1 = self.morphIDs_to_charIndices(morphID_1)
		#indices_2 = self.morphIDs_to_charIndices(morphID_2)
		#for i,j, in zip(indices_1, indices_2):
		comp_morph_indices = list(indices_1)
		comp_morph_indices.extend(list(indices_2))
		comp_seg = u""
		for idx in comp_morph_indices:
			comp_seg += word[idx]
		#index_span = (min(comp_morph_indices), max(comp_morph_indices))
		#self.segments.append(comp_morph_indices)
		return comp_morph_indices
		#return (comp_morph_indices, comp_seg)

	# def get_chars(self, morphIDs, morphIDs_to_charIndices, word):
	# 	slots = ["" for n in range(len(word))]
	# 	morph_objs = list_of_morph_objs(morphIDs)
	# 	for morphID,morph_obj in zip(morphIDs,morph_objs):
	# 		if type('a') == type(morphID) or type(u'a') == type(morphID):
	# 			idx = word.index(morphID)
	# 			slots[idx] = morphID
	# 			continue
	# 		indices = morphIDs_to_charIndices(morphID)
	# 		morph_chars = morph_obj.get_letters()
	# 		for idx,morph_char in zip(indices,morph_chars):
	# 			slots[idx] = morph_char
	# 	return chars

	def map_morphID_to_charIndices(self):
		"""Maps the 'raw' morph-ID sequence to a list of character indices, i.e.,
		a list of indices for each morph (ID)."""
		output_dict = {}
		for index,morph_ID_list in sorted(self.char_to_morph_mapping.items()):
			for morphID in morph_ID_list:
				if output_dict.has_key(morphID):
					output_dict[morphID].append(index)
				else:
					output_dict[morphID] = [index]
		return output_dict

	def encode_morphs(self, morphIDs):
		symbols = []
		for morphID in morphIDs:
			int_ID = int(morphID)
			symbols.append(get_chinese_char(int_ID))
		#return chinese_chars
		
		encoded_word = u""
		for morphID in morphIDs:
			#sys.stderr.write(morphID + " ")
			try: 
				int_ID = int(morphID)
				print "++++++++", type(morphID), "morphID:", morphID, int_ID
				#sys.stderr.write(str(int_ID))
				#encoded_word += map_id_to_chinese[int_ID]
				symbols.append(get_chinese_char(int_ID))

				#sys.stderr.write(encoded_word + ", ")
			except KeyError:
				sys.stdout.write("KEY_ERROR: MORPH_ID: " + str(morphID) + " !!!\n")

			except TypeError:
				sys.stdout.write("TYPE_ERROR: MORPH_ID: " + str(morphID) + " !!!\n")
				if type(u"a") == type(morphID) or type("a") == type(morphID):
					#encoded_word += morphID
					symbols.append(get_chinese_char(int_ID))
		return symbols
	
	def update_wt(self, weighted_sequence, weighted_item):
		"""Weighted_item is a pair consisting of a weight (positive real number)
		and an item. A sequence is a list of items."""
		item_wt = weighted_item[0]
		item = weighted_item[1]
		seq_wt = weighted_sequence[0]
		sequence = weighted_sequence[1]
		new_avg = (seq_wt+item_wt)/2.0
		if item in sequence: return 2.0*new_avg
		else: return new_avg

	def expand(self, paths, new_morphIDs):
		new_paths = []
		for wtd_path in paths:
			old_seq_wt = wtd_path[0]
			sequence = wtd_path[-1]
			#morph_objs = list_of_morph_objs(morphID_list)
			for new_morphID in new_morphIDs:
				#morph_obj = morph_dict(new_morphID)
				new_seq = list(sequence)
				new_seq_wt = update_wt(sequence, new_morphID)
				new_seq.append(morphID)
				new_paths.append((new_seq_wt, new_seq))
		return new_seqs

def main(word, self.char_to_morph_mapping, morph_dict):
	"""self.charIndices_to_morphIDsis dict wherein the keys are indices of a particular word, 
	and the values are morphIDs."""
	paths = []
	steps = self.char_to_morph_mapping.items()
	options = steps[0]
	init_morph_objs = list_of_morph_objs(options)
	for init_morph in init_morph_objs: 
		paths.append(avg_wt([init_morph]), [init_morph])
	for index,morphID_list in steps[1:]: 
		morph_obj = morph_dict[morphID]
		paths = expand(paths, list_of_morph_objs(morphID_list, morph_dict))
	
	paths.sort(reverse=True)
	best_path_wt = paths[0][0]	
	best_path = paths[0][1]
	letter_bundles
	for item in best_path:

if __name__ == '__main__':
	main()