#!/bin/bash

python remove_roots_with_middle_y.py T_analyses.txt > TS_analyses_roots.txt
python file_in_patterns_T.py T_analyses_roots.txt > TS_analyses_pats.txt
python binyanim.py T_analyses_pats.txt > TS_analyses_mod.txt

python remove_accents.py TS_analyses_mod.txt > TR_analyses_mod.txt

python remove_roots_with_middle_y_O.py O_analyses.txt > O_analyses_roots.txt
python file_in_patterns_O.py O_analyses_roots.txt > O_analyses_pats.txt
python binyanim_O.py O_analyses_pats.txt O_analyses_pats.txt > O_analyses_mod.txt