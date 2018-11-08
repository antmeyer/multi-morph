#!/usr/bin/env python

import sys, codecs, unicodedata, morfessor, re, pprint
import stage1_alt as stage1 
import stage2 as stage2
from best_path import *
#import sys, codecs, re
reload(sys)  
sys.setdefaultencoding('utf8')
UTF8Writer = codecs.getwriter('utf8')
sys.stdout = UTF8Writer(sys.stdout)
sys.stderr = UTF8Writer(sys.stderr)

UTF8Writer = codecs.getwriter('utf8')
sys.stdout = UTF8Writer(sys.stdout)

def get_chinese_char(i):
	# The integer '19968' marks the starting point of the unicode Chinese character block.
	return unichr(i + 19968)

def writeMorphDict(morph_dict):
	fobj = codecs.open("morph_dict.txt", 'w', encoding='utf8')
	for morphID,morph_wt_obj in morph_dict.items():
		morph_obj = morph_wt_obj[-1]
		letter_seq = morph_obj.get_letters()
		fobj.write(str(morphID) + "\t" + "".join(letter_seq) + "\n")
	fobj.close()

def writeChineseToMorphIDDict(chinese_dict):
	fobj = codecs.open("chinese_to_id_dict.txt", 'w', encoding='utf8')
	for chinese_char,morphID in chinese_dict.items():
		#morph_obj = morph_wt_obj[-1]
		#letter_seq = morph_obj.get_letters()
		fobj.write(str(chinese_char) + "\t" + str(morphID) + "\n")
	fobj.close()
#INPUT:
## 1: A file ending in ".mc.C_vals" (see eval_stage2 directory)
## 2: A file ending in ".mc.clusters" (see eval_stage2 directory)
## 3: Morfesser BS
## 4: Morfessor BS
# 2_2_K6000_N12222_basic_180626_18-27_k-1000.C_vals 2_2_K6000_N12222_basic_180626_18-27_k-1000.clusters

cluster_centroids_filename = sys.argv[1]
basename = cluster_centroids_filename.split(".")[0]
cluster_membership_filename = sys.argv[2]
control_training_filename = sys.argv[3]
control_gldstd_filename = sys.argv[4]
basename = cluster_centroids_filename.split(".")[0]
trn_basename = control_training_filename.split(".")[0]
gld_basename = control_gldstd_filename.split(".")[0]
encoded_training_filename = trn_basename + "_symbols.txt"
encoded_gldstd_filename = gld_basename + "_symbols.txt"
fobj_train = codecs.open(control_training_filename, 'r', encoding='utf8')
#control_training_filename = "morfessor_TR_training.txt"
#fobj_train_enc = codecs.open(encoded_training_filename , 'w', encoding='utf8')
eval_filename = basename + "_extrinsic_eval.txt"

# 	fobj_new_train.write(line)
chinese_segm_filename = basename + ".chinese_segm"

####### STAGE 1 ####### 
morph_dict = stage1.main(cluster_centroids_filename)
# print "from 4 stages main, stage 1:"
# for key,val in morph_dict.items():
# 	print key, "-->", val[-1].get_pattern()
####### STAGE 2 ####### 
#word_segmentations_dict = stage2.main(morph_dict, cluster_membership_filename)
charToMorphAlignments = stage2.main(morph_dict, cluster_membership_filename)
trn_lines = fobj_train.readlines()
if trn_lines[0][0] == "#":
	trn_lines.pop(0)
for line in trn_lines:
	word = line.replace("\n", "")
	paths_obj = CompressedPaths(morph_dict, charToMorphAlignments, word)
# print "from 4 stages main:, stage 2:"
# for key,val in word_segmentations_dict.items():
# 	print key, "-->", val
# print word_segmentations_dict
###### STAGE 3 ####### 
map_id_to_chinese = {}
map_chinese_to_id = {}
encoded_segmentations = {}
IDs = morph_dict.keys()
#IDs.extend(letter_dict.keys())

# for morphID in morph_dict.keys():
# 	map_id_to_chinese[morphID] = get_chinese_char(int(morphID))
for morphID in IDs:
	chinese_char = get_chinese_char(int(morphID))
	map_id_to_chinese[morphID] = get_chinese_char(int(morphID))
	map_chinese_to_id[chinese_char] = morphID
	#print map_id_to_chinese[morphID]
encoded_gldstd_filename = "morfessor_gldstd_symbols.txt"
#dummy_id = 1001
#encoded_strings = []
#print "PPRINT WORD_SEGMENTATIONS DICT"
#pprint.pprint(word_segmentations_dict.items())
encoded_lines = []
encoded_word = u""
numcntr = 0
for word,morphID_sequence_list in word_segmentations_dict.items():
	
	print "aaaaa", morphID_sequence_list
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
	encoded_word = u""
	encoded_strings = []
	for morphID_sequence in morphID_sequence_list[0:1]:
		print "bbbbb:", morphID_sequence
		#print "bbbbb" + str(numcntr) + ":", morphID_sequence
		#sys.stderr.write(word + "; seq: " + unicode(morphID_sequence) + u"\n")
		#temp = []
		encoded_word = u""
		for morphID in morphID_sequence:
			#sys.stderr.write(morphID + " ")
			try: 
				int_ID = int(morphID)
				print "++++++++", type(morphID), "morphID:", morphID, int_ID
				#sys.stderr.write(str(int_ID))
				encoded_word += map_id_to_chinese[int_ID]
				#sys.stderr.write(encoded_word + ", ")
			except KeyError:
				sys.stdout.write("KEY_ERROR: MORPH_ID: " + str(morphID) + " !!!\n")

			except TypeError:
				sys.stdout.write("TYPE_ERROR: MORPH_ID: " + str(morphID) + " !!!\n")
				if type(u"a") == type(morphID) or type("a") == type(morphID):
					encoded_word += morphID
					# choose an unused integer to serve as a 'dummy ID' for a 'None'-type morph-ID.
				#encoded_word += get_chinese_char(dummy_id)
			except ValueError: #continue
				sys.stdout.write("VALUE_ERROR: MORPH_ID: " + str(morphID) + " !!!\n")
				if type(u"a") == type(morphID) or type("a") == type(morphID):
					encoded_word += morphID
					#dummy_id += 1
					#continue
			#temp.append(encoded_word)
		sys.stdout.write(encoded_word + "\n")	
		encoded_strings.append(encoded_word)
		#encoded_lines.append(encoded_word + "\n")
		#encoded_words.append(encoded_word)
	encoded_line = ",".join(encoded_strings)
	encoded_lines.append(encoded_line)
	#encoded_segmentations[encoded_word] = encoded_line
#sys.stderr.write("\n")
	numcntr += 1
fobj_train_enc = codecs.open(encoded_training_filename, 'w', encoding='utf8')
#fobj_gldstd_enc = codecs.open(encoded_gldstd_filename, 'w', encoding='utf8')


for encoded_line in encoded_lines:
	#sys.stderr.write(encoded_line + "\n")
	fobj_train_enc.write(encoded_line + "\n")
fobj_train_enc.close()

writeMorphDict(morph_dict)
writeChineseToMorphIDDict(map_chinese_to_id)	
# for encoded_word,line in encoded_segmentations.items():
# 	#fobj_enc.write("".join(sequence) + "\n")
# 	fobj_train_enc.write(encoded_word + "\n")
# 	fobj_gldstd_enc.write(encoded_word + " " + line + "\n")
# fobj_gldstd_enc.close()
#fobj_train_ori = codecs.open(original_training_filename, 'w', encoding='utf8')
####### STAGE 4 #######


io = morfessor.MorfessorIO()
train_data = list(io.read_corpus_file(control_training_filename))
#model_types = morfessor.BaselineModel()
m1 = morfessor.BaselineModel()
m1.load_data(train_data)
m1.train_batch()
segmentations = m1.get_segmentations()
io.write_segmentation_file(segmentations, control_segm_filename)

goldstd_data = io.read_annotations_file(control_gldstd_filename)
ev = morfessor.MorfessorEvaluation(goldstd_data)
results_control = ev.evaluate_model(m1)


encoded_train_data = list(io.read_corpus_file(encoded_training_filename))
m2 = morfessor.BaselineModel()
m2.load_data(encoded_train_data)
m2.train_batch()
segmentations = m2.get_segmentations()
io.write_segmentation_file(segmentations, chinese_segm_filename)

encoded_gldstd_data = io.read_annotations_file(encoded_gldstd_filename)
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