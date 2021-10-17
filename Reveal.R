seed_raw <- $ChainLinkRandomSeedHere

set.seed(as.numeric(substr(seed_raw,1,10)))

df <- read.csv("Raptor-Giveaway-Final-Entrants.csv",header = F)

df$rand <- runif(nrow(df),0,1)

df[order(df$rand),"V1"][1]
