#include <stdio.h>
#include <stdlib.h>
#include <omp.h>
#include <math.h>
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
	double *Diff = (double *)malloc(I*J * sizeof(double));;
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
	//double *Diff = (double *)malloc(I*J * sizeof(double));;
	double *Diff = (double *)calloc(I*J, sizeof(double));;
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
	double *Diff = (double *)malloc(I*J * sizeof(double));;

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

double R_E_and_Grad_C_nsp_omp(double* vec_Grad,
						double** M, double** C, double** X, double** R,
						int I, int J, int K, double normConstant)
 {	
 	double E;				
	double *Diff = (double *)malloc(I*J * sizeof(double));;
	#pragma omp parallel
	{
		#pragma omp for
		for (int j=0; j<J; j++) {
			for (int k=0; k<K; k++) {
				vec_Grad[j*K + k] = 0.0;
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

		double * private_Grad = (double *)calloc(J*K, sizeof(double));;

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
				vec_Grad[j*K + k] += private_Grad[j*K + k];
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
	double *diff = (double *)malloc(J * sizeof(double));;
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
	double *diff = (double *)malloc(J * sizeof(double));;
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

		double * private_Grad = (double *)calloc(K, sizeof(double));;


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
	double *diff = (double *)malloc(J * sizeof(double));;
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
	double *diff = (double *)malloc(J * sizeof(double));;
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

		double * private_Grad = (double *)calloc(K, sizeof(double));;
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
	//double omega = sTy_inv + HyTy*sTy_inv*sTy_inv;
	double omega = sTy_inv*(1.0 + HyTy*sTy_inv);
	//double omega = (sTy +  HyTy) / sTy*sTy;
	for (int n=0; n<N; ++n) {
		//diagH[n] += omega*s[n]*s[n]*p[n] - ((2.0*diagH[n]*y[n]*s[n]*p[n]) / sTy);
		diagH[n] += s[n]*p[n]*(omega*s[n] - 2.0*diagH[n]*y[n]*sTy_inv);
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
		double * private_diagH = (double *)calloc(N, sizeof(double));;
		// for (int i=0; i<N; ++i) {
		// 	//diagH[i] += omega*s[i]*s[i]*p[i] - ((2.0*diagH[i]*y[i]*s[i]*p[i]) / sTy);
		// 	private_diagH[i] += s[i]*p[i]*(omega*s[i] - 2.0*diagH[i]*y[i]*sTy_inv);
		// }
		for (int n=0; n<N; ++n) {
			//diagH[n] += omega*s[n]*s[n]*p[n] - ((2.0*diagH[n]*y[n]*s[n]*p[n]) / sTy);
			private_diagH[n] += s[n]*p[n]*(omega*s[n] - 2.0*private_diagH[n]*y[n]*sTy_inv);
		}
		#pragma omp critical
		for (int n=0; n<N; ++n) 
		{
			diagH[n] += private_diagH[n];
		}
		free(private_diagH);
	}
	return 0;
}

int cluster_to_split_omp(double* M_data, int* M_indices, int* M_indptr, double** C, 
					double** X, double** R, int I, int J, int K, double normConstant)
{
	//double* Errors = (double *)malloc(K * sizeof(double));;
	printf("\n");
	const int N = I*J;
	double* Diff = (double *)malloc(I*J * sizeof(double));;
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
	double* Diff = (double *)malloc(I*J * sizeof(double));;
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
	//double* Errors = (double *)malloc(K * sizeof(double));;
	printf("\n");
	const int N = I*J;
	double* Diff = (double *)malloc(I*J * sizeof(double));;
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

double armijo2_M_increase_alpha_nor(double a_higher, double phi_a_higher,
				double a_lower, double phi_a_lower,
				double phi_0, double der_phi_0,
				double c1,
				double* m_test, int i,
				double** C, double* C_data, int* C_indices, int* C_indptr,
				double** X_ptr, double** R_ptr,
				double* d, double* d_data, int* d_indices, int* d_indptr,
				double normConstant, int K, int J,
				double lowerBound, double upperBound) {
	int itr = 1;
	int maxitr = 20;
	while(1==1){
		for (int h = 0; h < d_indptr[1]; h++) {
			m_test[d_indices[h]] += a_higher * d_data[h];
			// clip values to ensure that they stay within [0,1]
			if (m_test[d_indices[h]] > upperBound) {
				m_test[d_indices[h]] = upperBound;
			}
			else if (m_test[d_indices[h]] < lowerBound) {
				m_test[d_indices[h]] = lowerBound;		
			}
		}
		phi_a_higher = r_and_e(R_ptr[i], m_test, 
					C_data, C_indices, C_indptr,
					X_ptr[i], J, K, normConstant);

		if (phi_a_higher > phi_0 + c1 * a_higher * der_phi_0) {
			// armijo2_M_correct expects the first two args to be lowest in value.
			// Since we have been increasing, the latest alpha will be largest.
			return a_lower;
		}

		phi_a_lower = phi_a_higher;
		a_lower = a_higher;
		a_higher *= 5.0;
		itr++;
		if (itr > maxitr) {
			// print "\tToo many iterations; returning a_hi =", "{:.6f}".format(a_higher), "\n"
			return a_higher;
		}
		if (phi_a_higher == 1.0 && phi_a_lower == 1.0) {
			return a_higher;
		}
	}
	printf("*** Failed search; returning a_higher = %f\n", a_higher);
	return a_higher;
}

// double armijo2_M_increase_alpha_nor(double a_higher, double phi_a_higher,
// 				double a_lower, double phi_a_lower,
// 				double phi_0, double der_phi_0,
// 				double c1,
// 				double* m0, double* m,
// 				double** C, double* C_data, int* C_indices, int* C_indptr,
// 				double* x, double* r,
// 				double* d, double* d_data, int* d_indices, int* d_indptr,
// 				double normConstant, int K, int J,
// 				double lowerBound, double upperBound) {
// 	int itr = 1;
// 	int maxitr = 20;
// 	while(1==1){
// 		for (int h = 0; h < d_indptr[1]; h++) {
// 			m[d_indices[h]] += a_higher * d_data[h];
// 			// clip values to ensure that they stay within [0,1]
// 			if (m[d_indices[h]] > upperBound) {
// 				m[d_indices[h]] = upperBound;
// 			}
// 			else if (m[d_indices[h]] < lowerBound) {
// 				m[d_indices[h]] = lowerBound;		
// 			}
// 		}
// 		phi_a_higher = r_and_e(r, m, 
// 					C_data, C_indices, C_indptr,
// 					x, J, K, normConstant);

// 		if (phi_a_higher > phi_0 + c1 * a_higher * der_phi_0) {
// 			// armijo2_M_correct expects the first two args to be lowest in value.
// 			// Since we have been increasing, the latest alpha will be largest.
// 			return a_lower;
// 		}

// 		phi_a_lower = phi_a_higher;
// 		a_lower = a_higher;
// 		a_higher *= 5.0;
// 		itr++;
// 		if (itr > maxitr) {
// 			// print "\tToo many iterations; returning a_hi =", "{:.6f}".format(a_higher), "\n"
// 			return a_higher;
// 		}
// 		if (phi_a_higher == 1.0 && phi_a_lower == 1.0) {
// 			return a_higher;
// 		}
// 	}
// 	printf("*** Failed search; returning a_higher = %f\n", a_higher);
// 	return a_higher;
// }

// double armijo2_M_interpolate_nor(double a2, double phi_a2,
// 				double a1, double phi_a1,
// 				double phi_0, double der_phi_0,
// 				double c1, double* m0, double* m,
// 				double** C, double* C_data, int* C_indices, int* C_indptr,
// 				double* x, double* r,
// 				double* d, double* d_data, int* d_indices, int* d_indptr,
// 				double normConstant, int K, int J,
// 				double lowerBound, double upperBound) {
// 	//int itr = 1;
// 	const int maxitr = 20;
// 	double phi_a3 = 0.0;
// 	double a3 = 0.0;
// 	//int extremes, zeros;
// 	double a0 = a1;
// 	//while (itr < maxitr) {
// 	for (int itr=1; itr<maxitr; itr++) {   
// 		if (itr == 1) {
// 			//print "(quad)",
// 			// a2 is the most recent alpha.
// 			a3 = quadratic_interpolate(phi_0, der_phi_0, a2, phi_a2);
// 			if (a3 < 0.0) { a3 = a0 + 0.5*fabs(a0 - a2); }
// 		}						
// 		else {
// 			a3 = cubic(phi_0, der_phi_0, phi_a1, a1, phi_a2, a2);
// 			if (a3 < 0.0) {
// 				a3 = a0 + 0.5*fabs(a0 - a2);
// 			}
// 		}
// 		if (a3 < 0.000000001) return 0.0;	
// 		//extremes = 0;
// 		//zeros = 0;
// 		for (int h=0; h<d_indptr[1]; h++) {   
// 			m[d_indices[h]] = m0[d_indices[h]] + a3 * d_data[h];
// 			// clip values to ensure that they stay within [0,1].
// 			if (m[d_indices[h]] >= upperBound) {
// 				//extremes++;
// 				m[d_indices[h]] = upperBound;
// 			}
// 			else if (m[d_indices[h]] <= lowerBound) {
// 				//extremes++;
// 				//zeros++;
// 				m[d_indices[h]] = lowerBound;
// 			}
// 		}
// 		phi_a3 = r_and_e_nsp(r, m, C, x, J, K, normConstant);
// 		if (a2 == 0.0) return 0.0;
// 		if (phi_a3 <= phi_0 + c1 * a3 * der_phi_0) {
// 			// a2 satisfies the Armijo condition
// 			return a3;
// 		}
// 		a1 = a2;
// 		a2 = a3;
// 		phi_a1 = phi_a2;
// 		phi_a2 = phi_a3;
// 		//itr++;
// 	//print "\n\t**** Search failed; returning a3 =", a3, "\n"
// 	}
// 	return a3;
// }

double armijo2_M_interpolate_nor(double a2, double phi_a2,
				double a1, double phi_a1,
				double phi_0, double der_phi_0,
				double c1, double** M_ptr, double* m_test, int i,
				double** C, double* C_data, int* C_indices, int* C_indptr,
				double** X_ptr, double** R_ptr,
				double* d, double* d_data, int* d_indices, int* d_indptr,
				double normConstant, int K, int J,
				double lowerBound, double upperBound) {
	//int itr = 1;
	const int maxitr = 20;
	double phi_a3 = 0.0;
	double a3 = 0.0;
	//int extremes, zeros;
	double a0 = a1;
	//while (itr < maxitr) {
	for (int itr=1; itr<maxitr; itr++) {   
		if (itr == 1) {
			//print "(quad)",
			// a2 is the most recent alpha.
			a3 = quadratic_interpolate(phi_0, der_phi_0, a2, phi_a2);
			if (a3 < 0.0) { a3 = a0 + 0.5*fabs(a0 - a2); }
		}						
		else {
			a3 = cubic(phi_0, der_phi_0, phi_a1, a1, phi_a2, a2);
			if (a3 < 0.0) {
				a3 = a0 + 0.5*fabs(a0 - a2);
			}
		}
		if (a3 < 0.000000001) return 0.0;	
		for (int h=0; h<d_indptr[1]; h++) {   
			m_test[d_indices[h]] = M_ptr[i][d_indices[h]] + a3 * d_data[h];
			// clip values to ensure that they stay within [0,1].
			if (m_test[d_indices[h]] >= upperBound) {
				//extremes++;
				m_test[d_indices[h]] = upperBound;
			}
			else if (m_test[d_indices[h]] <= lowerBound) {
				//extremes++;
				//zeros++;
				m_test[d_indices[h]] = lowerBound;
			}
		}
		phi_a3 = r_and_e_nsp(R_ptr[i], m_test, C, X_ptr[i], J, K, normConstant);
		if (a2 == 0.0) return 0.0;
		if (phi_a3 <= phi_0 + c1 * a3 * der_phi_0) {
			// a2 satisfies the Armijo condition
			return a3;
		}
		a1 = a2;
		a2 = a3;
		phi_a1 = phi_a2;
		phi_a2 = phi_a3;
		//itr++;
	//print "\n\t**** Search failed; returning a3 =", a3, "\n"
	}
	return a3;
}

double quadratic_interpolate(double phi_0, double der_phi_0, double a_cur, double phi_cur) {
	//double top, bottom, dfcur;
	//dfcur = phi_cur - phi_0;
	double top = der_phi_0 * (a_cur*a_cur);
	double bottom = 2.0*(phi_cur - phi_0 - der_phi_0*a_cur);
	if (bottom == 0.0) return -1.0;
	return -(top / bottom);
}


double cubic_interpolate(double ai_old, double phi_old, double phi_prime_old, 
							double ai, double phi, double phi_prime) {
	// Cubic interpolation.
	// Formula 3.43, page 57, from 'Numerical Optimization' 
	// by Jorge Nocedal && Stephen J. Wright, 1999
	double d1 = phi_prime_old + phi_prime - 3.0 * ((phi_old - phi) / (ai_old - ai));
	double d2 = sqrt(fabs(d1*d1 - phi_prime_old*phi_prime));
	double denom = phi_prime - phi_prime_old + 2.0*d2;
	if (denom == 0.0) return -1;
	return ai - (ai - ai_old) * ((phi_prime + d2 - d1) / denom);
}

double cubic(double phi0, double phi0_prime, 
				double phi_alpha0, double alpha0,
				double phi_alpha1, double alpha1) {
	double a, b, d;
	double factor = alpha0*alpha0 * alpha1*alpha1 * (alpha1 - alpha0);
	if (factor == 0.0) return -1.0;
	a = alpha0*alpha0 * (phi_alpha1 - phi0 - phi0_prime * alpha1) - alpha1*alpha1 * (phi_alpha0 - phi0 - phi0_prime * alpha0);
	a = a / factor;
	b = -alpha0*alpha0*alpha0 * (phi_alpha1 - phi0 - phi0_prime * alpha1) + alpha1*alpha1*alpha1 * (phi_alpha0 - phi0 - phi0_prime * alpha0);
	b = b / factor;
	if (a == 0.0) return -1.0;
	else {
		d = b*b - 3.0 * a * phi0_prime;  //discriminant
		if (d < 0.0) return -1.0;
		else {
			return (-b + sqrt(d)) / (3.0*a);
		}
	}	
}

double armijo2_M_nor(double a_new, double a_max, double c1,
							double phi_0, double der_phi_0,
							double** M_ptr, double* m_test, int i,
							double** C, 
							double* C_data, int* C_indices, int* C_indptr,
							double** X_ptr, double** R_ptr,
							double* d, double* d_data, int* d_indices, int* d_indptr,
							double normConstant, 
							int K, int J, int* itrs,
							double lowerBound, double upperBound) 
{   
	itrs[0] = 0;
	//const int maxitr = 10;
	double phi_a_new = phi_0;
	double a_old = 0.0;
	double phi_a_old = phi_0;

	for (int h = 0; h < d_indptr[1]; h++) {
		m_test[d_indices[h]] = M_ptr[i][d_indices[h]] + a_new * d_data[h];
		//clip values to ensure that they stay within [0,1].
		if (m_test[d_indices[h]] > upperBound) m_test[d_indices[h]] = upperBound;
		else if (m_test[d_indices[h]] < lowerBound) m_test[d_indices[h]] = lowerBound;
	}
	phi_a_new = r_and_e(R_ptr[i], m_test, 
					C_data, C_indices, C_indptr,
					X_ptr[i], J, K, normConstant);
					
	if (phi_a_new <= phi_0 + c1 * a_new * der_phi_0) {      
		return armijo2_M_increase_alpha_nor(a_new, phi_a_new,
				a_old, phi_a_old,	
				phi_0, der_phi_0,
				c1, m_test, i, C, 
				C_data, C_indices, C_indptr,
				X_ptr, R_ptr,
				d, d_data, d_indices, d_indptr,
				normConstant, K, J,
				lowerBound, upperBound);
	}
	//else { //(phi_a_new > phi_0 + c1 * a_new * der_phi_0) {
	return armijo2_M_interpolate_nor(a_new, phi_a_new,
			a_old, phi_a_old, phi_0, der_phi_0,
			c1, M_ptr, m_test, i, C, 
			C_data, C_indices, C_indptr,
			X_ptr, R_ptr,
			d, d_data, d_indices, d_indptr,
			normConstant, K, J,
			lowerBound, upperBound);
	//}
}

// void prelims_slmqn_M(double* grad,
// 					double* grad_data, int* grad_indices, int* grad_indptr,
// 					double* x,
// 					double* diagP0, int* diagP0_indices, int* diagP0_indptr,
// 					int* diagP0_zero_indices, int* diagP0_zero_indptr,
// 					double* diagP1, int* diagP1_indices, int* diagP1_indptr,
// 					int* diagP1_zero_indices, int* diagP1_zero_indptr,
// 					int* diagP2_indices, int* diagP2_indptr,
// 					int* diagP3_indices, int* diagP3_indptr,
// 					double eps, double zero_eps, int J, int K, int N, double l, double u)
// {  
					
// 	double gradFactor;
// 	const double l_plus_eps = l+eps;
// 	const double u_minus_eps = u-eps;
// 	const double boundSum = u+l;
// 	for (int n=0; n<N; n++) {
// 		diagP0[n] = 0.0;
// 		diagP1[n] = 0.0;
// 	}
// 	diagP0_indptr[1] = 0;
// 	diagP1_indptr[1] = 0;
// 	diagP2_indptr[1] = 0;
// 	diagP3_indptr[1] = 0;

// 	// populate V, U1, U2, && U3
// 	for (int n=0; n<N; n++) {  
// 		gradFactor = (boundSum - 2.0*x[n]) * grad[n];
// 		// in the case of descent to toward minimum, is the grad positive or negative?
// 		// --> We want gTd to be negative, && d = -grad initially. That is, d && grad
// 		// point in opposing directions. When this is no longer true, the model
// 		// is moving away from its target.
// 		// However, d is not always going to be negative; its sign just needs to oppose
// 		// the gradient's sign.
// 		if (l_plus_eps < x[n] && x[n] < u_minus_eps) {
// 			diagP0_indices[diagP0_indptr[1]] = n;
// 			diagP0_indptr[1]++;
// 		}
// 		else if ((x[n] == l || x[n] == u) && gradFactor >= 0.0) {
// 			diagP1_indices[diagP1_indptr[1]] = n;
// 			diagP1_indptr[1]++;
// 		}
// 		else if ( ( ( l <= x[n] && x[n] <= l_plus_eps ) || (u_minus_eps <= x[n] &&  x[n] <= u) ) && gradFactor < 0.0 ) {  
// 			diagP2_indices[diagP2_indptr[1]] = n;
// 			diagP2_indptr[1]++;
// 		}
// 		else if ( ( ( l < x[n] && x[n] <= l_plus_eps) || (u_minus_eps <= x[n] && x[n] < u) ) && gradFactor >= 0.0) {  
// 			diagP3_indices[diagP3_indptr[1]] = n;
// 			diagP3_indptr[1]++;
// 		}
// 	}
// 	for (int i=0; i < diagP0_indptr[1]; i++) {
// 		diagP0[diagP0_indices[i]] = 1.0;
// 	}

// 	for (int i=0; i < diagP1_indptr[1]; i++) {
// 		diagP1[diagP1_indices[i]] = 1.0;
// 	}

// 	vector_zeros(diagP0, diagP0_zero_indices, diagP0_zero_indptr, N);
// 	vector_zeros(diagP1, diagP1_zero_indices, diagP1_zero_indptr, N);
// }

void prelims_slmqn_M(double* grad,
					double* grad_data, int* grad_indices, int* grad_indptr,
					double** M_ptr, int i,
					double* diagP0, int* diagP0_indices, int* diagP0_indptr,
					int* diagP0_zero_indices, int* diagP0_zero_indptr,
					double* diagP1, int* diagP1_indices, int* diagP1_indptr,
					int* diagP1_zero_indices, int* diagP1_zero_indptr,
					int* diagP2_indices, int* diagP2_indptr,
					int* diagP3_indices, int* diagP3_indptr,
					double eps, int J, int K, double l, double u)
{  
					
	double gradFactor;
	double l_plus_eps = l+eps;
	double u_minus_eps = u-eps;
	double boundSum = u+l;
	for (int k=0; k<K; k++) {
		diagP0[k] = 0.0;
		diagP1[k] = 0.0;
	}
	diagP0_indptr[1] = 0;
	diagP1_indptr[1] = 0;
	diagP2_indptr[1] = 0;
	diagP3_indptr[1] = 0;

	// populate V, U1, U2, && U3
	for (int k=0; k<K; k++) {  
		gradFactor = (boundSum - 2.0*M_ptr[i][k]) * grad[k];
		// in the case of descent to toward minimum, is the grad positive or negative?
		// --> We want gTd to be negative, && d = -grad initially. That is, d && grad
		// point in opposing directions. When this is no longer true, the model
		// is moving away from its target.
		// However, d is not always going to be negative; its sign just needs to oppose
		// the gradient's sign.
		if (l_plus_eps < M_ptr[i][k] && M_ptr[i][k] < u_minus_eps) {
			diagP0_indices[diagP0_indptr[1]] = k;
			diagP0_indptr[1]++;
		}
		else if ((M_ptr[i][k] == l || M_ptr[i][k] == u) && gradFactor >= 0.0) {
			diagP1_indices[diagP1_indptr[1]] = k;
			diagP1_indptr[1]++;
		}
		else if ( ( ( l <= M_ptr[i][k] && M_ptr[i][k] <= l_plus_eps ) || (u_minus_eps <= M_ptr[i][k] &&  M_ptr[i][k] <= u) ) && gradFactor < 0.0 ) {  
			diagP2_indices[diagP2_indptr[1]] = k;
			diagP2_indptr[1]++;
		}
		else if ( ( ( l < M_ptr[i][k] && M_ptr[i][k] <= l_plus_eps) || (u_minus_eps <= M_ptr[i][k] && M_ptr[i][k] < u) ) && gradFactor >= 0.0) {  
			diagP3_indices[diagP3_indptr[1]] = k;
			diagP3_indptr[1]++;
		}
	}
	for (int k_ptr=0; k_ptr < diagP0_indptr[1]; k_ptr++) {
		diagP0[diagP0_indices[k_ptr]] = 1.0;
	}

	for (int k_ptr=0; k_ptr < diagP1_indptr[1]; k_ptr++) {
		diagP1[diagP1_indices[k_ptr]] = 1.0;
	}

	vector_zeros(diagP0, diagP0_zero_indices, diagP0_zero_indptr, K);
	vector_zeros(diagP1, diagP1_zero_indices, diagP1_zero_indptr, K);
}

void direction_slmqn(double* d, double* d_data, int* d_indices, int* d_indptr,
					double* x,
					double* grad, double* grad_data, int* grad_indices, int* grad_indptr,
					double** s_vecs, 
					double** s_vecs_data, int** s_vecs_indices, int** s_vecs_indptr, 
					double** y_vecs,
					double** y_vecs_data, int** y_vecs_indices, int** y_vecs_indptr,
					double* diagP0, int* diagP0_indices, int* diagP0_indptr,
					int* diagP0_zero_indices, int* diagP0_zero_indptr,
					double* diagP1, int* diagP1_indices, int* diagP1_indptr,
					int* diagP1_zero_indices, int* diagP1_zero_indptr,
					int* diagP2_indices, int* diagP2_indptr,
					int* diagP3_indices, int* diagP3_indptr,
					double* rho, double gamma, int Z, int cur_iter, 
					double eps, double zero_eps, int N, double l, double u, double sign)
{				
	int P0_nnz = diagP0_indptr[1];
	int s_nnz, y_nnz;

	double* alpha = (double*)malloc(cur_iter*sizeof(double));;
	for (int n=0; n<cur_iter; n++) {
		alpha[n] = 0.0;
	}
	double* q = (double*)malloc(N*sizeof(double));;
	for (int n=0; n<N; n++) {
		q[n] = 0.0;
	}
	for (int n=0; n<N; n++) {
		d[n] = 0.0;
	}
	if (P0_nnz > 0) {  
		for (int n=0; n<diagP0_indptr[1]; n++) {
			q[diagP0_indices[n]] = -grad[diagP0_indices[n]];
		}

		for (int i = cur_iter; i > fmax(-1, cur_iter-Z-1); --i) {  
			s_nnz = s_vecs_indptr[i][1];
			y_nnz = y_vecs_indptr[i][1];
			
			double sigma=0.0;
			for (int n=0; n<s_nnz; n++) {
				sigma += s_vecs_data[i][n] * q[s_vecs_indices[i][n]];
			}
			alpha[i] = rho[i] * sigma;

			for (int n=0; n<y_nnz; n++) {
				q[y_vecs_indices[i][n]] -= alpha[i] * y_vecs_data[i][n];
			}
		}
		for (int n=0; n<P0_nnz; n++) {
			q[diagP0_indices[n]] *= gamma;
		}
		for (int n=0; n<diagP0_zero_indptr[1]; n++) {
			q[diagP0_zero_indices[n]] = 0.0;
		}
		for (int i = fmax(0, cur_iter-Z); i < cur_iter; ++i) {
			y_nnz = y_vecs_indptr[i][1];
			s_nnz = s_vecs_indptr[i][1];

			double sigma = 0.0;
			for (int n=0; n<y_nnz; n++) {
				sigma += y_vecs_data[i][n] * q[y_vecs_indices[i][n]];
			}
			double beta = rho[i] * sigma;
			for (int n=0; n<s_nnz; n++) {
				q[s_vecs_indices[i][n]] += s_vecs_data[i][n] * (alpha[i] - beta);
			}
		}
		for (int n=0; n<diagP0_indptr[1]; n++) {
			if (x[diagP0_indices[n]] + q[diagP0_indices[n]] > u) {
				d[diagP0_indices[n]] = u - x[diagP0_indices[n]];
			}
			else if (x[diagP0_indices[n]] + q[diagP0_indices[n]] < l) {
				d[diagP0_indices[n]] = l - x[diagP0_indices[n]];
			}
			else {
				d[diagP0_indices[n]] = q[diagP0_indices[n]];
			}
		}
	}
	//P1
	for (int n=0; n<diagP1_indptr[1]; n++) {
		d[diagP1_indices[n]] = 0.0;
	}
	//P2
	for (int h=0; h<diagP2_indptr[1]; h++) { 
		int n = diagP2_indices[h];
		if (x[n] - grad[n] <= l) {
			d[n] = l - x[n];
		}
		else if (x[n] - grad[n] >= u) {
			d[n] = u - x[n];
		}
		else {
			d[n] = -grad[n];
		}
	}
	//P3
	for (int h=0; h<diagP3_indptr[1]; h++) {   
		int n = diagP3_indices[h];
		if ((l < x[n] && x[n] <= l+eps) && (x[n] - grad[n] <= l)) {     
			//d[n] = -(x[n]/grad[n]) * grad[n];
			//d[n] = (x[n] - l)/grad[n] * (-grad[n]);
			d[n] = l - x[n];
		}
		else if ((u-eps <= x[n] && x[n] < u) && (x[n] - grad[n] >= u)) {
			d[n] = u - x[n];
		}
		else {   
			if (x[n] - grad[n] <= l) {
				d[n] = l - x[n];
			}
			else if (x[n] - grad[n] >= u) {
				d[n] = u - x[n];
			}
			else {
				d[n] = -grad[n];
			}
		}
	}
	compress_flt_vec(d, d_data, d_indices, d_indptr, N);
	//free(alpha)
	free(alpha);
	//free(q)
	free(q);
}

void vector_zeros(double* vector, int* zero_indices, int* indptr, int J) {
	indptr[0] = 0;
	indptr[1] = 0;
	int counter = 0;
	for (int j=0; j<J; j++) {
		if (vector[j] == 0.0) {
			zero_indices[counter] = j;
			counter++;
		}
	}
	indptr[1] = counter;
}

void compress_flt_mat(double** matrix, double* data, int* indices, int* indptr, int M, int N)
{  
	// Argument I = number of rows in the matrix to be compressed
	// Argument J = number of columns in the matrix to be compressed
	indptr[0] = 0;
	indptr[1] = 0;
	int counter = 0;
	int row_end;
	for (int m=0; m<M; m++) {
		row_end = 0;
		indptr[m+1] = indptr[m];
		for (int n=0; n<N; n++) {
			if (matrix[m][n] != 0.0) {  
				data[counter] = matrix[m][n];
				indices[counter] = n;
				counter++;
				row_end++;
			}
		}
		indptr[m+1] += row_end;
	}
}

void compress_flt_vec(double* vector, double* data, int* indices, int* indptr, int N) 
{
	int counter = 0;
	indptr[0] = 0;
	for (int n=0; n<N; n++) {
		if (vector[n] != 0.0) {  
			data[counter] = vector[n];
			indices[counter] = n;
			counter++;
		}
	}
	indptr[1] = counter;
}

double cg_M_nor(double** M_ptr, int i, double* m_old,
			double* m_test, 
			double** C, double* C_data, int* C_indices, int* C_indptr,
			double** X_ptr, double** R_ptr,
			double* grad, 
			double* grad_data, int* grad_indices, int* grad_indptr,
			double* grad_old,
			double* z, double* z_data, int* z_indices, int* z_indptr,
			double* z_old,
			double* s_vec, double* y_vec, double* Hy,
			double* d, double* d_data, int* d_indices, int* d_indptr,
			double* diagPre, double gTd,
			double gamma, double error, 
			int itr_max, int* cg_itrs, int* nr_itrs, 
			int K, int J, double normConstant, 
			int precondition,
			double* diagP0, int* diagP0_indices, int* diagP0_indptr,
			int* diagP0_zero_indices, int* diagP0_zero_indptr,
			double* diagP1, int* diagP1_indices, int* diagP1_indptr,
			int* diagP1_zero_indices, int* diagP1_zero_indptr,
			int* diagP2_indices, int* diagP2_indptr,
			int* diagP3_indices, int* diagP3_indptr,
			double eps, double* distance, int* num_steps, double l, double u)
{ 

	
	//const double zero_eps = 0.001;
	//const double eps_cg_sq = 0.01*0.01;
	//const double eps_nr_sq = 0.01*0.01;
	//const int size_max = 20;
	//int cg_i = 0;
	//error = 0.0;
	//double error0 = error;
	double prev_err = 0.0;
	const int cg_n = 10;
	//const int nr_max = 10;
	const int cg_max = itr_max;
	double cg_alpha = 0.0;
	double alpha1 = 1.0;
	const double alpha_max = 1000000000.0;
	const double c1 = 0.0001;
	//const double c2 = 0.1;
	int a_iter = 0;
	int* a_iter_ptr = &a_iter;
	double delta_0;
	//double s_norm, y_norm;
	double grad_norm;
	double delta_old = 0.0;
	double delta_new, delta_d;
	double beta_PRP;
	//double dTy = 0.0;
	double gTy = 0.0;
	double gTd_old;
	//double sTs = 0.0;
	double sTy = 0.0;
	double yTy = 0.0;
	double cg_beta = 0.0;
	//double beta_HS, beta_PRP, beta_reg, beta_DY, beta_DYCD;
	double prev_err_cg = -0.1;
	double prev_err_nr;
	double cg_criterion;
	double old_m;


	if (precondition > 0) {
		// as long as precondition is not 1 or 2, the gradient is 
		// multipilied by a preconditioner that is supplied to the 
		// program as a parameter. We use the diagonal of the 
		// preconditioner.
		for (int k=0; k<K; k++) {
			z[k] = grad[k] * diagPre[k];
		}
	}
	else {
		for (int k=0; k<K; k++) {
			z[k] = grad[k];
		}
	}
	for (int k=0; k<K; k++) {
		diagPre[k] = gamma;
	}
	compress_flt_vec(grad, grad_data, grad_indices, grad_indptr, K);
	compress_flt_vec(z, z_data, z_indices, z_indptr, K);
	prelims_slmqn_M(grad, grad_data, grad_indices, grad_indptr,
					M_ptr, i,
					diagP0, diagP0_indices, diagP0_indptr,
					diagP0_zero_indices, diagP0_zero_indptr,
					diagP1, diagP1_indices, diagP1_indptr,
					diagP1_zero_indices, diagP1_zero_indptr,
					diagP2_indices, diagP2_indptr,
					diagP3_indices, diagP3_indptr,
					eps, J, K, l, u);
	//P0
	for (int h=0; h<diagP0_indptr[1]; h++) {
		d[diagP0_indices[h]] = -z[diagP0_indices[h]];
	}
	//printf("in CG_M, %d\n", 3);
	//P1
	for (int h=0; h<diagP1_indptr[1]; h++) {
		d[diagP1_indices[h]] = 0.0;
	}

	//P2
	for (int h=0; h<diagP2_indptr[1]; h++) {
		//n = diagP2_indices[h]
		d[diagP2_indices[h]] = -z[diagP2_indices[h]];
	}

	//P3
	//printf("in CG_M, %d ; cg_i = %d\n", 5, 0);
	for (int h=0; h<diagP3_indptr[1]; h++) {
		int n = diagP3_indices[h];
		if ((l < M_ptr[i][n] &&  M_ptr[i][n] <= l+eps) && (M_ptr[i][n] - z[n] <= l)) {
			//d[n] = -(M_ptr[i][n]/grad[n]) * grad[n];
			d[n] = -M_ptr[i][n];
		}
		else if ((u-eps <= M_ptr[i][n] && M_ptr[i][n] < u) && (M_ptr[i][n] - z[n] >= u)) {
			//d[n] = -((M_ptr[i][n] - 1.0) / grad[n]) * grad[n];
			d[n] = -M_ptr[i][n] + 1.0;
		}		
		else {
			d[n] = -z[n];
		}
	}
	//printf("in CG_M, %d ; cg_i = %d\n", 6, 0);
	compress_flt_vec(d, d_data, d_indices, d_indptr, K);
	
	gTd = 0.0;
	for (int h=0; h<d_indptr[1]; h++) {
		gTd += grad[d_indices[h]] * d_data[h]; //* diagP0[d_indices[h]];
	}
	//compress_flt_vec(M_ptr[i], m_data, m_indices, m_indptr, K)
	//printf("in CG_M, %d\n", 7);
	delta_new = 0.0;
	for (int h=0; h<grad_indptr[1]; h++) {
		delta_new += (grad_data[h] * z[grad_indices[h]]) * diagP0[grad_indices[h]];
	}
	grad_norm = sqrt(delta_new);
	delta_0 = delta_new;
	
	//cg_i = 0
	//while cg_i <= cg_max:
	int cg_k = 0;
	cg_itrs[0] = 0;
	for (int cg_i=0; cg_i<cg_max; cg_i++) {
		cg_k++;
		//cg_i++;
		cg_itrs[0]++;
		//printf("in CG_M, %d\n", 7);
		prev_err = prev_err_cg;
		prev_err_cg = error;
		delta_d = 0.0;
		for (int h=0; h<d_indptr[1]; h++) {
			delta_d += d_data[h] * d_data[h];
		}
		gTd_old = gTd;
		alpha1 = 1.0;
		//printf("in CG_M, %d\n", 8);
		cg_alpha = armijo2_M_nor(alpha1, alpha_max, 
					c1, error, gTd,
					M_ptr, m_test, i,
					C, C_data, C_indices, C_indptr, 
					X_ptr, R_ptr,
					d, d_data, d_indices, d_indptr,
					normConstant, K, J, a_iter_ptr,
					l, u);
		printf("In CG_M; a_iter_ptr = %d\n", a_iter_ptr[0]);
		for (int k=0; k<K; k++) {
			m_old[k] = M_ptr[i][k];
		}
		//printf("in CG_M, %d\n", 10);
		for (int h=0; h<d_indptr[1]; h++) {
			int k = d_indices[h];
			old_m = M_ptr[i][k];
			M_ptr[i][k] += cg_alpha * d_data[h];
			if (M_ptr[i][k] > u) M_ptr[i][k] = u;
			else if (M_ptr[i][k] < l) M_ptr[i][k] = l;
			distance[0] += fabs(M_ptr[i][k] - old_m);
			//num_steps[0]++;
		}
		//printf("in CG_M, %f\n", 11.5);
		for (int k=0; k<K; k++) {
			s_vec[k] = M_ptr[i][k] - m_old[k];
		}
		//printf("in CG_M, %d\n", 12);
		prev_err_nr = error;

		for (int k=0; k<K; k++) grad_old[k] = grad[k];
		//printf("in CG_M, %d\n", 13);
		
		prev_err_cg = error;
		error = r_e_and_grad_m(grad, M_ptr[i], 
				C_data, C_indices, C_indptr, 
				X_ptr[i], R_ptr[i], J, K, normConstant);	
		
		for (int k=0; k<K; k++) { 
			s_vec[k] = M_ptr[i][k] - m_old[k];
			y_vec[k] = grad[k] - grad_old[k];
		}	
		if (precondition > 0) {
			for (int k=0; k<K; k++) {
				Hy[k] = diagPre[k] * y_vec[k];
			}
		}
		// if (yTy <= 0.0000000001) {
		// 	printf("yTy <= 0.0000000001; BREAK!\n");
		// 	break;
		//}
		//printf("in CG_M, %d\n", 14);
		delta_old = delta_new;
		delta_new = 0.0;
		for (int h=0; h<diagP0_indptr[1]; h++) {
			int k = diagP0_indices[h];
			delta_new += grad[k] * z[k];
		}

		//printf("in CG_M, %d\n", 15);
		grad_norm = sqrt(delta_new);
		if (precondition == 2) {
			//if precondition = 2, the preconditioner is updated with each iteration.
			//if precondition = 1, it is kept fixed.
			sTy = 0.0;
			for (int h=0; h<diagP0_indptr[1]; h++) {
				sTy += s_vec[diagP0_indices[h]] * y_vec[diagP0_indices[h]];
			}
			if (sTy == 0.0) {
				printf("sTy == 0.0; BREAK!\n");
				break;
			}
			else {
				inv_diag_bfgs(diagPre, s_vec, y_vec, Hy, sTy, K, diagP0);
			}
		}
		//printf("in CG_M, %d\n", 18);
		if (precondition > 0) {
			//the preconditioner is applied as long as precondition isn't 0.
			for (int k=0; k<K; k++) {
				z[k] = grad[k] * diagPre[k];
			}
			gTy = 0.0;
			for (int h=0; h<diagP0_indptr[1]; h++) {
				gTy += z[diagP0_indices[h]] * Hy[diagP0_indices[h]];
			}
		}				
		else {
			for (int k=0; k<K; k++) {
				z[k] = grad[k];
			}
			gTy = 0.0;
			for (int h=0; h<diagP0_indptr[1]; h++) {
				gTy += z[diagP0_indices[h]] * y_vec[diagP0_indices[h]];
			}
		}
		//printf("in CG_M, %d\n", 19);
		compress_flt_vec(grad, grad_data, grad_indices, grad_indptr, K);
		compress_flt_vec(z, z_data, z_indices, z_indptr, K);
		
		if (delta_old == 0.0) {
			printf("delta_old = 0; BREAK!\n");
			break;
		}
		else {
			beta_PRP = gTy / delta_old;
		}
		
		cg_beta = fmax(0.0, beta_PRP);	

		//printf("in CG_M, %d\n", 20);
		prelims_slmqn_M(grad, grad_data, grad_indices, grad_indptr,
					M_ptr, i,
					diagP0, diagP0_indices, diagP0_indptr,
					diagP0_zero_indices, diagP0_zero_indptr,
					diagP1, diagP1_indices, diagP1_indptr,
					diagP1_zero_indices, diagP1_zero_indptr,
					diagP2_indices, diagP2_indptr,
					diagP3_indices, diagP3_indptr,
					eps, J, K, l, u);
		//P0
		for (int h=0; h < diagP0_indptr[1]; h++) {
			int k = diagP0_indices[h];
			d[k] = -z[k] + (cg_beta * d[k]);
		}
		//printf("in CG_M, %d\n", 24);
		//P1
		for (int h=0; h<diagP1_indptr[1]; h++) {
			int k = diagP1_indices[h];
			d[k] = 0.0;
		}
		//P2
		for (int h=0; h<diagP2_indptr[1]; h++) {
			int k = diagP2_indices[h];
			d[k] = -z[k];
		}
		//printf("in CG_M, %d\n", 26);
		//P3
		for (int h=0; h<diagP3_indptr[1]; h++) {
			int k = diagP3_indices[h];
			if ((l < M_ptr[i][k] && M_ptr[i][k] <= l+eps) && (M_ptr[i][k] - z[k] <= l)) {
				//d[n] = -(M_ptr[i][n]/grad[n]) * grad[n];
				d[k] = -M_ptr[i][k];
			}
			else if ((u-eps <= M_ptr[i][k] && M_ptr[i][k] < u) && (M_ptr[i][k] - z[k] >= u)) {
				//d[n] = -((M_ptr[i][n] - 1.0) / grad[n]) * grad[n]
				d[k] = -M_ptr[i][k] + 1.0;
			}
			else d[k] = -z[k];
		}
		compress_flt_vec(d, d_data, d_indices, d_indptr, K);	
		gTd = 0.0;
		for (int h=0; h < d_indptr[1]; h++) {
			//int k = d_indices[h];
			gTd += d_data[h] * grad[d_indices[h]];
			//gTd += d[k] * grad[k];		
		}
		//print "cg_M ;", "cg_criterion =", cg_criterion
		//print "\t\t", itr_counter, ".  cg_M", "err diff =", "{:.12f}".format((prev_err_cg - error)/prev_err_cg)
		// if isNaN(gTd):
		// 	print "\n\n", "********************* CG M, gTd NaN *********************\n\n"
		// 	break
		if ((prev_err_cg - error)/prev_err_cg < 0.000000001) {
			printf("&&&& break cg error\n");
			break;
		}
		// if (cg_i >= cg_max) {
		// 	//print "\tbreak cgi", "; K" + str(K)
		// 	break;
		// }
		cg_criterion = -gTd;
		if (cg_k == cg_n || cg_criterion <= 0.0) { //r^T * d = 1 x K times K x 1 = 1 x 1
			cg_k = 0;
			for (int h=0; h<diagP0_indptr[1]; h++) {
				d[diagP0_indices[h]] = -z[diagP0_indices[h]];
			}
			for (int h=0; h<diagP1_indptr[1]; h++) {
				d[diagP1_indices[h]] = 0.0;
			}
			for (int h=0; h<diagP2_indptr[1]; h++) {
				d[diagP2_indices[h]] = -z[diagP2_indices[h]];
			}
			for (int h=0; h<diagP3_indptr[1]; h++) {
				int k = diagP3_indices[h];
				if ((l < M_ptr[i][k] && M_ptr[i][k] <= l+eps) && (M_ptr[i][k] - z[k] <= l)) {
					//d[k] = -(M_ptr[i][k]/grad[k]) * grad[k]
					d[k] = -M_ptr[i][k];
				}
				else if ((u-eps <= M_ptr[i][k] && M_ptr[i][k] < u) && (M_ptr[i][k] - z[k] >= u)) {
					//d[k] = -((M_ptr[i][k] - 1.0) / grad[k]) * grad[k]
					d[k] = -M_ptr[i][k] + 1.0;
				}
				else {
					d[k] = -z[k];
				}
			}
			compress_flt_vec(d, d_data, d_indices, d_indptr, K);
			
			gTd = 0.0;
			for (int h=0; h<d_indptr[1]; h++) {
				// int k = d_indices[h];
				// gTd += grad[k] * d[k];
				gTd += d_data[h] * grad[d_indices[h]];
			}
		}
	}
	//cg_itrs[0] = cg_i;
	return error;
}


void optimize_M_nor(double** X_ptr, double** R_ptr, double** M_ptr, 
					double** C_ptr,
					int I, int J, int K, double normConstant,
					int numIters, int qn, int cg, double* distance, int* num_steps,
					double lower, double upper)
{   
	printf("We're in optimize_M!\n");
	//double E = 0.0;
	//print "Error:", error, "\n"
	//int Z = 5;
	//int t = 0;
	//const int t_max = 10;
	const int size_max = 20;
	const double eps = 0.00000001;
	//int counter_old;

	//const double eps = 0.0000001;
	//const double zero_eps = 0.001;
	//const double err_thresh = 0.0000001;
	
	double* C_data = (double*)malloc(J*K*sizeof(double));
	int* C_indices = (int*)malloc(J*K*sizeof(int));
	int* C_indptr = (int*)malloc((J+1)*sizeof(int));
	C_indptr[0] = 0;
	
	compress_flt_mat(C_ptr, C_data, C_indices, C_indptr, J, K);
	//compress_flt_vec(d, d_data, d_indices, d_indptr, N);
	// for (int j=0; j<J; j++) {
	// 	int row_end = 0;
	// 	int counter = 0;
	// 	for (int k=0; k<K; k++) {
	// 		if (C_ptr[j][k] != 0.0) {
	// 			C_data[counter] = C_ptr[j][k];
	// 			C_indices[counter] = k;
	// 			counter++;
	// 			row_end++;
	// 		}
	// 	}
	// 	C_indptr[j+1] = C_indptr[j] + row_end;
	// }
	double* m_old = (double*)calloc(K,sizeof(double));
	double * m_test = (double*)calloc(K,sizeof(double));	
	double * grad_old = (double*)calloc(K,sizeof(double));
	double * d = (double*)calloc(K,sizeof(double));
	double * d_data = (double*)calloc(K,sizeof(double));
	int * d_indices = (int*)calloc(K,sizeof(int));
	int * d_indptr = (int*)calloc(2,sizeof(int));
	double * grad_data = (double*)calloc(K,sizeof(double));
	int * grad_indices = (int*)calloc(K,sizeof(int));
	int * grad_indptr = (int*)calloc(2,sizeof(int));
	double * z = (double*)calloc(K,sizeof(double));
	double * z_data = (double*)calloc(K,sizeof(double));
	int * z_indices = (int*)calloc(K,sizeof(int));
	int * z_indptr = (int*)calloc(2,sizeof(int));
	double * z_old = (double*)calloc(K,sizeof(double));
	double* Hy = (double*)calloc(K,sizeof(double));
	double * diagH = (double*)calloc(K,sizeof(double));
	double * diagPre = (double*)calloc(K,sizeof(double));
	double * diagP0 = (double*)calloc(K,sizeof(double));
	int * diagP0_indices = (int*)calloc(K,sizeof(int));
	int * diagP0_indptr = (int*)calloc(2,sizeof(int));
	diagP0_indptr[0] = 0;
	int * diagP0_zero_indices = (int*)calloc(K,sizeof(int));
	int * diagP0_zero_indptr = (int*)calloc(2,sizeof(int));
	diagP0_zero_indptr[0] = 0; 
	double * diagP1 = (double*)calloc(K,sizeof(double));
	int * diagP1_indices = (int*)calloc(K,sizeof(int));
	int * diagP1_indptr = (int*)calloc(2,sizeof(int));
	diagP1_indptr[0] = 0;
	int * diagP1_zero_indices = (int*)calloc(K,sizeof(int));
	int * diagP1_zero_indptr = (int*)calloc(2,sizeof(int));
	diagP1_zero_indptr[0] = 0;
	int * diagP2_indices = (int*)calloc(K,sizeof(int));
	int * diagP2_indptr = (int*)calloc(2,sizeof(int));
	diagP2_indptr[0] = 0;
	int * diagP3_indices = (int*)calloc(K,sizeof(int));
	int * diagP3_indptr = (int*)calloc(2,sizeof(int));
	diagP3_indptr[0] = 0;
	double * rho = (double*)calloc(size_max, sizeof(double));
	double * s_vec = (double*)calloc(size_max, sizeof(double));
	double * y_vec = (double*)calloc(size_max, sizeof(double));

	//int num_stored = 0;
	//double q_val = 0.0;
	//const double c1 = 0.00001;
	//const double c2 = 0.9;
	//double alpha1 = 1.0;
	//double alpha_max = 10000000000.0;
	//double prev_err_global = 1000000000000.0;
	//double err_before_cg = 0.0;
	//double sum_cg_err_diffs = 0.0;
	//cdef bint grad_break = 0
	//cdef bint gTd_break = 0
	//double sign = -1.0;
	double gTd = 0.0;
	int cg_itr_max = 40;
	int precondition = 0;
	double * grad;
	double gamma = 1.0;
	//int k;
	//double * m;
	//#pragma omp parallel private(grad) shared(gamma)
	//{


		// double** s_vecs = (double **)malloc(size_max*sizeof(double*));
		// for (int n=0; n<size_max; n++) {
		// 	s_vecs[n] = <double *>calloc(K,sizeof(double));
		// }
		// //s_vecs = &s_vecs[0];
		// double** y_vecs = (double **)malloc(size_max*sizeof(double*));
		// for (int n=0; n<size_max; n++) {
		// 	y_vecs[n] = (double *)calloc(K,sizeof(double));
		// }
		//y_vecs = &y_vecs[0];
		//double avg_step;
		//double step_norm;
		//double grad_old_len = 0.0;
		
		//double* gamma_ptr = &gamma;
		//double beta = 0.0;
		//int a_iter = 0;
		//int num_alphas = 0;
		//int* a_iter_ptr = &a_iter;
		//double avg_a_iters = 0.0;
		//int cg_itrs = 0;
		//int* cg_itrs_ptr = &cg_itrs;
		//int cg_itrs_sum = 0;

		
		//double P0_grad_norm = 0.0;
		//double P0_grad_sq_sum = 0.0;

		//double y_norm, m_norm, init_gamma, max_grad, max_m;
		//double total_avg_step = 0.0;
		//double alpha_sum = 0.0;
		//double alpha = 0.0;

		//double denom = 1.0;
		//double numer;
		// double yTy = 1000000.0;
		// double sTy = 1.0;
		// double sTs = 1.0;
		//double gTd = 0.0;
		//k = 0;
		double error = 0.0;
		double prev_err = error;
		grad = (double*)calloc(K,sizeof(double));
		//#pragma omp parallel for	
		for (int i=0; i<I; i++) 
		{
			//m = &M_ptr[i][0];
			
			error = r_e_and_grad_m(grad, M_ptr[i], 
					C_data, C_indices, C_indptr, 
					X_ptr[i], R_ptr[i], J, K, normConstant);

			prev_err = error;
			//grad = (double*)calloc(K,sizeof(double));
			int cg_itrs = 0;
			int* cg_itrs_ptr = &cg_itrs;
			int nr_itrs = 0;
			int* nr_itrs_ptr = &nr_itrs;
			cg_itrs_ptr[0] = 0;
			nr_itrs_ptr[0] = 0;
			//gamma_ptr[0] = 1.0;
			
			//printf("***********************\n");
			//printf("OPT M; pre-cg  error =%d\n", error);
			//printf("***********************\n");
			//double gamma = 1.0;
			// error = cg_M_nor(M_ptr[i], C_ptr, C_data, C_indices, C_indptr,
			// 			 X_ptr[i], R_ptr[i], grad,
			// 			 gamma, cg_itr_max, cg_itrs_ptr, nr_itrs_ptr,
			// 			 K, J, normConstant, precondition,
			// // 			 distance, num_steps, lower, upper);
			// error = cg_M_nor(M_ptr, i, C_ptr, C_data, C_indices, C_indptr,
			// 			 X_ptr, R_ptr, grad,
			// 			 gamma, cg_itr_max, cg_itrs_ptr, nr_itrs_ptr,
			// 			 K, J, normConstant, precondition,
			// 			 distance, num_steps, lower, upper);
			error = cg_M_nor(M_ptr, i, m_old, m_test,
							C_ptr, C_data, C_indices, C_indptr,
							X_ptr, R_ptr, grad, 
							grad_data, grad_indices, grad_indptr, grad_old,
							z, z_data, z_indices, z_indptr, z_old,
							s_vec, y_vec, Hy,
							d, d_data, d_indices, d_indptr,
							diagPre, gTd, gamma, error, 
							cg_itr_max, cg_itrs_ptr, nr_itrs_ptr,
							K, J, normConstant, precondition,
							diagP0, diagP0_indices, diagP0_indptr,
							diagP0_zero_indices, diagP0_zero_indptr,
							diagP1, diagP1_indices, diagP1_indptr,
							diagP1_zero_indices, diagP1_zero_indptr,
							diagP2_indices, diagP2_indptr,
							diagP3_indices, diagP3_indptr,
							eps, distance, num_steps, lower, upper);
			//printf("***********************\n");
			//printf("OPT M; post-cg error =%f\n", error);
			//printf("***********************\n");
			// #M_i_nnz = nnz.vectorNonZeros(M_ptr[i], K)
			//if ( i % 10 == 0 ) {
			double grad_sq_sum = 0.0;
			//#pragma omp atomic
			//int k = 0;
			for (int k=0; k<K; k++) {
				grad_sq_sum += grad[k] * grad[k];
			}
			double grad_len = sqrt(grad_sq_sum); 
			printf("here now 1\n");
			printf("*** M[%d]; e: %f; dif: %f; cgi:%d; gn: %f; K:%d\n", i, error, prev_err - error, cg_itrs_ptr[0], grad_len, K); 
			// # 	print "; nz: " + str(M_i_nnz) + "/" + str(K) + "; gn =", grad_len, 
			// # 	print "; cgi: " + str(cg_itrs_ptr[0]) + ";",
			// # 	print "ni: " + str(numIters) + "; K: " + str(K)								
			//}
			printf("here now 2\n");
			cg_itrs_ptr=NULL;
			nr_itrs_ptr=NULL;
			//free(grad);
			//m=NULL;
			//E += error;
			//E = E/<double>I
		}
		// for (int n=0; n<size_max; n++) { free(s_vecs[n]); }
		// free(s_vecs);
		// for (int n=0; n<size_max; n++) { free(y_vecs[n]); }
		// free(y_vecs);
		//free(grad);
	//}
	printf("here now 3\n");
	free(grad);
	free(C_data);
	free(C_indices);
	free(C_indptr);
	//cg_itrs_ptr=NULL;
	//nr_itrs_ptr=NULL;
	// dealloc_matrix_2(s_vecs, size_max)
	// dealloc_matrix_2(s_vecs_data, size_max)
	// dealloc_mat_2_int(s_vecs_indices, size_max)
	// dealloc_mat_2_int(s_vecs_indptr, size_max)
	// dealloc_matrix_2(y_vecs, size_max)
	// dealloc_matrix_2(y_vecs_data, size_max)
	// dealloc_mat_2_int(y_vecs_indices, size_max)
	// dealloc_mat_2_int(y_vecs_indptr, size_max)
	//printf("*** in CG_M, cg_i = %d\n", cg_i);
	free(m_old);
	//printf("in CG_M, %d\n", 100);
	free(m_test);
	//printf("in CG_M, %d\n", 101);	
	free(grad_old);
	//printf("in CG_M, %d\n", 102);
	//free(grad);
	free(d);
	//printf("in CG_M, %d\n", 103);
	free(d_data);
	//printf("in CG_M, %d\n", 104);
	free(d_indices);
	//printf("in CG_M, %d\n", 105);
	free(d_indptr);
	//printf("in CG_M, %d\n", 106);
	free(grad_data);
	//printf("in CG_M, %d\n", 107);
	free(grad_indices);
	//printf("in CG_M, %d\n", 108);
	free(grad_indptr);
	//printf("in CG_M, %d\n", 109);
	free(z);
	//printf("in CG_M, %d\n", 110);
	free(z_data);
	//printf("in CG_M, %d\n", 111);
	free(z_indices);
	//printf("in CG_M, %d\n", 112);
	free(z_indptr);
	//printf("in CG_M, %d\n", 113);
	free(z_old);
	//printf("in CG_M, %d\n", 114);
	free(Hy);
	//printf("in CG_M, %d\n", 115);
	free(diagH);
	//printf("in CG_M, %d\n", 116);
	free(diagPre);
	//printf("in CG_M, %d\n", 117);
	free(diagP0);
	//printf("in CG_M, %d\n", 118);
	free(diagP0_indices);
	//printf("in CG_M, %d\n", 119);
	free(diagP0_indptr);
	//printf("in CG_M, %d\n", 120);
	free(diagP0_zero_indices);
	//printf("in CG_M, %d\n", 121);
	free(diagP0_zero_indptr);
	//printf("in CG_M, %d\n", 122);
	free(diagP1);
	//printf("in CG_M, %d\n", 123);
	free(diagP1_indices);
	//printf("in CG_M, %d\n", 124);
	free(diagP1_indptr);
	//printf("in CG_M, %d\n", 125);
	free(diagP1_zero_indices);
	//printf("in CG_M, %d\n", 126);
	free(diagP1_zero_indptr);
	//printf("in CG_M, %d\n", 127);
	free(diagP2_indices);
	//printf("in CG_M, %d\n", 128);
	free(diagP2_indptr);
	//printf("in CG_M, %d\n", 129);
	free(diagP3_indices);
	//printf("in CG_M, %d\n", 130);
	free(diagP3_indptr);
	//printf("in CG_M, %d\n", 131);
	free(rho);
	//printf("in CG_M, %d\n", 132);
	free(s_vec);
	//printf("in CG_M, %d\n", 133);
	free(y_vec);
	//printf("in CG_M, %d\n", 134);
	//return E;
}
