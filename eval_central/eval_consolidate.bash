#!/bin/bash

# DATA_TYPE=$1
# NUM_CLUSTERS=$2
# TEMP_DIR=$1
# BASENAME=$2
# MCMM_OUTPUT_DIR=$4
ORI_DIR=
SEGM_DIR=
SEGM_TRANS_DIR=
SYMBOLS_DIR=
#GLD_STD_FILE="${DATA_TYPE}_gldstd.txt"
MCMM_OUTPUT_PREFIX="/Users/anthonymeyer/Development/multimorph/mcmm_results/"
#MCMM_OUTPUT_PREFIX="../mcmm_results/"
#DATA_TYPE=`echo "$MCMM_OUTPUT_DIR" | cut -d '_' -f1`
#K=`echo "$MCMM_OUTPUT_DIR" | cut -d '_' -f2`
#MCMM_OUTPUT_DIR="${DATA_TYPE}""_""${NUM_CLUSTERS}"
# MCMM_OUTPUT_PATH="{MCMM_OUTPUT_PREFIX}${MCMM_OUTPUT_DIR}"
MCMM_EVAL_PREFIX="/Users/anthonymeyer/Development/multimorph/eval_central/"
# MCMM_OUTPUT_PATH="{MCMM_OUTPUT_PREFIX}${MCMM_OUTPUT_DIR}"
#MCMM_EVAL_OUT="/Users/anthonymeyer/Development/multimorph/extrinsic_eval/"
#BASENAME=`echo "$MCMM_OUTPUT_DIR" | cut -d '_' -f1`
TIME=`eval date +"%y%m%d_%H-%M"`
COVER_DIR="extr_eval_${TIME}"
EVAL_RESULTS_PATH="/Users/anthonymeyer/Development/multimorph/extrinsic_eval/${COVER_DIR}/"
if [ ! -d "${EVAL_RESULTS_PATH}" ]; then
	mkdir "${EVAL_RESULTS_PATH}"
# else
# 	for F in "${SEGM_DIR}"/*; do rm $F; done
fi


#declare -a NUMBERS=(${2}${users[@]}")


#COVER_DIR="/Users/anthonymeyer/Development/multimorph/eval_central/${COVER_DIR}/"
# if [ ! -d ${EVAL_RESULTS_PATH} ]; then
# 	mkdir ${EVAL_RESULTS_PATH} 
# fi

declare -a TYPES=(TS)
declare -a NUMBERS=(1000)

for NUM in ${NUMBERS[@]}; do
	echo "${NUM}"
	for TYPE in ${TYPES[@]}; do
		DIR="${TYPE}_${NUM}"
		ORI_DIR="${EVAL_RESULTS_PATH}${DIR}_test_words/"
		CH_TO_MID_DIR="${EVAL_RESULTS_PATH}${DIR}_CH_to_morphID/"
		MORPH_DICT_DIR="${EVAL_RESULTS_PATH}${DIR}_morph_dict/"
		SYMBOLS_DIR="${EVAL_RESULTS_PATH}${DIR}_symbols/"
		SEGM_DIR="${EVAL_RESULTS_PATH}${DIR}_temp_segm/"
		SEGM_TRANS_DIR="${EVAL_RESULTS_PATH}${DIR}_temp_segm_trans/"
		COVERED_DIR="${EVAL_RESULTS_PATH}${DIR}_covered_words/"
		CONTROL_SEGM_DIR="${EVAL_RESULTS_PATH}${DIR}_control/"
		
		if [ ! -d "${ORI_DIR}" ]; then
			mkdir "${ORI_DIR}"
		#for F in "${SEGM_DIR}"/*; do rm $F; done
		fi

		if [ ! -d "${CH_TO_MID_DIR}" ]; then
			mkdir "${CH_TO_MID_DIR}"
		#for F in "${SEGM_DIR}"/*; do rm $F; done
		fi
		if [ ! -d "${MORPH_DICT_DIR}" ]; then
			mkdir "${MORPH_DICT_DIR}"
		#for F in "${SEGM_DIR}"/*; do rm $F; done
		fi
		if [ ! -d "${COVERED_DIR}" ]; then
			mkdir "${COVERED_DIR}"
		#for F in "${SEGM_DIR}"/*; do rm $F; done
		fi		
		if [ ! -d "${CONTROL_SEGM_DIR}" ]; then
			mkdir "${CONTROL_SEGM_DIR}"
		#for F in "${SEGM_DIR}"/*; do rm $F; done
		fi

		if [ ! -d "${SEGM_DIR}" ]; then
			mkdir "${SEGM_DIR}"
		# else
		# 	for F in "${SEGM_DIR}"/*; do rm $F; done
		fi

		if [ ! -d "${SEGM_TRANS_DIR}" ]; then 
			mkdir "${SEGM_TRANS_DIR}"
		fi

		if [ ! -d "${SYMBOLS_DIR}" ]; then 
			mkdir "${SYMBOLS_DIR}"
		fi

		if [ ! -d "${MCMM_EVAL_PREFIX}temp" ]; then 
			mkdir "${MCMM_EVAL_PREFIX}temp"
		fi
	#for NUM in ${NUMBERS[@]}; do

		#WORDLIST="morfessor_${TYPE}""_training.txt"
		#WORDLIST_PATH="${MCMM_EVAL_PREFIX}${WORDLIST}"
		GLDSTD_FILE="${MCMM_EVAL_PREFIX}morfessor_${TYPE}_gldstd.txt"
		#WORDLIST_FILE="${MCMM_EVAL_PREFIX}morfessor_${TYPE}_training.txt"
		#WORDLIST_FILE="${MCMM_EVAL_PREFIX}berman_words_${TYPE}.txt"
		#echo "DIR: ${DIR}   WORDLIST_PATH: ${WORDLIST_PATH}"
		MCMM_PATH="${MCMM_OUTPUT_PREFIX}${DIR}"
		#echo "MCMM_PATH: ""${MCMM_PATH}"
		
		for FILE in $MCMM_PATH/*; do
		#for FILE in `ls $MCMM_OUTPUT_PATH`; do
			echo $FILE
			echo "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
			CVALS_FILE=
			CLUSTERS_FILE=
			BASENAME=
			SUFFIX=
			#MAIN=`echo "$FILE" | cut -d '/' -f2`
			# #echo "mcmm bash 27; main = $MAIN"
			LOCNAME=`echo "$FILE" | rev | cut -d'/' -f1 | rev`
			BASENAME=`echo "$LOCNAME" | cut -d'.' -f1`
			if [ "${BASENAME}" != 6_3_K1000_N12272_basic_181104_07-21_k-1000 ] && [ "${BASENAME}" != 6_0_K1000_N12272_basic_181104_07-21_k-1000 ]; then
				continue
			fi 
			#echo "mcmm bash 28; basename = $BASENAME"
			MAIN_NAME=`echo "$FILE" | cut -d'.' -f1`
			SUFFIX=`echo "$FILE" | cut -d'.' -f2`
			echo "AAAAAAAAA Suffix: ${SUFFIX}"
			echo "XXXXXXXXX BASENAME: ${BASENAME}"

			if [ "${SUFFIX}" == "C_vals" ]; then
				if [ ! -f "${SYMBOLS_DIR}${BASENAME}.chinese" ]; then
					touch "${SYMBOLS_DIR}${BASENAME}.chinese"
				# else
				# 	rm "${SYMBOLS_DIR}${BASENAME}.chinese"
				# 	touch "${SYMBOLS_DIR}${BASENAME}.chinese"
				fi
				if [ ! -f "${MORPH_DICT_DIR}${BASENAME}.morph_dict" ]; then
					touch "${MORPH_DICT_DIR}${BASENAME}.morph_dict"
				# else
				# 	rm "${SEGM_DIR_TRANS}${BASENAME}.chinese_segm_trans"
				# 	touch "${SEGM_DIR_TRANS}${BASENAME}.chinese_segm_trans"
				fi

				if [ ! -f "${COVERED_DIR}${BASENAME}.words" ]; then
					touch "${COVERED_DIR}${BASENAME}.words"
				#for F in "${SEGM_DIR}"/*; do rm $F; done
				fi	
				if [ ! -f "${CH_TO_MID_DIR}${BASENAME}.CH_to_morphID" ]; then
					touch "${CH_TO_MID_DIR}${BASENAME}.CH_to_morphID"
				fi
				echo "BBBBBBBBB Suffix: ${SUFFIX}"
				CVALS_FILE=$FILE
				CLUSTERS_FILE=${MAIN_NAME}.clusters
				echo "&&^ CVALS_FILE: ${CVALS_FILE}"
				echo "&&^ CLUSTERS_FILE: ${CLUSTERS_FILE}"
				echo "&&^ WORDLIST_FILE: ${WORDLIST_FILE}"
				echo "&&^ GLDSTD_FILE: ${GLDSTD_FILE}"
				echo "&&^ ORI_TEST_DIR: ${ORI_DIR}"
				echo "&&^ SYMBOLS_DIR: ${SYMBOLS_DIR}"
				echo "&&^ WORDLIST_FILE: ${WORDLIST_FILE}"
				ORI_TEST_FILE="${ORI_DIR}${BASENAME}.original_order"
				#python four_stages_main.py ${BASENAME}.C_vals ${BASENAME}.clusters ${TEMP_DIR}/${BASENAME}.chinese morfessor_TR_gldstd.txt 
				#python four_stages_main.py "${CVALS_FILE}" "${CLUSTERS_FILE}" "${WORDLIST_FILE}" "${SYMBOLS_DIR}"
				#python four_stages_main.py "${CVALS_FILE}" "${CLUSTERS_FILE}" "${WORDLIST_FILE}" "${ORI_DIR}" "${SYMBOLS_DIR}"
				python four_stages_main.py "${CVALS_FILE}" "${CLUSTERS_FILE}" "${ORI_DIR}" "${COVERED_DIR}" "${SYMBOLS_DIR}"
				
				echo "consolidate bash 28; GLOBNAME: ${GLOBNAME}"
				echo "consolidate bash 28; LOCNAME: ${LOCNAME}"
				echo "consolidate bash 28; BASENAME = $BASENAME"
				SUFFIX=`echo "$LOCNAME" | cut -d '.' -f2`
				# if [ $SUFFIX == ""]; then
				# 	touch 
				# fi
				echo "XXXXXX 222: BASENAME: ${BASENAME}"

				# if [ ! -f "${ORI_DIR}${BASENAME}.original_order" ]; then
				# 	touch "${ORI_DIR}${BASENAME}.original_order"
				# else
				# 	rm "${ORI_DIR}${BASENAME}.original_order"
				# 	touch "${ORI_DIR}${BASENAME}.original_order"
				# fi

				# if [ ! -f "${SEGM_DIR}${BASENAME}.chinese_segm" ]; then
				# 	touch "${SEGM_DIR}${BASENAME}.chinese_segm"
				# else
				# 	rm "${SEGM_DIR}${BASENAME}.chinese_segm"
				# 	touch "${SEGM_DIR}${BASENAME}.chinese_segm"
				# fi

				#GLDSTD_FILE="morfessor_${TYPE}_gldstd.txt"
				#GLDSTD_PATH="${MCMM_EVAL_PREFIX}${GLDSTD_FILE}"
				
				# TRAIN_FILE="encoded_${TYPE}_training.txt"


				#TRAIN_PATH="${MCMM_EVAL_PREFIX}${TRAIN_FILE}"

				#echo "***"
				#cat "${SYMBOLS_DIR}${BASENAME}".chinese
				morfessor -t "${SYMBOLS_DIR}${BASENAME}.chinese" -S "${SEGM_DIR}${BASENAME}.chinese_segm" 
				# morfessor-train --encoding utf8 --traindata-list -S "${SEGM_DIR}${BASENAME}.chinese_segm" --logfile log.log "${SYMBOLS_DIR}${BASENAME}.chinese"
				# morfessor-segment -L model_B.segm test1.txt
				#echo "**** ${SEGM_DIR}${BASENAME}.chinese_segm ****"
				#cat "${SEGM_DIR}${BASENAME}.chinese_segm"
				#echo "**** COVERED ****"
				#cat "${COVERED_DIR}${BASENAME}.words" 
				#echo "**** CONTROL SEGM ****"
				#cat "${CONTROL_SEGM_DIR}${BASENAME}.control_segm" 
				morfessor -t "${COVERED_DIR}${BASENAME}.words" -S "${CONTROL_SEGM_DIR}${BASENAME}.control_segm" 
				# if [ ! -f "${SEGM_DIR_TRANS}${BASENAME}.chinese_segm_trans" ]; then
				# 	touch "${SEGM_DIR_TRANS}${BASENAME}.chinese_segm_trans"
				# else:
				# 	rm "${SEGM_DIR_TRANS}${BASENAME}.chinese_segm_trans"
				# 	touch "${SEGM_DIR_TRANS}${BASENAME}.chinese_segm_trans"
				# fi
				#echo "*&*"
				#cat "${SEGM_DIR}${BASENAME}.chinese_segm"
				#echo "*&* ${ORI_DIR}$BASENAME.original_order"
				#cat "${ORI_DIR}$BASENAME.original_order"
				#SEGM_TRANS_DIR="${EVAL_RESULTS_PATH}${DIR}_temp_segm_trans/"
				if [ ! -f "${SEGM_TRANS_DIR}${BASENAME}.chinese_segm_trans" ]; then
					touch "${SEGM_TRANS_DIR}${BASENAME}.chinese_segm_trans"
				# else
				# 	rm "${SEGM_DIR_TRANS}${BASENAME}.chinese_segm_trans"
				# 	touch "${SEGM_DIR_TRANS}${BASENAME}.chinese_segm_trans"
				fi

				echo "READ THIS 1: ${SEGM_TRANS_DIR}${BASENAME}.chinese_segm_trans"
				echo "READ THIS 1.5: ${ORI_DIR}$BASENAME.original_order"
				echo "READ THIS 1.7: ${CH_TO_MID_DIR}${BASENAME}.CH_to_morphID"
				#python reconvert_morphs.py "${SEGM_DIR}${BASENAME}.chinese_segm" "${MCMM_EVAL_PREFIX}temp/${BASENAME}.M2C_map" "${WORDLIST_FILE}" "${GLDSTD_FILE}" "${ORI_DIR}$BASENAME.original_order" "${CH_TO_MID_DIR}${BASENAME}.CH_to_morphID" "${SEGM_TRANS_DIR}${BASENAME}.chinese_segm_trans"
				python reconvert_morphs.py "${SEGM_DIR}${BASENAME}.chinese_segm" "${MCMM_EVAL_PREFIX}temp/${BASENAME}.M2C_map" "${GLDSTD_FILE}" "${ORI_DIR}$BASENAME.original_order" "${SEGM_TRANS_DIR}${BASENAME}.chinese_segm_trans" "${CH_TO_MID_DIR}${BASENAME}.CH_to_morphID"
				echo "READ THIS 2: ${SEGM_TRANS_DIR}${BASENAME}.chinese_segm_trans"
				echo "READ THIS 2.5: ${ORI_DIR}$BASENAME.original_order"
				echo "READ THIS 2.7: ${EVAL_RESULTS_PATH}${TYPE}_${NUM}_control_results.txt"
				touch "${EVAL_RESULTS_PATH}${TYPE}_${NUM}_multistage_results.txt"
				#morfessor-evaluate "${GLDSTD_FILE}" "${SEGM_TRANS_DIR}${BASENAME}.chinese_segm_trans"
				echo "${GLDSTD_FILE}"
				GSTD_SIZE=`cat "${GLDSTD_FILE}" | wc -l` 
				echo "${GSTD_SIZE}"
				#--format-template latex
				#morfessor-evaluate --num-samples 10 --sample-size 100 "${GLDSTD_FILE}" "${SEGM_TRANS_DIR}${BASENAME}.chinese_segm_trans" >> "${EVAL_RESULTS_PATH}${TYPE}_${NUM}_multistage_results.txt"
				#morfessor-evaluate --num-samples 10 --sample-size 100 "${GLDSTD_FILE}" "${CONTROL_SEGM_DIR}${BASENAME}.control_segm" >> "${EVAL_RESULTS_PATH}${TYPE}_${NUM}_control_results.txt"
				morfessor-evaluate --num-samples 1 --sample-size "${GSTD_SIZE}" --format-template latex "${GLDSTD_FILE}" "${SEGM_TRANS_DIR}${BASENAME}.chinese_segm_trans" >> "${EVAL_RESULTS_PATH}${TYPE}_${NUM}_multistage_results.txt"
				morfessor-evaluate --num-samples 1 --sample-size "${GSTD_SIZE}" --format-template latex "${GLDSTD_FILE}" "${CONTROL_SEGM_DIR}${BASENAME}.control_segm" >> "${EVAL_RESULTS_PATH}${TYPE}_${NUM}_control_results.txt"
			fi
		done
	done
done	




		# SEGM_DIR=temp_segm
		# SEGM_TRANS_DIR=temp_segm_trans
		#for FILE in `ls $TEMP_DIR`; do
# 		CVALS_FILE=
# 		CLUSTERS_FILE=
# 		BASENAME=
# 		SUFFIX=

# 		for FILE in `ls $MCMM_PATH`; do
# 			LOCNAME=
# 			BASENAME=
# 			SUFFIX=
# 			# MAIN=`echo "$FILE" | cut -d '/' -f2`
# 			# #echo "mcmm bash 27; main = $MAIN"
# 			GLOBNAME=`echo "$FILE" | cut -d '.' -f1`
# 			LOCNAME=`echo "$FILE" | rev | cut -d '/' -f1 | rev`
# 			BASENAME=`echo "$LOCNAME" | cut -d '.' -f1`
# 			echo "consolidate bash 28; GLOBNAME: ${GLOBNAME}"
# 			echo "consolidate bash 28; LOCNAME: ${LOCNAME}"
# 			echo "consolidate bash 28; BASENAME = $BASENAME"
# 			SUFFIX=`echo "$LOCNAME" | cut -d '.' -f2`
# 			# if [ $SUFFIX == ""]; then
# 			# 	touch 
# 			# fi
# 			echo "XXXXXX 222: BASENAME: ${BASENAME}"

# 			# if [ ! -f "${ORI_DIR}${BASENAME}.original_order" ]; then
# 			# 	touch "${ORI_DIR}${BASENAME}.original_order"
# 			# else
# 			# 	rm "${ORI_DIR}${BASENAME}.original_order"
# 			# 	touch "${ORI_DIR}${BASENAME}.original_order"
# 			# fi

# 			# if [ ! -f "${SEGM_DIR}${BASENAME}.chinese_segm" ]; then
# 			# 	touch "${SEGM_DIR}${BASENAME}.chinese_segm"
# 			# else
# 			# 	rm "${SEGM_DIR}${BASENAME}.chinese_segm"
# 			# 	touch "${SEGM_DIR}${BASENAME}.chinese_segm"
# 			# fi

# 			#GLDSTD_FILE="morfessor_${TYPE}_gldstd.txt"
# 			#GLDSTD_PATH="${MCMM_EVAL_PREFIX}${GLDSTD_FILE}"
			
# 			# TRAIN_FILE="encoded_${TYPE}_training.txt"


# 			#TRAIN_PATH="${MCMM_EVAL_PREFIX}${TRAIN_FILE}"

# 			#echo "***"
# 			#cat "${SYMBOLS_DIR}${BASENAME}".chinese
# 			morfessor -t "${SYMBOLS_DIR}${BASENAME}.chinese" -S "${SEGM_DIR}${BASENAME}.chinese_segm" 
# 			# morfessor-train --encoding utf8 --traindata-list -S "${SEGM_DIR}${BASENAME}.chinese_segm" --logfile log.log "${SYMBOLS_DIR}${BASENAME}.chinese"
# 			# morfessor-segment -L model_B.segm test1.txt
# 			#echo "**** ${SEGM_DIR}${BASENAME}.chinese_segm ****"
# 			#cat "${SEGM_DIR}${BASENAME}.chinese_segm"
# 			#echo "**** COVERED ****"
# 			#cat "${COVERED_DIR}${BASENAME}.words" 
# 			#echo "**** CONTROL SEGM ****"
# 			#cat "${CONTROL_SEGM_DIR}${BASENAME}.control_segm" 
# 			morfessor -t "${COVERED_DIR}${BASENAME}.words" -S "${CONTROL_SEGM_DIR}${BASENAME}.control_segm" 
# 			# if [ ! -f "${SEGM_DIR_TRANS}${BASENAME}.chinese_segm_trans" ]; then
# 			# 	touch "${SEGM_DIR_TRANS}${BASENAME}.chinese_segm_trans"
# 			# else:
# 			# 	rm "${SEGM_DIR_TRANS}${BASENAME}.chinese_segm_trans"
# 			# 	touch "${SEGM_DIR_TRANS}${BASENAME}.chinese_segm_trans"
# 			# fi
# 			#echo "*&*"
# 			#cat "${SEGM_DIR}${BASENAME}.chinese_segm"
# 			#echo "*&* ${ORI_DIR}$BASENAME.original_order"
# 			#cat "${ORI_DIR}$BASENAME.original_order"
# 			#SEGM_TRANS_DIR="${EVAL_RESULTS_PATH}${DIR}_temp_segm_trans/"
# 			if [ ! -f "${SEGM_TRANS_DIR}${BASENAME}.chinese_segm_trans" ]; then
# 				touch "${SEGM_TRANS_DIR}${BASENAME}.chinese_segm_trans"
# 			# else
# 			# 	rm "${SEGM_DIR_TRANS}${BASENAME}.chinese_segm_trans"
# 			# 	touch "${SEGM_DIR_TRANS}${BASENAME}.chinese_segm_trans"
# 			fi

# 			echo "READ THIS 1: ${SEGM_TRANS_DIR}${BASENAME}.chinese_segm_trans"
# 			echo "READ THIS 1.5: ${ORI_DIR}$BASENAME.original_order"
# 			echo "READ THIS 1.7: ${CH_TO_MID_DIR}${BASENAME}.CH_to_morphID"
# 			#python reconvert_morphs.py "${SEGM_DIR}${BASENAME}.chinese_segm" "${MCMM_EVAL_PREFIX}temp/${BASENAME}.M2C_map" "${WORDLIST_FILE}" "${GLDSTD_FILE}" "${ORI_DIR}$BASENAME.original_order" "${CH_TO_MID_DIR}${BASENAME}.CH_to_morphID" "${SEGM_TRANS_DIR}${BASENAME}.chinese_segm_trans"
# 			python reconvert_morphs.py "${SEGM_DIR}${BASENAME}.chinese_segm" "${MCMM_EVAL_PREFIX}temp/${BASENAME}.M2C_map" "${GLDSTD_FILE}" "${ORI_DIR}$BASENAME.original_order" "${SEGM_TRANS_DIR}${BASENAME}.chinese_segm_trans" "${CH_TO_MID_DIR}${BASENAME}.CH_to_morphID"
# 			echo "READ THIS 2: ${SEGM_TRANS_DIR}${BASENAME}.chinese_segm_trans"
# 			echo "READ THIS 2.5: ${ORI_DIR}$BASENAME.original_order"
# 			echo "READ THIS 2.7: ${EVAL_RESULTS_PATH}${TYPE}_${NUM}_control_results.txt"
# 			touch "${EVAL_RESULTS_PATH}${TYPE}_${NUM}_multistage_results.txt"
# 			#morfessor-evaluate "${GLDSTD_FILE}" "${SEGM_TRANS_DIR}${BASENAME}.chinese_segm_trans"
# 			echo "${GLDSTD_FILE}"
# 			GSTD_SIZE=`cat "${GLDSTD_FILE}" | wc -l` 
# 			echo "${GSTD_SIZE}"
# 			#--format-template latex
# 			morfessor-evaluate --num-samples 10 --sample-size 100 "${GLDSTD_FILE}" "${SEGM_TRANS_DIR}${BASENAME}.chinese_segm_trans" >> "${EVAL_RESULTS_PATH}${TYPE}_${NUM}_multistage_results.txt"
# 			morfessor-evaluate --num-samples 10 --sample-size 100 "${GLDSTD_FILE}" "${CONTROL_SEGM_DIR}${BASENAME}.control_segm" >> "${EVAL_RESULTS_PATH}${TYPE}_${NUM}_control_results.txt"
# 		done
# 	done
# done	

# for NUM in ${NUMBERS[@]}; do
# 	echo "${NUM}"
# 	for TYPE in ${TYPES[@]}; do
# 		"${CONTROL_SEGM_DIR}${BASENAME}.control_segm" 
# 	done
# done
# 		# 	if [ ! -f ${SEGM_DIR}/${BASENAME}.chinese_segm ]; then
		# 		touch ${SEGM_DIR}/${BASENAME}.chinese_segm
		# 	fi
			
		# 	morfessor -t ${TEMP_DIR}/${BASENAME}.chinese -S ${SEGM_DIR}/${BASENAME}.chinese_segm
			
		# 	if [ ! -f ${SEGM_DIR_TRANS}/${BASENAME}.chinese_segm_trans ]; then
		# 		touch ${SEGM_DIR_TRANS}/${BASENAME}.chinese_segm_trans
		# 	fi
		# 	python reconvert_morphs.py ${SEGM_DIR}/${BASENAME}.chinese_segm > ${SEGM_DIR_TRANS}/${BASENAME}.chinese_segm_trans

		# 	morfessor-evaluate "${MCMM_EVAL_PREFIX}morfessor_${TYPE}_gldstd.txt" ${SEGM_DIR_TRANS}/${BASENAME}.chinese_segm_trans
		# done