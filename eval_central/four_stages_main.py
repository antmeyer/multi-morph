import sys, codecs, unicodedata, morfessor, regex as re
import stage1_pda as stage1, stage2

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
training_filename = sys.argv[3]
gldstd_filename = sys.argv[4]

####### STAGE 1 ####### 
morph_dict = stage1.main(cluster_centroids_filename)
####### STAGE 2 ####### 
word_segmentations_dict = stage2.main(morph_dict, cluster_membership_filename)

####### STAGE 3 ####### 
chinese_char_mapping = {}
encoded_segmentations = {}
for ID in morph_dict.keys():
	chinese_char_mapping[ID] = get_chinese_char(int(ID))

io = morfessor.MorfessorIO()
train_data = list(io.read_corpus_file(training_filename))
model_types = morfessor.BaselineModel()

model.load_data(train_data)
model.train_batch()

for model in models:
    model.train_batch()

goldstd_data = io.read_annotations_file(gldstd_filename)
ev = morfessor.MorfessorEvaluation(goldstd_data)
results = [ev.evaluate_model(m) for m in models]

wsr = morfessor.WilcoxonSignedRank()
r = wsr.significance_test(results)
WilcoxonSignedRank.print_table(r))
ev = morfessor.MorfessorEvaluation(goldstd_data)
results = [ev.evaluate_model(m) for m in models]

wsr = morfessor.WilcoxonSignedRank()
r = wsr.significance_test(results)
WilcoxonSignedRank.print_table(r)





