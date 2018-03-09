#!/bin/bash
# mcmm.bash
#
# define parameters for number-of-data-points, (pixel-row) width, input file name, and output file name
#
NUMCLUSTERS=
K_INTERVAL=
INPUTFILE=
OUTPUTFILE=
AFFIXLEN=
PRECSPAN=
FEATURETYPE=
TEMPDIR=
EXPERI_TITLE=
K_FLAG=0
K_INTERVAL_FLAG=0
WIDTH_FLAG=0
INPUTFILE_FLAG=0
OUTPUTFILE_FLAG=0
AFFIXLEN_FLAG=0
PRECSPAN_FLAG=0
BIGRAMS=0
BIGRAMS_FLAG=0
TEMPDIR_FLAG=0
EXPERI_FLAG=0
M_FILE=
C_FILE=
M_FILE_FLAG=0
C_FILE_FLAG=0
USE_SQ=
USE_SQ_FLAG=0
OBJFUNC=
OBJFUNC_FLAG=0
QN=0
QN_FLAG=0
CG=0
CG_FLAG=0
MIXING_FUNC=
MIXING_FUNC_FLAG=0
ETA=0
ETA_FLAG=0
PREFIX1="/Users/anthonymeyer"
#PREFIX2="/Documents/qual_paper_2/code/mcmm-cython/mcmm_system"
PREFIX2="/Development/mcmm/mcmm_system"
STD=
while getopts "K:l:i:o:a:d:b:t:e:m:c:Q:j:y:z:M:E:" OPTION
do
	case $OPTION in
	K)	
		NUMCLUSTERS="$OPTARG"
		K_FLAG=1
		;;
	l)
		K_INTERVAL="$OPTARG"
		K_INTERVAL_FLAG=1
		;;
	i)	
		INPUTFILE="$OPTARG"
		INPUTFILE_FLAG=1
		;;
	o)	
		OUTPUTFILE="$OPTARG"
		OUTPUTFILE_FLAG=1
		;;
	a)	
		AFFIXLEN="$OPTARG"
		AFFIXLEN_FLAG=1
		;;
	d)
		PRECSPAN="$OPTARG"
		PRECSPAN_FLAG==1
		;;
	b)
		BIGRAMS="$OPTARG"
		BIGRAMS_FLAG==1
		;;
	t)
		TEMPDIR=$OPTARG
		TEMPDIR_FLAG=1
		#echo "tttt"
		#echo ""
		;;
	e)
		EXPERI_TITLE=$OPTARG
		EXPERI_FLAG=1
		#echo "tttt"
		#echo ""
		;;
	m)
		M_FILE="$OPTARG"
		M_FILE_FLAG=1
		;;
	c)
		C_FILE="$OPTARG"
		C_FILE_FLAG=1
		;;
	Q)
		USE_SQ="$OPTARG"
		USE_SQ_FLAG=1
		;;
	j)
		OBJFUNC="$OPTARG"
		OBJFUNC_FLAG=1
		;;

	y)
		QN="$OPTARG"
		QN_FLAG=1
		;;
	z)
		CG="$OPTARG"
		CG_FLAG=1
		;;
	M)
		MIXING_FUNC="$OPTARG"
		MIXING_FUNC_FLAG=1
		;;
	E)
		ETA="$OPTARG"
		ETA_FLAG=1
		;;
	\?)
		echo "Usage: %s: [-K number of data points to generate] [-i input file ] [-o output file ] args\n" $(basename $0) >&10
		exit 2
		;;
	esac
done
shift $(($OPTIND - 1))

# echo "^&^&^&^&^&^&^&^&^&^&^&^& mcmm_sp2.bash; tempdir_m: $TEMPDIR""_m"
# echo "^&^&^&^&^&^&^&^&^&^&^&^& mcmm_sp2.bash; tempdir_mc: $TEMPDIR""_mr"
# echo "^&^&^&^&^&^&^&^&^&^&^&^& mcmm_sp2.bash; tempdir_mc: $TEMPDIR""_mc"
# echo "^&^&^&^&^&^&^&^&^&^&^&^& mcmm_sp2.bash; tempdir_mcr: $TEMPDIR""_mcr"
# 
# tdm="$TEMPDIR""_m"
# tdmr="$TEMPDIR""_mr"
# tdmc="$TEMPDIR""_mc"
# tdmcr="$TEMPDIR""_mcr"

# CONTENTS=`ls $TEMPDIR`
# if [ ${#CONTENTS} -gt 0 ]
# then
# 	for FILE in `ls $TEMPDIR/*`
# 	do
# 		rm $FILE
# 	done
# fi
echo "$TEMPDIR"
echo "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&"
echo "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&"
echo "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&"
echo "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&"
echo "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&"
echo "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&"
echo "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&"
echo "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&"
echo "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&"
echo "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&"
echo "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&"

## declare an array variable
#declare -a arr=($tdm $tmdr $tdmc $tdmcr)
#declare -a arr=("m--" "m-r" "mc-" "mcr")
declare -a arr=("mc-")
# for i in "${arr[@]}"
# do
CONTENTS=`ls $TEMPDIR`
echo "$CONTENTS"
if [ ${#CONTENTS} -gt 0 ]
then
	for FILE in `ls $TEMPDIR/*`
	do
		rm $FILE
	done
fi
#done

if [ "$K_FLAG" == 0 ]
then
	NUMCLUSTERS=50
fi

if [ "$K_INTERVAL_FLAG" == 0 ]
then
	K_INTERVAL=5
fi

if [ "$AFFIXLEN_FLAG" == 0 ]
then
	AFFIXLEN="0"
fi

if [ "$PRECSPAN_FLAG" == 0 ]
then
	PRECSPAN="0"
fi

if [ "$BIGRAMS_FLAG" == 0 ]
then
	BIGRAMS="0"
fi

if [ "$M_FILE_FLAG" == 0 ]
then
	M_FILE="0"
fi

if [ "$C_FILE_FLAG" == 0 ]
then
	C_FILE="0"
fi

if [ "$USE_SQ_FLAG" == 0 ]
then
	USE_SQ=0
fi

if [ "$OBJFUNC_FLAG" == 0 ]
then
	OBJFUNC="log"
fi

if [ "$EXPER_FLAG" == 0 ]
then
	EXPER_TITLE="Use S and Q: $USE_SQ; Objective Function: $OBJFUNC"
fi

if [ "$QN_FLAG" == 0 ]
then
	QN=0
fi

if [ "$CG_FLAG" == 0 ]
then
	CG=0
fi

if [ "$MIXING_FUNC_FLAG" == 0 ]
then
	MIXING_FUNC="nor"
fi

if [ "$ETA_FLAG" == 0 ]
then
	ETA="default"
fi
if [ "$MIXING_FUNC" == "nor" ]
then
	ETA="none"
fi
echo "mcmm bash; BIGRAMS = $BIGRAMS"
echo "mcmm bash; BIGRAMS_FLAG = $BIGRAMS_FLAG"
# if [ "$K_FLAG" == 1 ]
# then
# 	python genExamples.py "$NUMBER" 3 "$INPUTFILE"
# 	python wrapper_wrapper.py "$INPUTFILE" "$OUTPUTFILE" 3
# else
#echo $TEMPDIR
echo "mcmm bash; MIXING FUNC: $MIXING_FUNC"
echo "mcmm bash; USE_SQ? $USE_SQ"
echo "mcmm bash; OBJFUNC? $OBJFUNC"
echo "mcmm bash; QN? $QN"
echo "mcmm bash; CG? $CG"
echo "***"
echo "***"
echo "***"
echo "*** INPUTFILE = ""$INPUTFILE"
echo "***"
echo "***"
echo "***"
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
if [ "$MIXING_FUNC" == "wwb" ]; then
	python wrapper_wrapper_wwb.py "$INPUTFILE" "$OUTPUTFILE" "$AFFIXLEN" "$PRECSPAN" "$BIGRAMS" "$NUMCLUSTERS" "$K_INTERVAL" "$TEMPDIR" "$EXPERI_TITLE" "$M_FILE" "$C_FILE" "$USE_SQ" "$OBJFUNC" "$QN" "$CG" "$MIXING_FUNC" "$ETA"
	
else
	python wrapper_wrapper_nor.py "$INPUTFILE" "$OUTPUTFILE" "$AFFIXLEN" "$PRECSPAN" "$BIGRAMS" "$NUMCLUSTERS" "$K_INTERVAL" "$TEMPDIR" "$EXPERI_TITLE" "$M_FILE" "$C_FILE" "$USE_SQ" "$OBJFUNC" "$QN" "$CG" "$MIXING_FUNC" "$ETA"
fi

MILA_DIR="$PREFIX1/Development/morphAnalyzer_v_1-0/jars/"
ANALYZER="${MILA_DIR}TextAnalyzer.jar"
#ANALYZER+="TextAnalyzer.jar"
DINFLECT=${MILA_DIR}
DINFLECT+="dinflections.data"
DPREFIXES=${MILA_DIR}
DPREFIXES+="dprefixes.data"
GIMATRIA=${MILA_DIR}
GIMATRIA+="gimatria.data"
MCMM_DIR="$PREFIX1$PREFIX2/$TEMPDIR"
# ptm="$PREFIX1$PREFIX2/$tdm"
# ptmr="$PREFIX1$PREFIX2/$tdmr"
# ptmc="$PREFIX1$PREFIX2/$tdmc"
# ptmcr="$PREFIX1$PREFIX2/$tdmcr"
#java -Xmx1024m -jar $ANALYZER FALSE $INPUT $OUTPUT $DINFLECT $DPREFIXES $GIMATRIA
maxBigK=0
# declare -a path_arr=($tdm $tmdr $tdmc $tdmcr)
echo ""
echo "*** BASH MCMM 1"
echo ""
CONTENTS=`ls $MCMM_DIR`
echo "******************"
echo "CONTENTS = ${CONTENTS}"
echo "******************"
if [ ${#CONTENTS} -eq 0 ]; then
	echo "No Result Files"
	exit
else
	#for FILE in "$TEMPDIR"/*; do
	for FILE in $TEMPDIR/*; do
		echo "mcmm bash 6; file = $FILE"
		#for each file, loop over each "std" to which $std $file is.
		#for i in "${arr[@]}"; do
		#for FILE in `ls $TEMPDIR/*`
		#PREFIX="/Users/anthonymeyer/Documents/qual_paper_2/code/mcmm-cython"
		MAIN=`echo "$FILE" | cut -d '/' -f2`
		echo "mcmm bash 7; main = $MAIN"
		NAME=`echo "$MAIN" | cut -d '.' -f1`
		echo "mcmm bash 8; name = $NAME"
		k=`echo "$MAIN" | cut -d '.' -f2`
		echo "mcmm bash 9; k = $k"
		bigK=`echo "$MAIN" | cut -d '.' -f3`
		echo "mcmm bash 10; bigK = $bigK"
		echo "mcmm bash 10.5; maxBigK = $maxBigK"
		if [ "$bigK" -gt "$maxBigK" ]; then
			maxBigK=$bigK
		fi
		STD=`echo "$MAIN" | cut -d '.' -f4`
		TYPE=`echo "$MAIN" | cut -d '.' -f5`
		if [ "${TYPE}" == "input" ] #&& [ "$STD" == "$i" ]
		then
			#echo "mcmm bash; MAIN = ${MAIN}"
			#INPUT="$PREFIX1$PREFIX2"/"${FILE}"
			#OUTPUT="$PREFIX1$PREFIX2"/"${NAME}.${k}.${bigK}.output"
			INPUT="$PREFIX1$PREFIX2/$TEMPDIR/${MAIN}"
			OUTPUT="$PREFIX1$PREFIX2/$TEMPDIR/${NAME}.${k}.${bigK}.${STD}.output"
			echo "mcmm bash 11; Input = $INPUT"
			echo "mcmm bash 12; Output = $OUTPUT"
			java -Xmx1024m -jar $ANALYZER FALSE $INPUT $OUTPUT $DINFLECT $DPREFIXES $GIMATRIA
		fi
		#done
	done
fi
echo ""
echo "*** BASH MCMM 2"
echo ""
COUNTER=0
LAST_INTERVAL=$(($maxBigK - $K_INTERVAL))
while [ "$COUNTER" -lt "$LAST_INTERVAL" ]; do
	COUNTER=$(($COUNTER + $K_INTERVAL))  #num=$(($num1 + $num2))
	echo "*** mcmm_bash; COUNTER = ${COUNTER}"
	for FILE in $TEMPDIR/*; do	
		echo "***********************************************"
		echo "*** mcmm_bash; ${FILE}"
		echo "***********************************************"
		#for i in "${arr[@]}"; do
		echo "   *** mcmm_bash; STD = ${i}"
		MAIN=`echo "$FILE" | cut -d '/' -f2`
		echo "mcmm bash 27; main = $MAIN"
		NAME=`echo "$MAIN" | cut -d '.' -f1`
		echo "mcmm bash 28; name = $NAME"
		k=`echo "$MAIN" | cut -d '.' -f2`
		bigK=`echo "$MAIN" | cut -d '.' -f3`
		STD=`echo "$MAIN" | cut -d '.' -f4`
		echo "mcmm bash 32; std = $STD"
		TYPE=`echo "$MAIN" | cut -d '.' -f5`
		echo "mcmm bash 32; type = $TYPE"
		#echo "     *** mcmm_bash; ${i} == ${STD}? ${FILE}"
		if [ "$TYPE" == "output" ] && [ "$bigK" == "$COUNTER" ] #&& [ "$STD" == "$i" ] 
		then
			# We need $bigK (one of the max-k intervals) to equal our interval counter
			OUTPUT_TRANS="$OUTPUTFILE".K@"$COUNTER"."$STD"."transoutput"
			echo "        ***** OUT_TRANS: $OUTPUT_TRANS"
			if [ ! -e "$OUTPUT_TRANS" ]; then
				touch $OUTPUT_TRANS
				echo "%${OUTPUTFILE}" >> "$OUTPUT_TRANS"
			fi
			python transliterate.py "$FILE" >> "$OUTPUT_TRANS"
			echo "#" >> "$OUTPUT_TRANS"
			rm "$FILE"
		fi
		#done
	done
done

echo ""
echo "*** BASH MCMM 3"
echo ""

#for FILE in $TEMPDIR/*; do
for FILE in $TEMPDIR/*; do	
	#for i in "${arr[@]}"; do
	#echo "*** BASH MCMM 3 ${i} ${FILE}"
	MAIN=`echo "$FILE" | cut -d '/' -f2`
	
	NAME=`echo "$MAIN" | cut -d '.' -f1`
	k=`echo "$MAIN" | cut -d '.' -f2`
	bigK=`echo "$MAIN" | cut -d '.' -f3`
	STD=`echo "$MAIN" | cut -d '.' -f4`
	TYPE=`echo "$MAIN" | cut -d '.' -f5`
	if [ "$TYPE" == "output" ] && [ "$bigK" == "$maxBigK" ] #&& [ "$STD" == "$i" ]
	then
		OUTPUT_TRANS="$OUTPUTFILE".K@"$maxBigK"."$STD"."transoutput"
		if [ ! -e "$OUTPUT_TRANS" ]; then
			touch $OUTPUT_TRANS
			echo "%${OUTPUTFILE}" >> "$OUTPUT_TRANS"
		fi
		python transliterate.py "$FILE" >> "$OUTPUT_TRANS"
		echo "#" >> "$OUTPUT_TRANS"
		rm "$FILE"
	fi
	#done
done
echo ""
echo "*** BASH MCMM 4"
echo ""
# for FILE in `ls $TEMPDIR/*`; do
# 	NAME=`echo "$FILE" | cut -d '.' -f1`
# 	k=`echo "$FILE" | cut -d '.' -f2`
# 	bigK=`echo "$FILE" | cut -d '.' -f3`
# 	TYPE=`echo "$FILE" | cut -d '.' -f4`
# 	if [ "$TYPE" == "output" ] && [ $bigK -le $NUMCLUSTERS ]; then
# 		OUTPUT_TRANS="$OUTPUTFILE".K@"$bigK".transoutput
# 		if [ -e "$OUTPUT_TRANS" ]
# 		then
# 			rm $OUTPUT_TRANS
# 		fi
# 		touch $OUTPUT_TRANS
# 		echo "%${OUTPUTFILE}" >> "$OUTPUT_TRANS"
# 		python transliterate.py "$FILE" >> "$OUTPUT_TRANS"
# 		echo "#" >> "$OUTPUT_TRANS"
# 	fi
# done
#python clustering_eval.py "$OUTPUT_TRANS" > "$EVAL_FILE"