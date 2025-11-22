#generates the TAC for the MP from a specified HCR given stock assessment output
#NOTE the stock assessment has to be run with the forecast file set to the Ftarget 
#of the HCR the MP is being computed for

#' @author D.Tommasi 11/12/2025

#load needed packages
library(r4ss)
library(tidyverse)
library(reshape2)

#set working directory to where all functions needed are stored
setwd("C:/Users/desiree.tommasi/Documents/Bluefin/MP_dev/Rfuns")

#source all the functions
file.sources = list.files()
sapply(file.sources,source,.GlobalEnv)

#load the specifications of the candidate HCRs
hcrs=read.csv("C:/Users/desiree.tommasi/Documents/Bluefin/MP_dev/HCR_specs.csv",sep="\t")

#vector of hcrs to compute TAC under the specified impact and EM to generate 2015-2022 baseline
hcrv=c(1:8)
#select EPO impact
#for HCRs 1 to 8 select epoi 20
#for HCRs 9 to 16 select epoi 30 - but note here still labeled as HCRs 1 to 8 as HCRs are the same, only the RelF changes
epoi=20
#select the EM used to generate the baseline 2015-2022 relative F 
# use "newEM/" for the EM updated with new data (i.e. stock assessment)
# use "MSEEM/" for the EM ending in 2022 (end of MSE conditioning period)
em="newEM/"

#data frame where to store the output
TACout = data.frame(hcr =1:8, Ws=rep(NaN,8), Wl=rep(NaN,8), EPO=rep(NaN,8), impact=rep(epoi,8))

#loop to compute TAC by HCR
#Once he JWG will select an MP the code can be modified to just be run for that
#MP and associated HCR
#Now all the HCRs are run
#Therefore, the directory of the stock assessment (ASPM-R+ model) to be used
#changes for each HCR
#HCRs with the same Ftarget and impact share the same stock assessment model
#this current code uses the ASPM-R+ model based on a full dynamics model updated with
#available fishing year 2023 data. Only catch and adult index data was available
#no size compositions were updated
#If this code would have to be used for another 3-yr TAC period, the path would
#have to be updated to a new assessment

for (h in hcrv){
  #specify hcr with model, note it is the same for each Ftarget
  if (h %in% c(1,2,4,8)){hcr=1} else if (h==3) {hcr=3} else if (h %in% c(5,7)) {hcr=5} else {hcr=6}
  #Specify directory with stock assessment output
  samdir = paste0("C:/Users/desiree.tommasi/Documents/Bluefin/MP_dev/RelF_",em,"hcr",hcr,epoi)
  
  #read stock assessment output file
  samout = SS_output(samdir, covar = FALSE)
  
  #read forecast report file output from stock assessment
  for_file_in = paste(samdir, "/Forecast-report.SSO", sep = "")
  for_rep = readLines(for_file_in, warn = FALSE)
  
  #read end year of assessment model
  yr_end = samout$endyr
  
  #Extract SPR series data
  SPRmat = samout$sprseries
  
  #Generate TAC based on the harvest control rule
  #an input is to specify years over which to compute biology (yrb) and exploitation pattern (yrf)
  #make sure they match what is the assessment forecast file
  if (h %in% c(1:4,8)){
    
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