# ----------------------------------------------------
#   Bayesian causal mediation example
# ----------------------------------------------------

library("here")
library("magrittr")
library("tidyverse")
library("broom")
# library("mediation") not attaching bc function clashes
library("rstan")
options(mc.cores = parallel::detectCores())
rstan_options(auto_write = TRUE)


# data can be obtained through Harvard Dataverse
bvs <- 
  haven::read_dta(
    here("static", "data", "mediation", "brader_trim_nomiss.dta")
  ) %>%
  print()

# standardizing predictors except for Y, T, M
bvs_std <- bvs %>%
  select(
    cong_mesg, emo, tone_eth, ppage, ppeducat, ppgender, ppincimp
  ) %>%
  mutate_all(as.integer) %>%
  mutate_at(
    .vars = vars(-cong_mesg, -emo, -tone_eth), 
    .funs = ~ (. - mean(.)) / sd(.)
  ) %>%
  print()


# ---- imai method -----------------------

# mediation model
mod_m <- lm(
  emo ~ tone_eth + ppage + ppeducat + ppgender + ppincimp, 
  data = bvs_std
  )

# outcome model
mod_y <- glm(
  cong_mesg ~ emo + tone_eth + ppage + ppeducat + ppgender + ppincimp, 
  data = bvs_std, 
  family = binomial("probit")
)

# mediation routine
med_obj <- mediation::mediate(
  mod_m, mod_y, 
  treat = "tone_eth", mediator = "emo",
  sims = 1000, boot = FALSE
)

summary(mod_m)
summary(mod_y)
summary(med_obj)




# ---- Bayesian version -----------------------

# prepare data
stan_data <- bvs_std %$%
  list(
    Y = cong_mesg,
    M = emo,
    T = tone_eth,
    X = dplyr::select(., ppage:ppincimp) %>% as.matrix()
  ) %>%
  c(
    n = nrow(.$X),
    k = ncol(.$X)
  ) 

lapply(stan_data, head)

# prepare model
compiled_mod <- 
  stan_model(
    file = here("static", "code", "mediation", "mediation-bvs.stan"),
    save_dso = TRUE, verbose = TRUE
  )

# S A M P L E 
# Running this a little long to minimize MCSE for the haters
mcmc <- 
  sampling(
    object = compiled_mod, 
    data = stan_data, 
    iter = 4000, 
    thin = 1, 
    pars = c(
      "mhat", "yhat_index", "yhat",
      "m0", "m1", "y1m0", "y1m1", "y0m0", "y0m1", 
      "CME_0", "CME_1",
      "DE_0", "DE_1",
      "TE_0", "TE_1"),
    include = FALSE,
    chains = 4
  )


# compare to OLS/probit versions

mod_m
mod_y
summary(med_obj)
mcmc


# ---- Graphic -----------------------

# want to get the mediation results into a "tidy" looking table

tidy_med <- summary(med_obj) %$%
  tribble(
    ~ term   , ~ estimate , ~ conf.low , ~ conf.high ,
    "ACME_0" , d0         , d0.ci[1]   , d0.ci[2]    ,
    "ACME_1" , d1         , d1.ci[1]   , d1.ci[2]    ,
    "ADE_0"  , z0         , z0.ci[1]   , z0.ci[2]    ,
    "ADE_1"  , z1         , z1.ci[1]   , z1.ci[2]    ,
    "TE"     , tau.coef   , tau.ci[1]  , tau.ci[2]
  ) %>%
  print()

# combines all models in a tidy data frame
alltidy <- 
  bind_rows(
    "Mediation Pkg." = tidy_med, 
    "mod_m" = tidy(mod_m, conf.int = TRUE),
    "mod_y" = tidy(mod_y, conf.int = TRUE),
    "Bayes" = tidy(mcmc, conf.int = TRUE),
    .id = "sub" 
  ) %>%
  print(n = nrow(.))
