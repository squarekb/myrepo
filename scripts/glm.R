library(tidyverse)
library(performance)
library(dplyr)
library(dotwhisker)
library(broom)
library(effects)

#Hypothesis: do chemical or physical variables produce a better model for occupancy?

edna <- (read_csv("data/edna.csv",  col_types=cols())
        %>% mutate(occupancy = as.factor(occ))
        %>% mutate(diff = air_temp - water_temp)
  )

#glm, occupancy is a bernoulli response variable so I am using a logit link function

glmchem <-glm(occupancy~pH+salinity+do+turbidity+cond+tds, data = edna, family = binomial)
glmphys <-glm(occupancy~day+size+diff+canopy_pct, data = edna, family = binomial)
glmall <-glm(occupancy ~ pH+salinity+do+turbidity+cond+tds+day+size+diff+canopy_pct, data = edna, family = binomial)

## JD: This seems like the most interesting take-home:
summary(glmall)

#diagnostics
check_model(glmchem)
check_model(glmphys)
check_model(glmall)

## My residuals are outside error bounds for one point in glmchem, otherwise all models are ok

#inference test, which model is a better predictor of occupancy
anova(glmchem,glmphys,glmall)

#according to this anova, model 1 or the chemical model is the best predictor of occupancy

## JD: Not really. You could test which one is the best _predictor_ with cross-validation or with information criteria. anova() is aimed at inference: in my interpretation, are we convinced we've seen a clear effect? It's more about parameters than about prediction.

#Interpreting logit coefficients: for a one unit change in our coefficients, the odds for the presence of Blanding's turtles is changes by x. As tds increases by one unit, probaility of detection increases by (6.668-1.00)*100 = 566%. Salinity = 399%. Size = 85%. pH, dissolved oxygen, conductivity, day and temperature difference all increase odds of detection slightly. Increases in canopy_pct decrease the odds of detecting Blanding's Turtle slightly.
exp(glmall$coefficient[2:11])


#how much of the variance is explained by the "glmall" model? (I know this was not the best according to ANOVA, jut messing around)

# calculate the pseudo-R2
pseudoR2 <- (glmall$null.deviance - glmall$deviance) / glmall$null.deviance
pseudoR2
#6% of the variance in occupancy is explained by this model, that's awful. Good thing these are poorly simulated data!

## Grade 2/3
