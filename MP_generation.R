#generates the TAC for the MP from a specified HCR given stock assessment output
#NOTE the stock assessment has to be run with the forecast file set to the Ftarget 
#of the HCR the MP is being computed for

#' @author D.Tommasi 11/12/2025

#load needed packages
library(r4ss)
library(tidyverse)
library(reshape2)

#get working directory
dir <- getwd()
#set working directory to where all functions needed are stored
setwd(paste0(dir,"/Rfuns"))

#source all the functions
file.sources = list.files()
sapply(file.sources,source,.GlobalEnv)

#load the specifications of the candidate HCRs (includes the new JWG propoal from March 2026)
hcrs=read.csv(paste0(dir,"/HCR_specs.csv"))

#vector of hcrs to compute TAC under the specified impact and EM to generate 2015-2022 baseline
hcrv=c(1:8,17)
#select EPO impact
#for HCRs 1 to 8, 17 select epoi 20
#for HCRs 9 to 16, 18 select epoi 30 - but note here still labeled as HCRs 1 to 8, 17 as HCRs are the same, only the RelF changes
epoi=30
#select the EM used to generate the baseline 2015-2022 relative F 
# use "newEM/" for the EM updated with new data (now up to FY2023)
# use "MSEEM/" for the EM ending in FY2022 (end of MSE conditioning period)
em="newEM/"

#data frame where to store the output TAC for each HCR
TACout = data.frame(hcr =hcrv, Ws=rep(NaN,9), Wl=rep(NaN,9), EPO=rep(NaN,9), impact=rep(epoi,9))

#loop to compute TAC by HCR
#Once he JWG will select an MP the code can be modified to just be run for that
#MP and associated HCR
#Now all the HCRs are run
#Therefore, the directory of the EM (i.e. ASPM-R+ model) to be used
#changes for each HCR, as it is in the forecast file of the EM that the Ftarget is specified
#HCRs with the same Ftarget and impact share the same stock assessment model
#this current code uses the ASPM-R+ model based on a full dynamics model updated with
#available fishing year 2023 data. Only catch and adult index data was available
#no size compositions were updated
#If this code would have to be used for another management period, the path would
#have to be updated to a new EM updated with new data

for (h in (1:length(hcrv))){
  #link hcr to EM, note EM is the same for HCRs with the same Ftarget
  if (h %in% c(1,2,4,8)){hcr=1} else if (h==9) {hcr=17} else if (h==3) {hcr=3} else if (h %in% c(5,7)) {hcr=5} else {hcr=6}
  #Specify directory with EM output
  samdir = paste0(dir,"/RelF_",em,"hcr",hcr,epoi)
  
  #read EM output file
  samout = SS_output(samdir, covar = FALSE)
  
  #read forecast report file output from the EM
  for_file_in = paste(samdir, "/Forecast-report.SSO", sep = "")
  for_rep = readLines(for_file_in, warn = FALSE)
  
  #read end year of EM
  yr_end = samout$endyr
  
  #Extract SPR series data
  SPRmat = samout$sprseries
  
  #Generate TAC based on the harvest control rule
  #an input is to specify years over which to compute biology (yrb) and exploitation pattern (yrf)
  #make sure they match what is the EM forecast file
  if (h %in% c(1:4,8,9)){
    
    #Compute the SSB associated with the threshold and limit biomass reference points for the specified hcr
    ssb_thr = brp_fun_pbf(ssoutput=samout, fraction=hcrs$Bthr[h])
    ssb_lim = brp_fun_pbf(ssoutput=samout, fraction=hcrs$LRP[h])
    
    TAC_mat = HCR1_7_11_12(ssout=samout, dat = SPRmat, forf=for_rep, yr=yr_end, SSBtrs=ssb_thr, SSBlim=ssb_lim, Fmin=hcrs$Fmin[hcr],yrb=c(2002:2004),yrf=c(2015:2022),tacl=25, TACEdt=7581,TACWldt=11869,TACWsdt=5125)
    
  } else if (h==5){
    
    #Compute the SSB associated with the threshold reference points for the specified hcr
    ssb_thr = brp_fun_pbf(ssoutput=samout, fraction=hcrs$Bthr[h])
    
    TAC_mat = HCR8(ssout=samout, dat = SPRmat, forf=for_rep, yr=yr_end, SSBtrs=ssb_thr, yrb=c(2002:2004),yrf=c(2015:2022),tacl=25, TACEdt=7581,TACWldt=11869,TACWsdt=5125)
    
  } else {
    
    #Compute the SSB associated with the threshold reference points for the specified hcr
    ssb_thr = brp_fun_pbf(ssoutput=samout, fraction=hcrs$Bthr[h])
    
    TAC_mat = HCR9_10(ssout=samout, dat = SPRmat, forf=for_rep, yr=yr_end, SSBtrs=ssb_thr,yrb=c(2002:2004),yrf=c(2015:2022),tacl=25, TACEdt=7581,TACWldt=11869,TACWsdt=5125)
  }
  
  TACout$Ws[h]=round(TAC_mat$TACWs)
  TACout$Wl[h]=round(TAC_mat$TACWl)
  TACout$EPO[h]=round(TAC_mat$TACE)
}