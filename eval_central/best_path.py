#!/usr/bin/env python

import sys, re, codecs
reload(sys)  
sys.setdefaultencoding('utf8')
UTF8Writer = codecs.getwriter('utf8')
sys.stdout = UTF8Writer(sys.stdout)
sys.stderr = UTF8Writer(sys.stderr)

def list_of_morph_objs(morphIDs, morph_dict):
	morph_objs = []
	for morphID in morphIDs:
		#print "MID:", morphID
		try: int_ID = int(morphID)
		except TypeError:
			morph_obj = morphID
			item_wt = 1.0
		except ValueError:
			morph_obj = morphID
			item_wt = 1.0
		else:
			morph_obj = morph_dict[int_ID][-1]
			item_wt = morph_obj.get_weight()
			morph_objs.append(morph_obj)
	#print "from list func:", morph_objs
	return morph_objs

def dict_to_list(index_dict):
	items = []
	for index,item in sorted(index_dict.items()):
		#print "dict_to_list:", index_dict
		items.append(item)
	return item

def avg_wt(morphID_list, morph_dict):
	s = 0.0
	#print "avg_wt"
	morph_objs = list_of_morph_objs(morphID_list, morph_dict)
	for morph_obj in morph_objs:
		s += morph_obj.get_weight()
	try: quotient = s/float(len(morph_objs))
	except ZeroDivisionError: return 0.0
	else: return quotient

def get_chinese_char(i):
	# The integer '19968' marks the starting point of the unicode Chinese character block.
	return unichr(i + 19968)

def strictly_ordered(index_bundle_1, index_bundle_2):
	#indices_1 = self.morphIDs_to_charIndices(morphID_1)
	#indices_2 = self.morphIDs_to_charIndices(morphID_2)
	for i in index_bundle_1:
		for j in index_bundle_2:
			if i >= j: return False
	return True	

def interweave_bundles(index_bundle_1, index_bundle_2, word):
	#indices_1 = self.morphIDs_to_charIndices(morphID_1)
	#indices_2 = self.morphIDs_to_charIndices(morphID_2)
	#for i,j, in zip(indices_1, indices_2):
	comp_morph_indices = list(index_bundle_1)
	comp_morph_indices.extend(list(index_bundle_2))
	comp_seg = u""
	for idx in comp_morph_indices:
		comp_seg += word[idx]
	#index_span = (min(comp_morph_indices), max(comp_morph_indices))
	#self.segments.append(comp_morph_indices)
	return sorted(comp_morph_indices)

def process_index_bundles(path, morphIDs_to_charIndices, word):
#def process_index_bundles(morphIDs_to_charIndices, word):
	index_bundles = []
	#print "bp 3; path =", path
	if len(path) > 0:
		morphID = path[0]
		try: index_bundle = morphIDs_to_charIndices[morphID]
		except KeyError: pass
		#init_index_bundle = 
		#print "bp 3.5; path =", path
		#print "bp 4; working index_bundle =", index_bundle
		#index_bundle = morphIDs_to_charIndices[morphID]
		#print "bp 5; morphIDs_to_charIndices =", morphIDs_to_charIndices
		
		#print "bp 5; index_bundle =", index_bundle
		#print "bp 5; index_bundle =", index_bundle
		index_bundles.append(index_bundle)
		#print "bp 6; index_bundles =", index_bundles
	#for i in range(start, len(path)):
	#pairs = morphIDs_to_charIndices.items()
	#morphdID,index_bundle = pair[0]
	#index_bundles.append(index_bundle)
	#for i in range(len(1, morphIDs_to_charIndices.items())):
	for i in range(1,len(path)):
		# morphdID,cur_index_bundle = pairs[i]
		# print "bp 9; apirs:",pairs[i]
		# print "bp 7; path =", path[i]
		
		# try: 
		index_bundle_1 = index_bundles[-1]
		index_bundle_2 = morphIDs_to_charIndices[path[i]]
		#index_bundle_2 == path[i] #cur_index_bundle
		#except KeyError: pass
		if strictly_ordered(index_bundle_1, index_bundle_2):
			index_bundles.append(index_bundle_2)
		else:
			index_bundles[-1] = interweave_bundles(index_bundle_1, index_bundle_2, word)
	return index_bundles

#class Segmentation:
class Compression:
	#def __init__(self, morphID_list, morph_dict, charIndex_to_morphID_dict, word):
	def __init__(self, morph_dict, charIndex_to_morphID_dict, word):
		self.charIndices_to_morphIDs = charIndex_to_morphID_dict
		self.morph_dict = morph_dict
		self.paths = []
		self.word = word
		steps = self.charIndices_to_morphIDs.items()
		options = steps[0][-1]
		#print "STEPS:", steps, ";", "OPTIONS:", options
		#init_morph_objs = list_of_morph_objs(options, self.morph_dict)
		for morphID in options:
			wt = avg_wt(options, self.morph_dict)
			#sys.stderr.write("\n\n****** wt = " + str(wt) + "\n\n")
			self.paths.append((wt, [morphID]))
		#print "self.paths =", self.paths
		#for init_morph in init_morph_objs:
		print "*** num_options:", len(steps[1:]) 
		for index,options in steps[1:]:
			print "****** index,options =", index,options
			#print "index,morphID_list:", index,morphID_list
			#for morphID in options:
				#try: int_ID = int(morphID)
				#morph_obj = self.morph_dict[morphID][-1]
			#self.paths = expand(self.paths, list_of_morph_objs(morphID_list, self.morph_dict))
			self.paths = self.expand(self.paths, options)
		
		# init_morph_objs = list_of_morph_objs(options, self.morph_dict)
		# for init_morph in init_morph_objs: 
		# 	self.paths.append(avg_wt([init_morph]), [init_morph])

		# for index,morphID_list in steps[1:]: 
		# 	morph_obj = morph_dict[morphID]
		# 	#paths = expand(paths, list_of_morph_objs(morphID_list, morph_dict))
		# 	self.paths = self.expand(self.paths, morphID_list)
		# at this point, all the paths, i.e., self.paths, will have been computed. 
		self.paths.sort(reverse=True)
		best_path_wt = self.paths[0][0]	
		self.best_raw_path = self.paths[0][1]
		
		# def get_compressed_path(self):
		# """Removes duplicate instances of morph IDs (i.e. morphs, basically). Any morph that consists
		# of more that one character will manifest as multiple instances of the same morph ID
		# in a given path."""
		self.morphIDs = []
		for morphID in self.best_raw_path:
			if morphID in self.morphIDs: pass
			else: self.morphIDs.append(morphID)
		#return compressed_sequence
		#self.compressed_path = []
		#self.morphIDs = self.get_compressed_path()

		# self.encodedMorphIDs = self.encode_morphs(self.morphIDs)
		# for morphID in self.best_raw_path:
		# 	if morphID not in self.compressed_best_path:
		# 		self.compressed_best_path.append(morphID)
		#output_dict = {}
		self.morphIDs_to_charIndices = {}
		for index,morphID_list in sorted(self.charIndices_to_morphIDs.items()):
			for morphID in morphID_list:
				if self.morphIDs_to_charIndices.has_key(morphID):
					self.morphIDs_to_charIndices[morphID].append(index)
				else:
					self.morphIDs_to_charIndices[morphID] = [index]
		#return output_dict
		#self.morphIDs_to_charIndices = self.map_morphIDs_to_charIndices()
		# self.segments = []
		self.index_bundles = process_index_bundles(self.morphIDs, self.morphIDs_to_charIndices, self.word)

	
	# def get_char_indices(self, morphID):
	# 	return self.morphIDs_to_charIndices[morphID]
	
	def compute_segments(self): 
		"""This method returns the (merged) index bundles."""
		for bundle in self.index_bundles:
			segment = u""
			for index in bundle:
				segment += self.word[index]
			self.segments.append(segment)
		#return self.segments 
	
	# def get_segments(self):
	# 	return self.segments
	
	def get_morphIDs_to_charIndices_map(self):
		return self.morphIDs_to_charIndices

	def get_compressed_path(self):
		"""Removes duplicate instances of morph IDs (i.e. morphs, basically). Any morph that consists
		of more that one character will manifest as multiple instances of the same morph ID
		in a given path."""
		# compressed_sequence = []
		# for morphID in self.best_raw_path:
		# 	if morphID in compressed_sequence: pass
		# 	else: compressed_sequence.append(morphID)
		#return compressed_sequence
		return self.morphIDs

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
		
	# def strictly_ordered(self, index_bundle_1, index_bundle_2):
	# 	#indices_1 = self.morphIDs_to_charIndices(morphID_1)
	# 	#indices_2 = self.morphIDs_to_charIndices(morphID_2)
	# 	for i in index_bundle_1:
	# 		for j in index_bundle_2:
	# 			if i >= j: return False
	# 	return True

	# def interweave(self, index_bundle_1, index_bundle_2):
	# 	#indices_1 = self.morphIDs_to_charIndices(morphID_1)
	# 	#indices_2 = self.morphIDs_to_charIndices(morphID_2)
	# 	#for i,j, in zip(indices_1, indices_2):
	# 	comp_morph_indices = list(index_bundle_1)
	# 	comp_morph_indices.extend(list(index_bundle_2))
	# 	comp_seg = u""
	# 	for idx in comp_morph_indices:
	# 		comp_seg += self.word[idx]
	# 	#index_span = (min(comp_morph_indices), max(comp_morph_indices))
	# 	#self.segments.append(comp_morph_indices)
	# 	return comp_morph_indices
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

	# def map_morphIDs_to_charIndices(self):
	# 	"""Maps the 'raw' morph-ID sequence to a list of character indices, i.e.,
	# 	a list of indices for each morph (ID)."""
	# 	output_dict = {}
	# 	for index,morph_ID_list in sorted(self.char_to_morph_mapping.items()):
	# 		for morphID in morph_ID_list:
	# 			if output_dict.has_key(morphID):
	# 				output_dict[morphID].append(index)
	# 			else:
	# 				output_dict[morphID] = [index]
	# 	return output_dict

	def get_chinese_chars(self):
		symbols = []
		# for morphID in morphIDs:
		# 	int_ID = int(morphID)
		# 	symbols.append(get_chinese_char(int_ID))
		#return chinese_chars
		
		#encoded_word = u""
		for morphID in self.morphIDs:
			#sys.stderr.write(morphID + " ")
			try: 
				int_ID = int(morphID)
				morphID = int_ID
				#print "++++++++", type(morphID), "morphID:", morphID, int_ID
				#sys.stderr.write(str(int_ID))
				#encoded_word += map_id_to_chinese[int_ID]
				symbols.append(get_chinese_char(int_ID))

				#sys.stderr.write(encoded_word + ", ")
			except KeyError:
				#sys.stdout.write("KEY_ERROR: MORPH_ID: " + str(morphID) + " !!!\n")
				symbols.append(morphID)

			except TypeError:
				sys.stdout.write("TYPE_ERROR: MORPH_ID: " + str(morphID) + " !!!\n")
				if type(u"a") == type(morphID) or type("a") == type(morphID):
					#encoded_word += morphID
					symbols.append(morphID)
			except ValueError:
				# sys.stdout.write("TYPE_ERROR: MORPH_ID: " + str(morphID) + " !!!\n")
				# if type(u"a") == type(morphID) or type("a") == type(morphID):
					#encoded_word += morphID
				symbols.append(morphID)
			else:
				symbols.append(get_chinese_char(morphID))
		return symbols
		#return encoded_word
	
	def update_wt(self, weighted_sequence, morphID):
		"""Weighted_item is a pair consisting of a weight (positive real number)
		and an item. A sequence is a list of items."""
		#item_wt = morphID[1][0]
		#sys.stderr.write("\n\n\n Weighted item: " + str(morphID) + "\n\n\n")
		#if type(morphID) == "a" or type(morphID) == u"a":
		#if type(morphID) != type(1):
		try: int_ID = int(morphID)
		except TypeError:
			morph_obj = morphID
			item_wt = 1.0
		except ValueError:
			morph_obj = morphID
			item_wt = 1.0
		else:
			morph_obj = self.morph_dict[int_ID][-1]
			item_wt = morph_obj.get_weight()
		#item_wt = morphID[1][0]
		#item = morphID[1][1]'
		#sys.stderr.write("\n\n\nWtd Seq: " + str(weighted_sequence) + "\n\n\n")
		seq_wt = weighted_sequence[0]
		sequence = weighted_sequence[-1]
		#print "WTD SEQ:", weighted_sequence
		#print "SEQ:", sequence
		new_avg = (seq_wt+item_wt)/2.0
		for n in range(1,3):
			try: item = sequence[-n]
			except IndexError: 
				#print "IND   E   X       Error   !"
				break
			else:
				#print item, "==", morphID, " ?"
				if item == morphID:
					#print "TRUE"
					return 2.0*new_avg
		# if morphID in sequence: 
		# 	return 2.0*new_avg
		# else: return new_avg
		return new_avg

	def expand(self, paths, new_morphIDs):
		new_paths = []
		m = 0
		#print "&&&&&& num_paths =", len(paths)
		limit = min(10,len(paths))
		paths.sort(reverse=True)
		print paths
		print "truncated:", paths[:limit]
		#for wtd_path in sorted(paths[0:limit], reverse=True):
		for wtd_path in paths[:limit]:
			old_seq_wt = wtd_path[0]
			sequence = wtd_path[-1]
			m += 1
			#morph_objs = list_of_morph_objs(morphID_list)
			n = 0
			for new_morphID in new_morphIDs:
				#print "^^", new_morphID, "^^!"
				#morph_obj = morph_dict(new_morphID)
				new_seq = list(sequence)
				new_seq_wt = self.update_wt((old_seq_wt, sequence), new_morphID)
				# if new_seq_wt > old_seq_wt:
				# 	print "^^", new_morphID, new_seq_wt, old_seq_wt, "^^!"
				new_seq.append(new_morphID)
				new_paths.append((new_seq_wt, new_seq))
				n += 1
		#print "***** m =", m, "\t", "***** n =", n, " --> ", m*n
		return new_paths


def main(word, char_to_morph_mapping, morph_dict):
	"""self.charIndices_to_morphIDsis dict wherein the keys are indices of a particular word, 
	and the values are morphIDs."""
	paths = []
	steps = self.char_to_morph_mapping.items()
	options = steps[0][-1]
	init_morph_objs = list_of_morph_objs(options)
	for init_morph in init_morph_objs: 
		paths.append(avg_wt([init_morph]), [init_morph])
	for index,morphID_list in steps[1:]: 
		morph_obj = morph_dict[morphID]
		paths = expand(paths, list_of_morph_objs(morphID_list, morph_dict))
	
	paths.sort(reverse=True)
	best_path_wt = paths[0][0]	
	best_path = paths[0][1]
	#letter_bundles
	#for item in best_path:

# if __name__ == '__main__':
# 	main()