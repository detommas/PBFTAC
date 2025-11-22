#' Calculates the TAC based on HCRs 1 to 7, 11, or 12 from the NC19 Attachment G
#' 
#' This HCR has the following specifications
#' F = Fmin if SSBcur<SSBlim
#' -management action occurs when either SSBcur<SSBthreshold or when SSBcur<SSBlim with a 50% probability
#' -allocation of the TAC is simply based on the relF specified in the forecast
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

#' @return A TAC by fleet segment in mt
#' @author Desiree Tommasi

HCR1_7_11_12_setnet <- function(ssout, dat, forf, yr, SSBtrs, SSBlim, Fmin, yrb,yrf,tacl,TACEdt,TACWldt,TACWsdt){

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
  if (SSBcur >= SSBtrs){
    Fm = fmult
  } else if (SSBcur > SSBlim) {
    Fm = ((fmult-(Fmin*fmult))/(SSBtrs-SSBlim))*(SSBcur-SSBlim)+Fmin*fmult
  } else {
    Fm=Fmin*fmult
  }
  
  #Calculate the total TAC given the current numbers at age, fmultiplier and biology and exploitation pattern 
  cage = catch_calc_f(ssout=ssout,yearsb=yrb,yearsf=yrf,ben=forf,fmult=fmult,ffraction=(Fm/fmult))
  
  #add a fleet type factor
  cage2 = cage %>%
    mutate(Size = case_when(
      Age %in% c(0:2) ~ "small",
      Age %in% c(3:20) ~ "Large"))

  #Calculate the potential TAC by fleet segment if no limit on TAC change
  ChcrWs = sum(cage2$yield[cage2$Fleet %in% c(8:10,12:15)])+sum(cage2$yield[cage2$Fleet %in% c(11,16:19)&cage2$Size=="small"])
  ChcrWl = sum(cage2$yield[cage2$Fleet %in% c(1:7)])+sum(cage2$yield[cage2$Fleet %in% c(11,16:19)&cage2$Size=="Large"])
  ChcrE = sum(cage2$yield[cage2$Fleet %in% c(20:23)])
  
  #compute the potential change in TAC by fleet segment
  CchangeWs = (ChcrWs-CcurWs)/CcurWs
  CchangeWl = (ChcrWl-CcurWl)/CcurWl
  CchangeE = (ChcrE-CcurE)/CcurE

  #Calculates the TAC by fleet and age if the HCR determined TAC has a change greater than tacl
  #For WCPO small fish
  if (tacl>0){
  if (abs(CchangeWs) > (tacl/100) & CchangeWs > 0){
    TACWs = CcurWs*(1+tacl/100)
  } else if (abs(CchangeWs) > (tacl/100) & CchangeWs < 0){
    TACWs = CcurWs*(1-tacl/100)
  } else {
    TACWs = ChcrWs
  }
    
  #do for WCPO large fish
  if (abs(CchangeWl) > (tacl/100) & CchangeWl > 0){
    TACWl = CcurWl*(1+tacl/100)
  } else if (abs(CchangeWl) > (tacl/100) & CchangeWl < 0){
    TACWl = CcurWl*(1-tacl/100)
  } else {
    TACWl = ChcrWl
  }
  
  #do for EPO
  if (abs(CchangeE) > (tacl/100) & CchangeE > 0){
    TACE = CcurE*(1+tacl/100)
   } else if (abs(CchangeE) > (tacl/100) & CchangeE < 0){
    TACE = CcurE*(1-tacl/100)
  } else {
    TACE = ChcrE
  }
 #doesn't apply TAC limit change if current biomass is less than the limit
  if (SSBlim > SSBcur){
    TACWs = ChcrWs
    TACWl = ChcrWl
    TACE = ChcrE
  }
  } else{
    TACWs = ChcrWs
    TACWl = ChcrWl
    TACE = ChcrE
  }
  

  TAC_dat = list(TACWs=TACWs, TACWl=TACWl, TACE=TACE)
  
  return(TAC_dat)
}