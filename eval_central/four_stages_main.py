#!/usr/bin/env python

import sys, codecs, unicodedata    #, morfessor, re, pprint
import stage1_alt as stage1 
#import stage2 as stage2
from stage2 import *
from best_path import *
#from reconvert_morphs import read_gldstd_words, original_test_words
	
#import sys, codecs, re
reload(sys)  
sys.setdefaultencoding('utf8')
UTF8Writer = codecs.getwriter('utf8')
sys.stdout = UTF8Writer(sys.stdout)
sys.stderr = UTF8Writer(sys.stderr)

def get_chinese_char(i):
	# The integer '19968' marks the starting point of the unicode Chinese character block.
	return unichr(i + 19968)

def writeMorphDict(morph_dict, filename):
	fobj = codecs.open(filename, 'w', encoding='utf8')
	for morphID,morph_wt_obj in morph_dict.items():
		morph_obj = morph_wt_obj[-1]
		letter_seq = morph_obj.get_letters()
		fobj.write(unicode(morphID) + u"\t" + u"".join(letter_seq) + u"\n")
	fobj.close()

def writeChineseToMorphIDDict(chinese_dict, filename):
	fobj = codecs.open(filename, 'w', encoding='utf8')
	for chinese_char,morphID in chinese_dict.items():
		#morph_obj = morph_wt_obj[-1]
		#letter_seq = morph_obj.get_letters()
		fobj.write(unicode(chinese_char) + u"\t" + unicode(morphID) + u"\n")
	fobj.close()
#INPUT:
## 1: A file ending in ".mc.C_vals" (see eval_stage2 directory)
## 2: A file ending in ".mc.clusters" (see eval_stage2 directory)
## 3: Morfesser BS
## 4: Morfessor BS
# 2_2_K6000_N12222_basic_180626_18-27_k-1000.C_vals 2_2_K6000_N12222_basic_180626_18-27_k-1000.clusters
	
# def four_stages(cluster_centroids_filename, cluster_membership_filename, wordlist_filename, originals_dir, output_dir):
def four_stages(cluster_centroids_filename, cluster_membership_filename, originals_dir, covered_dir, output_dir):
	word_idx_dict = {}
	idx_word_dict = {}
	print "4_stages 0; covered_dir:", covered_dir
	#original_words_dict = read_gldstd_words(originals_filename)
	#gldstd_list = gldstd_word_dict.keys()
	#cluster_centroids_filename = sys.argv[1]
	#basename = cluster_centroids_filename.split(".")[0]
	#cluster_membership_filename = sys.argv[2]
	#control_training_filename = sys.argv[3]
	#wordlist_filename = sys.argv[3]
	# fobj = codecs.open(originals_filename, 'r', encoding='utf8')
	# lines = fobj.readlines()
	# fobj.close()
	# #print "???", lines[0]
	# if lines[0][0] == "#":
	# 	lines.pop(0)
	# for n in range(len(lines)):
	# 	#print "4stgs;", "line ", n, ":", lines[n]
	# 	word = lines[n].replace("\n", "") 
	# 	word_idx_dict[word] = n
	# 	idx_word_dict[n] = word

	# fobj = codecs.open(wordlist_filename, 'r', encoding='utf8')
	# lines = fobj.readlines()
	# print "4_stages 0; NUMBER OF LINES =", len(lines)
	# fobj.close()
	# #print "???", lines[0]
	# if lines[0][0] == "#":
	# 	lines.pop(0)
	# for n in range(len(lines)):
	# 	#print "4stgs;", "line ", n, ":", lines[n]
	# 	word = lines[n].replace("\n", "") 
	# 	word_idx_dict[word] = n
	# 	idx_word_dict[n] = word
	#if "n" in word_idx_dict.keys():
		#print "\n\n\n\n\n\n" + "n  is in word_idx_dict\n\n\n\n\n\n"
	#fobj.close()
	#control_gldstd_filename = sys.argv[4]
	#ori_words = original_test_words(originals_filename)
	main_name = cluster_centroids_filename.split("/")[-1]
	basename = main_name.split(".")[0]
	#print "4_stages 3; main_name =", main_name
	#print "4_stages 4; basename =", basename
	#sys.stderr.write("BASE BASE BASE: "+ basename + "\n")
	# trn_basename = control_training_filename.split(".")[0]
	# gld_basename = control_gldstd_filename.split(".")[0]
	# encoded_training_filename = trn_basename + "_symbols.txt"
	# #encoded_gldstd_filename = gld_basename + "_symbols.txt"
	# #fobj_train = codecs.open(control_training_filename, 'r', encoding='utf8')
	# #control_training_filename = "morfessor_TR_training.txt"
	# fobj_train_enc = codecs.open(encoded_training_filename , 'w', encoding='utf8')
	#eval_filename = basename + "_extrinsic_eval.txt"

	# 	fobj_new_train.write(line)
	#chinese_segm_filename = basename + ".chinese_segm"

	####### STAGE 1 ####### 
	morph_dict = stage1.main(cluster_centroids_filename)
	# print "from 4 stages main, stage 1:"
	# for key,val in morph_dict.items():
	# 	print key, "-->", val[-1].get_pattern()
	####### STAGE 2 ####### 
	#word_segmentations_dict = stage2.main(morph_dict, cluster_membership_filename)
	#charToMorphAlignments = stage2.main(morph_dict, cluster_membership_filename)
	#compressed_morph_seqs = stage2.main(morph_dict, cluster_membership_filename)

	clustersAndWords_dict = process_clustering_file(cluster_membership_filename)
	morphIDs = morph_dict.keys() ####print clustersAndWords_dict
	print "4_stages 10; TYPE OF FIRST MORPH_ID:", type(morphIDs[0])
	my_stage2 = Stage2(morph_dict, clustersAndWords_dict, cluster_membership_filename)
	#my_stage2 = Stage2(morph_dict, clustersAndWords_dict, cluster_membership_filename, wordlist_filename)
	my_stage2.segment()
	compressed_morph_seqs = my_stage2.get_compressed_morph_seqs()
	#word_segmentations = dict()
	#word_segmentations = my_stage2.get_segmentations()
	#charToMorphAlignments = my_stage2.get_alignments()
	my_stage2.print_morphID_toCharIdx_maps("temp/" + basename + ".M2C_map")
	covered_words = my_stage2.get_covered_words()
	for n in range(len(covered_words)):
		#print "4stgs;", "line ", n, ":", lines[n]
		word = covered_words[n]    #.replace("\n", "") 
		word_idx_dict[word] = n
		idx_word_dict[n] = word
	print "4_stages 15; COVERED PATH:", covered_dir + basename + ".words"
	my_stage2.print_covered_words(covered_dir + basename + ".words")
	# trn_lines = fobj_train.readlines()
	# if trn_lines[0][0] == "#":
	# 	trn_lines.pop(0)
	# for line in trn_lines:
	# 	word = line.replace("\n", "")
	# 	paths_obj = Compression(morph_dict, charToMorphAlignments, word)

	# print "from 4 stages main:, stage 2:"
	# for key,val in word_segmentations_dict.items():
	# 	print key, "-->", val
	# print word_segmentations_dict
	###### STAGE 3 ####### 
	map_id_to_chinese = {}
	map_chinese_to_id = {}
	#encoded_segmentations = {}
	#morphIDs = morph_dict.keys()
	#IDs.extend(letter_dict.keys())
	encodings = {}
	gldstd_encodings = list()

	for word,word_idx in word_idx_dict.items():
	#for word in covered_words:
		#print "^^^^^^******** WORD:", word
		try: morphID_seq = compressed_morph_seqs[word]
		except KeyError: continue
		#for wordO,morphID_seq in compressed_morph_seqs.items():
		symbols = []
		for morphID in morphID_seq:
			#sys.stderr.write(morphID + " ")
			try: 
				int_ID = int(morphID)
				morphID = int_ID
				#print "++++++++", type(morphID), "morphID:", morphID, int_ID
				#sys.stderr.write(str(int_ID))
				#encoded_word += map_id_to_chinese[int_ID]
				#sys.stderr.write(encoded_word + ", ")
			# except KeyError:
			# 	sys.stdout.write("KEY_ERROR: MORPH_ID: " + str(morphID) + " !!!\n")

			except TypeError:
				#sys.stdout.write("TYPE_ERROR: MORPH_ID: " + str(morphID) + " !!!\n")
				if type(u"a") == type(morphID) or type("a") == type(morphID):
					symbols.append(morphID)
					continue
					# choose an unused integer to serve as a 'dummy ID' for a 'None'-type morph-ID.
				#encoded_word += get_chinese_char(dummy_id)
			except ValueError: #continue
				#sys.stdout.write("VALUE_ERROR: MORPH_ID: " + str(morphID) + " !!!\n")
				if type(u"a") == type(morphID) or type("a") == type(morphID):
					symbols.append(morphID)
					continue
			
			# except ValueError: #continue
			# 	symbols.append(morphID)
			# 	continue
				# sys.stdout.write("VALUE_ERROR: MORPH_ID: " + str(morphID) + " !!!\n")
				# if type(u"a") == type(morphID) or type("a") == type(morphID):
				# 	symbols.append(str(morphID))
				# 	continue
			else:
				try: #symbol = #map_id_to_chinese[morphID]
					symbol = get_chinese_char(morphID)
					#symbols.append(sy)
				except KeyError:
					symbols.append(morphID)
					#print "K E Y   E R R O R ! ! !"
					pass
				else: 
					symbols.append(symbol)
					map_id_to_chinese[morphID] = symbol
					map_chinese_to_id[symbol] = morphID
					# if symbol in map_chinese_to_id.keys():
					# 	map_chinese_to_id[symbol].append(morphID)
					# else:
					# 	map_chinese_to_id[symbol] = [moprhID]
		# try: word_idx = word_idx_dict[word]
		# except KeyError: continue
		# else:
		encodings[word_idx] = "".join(symbols)
			#if gldstd_encodings 
			#encodings_list.append("".join(symbols))
			#if word in gldstd_portion.keys()
			#if word in gldstd_list:
		# gldstd_encodings.append(("".join(symbols), word))
			#print "4_stages 100;", "".join(symbols), word
	#print "4_stages 200; gldstd_encodings:", gldstd_encodings
					#dummy_id += 1
					#continue
	#encoded_training_filename = trn_basename + "_symbols.txt"
	encoded_items = encodings.items()
	encoded_items.sort(key=lambda x: x[1]) 
	output_dir = output_dir.rstrip("/")
	fobj_train_enc = codecs.open(output_dir + "/" + basename + ".chinese", 'w', encoding='utf8')
	#for word_idx,encoded_word in sorted(encodings.items()):
	for word_idx,encoded_word in encoded_items:
		fobj_train_enc.write(encoded_word + "\n")	
	fobj_train_enc.close()
	
	originals_dir = originals_dir.rstrip("/")
	fobj_order = codecs.open(originals_dir + "/" + basename + ".original_order", 'w', encoding='utf8')
	for word_idx,encoded_word in encoded_items:
		fobj_order.write(encoded_word + "\t" + str(word_idx) + "\t" + idx_word_dict[word_idx] + "\n")	
	fobj_order.close()

	# fobj_test_enc = codecs.open(originals_dir + "/" + basename + ".test_words", 'w', encoding='utf8')
	# for encoded_word,ori_word in sorted(gldstd_encodings):
	# 	line = encoded_word + "\t" + ori_word + "\n"
	# 	#print "4_stages 300; ***", line
	# 	fobj_test_enc.write(line)
	# fobj_test_enc.close()	

	items = originals_dir.split("/")
	items2 = list(items)
	old_dir_name = items.pop()
	old_dir_name2 = items2.pop()
	dir_name_pieces = old_dir_name.split("_")
	dir_name_pieces2 = old_dir_name2.split("_")
	toKeep = dir_name_pieces[0:2]
	toKeep2 = dir_name_pieces2[0:2]
	toKeep.append("CH_to_morphID")
	toKeep2.append("morph_dict")  #extend(["symbol","key"])
	new_dir_name = "_".join(toKeep)
	new_dir_name2 = "_".join(toKeep2)
	items.append(new_dir_name)
	items2.append(new_dir_name2)
	new_path = "/".join(items)
	new_path2 = "/".join(items2)
	#items.append("")
	chinese_to_morphID_file = new_path + "/" + basename + ".CH_to_morphID"
	morph_dict_file = new_path2 + "/" + basename + ".morph_dict"

	# for morphID in morph_dict.keys():
	# 	map_id_to_chinese[morphID] = get_chinese_char(int(morphID))
	# for morphID in morphIDs:
	# 	chinese_char = get_chinese_char(int(morphID))
	# 	map_id_to_chinese[morphID] = get_chinese_char(int(morphID))
	# 	map_chinese_to_id[chinese_char] = morphID
		#print map_id_to_chinese[morphID]
	#encoded_gldstd_filename = "morfessor_gldstd_symbols.txt"
	#dummy_id = 1001
	#encoded_strings = []
	#print "PPRINT WORD_SEGMENTATIONS DICT"
	#pprint.pprint(word_segmentations_dict.items())
	# encoded_lines = []
	# encoded_word = u""
	# numcntr = 0
	#for word,morphID_sequence_list in word_segmentations_dict.items():
		#print "aaaaa", morphID_sequence_list
		#print "aaaaa" + str(numcntr) + ":", morphID_sequence_list
		#encoded_segmentations[word] = []
		#sys.stderr.write(word + "; seq: " + unicode(morphID_sequence) + u"\n")
		
		#encoded_word = ""
		#encoded_words = []
		#print map_id_to_chinese
		# try: morphID_sequence = morphID_sequences[0]
		# except IndexError:
		# 	sys.stderr.write("INDEX_ERROR!" + "\n")
		# 	continue
		#sys.stderr.write(" ".join(morphID_sequence) + "\n")
		#for morphID_sequence in morphID_sequences:
			#sys.stderr.write(morphID_sequence + " ")
	# 	encoded_word = u""
	# 	encoded_strings = []
	# 	for morphID_sequence in morphID_sequence_list[0:1]:
	# 		print "bbbbb:", morphID_sequence
	# 		#print "bbbbb" + str(numcntr) + ":", morphID_sequence
	# 		#sys.stderr.write(word + "; seq: " + unicode(morphID_sequence) + u"\n")
	# 		#temp = []
	# 		encoded_word = u""
	# 		for morphID in morphID_sequence:
	# 			#sys.stderr.write(morphID + " ")
	# 			try: 
	# 				int_ID = int(morphID)
	# 				print "++++++++", type(morphID), "morphID:", morphID, int_ID
	# 				#sys.stderr.write(str(int_ID))
	# 				encoded_word += map_id_to_chinese[int_ID]
	# 				#sys.stderr.write(encoded_word + ", ")
	# 			except KeyError:
	# 				sys.stdout.write("KEY_ERROR: MORPH_ID: " + str(morphID) + " !!!\n")

	# 			except TypeError:
	# 				sys.stdout.write("TYPE_ERROR: MORPH_ID: " + str(morphID) + " !!!\n")
	# 				if type(u"a") == type(morphID) or type("a") == type(morphID):
	# 					encoded_word += morphID
	# 					# choose an unused integer to serve as a 'dummy ID' for a 'None'-type morph-ID.
	# 				#encoded_word += get_chinese_char(dummy_id)
	# 			except ValueError: #continue
	# 				sys.stdout.write("VALUE_ERROR: MORPH_ID: " + str(morphID) + " !!!\n")
	# 				if type(u"a") == type(morphID) or type("a") == type(morphID):
	# 					encoded_word += morphID
	# 					#dummy_id += 1
	# 					#continue
	# 			#temp.append(encoded_word)
	# 		sys.stdout.write(encoded_word + "\n")	
	# 		encoded_strings.append(encoded_word)
	# 		#encoded_lines.append(encoded_word + "\n")
	# 		#encoded_words.append(encoded_word)
	# 	encoded_line = ",".join(encoded_strings)
	# 	encoded_lines.append(encoded_line)
	# 	#encoded_segmentations[encoded_word] = encoded_line
	# #sys.stderr.write("\n")
	# 	numcntr += 1
	# fobj_train_enc = codecs.open(encoded_training_filename, 'w', encoding='utf8')
	# #fobj_gldstd_enc = codecs.open(encoded_gldstd_filename, 'w', encoding='utf8')


	# Write the encoded version of the word list to a file.
	# for encoded_line in encoded_lines:
	# 	#sys.stderr.write(encoded_line + "\n")
	# 	fobj_train_enc.write(encoded_line + "\n")
	# fobj_train_enc.close()

	writeMorphDict(morph_dict, morph_dict_file)
	writeChineseToMorphIDDict(map_chinese_to_id, chinese_to_morphID_file)	
# for encoded_word,line in encoded_segmentations.items():
# 	#fobj_enc.write("".join(sequence) + "\n")
# 	fobj_train_enc.write(encoded_word + "\n")
# 	fobj_gldstd_enc.write(encoded_word + " " + line + "\n")
# fobj_gldstd_enc.close()
#fobj_train_ori = codecs.open(original_training_filename, 'w', encoding='utf8')
####### STAGE 4 #######


# io = morfessor.MorfessorIO()
# train_data = list(io.read_corpus_file(control_training_filename))
# #model_types = morfessor.BaselineModel()
# m1 = morfessor.BaselineModel()
# m1.load_data(train_data)
# m1.train_batch()
# segmentations = m1.get_segmentations()
# io.write_segmentation_file(segmentations, control_segm_filename)

# goldstd_data = io.read_annotations_file(control_gldstd_filename)
# ev = morfessor.MorfessorEvaluation(goldstd_data)
# results_control = ev.evaluate_model(m1)

# encoded_train_data = list(io.read_corpus_file(encoded_training_filename))
# m2 = morfessor.BaselineModel()
# m2.load_data(encoded_train_data)
# m2.train_batch()
# segmentations = m2.get_segmentations()
# io.write_segmentation_file(segmentations, chinese_segm_filename)

# encoded_gldstd_data = io.read_annotations_file(encoded_gldstd_filename)

#ev = morfessor.MorfessorEvaluation(encoded_gldstd_data)
# results_symbols = ev.evaluate_model(m2)

# print "Control Results:"
# print results_control

# print "\n"
# print "Symbols Results:"
# print results_symbols

# print "results data type:", type(results_control)

#fobj_eval = codecs.open(eval_filename, 'w', encoding='utf8')
#for 
# for model in models:
#model.train_batch()

# goldstd_data = io.read_annotations_file(gldstd_filename)
# ev = morfessor.MorfessorEvaluation(goldstd_data)
#results = [ev.evaluate_model(m) for m in models]

# wsr = morfessor.WilcoxonSignedRank()
# r = wsr.significance_test(results)
# WilcoxonSignedRank.print_table(r)
# ev = morfessor.MorfessorEvaluation(goldstd_data)
# results = [ev.evaluate_model(m) for m in models]

# wsr = morfessor.WilcoxonSignedRank()
# r = wsr.significance_test(results)
# WilcoxonSignedRank.print_table(r)

if __name__ == '__main__':
	cluster_centroids_filename = sys.argv[1]
	#basename = cluster_centroids_filename.split(".")[0]
	cluster_membership_filename = sys.argv[2]
	#control_training_filename = sys.argv[3]
	#wordlist_filename = sys.argv[3]
	originals_dir = sys.argv[3]
	covered_dir = sys.argv[4]
	output_dir = sys.argv[5]
	four_stages(cluster_centroids_filename, cluster_membership_filename, originals_dir, covered_dir, output_dir)