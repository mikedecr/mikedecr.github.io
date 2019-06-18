library("here")
library("tidyverse")
library("brms")
library("tidybayes")
library("rstan")
options(mc.cores = parallel::detectCores())
rstan_options(auto_write = TRUE)
library("broom")

anes_raw <- 
  haven::read_dta(here("static", "data", "anes_timeseries_cdf.dta")) %>%
  print()


rr_data <- anes_raw %>%
  filter(VCF0004 == 2012) %>%
  transmute(
    id = VCF0006a,
    pid = VCF0301, 
    item_diff_cond = (VCF9039 - 3), 
    item_special_favs = -1 * (VCF9040 - 3), 
    item_try_harder = -1 * (VCF9041 - 3), 
    item_less_deserve = (VCF9042 - 3)
  ) %>%
  filter_at(vars(starts_with("item_")), ~ .x %in% -2:2) %>%
  mutate(
    sum_rr = item_diff_cond + item_special_favs + item_try_harder + item_less_deserve,
    rr_center = 0.25 * sum_rr,
    rr_std = (rr_center - mean(rr_center)) / sd(rr_center)
  ) %>%
  print()

ggplot(data = rr_data, aes(x = rr_std)) +
  geom_histogram()

rr_sample <- rr_data %>%
  sample_n(200) %>%
  mutate(id = as.factor(id)) %>%
  print()


rr_sample_long <- rr_sample %>%
  gather(key = rr_item, value = rr_response, starts_with("item_")) %>%
  print()




# ----------------------------------------------------
#   compile and estimate model
# ----------------------------------------------------

rr_stanmod <- 
  stanc(file = here("static", "code-blogs", "stan", "racial-IRT.stan")) %>%
  stan_model(stanc_ret = ., verbose = TRUE) %>%
  print()

beepr::beep(2)

stan_data <- rr_sample_long %>%
  mutate_all(labelled::remove_labels) %>%
  compose_data(precision = .0001,
               disc_location = 1) %>%
  print()


rr_stanfit <- 
  sampling(
    object = rr_stanmod, 
    data = stan_data, 
    iter = 2000)

beepr::beep(2)



tidy(rr_stanfit, conf.int = TRUE) %>%
  filter(str_detect(term, "rr_irt")) %>%
  mutate(id = parse_number(term)) %>% 
  left_join(rr_sample %>% transmute(rr_std, id = as.integer(id))) %>%
  # sample_n(100) %>%
  ggplot(aes(x = rr_std, y = estimate)) +
    geom_pointrange(aes(ymin = conf.low, ymax = conf.high),
                    position = position_jitter(width = 0.1),
                    fatten = 0.5) +
    geom_abline() +
    coord_cartesian(ylim = c(-3.25, 3.25), xlim = c(-3.25, 3.25)) +
    theme_minimal() +
    labs(x = "Racial Resentment (Conventional)",
         y = "Measurement Model Estimate")



get_prior(bf(rr_response ~ 0 + ((1 | rr_item) / id) + (1 | rr_item)),
          data = rr_sample_long)

rr_irt <- 
  brm(
    bf(rr_response ~ 0 + ((1 | rr_item) | id) + (1 | rr_item)), 
    data = rr_sample_long, 
    prior = c(
      set_prior("normal(0, 1)", class = "sd", coef = "Intercept
                , group = "rr_item"),
      set_prior("normal(1, 1)", class = "sd", group = "rr_item")
    )
  )


