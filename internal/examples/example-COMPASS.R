library(COMPASS)

## source Lynn's code to get y_s, y_u, cd4_counts, meta
# setwd("refactor")
# ## source first part of master4model_cpp.R
CC <- COMPASSContainer(
  data=res,
  counts=cd4_counts,
  meta=meta,
  stim="Stim",
  sample="name",
  indiv="PTID"
)

# saveRDS(CC, file="COMPASS.rds")
# setwd("../")

## flowWorkspaceToSingleCell?

## speeding things up -- almost all of the time is spent in .Call, so we have
## to dive into the C++ code if we want to make a difference...

CC <- readRDS("refactor/COMPASS.rds")

## Aggregate samples?

## debug
data <- CC
treatment <- quote(Stim == "92TH023 Env")
control <- quote(Stim == "negctrl 1")
model <- "discrete"
verbose <- TRUE

## An example call
set.seed(123)
system.time(discrete1 <- COMPASS(
  data=CC,
  treatment=Stim == "92TH023 Env",
  control=Stim == "negctrl 1",
  model="discrete",
  iterations=1E2,
  replications=4
))

set.seed(123)
discrete2 <- COMPASS(
  data=CC,
  treatment="92TH023 Env",
  control="negctrl 1",
  model="continuous",
  iterations=10,
  replications=8
)

stopifnot( identical(discrete1, discrete2) )

saveRDS(discrete, file="data/RV144_CD4_results_discrete.rds")
discrete <- readRDS("data/RV144_CD4_results_discrete.rds")
plot(discrete, "vaccine")
FunctionalityScore(discrete)
PolyfunctionalityScore(discrete)
plot(PolyfunctionalityScore(discrete) ~ FunctionalityScore(discrete))

## test unpaired sample removal
CC_sub <- CC
CC_sub$data <- CC_sub$data[1:520]
data <- CC_sub
discrete <- COMPASS(
  data=CC_sub,
  treatment=Stim == "92TH023 Env",
  control=Stim == "negctrl 1",
  model="discrete",
  iterations=10
)

continuous <- COMPASS(
  data=CC,
  treatment=Stim == "92TH023 Env",
  control=Stim == "negctrl 1",
  model="continuous",
  iterations=10
)

FunctionalityScore(continuous)
PolyfunctionalityScore(continuous)
plot( FunctionalityScore(continuous) ~ PolyfunctionalityScore(continuous) )
