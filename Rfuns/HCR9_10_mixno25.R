#' Calculates the TAC based on HCRs 9 or 10 from the NC19 Attachment G
#' 
#' This HCR has the following specifications
#' -management action occurs when either SSBcur<SSBthreshold with a 50% probability
#' -allocation of the TAC is simply based on the specified relF in the control file
#' -TAC is generated for EPO (including recreational), WCPO large, and WCPO small fish
#' 
#' @param ssout SS output file
#' @param dat specifies the data frame which contains the sprseries data extracted from the stock assessment output
#' @param forf specifies the the forecast report file from which the Fmult will be extracted
#' @param yr specifies the year for which to extract the current total biomass
#' @param SSBtrs the threshold biomass reference point
#' @param Fmin specifies the fraction of Ftarget that the minimum F is set to once the LRP is reached
#' @param yrb specifies the years biological parameters are averaged over in the forecast file - needs to match what is in the assessment forecast file
#' @param yrf specifies the years relF and selectivity parameters are averaged over in the forecast file - needs to match what is in the assessment forecast file
#' @param tacl specifies limit on TAC change relative to previous period in % 
#' @param TACEdt specifies EPO TAC from previous management period
#' @param TACWldt specifies WCPO large fish TAC from previous management period
#' @param TACWsdt specifies WCPO small fish TAC from previous management period

#' @return A TAC by fleet segment in mt
#' @author Desiree Tommasi

HCR9_10_mixno25 <- function(ssout, dat, forf, yr, SSBtrs, yrb,yrf,tacl,TACEdt,TACWldt,TACWsdt){

  #extract the current SSB, the spawning stock biomass in the terminal year of the stock assessment
  SSBcur = dat[(dat$Yr==yr),]$SSB
  
  #Read in TAC from previous management period
  CcurWs = TACWsdt
  CcurWl = TACWldt
  CcurE = TACEdt
  
  #extract the F multiplier
  pattern = "Forecast_using_Fspr:"
  which.line = grep(pattern=pattern, x=forf)
  fmdat=forf[which.line]
  fmdat2 = unlist(strsplit(fmdat, split= " "))
  fmult = as.numeric(fmdat2[4])
  
  #Scale the fmult given the HCR and stock status
  if (SSBcur > SSBtrs){
    Fm = fmult
  } else {
    Fm = (fmult/SSBtrs)*SSBcur
  } 
  
  #Calculate the total TAC given the current numbers at age, fmultiplier and biology and exploitation pattern 
  cage = catch_calc_f(ssout=ssout,yearsb=yrb,yearsf=yrf,ben=forf,fmult=fmult, ffraction=Fm/fmult)
  
  #add a fleet type factor
  cage2 = cage %>%
    mutate(Size = case_when(
      Age %in% c(0:2) ~ "small",
      Age %in% c(3:20) ~ "Large"))
  
  #Calculate the potential TAC by fleet segment if no limit on TAC change
  #Calculate the potential TAC by fleet segment if no limit on TAC change
  TACWs = sum(cage2$yield[cage2$Fleet %in% c(8:10,12:15)])
  TACWm = sum(cage2$yield[cage2$Fleet %in% c(11,16:19)])
  TACWl = sum(cage2$yield[cage2$Fleet %in% c(1:7)])
  TACE = sum(cage2$yield[cage2$Fleet %in% c(20:23)])
  
  #calculate the SPR and spawning potential by fleet
  SPRWs = get_spr_Fleets_TAC(model=ssout, Fhcr=cage, spawningseas= 4, extendages=20, Fleets.group=c(8:10,12:15))
  SPRWm = get_spr_Fleets_TAC(model=ssout, Fhcr=cage, spawningseas= 4, extendages=20, Fleets.group=c(11,16:19))
  SPRWl = get_spr_Fleets_TAC(model=ssout, Fhcr=cage, spawningseas= 4, extendages=20, Fleets.group=c(1:7))
  SPRE = get_spr_Fleets_TAC(model=ssout, Fhcr=cage, spawningseas= 4, extendages=20, Fleets.group=c(20:23))
  SPRD = get_spr_Fleets_TAC(model=ssout, Fhcr=cage, spawningseas= 4, extendages=20, Fleets.group=c(24:26))
  
  TAC_dat = list(TACWs=TACWs, TACWm=TACWm, TACWl=TACWl, TACE=TACE,SPRWs=SPRWs,SPRWm=SPRWm,SPRWl=SPRWl,SPRE=SPRE,SPRD=SPRD)
  
  return(TAC_dat)
}