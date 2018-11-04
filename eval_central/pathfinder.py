#!/usr/bin/env python
# -*- coding: utf-8 -*-

import math,pprint,random
#import regex as re
import re
import sys, codecs

def sum_sequence(sequence):
	integers = []
	num_None = 0
	for item in sequence:
		try: int_item = int(item)
		except TypeError: 
			num_None += 1
			continue
		except ValueError: 
			num_None += 1
			continue
		else: integers.append(int_item)
	try: max_val = max(integers) + 1
	except ValueError: return 100000000
	return  sum(integers) + num_None * max_val

def get_weight(sequence, morph_dict):
	new_sequence = []
	overall_weight = 0.0
	num_None = 0
	for item in sequence:
		try: int_item = int(item)
		except TypeError: 
			num_None += 1
			continue
		except ValueError: 
			num_None += 1
			continue
		
		try: 
			current_wt = morph_dict[int(item)][0]
			#print "GW: morph_dict[", item, "] =", morph_dict[int(item)]
			#print "GW_CW =", current_wt
		except IndexError: 
			print "GW: INDEX_ERROR"
			continue
		except KeyError: 
			print "GW: KEY_ERROR"
			continue
		if item in new_sequence:
		#if step in new_sequence:
			pass
		else: 
			overall_weight += (1.0 + (1.0-current_wt))
			new_sequence.append(item)
	#try: max_val = max(integers) + 1
	#except ValueError: return 100000000
	return overall_weight + (num_None*2.0)

def remove_duplicate_steps(sequence):
	new_sequence = []
	#previous_step = ""
	for step in sequence:
		if step in new_sequence:
			pass
		else: new_sequence.append(step)
		#previous_step = step
	return new_sequence

class Pathfinder:
	def __init__(self, alignments, morph_dict, word): #, file_base_name):
		self.stack = []
		#self.paths = []
		self.input = alignments
		print "PF:", self.input
		#self.input = sorted(alignments.items())
		# init_item = self.input.pop(0)
		# init_position = init_item[0]
		# init_morph_list = init_item[1]
		# for morph_ID in init_morph_list:
		# 	self.stack.append([morph_ID])
		#print "SELF.INPUT:", self.input
		self.morph_dict = morph_dict
		init_index = 0
		#self.aux_filename = file_base_name + "_morphs.txt"
		input_morph_ID_list = [] #self.input[init_index]
		#print '/0/ ', input_morph_ID_list
		len_input_list = len(input_morph_ID_list)
		self.morphStrings = {}
		input_type = type(self.input[init_index])
		list_type = type([])
		init_avail_chars = list(word)
		init_used_chars = {}
		init_used_chars['other'] = []
		used_chars_copy = dict(init_used_chars)
		self.abbr_stack = []
		#while len(input_morph_ID_list) < 1 and init_index < len(self.input)-1:
		# while input_type != list_type and init_index < len(self.input)-1:
		# 	#self.stack.append([(init_index, None)])
		# 	avail_chars_copy = list(init_avail_chars)
		# 	avail_chars_copy.remove(self.input[init_index])
		# 	used_chars_copy = dict(init_used_chars)
		# 	used_chars_copy['other'].append(self.input[init_index])
		# 	self.stack.append([(init_index, self.input[init_index], avail_chars_copy, used_chars_copy)])
		# 	print '/1.1/', "STACK:", self.stack
		# 	init_index += 1
		# 	#print '/1.2/ ', init_index, "; input morph list:", input_morph_ID_list, "; length:", len(input_morph_ID_list)
		# 	#input_morph_ID_list = self.input[init_index]

		# 	input_type = type(self.input[init_index])
			#print '/1.3/ ', input_morph_ID_list 
			#len_input_list = len(input_morph_ID_list)
			#print '/1.4/ ', len_input_list 
			
			##print '/1.5/ ', init_index
		# if len(input_morph_ID_list) == 0:
		# 	cur_index += 1
		#print "/2/ STACK:", self.stack
		# for i in range(init_index, len(input_morph_ID_list)):
		# 	avail_chars = list(word[i:])
		# 	popped_path = self.stack.pop(0)

		# 	popped_index = popped_path[-1][0]

		# 	#used_chars_copy = dict(init_used_chars)
		# 	used_chars_copy['other'].append(input_morph_ID_list[i])
		# 	self.stack.append([(i, input_morph_ID_list[i], avail_chars, used_chars_copy)])
		# 	new_list = list(popped_path)
			#print '/2.' + str(i) + '/ STACK:', self.stack
		init_avail_chars = list(word)
		avail_chars_copy = list(init_avail_chars)
		self.stack.append([(0, input_morph_ID_list, avail_chars_copy, used_chars_copy)])
		self.abbr_stack.append(input_morph_ID_list)
		#self.stack.append([(init_index, input_morph_ID_list, used_chars_copy)])
		cur_index = init_index
		while cur_index < len(self.input):

			#self.stack.append([(cur_index, input_morph_ID_list, avail_chars_copy, used_chars_copy)])
			#print "/3.0.0/ STACK:", self.stack[0:3]
			popped_path = self.stack.pop(0)
			popped_abbr_path = self.abbr_stack.pop(0)
			#print 'ORIGEN /3.0.5/ popped_path:', popped_path
			popped_index = popped_path[-1][0]
			#popped_morph_ID = popped_path[-1][1]
			popped_avail_chars = popped_path[-1][-1]
			# if len(popped_avail_chars) == 0:
			# 	cur_index = popped_index + 1
			# 	#continue
			# 	break
			avail_chars_copy = list(popped_avail_chars)
			#morph_obj = morph_dict[popped_morph_ID][-1]
			#letters = morph_obj.get_letters()
			# all_letters_present = True
			# for letter in letters:
			# 	if letter not in popped_avail_chars:
			# 		all_letters_present = False
			# 		break

			#print '/3.1/ popped_index:', popped_index
			#if popped_index == 0:
			cur_index = popped_index + 1
			#cur_index = popped_index
			#print '/3.2/ cur_index:', cur_index
			if cur_index >= len(self.input): # or len(popped_avail_chars) == 0:
				#self.stack.append(popped_path)
				#print '/3.3/ cur_index:', cur_index, "BREAK!"
				#print "STACK:", self.stack
				break
			
			#print '/3.4/ popped_morph_ID:', popped_morph_ID
			input_tape = self.input[cur_index]
			#input_morph_ID = input_morph_ID_list 
			#print '/3.5/ input_morph_ID_list:', input_morph_ID_list
			#print "PF 185;", "MORPH LETTERS:", morph_obj.get_letters(),
			test_list = []
			if type(input_tape) != type(test_list): # or all_letters_present == False:
			#if len(input_morph_ID_list) == 0:
				#print '/4.' + str(0) + '.0/ STACK:', self.stack
				# if all_letters_present == False:
				# 	print "MORPH LETTERS NOT ALL PRESENT"
				# if type(input_tape) != type(test_list):
				# 	print "PF 187;", "MORPH_ID IS A LETTER, NOT A LIST"
				popped_avail_chars = popped_path[-1][-2]
				avail_chars_copy = list(popped_avail_chars)
				popped_used_chars = popped_path[-1][-1]
				used_chars_copy = dict(popped_used_chars)
				
				# if used_chars_copy.has_key('other'):
				# 	pass
				#else: used_chars_copy['other'] = []

				#morph_obj = morph_dict[input_morph_ID][-1]
				print "\nPF 187;","NON-MORPH INPUT:", input_tape, "; AVAIL LETTERS (before):", avail_chars_copy
				print "\tcur_index =", cur_index, "; word =", word, "; word[", cur_index, "] = ", word[cur_index]
				new_list = list(popped_path)
				new_abbr_list = list(popped_abbr_path)
				# try: 
				# 	#print "PF 187;","NON-MORPH:", input_tape, "; AVAIL LETTERS (before):", avail_chars_copy
				# 	avail_chars_copy.remove(input_tape)
				# 	print "PF 188;", "AVAIL LETTERS:", avail_chars_copy
				# except ValueError:
				# 	print "PF 189;", "VALUE_ERROR!!!!", "The letter", input_tape, "is unavailable."
				# 	continue
				#else:
				#used_chars_copy = dict(popped_used_chars)
				print "\tUSED_CHARS =", used_chars_copy
				# if input_tape in used_chars_copy['other']:
				# 	new_list.append((cur_index, input_tape, avail_chars_copy, used_chars_copy))
				# 	pass
				# else:
				print "avail_chars_copy =", avail_chars_copy
				#if input_tape in avail_chars_copy: 
				try: avail_chars_copy.remove(input_tape)
				except ValueError: continue
					#used_chars_copy['other'].append(input_tape)
					#print "\t*USED_CHARS =", used_chars_copy
				new_list.append((cur_index, input_tape, avail_chars_copy, used_chars_copy))
				self.stack.append(new_list)
				new_abbr_list.append(input_tape)
				self.abbr_stack.append(new_abbr_list)
				#else:
					#new_list.append((cur_index, input_tape, avail_chars_copy, used_chars_copy))
					#pass
						#new_list.append((cur_index, input_tape, used_chars_copy))
						# if used_chars_copy.has_key('other'):
						# 	used_chars_copy.append(input_tape)
						# else:
						
				#print "NEW_LIST 2:", new_list
				
				#self.stack.append(list(popped_path).append((cur_index, input_morph_ID)))
				#print '/4.' + str(0) + '.1/ STACK:', self.stack
				continue
			# if popped_morph_ID in input_morph_ID_list:
			# 	#print '/4.' + str(1) + '.0/ STACK:', self.stack, "; input_morph_ID_list:", input_morph_ID_list
			# 	new_list = list(popped_path)
			# 	#print "NEW_LIST:", new_list
			# 	new_list.append((cur_index, popped_morph_ID))
			# 	#print "NEW_LIST 2:", new_list
			# 	self.stack.append(new_list)
				#print '/4.' + str(1) + '.1/ STACK:', self.stack
				#continue
			#print '/4.' + '1.5' + '.0/ STACK:', self.stack
			i = 0
			#print "PF 200;", "MORPH LETTERS:", morph_obj.get_letters()
			#print "PF 201;", "AVAIL LETTERS:", avail_chars_copy

			for input_morph_ID in input_tape:
				#print '/4.' + str(2) + "." + str(i) + '.0/ input_morph_ID:', input_morph_ID
				new_list = list(popped_path)
				new_abbr_list = list(popped_abbr_path)
				#print "NEW_LIST:", new_list

				popped_avail_chars = popped_path[-1][-2]
				avail_chars_copy = list(popped_avail_chars)
				popped_used_chars = popped_path[-1][-1]
				used_chars_copy = dict(popped_used_chars)
				
				if used_chars_copy.has_key(input_morph_ID):
					pass
				else: used_chars_copy[input_morph_ID] = []

				morph_obj = morph_dict[input_morph_ID][-1]
				letters = morph_obj.get_letters()
				#all_letters_present = True
				pattern = morph_obj.get_pattern()
				re_morph = re.compile(pattern, re.UNICODE)
				#string = "".join(avail_chars_copy)
				match_obj = re_morph.search(word)
				if match_obj == None:
					print "NO MATCH IN ORIGINAL WORD!"
					not_all_letters_available = True
				print "\nINPUT:", self.input, ";", "POPPED AVAIL CHARS:", popped_avail_chars
				print "INPUT TAPE:", input_tape, "; WORD:", word, "cur_index =", cur_index, "; len_word:", len(word)
				print "MORPH_ID:", input_morph_ID, ";", "MORPH PAT:", morph_obj.get_pattern(), "LETTERS:", letters
				print "ABBR_STACK:", self.abbr_stack
				print "CURRENT_ABBR_PATH =", popped_abbr_path
				if cur_index + 1 < len(self.input):
					print "self.input[cur_index + 1]:", self.input[cur_index + 1]
				morph_letters_were_exhausted = True
				not_all_letters_available = False
				print "USED_CHARS =", used_chars_copy
				#print "CHECKING:",
				#char_used = False
				break_flag = False
				for letter in letters:
					print "CHECKING:", letter
					if letter in used_chars_copy[input_morph_ID]:
						#morph_letters_exhausted = True
						print "\tThe letter", letter, "has already been used by this morph. Try next letter" #Moving on.","Len_word:", len(word)
						#print self.input[cur_index + 1]
						
						continue
					# break_flag = 
					# for key in used_chars_copy.keys():
					# 	if letter in used_chars_copy[key]:
					# 		morph_letters_exhausted = True

					else:
						print "The letter", letter, "has not been used by this morph."
						morph_were_letters_exhausted = False
						#print "NEW_LIST:", new_list
						#new_list.append((cur_index, input_morph_ID, avail_chars_copy, used_chars_copy))
						if letter in avail_chars_copy:
							used_chars_copy[input_morph_ID].append(letter)
							avail_chars_copy.remove(letter)
							#new_list.append((cur_index, input_morph_ID, used_chars_copy))
							print "*USED_CHARS =", used_chars_copy, "; len_word:", len(word)
							new_list.append((cur_index,input_morph_ID, avail_chars_copy, used_chars_copy))
							self.stack.append(new_list)
							new_abbr_list.append(input_morph_ID)
							self.abbr_stack.append(new_abbr_list)
							#print ""
							#print "*USED_CHARS =", used_chars_copy
						else:
							print "But", letter, "is not available globally:", "AvailChars:", avail_chars_copy, "; len_word:", len(word)
							not_all_letters_available = True
						# We break the loop because we only want to use one letter at a time.
						break_flag = True
						break
						# if used_chars_copy.has_key(input_morph_ID):
						# 	used_chars_copy.append(input_tape)
						# else:
				if break_flag:
					break_flag = False
					continue

				# if match_obj == None:
				# 	print "NO MATCH"
				# 	all_letters_present = False
				# else:
				# 	all_letters_present = True
				# 	my_groups = match_obj.groups()
				# 	offset = 0
				# 	for i in range(len(my_groups)):
				# 		letter = my_groups[i]
				# 		try: 
				# 			idx = match_obj.span(i+1)[0]
				# 			#print idx,
				# 		except AttributeError:
				# 			print "NO SPAN!", "continue;"
				# 			continue
				# 		else:
				# 			print "word[" + str(idx) + "] = ", word[idx], ";", "word[" + str(idx) + " - " + str(offset) + "] = ", word[idx-offset]
				# 			avail_chars_copy.pop(idx - offset)
				# 			print "avail_chars_copy =", avail_chars_copy
				# 			offset += 1
							
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
						# try: mapping[idx].append(morphID)
						# except AttributeError:
						# 	#print "Can't append to", type(mapping[idx]), "!"
						# 	mapping[idx] = [morphID]
				
				# #print "MORPH PAT:", morph_obj.get_pattern()
				# all_letters_present = True
				# for letter in letters:
				# 	print "PF 202; MORPH LETTER", letter, "; AVAIL LETTERS:", avail_chars_copy 
				# 	#avail_chars_copy.remove(letter)
				# 	#avail_chars_copy2 = list(avail_chars_copy)
				# 	try: 
				# 		avail_chars_copy.remove(letter)
				# 		print "PF 203 (post-202);", letter, "; AVAIL LETTERS:", avail_chars_copy
				# 	except ValueError:
				# 		all_letters_present = False
				# 		print "^^^ PathFinder 210 ^^^ VALUE ERROR"
				# 		break
					
					#if letter not in popped_avail_chars:
					#all_letters_present = False
					#break
				#if all_letters_present:
				# 	new_list.append((cur_index, input_morph_ID, avail_chars_copy, used_chars_copy))
				# #print "NEW_LIST 2:", new_list
				# 	self.stack.append(new_list)
				if morph_letters_were_exhausted or not_all_letters_available:
					#pass
					to_stack = word[cur_index]
					# print "Word char to stack:", to_stack, "; word:", word, "; cur_index:", cur_index
					print "Cur_idx:", cur_index, "; word:", word, "; word[", cur_index, "]:", word[cur_index], "; len_word:", len(word)
					try: avail_chars_copy.remove(to_stack)
					except: 
						print  "TO_STACK ITEM", to_stack, "NOT AVAILABLE. These chars are availabel:", avail_chars_copy, ". Cur_idx:", cur_index, "."
						continue
					# new_list.append((cur_index, to_stack, avail_chars_copy))
					#self.stack.append(new_list)
					#used_chars_copy['other'].append(letter)
					new_list.append((cur_index, to_stack, avail_chars_copy, used_chars_copy))
					new_abbr_list.append(to_stack)
					#new_list.append((cur_index, to_stack, used_chars_copy))
					self.stack.append(new_list)
					self.abbr_stack.append(new_abbr_list)
				#print '/4.' + str(2) + "." + str(i) + '.1/ STACK:', self.stack
				i += 1

		# while len(self.input) > 0 and len(self.stack) > 0:
		# 	input_item = self.alignment_sequence.pop(0)
		# 	position,morph_ID_list = input_item[0],input_item[1]
		# 	if len(morph_ID_list) == 0:
		#cur_index = popped_index
			#print '/3.2/ cur_index:', cur_index
			#if cur_index >= len(self.input): # or len(popped_avail_chars) == 0:
				#self.stack.append(popped_path)
				#print '/3.3/ cur_index:', cur_index, "BREAK!"
				#print "STACK:", self.stack
				#break
	def replace_ids_with_morphs(self,ID_sequence):
		str_representations = []
		for morph_ID in ID_sequence:
			print "PF 10 (replace):", morph_ID, ";",
			try: int_morph_ID = int(morph_ID)
			except ValueError:
				#str_representations.append("None" + " " + "None")
				if type(u"a") == type(morph_ID) or type("a") == type(morph_ID):
					str_representations.append("*"+ morph_ID)
				continue
			except TypeError:
				#str_representations.append("None" + " " + "None")
				if type(u"a") == type(morph_ID) or type("a") == type(morph_ID):
					str_representations.append("*"+ morph_ID)
				continue
			wt, morph_obj= self.morph_dict[int_morph_ID]
			print ""
			#print "THIS IS A PROBLEM ->",self.morph_dict[int_morph_ID]
			morph_pattern = morph_obj.get_pattern()
			morph_letters = morph_obj.get_letters()
			letter_seq_str = "-".join(morph_letters)
			str_representations.append(morph_pattern) # + "/" + letter_seq_str)
		return str_representations

	def compute_paths(self):
		##print "uuuu"
		##print self.stack
		#fobj_strings = codecs.open(self.aux_filename, 'w', encoding='utf8')
		paths_hash = dict()
		#new_paths = []
		#print "PF_CP: STACK:", self.stack
		for path in self.stack:
			#print "Path:", path
			just_morph_IDs = []
			for pair in path:
				#new_list.append(str(pair[0]) + "," + str(pair[1]))
				just_morph_IDs.append(str(pair[1]))
		#new_paths.append(new_list)
			#just_morph_IDs = remove_duplicate_steps(just_morph_IDs)
		#for path in just_morph_IDs:	
			string_path = ";".join(just_morph_IDs)
			#new_paths.append(string_path)
		#output = "\n".join(new_paths)
		##print output
			paths_hash[string_path] = 1
			#print "STR_PATH:", string_path
		weighted_paths = []
		for str_path in paths_hash.keys():
			sequence = str_path.split(";")
			#weighted_paths.append((sum_sequence(sequence), sequence))
			weighted_paths.append((get_weight(sequence, self.morph_dict), sequence))
			#new_paths.append(str_path.split(";"))
		weighted_paths.sort()
		top_n_paths = weighted_paths[0:1]
		print "Top 5 Wtd Paths:", weighted_paths[0:5]
		self.final_morphID_sequences = []
		for weight,sequence in top_n_paths:
			sequence = remove_duplicate_steps(sequence)
			self.final_morphID_sequences.append(sequence)
			#output_line_components.append(",".join(self.getMorphStrings(sequence)))
		
		#return self.final_seq_list
		#return weighted_paths
		#return new_paths
	def get_paths(self):
		return self.final_morphID_sequences
	
	def get_morph_strings(self):
		# top_three = weighted_paths[0:3]
		# final_list = []
		output_line_components = []
		for sequence in self.final_morphID_sequences:
			#sys.stderr.write(str(sequence) + "\n")
			output_line_components.append(", ".join(self.replace_ids_with_morphs(sequence)))
		output_line = "\n\t".join(output_line_components)
		return output_line

	def get_simplified_paths(self):
		paths_hash = dict()
		new_paths = []
		##print self.stack
		for path in self.stack:
			##print path
			new_list = []
			for pair in path:
				#new_list.append(str(pair[0]) + "," + str(pair[1]))
				str_morph_ID = str(pair[1])
				if str_morph_ID not in new_list:
					new_list.append(str_morph_ID)
			#new_paths.append(",".join(new_list))
			new_paths.append(new_list)
		return new_paths 
	
	# def read(self):
	# 	item_read = self.input
	# 	if len(morph_ID_list) == 0:
	# 		for path in self.paths:
	# 			path.append(None)
	# 	else:
	# 		item_popped = stack.pop(0)
	# 		while len(self.stack) > 0:



	# 		addition = []
	# 		if len(morph_ID_list) > 1:
	# 			for path in self.paths:
	# 				last_item = path[-1]
	# 				position = last_item[0]
	# 				my_morph_ID = last_item[1]
	# 				for new_morph_ID in morph_ID_list:
	# 					if new_morph_ID == my_morph_ID:
	# 						path.append(new_morph_ID)
	# 						break
	# 					else:
	# 						path.append(new_morph_ID)
	# 						new_path = list(path)
	# 						new_path.
	# 						addition.append()



	# 	if morphID not in paths
	# 	return self.alignment_sequence.pop(0)

def main():
	##print alignments
	##print "SECOND:",alignments[1]
	alignments = {0:[200], 1:[], 2:[100,200], 3:[100,117,200]}
	my_pathfinder = Pathfinder(alignments)
	#print "boom"
	paths = my_pathfinder.get_paths()
	#for path in paths:
		#print path

if __name__ == '__main__':
	main()
#if __name__=="__main__":
	#cluster_file = sys.argv[1]
	#cluster_dict = process_clustering_file(cluster_file)
	
	#main(output_of_stage1, cluster_file)
	#main(alignments)
