import regex as re
#import sys, codecs
import sys
#import activeCentroidFeatures as acf
import active_centroid_features as acf
from get_active import *
#from get_active import read_lists
from stage1_pda import *
reload(sys)  
sys.setdefaultencoding('utf8')
# UTF8Writer = codecs.getwriter('utf8')
# sys.stdout = UTF8Writer(sys.stdout)
# sys.stderr = UTF8Writer(#sys.stderr)

pat_pos = ur"\@"
re_pos = re.compile(pat_pos, re.UNICODE)
pat_pos_pre = ur"@\[[0-9]\]"
pat_pos_suf = ur"@\[\-[0-9]\]"
re_pos_pre = re.compile(pat_pos_pre, re.UNICODE)
re_pos_suf = re.compile(pat_pos_suf, re.UNICODE)
pat_prec = ur"\<"
re_prec = re.compile(pat_prec, re.UNICODE)
pat_bi = ur"\+"
re_bi = re.compile(pat_bi, re.UNICODE)
pat_seq = ur"[<+]"
re_seq = re.compile(pat_seq, re.UNICODE)

def main(filename):
	centroids_featuresAndValues = {0: {"k<t":1.0, "k<a":0.9, "t<b":1, "a<b":0.8},
		1 : {"d@[-4]":1, "i@[0]":1, "i@[-2]":1, "m@[-1]":1},
		#1: {"a<i":1, "i<t":1, "i@[-2]":1}}
		2: {"i<t":1.0, "i@[-2]":1.0, "t<i":1.0},
		3: {"b<i":1, "a<i":1, "i<m":1, "i@[-2]":1}}
	for cluster_ID,cluster_dict in centroids_featuresAndValues.items():
		fw_objects = []
		print "fw_pairs:",
		for feature,weight in sorted(cluster_dict.items(), key=lambda x: x[1], reverse=True):
	#for feature,weight in sorted(centroids_featuresAndValues.items()):
			print feature,weight, ";",
			if re_pos_pre.search(feature):
				fwp = FWP_pos_front(feature,weight)
				fw_objects .append(fwp)
			elif re_pos_suf.search(feature):
				fwp = FWP_pos_back(feature,weight)
				fw_objects.append(fwp)
			elif re_prec.search(feature):
				fwp = FWP_prec(feature,weight)
				fw_objects.append(fwp)
		print ""
		fw_objs_srtd = partition_feat_objs(fw_objects)
		print "fw_objs_srtd:",
		for obj in fw_objs_srtd:
			print obj.get_feature(), obj.get_weight(), ";",
		print ""
		# Each vector of fw_objects is a centroid vector. That is, it corresponds to exactly one cluster.
		# There, each such vector corresponds to exactly one morph. Initially, however, we do not know
		# the morph's type. That is, we don't know wheter it is a prefix morph, a stem morph, or a suffix morph.
		# We therefore develop all three types, and select the one with the higest average weight.

		# Initialize all three morph objects on the first feature-weight object:
		print "FWPs categorized:",
		morph_prefix = MWP()
		morph_suffix = MWP()
		morph_stem = MWP()
		fwp = fw_objs_srtd.pop(0)
		print fwp.get_feature(),
		if fwp.get_feature_type() != "pos_back":
			try: morph_prefix = MWP_prefix(fwp)
			except AttributeError: pass
		try: morph_stem = MWP_stem(fwp)
		except AttributeError: pass
		if fwp.get_feature_type() != "pos_front":
			try: morph_suffix = MWP_suffix(fwp)
			except AttributeError: pass
		for fwp in fw_objs_srtd:
			print fwp.get_feature(),
			try: morph_prefix.update(fwp)
			except AttributeError: pass
			try: morph_stem.update(fwp)
			except AttributeError: pass
			try: morph_suffix.update(fwp)
			except AttributeError: pass
		print ""
		print "morph_prefix:", morph_prefix.get_morph()
		print "morph_stem:", morph_stem.get_morph()
		print "morph_suffix:", morph_suffix.get_morph()



if __name__ == "__main__":
	filename = sys.argv[1]
	morph_dict = main(filename)
	# print "MORPH_DICT:"
	# for cluster_ID in morph_dict.keys():
	# 	print cluster_ID, morph_dict[cluster_ID]