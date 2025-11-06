#load libraries
require(tidyverse)
require(ggplot2)
require(desplot)
require(patchwork)
require(RColorBrewer)
require(ggforce)
require(ggpubr)
require(data.table)
library(readr)
#set working directory
# setwd("/restricted/projectnb/causal/Nico/output/generative_model")
# setwd("/restricted/projectnb/causal/Nico/output/HIV_prevalence")
# setwd("/work/pi_buchanan_uri_edu/nico_dangelo/Network-Spillover/outputs/Generative_Model")
#import data
# data_path <- paste0(getwd(), "/")
# file_df <-
#   list.files(path="/restricted/projectnb/causal/Nico/output/generative_model") %>% lapply(
#     FUN = function(f) {
#       fread(f)
#     }
#   ) %>% lapply(data.frame, stringsAsFactors = FALSE)

# file_df <-
#   list("N_20_phiv_0.1_model_ER_nsim_200.csv") %>% lapply(
#     FUN = function(f) {
#       fread(f)
#     }
#   ) %>% lapply(data.frame, stringsAsFactors = FALSE)
#file_df<-list(N_50_phiv_0_1_model_BA_nsim_200,N_50_phiv_0_1_model_ER_nsim_200,N_50_phiv_0_1_model_WS_nsim_200)
# file_df <-
#   list(N_20_phiv_0_1_model_ER_nsim_200,
#        N_20_phiv_0_1_model_ER_nsim_2000)
# file_df<-
#   list("N_20_phiv_0.1_p1_0.1_model_ER_nsim_200", "N_20_phiv_0.1_p2_0.1_model_ER_nsim_200") %>%
#   lapply(
#         FUN = function(f) {
#           fread(f)
#         }
#       ) %>% lapply(data.frame, stringsAsFactors = FALSE)
#Manually imported for p1 and p2
# file_df<- list(
#   N_20_phiv_0_1_p1_0_1_model_ER_nsim_200,
#   N_20_phiv_0_1_p2_0_1_model_ER_nsim_200
# )
#manually imported for generative model
# file_df<-list(
#   "N_50_phiv_0.1_model_BA_nsim_200",
#   "N_50_phiv_0.1_model_ER_nsim_200",
#   "N_50_phiv_0.1_model_WS_nsim_200"
# ) %>%lapply(
#     FUN = function(f){
#       fread(f)
#   }
#       ) |> lapply(data.frame, stringsAsFactors = FALSE)
#resampling sample size
# file_df <- list.files(path="/restricted/projectnb/causal/Nico/output/nsim_3_14_24") |> lapply(
#   FUN = function(f){
#     fread(f)
# }
#     ) |> lapply(data.frame, stringsAsFactors = FALSE)
# PrEP contrasts 
# file_df <-  list.files(path="/restricted/projectnb/causal/Nico/output/PrEP_3_14_24") %>% lapply(
#       FUN = function(f) {
#         fread(f)
#       }
#     ) %>% lapply(data.frame, stringsAsFactors = FALSE)
# Cleaning ----------------------------------------------------------------

# res <- rbindlist(file_df)
res <- read_csv("outputs/Generative_Model/N_50phiv_0.1PrEP1_0.2PrEP2_0.4nsim_200.csv")
#clean column-name rows
res_clean <- res %>% filter(model!="model")
# res_clean <- res %>% filter(N != "N")
# shift_columns_left <- function(df) {
#   first_col_name <- names(df)[1]
#   
#   df <- df %>%
#     select(-1) %>%  # Remove first column
#     setNames(c(first_col_name, names(.)[-length(names(.))]))  # Shift names right, keep first name
#   
#   return(df)
# }
# res_clean <- shift_columns_left(res)
# rm(res)
#coerce values back to numeric
res_clean <- res
numeric_columns <-
  colnames(res_clean)[colnames(res_clean) != "model"]
res_clean <- res_clean %>% mutate_at(numeric_columns, as.numeric)

#Subset appropriate PrEP allocation strategy pairs

res_clean <- res_clean %>% filter(PrEP1 < PrEP2)

#Subset contrasts for fixed PrEP analyses of other parameters

res_clean_PrEP_fixed <- res_clean %>% filter(PrEP1 == 0.2 &
                                               PrEP2 == 0.4)
save(res_clean, file = "res_clean.Rda")
save(res_clean_PrEP_fixed, file = "res_clean_PrEP_fixed.Rda")

#Subset contrasts for fixed HIV prevalence analyses of other parameters

res_clean_PrEP_HIV_fixed <-
  res_clean_PrEP_fixed %>% filter(phiv == 0.1)
save(res_clean_PrEP_HIV_fixed, file = "res_clean_PrEP_HIV_0.1_fixed.Rda")

#subset 20-node networks

res_clean_N_PrEP_fixed <- res_clean_PrEP_fixed %>% filter(N == 20)
save(res_clean_N_PrEP_fixed, file = "res_clean_N_PrEP_fixed.Rda")
# fix PrEP, HIV, Network Size, and Generative model for resampling size comparison
res_clean_N_PrEP_HIV_ER_fixed <-
  res_clean_PrEP_fixed %>% filter(phiv == 0.1, N == 20, model == "ER")

# fix PrEP, HIV, and Network Size for generative model comparison

# res_clean_N_PrEP_HIV_fixed <-
#   res_clean_PrEP_fixed %>% filter(phiv == 0.1, N == 50)
# save(res_clean_N_PrEP_HIV_fixed, file = "output/res_clean_N_PrEP_HIV_fixed.Rda")

# Fix all other variables to compare PrEP contrasts (check)
res_clean_PrEP <-
  res_clean %>% filter(N == 20, phiv == 0.1, nsim == 200)

#Underlying risks p1 and p2 data
save(res_clean, file = '/restricted/projectnb/causal/Nico/output/res_clean_underlying_risks.Rda')
# Means across PrEP contrasts ---------------------------------------------

#compute means across PrEP contrasts
means_PrEP <-
  res_clean_PrEP %>% group_by(PrEP1, PrEP2, p1, p2) %>% summarise(across(all_of(
    c(
      "random_contrast",
      "additive_contrast",
      "regenerated_contrast"
    )
  ), mean), .groups = "keep") %>%
  ungroup()

lims_means_PrEP <- c(min(means_PrEP[, c("random_contrast",
                                        "additive_contrast",
                                        "regenerated_contrast")]), max(means_PrEP[, c("random_contrast",
                                                                                      "additive_contrast",
                                                                                      "regenerated_contrast")]))
# Plot means across PrEP contrasts
facet_labels_PrEP <- c()
means_PrEP_grouped <-
  means_PrEP %>% filter(PrEP2 < 1) %>% mutate(group = paste(PrEP1, PrEP2, sep =
                                                              " vs. "))

PrEP_plot_1 <-
  means_PrEP_grouped  %>% ggplot(aes(x = p1, y = p2, fill = random_contrast)) + geom_tile() +
  facet_wrap(~ group,
             scales = "free") + scale_fill_gradientn(limits = lims_means_PrEP, name="Random Contrast", colors = brewer.pal(10, name =
                                                                                                     "RdYlBu")) + xlab("P(HIV|Contact and -PrEP)") + ylab("P(HIV|Contact and PrEP)") +
  ggtitle("Contrast Estimate Mean in Random PrEP Allocation by PrEP Coverage on N=20-node Networks ") +  theme(plot.title = element_text(hjust = 0.5))
#+
# scale_x_discrete(guide = guide_axis(n.dodge = 2))
#ncol = 9,
#nrow = 4)


PrEP_plot_2 <-
  means_PrEP_grouped %>% ggplot(aes(x = p1, y = p2, fill = additive_contrast)) + geom_tile() +
  facet_wrap(~ group,
             scales = "free") + scale_fill_gradientn(limits = lims_means_PrEP, name="Additive Contrast", colors = brewer.pal(10, name ="RdYlBu")) + xlab("P(HIV|Contact and -PrEP)") + ylab("P(HIV|Contact and PrEP)") +
  ggtitle(
    "Contrast Estimate Mean in Additive PrEP Allocation by PrEP Coverage on N=20-node Networks") +  theme(plot.title = element_text(hjust = 0.5))

             #ncol = 9,nrow = 4) 
# +
#   scale_x_discrete(guide = guide_axis(n.dodge = 2))

PrEP_plot_3 <-
  means_PrEP_grouped %>% ggplot(aes(x = p1, y = p2, fill = regenerated_contrast)) + geom_tile() +
  facet_wrap(~ group,
             scales = "free") + xlab("P(HIV|Contact and -PrEP)") + ylab("P(HIV|Contact and PrEP)") +
  ggtitle(
    "Contrast Estimate Mean in Regenerated PrEP Allocation by PrEP Coverage on N=20-node Networks"
  ) +  theme(plot.title = element_text(hjust = 0.5)) + scale_fill_gradientn(limits = lims_means_PrEP, name="Regenerated Contrast", colors = brewer.pal(10, name ="RdYlBu")) + xlab("P(HIV|Contact and -PrEP)") + ylab("P(HIV|Contact and PrEP)") +
                                                                              ggtitle(
                                                                                "Contrast Estimate Mean in Regenerated PrEP Allocation by PrEP Coverage on N=20-node Networks") +  theme(plot.title = element_text(hjust = 0.5))
                                                                                                                            
             #ncol = 9,
             #nrow = 4) 
# +
#   scale_x_discrete(guide = guide_axis(n.dodge = 2))
ggsave(
  "PrEP Random Mean Plots.png",
  plot = PrEP_plot_1,
  path = "/restricted/projectnb/causal/Nico/plots/",
  width = 1920,
  height = 980,
  units = "px",
  dpi = 96
)
ggsave(
  "PrEP Additive Mean Plots.png",
  plot = PrEP_plot_2,
  path = "/restricted/projectnb/causal/Nico/plots/",
  width = 1920,
  height = 980,
  units = "px",
  dpi = 96
)
ggsave(
  "PrEP Regenerated Mean Plots.png",
  plot = PrEP_plot_3,
  path = "/restricted/projectnb/causal/Nico/plots/",
  width = 1920,
  height = 980,
  units = "px",
  dpi = 96
)

#compute variances across PrEP contrasts

vars_PrEP <-
  res_clean_PrEP %>%  group_by(PrEP1, PrEP2, p1, p2) %>%
  summarise(across(all_of(
    c(
      "random_contrast",
      "additive_contrast",
      "regenerated_contrast"
    )
  ), var), .groups = "keep") %>% ungroup()

lims_vars_PrEP <- c(min(vars_PrEP[, c("random_contrast",
                                      "additive_contrast",
                                      "regenerated_contrast")]), max(vars_PrEP[, c("random_contrast",
                                                                                   "additive_contrast",
                                                                                   "regenerated_contrast")]))
vars_PrEP_grouped <-
  vars_PrEP %>% filter(PrEP2 < 1) %>% mutate(group = paste(PrEP1, PrEP2, sep =
                                                             " vs. "))

PrEP_plot_4 <-
  vars_PrEP_grouped  %>% ggplot(aes(x = p1, y = p2, fill = random_contrast)) + geom_tile() +
  facet_wrap(~ group,
             scales = "free") + scale_fill_gradientn(limits = lims_vars_PrEP, name="Random Contrast", colors = brewer.pal(10, name =
                                                                                                    "RdYlBu")) + xlab("P(HIV|Contact and -PrEP)") + ylab("P(HIV|Contact and PrEP)") +
  ggtitle(
    "Contrast Estimate Variance in Random PrEP Allocation by PrEP Coverage on N=20-node Networks"
  ) +  theme(plot.title = element_text(hjust = 0.5))
# +
# scale_x_discrete(guide = guide_axis(n.dodge = 2))

PrEP_plot_5 <-
  vars_PrEP_grouped %>% ggplot(aes(x = p1, y = p2, fill = additive_contrast)) + geom_tile() +
  facet_wrap(~ group,
             scales = "free") + scale_fill_gradientn(limits = lims_vars_PrEP, name="Additive Contrast", colors = brewer.pal(10, name =
                                                                                                    "RdYlBu")) + xlab("P(HIV|Contact and -PrEP)") + ylab("P(HIV|Contact and PrEP)") +
  ggtitle(
    "Contrast Estimate Variance in Additive PrEP Allocation by PrEP Coverage on N=20-node Networks"
  ) +  theme(plot.title = element_text(hjust = 0.5))
# +
# scale_x_discrete(guide = guide_axis(n.dodge = 2))

PrEP_plot_6 <-
  vars_PrEP_grouped %>% ggplot(aes(x = p1, y = p2, fill = regenerated_contrast)) + geom_tile() +
  facet_wrap(~ group,
             scales = "free") + scale_fill_gradientn(limits = lims_vars_PrEP, name="Regenerated Contrast", colors = brewer.pal(10, name =
                                                                                                    "RdYlBu")) + xlab("P(HIV|Contact and -PrEP)") + ylab("P(HIV|Contact and PrEP)") +
  ggtitle(
    "Contrast Estimate Variance in Regenerated PrEP Allocation by PrEP Coverage on N=20-node Networks"
  ) +  theme(plot.title = element_text(hjust = 0.5))
# +
#   scale_x_discrete(guide = guide_axis(n.dodge = 2))
ggsave(
  "PrEP Random Variance Plots.png",
  plot = PrEP_plot_4,
  path = "/restricted/projectnb/causal/Nico/plots/",
  width = 1920,
  height = 980,
  units = "px",
  dpi = 96
)
ggsave(
  "PrEP Additive Variance Plots.png",
  plot = PrEP_plot_5,
  path = "/restricted/projectnb/causal/Nico/plots/",
  width = 1920,
  height = 980,
  units = "px",
  dpi = 96
)
ggsave(
  "PrEP Regenerated Variance Plots.png",
  plot = PrEP_plot_6,
  path = "/restricted/projectnb/causal/Nico/plots/",
  width = 1920,
  height = 980,
  units = "px",
  dpi = 96
)


# Means across underlying risks -------------------------------------------

#Plot means across underlying risks

#compute means and variances across risks

#Across P(HIV| Contact and No PrEP) fixing #P(HIV | contact and PrEP at 0.1)
means_p1 <-
  res_clean %>% group_by(p1, p2) %>% filter(p2 == 0.1) %>% summarise(across(all_of(
    c(
      "random_contrast",
      "additive_contrast",
      "regenerated_contrast"
    )
  ), mean), .groups = "keep") %>% ungroup()

vars_p1 <-
  res_clean %>% group_by(p1, p2) %>% filter(p2 == 0.1) %>% summarise(across(all_of(
    c(
      "random_contrast",
      "additive_contrast",
      "regenerated_contrast"
    )
  ), var), .groups = "keep") %>% ungroup()

lims_means_p1 <-
  c(min(means_p1[, c("random_contrast",
                     "additive_contrast",
                     "regenerated_contrast")]), max(means_p1[, c("random_contrast",
                                                                 "additive_contrast",
                                                                 "regenerated_contrast")]))

lims_vars_p1 <-
  c(min(vars_p1[, c("random_contrast",
                    "additive_contrast",
                    "regenerated_contrast")]), max(vars_p1[, c("random_contrast",
                                                               "additive_contrast",
                                                               "regenerated_contrast")]))
 p1_plot_1 <-
  ggplot(means_p1, aes_string(x = "p1", y = "random_contrast")) + geom_point() +
  scale_y_continuous(limits = lims_means_p1) + xlab("P(HIV|Contact and -PrEP)") + ylab("Random Contrast") +
  scale_x_discrete(breaks = seq(0.1, 1, 0.05))
p1_plot_2 <-
  ggplot(means_p1, aes_string(x = "p1", y = "additive_contrast")) + geom_point() +
  scale_y_continuous(limits = lims_means_p1) + xlab("P(HIV|Contact and -PrEP)") + ylab("Additive Contrast") +
  scale_x_discrete(breaks = seq(0.1, 1, 0.05))
p1_plot_3 <-
  ggplot(means_p1, aes_string(x = "p1", y = "regenerated_contrast")) + geom_point() +
  scale_y_continuous(limits = lims_means_p1) + xlab("P(HIV|Contact and -PrEP)") + ylab("Regenerated Contrast") + 
  scale_x_discrete(breaks = seq(0.1, 1, 0.05))
p1_plot_2 / p1_plot_1 / p1_plot_3 +    # Create grid of plots with title
  plot_annotation(title = "Contrast Estimate Mean by P(HIV|Contact and -PrEP) and Allocation with 20% vs 40% PrEP coverage, P(HIV|Contact and PrEP)=0.1 on N=20 networks ") &
  theme(plot.title = element_text(hjust = 0.5))
ggsave(
  plot = p1_plot_2 / p1_plot_1 / p1_plot_3 +    # Create grid of plots with title
    plot_annotation(title = "Contrast Estimate Mean by P(HIV|Contact and -PrEP) and Allocation with 20% vs 40% PrEP coverage, P(HIV|Contact and PrEP)=0.1 on N=20 networks ") &
    theme(plot.title = element_text(hjust = 0.5)),
  width=1350,
  height =544 ,
  units = "px",
  dpi=96,
  file = "p1 Mean plots.png",
  path = "/restricted/projectnb/causal/Nico/plots/"
)


#Across P(HIV| Contact and PrEP) fixing #P(HIV | contact and  No PrEP at 0.1)

means_p2 <-
  res_clean %>% group_by(p1, p2) %>% filter(p1 == 0.1) %>% summarise(across(all_of(
    c(
      "random_contrast",
      "additive_contrast",
      "regenerated_contrast"
    )
  ), mean), .groups = "keep") %>% ungroup()

vars_p2 <-
  res_clean %>% group_by(p1, p2) %>% filter(p1 == 0.1) %>% summarise(across(all_of(
    c(
      "random_contrast",
      "additive_contrast",
      "regenerated_contrast"
    )
  ), var), .groups = "keep") %>% ungroup()

lims_means_p2 <-
  c(min(means_p2[, c("random_contrast",
                     "additive_contrast",
                     "regenerated_contrast")]), max(means_p2[, c("random_contrast",
                                                                 "additive_contrast",
                                                                 "regenerated_contrast")]))

lims_vars_p2 <-
  c(min(vars_p2[, c("random_contrast",
                    "additive_contrast",
                    "regenerated_contrast")]), max(vars_p2[, c("random_contrast",
                                                               "additive_contrast",
                                                               "regenerated_contrast")]))
p2_plot_1 <-
  ggplot(means_p2, aes_string(x = "p2", y = "random_contrast")) + geom_point() +
  scale_y_continuous(limits = lims_means_p2) + xlab("P(HIV|Contact and PrEP)") +
  scale_x_discrete(breaks = seq(0.1, 1, 0.05)) +ylab("Random Contrast")
p2_plot_2 <-
  ggplot(means_p2, aes_string(x = "p2", y = "additive_contrast")) + geom_point() +
  scale_y_continuous(limits = lims_means_p2) + xlab("P(HIV|Contact and PrEP)") +
  scale_x_discrete(breaks = seq(0.1, 1, 0.05)) + ylab("Additive Contrast")
p2_plot_3 <-
  ggplot(means_p2, aes_string(x = "p2", y = "regenerated_contrast")) + geom_point() +
  scale_y_continuous(limits = lims_means_p2) + xlab("P(HIV|Contact and PrEP)") +
  scale_x_discrete(breaks = seq(0.1, 1, 0.05)) + ylab("Regenerated Contrast")
p2_plot_2 / p2_plot_1 / p2_plot_3  

ggsave(
  plot = p2_plot_2 / p2_plot_1 / p2_plot_3 +    # Create grid of plots with title
    plot_annotation(title = "Contrast Estimate Mean by P(HIV|Contact and PrEP) and Allocation with 20% vs 40% PrEP coverage, P(HIV|Contact and -PrEP)=0.1 on N=20 networks") &
    theme(plot.title = element_text(hjust = 0.5)),
  width=1350,
  height =544 ,
  units = "px",
  dpi=96,
  file = "p2 Mean plots.png",
  path = "/restricted/projectnb/causal/Nico/plots/"
)


# Variances across underlying risks ---------------------------------------

#Across P(HIV| Contact and -PrEP) fixing #P(HIV | contact and  PrEP at 0.1)

p1_plot_4 <-
  ggplot(vars_p1, aes_string(x = "p1", y = "random_contrast")) + geom_point() +
  scale_y_continuous(limits = lims_vars_p1) + xlab("P(HIV|Contact and -PrEP)") +
  scale_x_discrete(breaks = seq(0.1, 1, 0.05)) +ylab("Random Contrast")

p1_plot_5 <-
  ggplot(vars_p1, aes_string(x = "p1", y = "additive_contrast")) + geom_point() +
  scale_y_continuous(limits = lims_vars_p1) + xlab("P(HIV|Contact and -PrEP)") +
  scale_x_discrete(breaks = seq(0.1, 1, 0.05)) +ylab("Additive Contrast")

p1_plot_6 <-
  ggplot(vars_p1, aes_string(x = "p1", y = "regenerated_contrast")) + geom_point() +
  scale_y_continuous(limits = lims_vars_p1) + xlab("P(HIV|Contact and -PrEP)") +
  scale_x_discrete(breaks = seq(0.1, 1, 0.05)) + ylab("Regenerated Contrast")

p1_plot_5 / p1_plot_4 / p1_plot_6

ggsave(
  plot = p1_plot_5 / p1_plot_4 / p1_plot_6 +    # Create grid of plots with title
    plot_annotation(title = "Contrast Estimate Variance by P(HIV|Contact and -PrEP) and Allocation with 20% vs 40% PrEP coverage, P(HIV|Contact and PrEP)=0.1 on N=20 networks") &
    theme(plot.title = element_text(hjust = 0.5)),
  width=1350,
  height =544 ,
  units = "px",
  dpi=96,
  file = "p1 Variance plots.png",
  path = "/restricted/projectnb/causal/Nico/plots/"
)

#Across P(HIV| Contact and PrEP) fixing #P(HIV | contact and  No PrEP at 0.1)
p2_plot_4 <-
  ggplot(vars_p2, aes_string(x = "p2", y = "random_contrast")) + geom_point() +
  scale_y_continuous(limits = lims_vars_p2) + xlab("P(HIV|Contact and PrEP)") +
  scale_x_discrete(breaks = seq(0.1, 1, 0.05)) + ylab("Random Contrast")

p2_plot_5 <-
  ggplot(vars_p2, aes_string(x = "p2", y = "additive_contrast")) + geom_point() +
  scale_y_continuous(limits = lims_vars_p2) + xlab("P(HIV|Contact and PrEP)") +
  scale_x_discrete(breaks = seq(0.1, 1, 0.05)) +ylab("Additive Contrast")

p2_plot_6 <-
  ggplot(vars_p2, aes_string(x = "p2", y = "regenerated_contrast")) + geom_point() +
  scale_y_continuous(limits = lims_vars_p2) + xlab("P(HIV|Contact and PrEP)") +
  scale_x_discrete(breaks = seq(0.1, 1, 0.05)) + ylab("Regenerated Contrast")

p2_plot_5 / p2_plot_4 / p2_plot_6

ggsave(
  plot = p2_plot_5 / p2_plot_4 / p2_plot_6 +    # Create grid of plots with title
    plot_annotation(title = "Contrast Estimate Variance by P(HIV|Contact and PrEP) and Allocation with 20% vs 40% PrEP coverage, P(HIV|Contact and -PrEP)=0.1 on N=20 networks ") &
    theme(plot.title = element_text(hjust = 0.5)),
  width=1350,
  height =544 ,
  units = "px",
  dpi=96,
  file = "p2 Variance plots.png",
  path = "/restricted/projectnb/causal/Nico/plots/"
)

# Means across Network Size -----------------------------------------------


means_N <-
  res_clean_PrEP_HIV_fixed %>% group_by(N, p1, p2) %>% summarise(across(all_of(
    c(
      "random_contrast",
      "additive_contrast",
      "regenerated_contrast"
    )
  ), mean), .groups = "keep") %>% ungroup()

lims_means_N <- c(min(means_N[, c("random_contrast",
                                  "additive_contrast",
                                  "regenerated_contrast")]), max(means_N[, c("random_contrast",
                                                                             "additive_contrast",
                                                                             "regenerated_contrast")]))

#truncate graph limits at 15 th percentile of regenerated contrast
# means_N_trunc<- means_N %>% filter(regenerated_contrast>=quantile(means_N$regenerated_contrast, probs=c(0.15)))
# lims_means_N_trunc<-c(min(means_N_trunc[, c("random_contrast",
#                                 "additive_contrast",
#                                 "regenerated_contrast")]), max(means_N_trunc[, c("random_contrast",
#                                                                             "additive_contrast",
#                                                                             "regenerated_contrast")]))


# Plots means by Network Size ---------------------------------------------


facet_labels_N <- c(`20` = "N=20", `200` = "N=200")
N_plot_1 <-
  means_N %>%  ggplot(aes(x = p1, y = p2, fill = random_contrast)) + geom_tile() +
  facet_grid( ~ N, labeller = labeller(N = facet_labels_N)) + scale_fill_gradientn(
    name = "Random Contrast",
    limits = lims_means_N,
    #breaks=quantile(means_N$random_contrast),
    colors =
      brewer.pal(11, name = "RdYlBu")
  ) + xlab("P(HIV|Contact and -PrEP)") + ylab("P(HIV|Contact and PrEP)")
N_plot_2 <-
  means_N %>% ggplot(aes(x = p1, y = p2, fill = additive_contrast)) + geom_tile() +
  facet_grid( ~ N, labeller = labeller(N = facet_labels_N)) + scale_fill_gradientn(
    name = "Additive Contrast",
    limits = lims_means_N,
    colors =
      brewer.pal(11, name = "RdYlBu")
  ) + xlab("P(HIV|Contact and -PrEP)") + ylab("P(HIV|Contact and PrEP)")
N_plot_3 <-
  means_N %>% ggplot(aes(x = p1, y = p2, fill = regenerated_contrast)) + geom_tile() +
  facet_grid( ~ N, labeller = labeller(N = facet_labels_N)) + scale_fill_gradientn(name = "Regenerated Contrast",
                                                                                   limits = lims_means_N,
                                                                                   colors = brewer.pal(6, name = "RdYlBu")) + xlab("P(HIV|Contact and -PrEP)") + ylab("P(HIV|Contact and PrEP)")
N_plot_2 / N_plot_1 / N_plot_3 +
  # Create grid of plots with title
  plot_annotation(title = "Contrast Estimate Mean by Network Size and Allocation") &
  theme(plot.title = element_text(hjust = 0.5))

ggsave(
  plot = N_plot_2 / N_plot_1 / N_plot_3 +    # Create grid of plots with title
    plot_annotation(title = "Contrast Estimate Mean by Network Size and Allocation with 20% PrEP vs. 40% PrEP coverage and 10% HIV Prevalence") &
    theme(plot.title = element_text(hjust = 0.5)),
  device = "png",
  width = 11,
  height = 9,
  units = "in",
  file = "Network Size Mean Plot.png",
  path = "/restricted/projectnb/causal/Nico/plots/"
)

# Variances across network size -------------------------------------------

vars_N <-
  res_clean_PrEP_HIV_fixed %>% group_by(N, p1, p2) %>% summarise(across(all_of(
    c(
      "random_contrast",
      "additive_contrast",
      "regenerated_contrast"
    )
  ), var), .groups = "keep") %>% ungroup()
lims_vars_N <- c(min(vars_N[, c("random_contrast",
                                "additive_contrast",
                                "regenerated_contrast")]), max(vars_N[, c("random_contrast",
                                                                          "additive_contrast",
                                                                          "regenerated_contrast")]))

# Plot Variances across Network Size --------------------------------------

N_plot_4 <-
  vars_N %>% ggplot(aes(x = p1, y = p2, fill = random_contrast)) + geom_tile() +
  facet_grid( ~ N, labeller = labeller(N = facet_labels_N)) + scale_fill_gradientn(
    name = "Random Contrast",
    limits = lims_vars_N,
    colors =
      brewer.pal(11, name = "RdYlBu")
  ) + xlab("P(HIV|Contact and -PrEP)") + ylab("P(HIV|Contact and PrEP)")
N_plot_5 <-
  vars_N %>% ggplot(aes(x = p1, y = p2, fill = additive_contrast)) + geom_tile() +
  facet_grid( ~ N, labeller = labeller(N = facet_labels_N)) + scale_fill_gradientn(
    name = "Additive Contrast",
    limits = lims_vars_N,
    colors =
      brewer.pal(11, name = "RdYlBu")
  ) + xlab("P(HIV|Contact and -PrEP)") + ylab("P(HIV|Contact and PrEP)")
N_plot_6 <-
  vars_N %>% ggplot(aes(x = p1, y = p2, fill = regenerated_contrast)) + geom_tile() +
  facet_grid( ~ N, labeller = labeller(N = facet_labels_N)) + scale_fill_gradientn(
    name = "Regenerated Contrast",
    limits = lims_vars_N,
    breaks = waiver(),
    colors = brewer.pal(11, name = "RdYlBu")
  ) + xlab("P(HIV|Contact and -PrEP)") + ylab("P(HIV|Contact and PrEP)")
N_plot_5 / N_plot_4 / N_plot_6

ggsave(
  plot = N_plot_5 / N_plot_4 / N_plot_6 + plot_annotation(title = "Contrast Estimate Variance by Network Size and Allocation \n with 20% PrEP vs. 40% PrEP coverage") &
    theme(plot.title = element_text(hjust = 0.5))
  ,
  device = "png",
  width = 11,
  height = 9,
  units = "in",
  file = "Network Size Variance plots.png",
  path = "/restricted/projectnb/causal/Nico/plots/"
)

# Means by initial HIV prevalence ------------------------------------
means_phiv <-
  res_clean_N_PrEP_fixed %>% group_by(phiv, p1, p2) %>% summarise(across(all_of(
    c(
      "random_contrast",
      "additive_contrast",
      "regenerated_contrast"
    )
  ), mean), .groups = "keep") %>% ungroup()

lims_means_phiv <- c(min(means_phiv[, c("random_contrast",
                                        "additive_contrast",
                                        "regenerated_contrast")]), max(means_phiv[, c("random_contrast",
                                                                                      "additive_contrast",
                                                                                      "regenerated_contrast")]))

# Variances by HIV Prevalence ---------------------------------------------

vars_phiv <-
  res_clean_N_PrEP_fixed %>% group_by(phiv, p1, p2) %>% summarise(across(all_of(
    c(
      "random_contrast",
      "additive_contrast",
      "regenerated_contrast"
    )
  ), var), .groups = "keep") %>% ungroup()

lims_vars_phiv <- c(min(vars_phiv[, c("random_contrast",
                                      "additive_contrast",
                                      "regenerated_contrast")]), max(vars_phiv[, c("random_contrast",
                                                                                   "additive_contrast",
                                                                                   "regenerated_contrast")]))
# Plot Means by HIV prevalence --------------------------------------------

phiv_plot_1 <-
  means_phiv %>% ggplot(aes(x = p1, y = p2, fill = random_contrast)) + geom_tile() +
  facet_grid( ~ phiv) + scale_fill_gradientn(limits = lims_means_phiv,
                                             name="Random Contrast",
                                             colors =
                                               brewer.pal(11, name = "RdYlBu")) + xlab("P(HIV|Contact and -PrEP)") + ylab("P(HIV|Contact and PrEP)")

phiv_plot_2 <-
  means_phiv %>% ggplot(aes(x = p1, y = p2, fill = additive_contrast)) + geom_tile() +
  facet_grid( ~ phiv) + scale_fill_gradientn(limits = lims_means_phiv,
                                             name="Additive Contrast",
                                             colors =
                                               brewer.pal(11, name = "RdYlBu")) + xlab("P(HIV|Contact and -PrEP)") + ylab("P(HIV|Contact and PrEP)")

phiv_plot_3 <-
  phiv_plot_1 <-
  means_phiv %>% ggplot(aes(x = p1, y = p2, fill = regenerated_contrast)) + geom_tile() +
  facet_grid( ~ phiv) + scale_fill_gradientn(limits = lims_means_phiv,
                                             name="Regenerated Contrast",
                                             colors =
                                               brewer.pal(11, name = "RdYlBu")) + xlab("P(HIV|Contact and -PrEP)") + ylab("P(HIV|Contact and PrEP)")

phiv_plot_2 / phiv_plot_1 / phiv_plot_3 + plot_annotation(title = "Contrast Estimate Mean by HIV Prevalence and Allocation \n with 20% PrEP vs. 40% PrEP coverage on N=20-node Networks") &
  theme(plot.title = element_text(hjust = 0.5))
ggsave(
  plot = phiv_plot_2 / phiv_plot_1 / phiv_plot_3 + plot_annotation(title = "Contrast Estimate Mean by HIV Prevalence and Allocation \n with 20% PrEP vs. 40% PrEP coverage on N=20-node Networks") &
    theme(plot.title = element_text(hjust = 0.5)),
  device = "png",
  width = 13,
  height = 9,
  units = "in",
  file = "HIV Prevalence Mean Plot.png",
  path = "/restricted/projectnb/causal/Nico/plots/"
)

# Plot Variances by HIV Prevalence ----------------------------------------

phiv_plot_4 <-
  vars_phiv %>% ggplot(aes(x = p1, y = p2, fill = random_contrast)) + geom_tile() +
  facet_grid( ~ phiv) + scale_fill_gradientn(
    name = "Random Contrast",
    limits = lims_vars_phiv,
    colors =
      brewer.pal(11, name = "RdYlBu")) + xlab("P(HIV|Contact and -PrEP)") + ylab("P(HIV|Contact and PrEP)")
phiv_plot_5 <-
  vars_phiv %>% ggplot(aes(x = p1, y = p2, fill = additive_contrast)) + geom_tile() +
  facet_grid( ~ phiv) + scale_fill_gradientn(
    name = "Additive Contrast",
    limits = lims_vars_phiv,
    colors =
      brewer.pal(11, name = "RdYlBu")) + xlab("P(HIV|Contact and -PrEP)") + ylab("P(HIV|Contact and PrEP)")
phiv_plot_6 <-
  vars_phiv %>% ggplot(aes(x = p1, y = p2, fill = regenerated_contrast)) + geom_tile() +
  facet_grid( ~ phiv) + scale_fill_gradientn(
    name = "Regenerated Contrast",
    limits = lims_vars_phiv,
    colors = brewer.pal(11, name = "RdYlBu")) + xlab("P(HIV|Contact and -PrEP)") + ylab("P(HIV|Contact and PrEP)")

phiv_plot_5 / phiv_plot_4 / phiv_plot_6
ggsave(
  plot = phiv_plot_5 / phiv_plot_4 / phiv_plot_6 + plot_annotation(title = "Contrast Estimate Variance by HIV Prevalence and Allocation \n with 20% PrEP vs. 40% PrEP coverage on N=20-node Networks") &
    theme(plot.title = element_text(hjust = 0.5)),
  device = "png",
  width = 13,
  height = 9,
  units = "in",
  file = "HIV Prevalence Variance Plot.png",
  path = "/restricted/projectnb/causal/Nico/plots/"
)


# Means by Network Generative Model ---------------------------------------
res_generative_model <- res_clean
means_model <-
  res_generative_model %>% group_by(model, p1, p2) %>% summarise(across(all_of(
    starts_with("RD_")
    # c("RD_random",
      # "RD_additive",
      # "RD_regenerated"
    # )
  ), mean),.groups = "keep") %>% ungroup()

lims_means_model <- c(min(means_model[, c("RD_random",
                                          "RD_additive",
                                          "RD_regenerated"
)]), max(means_model[, c("RD_random",
                         "RD_additive",
                         "RD_regenerated"
)]))

# Plot Means by Generative Model ------------------------------------------

model_plot_1 <-
  means_model %>% ggplot(aes(x = p1, y = p2, fill = RD_random)) + geom_tile() +
  facet_grid( ~ model) + scale_fill_gradientn(limits = lims_means_model, breaks=lims_means_model,
                                              name="Random Mean RD",
                                              colors =
                                                brewer.pal(11, name = "RdYlBu")) + xlab("P(HIV|Contact and -PrEP)") + ylab("P(HIV|Contact and PrEP)")

model_plot_2 <-
  means_model %>% ggplot(aes(x = p1, y = p2, fill = RD_additive)) + geom_tile() +
  facet_grid( ~ model) + scale_fill_gradientn(limits = lims_means_model, breaks=lims_means_model,
                                              name="Additive  Mean RD",
                                              colors =
                                                brewer.pal(11, name = "RdYlBu")) + xlab("P(HIV|Contact and -PrEP)") + ylab("P(HIV|Contact and PrEP)")
model_plot_3 <-
  means_model %>% ggplot(aes(x = p1, y = p2, fill = RD_regenerated)) + geom_tile() +
  facet_grid( ~ model) + scale_fill_gradientn(limits = lims_means_model, breaks=lims_means_model,
                                              name="Regenerated Mean RD",
                                              colors =
                                                brewer.pal(11, name = "RdYlBu")) + xlab("P(HIV|Contact and -PrEP)") + ylab("P(HIV|Contact and PrEP)")

model_plot_2/model_plot_1/model_plot_3
ggsave(
  plot = model_plot_2 / model_plot_1 / model_plot_3 + plot_annotation(title = "Contrast Estimate Mean by Generative Model and Allocation \n with 20% PrEP vs. 40% PrEP coverage on N=50-node Networks") &
    theme(plot.title = element_text(hjust = 0.5)),
  device = "png",
  width = 13,
  height = 9,
  units = "in",
  file = "Generative Model Mean Plot.png",
  path = "/work/pi_buchanan_uri_edu/nico_dangelo/Network-Spillover/Corrected Figures"
)


# Variances by Network Generative Model -----------------------------------

vars_model <-
  res_generative_model %>% group_by(model, p1, p2) %>% summarise(across(all_of(
starts_with("RD_")    # c(
    #   "random_contrast",
    #   "additive_contrast",
    #   "regenerated_contrast"
    # )
  ), var), .groups = "keep") %>% ungroup()

lims_vars_model <- c(min(vars_model[, c("RD_random",
                                        "RD_additive",
                                        "RD_regenerated")]), max(vars_model[, c("RD_random",
                                                                                      "RD_additive",
                                                                                      "RD_regenerated")]))

# Plot Variances by Generative Plot ---------------------------------------

model_plot_4 <-
  vars_model %>% ggplot(aes(x = p1, y = p2, fill = RD_random)) + geom_tile() +
  facet_grid( ~ model) + scale_fill_gradientn(limits = lims_vars_model,
                                              name="Random RD Variance",
                                              colors =
                                                brewer.pal(11, name = "RdYlBu")) + xlab("P(HIV|Contact and -PrEP)") + ylab("P(HIV|Contact and PrEP)")
model_plot_5 <-
  vars_model %>% ggplot(aes(x = p1, y = p2, fill = RD_additive)) + geom_tile() +
  facet_grid( ~ model) + scale_fill_gradientn(limits = lims_vars_model,
                                              name="Additive RD Variance",
                                              colors =
                                                brewer.pal(11, name = "RdYlBu")) + xlab("P(HIV|Contact and -PrEP)") + ylab("P(HIV|Contact and PrEP)")
model_plot_6 <-
  vars_model %>% ggplot(aes(x = p1, y = p2, fill = RD_regenerated)) + geom_tile() +
  facet_grid( ~ model) + scale_fill_gradientn(limits = lims_vars_model,
                                              name="Regenerated RD Variance",
                                              colors = brewer.pal(11, name = "RdYlBu")) + xlab("P(HIV|Contact and -PrEP)") + ylab("P(HIV|Contact and PrEP)")

model_plot_5 / model_plot_4 / model_plot_6
ggsave(
  plot = model_plot_5 / model_plot_4 / model_plot_6 + plot_annotation(title = "Contrast Estimate Variance by Generative Model and Allocation \n with 20% PrEP vs. 40% PrEP coverage on N=50-node Networks") &
    theme(plot.title = element_text(hjust = 0.5)),
  device = "png",
  width = 13,
  height = 9,
  units = "in",
  file = "Generative Model Variance Plot.png",
  path = "/work/pi_buchanan_uri_edu/nico_dangelo/Network-Spillover/Corrected Figures"
)


# Summary Statistics by Generative Model ----------------------------------
res_model <- res_clean_N_PrEP_HIV_fixed
model_plot_7 <-
  ggboxplot(
    res_model,
    x = "model",
    y = c("Number_of_Components_g", "Number_of_Components_k"),
    ylab = F,
    merge = T
  )
model_plot_8 <-
  ggboxplot(
    res_model,
    x = "model",
    y = c("Largest_Component_Size_g", "Largest_Component_Size_k"),
    ylab = F,
    merge = T
  )
model_plot_9 <-
  ggboxplot(
    res_model,
    x = "model",
    y = c("Avg._Betweenness_g", "Avg._Betweenness_k"),
    ylab = F,
    merge = T
  )
model_plot_10 <-
  ggboxplot(
    res_model,
    x = "model",
    y = c("Density_g", "Density_k"),
    ylab = F,
    merge = T
  )
model_plot_11 <-
  ggboxplot(
    res_model,
    x = "model",
    y = c("Degree_Centralization_g", "Degree_Centralization_k"),
    ylab = F,
    merge = T
  )
model_plot_12 <-
  ggboxplot(
    res_model,
    x = "model",
    y = c("Avg._Geodesic.Distance_g", "Avg._Geodesic.Distance_k"),
    ylab = F,
    merge = T
  )
model_plot_13 <-
  ggboxplot(
    res_model,
    x = "model",
    y = c("Diameter_g", "Diameter_k"),
    ylab = F,
    merge = T
  )
model_plot_14 <-
  ggboxplot(
    res_model,
    x = "model",
    y = c("Transitivity_g", "Transitivity_k"),
    ylab = F,
    merge = T
  )
model_plot_15 <-
  ggboxplot(
    res_model,
    x = "model",
    y = c(
      "Proportion_of_nodes_in_2.cores_g",
      "Proportion_of_nodes_in_2.cores_k"
    ),
    ylab = F,
    merge = T
  )
model_plot_16 <-
  ggboxplot(
    res_model,
    x = "model",
    y = c("Degree_Assortativity_g", "Degree_Assortativity_k"),
    ylab = F,
    merge = T
  )
ggsave(
  model_plot_7 + model_plot_8 + model_plot_9 + model_plot_10 + model_plot_12 +
    model_plot_13 + model_plot_14 + model_plot_15 +    # Create grid of plots with title
    plot_annotation(title = "Network Summary Statistics by Generative Model and Allocation") &
    theme(plot.title = element_text(hjust = 0.5)),
  width = 1920,
  height = 976,
  dpi = 96,
  units = "px",
  file = "Network Summary Statistics.png",
  path = "plots"
)

# Means by Resampling Size ------------------------------------------------

means_nsim <-
  res_clean_nsim %>% group_by(nsim, p1, p2) %>% summarise(across(all_of(
    c(
      "random_contrast",
      "additive_contrast",
      "regenerated_contrast"
    )
  ), mean), .groups = "keep") %>% ungroup()

lims_means_nsim <- c(min(means_nsim[, c("random_contrast",
                                        "additive_contrast",
                                        "regenerated_contrast")]), max(means_nsim[, c("random_contrast",
                                                                                      "additive_contrast",
                                                                                      "regenerated_contrast")]))

# Plot means by resampling size -------------------------------------------
facet_labels_nsim <- c(`200` = "n=200", `2000` = "n=2000")
nsim_plot_1 <-
  means_nsim %>% ggplot(aes(x = p1, y = p2, fill = random_contrast)) + geom_tile() +
  facet_grid( ~ nsim, labeller = labeller(nsim = facet_labels_nsim)) + scale_fill_gradientn(limits = lims_means_nsim,
                                                                                            name="Random Contrast",
                                                                                            colors =
                                                                                              brewer.pal(11, name = "RdYlBu")) + xlab("P(HIV|Contact and -PrEP)") + ylab("P(HIV|Contact and PrEP)")

nsim_plot_2 <-
  means_nsim %>% ggplot(aes(x = p1, y = p2, fill = additive_contrast)) + geom_tile() +
  facet_grid( ~ nsim, labeller = labeller(nsim = facet_labels_nsim)) + scale_fill_gradientn(limits = lims_means_nsim,
                                                                                            name="Additive Contrast",
                                                                                            colors =
                                                                                              brewer.pal(11, name = "RdYlBu")) + xlab("P(HIV|Contact and -PrEP)") + ylab("P(HIV|Contact and PrEP)")
nsim_plot_3 <-
  means_nsim %>% ggplot(aes(x = p1, y = p2, fill = regenerated_contrast)) + geom_tile() +
  facet_grid( ~ nsim, labeller = labeller(nsim = facet_labels_nsim)) + scale_fill_gradientn(limits = lims_means_nsim,
                                                                                            name="Regenerated Contrast",
                                                                                            colors =
                                                                                              brewer.pal(11, name = "RdYlBu")) + xlab("P(HIV|Contact and -PrEP)") + ylab("P(HIV|Contact and PrEP)")
nsim_plot_2 / nsim_plot_1 / nsim_plot_3

ggsave(
  plot = nsim_plot_2 / nsim_plot_1 / nsim_plot_3 + plot_annotation(title = "Contrast Estimate Mean by Resampling Size and Allocation \n with 20% PrEP vs. 40% PrEP coverage on N=20-node Networks") &
    theme(plot.title = element_text(hjust = 0.5)),
  device = "png",
  width = 13,
  height = 9,
  units = "in",
  file = "Resampling Size Mean Plot.png",
  path = "/restricted/projectnb/causal/Nico/plots/"
)

# Variances by Resampling Size --------------------------------------------

vars_nsim <-
  res_clean_nsim %>% group_by(nsim, p1, p2) %>% summarise(across(all_of(
    c(
      "random_contrast",
      "additive_contrast",
      "regenerated_contrast"
    )
  ), var), .groups = "keep") %>% ungroup()

lims_vars_nsim <- c(min(vars_nsim[, c("random_contrast",
                                      "additive_contrast",
                                      "regenerated_contrast")]), max(vars_nsim[, c("random_contrast",
                                                                                   "additive_contrast",
                                                                                   "regenerated_contrast")]))

# Plot Variances by Resampling Size ---------------------------------------

nsim_plot_4 <-
  vars_nsim %>% ggplot(aes(x = p1, y = p2, fill = random_contrast)) + geom_tile() +
  facet_grid( ~ nsim, labeller = labeller(nsim = facet_labels_nsim)) + scale_fill_gradientn(
    name = "Random Contrast",
    limits = lims_vars_nsim,
    colors =
      brewer.pal(11, name = "RdYlBu")
  ) + xlab("P(HIV|Contact and -PrEP)") + ylab("P(HIV|Contact and PrEP)")
nsim_plot_5 <-
  vars_nsim %>% ggplot(aes(x = p1, y = p2, fill = additive_contrast)) + geom_tile() +
  facet_grid( ~ nsim, labeller = labeller(nsim = facet_labels_nsim)) + scale_fill_gradientn(
    name = "Additive Contrast",
    limits = lims_vars_nsim,
    colors =
      brewer.pal(11, name = "RdYlBu")
  ) + xlab("P(HIV|Contact and -PrEP)") + ylab("P(HIV|Contact and PrEP)")
nsim_plot_6 <-
  vars_nsim %>% ggplot(aes(x = p1, y = p2, fill = regenerated_contrast)) + geom_tile() +
  facet_grid( ~ nsim, labeller = labeller(nsim = facet_labels_nsim)) + scale_fill_gradientn(
    name = "Regenerated Contrast",
    limits = lims_vars_nsim,
    colors = brewer.pal(11, name = "RdYlBu")
  ) + xlab("P(HIV|Contact and -PrEP)") + ylab("P(HIV|Contact and PrEP)")

nsim_plot_5 / nsim_plot_4 / nsim_plot_6
ggsave(
  plot = nsim_plot_5 / nsim_plot_4 / nsim_plot_6 + plot_annotation(title = "Contrast Estimate Variance by Resampling Size  and Allocation \n with 20% PrEP vs. 40% PrEP coverage on N=20-node Networks") &
    theme(plot.title = element_text(hjust = 0.5)),
  device = "png",
  width = 13,
  height = 9,
  units = "in",
  file = "Resampling Size Variance Plot.png",
  path = "/restricted/projectnb/causal/Nico/plots/"
)
