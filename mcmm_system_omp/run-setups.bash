#!/bin/bash

# python setup_matmath_nullptr.py build_ext --inplace
# python setup_matmath_samerow.py build_ext --inplace
# python setup_sparse.py build_ext --inplace
# 
# python setup_nnz.py build_ext --inplace
# python setup_sparsemat.py build_ext --inplace
# python setup_predict_sp.py build_ext --inplace
# 
# python setup_update.py build_ext --inplace
# python setup_update_sp.py build_ext --inplace
# 
# python setup_optimize_1K_np.py build_ext --inplace
# python setup_optimize_sp1.py build_ext --inplace

#cp optimize_sp2_newhope.py optimize_sp2.pyx
rm optimize_nor.so
rm optimize_nor.c
cp optimize_nor.py optimize_nor.pyx

#cp optimize_sp2_newhope_vec.py optimize_sp2.pyx
#cp optimize_1K_sp2_r_all_nsp.py optimize_1K_sp2.pyx
#cp optimize_1K_sp2_norm.py optimize_1K_sp2.pyx

#cp predict_nor.pyx predict_sp2.pyx
#cp linesearch.py linesearch.pyx
#cp predict_nonsparse.py predict_nonsparse.pyx
rm linesearch.so
rm linesearch.c

rm selection_phase_nor.so
rm selection_phase_nor.c

rm selection_phase_wwb.so
rm selection_phase_wwb.c

#cp optimize_sp2_supercharged_m-justnr.py optimize_sp2.pyx
rm predict_nor.so
rm predict_nor.c

rm predict_wwb.so
rm predict_wwb.c

rm encode_nor.c
rm encode_nor.so

rm decode.so
rm decode.c

rm bcubed_eval.so
rm bcubed_eval.c

rm clustertest_nor.so
rm clustertest_nor.c

rm sparsemat.so
rm sparsemat.c

rm matmath_sparse.so
rm matmath_sparse.c

if [ -e "matmath_nullptr.so" ]; then
	rm matmath_nullptr.so
fi
if [ -e "matmath_nullptr.c" ]; then
	rm matmath_nullptr.c
fi

if [ -e "search_direction.so" ]; then
	rm search_direction.so
fi
if [ -e "search_direction.c" ]; then
	rm search_direction.c
fi

rm dealloc.so
rm dealloc.c

rm mcmm_nor.so
rm mcmm_nor.c

cp encode_nor.py encode_nor.pyx
cp mcmm_nor.py mcmm_nor.pyx
cp new_wrapper_nor.py wrapper_nor.pyx

python setup_nor.py build_ext --inplace
#python setup_wrapper_sp1.py build_ext --inplace
