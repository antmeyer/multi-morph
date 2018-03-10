#!/bin/bash
# run-mcmm-experiments.bash
#
# Run a loop of mcmm experiments

N=""
INPUT=""
INDIR=""
INFILE=""
INFLAG=0
#INFILE="data/hbwrds_charsamp_r22_3"
OUTDIR=""
OUTFILE=""
DIR=
K_RANGE=
bigK=
K_FLAG=0
N_FLAG=0
POS_RANGE=
POS_RANGE_FLAG=0
PREC_RANGE=0
PREC_RANGE_FLAG=0
BIGRAMS=0
BIGRAMS_FLAG=0
# FEATURE_FLAG=0
TEMPDIR=
TDFLAG=0
M_FILE=
C_FILE=
M_FILE_FLAG=0
C_FILE_FLAG=0
USE_SQ=0
OBJFUNC="---"
OBJFUNC_FLAG=0
QN=0
CG=0
MIXING_FUNC=
MIXING_FUNC_FLAG=0
ETA="default"
ETA_FLAG=0
TITLE1=
TITLE2=
TITLE3=
TITLE4=
TITLE5=
TITLE6=
#PREFIX="/Users/anthonymeyer/Documents/qual_paper_2/code/mcmm-cython"
#PREFIX="/Users/anthonymeyer/Development/mcmm"
PREFIX="/N/u/antmeyer/BigRed2/mcmm/"
#DATE=$(date +"%m-%d-%Y")
TIME=`eval date +"%Y-%m-%d_%H-%M"`
# echo "* BIGRAMS: $BIGRAMS"

while getopts "i:N:K:l:a:d:bt:m:c:Qj:yzM:E:" OPTION
do
	case $OPTION in
	i)	
		INPUT="$OPTARG"
		INFLAG=1
		;;
	N)	
		N="$OPTARG"
		N_FLAG=1
		;;
	K)
		K_RANGE="${OPTARG}"
		K_FLAG=1
		;;
	l)
		K_INTERVAL="${OPTARG}"
		K_INTERVAL_FLAG=1
		;;
	a)
		POS_RANGE="${OPTARG}"
		POS_RANGE_FLAG=1
		;;
	d)
		PREC_RANGE="${OPTARG}"
		PREC_RANGE_FLAG=1
		;;
	b)
		BIGRAMS=1
		BIGRAMS_FLAG=1
		;;
	t)
		TEMPDIR="$OPTARG"
		TDFLAG=1
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
		USE_SQ=1
		TITLE2="Use S and Q? $USE_SQ; "
		;;
	j)
		OBJFUNC="$OPTARG"
		OBJFUNC_FLAG=1
		TITLE3="Objective function: $OBJFUNC; "
		;;
	y)
		echo "&***&&&***&&   -y OPT QN (1)   &&***&&&***&"
		QN=1
		TITLE4="QN? $QN; "
		;;
	z)
		CG=1
		TITLE5="CG? $CG; "
		;;
	M)
		MIXING_FUNC="$OPTARG"
		MIXING_FUNC_FLAG=1
		;;
	E)
		ETA="$OPTARG"
		ETA_FLAG=1
		if [ "$ETA" == "default" ]
		then
			TITLE6="ETA: Default (# of neg. features div. by total feature count); "	
		else
			TITLE6="ETA = $ETA/100; "
		fi
		;;
	\?)	
		echo "Usage: %s: [-i input file path] [-K number of clusters] [-l the interval between evaluated Ks] [-a affix-length range] [-d range of distances for precedence features ] \n" $(basename $0) >&7
		exit 2
		;;
	esac
done
shift $(($OPTIND - 1))


echo "*** BIGRAMS: $BIGRAMS"
echo "*** BIGRAMS_FLAG: $BIGRAMS_FLAG"

if [ "$K_FLAG" == 0 ]
then
	K_RANGE=".*"
fi
if [ "$N_FLAG" == 0 ]
then
	N=""
fi
bigK=`echo ${K_RANGE##* }`

if [ "$K_INTERVAL_FLAG" == 0 ]
then
	K_INTERVAL=5
fi

if [ "$POS_RANGE_FLAG" == 0 ]
then
	POS_RANGE="2 3 4"
fi

if [ "$PREC_RANGE_FLAG" == 0 ]
then
	PREC_RANGE="1 2 3 star"
fi

if [ "$BIGRAMS_FLAG" == 0 ]
then
	BIGRAMS=0
else
	BIGRAMS=1
fi
TITLE1=" Bigrams? $BIGRAMS; "

if [ "$TDFLAG" == 0 ]
then
	TEMPDIR=temp_files_2
fi

# if [ "$INFLAG" == 0 ]
# then
# 	INDIR="."
# 	OUTDIR=mcmm-out_"$TIME"
# else
# 	INDIR=`echo "$INPUT" | cut -d '/' -f2`
# 	INFILE=`echo "$INPUT" | cut -d '/' -f3`
# 	OUTDIR="../mcmm_results/mcmm-out""_""N-$N""_""K-$bigK""_""$TIME"
# fi

if [ "$OBJFUNC_FLAG" == 0 ]
then
	OBJFUNC=0
fi

if [ "$M_FILE_FLAG" == 0 ]
then
	M_FILE="0"
fi

if [ "$C_FILE_FLAG" == 0 ]
then
	C_FILE="0"
fi

if [ "$MIXING_FUNC_FLAG" == 0 ]
then
	MIXING_FUNC="nor"
fi

if [ "$ETA_FLAG" == 0 ]
then
	ETA="none"
	#TITLE6="ETA: Default (# of neg. features div. by total feature count); "
	TITLE6="No eta or lambda used"
elif [ "$MIXING_FUNC" == "nor" ]
then
	ETA="none"
	#TITLE6="ETA: Default (# of neg. features div. by total feature count); "
	TITLE6="Mixing function = $MIXING_FUNC"
fi

if [ "$INFLAG" == 0 ]
then
	INDIR="."
	OUTDIR=mcmm-out_"$TIME"
else
	INDIR=`echo "$INPUT" | cut -d '/' -f1`
	INDIR="$PREFIX""/""$INDIR"
	INFILE=`echo "$INPUT" | cut -d '/' -f2`
	#INFILE="$INFILE"".txt"
	OUTDIR="$PREFIX""/mcmm_results/mcmm-out""_""N-$N""_""K-$bigK""_""$TIME"

# 	if [ "$MIXING_FUNC" == "wwb" ]; then
# 		OUTDIR+="ETA-$ETA""_"
# 	fi
# OUTDIR+="$TIME"
fi
mkdir "$OUTDIR"

# if [ -d "$TEMPDIR" ]; then
# 	echo "${TEMPDIR} exists. Thanks!"
# 	CONTENTS=`ls "$TEMPDIR"`
# 	if [ ${#CONTENTS} -gt 0 ]; then
# 		for FILE in $TEMPDIR/*; do
# 			rm $FILE
# 		done
# 	fi
# else
# 	mkdir "$TEMPDIR" 
# fi

#chmod a+rwx mcmm_sp2.bash
echo ""
echo ""
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
echo ""
echo "   QN? $QN"
echo "   CG? $CG"
echo ""
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
echo ""
echo ""
find "$TEMPDIR" -type f -delete
echo "******* MIXING FUNC: $MIXING_FUNC ********"
EXPERI_TITLE="$TITLE1""$TITLE2""$TITLE3""$TITLE4""$TITLE5""$TITLE6"
for KVAL in ${K_RANGE}; do
	for AFFIXLEN in ${POS_RANGE}; do
		DIST=0
		if [ "$AFFIXLEN" == "" ]; then
			continue
		fi
# 		if [ "$AFFIXLEN" != 0 ]; then
# 			TYPE=positional
# 			TIME=`eval date +"%Y-%m-%d_%H-%M"`
# 			OUTFILE="$AFFIXLEN"_na_K-"$KVAL"_N-"$N"_"$TIME"
# 			bash mcmm.bash -K "$KVAL" -l "$K_INTERVAL" -i "$INDIR"/"$INFILE" -o "$OUTDIR"/"$OUTFILE" -a "$AFFIXLEN" -d "$DIST" -f "$TYPE" -t "$TEMPDIR"
# 		fi
		for DIST in ${PREC_RANGE}; do
			if [ "$DIST" == "" ]; then
				continue
			fi
			if [ "$AFFIXLEN" == 0 ]; then
				#TYPE=precedence
				TIME=`eval date +"%Y-%m-%d_%H-%M"`
				OUTFILE=na_"$DIST"_"$BIGRAMS"_K-"$KVAL"_N-"$N"_ETA-"$ETA"_"$TIME"
				echo "DIST: ""$DIST"
				bash mcmm_sp2.bash -K "$KVAL" -l "$K_INTERVAL" -i "$INDIR"/"$INFILE" -o "$OUTDIR"/"$OUTFILE" -a "$AFFIXLEN" -d "$DIST" -b "$BIGRAMS" -t "$TEMPDIR" -e "$EXPERI_TITLE" -m "$M_FILE" -c "$C_FILE" -Q "$USE_SQ" -j "$OBJFUNC" -y "$QN" -z "$CG" -M "$MIXING_FUNC" -E "$ETA"
			elif [ "$DIST" == 0 ] && [ "$AFFIXLEN" != 0 ]; then
				#TYPE=positional
				TIME=`eval date +"%Y-%m-%d_%H-%M"`
				OUTFILE="$AFFIXLEN"_na_"$BIGRAMS"_K-"$KVAL"_N-"$N"_ETA-"$ETA"_"$TIME"
				bash mcmm_sp2.bash -K "$KVAL" -l "$K_INTERVAL" -i "$INDIR"/"$INFILE" -o "$OUTDIR"/"$OUTFILE" -a "$AFFIXLEN" -d "$DIST" -b "$BIGRAMS" -t "$TEMPDIR" -e "$EXPERI_TITLE" -m "$M_FILE" -c "$C_FILE" -Q "$USE_SQ" -j "$OBJFUNC" -y "$QN" -z "$CG" -M "$MIXING_FUNC" -E "$ETA"
			else
				#TYPE=both
				TIME=`eval date +"%Y-%m-%d_%H-%M"`
				OUTFILE="$AFFIXLEN"_"$DIST"_"$BIGRAMS"_K-"$KVAL"_N-"$N"_ETA-"$ETA"_"$TIME"
				bash mcmm_sp2.bash -K "$KVAL" -l "$K_INTERVAL" -i "$INDIR"/"$INFILE" -o "$OUTDIR"/"$OUTFILE" -a "$AFFIXLEN" -d "$DIST" -b "$BIGRAMS" -t "$TEMPDIR" -e "$EXPERI_TITLE" -m "$M_FILE" -c "$C_FILE" -Q "$USE_SQ" -j "$OBJFUNC" -y "$QN" -z "$CG" -M "$MIXING_FUNC" -E "$ETA"
			fi
		done
	done
done

echo "Finished with run-mcmm-experiments"
chmod a+rwx run-eval.bash 
bash run-eval.bash -r "$OUTDIR" -K "$bigK" -l "$K_INTERVAL" -a "$POS_RANGE" -d "$PREC_RANGE" -I "$INDIR""/""$INFILE"".txt"
if [ -d "$OUTDIR"_eval ]; then
	bash makeTable.bash -r "$OUTDIR" -o "$OUTDIR"_eval
fi
