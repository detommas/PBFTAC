# function to get SPR for a given MP TAC output

get_spr_Fleets_TAC <- function(model, Fhcr, spawningseas= 4, extendages=15, Fleets.group=c(1,4,5,12,17,28)) {
  cols_pop <- as.character(0:(model$accuage))
  cols_plus <- as.character(0:(model$accuage+extendages))

  # maturity * fecundity for model with parametric growth
  matfec.vec2 <- model$endgrowth |>
    dplyr::filter(Sex == 1 & Seas == spawningseas) |> # values are the same across seasons, not sure why
    dplyr::pull("Mat*Fecund")
  
  matfec.vec2 <- c(matfec.vec2, rep(matfec.vec2[model$accuage+1],extendages))
  # calculate numbers at age with and without fishing based on 1 at age 0 in season 1
  N_at_age.M <- matrix(NA, nrow = 4, ncol = 1 + model$accuage + extendages)
  N_at_age.Z <- matrix(NA, nrow = 4, ncol = 1 + model$accuage + extendages)
  N_at_age.M[1, 1] <- 1
  N_at_age.Z[1, 1] <- 1

  # loop over ages
  for (iage in 1:(model$accuage + 1 + extendages)) {
    # loop over seasons
    for (iseas in 1:4) {
      # M at age for the given season (seems to be constant across years)
      if ("Yr" %in% names(model$Natural_Mortality)){
        M_at_age.y <- model$Natural_Mortality |>
          dplyr::filter(Yr == 1983 & Sex == 1 & Seas == iseas) |>
          dplyr::select(all_of(cols_pop)) |>
          as.numeric() 
      } else {
        M_at_age.y <- model$Natural_Mortality |>
          dplyr::filter(Sex == 1 & Seas == iseas) |>
          dplyr::select(all_of(cols_pop)) |>
          as.numeric() 
      }
        
      M_at_age.y.plus <- vctrs::vec_c(M_at_age.y, rep(M_at_age.y[model$accuage+1],extendages)) 
      
      # F at age for the given year/season
      Fmat <- Fhcr |>
        dplyr::filter(Sex == 1 & Seas == iseas & Fleet %in% Fleets.group) |>
        dplyr::group_by(Age) |>
        # aggregating F across fleets, change this to get fleet-specific SPR
        dplyr::summarize(Fa=sum(Fa))
        F_at_age.y=as.numeric(Fmat$Fa)

      F_at_age.y.plus <- vctrs::vec_c(F_at_age.y, rep(F_at_age.y[model$accuage+1],extendages)) 

      # Z at age is sum of M + F
      Z_at_age.y.plus <- F_at_age.y.plus + M_at_age.y.plus
      
      # apply M and Z to the numbers at age
      # for seasons 1-3 fill in the following season
      if (iseas < 4) {
        N_at_age.M[iseas + 1, iage] <- N_at_age.M[iseas, iage] * exp(-M_at_age.y.plus[iage] / 4)
        N_at_age.Z[iseas + 1, iage] <- N_at_age.Z[iseas, iage] * exp(-Z_at_age.y.plus[iage] / 4)
      }
      # for season 4, increment the age and fill in season 1
      if (iseas == 4 & iage <= (model$accuage+ extendages)) {
        N_at_age.M[1, iage + 1] <- N_at_age.M[iseas, iage] * exp(-M_at_age.y.plus[iage] / 4)
        N_at_age.Z[1, iage + 1] <- N_at_age.Z[iseas, iage] * exp(-Z_at_age.y.plus[iage] / 4)
      }
    }
  }

  # spawning potential is sum of numbers * maturity * fecundity
  spawn.potential.M <- sum(N_at_age.M[spawningseas, ] * matfec.vec2)
  spawn.potential.Z <- sum(N_at_age.Z[spawningseas, ] * matfec.vec2)
  SPR <- spawn.potential.Z / spawn.potential.M
  SPR_dat = list(SPR=SPR, SPz=spawn.potential.Z)
  return(SPR_dat)
}