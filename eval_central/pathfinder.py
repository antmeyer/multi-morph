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
	def __init__(self, alignments, morph_dict): #, file_base_name):
		self.stack = []
		#self.paths = []
		self.input = alignments
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
		input_morph_ID_list = self.input[init_index]
		#print '/0/ ', input_morph_ID_list
		len_input_list = len(input_morph_ID_list)
		self.morphStrings = {}
		input_type = type(self.input[init_index])
		list_type = type([])
		#while len(input_morph_ID_list) < 1 and init_index < len(self.input)-1:
		while input_type != list_type and init_index < len(self.input)-1:
			#self.stack.append([(init_index, None)])
			self.stack.append([(init_index, self.input[init_index])])
			#print '/1.1/ ', self.stack
			init_index += 1
			#print '/1.2/ ', init_index, "; input morph list:", input_morph_ID_list, "; length:", len(input_morph_ID_list)
			#input_morph_ID_list = self.input[init_index]
			input_type = type(self.input[init_index])
			#print '/1.3/ ', input_morph_ID_list 
			#len_input_list = len(input_morph_ID_list)
			#print '/1.4/ ', len_input_list 
			
			##print '/1.5/ ', init_index
		# if len(input_morph_ID_list) == 0:
		# 	cur_index += 1
		#print "/2/ STACK:", self.stack
		for i in range(init_index, len(input_morph_ID_list)):
			self.stack.append([(i, input_morph_ID_list[i])])
			#print '/2.' + str(i) + '/ STACK:', self.stack
		
		cur_index = init_index
		while cur_index < len(self.input):
			#print "/3.0.0/ + STACK:", self.stack
			popped_path = self.stack.pop(0)
			#print 'ORIGEN /3.0.5/ popped_path:', popped_path
			popped_index = popped_path[-1][0]
			#print '/3.1/ popped_index:', popped_index
			cur_index = popped_index + 1
			#print '/3.2/ cur_index:', cur_index
			if cur_index >= len(self.input):
				#self.stack.append(popped_path)
				#print '/3.3/ cur_index:', cur_index, "BREAK!"
				#print "STACK:", self.stack
				break
			popped_morph_ID = popped_path[-1][1]
			#print '/3.4/ popped_morph_ID:', popped_morph_ID
			input_tape = self.input[cur_index]
			#input_morph_ID = input_morph_ID_list 
			#print '/3.5/ input_morph_ID_list:', input_morph_ID_list
			test_list = []
			if type(input_tape) != type(test_list):
			#if len(input_morph_ID_list) == 0:
				#print '/4.' + str(0) + '.0/ STACK:', self.stack
				new_list = list(popped_path)
				#print "NEW_LIST:", new_list
				new_list.append((cur_index, input_tape))
				#print "NEW_LIST 2:", new_list
				self.stack.append(new_list)
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
			for input_morph_ID in input_tape:
				#print '/4.' + str(2) + "." + str(i) + '.0/ input_morph_ID:', input_morph_ID
				new_list = list(popped_path)
				#print "NEW_LIST:", new_list
				new_list.append((cur_index, input_morph_ID))
				#print "NEW_LIST 2:", new_list
				self.stack.append(new_list)
				#print '/4.' + str(2) + "." + str(i) + '.1/ STACK:', self.stack
				i += 1

		# while len(self.input) > 0 and len(self.stack) > 0:
		# 	input_item = self.alignment_sequence.pop(0)
		# 	position,morph_ID_list = input_item[0],input_item[1]
		# 	if len(morph_ID_list) == 0:

	def replace_ids_with_morphs(self,ID_sequence):
		str_representations = []
		for morph_ID in ID_sequence:
			try: int_morph_ID = int(morph_ID)
			except ValueError:
				#str_representations.append("None" + " " + "None")
				if type(u"a") == type(morph_ID) or type("a") == type(morph_ID):
					str_representations.append("*"+ morph_ID)
				continue
			wt, morph_obj= self.morph_dict[int_morph_ID]
			#print "THIS IS A PROBLEM ->",self.morph_dict[int_morph_ID]
			morph_pattern = morph_obj.get_pattern()
			morph_letters = morph_obj.get_letters()
			letter_seq_str = "-".join(morph_letters)
			str_representations.append(morph_pattern + "/" + letter_seq_str)
		return str_representations

	def compute_paths(self):
		##print "uuuu"
		##print self.stack
		#fobj_strings = codecs.open(self.aux_filename, 'w', encoding='utf8')
		paths_hash = dict()
		#new_paths = []
		##print self.stack
		for path in self.stack:
			#print "Path:", path
			just_morph_IDs = []
			for pair in path:
				#new_list.append(str(pair[0]) + "," + str(pair[1]))
				just_morph_IDs.append(str(pair[1]))
		#new_paths.append(new_list)
			just_morph_IDs = remove_duplicate_steps(just_morph_IDs)
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
			weighted_paths.append((sum_sequence(sequence), sequence))
			#new_paths.append(str_path.split(";"))
		weighted_paths.sort()
		top_n_paths = weighted_paths[0:1]
		self.final_morphID_sequences = []
		for weight,sequence in top_n_paths:
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
