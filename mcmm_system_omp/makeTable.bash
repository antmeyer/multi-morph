#!/bin/bash
# makeTable.bash
#

DIR=
DIR_FLAG=0
DIR_EVAL=
DIR_EVAL_FLAG=0

#DATE=$(date +"%m-%d-%Y")
TIME=`eval date +"%Y-%m-%d_%H-%M"`

while getopts "r:o:" OPTION
do
	case $OPTION in
	r)	
		DIR="$OPTARG"
		DIR_FLAG=1
		;;
	o)
		DIR_EVAL="$OPTARG"
		DIR_EVAL_FLAG=1
		;;
	\?)	
		echo "Usage: %s: [-k number of data points to generate] [-i input file ] [-o output file ] args\n" $(basename $0) >&6
		exit 2
		;;
	esac
done
shift $(($OPTIND - 1))

#echo "$DIR"
#echo "$DIR_EVAL"
if [ "$DIR_EVAL_FLAG" == 0 ]
then
	#DIR_EVAL="$DIR"_eval_2
	DIR_EVAL="$DIR"
fi

# for F1 in `ls $DIR/*`
# do
# # 	#if [[ "$F1" =~ (\.output_trans)$ && "$F1" =~ ^($DIR\/10\-)((08)|(09)|(10)|(11)|(12)|(13)|(14)|(15)|(16))(\-2013_N\-6888_K\-50) ]]
# # 	#if [[ "$F1" =~ (\.output_trans)$ && "$F1" =~ ^(experimentResults\/10\-15\-2013)_(.*)(affixlen\-0_x\-0\-y_precedence) ]]
# # 	if [[ "$F1" =~ (\.output_trans)$ ]]
# 	#echo "^""$DIR""\/[0-1][0-9]\-[0-3][0-9]\-[1-2][0-9]{3}_N\-6888_K\-""$K""_affixlen\-(""$AFFIXLEN"")_(""$PRECSPAN"")"
# 	#echo ^"$DIR"\/[0-1][0-9]\-[0-3][0-9]\-[1-2][0-9]{3}_N\-6888_K\-"$K"_affixlen\-["$AFFIXLEN"]_x\-"$PRECSPAN"\-y
# 	#if [[ "$F1" =~ ^"$DIR"\/[0-1][0-9]\-[0-3][0-9]\-[1-2][0-9]{3}_N\-6888_K\-"$K"_affixlen\-"$AFFIXLEN"_"$PRECSPAN" && "$F1" =~ (\.output_trans)$ ]]
# 	#echo "$PRECSPAN"
# 	#if [[ "$F1" =~ ^"$DIR"\\/[0-1][0-9]\\-[0-3][0-9]\-[1-2][0-9]{3}_N\\-6888_K\\-"$K"_affixlen\\-["$AFFIXLEN"]_x\\-"$PRECSPAN"\\-y ]]
# 	if [[ "$F1" =~ ^"$DIR"\/[0-1][0-9]\-[0-3][0-9]\-[1-2][0-9]{3}_N\-6888_K\-"$K"_affixlen\-["$AFFIXLEN"]_$PRECSPAN && "$F1" =~ (\.output_trans)$ ]]
# 	then
# 		#echo ""
# 		base=`echo "$F1" | cut -d '.' -f1`
# 		name=`echo "$base" | cut -d '/' -f2`
# 		echo "$F1"
# 		echo ""
# 		F_eval="$DIR_EVAL"/"$name"_eval.txt
# 		#echo "$F_eval"
# 		touch "$F_eval"
# 		python clustering_eval.py "$F1" > "$F_eval"
# 	fi
# done
TAB=table
TABLE="$DIR_EVAL"/$TAB.txt
TMP="$DIR_EVAL"/tmp.txt
if [ -f "$TABLE" ]
then
	rm "$TABLE"
fi
if [ -f "$TMP" ]
then
	rm "$TMP"
fi
#touch "$TMP"
touch "$TABLE"
#echo "$K$ & $\eta$ & $s$ & $\delta$ & purity & BP & BR & cov. & std." > "$TABLE"
echo "$""K$ & $""s$ & $\delta$ & Purity & BP & BR & Cov. & $""K^\prime$" > "$TABLE"
# For every eval file, do the following:
# 1. Run extractResult.py on it, printing its result lines to a temp file.
# 2. Look through the results directory to find the eval file's corresponding clusters file.
# 3. Rn extractResult.py on the clusters file, appending its result line(s) to the same line in the temp file.
# 4. Append "\\\\\n" to this temp-file line, so that a new line can be started.
for F1 in `ls $DIR_EVAL/*`; do
	#echo "F1: $F1"
	P1=`echo "$F1" | cut -d '.' -f1`
	#P2=`echo "$F1" | cut -d '.' -f2`
	#S1=`echo "$F1" | cut -d '.' -f3`
	#TOMATCH="$N1".clusters
	#echo "MAIN_N1: $MAIN_N1"
	#echo ""
	#echo "P2: $P2"
	MAIN_N1=`echo "$P1" | cut -d '/' -f2`
	#echo "MAIN_N1: $MAIN_N1"
	#echo ""
	if [ "$MAIN_N1" != "$TAB" ]; then
		python extractResult.py "$F1" >> "$TABLE"
	fi
	#TOMATCH1="$MAIN_N1".clusters
	#if [ "$MAIN_N1" == "table" -o "$MAIN_N1" == "tmp" ]
	#python extractResult.py "$F1" >> "$TMP"
# 	echo "%%%%%%%%%%1 $TOMATCH1"
# 	for F2 in `ls $DIR/*`
# 	do
# 		TOMATCH2=`echo "$F2" | cut -d '/' -f2`
# 		#echo "%%%%%%%%%%2 $TOMATCH2"
# 		if [ "$TOMATCH1" == "$TOMATCH2" ]
# 		then
# 			echo "match!!!"
# 			python extractResult.py "$F2" >> "$TMP"
# 		fi
# 	done
	#echo "\\\\\n" >> "$TMP"
done

# for F1 in `ls $DIR_EVAL/*`
# do
# 	if [[ "$F1" =~ (_Clusters.txt)$ && "$F1" ]]
# 	then
# 		python extractResult.py "$F1" >> "$TMP"
# 	fi
# done

#python compileResults.py "$TMP" > "$TABLE"
