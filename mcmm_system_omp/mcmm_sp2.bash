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
PREC_TYPES=
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
PREC_TYPE_FLAG=
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
PREFIX1="/Users/anthonymeyer"
PREFIX2="/Development/multimorph/mcmm_system_omp"
#PREFIX1="N/u/antmeyer"
#PREFIX2="/mcmm/multimorph/mcmm_system_omp"
STD=
while getopts "K:l:i:o:a:d:D:b:t:e:m:c:Q:j:y:z:M:E:" OPTION
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
	D)
		PREC_TYPES="$OPTARG"
		PREC_TYPE_FLAG==1
		;;
	b)
		BIGRAMS="$OPTARG"
		BIGRAMS_FLAG==1
		;;
	t)
		TEMPDIR="$OPTARG"
		TEMPDIR_FLAG=1
		;;
	e)
		EXPERI_TITLE="$OPTARG"
		EXPERI_FLAG=1
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
	\?)
		echo "Usage: %s: [-K number of data points to generate] [-i input file ] [-o output file ] args\n" $(basename $0) >&10
		exit 2
		;;
	esac
done
shift $(($OPTIND - 1))


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

declare -a arr=("mc-")

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

if [ "$PREC_TYPE_FLAG" == 0 ]
then
	PREC_TYPES="basic"
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
	EXPER_TITLE="Objective Function: $OBJFUNC"
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

echo "mcmm bash; BIGRAMS = $BIGRAMS"
echo "mcmm bash; BIGRAMS_FLAG = $BIGRAMS_FLAG"
echo "mcmm bash; MIXING FUNC: $MIXING_FUNC"
echo "mcmm bash; USE_SQ? $USE_SQ"
echo "mcmm bash; OBJFUNC? $OBJFUNC"
echo "mcmm bash; QN? $QN"
echo "mcmm bash; CG? $CG"
echo "***"
echo "***"
echo "*** OUTPUT FILE = ""$OUTPUTFILE"
echo "***  INPUT FILE = ""$INPUTFILE"
echo "***"
echo "***"
echo "***"
# echo ""
# echo ""
# echo ""
# echo ""
# echo ""
# echo ""
#if [ "$MIXING_FUNC" == "wwb" ]; then
	#python wrapper_wrapper_wwb.py "$INPUTFILE" "$OUTPUTFILE" "$AFFIXLEN" "$PRECSPAN" "$BIGRAMS" "$NUMCLUSTERS" "$K_INTERVAL" "$TEMPDIR" "$EXPERI_TITLE" "$M_FILE" "$C_FILE" "$USE_SQ" "$OBJFUNC" "$QN" "$CG" "$MIXING_FUNC"
#fi

python wrapper_wrapper_nor.py "$INPUTFILE" "$OUTPUTFILE" "$AFFIXLEN" "$PRECSPAN" "$PREC_TYPES" "$BIGRAMS" "$NUMCLUSTERS" "$K_INTERVAL" "$TEMPDIR" "$EXPERI_TITLE" "$M_FILE" "$C_FILE" "$USE_SQ" "$OBJFUNC" "$QN" "$CG" "$MIXING_FUNC"


# MILA_DIR="$PREFIX1/Development/morphAnalyzer_v_1-0/jars/"
# ANALYZER="${MILA_DIR}TextAnalyzer.jar"
# DINFLECT=${MILA_DIR}
# DINFLECT+="dinflections.data"
# DPREFIXES=${MILA_DIR}
# DPREFIXES+="dprefixes.data"
# GIMATRIA=${MILA_DIR}
# GIMATRIA+="gimatria.data"
# MCMM_DIR="$PREFIX1$PREFIX2/$TEMPDIR"

# maxBigK=0
# echo ""
# echo "*** BASH MCMM 1"
# echo ""
# CONTENTS=`ls $MCMM_DIR`
# echo "******************"
# echo "CONTENTS = ${CONTENTS}"
# echo "******************"
# if [ ${#CONTENTS} -eq 0 ]; then
# 	echo "No Result Files"
# 	exit
# else
# 	for FILE in $TEMPDIR/*; do
# 		echo "mcmm bash 6; file = $FILE"
# 		MAIN=`echo "$FILE" | cut -d '/' -f2`
# 		echo "mcmm bash 7; main = $MAIN"
# 		NAME=`echo "$MAIN" | cut -d '.' -f1`
# 		echo "mcmm bash 8; name = $NAME"
# 		k=`echo "$MAIN" | cut -d '.' -f2`
# 		echo "mcmm bash 9; k = $k"
# 		bigK=`echo "$MAIN" | cut -d '.' -f3`
# 		echo "mcmm bash 10; bigK = $bigK"
# 		echo "mcmm bash 10.5; maxBigK = $maxBigK"
# 		if [ "$bigK" -gt "$maxBigK" ]; then
# 			maxBigK=$bigK
# 		fi
# 		STD=`echo "$MAIN" | cut -d '.' -f4`
# 		TYPE=`echo "$MAIN" | cut -d '.' -f5`
# 		if [ "${TYPE}" == "input" ] #&& [ "$STD" == "$i" ]
# 		then
# 			INPUT="$PREFIX1$PREFIX2/$TEMPDIR/${MAIN}"
# 			OUTPUT="$PREFIX1$PREFIX2/$TEMPDIR/${NAME}.${k}.${bigK}.${STD}.output"
# 			echo "mcmm bash 11; Input = $INPUT"
# 			echo "mcmm bash 12; Output = $OUTPUT"
# 			java -Xmx1024m -jar $ANALYZER FALSE $INPUT $OUTPUT $DINFLECT $DPREFIXES $GIMATRIA
# 		fi
# 	done
# fi
# echo ""
# echo "*** BASH MCMM 2"
# echo ""
# COUNTER=0
# LAST_INTERVAL=$(($maxBigK - $K_INTERVAL))
# while [ "$COUNTER" -lt "$LAST_INTERVAL" ]; do
# 	COUNTER=$(($COUNTER + $K_INTERVAL))
# 	echo "*** mcmm_bash; COUNTER = ${COUNTER}"
# 	for FILE in $TEMPDIR/*; do	
# 		echo "***********************************************"
# 		echo "*** mcmm_bash; ${FILE}"
# 		echo "***********************************************"
# 		echo "   *** mcmm_bash; STD = ${i}"
# 		MAIN=`echo "$FILE" | cut -d '/' -f2`
# 		echo "mcmm bash 27; main = $MAIN"
# 		NAME=`echo "$MAIN" | cut -d '.' -f1`
# 		echo "mcmm bash 28; name = $NAME"
# 		k=`echo "$MAIN" | cut -d '.' -f2`
# 		bigK=`echo "$MAIN" | cut -d '.' -f3`
# 		STD=`echo "$MAIN" | cut -d '.' -f4`
# 		echo "mcmm bash 32; std = $STD"
# 		TYPE=`echo "$MAIN" | cut -d '.' -f5`
# 		echo "mcmm bash 32; type = $TYPE"
# 		if [ "$TYPE" == "output" ] && [ "$bigK" == "$COUNTER" ]
# 		then
# 			# We need $bigK (one of the max-k intervals) to equal our interval counter
# 			OUTPUT_TRANS="$OUTPUTFILE".K@"$COUNTER"."$STD"."transoutput"
# 			echo "        ***** OUT_TRANS: $OUTPUT_TRANS"
# 			if [ ! -e "$OUTPUT_TRANS" ]; then
# 				touch $OUTPUT_TRANS
# 				echo "%${OUTPUTFILE}" >> "$OUTPUT_TRANS"
# 			fi
# 			python transliterate.py "$FILE" >> "$OUTPUT_TRANS"
# 			echo "#" >> "$OUTPUT_TRANS"
# 			rm "$FILE"
# 		fi
# 	done
# done

# echo ""
# echo "*** BASH MCMM 3"
# echo ""

# for FILE in $TEMPDIR/*; do	
# 	MAIN=`echo "$FILE" | cut -d '/' -f2`
	
# 	NAME=`echo "$MAIN" | cut -d '.' -f1`
# 	k=`echo "$MAIN" | cut -d '.' -f2`
# 	bigK=`echo "$MAIN" | cut -d '.' -f3`
# 	STD=`echo "$MAIN" | cut -d '.' -f4`
# 	TYPE=`echo "$MAIN" | cut -d '.' -f5`
# 	if [ "$TYPE" == "output" ] && [ "$bigK" == "$maxBigK" ]
# 	then
# 		OUTPUT_TRANS="$OUTPUTFILE".K@"$maxBigK"."$STD"."transoutput" # transliterated file
# 		if [ ! -e "$OUTPUT_TRANS" ]; then
# 			touch $OUTPUT_TRANS
# 			echo "%${OUTPUTFILE}" >> "$OUTPUT_TRANS"
# 		fi
# 		python transliterate.py "$FILE" >> "$OUTPUT_TRANS"
# 		echo "#" >> "$OUTPUT_TRANS"
# 		rm "$FILE"
# 	fi
# done
# echo ""
# echo "*** BASH MCMM 4"
# echo ""
