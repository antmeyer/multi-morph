#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os,sys,re,math,pprint
import random
from random import *
from StringIO import StringIO
import numpy
from numpy import *
from numpy.linalg import *
import time

def processFile(filename):
    """ Takes a (data) filename as input. <filename> is a text file of words, each
    separated by a newline. Outputs a python list of words.
    """
    fobj = open(filename, 'r')
    strings = list()
    for line in fobj.readlines():
        items = line.split()
        if len(items) < 1:
            continue
        string = items[0]
        pat = "\""
        if re.search(pat, string):
            continue
        string = string.replace("\n","")
        string = string.replace("\r","")
        #print string
        strings.append(string)
    fobj.close()
    return strings

def getWordsAndRoots(filename):
    fobj = open(filename, 'r')
    strings = list()
    for line in fobj.readlines():
    	#string = line.replace("\t", "  ")
    	string = line
        pat = "\"|0-9"
        if re.search(pat, string):
            continue
        string = string.replace("\n","")
        string = string.replace("\r","")
        #print string
        #sys.stderr.write(string + "\n")
        strings.append(string)
    fobj.close()
    return strings
        
def writeFile(filename, dataList):
    fobj = open(filename, 'w')
    for line in dataList:
	fobj.write(line + "\n")
	
def main(inputFile, numCharacters, numWords=0, alphabet="abgdhwzxviklmnsypcqret"):

    baseName = inputFile.split(".")[0]
    if numWords == 0:
    	str_N = "allWords"
    else:
    	str_N = str(numWords)
    print "alphabet =", alphabet, ";", "numWords =", str_N
    mcmmInputFile = baseName + "_" + str(numCharacters) + "_" + str_N + ".txt"
    #rootsFile = baseName + "_N-" + str_N + "_roots.txt"
    rootsFile = baseName +"_" + str(numCharacters) + "_" + str_N + "_roots.txt"
    if numCharacters < len(alphabet):
        charList = sample(list(alphabet), numCharacters)
    else:
        charList = list(alphabet)
    sys.stderr.write("charList = " + str(charList) + "\n")
    items = getWordsAndRoots(inputFile)
    words = list()
    wordsAndRoots = list()

    for item in items:
    	elems = item.split()
    	if len(elems) < 1:
    		continue
    	#sys.stderr.write(str(elems) + "\n")
    	word = elems[0]
    	if len(elems) > 1:
    		root = elems[1]
    	else:
    		root = ""
        include = True # this just initializes 'include'. 
                        # we will use it to filter out certain kinds of strings,
                        # such as those with only one letter (see next line).
        if len(word) < 2:
            include = False
        for i in range(len(word)):  # now we want to filter out words that contain
                                    # letters which are not in our (sub-)alphabet (i.e., 'charlist')
            if word[i] not in charList:
                include = False
                break
        if include:
            if word not in words:
                words.append(word)
                wordsAndRoots.append((word, root))
    # if numWords == 0:
	   #  numWords = len(words)
    #numWords = len(words)
    # Get a sample of size 'numWords' from the population 'wordsAndRoots'
    print "*** numWords =", numWords
    dataSample = sample(wordsAndRoots, numWords)
    #dataSample = sample(words, numWords)
    dataSample.sort()
    sys.stdout.write("#" + "".join(charList) + "\n")
    #for datum in dataSample:
	#	sys.stdout.write(datum + "\n")
    fobj_mcmm = open(mcmmInputFile, "w")
    fobj_mcmm.write("#" + "".join(charList) + "\n")
    fobj_roots = open(rootsFile, "w")
    for word, root in dataSample:
    	fobj_mcmm.write(word + "\n")
    	if root != "":
    		fobj_roots.write(word + "\t" + root + "\n")
    fobj_mcmm.close()
    
	
if __name__ == "__main__":
    # command line will have this:  python random_sublist.py  [inputFileName  alphabet  numChars  numWords]
    inputFileName = sys.argv[1]
    #alphabet = "abgdhwzxviklmnsypcqret"
    #alphabet = sys.argv[2]
    numChars = int(sys.argv[2])
    numWords = int(sys.argv[3])
    print "len sys.argv =", len(sys.argv)
    if len(sys.argv) > 4:
        alpha_str = sys.argv[4]
    else:
        alpha_str = "abgdhwzxviklmnsypcqret"
    print "len of alphabet =", len(alpha_str)
    main(inputFileName, numChars, numWords=numWords, alphabet=alpha_str)