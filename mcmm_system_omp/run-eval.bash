#!/bin/bash
# run-eval.bash
#
# define parameters for number-of-data-points, (pixel-row) width, input file name, and output file name
#
DIR=
DIR_FLAG=0
DIR_EVAL=
DIR_EVAL_FLAG=0
KVAL=
K_FLAG=0
K_INTERVAL=
K_INTERVAL_FLAG=0
AFFIXLEN=
AFFIXLEN_FLAG=0
DIS=
PRECSPAN=
PRECSPAN_FLAG=0
INPUT_CORPUS=
INPUT_CORPUS_FLAG=0
PREFIX0="/Users/anthonymeyer/Development/multimorph"
PREFIX="/Users/anthonymeyer/Development/multimorph/mcmm_results"
#PREFIX0="~/Development/multimorph"
#PREFIX="~/Development/multimorph/mcmm_results"
# PREFIX0="/N/u/antmeyer/BigRed2/mcmm/multimorph"
# PREFIX="/N/u/antmeyer/BigRed2/mcmm/multimorph/mcmm_results"
TIME=`eval date +"%Y-%m-%d_%H-%M"`

while getopts "r:o:K:l:a:d:I:" OPTION
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
	K)
		KVAL="$OPTARG"
		K_FLAG=1
		;;
	l)
		K_INTERVAL="$OPTARG"
		K_INTERVAL_FLAG=1
		;;
	a)
		AFFIXLEN="$OPTARG"
		AFFIXLEN_FLAG=1
		;;
	d)
		DIS="$OPTARG"
		PRECSPAN_FLAG=1
		;;
	I)
		INPUT_CORPUS_FLAG=1
		INPUT_CORPUS="$OPTARG"
		;;
	\?)	
		echo "Usage: %s: [ -r input directory ] [ -o output directory ] [ -K number of clusters ] [ -a input file ] [ -d output file ] args\n" $(basename $0) >&6
		exit 2
		;;
	esac
done
shift $(($OPTIND - 1))

if [ "$DIR_FLAG" == 0 ]
then
	DIR="."
fi

if [ "$DIR_EVAL_FLAG" == 0 ]
then
	DIR_EVAL="$DIR"_eval
fi

if [ "$K_FLAG" == 0 ]
then
	KVAL=".*"
fi
bigK=`echo ${KVAL##* }`

if [ "$AFFIXLEN_FLAG" == 0 ]
then
	AFFIXLEN=".*"
fi

if [ "$PRECSPAN_FLAG" == 0 ]
then
	PRECSPAN=".*"
else
	#PRECSPAN="x\-""($DIS)""\-y"
	PRECSPAN="$DIS"
fi

if [ "$INPUT_CORPUS_FLAG" == 0 ]
then
	INPUT_CORPUS="$PREFIX0""/""hebrewWords.txt"
fi

if [ -d "$DIR_EVAL" ]; then
	echo "$DIR_EVAL exists. Thanks!"
	CONTENTS=`ls $DIR_EVAL`
	if [ ${#CONTENTS} -gt 0 ]; then
		for FILE in $DIR_EVAL/*; do
			rm $FILE
		done
	fi
else
	mkdir "$DIR_EVAL"
fi

echo "^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
echo "run-eval.bash" 
echo "DIR = $DIR"
echo "DIR_EVAL = $DIR_EVAL"
echo "^^^^^^^^^^^^^^^^^^^^^^^^^^^^"

# COUNTER=0
# while [ $COUNTER -lt $KVAL ]; do
# COUNTER=$(($COUNTER + $K_INTERVAL))
#for F1 in `ls $DIR/*`; do
echo "*****************************************"
echo "*****************************************"
echo "************** RUN EVAL *****************"
echo "*****************************************"
echo "*****************************************"
echo ""
for F1 in `ls $DIR`; do
	echo "*** run-eval; for loop; F1: $F1"
# 	for i in "${arr[@]}"; do
# 	echo "*** run-eval; STD = ${i}"
	#if [[ "$F1" =~ ^"$DIR"\/[0-1][0-9]\-[0-3][0-9]\-[1-2][0-9]{3}_N\-6888_K\-"$K"_affixlen\-["$AFFIXLEN"]_$PRECSPAN && "$F1" =~ (\.output_trans)$ ]]
		#if [[ "$F1" =~ ^$DIR\/($AFFIXLEN)_($PRECSPAN)_K\-($KVAL) && "$F1" =~ K@($COUNTER)(\.transoutput)$ ]]
	#if [[ "$F1" =~ ^$DIR\/($AFFIXLEN)_($PRECSPAN)_(0|1)_K\-($KVAL) && "$F1" =~ \.transoutput$ ]]; then
	#if [[ "$F1" =~ ^($AFFIXLEN)_($PRECSPAN)_(0|1)_K\-($KVAL) && "$F1" =~ \.transoutput$ ]]; then
	if [[ "$F1" =~ \.transoutput$ ]]; then
# 	if [[ "$F1" =~ ^($DIR)\/($AFFIXLEN)_($PRECSPAN)_(0|1)_K\-($KVAL)(.*) && "$F1" =~ (.*)\.(m[cr][cr]?)\.(transoutput)$ ]]; then
	#if [[ "$F1" =~ ^($AFFIXLEN)_($PRECSPAN)_(0|1)_K\-($KVAL) && "$F1" =~ \.transoutput$ ]]; then
		#echo ""
		#PREFIX="/Users/anthonymeyer/Documents/qual_paper_2/code/mcmm-cython"
			#rest: /mcmm_results/<$DIR>/<$name>
		#base=`echo "$F1" | cut -d '.' -f1`
		#echo "*** run-eval; base = ${base}"
		name=`echo "$F1" | cut -d '.' -f1`
		#echo "*** run-eval; name = $name"
		interval=`echo "$F1" | cut -d '.' -f2`
		STD=`echo "$F1" | cut -d '.' -f3`
		#if [ "${STD}" == "${i}" ]; then
		#echo "*** run-eval; interval = $interval"
		#echo "*** run-eval; STD = $STD"
		#name=`echo "$base" | cut -d '/' -f10`
		#name=""
		#echo "*** run-eval; name = $name"
		F_eval="$name"."$interval"."$STD".eval
		#echo "*** run-eval; I'm here! NAME = ${name}"
		#F_eval="$DIR_EVAL""/""$F_eval"
		#echo "*** run-eval; F_eval = $F_eval"
		touch "$DIR_EVAL""/""$F_eval" 
		python clustering_eval.py "$DIR""/""$F1" "$INPUT_CORPUS" > "$DIR_EVAL""/""$F_eval"
		#fi
		#rm "$F1"
	fi
	#done
done
#done
