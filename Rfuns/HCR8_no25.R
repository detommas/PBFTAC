#' Calculates the TAC based on HCR 8 from the NC19 Attachment G
#' 
#' This HCR has the following specifications
#' TAC = TAC min from WCPFC CMM2020-02 and IATTC Resolution C-18-01 if SSBcur<SSBlim
#' -management action occurs when either SSBcur<SSBthreshold or when SSBcur<SSBlim with a 50% probability
#' -allocation of the TAC is simply based on the relF specified in the forecast file
#' -TAC is generated for EPO (including recreational), WCPO large, and WCPO small fish
#' 
#' Here the exploitation rate is the ratio of the total catch in weight over the total biomass
#' @param ssout SS output file
#' @param dat specifies the data frame which contains the sprseries data extracted from the stock assessment output
#' @param forf specifies the the forecast report file from which the Fmult will be extracted
#' @param yr specifies the year for which to extract the current total biomass
#' @param SSBtrs the threshold biomass reference point
#' @param SSBlim the limit biomass reference point
#' @param Fmin specifies the fraction of Ftarget that the minimum F is set to once the LRP is reached
#' @param yrb specifies the years biological parameters are averaged over in the forecast file - needs to match what is in the assessment forecast file
#' @param yrf specifies the years relF and selectivity parameters are averaged over in the forecast file - needs to match what is in the assessment forecast file
#' @param tacl specifies limit on TAC change relative to previous period in % 
#' @param TACEdt specifies EPO TAC from previous management period
#' @param TACWldt specifies WCPO large fish TAC from previous management period
#' @param TACWsdt specifies WCPO small fish TAC from previous management period

#' @return A TAC by fleet segment in mt#' @author Desiree Tommasi

HCR8_no25 <- function(ssout, dat, forf, yr, SSBtrs, yrb,yrf,tacl,TACEdt,TACWldt,TACWsdt){

  #extract the current SSB, the spawning stock biomass in the terminal year of the stock assessment
  SSBcur = dat[(dat$Yr==yr),]$SSB
  
  SSBlim=40724.6 #median SSB from 1952-2014 
  
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
  if (SSBcur >= SSBtrs){
    Fm = fmult
    cage = catch_calc_f(ssout=ssout,yearsb=yrb,yearsf=yrf,ben=forf,fmult=fmult,ffraction=(Fm/fmult))
    
  #add a fleet type factor
  cage2 = cage %>%
    mutate(Size = case_when(
      Age %in% c(0:2) ~ "small",
      Age %in% c(3:20) ~ "Large"))
  
  #Calculate the potential TAC by fleet segment if no limit on TAC change
  TACWs = sum(cage2$yield[cage2$Fleet %in% c(8:10,12:16)])+sum(cage2$yield[cage2$Fleet %in% c(11,17:19)&cage2$Size=="small"])
  TACWl = sum(cage2$yield[cage2$Fleet %in% c(1:7)])+sum(cage2$yield[cage2$Fleet %in% c(11,17:19)&cage2$Size=="Large"])
  TACE = sum(cage2$yield[cage2$Fleet %in% c(20:23)])
  
  } else  {

 #when SSBtrs>SSB current TAC is set equal to CMM
    TACWs=4725
    TACWl=7609
    TACE=5472.761
  }
  
  TAC_dat = list(TACWs=TACWs, TACWl=TACWl, TACE=TACE)
  return(TAC_dat)
}