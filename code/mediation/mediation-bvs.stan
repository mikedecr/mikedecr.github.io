data {

  int<lower = 1> n;
  int<lower = 0, upper = 1> Y[n];             // outcome
  vector[n] M;             // mediator
  vector[n] T;             // treatment
  int<lower = 0> k; // number of covariates
  matrix[n, k] X;             // covariates

}

parameters {

  // mediator model
  real alpha_m;
  real beta_m;       // treatment
  vector[k] zeta_m; // covariates
  real<lower = 0> sig_m; 

  // outcome model
  real alpha_y;
  real beta_y;       // treatment
  real gamma;        // mediator effect
  vector[k] zeta_y; // covariates

}

transformed parameters {

  vector[n] mhat;
  vector[n] yhat_index;
  vector<lower = 0, upper = 1>[n] yhat;

  mhat = alpha_m + (T * beta_m) + (X * zeta_m);
  yhat_index = alpha_y + (T * beta_y) + (M * gamma) + (X * zeta_y);
  
  yhat = Phi_approx(yhat_index);

}

model {

  // mediator
  M ~ normal(mhat, sig_m);
  // mediator params
  alpha_m ~ normal(5, 100);
  beta_m ~ normal(0, 10);
  zeta_m ~ normal(0, 10);
  sig_m ~ normal(0, 10);

  // outcome
  Y ~ bernoulli(yhat);
  alpha_y ~ normal(0, 10);
  beta_y ~ normal(0, 3);
  gamma ~ normal(0, 3);
  zeta_y ~ normal(0, 3);

}

generated quantities {
 
  // M as f(T)
  vector[n] m0;
  vector[n] m1;

  vector<lower = 0, upper = 1>[n] y1m0;
  vector<lower = 0, upper = 1>[n] y1m1;

  vector<lower = 0, upper = 1>[n] y0m0;
  vector<lower = 0, upper = 1>[n] y0m1;

  real ACME_0;
  real ACME_1;

  real ADE_0;
  real ADE_1;

  real TE_0;
  real TE_1;
  real TE;

  m0 = alpha_m + (0 * beta_m) + (X * zeta_m);
  m1 = alpha_m + (1 * beta_m) + (X * zeta_m);

  y1m0 = Phi_approx(alpha_y + (1 * beta_y) + (m0 * gamma) + (X * zeta_y));
  y1m1 = Phi_approx(alpha_y + (1 * beta_y) + (m1 * gamma) + (X * zeta_y));
  y0m0 = Phi_approx(alpha_y + (0 * beta_y) + (m0 * gamma) + (X * zeta_y));
  y0m1 = Phi_approx(alpha_y + (0 * beta_y) + (m1 * gamma) + (X * zeta_y));

  ACME_0 = mean(y0m1 - y0m0);
  ACME_1 = mean(y1m1 - y1m0);

  ADE_0 = mean(y1m0 - y0m0);
  ADE_1 = mean(y1m1 - y0m1);

  TE_0 = ADE_0 + ACME_0;
  TE_1 = ADE_1 + ACME_1;

  TE = 0.5 * (TE_0 + TE_1);


}
