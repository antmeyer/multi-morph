#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os,sys,re,math,pprint

#Takes as input an eval or a "clusters" file, 
# and returns the results summary found in the file's two topmost lines.

inputFile = sys.argv[1]
sys.stderr.write("&&&&&&& " + inputFile + "\n")
fobj = open(inputFile, "r")
# get lines of file
lines = fobj.readlines()
dataFile = ""
dataRow = ""
items = ["",""]
firstChar = ""
#sys.stderr.write("\nLines: " + str(lines))
if len(lines) >= 2:
	for ndx in range(2):
		#sys.stderr.write("\nLine: " + lines[ndx] + "\n")
		try: firstChar = lines[ndx][0] 
		except IndexError:
			continue
		else:
			if firstChar == "#":
				#items.append(lines[ndx][1:])
				dataLine = lines[ndx][1:]
				dataLine = dataLine.replace("\r", "")
				dataLine = dataLine.rstrip("\n")
				dataLine = dataLine.rstrip()
				sys.stderr.write(dataLine + "\n")
				items[ndx] = dataLine

	dataFile = items[0]
	dataRow = items[1]
	#sys.stderr.write("******** dataFile: " + dataFile + "\n")
	#sys.stderr.write("******** dataRow:  " + dataRow + "\n")
	#sys.stdout.write(dataFile + "\t" + dataRow + "\n")
	sys.stdout.write(dataRow + " % " + dataFile + "\n")
