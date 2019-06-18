// to do
// - i-level index tracker
// for tracking in the response model

data {

  int<lower = 1> n;
  int<lower = 1> n_id;
  int<lower = 1> n_rr_item;

  // indexing and DV
  int<lower = 1, upper = n_id> id[n];
  int<lower = 1, upper = n_rr_item> rr_item[n];
  vector<lower = -2, upper = 2>[n] rr_response;

  // input prior
  real<lower = 0> precision;
  real disc_location;

}

transformed data {
 


}

parameters {
 
  vector[n_id] theta;
  real<lower = 0> sigma;
  
  vector[n_rr_item] z_diff;
  vector[n_rr_item] z_disc;

  real<lower = 0> scale_diff;
  real<lower = 0> scale_disc;

}

transformed parameters {

  vector[n] eta;
  vector[n_rr_item] beta_j;
  vector[n_rr_item] alpha_j;

  // upscale item parameters
  alpha_j = z_diff * scale_diff;
  beta_j = (z_disc * scale_disc) + disc_location;

  
  for (ij in 1:n) {
    eta[ij] = 
      alpha_j[rr_item[ij]] + 
      ( theta[id[ij]] .* beta_j[rr_item[ij]] );
  }

}

model {
 
  rr_response ~ normal(eta, sigma);

  theta ~ normal(0, 1);
  z_diff ~ normal(0, 1);
  z_disc ~ normal(0, 1);

  sigma ~ exponential(1);
  scale_diff ~ exponential(precision);
  scale_disc ~ exponential(precision);

}

generated quantities {
 
  // cutoff = -1(beta*alpha)
  vector[n_id] rr_irt;
  vector[n_rr_item] kappa;
  
  rr_irt = (theta - mean(theta)) ./ sd(theta);
  kappa = -1 * (beta_j .* alpha_j);


}
