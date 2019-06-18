data {
 
  int<lower = 1> n;
  
  int<lower = 1> bin[n];
  int<lower = 1> n_bin;

  int<lower = 0> cuts[n_bin - 1];

  real<lower = 0> alpha_shape;
  real<lower = 0> beta_rate;
  
  // state?
  // n_states? 

}

parameters {

  // true rate
  real<lower = 0> lambda;

}

transformed parameters {
  
  real<lower = 0> beta;
  vector[n_bin] log_prob;
  vector[n_bin] cut_lps;
  vector[n_bin] cut_cdfs;
  
  // mean wait is inverse rate
  beta = inv(lambda);

  // find the exponential LCDF at each cutpoint | lambda
  // Then log_prob is the cumulative link
  for (b in 1:n_bin) {
    if (b < n_bin) {
      cut_lps[b] = exponential_lcdf(cuts[b] | lambda);
    } else if (b == n_bin) {
      cut_lps[b] = log(1);
    }
  }

  cut_cdfs = exp(cut_lps);

  for (c in 1:n_bin) {
    if (c == 1) {
      log_prob[c] = cut_lps[c];
    } else {
      log_prob[c] = log(exp(cut_lps[c]) - exp(cut_lps[c - 1]));
    }
  }


}

model {

  // binned wait should be a deterministic function?
  // bin ~ categorical(prob);
  bin ~ categorical_logit(log_prob);
  
  // prob = diff of CDFs

  lambda ~ gamma(alpha_shape, beta_rate);

}

generated quantities {
  // simplex
  simplex[n_bin] prob;
  prob = softmax(log_prob);

}
