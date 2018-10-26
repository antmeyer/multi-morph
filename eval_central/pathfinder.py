#!/usr/bin/env python
# -*- coding: utf-8 -*-

import math,pprint,random
#import regex as re
import re
import sys, codecs

class Pathfinder:
	def __init__(self, alignments):
		self.stack = []
		#self.paths = []
		self.input = alignments
		#self.input = sorted(alignments.items())
		# init_item = self.input.pop(0)
		# init_position = init_item[0]
		# init_morph_list = init_item[1]
		# for morph_ID in init_morph_list:
		# 	self.stack.append([morph_ID])
		print "SELF.INPUT:", self.input
		init_index = 0
		input_morph_ID_list = self.input[init_index]
		print '/0/ ', input_morph_ID_list
		len_input_list = len(input_morph_ID_list)

		while len_input_list < 1:
			self.stack.append([(init_index, None)])
			print '/1.1/ ', self.stack
			init_index += 1
			print '/1.2/ ', init_index
			input_morph_ID_list = self.input[init_index]
			print '/1.3/ ', input_morph_ID_list 
			len_input_list = len(input_morph_ID_list)
			print '/1.4/ ', len_input_list 
			
			#print '/1.5/ ', init_index
		# if len(input_morph_ID_list) == 0:
		# 	cur_index += 1
		print "/2/ STACK:", self.stack
		for i in range(init_index, len(input_morph_ID_list)):
			self.stack.append([(i, input_morph_ID_list[i])])
			print '/2.' + str(i) + '/ STACK:', self.stack
		
		cur_index = 0
		while cur_index < len(self.input):
			print "/3.0.0/ + STACK:", self.stack
			popped_path = self.stack.pop(0)
			print 'ORIGEN /3.0.5/ popped_path:', popped_path
			popped_index = popped_path[-1][0]
			print '/3.1/ popped_index:', popped_index
			cur_index = popped_index + 1
			print '/3.2/ cur_index:', cur_index
			if cur_index >= len(self.input):
				#self.stack.append(popped_path)
				print '/3.3/ cur_index:', cur_index, "BREAK!"
				print "STACK:", self.stack
				break
			popped_morph_ID = popped_path[-1][1]
			print '/3.4/ popped_morph_ID:', popped_morph_ID
			input_morph_ID_list = self.input[cur_index]
			#input_morph_ID = input_morph_ID_list 
			print '/3.5/ input_morph_ID_list:', input_morph_ID_list
			if len(input_morph_ID_list) == 0:
				print '/4.' + str(0) + '.0/ STACK:', self.stack
				new_list = list(popped_path)
				print "NEW_LIST:", new_list
				new_list.append((cur_index, None))
				print "NEW_LIST 2:", new_list
				self.stack.append(new_list)
				#self.stack.append(list(popped_path).append((cur_index, input_morph_ID)))
				print '/4.' + str(0) + '.1/ STACK:', self.stack
				continue
			if popped_morph_ID in input_morph_ID_list:
				print '/4.' + str(1) + '.0/ STACK:', self.stack, "; input_morph_ID_list:", input_morph_ID_list
				new_list = list(popped_path)
				print "NEW_LIST:", new_list
				new_list.append((cur_index, popped_morph_ID))
				print "NEW_LIST 2:", new_list
				self.stack.append(new_list)
				print '/4.' + str(1) + '.1/ STACK:', self.stack
				#continue
			print '/4.' + '1.5' + '.0/ STACK:', self.stack
			i = 0
			for input_morph_ID in input_morph_ID_list:
				print '/4.' + str(2) + "." + str(i) + '.0/ STACK:', self.stack
				new_list = list(popped_path)
				print "NEW_LIST:", new_list
				new_list.append((cur_index, input_morph_ID))
				print "NEW_LIST 2:", new_list
				self.stack.append(new_list)
				print '/4.' + str(2) + "." + str(i) + '.1/ STACK:', self.stack
				i += 1

		# while len(self.input) > 0 and len(self.stack) > 0:
		# 	input_item = self.alignment_sequence.pop(0)
		# 	position,morph_ID_list = input_item[0],input_item[1]
		# 	if len(morph_ID_list) == 0:

	def get_paths(self):
		#print "uuuu"
		#print self.stack
		paths_hash = dict()
		new_paths = []
		print self.stack
		for path in self.stack:
			#print path
			new_list = []
			for pair in path:
				#new_list.append(str(pair[0]) + "," + str(pair[1]))
				new_list.append(str(pair[1]))
		#new_paths.append(new_list)
			string_path = ";".join(new_list)
			new_paths.append(string_path)
		#output = "\n".join(new_paths)
		#print output
			paths_hash[string_path] = 1
		return paths_hash.keys()
	
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

def main(alignments):
	#print alignments
	#print "SECOND:",alignments[1]
	my_pathfinder = Pathfinder(alignments)
	print "boom"
	paths = my_pathfinder.get_paths()
	for path in paths:
		print path

if __name__=="__main__":
	#cluster_file = sys.argv[1]
	#cluster_dict = process_clustering_file(cluster_file)
	alignments = {0:[200], 1:[], 2:[100,200], 3:[100,117,200]}
	#main(output_of_stage1, cluster_file)
	main(alignments)
