data {
 
  int<lower = 1> n;
  
  int<lower = 0> binned_wait[n];
  int<lower = 1> n_bins;
  int<lower = 0> cuts[n_bins - 1];
  
  int<lower = 1> state[n];
  int<lower = 1> n_state;

}

// transformed data {// }

parameters {

  // vector<lower = 0> true_wait[n];
  vector<lower = 0> true_state[n_state];

}

transformed parameters {
  
  // simplex
  simplex[n_bins] pi_k[n_state];
  // for k in 0:(n_bins-1)?
  // if k = n_bins - 1, 1 - cdf(k)?
  // also looping over state?
  for (s in 1:n_state) {
    for (c in 1:cuts) {
      if (cuts[c] == 0) {
        pi_k[c, s] = poisson_cdf(0 | true_state[s]);
      } else if (cuts[c] == n_bins - 1) {
        pi_k[c, s] = 1 - poisson_cdf(cuts[c] | true_state[s]);
      } else {
        pi_k[c, s] = poisson_cdf(cuts[c] | true_state[s]) - 
                       poisson_cdf(cuts[c - 1] | true_state[s])
      }


      // if 0
      // if 1
      // if between
      // pi_k[c, s] = poisson_cdf(cuts[c + 1], true_state[s]) - poisson_cdf(cuts[c]);
    }
    
  }


}

model {

  // binned wait should be a deterministic function?
  binned_wait ~ categorical(pi_k);
  // pi_k = diff of CDFs

  true_state ~ gamma();

}

// generated quantities {}
