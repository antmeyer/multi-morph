 #include <stdio.h>
 #include <stdlib.h>
 #include <omp.h>
 #include "predict_c_funcs.h"

double R_and_E(double** R, double* M_data, int * M_indices, 
					int * M_indptr, double** C, double** X, 
					int I, int J, int K, double normConstant)
{					
	double E = 0.0;

	for (int i=0; i<I; i++) 
	{
		int m_row_start = M_indptr[i];
		int m_row_end = M_indptr[i+1];
		for (int j=0; j<J; j++) {
			double prod = 1.0;
			for (int k_ptr=m_row_start; k_ptr<m_row_end; ++k_ptr)
			{
				prod *= (1.0 - M_data[k_ptr]*C[j][M_indices[k_ptr]]);
			}
			R[i][j] = 1.0 - prod;
		}
	}

	for (int i=0; i<I; i++) {
		for (int j=0; j<J; j++) {
			E += (R[i][j] - X[i][j]) * (R[i][j] - X[i][j]);
		}	
	}
	return 0.5*E*normConstant;
}

double R_and_E_omp(double** R, double* M_data, int* M_indices, 
					int * M_indptr, double** C, double** X, 
					int I, int J, int K, double normConstant)
{					
	double E = 0.0;
	// #pragma omp parallel
	// {
	double prod;
	#pragma omp parallel for private(prod)
	for (int i=0; i<I; i++) 
	{
		int m_row_start = M_indptr[i];
		int m_row_end = M_indptr[i+1];
		for (int j=0; j<J; j++) {
			prod = 1.0;
			for (int k_ptr=m_row_start; k_ptr<m_row_end; ++k_ptr)
			{
				prod *= (1.0 - M_data[k_ptr]*C[j][M_indices[k_ptr]]);
			}
			R[i][j] = 1.0 - prod;
		}
	}

	#pragma omp parallel for reduction(+:E)
	for (int i=0; i<I; i++) {
		for (int j=0; j<J; j++) {
			E += (R[i][j] - X[i][j]) * (R[i][j] - X[i][j]);
		}	
	}
	// }
	return 0.5*E*normConstant;
}

double R_and_E_nsp(double** R, double** M, double** C, double** X,
				int I, int J, int K, double normConstant)
{					
	double prod_j, diff_j;
	int i, j, k;			
	double E = 0.0;
	for (i=0; i<I; ++i)
	{
		for (j=0; j<J; ++j)
		{
			prod_j = 1.0;
			for (k=0; k<K; ++k) {
				prod_j *= (1.0 - M[i][k] * C[j][k]);
			}
			R[i][j] = 1.0 - prod_j;
			diff_j = R[i][j] - X[i][j];
			E += diff_j*diff_j;
		}
	}
	return 0.5*E*normConstant;
}

double R_and_E_nsp_omp(double** R, double** M, double** C, double** X,
				int I, int J, int K, double normConstant)
{					
	double E = 0.0;
	#pragma omp parallel
	{
		#pragma omp for
		for (int i=0; i<I; i++) 
		{
			for (int j=0; j<J; j++) {
				double prod = 1.0;
				for (int k=0; k<K; ++k)
				{
					prod *= (1.0 - M[i][k]*C[j][k]);
				}
				R[i][j] = 1.0 - prod;
			}
		}

		#pragma omp for reduction(+:E)
		for (int i=0; i<I; i++) {
			for (int j=0; j<J; j++) {
				E += (R[i][j] - X[i][j]) * (R[i][j] - X[i][j]);
			}	
		}
	}
	return 0.5*E*normConstant;
}

double R_E_and_Grad_C(double** Grad, double* M_data, int * M_indices, int * M_indptr,
						double** C, double** X, double** R,
						int I, int J, int K, double normConstant)
 {	
	double E = 0.0;				
	double *Diff = (double *)malloc(I*J * sizeof(double));
	for (int j=0; j<J; j++) {
		for (int k=0; k<K; k++) {
			Grad[j][k] = 0.0;
		}
	}

	for (int i=0; i<I; i++) 
	{
		int m_row_start = M_indptr[i];
		int m_row_end = M_indptr[i+1];
		for (int j=0; j<J; j++) {
			double prod = 1.0;
			for (int k_ptr=m_row_start; k_ptr<m_row_end; ++k_ptr)
			{
				prod *= (1.0 - M_data[k_ptr]*C[j][M_indices[k_ptr]]);
			}
			R[i][j] = 1.0 - prod;
			Diff[i*J + j] = R[i][j] - X[i][j];
		}
	}

	for (int i=0; i<I; i++) {
		for (int j=0; j<J; j++) {
			E += Diff[i*J + j] * Diff[i*J + j];
		}			
	}

	for (int i=0; i<I; ++i) 
	{
		int m_row_start = M_indptr[i];
		int m_row_end = M_indptr[i+1];
		for (int j=0; j<J; ++j) 
		{
			double s = (-R[i][j] + 1.0) * Diff[i*J + j] * normConstant;
			if (s*s > 0.0)
			{
				for (int k_ptr=m_row_start; k_ptr<m_row_end; ++k_ptr) 
				{
					// We consider only "nonzero" row-indices of M, for if
					// M[i][k] is zero, nothing can be added to the cell
					// Grad[j][k].
					double m = M_data[k_ptr];
					double denom = 1.0 - m*C[j][M_indices[k_ptr]];
					if (denom*denom > 0.0) {
						Grad[j][M_indices[k_ptr]] += ( s / denom ) * m;
					}
				}
			}
		}
	}
	free(Diff);
	return 0.5*E*normConstant;
}

double R_E_and_Grad_C_omp(double** Grad,
						double* M_data, int * M_indices, int * M_indptr,
						double** C, double** X, double** R,
						int I, int J, int K, double normConstant)
 {					
	//double E;
	//double *Diff = (double *)malloc(I*J * sizeof(double));
	double *Diff = (double *)calloc(I*J, sizeof(double));
	//double s, m, denom, 
	double prod, E;

	// #pragma omp parallel for
	// for (int j=0; j<J; j++) {
	// 	for (int k=0; k<K; k++) {
	// 		Grad[j][k] = 0.0;
	// 	}
	// }
	#pragma omp parallel
	{
		#pragma omp for
		for (int j=0; j<J; j++) {
			for (int k=0; k<K; k++) {
				Grad[j][k] = 0.0;
			}
		}
		#pragma omp for private(prod)
		for (int i=0; i<I; i++) 
		{
			int m_row_start = M_indptr[i];
			int m_row_end = M_indptr[i+1];
			for (int j=0; j<J; j++) {
				prod = 1.0;
				for (int k_ptr=m_row_start; k_ptr<m_row_end; ++k_ptr)
				{
					prod *= (1.0 - M_data[k_ptr]*C[j][M_indices[k_ptr]]);
				}
				R[i][j] = 1.0 - prod;
				Diff[i*J + j] = R[i][j] - X[i][j];
			}
		}

		E = 0.0;
		#pragma omp for reduction(+:E)
		for (int i=0; i<I; i++) {
			for (int j=0; j<J; j++) {
				E += Diff[i*J + j] * Diff[i*J + j];
				//E += (R[i][j] - X[i][j])*(R[i][j] - X[i][j])
			}	
		}

		double * private_Grad = (double *)calloc(J*K, sizeof(double));

		#pragma omp for
		for (int i=0; i<I; ++i) 
		{
			int m_row_start = M_indptr[i];
			int m_row_end = M_indptr[i+1];
			for (int j=0; j<J; ++j) 
			{
				double s = (-R[i][j] + 1.0) * Diff[i*J + j] * normConstant;
				if (s*s > 0.0)
				{
					for (int k_ptr=m_row_start; k_ptr<m_row_end; ++k_ptr) 
					{
						// We consider only "nonzero" row-indices of M, for if
						// M[i][k] is zero, nothing can be added to the cell
						// Grad[j][k].
						double m = M_data[k_ptr];
						double denom = 1.0 - m*C[j][M_indices[k_ptr]];
						if (denom*denom > 0.0) {
							private_Grad[j*K + M_indices[k_ptr]] += ( s / denom ) * m;
						}
					}
				}
			}
		}
		#pragma omp critical
		for (int j=0; j<J; ++j) 
		{
			for (int k=0; k<K; ++k)
			//for (int k_ptr=m_row_start; k_ptr<m_row_end; ++k_ptr) 
			{
				Grad[j][k] += private_Grad[j*K + k];
			}
		}
		free(private_Grad);
	}
	free(Diff);
	return 0.5*E*normConstant;
}

double R_E_and_Grad_C_nsp(double** Grad,
						double** M, double** C, double** X, double** R,
						int I, int J, int K, double normConstant)
 {					
	double E = 0.0;
	double *Diff = (double *)malloc(I*J * sizeof(double));

	for (int j=0; j<J; j++) {
		for (int k=0; k<K; k++) {
			Grad[j][k] = 0.0;
		}
	}

	for (int i=0; i<I; i++) 
	{
		for (int j=0; j<J; j++) {
			double prod = 1.0;
			for (int k=0; k<K; ++k)
			{
				prod *= (1.0 - M[i][k]*C[j][k]);
			}
			R[i][j] = 1.0 - prod;
			Diff[i*J + j] = R[i][j] - X[i][j];
		}
	}

	for (int i=0; i<I; i++) {
		for (int j=0; j<J; j++) {
			E += Diff[i*J + j] * Diff[i*J + j];
		}	
	}

	for (int i=0; i<I; ++i) 
	{
		for (int j=0; j<J; ++j) 
		{
			double s = (-R[i][j] + 1.0) * Diff[i*J + j] * normConstant;
			if (s*s > 0.0)
			{
				for (int k=0; k<K; ++k)
				{
					double m = M[i][k];
					double denom = 1.0 - m*C[j][k];
					if (denom*denom > 0.0) {
						Grad[j][k] += ( s / denom ) * m;
					}
				}
			}
		}
	}

	free(Diff);
	return 0.5*E*normConstant;
}

double R_E_and_Grad_C_nsp_omp(double** Grad,
						double** M, double** C, double** X, double** R,
						int I, int J, int K, double normConstant)
 {	
 	double E;				
	double *Diff = (double *)malloc(I*J * sizeof(double));
	#pragma omp parallel
	{
		#pragma omp for
		for (int j=0; j<J; j++) {
			for (int k=0; k<K; k++) {
				Grad[j][k] = 0.0;
			}
		}
		#pragma omp for
		for (int i=0; i<I; i++) 
		{
			for (int j=0; j<J; j++) {
				double prod = 1.0;
				for (int k=0; k<K; ++k)
				{
					prod *= (1.0 - M[i][k]*C[j][k]);
				}
				R[i][j] = 1.0 - prod;
				Diff[i*J + j] = R[i][j] - X[i][j];
			}
		}
		E = 0.0;
		#pragma omp for reduction(+:E)
		for (int i=0; i<I; i++) {
			for (int j=0; j<J; j++) {
				E += Diff[i*J + j] * Diff[i*J + j];
			}	
		}

		double * private_Grad = (double *)calloc(J*K, sizeof(double));

		#pragma omp for //private(m,denom)
		for (int i=0; i<I; ++i) 
		{
			for (int j=0; j<J; ++j) 
			{
				double s = (-R[i][j] + 1.0) * Diff[i*J + j] * normConstant;
				if (s*s > 0.0)
				{
					for (int k=0; k<K; ++k)
					{
						double m = M[i][k];
						double denom = 1.0 - m*C[j][k];
						if (denom*denom > 0.0) {
							private_Grad[j*K + k] += ( s / denom ) * m;
						}
					}
				}
			}
		}
		#pragma omp critical
		for (int j=0; j<J; ++j) 
		{
			for (int k=0; k<K; ++k) 
			{
				Grad[j][k] += private_Grad[j*K + k];
			}
		}
		free(private_Grad);
	}
	free(Diff);
	return 0.5*E*normConstant;
}


double r_and_e(double* r, double* m, double *C_data, int *C_indices, 
			int *C_indptr, double* x, int J, int K, double normConstant) 
{
	double error = 0.0;
	for (int j=0; j<J; ++j) 
	{
		double row_start = C_indptr[j];
		double row_end = C_indptr[j+1];
		double prod_j = 1.0;
		for (int k_ptr=row_start; k_ptr<row_end; ++k_ptr) 
		{
			prod_j *= (1.0 - m[C_indices[k_ptr]] * C_data[k_ptr]);
		}
		r[j] = 1.0 - prod_j;
	}
	error=0.0;
	for (int j=0; j<J; ++j) 
	{
		double diff_j = r[j] - x[j];
		//error += (r[j] - x[j])*(r[j] - x[j]);
		error += diff_j*diff_j;
	}
	return 0.5*error*normConstant;
}

double r_and_e_omp(double* r, double* m, double *C_data, int *C_indices, 
			int *C_indptr, double* x, int J, int K, double normConstant) 
{
	double error;
	#pragma omp parallel
	{
		#pragma omp for
		for (int j=0; j<J; ++j) 
		{
			double row_start = C_indptr[j];
			double row_end = C_indptr[j+1];
			double prod_j = 1.0;
			for (int k_ptr=row_start; k_ptr<row_end; ++k_ptr) 
			{
				prod_j *= (1.0 - m[C_indices[k_ptr]] * C_data[k_ptr]);
			}
			r[j] = 1.0 - prod_j;
		}
		error = 0.0;
		#pragma omp for reduction(+:error)
		for (int j=0; j<J; ++j) 
		{
			double diff_j = r[j] - x[j];
			error += diff_j*diff_j;
		}
	}
	return 0.5*error*normConstant;
}

double r_and_e_nsp(double* r, double* m, double **C, double* x,
				int J, int K, double normConstant) 
{
	double error;
	for (int j=0; j<J; ++j) 
	{
		double prod_j = 1.0;
		for (int k=0; k<K; ++k)
		{
			prod_j *= (1.0 - m[k] * C[j][k]);
		}
		r[j] = 1.0 - prod_j;
	}
	error = 0.0;
	for (int j=0; j<J; ++j) 
	{
		double diff_j = r[j] - x[j];
		error += diff_j*diff_j;
	}
	return 0.5*error*normConstant;
}

double r_and_e_nsp_omp(double* r, double* m, double** C, 
					double* x, int J, int K, double normConstant) 
{
	double error;
	#pragma omp parallel
	{
		#pragma omp for
		for (int j=0; j<J; ++j) 
		{
			double prod_j = 1.0;
			for (int k=0; k<K; ++k)
			{
				prod_j *= (1.0 - m[k] * C[j][k]);
			}
			r[j] = 1.0 - prod_j;
		}
		error = 0.0;
		#pragma omp for reduction(+:error)
		for (int j=0; j<J; ++j) 
		{
			double diff_j = r[j] - x[j];
			error += diff_j*diff_j;
		}
	}
	return 0.5*error*normConstant;
}

double r_e_and_grad_m(double* grad, double* m, double *C_data, int *C_indices, 
			int *C_indptr, double* x, double* r,
			int J, int K, double normConstant)
{
	double error = 0.0;
	for (int k=0; k<K; ++k) {
		grad[k] = 0.0;
	}
	double *diff = (double *)malloc(J * sizeof(double));
	for (int j=0; j<J; j++) {
		int row_start = C_indptr[j];
		int row_end = C_indptr[j+1];
		double prod = 1.0;
		for (int k_ptr=row_start; k_ptr<row_end; ++k_ptr)
		{
			prod *= (1.0 - m[C_indices[k_ptr]] * C_data[k_ptr]);
		}
		r[j] = 1.0 - prod;
		diff[j] = r[j] - x[j];
	}

	for (int j=0; j<J; j++) {
		error += diff[j]*diff[j];
	}	

	for (int j=0; j<J; ++j) 
	{
		int row_start = C_indptr[j];
		int row_end = C_indptr[j+1];
		double s = (-r[j] + 1.0) * diff[j] * normConstant;
		if (s*s > 0.0)
		{
			for (int k_ptr=row_start; k_ptr<row_end; ++k_ptr) 
			{
				// We consider only "nonzero" row-indices of M, for if
				// M[i][k] is zero, nothing can be added to the cell
				// Grad[j][k].
				double c = C_data[k_ptr];
				double denom = 1.0 - m[C_indices[k_ptr]] * c;
				if (denom*denom > 0.0) {
					grad[C_indices[k_ptr]] += ( s / denom ) * c;
				} 
			}
		}
	}
	free(diff);
	return 0.5*error*normConstant;
}

double r_e_and_grad_m_omp(double* grad, double* m, double *C_data, int *C_indices, 
			int *C_indptr, double* x, double* r, 
			int J, int K, double normConstant)
{
	double *diff = (double *)malloc(J * sizeof(double));
	double error;
	double prod;
	#pragma omp parallel
	{
		#pragma omp for
		for (int k=0; k<K; k++) {
			grad[k] = 0.0;
		}
		#pragma omp for private(prod)
		for (int j=0; j<J; j++) {
			int row_start = C_indptr[j];
			int row_end = C_indptr[j+1];
			prod = 1.0;
			for (int k_ptr=row_start; k_ptr<row_end; ++k_ptr)
			{
				prod *= (1.0 - m[C_indices[k_ptr]] * C_data[k_ptr]);
			}
			r[j] = 1.0 - prod;
			diff[j] = r[j] - x[j];
		}
		
		error = 0.0;
		
		#pragma omp for reduction(+:error)
		for (int j=0; j<J; j++) {
			error += diff[j]*diff[j];
		}	

		double * private_Grad = (double *)calloc(K, sizeof(double));


		for (int j=0; j<J; ++j) 
		{
			int row_start = C_indptr[j];
			int row_end = C_indptr[j+1];
			double s = (-r[j] + 1.0) * diff[j] * normConstant;
			if (s*s > 0.0)
			{
				for (int k_ptr=row_start; k_ptr<row_end; ++k_ptr) 
				{
					// We consider only "nonzero" row-indices of M, for if
					// M[i][k] is zero, nothing can be added to the cell
					// Grad[j][k].
					double c = C_data[k_ptr];
					double denom = 1.0 - m[C_indices[k_ptr]] * c;
					if (denom*denom > 0.0) {
						private_Grad[C_indices[k_ptr]] += ( s / denom ) * c;
					}
				}
			}
		}
		#pragma omp critical
		for (int j=0; j<J; ++j) 
		{
			int row_start = C_indptr[j];
			int row_end = C_indptr[j+1];
			//for (int k=0; k<K; ++k)
			for (int k_ptr=row_start; k_ptr<row_end; ++k_ptr) 
			{
				grad[C_indices[k_ptr]] += private_Grad[C_indices[k_ptr]];
			}
		}
		free(private_Grad);
	}
	free(diff);
	return 0.5 * error * normConstant;
}

double r_e_and_grad_m_nsp(double* grad, double* m, double **C, 
			double* x, double* r, 
			int J, int K, double normConstant)
{
	double error;
	for (int k=0; k<K; ++k) {
		grad[k] = 0.0;
	}
	double *diff = (double *)malloc(J * sizeof(double));
	for (int j=0; j<J; j++) {
		double prod = 1.0;
		for (int k=0; k<K; ++k)
		{
			prod *= (1.0 - m[k] * C[j][k]);
		}
		r[j] = 1.0 - prod;
		diff[j] = r[j] - x[j];
	}
	error = 0.0;
	for (int j=0; j<J; j++) {
		error += diff[j]*diff[j];
	}	

	for (int j=0; j<J; ++j) 
	{
		double s = (-r[j] + 1.0) * diff[j] * normConstant;
		if (s*s > 0.0)
		{
			for (int k=0; k<K; ++k) 
			{
				// We consider only "nonzero" row-indices of M, for if
				// M[i][k] is zero, nothing can be added to the cell
				// Grad[j][k].
				double c = C[j][k];
				double denom = 1.0 - m[k] * c;
				if (denom*denom > 0.0) {
					grad[k] += ( s / denom ) * c;
				} 
			}
		}
	}
	free(diff);
	return 0.5*error*normConstant;
}

double r_e_and_grad_m_nsp_omp(double* grad, double* m, double **C, 
			double* x, double* r, 
			int J, int K, double normConstant)
{
	double *diff = (double *)malloc(J * sizeof(double));
	double error;
	#pragma omp parallel
	{
		#pragma omp for
		for (int k=0; k<K; k++) {
			grad[k] = 0.0;
		}
		#pragma omp for
		for (int j=0; j<J; j++) {
			double prod = 1.0;
			for (int k=0; k<K; ++k)
			{
				prod *= (1.0 - m[k] * C[j][k]);
			}
			r[j] = 1.0 - prod;
			diff[j] = r[j] - x[j];
		}
		
		error = 0.0;
		#pragma omp for reduction(+:error)
		for (int j=0; j<J; j++) {
			error += diff[j]*diff[j];
		}	

		double * private_Grad = (double *)calloc(K, sizeof(double));
		#pragma omp for 
		for (int j=0; j<J; ++j) 
		{
			double s = (-r[j] + 1.0) * diff[j] * normConstant;
			if (s*s > 0.0)
			{
				for (int k=0; k<K; ++k) 
				{
					double c = C[j][k];
					double denom = 1.0 - m[k] * c;
					if (denom*denom > 0.0) {
						private_Grad[k] += ( s / denom ) * c;
					}
				}
			}
		}
		#pragma omp critical
		for (int j=0; j<J; ++j) 
		{
			for (int k=0; k<K; ++k)
			{
				grad[k] += private_Grad[k];
			}
		}
		free(private_Grad);
	}
	free(diff);
	return 0.5 * error * normConstant;
}

int inv_diag_bfgs(double* diagH, double* s, double* y, double* Hy, 
					double sTy, int N, double* p)
{	
	double HyTy;
	HyTy = 0.0;
	for (int n=0; n<N; ++n) {
		HyTy += Hy[n] * y[n];
	}
	double sTy_inv = 1.0/sTy;
	//double omega = (1.0/sTy) + HyTy/(sTy*sTy);
	double omega = sTy_inv + HyTy*sTy_inv*sTy_inv;
	//double omega = (sTy +  HyTy) / sTy*sTy;
	for (int i=0; i<N; ++i) {
		//diagH[i] += omega*s[i]*s[i]*p[i] - ((2.0*diagH[i]*y[i]*s[i]*p[i]) / sTy);
		diagH[i] += omega*s[i]*s[i]*p[i] - 2.0*diagH[i]*y[i]*s[i]*p[i]*sTy_inv;
	}
	return 0;
}

int inv_diag_bfgs_omp(double* diagH, double* s, double* y, double* Hy, 
					double sTy, int N, double* p)
{	
	double HyTy;
	#pragma omp parallel 
	{
		HyTy = 0.0;
		#pragma omp for reduction(+:HyTy)
		for (int n=0; n<N; ++n) {
			HyTy += Hy[n] * y[n];
		}
		double sTy_inv = 1.0/sTy;
		//double omega = (1.0/sTy) + HyTy/(sTy*sTy);
		double omega = sTy_inv + HyTy*sTy_inv*sTy_inv;
		//double omega = (sTy +  HyTy) / sTy*sTy;
		double * private_diagH = (double *)calloc(N, sizeof(double));
		for (int i=0; i<N; ++i) {
			//diagH[i] += omega*s[i]*s[i]*p[i] - ((2.0*diagH[i]*y[i]*s[i]*p[i]) / sTy);
			private_diagH[i] += s[i]*p[i]*(omega*s[i] - 2.0*diagH[i]*y[i]*sTy_inv);
		}
		#pragma omp critical
		for (int i=0; i<N; ++i) 
		{
			diagH[i] += private_diagH[i];
		}
		free(private_diagH);
	}
	return 0;
}

int cluster_to_split_omp(double* M_data, int* M_indices, int* M_indptr, double** C, 
					double** X, double** R, int I, int J, int K, double normConstant)
{
	//double* Errors = (double *)malloc(K * sizeof(double));
	printf("\n");
	const int N = I*J;
	double* Diff = (double *)malloc(I*J * sizeof(double));
	int k_to_split = 0;
	double E;
	double min_E = 1000000000.0;
	double prod;
	int after_skip, m_row_start, m_row_end, k_ptr;
	for (int k_to_skip=0; k_to_skip<K; ++k_to_skip) {
		#pragma omp parallel for private(prod, k_ptr)
		for (int i=0; i<I; ++i) {
			for (int j=0; j<J; ++j) {
				prod = 1.0;
				for (k_ptr = m_row_start; k_ptr < k_to_skip; k_ptr++) {
					prod *= (1.0 - M_data[k_ptr] * C[j][M_indices[k_ptr]]);
				}
				after_skip = k_ptr;
				if (M_indices[k_ptr] <= k_to_skip) after_skip++;
				for (k_ptr = after_skip; k_ptr < m_row_end; k_ptr++) {
					prod *= (1.0 - M_data[k_ptr] * C[j][M_indices[k_ptr]]);
				}
				R[i][j] = 1.0 - prod;
				Diff[i*J + j] = R[i][j] - X[i][j];
			}
		}
		E = 0.0;
		#pragma omp parallel for reduction(+:E)
		for (int n=0; n<N; ++n) {
			E += Diff[n]*Diff[n];	
		}
		printf("OMP: Considering cluster %d. E = %f\n", k_to_skip, E);
		if (E < min_E) {
			min_E = E;
			k_to_split = k_to_skip;
		}		
	}
	printf("OMP min_E = %f\n", min_E);
	free(Diff);
	return k_to_split;
}

int cluster_to_split_nsp(double** M, double** C, 
					double** X, double** R, int I, int J, int K, double normConstant)
{
	double* Diff = (double *)malloc(I*J * sizeof(double));
	int k_to_split = 0;
	double E;
	double min_E = 1000000000.0;
	int k, k_to_skip;
	k_to_skip=0;
	for (k_to_skip=0; k_to_skip<K; ++k_to_skip) {
		//k_to_split = k_to_skip&;
		//double E = 0.0
		//int k_to_skip = k;
		//printf("Considering cluster %d...\n", k_to_skip);
		double prod;
		//double prod_to_skip;
		for (int i=0; i<I; ++i) {
			// int m_row_start = M_indptr[i];
			// int m_row_end = M_indptr[i+1];
			for (int j=0; j<J; ++j) {
				prod = 1.0;
				//prod_to_skip = 1.0 - M[i][k_to_skip] * C[j][k_to_skip];
				// for (int k_ptr = m_row_start; k_ptr < k_to_skip; k_ptr++) {
				// 	prod *= (1.0 - M_data[k_ptr] * C[j][M_indices[k_ptr]]);
				// }
				// for (int k_ptr = k_to_skip; k_ptr < m_row_end; k_ptr++) {
				// 	prod *= (1.0 - M_data[k_ptr] * C[j][M_indices[k_ptr]]);
				// }
				for (k=0; k<k_to_skip; k++) {
					prod *= (1.0 - M[i][k] * C[j][k]);
				}
				for (k=k_to_skip+1; k<K; k++) {
					prod *= (1.0 - M[i][k] * C[j][k]);
				}
				// for (inr k=0; k<K; ++k) {
				// 	prod *= (1.0 - M[i][k] * C[j][k]);
				// }
				// R[i][j] = 1.0 - prod/prod_to_skip;
				R[i][j] = 1.0 - prod;
				Diff[i*J + j] = R[i][j] - X[i][j];
			}
		}
		E = 0.0;
		for (int i=0; i<I; ++i) {
			for (int j=0; j<J; ++j) {
				E += Diff[i*J + j]*Diff[i*J + j];
			}	
		}
		printf("Considering cluster %d. E = %f\n", k_to_skip, E);
		if (E < min_E) {
			min_E = E;
			k_to_split = k_to_skip;
		}
	
	}
	printf("reg min_E = %f\n", min_E);
	free(Diff);	
	return k_to_split;	
}

int cluster_to_split_nsp_omp(double** M, double** C, 
					double** X, double** R, int I, int J, int K, double normConstant)
{
	//double* Errors = (double *)malloc(K * sizeof(double));
	printf("\n");
	const int N = I*J;
	double* Diff = (double *)malloc(I*J * sizeof(double));
	int k_to_split = 0;
	double E;
	double min_E = 1000000000.0;
	double prod;
	int k_to_skip, k;
	k_to_skip=0;
	for (k_to_skip=0; k_to_skip<K; ++k_to_skip) {
		//k_to_split = k_to_skip&;
		//double E = 0.0
		//int k_to_skip = k;
		//#pragma omp parallel { 

		
		//double prod_to_skip;
		//#pragma omp parallel {
		//double prod;
		#pragma omp parallel for private(prod, k)
		for (int i=0; i<I; ++i) {
			// int m_row_start = M_indptr[i];
			// int m_row_end = M_indptr[i+1];

			for (int j=0; j<J; ++j) {
				prod = 1.0;
				//prod_to_skip = 1.0 - M[i][k_to_skip] * C[j][k_to_skip];
				// for (int k_ptr = m_row_start; k_ptr < k_to_skip; k_ptr++) {
				// 	prod *= (1.0 - M_data[k_ptr] * C[j][M_indices[k_ptr]]);
				// }
				// for (int k_ptr = k_to_skip; k_ptr < m_row_end; k_ptr++) {
				// 	prod *= (1.0 - M_data[k_ptr] * C[j][M_indices[k_ptr]]);
				// }
				for (k=0; k<k_to_skip; k++) {
					prod *= (1.0 - M[i][k] * C[j][k]);
				}
				for (k=k_to_skip+1; k<K; k++) {
					prod *= (1.0 - M[i][k] * C[j][k]);
				}
				// for (inr k=0; k<K; ++k) {
				// 	prod *= (1.0 - M[i][k] * C[j][k]);
				// }
				//R[i][j] = 1.0 - prod/prod_to_skip;
				R[i][j] = 1.0 - prod;
				//Diff[i*J + j] = (R[i][j] - X[i][j]) * (R[i][j] - X[i][j]);
				Diff[i*J + j] = R[i][j] - X[i][j];
			}
		}
		//}
		E = 0.0;
		// #pragma omp parallel for reduction(+:E)
		// for (int i=0; i<I; ++i) {
		// 	for (int j=0; j<J; ++j) {
		// 		//E += Diff[i*J + j]*Diff[i*J + j];
		// 		E += Diff[n];
		// 	}	
		// }
		#pragma omp parallel for reduction(+:E)
		for (int n=0; n<N; ++n) {
			E += Diff[n]*Diff[n];	
		}
		printf("OMP: Considering cluster %d. E = %f\n", k_to_skip, E);
		if (E < min_E) {
			min_E = E;
			k_to_split = k_to_skip;
		}		
	}
	printf("OMP min_E = %f\n", min_E);
	free(Diff);
	return k_to_split;
}
