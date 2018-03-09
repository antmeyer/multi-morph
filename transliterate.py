#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os,sys,re

# default transliteration direction: heb2eng

def clusterWords(clusterStr):
    """takes as input a single cluster's member words (perhaps with activities) cluster activities.
    writes to stdout the same words, but with each word on a new line.
    If there cluster activities in the original list, discard those.
    This function's purpose is to prepare the input for MILA (the
    morphological analyzer)."""
    clusterStr = clusterStr.replace("\n", "")
    clusterStr = clusterStr.replace("\r", "")
    outerList = clusterStr.split(", ")
    wordsStr = ""
    for item in outerList:
        pair = item.split(" ")
        wordsStr += pair[0] + "\n"
    return wordsStr

def clusterWords2(clusterStr):
    clusterStr = clusterStr.replace("\n", "")
    clusterStr = clusterStr.replace("\r", "")
    words = clusterStr.split(", ")
    return "\n".join(words)
    

def clusterActivities(clusterStr):
    """takes as input single cluster's membership list, which is a string.
    writes to stdout a list consisting of each members activity level.
    Each activity is printed to a new line."""
    clusterStr = clusterStr.replace("\n", "")
    clusterStr = clusterStr.replace("\r", "")
    outerList = clusterStr.split(", ")
    for item in outerList:
        pair = item.split(" ")
        activityStr = pair[1].lstrip("(")
        activityStr = activityStr.rstrip(")")
        #activities.append(activityStr)
        sys.stdout.write(activityStr + "\n")        
    
def heb2eng(hebString):
    engString = hebString.replace("א", "a")
    engString = engString.replace("ב", "b")
    engString = engString.replace("ג", "g")
    engString = engString.replace("ד", "d")
    engString = engString.replace("ה", "h")
    engString = engString.replace("ו", "w")
    engString = engString.replace("ז", "z")
    engString = engString.replace("ח", "x")
    engString = engString.replace("ט", "v")
    engString = engString.replace("י", "i")
    engString = engString.replace("כ", "k")
    engString = engString.replace("ך", "k")
    engString = engString.replace("ל", "l")
    engString = engString.replace("מ", "m")
    engString = engString.replace("ם", "m")
    engString = engString.replace("נ", "n")
    engString = engString.replace("ן", "n")
    engString = engString.replace("ס", "s")
    engString = engString.replace("ע", "y")
    engString = engString.replace("פ", "p")
    engString = engString.replace("ף", "p")
    engString = engString.replace("צ", "c")
    engString = engString.replace("ץ", "C")
    engString = engString.replace("ק", "q")
    engString = engString.replace("ר", "r")
    engString = engString.replace("ש", "e")
    engString = engString.replace("ת", "t")
    return engString

def eng2heb_1(engString):
    engString = engString.replace("k ", "K ")
    engString = engString.replace("k\n", "K\n")
    engString = engString.replace("k,", "K,")
    
    engString = engString.replace("m ", "M ")
    engString = engString.replace("m\n", "M\n")
    engString = engString.replace("m,", "M,")
    
    engString = engString.replace("n ", "N ")
    engString = engString.replace("n\n", "N\n")
    engString = engString.replace("n,", "N,")
    
    engString = engString.replace("c ", "C ")
    engString = engString.replace("c\n", "C\n")
    engString = engString.replace("c,", "C,")
    
    engString = engString.replace("p  ", "P ")
    engString = engString.replace("p\n", "P\n")
    engString = engString.replace("p,", "P,")
    return engString

def eng2heb_2(engString):
    hebString = engString.replace("a", "א")
    hebString = hebString.replace("b", "ב")
    hebString = hebString.replace("g", "ג")
    hebString = hebString.replace("d", "ד")
    hebString = hebString.replace("h", "ה")
    hebString = hebString.replace("w", "ו")
    hebString = hebString.replace("z", "ז")
    hebString = hebString.replace("x", "ח")
    hebString = hebString.replace("v", "ט")
    hebString = hebString.replace("i", "י")
    hebString = hebString.replace("k", "כ")
    hebString = hebString.replace("K", "ך")
    hebString = hebString.replace("l", "ל")
    hebString = hebString.replace("m", "מ")
    hebString = hebString.replace("M", "ם")
    hebString = hebString.replace("n", "נ")
    hebString = hebString.replace("N", "ן")
    hebString = hebString.replace("s", "ס")
    hebString = hebString.replace("y", "ע")
    hebString = hebString.replace("p", "פ")
    hebString = hebString.replace("P", "ף")
    hebString = hebString.replace("c", "צ")
    hebString = hebString.replace("C", "ץ")
    hebString = hebString.replace("q", "ק")
    hebString = hebString.replace("r", "ר")
    hebString = hebString.replace("e", "ש")
    hebString = hebString.replace("t", "ת")
    return hebString

def transLine(line):
    newString = transliterateHeb2Eng(line)
    newString = newString.replace("\n", "")
    newString = newString.replace("\r", "")
    #newString = newString.replace(".", " .")
    #newString = newString.replace("?", " ?")
    #newString = newString.replace("!", " !")
    #newString = newString.replace(",", " , ")
    newString = newString.rstrip()
    newString = newString.lstrip()
    lineItems = newString.split()
    newLine = " ".join(lineItems)
    newLine = newLine + "\n"
    return newLine

def main(inFileName):
    #sys.stderr.write("\ninFileName = " + inFileName + "\n")
    inFileObj = open(inFileName, "r")
    oldLines = inFileObj.readlines()
    #sys.stderr.write("\noldLines[2] = " + str(oldLines[2]) + "\n")
    #sys.stderr.write("\noldLines[3] = " + str(oldLines[3]) + "\n")
    inFileObj.close()
    for line in oldLines:
    	sys.stdout.write(heb2eng(line))

if __name__ == "__main__":
    main(sys.argv[1])
