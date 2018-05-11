#!/bin/bash

# rm optimize_nor.so
# rm optimize_nor.c

# rm linesearch.so
# rm linesearch.c

# rm selection_phase_nor.so
# rm selection_phase_nor.c

# rm predict_nor.so
# rm predict_nor.c

#rm predict_wwb.so
#rm predict_wwb.c



# if [ -e "encode_nor.so" ]; then
# 	rm encode_nor.so
# fi

# if [ -e "encode_nor.so" ]; then
# 	rm encode_nor.so
# fi

# if [ -e "decode.so" ]; then
# 	rm decode.so
# fi

# if [ -e "decode.so" ]; then
# 	rm decode.so
# fi

# if [ -e "bcubed_eval.so" ]; then
# 	rm bcubed_eval.so
# fi

# if [ -e "bcubed_eval.c" ]; then
# 	rm bcubed_eval.c
# fi

# if [ -e "clustertest_nor.so" ]; then
# 	rm clustertest_nor.so
# fi

# if [ -e "clustertest_nor.c" ]; then
# 	rm clustertest_nor.c
# fi

# if [ -e "sparsemat.so" ]; then
# 	rm sparsemat.so
# fi

# if [ -e "sparsemat.c" ]; then
# 	rm sparsemat.c
# fi

# if [ -e "matmath_sparse.so" ]; then
# 	rm matmath_sparse.so
# fi

# if [ -e "matmath_sparse.c" ]; then
# 	rm matmath_sparse.c
# fi

# if [ -e "matmath_nullptr.so" ]; then
# 	rm matmath_nullptr.so
# fi

# if [ -e "matmath_nullptr.c" ]; then
# 	rm matmath_nullptr.c
# fi

# if [ -e "search_direction.so" ]; then
# 	rm search_direction.so
# fi

# if [ -e "search_direction.c" ]; then
# 	rm search_direction.c
# fi

# if [ -e "dealloc.so" ]; then
# 	rm dealloc.so
# fi

# if [ -e "dealloc.c" ]; then
# 	rm dealloc.c
# fi

# if [ -e "mcmm_nor.so" ]; then
# 	rm mcmm_nor.so
# fi

# if [ -e "mcmm_nor.c" ]; then
# 	rm mcmm_nor.c
# fi

python setup_nor.py build_ext --inplace
#python setup_wrapper_sp1.py build_ext --inplace
