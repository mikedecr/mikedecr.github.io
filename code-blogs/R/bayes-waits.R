# ----------------------------------------------------
#   Bayesian Wait Times Estimates
# ----------------------------------------------------

library("here")
# library("magrittr")
library("tidyverse")
library("rstan")
options(mc.cores = parallel::detectCores())
rstan_options(auto_write = TRUE)
# library("ggmcmc") # decide if you need this
library("tidybayes")

# library("labelled")
# library("broom")
# library("latex2exp")


# ---- data -----------------------

cces_raw <- haven::read_dta("~/data/cces-2018/CCES2018_OUTPUT.dta") %>%
  print()

fips <- read_csv(here("static", "data", "census-state-fips.csv")) %>%
  select(-state) %>%
  print()

names(cces_raw) 

cces_raw


# trim variables
cces <- cces_raw %>%
  filter(tookpost == 2) %>%
  select(caseid, wt = commonpostweight, wait = CC18_404, wait_open = CC18_404_t, inputstate) %>%
  left_join(fips, by = c("inputstate" = "state_FIPS")) %>%
  print()


# export open-ended responses for hand-coding
count(cces, wait_open) %>%
  write_csv(here("static", "data", "cces-2018_wait-open.csv"))

# this didn't take long at all
open_waits <- 
  read_csv(here("static", "data", "cces-2018_wait-open-coded.csv")) %>%
  select(-n) %>%
  print()


# join hand-coded into full data,
# calculate "minute" estimates using Stewart method
cces <- cces %>%
  left_join(open_waits) %>%
  mutate(wait_mins = case_when(is.na(wait_mins) == FALSE ~ wait_mins,
                               wait == 1 ~ 0,
                               wait == 2 ~ 5,
                               wait == 3 ~ 15,
                               wait == 4 ~ 45)) %>%
  print()


# boundaries for discrete categories
# [0, 10], (10, 30], (30, 60], (60, ...)
cuts <- c(0, 10, 30, 60)


state_wait <- cces %>%
  group_by(state_abb) %>%
  summarize(raw_mean_wait = mean(wait_mins, na.rm = TRUE),
            weighted = weighted.mean(wait_mins, wt, na.rm = TRUE)) %>%
  arrange(desc(weighted)) %>%
  print()


ggplot(cces, aes(x = wait_mins)) +
  geom_histogram() +
  geom_vline(xintercept = cuts, size = 0.25, color = "red") +
  facet_wrap(~ state_abb)


# ----------------------------------------------------
#   Testing the stan file
# ----------------------------------------------------

lam <- 20

x <- rpois(n = 200, lambda = lam)

# plot density
tibble(x = 1:100, d = dpois(x, lambda = lam)) %>% 
  ggplot(aes(x = x, y = d)) +
  geom_col()

sim_data <- 
  tibble(x = rpois(n = 200, lambda = lam)) %>%
  mutate(bin = case_when(x == 0 ~ 1,
                         x <= 10 ~ 2,
                         x <= 30 ~ 3,
                         x <= 60 ~ 4,
                         x > 60 ~ 5)) %>%
  print()

sim_data %>% pull(bin) %>% as.factor() %>% levels()


alpha_shape <- 2
beta_rate <- .2
tibble(x = seq(0, 50, .1),
       dg = dgamma(x, shape = alpha_shape, rate = beta_rate)) %>%
  ggplot(aes(x = x, y = dg)) +
    geom_line()



stan_sim <- sim_data %>%
  select(-x) %>%
  compose_data(n_bin = 5,
               cuts = seq(0, 30, 10),
               alpha_shape = alpha_shape,
               beta_rate = beta_rate) %>%
  print()

sim_data %>% 
  ggplot(aes(x = x)) + 
  geom_histogram() +
  geom_vline(xintercept = seq(0, 30, 10))


simple_mod <- stan_model(file = here("static", "code-blogs", "stan", "iter-waits.stan"), verbose = TRUE)

beepr::beep(2)

sim_fit <- 
  sampling(object = simple_mod, 
           data = stan_sim, 
           iter = 2000, 
           thin = 1, 
           # init = list(list("lambda" = 10,
           #                  "prob[1]" = 0.2,
           #                  "prob[2]" = 0.2,
           #                  "prob[3]" = 0.2,
           #                  "prob[4]" = 0.2,
           #                  "prob[5]" = 0.2)),
           chains = 4)

beepr::beep(2)

sim_fit

broom::tidy(sim_fit)