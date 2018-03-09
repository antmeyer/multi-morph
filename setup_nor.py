#!/usr/bin/env python
from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext
import Cython.Compiler.Options
Cython.Compiler.Options.annotate = True
from Cython.Build import cythonize
import numpy as np

print "\n\nsetup 1\n\n"

ext = Extension("predict",
              sources=["predict.pyx", "predict_c_funcs.c"],
              extra_compile_args = ["-O2", "-fopenmp"],
              extra_link_args=['-fopenmp']
              )
setup(
    name="predict",
    ext_modules = cythonize([ext]),
    include_dirs = [np.get_include()]
)

setup(
    include_dirs = [np.get_include(), '.'],
    cmdclass = {'build_ext': build_ext},
    ext_modules = cythonize('dealloc.pyx', annotate=True),
)

# setup(
#     include_dirs = [np.get_include(), '.'],
#     cmdclass = {'build_ext': build_ext},
#     ext_modules = cythonize('utility.pyx', annotate=True),
# )


setup(
    include_dirs = [np.get_include(), '.'],
    cmdclass = {'build_ext': build_ext},
    ext_modules = cythonize('numberNonZeros.pyx', annotate=True),
)

setup(
    include_dirs = [np.get_include(), '.'],
    cmdclass = {'build_ext': build_ext},
    ext_modules = cythonize('matmath_nullptr.pyx', annotate=True),
)

print "\n\nsetup 2\n\n"
setup(
    include_dirs = [np.get_include(), '.'],
    cmdclass = {'build_ext': build_ext},
    ext_modules = cythonize('sparsemat.pyx', annotate=True),
)

# setup(
#     include_dirs = [np.get_include(), '.'],
#     cmdclass = {'build_ext': build_ext},
#     ext_modules = cythonize('prod_sp2.pyx', annotate=True),
# )
setup(
    include_dirs = [np.get_include(), '.'],
    cmdclass = {'build_ext': build_ext},
	ext_modules = cythonize('matmath_sparse.pyx', annotate=True),
)


# setup(
#     include_dirs = [np.get_include(), '.'],
#     cmdclass = {'build_ext': build_ext},
# 	ext_modules = cythonize('lbfgs.pyx', annotate=True),
# )
print "\n\nsetup 3\n\n"
setup(
    include_dirs = [np.get_include(), '.'],
    cmdclass = {'build_ext': build_ext},
	ext_modules = cythonize('search_direction.pyx', annotate=True),
)
#print "\n\nsetup 3.5\n\n"
# setup(
#     include_dirs = [np.get_include(), '.'],
#     cmdclass = {'build_ext': build_ext},
# 	ext_modules = cythonize('update_sp2.pyx', annotate=True),
# )
# setup(
#     include_dirs = [np.get_include(), '.'],
#     cmdclass = {'build_ext': build_ext},
#    	ext_modules = cythonize('predict_sp2.pyx', annotate=True),
# )

print "\n\n", "setup 4", "\n\n"
# setup(
#     include_dirs = [np.get_include(), '.'],
#     cmdclass = {'build_ext': build_ext},
#    	ext_modules = cythonize('predict_nonsparse.pyx', annotate=True),
# )

setup(
    include_dirs = [np.get_include(), '.'],
    cmdclass = {'build_ext': build_ext},
	ext_modules = cythonize('interpolate.pyx', annotate=True),
)

print "\n\n", "setup 4.2", "\n\n"

# setup(
#     include_dirs = [np.get_include(), '.'],
#     cmdclass = {'build_ext': build_ext},
# 	ext_modules = cythonize('lcsubseq.pyx', annotate=True),
# )

setup(
    include_dirs = [np.get_include(), '.'],
    cmdclass = {'build_ext': build_ext},
	ext_modules = cythonize('selection_phase_nor.pyx', annotate=True),
)

# setup(
#     include_dirs = [np.get_include(), '.'],
#     cmdclass = {'build_ext': build_ext},
# 	ext_modules = cythonize('selection_phase_wwb.pyx', annotate=True),
# )

print "\n\n", "setup 4.3", "\n\n"

setup(
    include_dirs = [np.get_include(), '.'],
    cmdclass = {'build_ext': build_ext},
   	ext_modules = cythonize('linesearch.pyx', annotate=True),
)

# setup(
#     include_dirs = [np.get_include(), '.'],
#     cmdclass = {'build_ext': build_ext},
#    	ext_modules = cythonize('predict_nor.pyx', annotate=True),
# )
# setup(
#     include_dirs = [np.get_include(), '.'],
#     cmdclass = {'build_ext': build_ext},
#    	ext_modules = cythonize('predict_wwb.pyx', annotate=True),
# )

print "\n\n", "setup 4.4", "\n\n"

setup(
    include_dirs = [np.get_include(), '.'],
    cmdclass = {'build_ext': build_ext},
   	ext_modules = cythonize('cg_nor.pyx', annotate=True),
)

# setup(
#     include_dirs = [np.get_include(), '.'],
#     cmdclass = {'build_ext': build_ext},
#    	ext_modules = cythonize('optimize_wwb.pyx', annotate=True),
# )
setup(
    include_dirs = [np.get_include(), '.'],
    cmdclass = {'build_ext': build_ext},
   	ext_modules = cythonize('optimize_nor.pyx', annotate=True),
)
# ext_modules = [
#     Extension(
#         "hello",
#         ["hello.pyx"],
#         extra_compile_args=['-fopenmp'],
#         extra_link_args=['-fopenmp'],
#     )
# ]
# ext2 = Extension("optimize_nor", sources=["optimize_nor.pyx"],
#               #sources=["optimize_nor.pyx", "predict_c_funcs.c"],
#               extra_compile_args = ["-O2", "-fopenmp"],
#               extra_link_args=['-fopenmp']
#               )
# setup(
#     name="optimize_nor",
#     ext_modules = cythonize([ext2], annotate=True),
#     include_dirs = [np.get_include()]
# )

setup(
    include_dirs = [np.get_include(), '.'],
    cmdclass = {'build_ext': build_ext},
   	ext_modules = cythonize('clustertest_nor.pyx', annotate=True),
)
setup(
    include_dirs = [np.get_include(), '.'],
    cmdclass = {'build_ext': build_ext},
    ext_modules = cythonize('encode_nor.pyx', annotate=True),
)
# setup(
#     include_dirs = [np.get_include(), '.'],
#     cmdclass = {'build_ext': build_ext},
#     ext_modules = cythonize('encode_nor.pyx', annotate=True),
# )
setup(
    include_dirs = [np.get_include(), '.'],
    cmdclass = {'build_ext': build_ext},
    ext_modules = cythonize('decode.pyx', annotate=True),
)


# sourcefiles = ['mcmm_wwb.pyx', 'clustertest_wwb.c', 'cg_wwb.c', 'optimize_wwb.c', 'predict_wwb.c', 'decode.c', 'encode_wwb.c', 'dealloc.c']

# setup(
#     include_dirs = [np.get_include(), '.'],
#     cmdclass = {'build_ext': build_ext},
#     ext_modules = [Extension("mcmm_wwb", sourcefiles)]
# )
setup(
    include_dirs = [np.get_include(), '.'],
    cmdclass = {'build_ext': build_ext},
    ext_modules = cythonize('mcmm_nor.pyx', annotate=True),
)
print "\n\nsetup 6\n\n"
# setup(
#     include_dirs = [np.get_include(), '.'],
#     cmdclass = {'build_ext': build_ext},
#    	ext_modules = cythonize('mcmm_sp2.pyx', annotate=True),
# )

setup(
    include_dirs = [np.get_include(), '.'],
    cmdclass = {'build_ext': build_ext},
   	ext_modules = cythonize('wrapper_nor.pyx', annotate=True),
	)
	
# setup(
#     include_dirs = [np.get_include(), '.'],
#     cmdclass = {'build_ext': build_ext},
#    	ext_modules = cythonize('set_ops.pyx', annotate=True)
#    )
   	
setup(
    include_dirs = [np.get_include(), '.'],
    cmdclass = {'build_ext': build_ext},
    ext_modules = cythonize('bcubed_eval.pyx'), # accepts a glob pattern 
)

print "\n\nsetup 7\n\n"