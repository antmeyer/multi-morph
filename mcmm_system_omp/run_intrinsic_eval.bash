#!/bin/bash

# TYPE=$1
# NUMBER=$2
DIR=
EVAL_DIR=/Users/anthonymeyer/Development/multimorph/eval_central/
MCMM_OUTPUT_PREFIX=/Users/anthonymeyer/Development/multimorph/mcmm_results/
BERMAN_PREFIX=/Users/anthonymeyer/Development/multimorph/eval_central/
EVAL_RESULTS_PREFIX=/Users/anthonymeyer/Development/multimorph/eval_central/
#BERMAN_PREFIX="../eval_central/"
#declare -a TYPES=("${NUMBERS[@]}")
declare -a TYPES=(O)
declare -a NUMBERS=(1000)

#declare -a NUMBERS=(${2}${users[@]}")
TIME=`eval date +"%y%m%d_%H-%M"`
COVER_DIR="intr_eval_${TIME}"
EVAL_RESULTS_PATH="/Users/anthonymeyer/Development/multimorph/eval_central/${COVER_DIR}/"
#COVER_DIR="/Users/anthonymeyer/Development/multimorph/eval_central/${COVER_DIR}/"
if [ ! -d ${EVAL_RESULTS_PATH} ]; then
	mkdir ${EVAL_RESULTS_PATH} 
fi
#TABLE_FILE="results_table_""${TYPE}_${NUM}"".txt"
TABLE_FILE="results_table.txt"
TABLE_PATH="${EVAL_RESULTS_PATH}${TABLE_FILE}"

#
#echo 'maps.google.com' | rev | cut -d'.' -f 1 | rev
for NUM in ${NUMBERS[@]}; do
	echo "${NUM}"
	for TYPE in ${TYPES[@]}; do
	#for NUM in ${NUMBERS[@]}; do
		DIR="${TYPE}_${NUM}"
		echo "DIR: ""${DIR}"
		MCMM_PATH="${MCMM_OUTPUT_PREFIX}${DIR}"
		echo "MCMM_PATH: ""${MCMM_PATH}"
		for FILE in $MCMM_PATH/*; do
			echo ">>> **** ACTUAL CLUSTERS FILE: ** ""${FILE}"
			WHOLENAME=`echo "$FILE" | rev | cut -d '/' -f1 | rev`
			echo $WHOLENAME
			#echo "$FILE" | cut -d'/' -f 1
			ROOTNAME=`echo "$FILE" | cut -d '.' -f1`
			BASENAME=`echo "$WHOLENAME" | cut -d '.' -f1`
			SUFFIX=`echo "$WHOLENAME" | cut -d '.' -f2`
			if [ "${BASENAME}" != "1_3_K1000_N11166_basic_181104_15-26_k-1000" ]; then
				continue
			fi
			if [ "${SUFFIX}" == clusters_justWords ]; then
				echo ""
				echo ""
				echo "TYPE: ""${TYPE}"
				echo ""
				echo ""
				if [ "${TYPE}" == "TS" ]; then
					BERMAN_FILE="TS_analyses_mod.txt"
				elif [ ${TYPE} == "TR" ]; then
					BERMAN_FILE="TR_analyses_mod.txt"
				elif [ ${TYPE} == "O" ]; then
					BERMAN_FILE="O_analyses_mod.txt"
				# else
				# 	BERMAN_FILE="TS_analyses_mod.txt"
				fi
				EVAL_DIR="${EVAL_RESULTS_PATH}${DIR}_intrinsic/"
				if [ ! -d "${EVAL_DIR}" ]; then
					mkdir "${EVAL_DIR}"
				fi
				echo "to clustering"
				# bermanAnalysesFile = sys.argv[1]
				# clustersFile = sys.argv[2]
				# clusterActivitiesFile = sys.argv[3]
				# #outFilePath = sys.argv[3]
				# outFilePath = sys.argv[4]
				python clustering_eval.py "${BERMAN_PREFIX}${BERMAN_FILE}" "${FILE}" "${ROOTNAME}.clusters" "${EVAL_DIR}${BASENAME}.intr_eval" >> "${TABLE_PATH}"
			fi
		done
	done
done
