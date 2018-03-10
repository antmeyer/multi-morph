double R_and_E(double** R, double* M_data, int * M_indices, 
					int * M_indptr, double** C, double** X, 
					int I, int J, int K, double normConstant);

double R_and_E_omp(double** R, double* M_data, int * M_indices, 
					int * M_indptr, double** C, double** X, 
					int I, int J, int K, double normConstant);

double R_and_E_nsp(double** R, double** M, double** C, double** X,
						int I, int J, int K, double normConstant);

double R_and_E_nsp_omp(double** R, double** M, double** C, double** X,
						int I, int J, int K, double normConstant);

double R_E_and_Grad_C(double** Grad, double* M_data, int * M_indices, int * M_indptr,
						double** C, double** X, double** R,
						int I, int J, int K, double normConstant);

double R_E_and_Grad_C_omp(double** Grad, double* M_data, 
						int * M_indices, int * M_indptr,
						double** C, double** X, double** R,
						int I, int J, int K, double normConstant);				

double R_E_and_Grad_C_nsp(double** Grad,
						double** M, double** C, double** X, double** R,
						int I, int J, int K, double normConstant);

double R_E_and_Grad_C_nsp_omp(double** Grad,
						double** M, double** C, double** X, double** R,
						int I, int J, int K, double normConstant);			

double r_and_e(double* r, double* m, double *C_data, int *C_indices, 
			int *C_indptr, double* x, int J, int K, double normConstant); 

double r_and_e_omp(double* r, double* m, double *C_data, int *C_indices, 
			int *C_indptr, double* x, int J, int K, double normConstant); 

double r_and_e_nsp(double* r, double* m, double **C, double* x,
				int J, int K, double normConstant);

double r_and_e_nsp_omp(double* r, double* m, double** C, 
					double* x, int J, int K, double normConstant); 

double r_e_and_grad_m(double* grad, double* m, 
			double *C_data, int *C_indices, 
			int *C_indptr, double* x, double* r, 
			int J, int K, double normConstant);

double r_e_and_grad_m_omp(double* grad, double* m, double *C_data, int *C_indices, 
			int *C_indptr, double* x, double* r, 
			int J, int K, double normConstant);

double r_e_and_grad_m_nsp(double* grad, double* m, double **C, 
			double* x, double* r, 
			int J, int K, double normConstant);

double r_e_and_grad_m_nsp_omp(double* grad, double* m, double **C, 
			double* x, double* r, 
			int J, int K, double normConstant);

int inv_diag_bfgs(double* diagH, double* s, double* y, double* Hy, 
					double sTy, int N, double* p);
	
int inv_diag_bfgs_omp(double* diagH, double* s, double* y, double* Hy, 
					double sTy, int N, double* p);

int cluster_to_split_omp(double* M_data, int* M_indices, int* M_indptr, double** C, 
					double** X, double** R, int I, int J, int K, double normConstant);

int cluster_to_split_nsp(double** M, double** C, 
					double** X, double** R, int I, int J, int K, double normConstant);

int cluster_to_split_nsp_omp(double** M, double** C, 
					double** X, double** R, int I, int J, int K, double normConstant);
