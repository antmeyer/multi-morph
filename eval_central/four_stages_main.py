import sys, codecs, unicodedata, morfessor, regex as re
import stage1_alt as stage1 
import stage2 as stage2

UTF8Writer = codecs.getwriter('utf8')
sys.stdout = UTF8Writer(sys.stdout)

def get_chinese_char(i):
	# The integer '19968' marks the starting point of the unicode Chinese character block.
	return unichr(i + 19968)

#INPUT:
## 1: A file ending in ".mc.C_vals" (see eval_stage2 directory)
## 2: A file ending in ".mc.clusters" (see eval_stage2 directory)
## 3: Morfesser BS
## 4: Morfessor BS
cluster_centroids_filename = sys.argv[1]
cluster_membership_filename = sys.argv[2]
# training_filename = sys.argv[3]
# gldstd_filename = sys.argv[4]

####### STAGE 1 ####### 
morph_dict = stage1.main(cluster_centroids_filename)
####### STAGE 2 ####### 
word_segmentations_dict = stage2.main(morph_dict, cluster_membership_filename)

print "from 4 stages main:"
print word_segmentations_dict
####### STAGE 3 ####### 
# chinese_char_mapping = {}
# encoded_segmentations = {}
# for morphID in morph_dict.keys():
# 	chinese_char_mapping[morphID] = get_chinese_char(int(morphID))

# for key,morphID_sequence in word_segmentations_dict:
# 	encoded_segmentations[key] = []
# 	for morphID in morphID_sequence:
# 		encoded_segmentations.append(chinese_char_mapping[morphID])

# fobj_enc = codecs.open(encoded_training_filename, 'w', encoding='utf8')

# for key,sequence in encoded_segmentations.items():
# 	fobj_enc.write("".join(sequence) + "\n")


####### STAGE 4 #######
# io = morfessor.MorfessorIO()
# train_data = list(io.read_corpus_file(training_filename))
# #model_types = morfessor.BaselineModel()

# model.load_data(train_data)
# model.train_batch()
# goldstd_data = io.read_annotations_file(gldstd_filename)
# ev = morfessor.MorfessorEvaluation(goldstd_data)
# results = ev.evaluate_model(model)


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





