#!/usr/bin/env python
# -*- coding: utf-8 -*-
import re, sys, codecs

reload(sys)  
sys.setdefaultencoding('utf8')
UTF8Writer = codecs.getwriter('utf8')
sys.stdout = UTF8Writer(sys.stdout)
sys.stderr = UTF8Writer(sys.stderr)

######## LAST-MINUTE EDITS ###########

######################################
# goldstd_filename = sys.argv[1]
accented_filename = sys.argv[1]
# wordlist_filename = sys.argv[3]

fobj_acc = codecs.open(accented_filename, "r", encoding='utf8')
lines = fobj_acc.readlines()

# goldstd_filename = "gold_Rsegs.txt"
# fobj_gold = codecs.open(goldstd_filename, "w", encoding='utf8')

#fobj_wl = codecs.open(wordlist_filename, "r", encoding='utf8')

# wl_lines = fobj_wl.readlines()
# if wl_lines[0][0] == "#":
# 	wl_lines.pop(0)
# ori_words = []
mod_words = {}
# missing_in_mod = []
# missing_in_ori = []
# for wl_line in wl_lines:
# 	ori_words.append(wl_line.replace("\n", ""))
# for ow in ori_words:
# 	sys.stderr.write("***" + ow + "\n")
for line in lines:
	#remove accents
	newline = line.replace(u"\u00ED", "i")
	newline = newline.replace(u"\u00E9", "e")
	newline = newline.replace(u"\u00E1", "a")
	newline = newline.replace(u"\u00F3", "o")
	newline = newline.replace(u"\u00FA", "u")
	newline = newline.replace("\n", "")
	#print "*", newline
	#print newline.split("\t")
	items = newline.split()
	ori_word = items.pop(0)
	segments = list(items)
	ori_word = ori_word.replace("^", "")
	new_segments = []
	for segment in segments:
		new_segments.append(segment.replace("^", ""))
	seg_str = " ".join(new_segments)


	if mod_words.has_key(ori_word):
		if seg_str in mod_words[ori_word]: pass
		else: mod_words[ori_word].append(seg_str)
	else:
		mod_words[ori_word] = [seg_str]

for w,seg_list in sorted(mod_words.items()):
	#fobj_train.write(w + "\n")
	seg_str = ",".join(seg_list)
# 	#gold_line = w + 
	sys.stdout.write(w + " " + seg_str + "\n")

# for ori_word in ori_words:
# 	if ori_word in mod_words.keys(): pass
# 	else:
# 		missing_in_mod.append(ori_word)
# newlines = []
# for word,segs in sorted(mod_words.items()):
# 	newlines.append(word + "\t" + ",".join(segs) + "\n")

# fobj_mim = codecs.open("missing.txt", "w", encoding='utf8')
# fobj_mim.write("MISSING IN MOD:"+ "\n")
# for word in missing_in_mod:
# 	fobj_mim.write(word + "\n")
# fobj_mim.write("\nMISSING IN ORI:"+ "\n")
# for word in missing_in_ori:
# 	fobj_mim.write(word + "\n")
# fobj_mim.close()

# for line in newlines:
# 	sys.stdout.write(line)

# sys.stdout.write()
# 	mod_words[word] 
# 		include=False
# 		if word in ori_words:
# 			if word not in mod_words:
# 				mod_words.append(word)
# 				mod_lines
# 			newlines.append(newline)
# 	for ori_word in ori_words:
# 		if ori_word in mod_words: pass
# 		else:
# 			missing_in_mod.append(ori_word)