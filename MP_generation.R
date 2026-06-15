#generates the TAC for the MP from a specified HCR given stock assessment output
#NOTE the stock assessment has to be run with the forecast file set to the Ftarget 
#of the HCR the MP is being computed for

#' @author D.Tommasi 11/12/2025, updated 3/19/2026

#load needed packages
library(r4ss)
library(tidyverse)
library(reshape2)

#set main directory
mdir <- getwd()
#set working directory to where all functions needed are stored
setwd(paste0(mdir,"/Rfuns"))

#source all the functions
file.sources = list.files()
sapply(file.sources,source,.GlobalEnv)

#load the specifications of the candidate HCRs
hcrs=read.csv(paste0(mdir,"/HCR_specs.csv"))

#vector of hcrs to compute TAC under the specified impact and EM to generate 2015-2022 baseline
#note here we use HCRs 1 to 8 also for HCRs 9 to 16 as they are same, only the RelF changes
#the RelF to use is specified in the line below as th epoi (EPO impact)
#hcr 17 i the Newport HCR
hcrv=c(1:8,17)
#select EPO impact
epoi=22
#select the EM used to generate the baseline 2015-2022 relative F 
# use "newEM/" for the latest EM updated with new data (i.e. stock assessment)
#the newEM uses the ASPM-R+ EM based on a full dynamics model updated with
#available fishing year 2023 data. Only catch and adult index data was available
#no size compositions were updated
#when using this code 2 yer from now to compute a new TAC, the path would
#have to be updated to a new EM 
#use "MSEEM/" for the EM ending in 2022 (end of MSE conditioning period)
em="newEM/"

#specify what the TAC from the previous time period was as TAC cannot changemore than 25% from previous
#since this is the first MP TAC compare to current change limits
#for the WCPO use CMM-2024-01 https://cmm.wcpfc.int/measure/cmm-2024-01
#WCPO large fish previous TAC
TACWl1 = 11869
#WCPO small fish previous TAC
TACWs1 = 5125
#for the EPO use the one-year maximum of IATTC’s Resolution C-24-02
#https://www.iattc.org/GetAttachment/b02f2675-e880-40a0-bc9b-dabda92adaad/C-24-02_Bluefin-tuna.pdf
TACE1 = 7581

#data frame where to store the output
TACout = data.frame(hcr =hcrv, Ws=rep(NaN,9), Wl=rep(NaN,9), EPO=rep(NaN,9), impact=rep(epoi,9))

#loop to compute TAC by HCR
#Once he JWG will select an MP the code can be modified to just be run for that
#MP and associated HCR
#Now all the HCRs are run
#Therefore, the directory of the stock assessment (ASPM-R+ model) to be used
#changes for each HCR
#HCRs with the same Ftarget and impact share the same EM forecast file and associated EM output

for (h in (1:length(hcrv))){
  #the hcr here specifies which forecast and associated EM file to use, note it is the same for each Ftarget
  if (h %in% c(1,2,4,8)){hcr=1} else if (h==9) {hcr=17} else if (h==3) {hcr=3} else if (h %in% c(5,7)) {hcr=5} else {hcr=6}
  #Specify directory with EM output
  samdir = paste0(mdir,"/RelF_",em,"hcr",hcr,epoi)
  
  #read EM output file
  samout = SS_output(samdir, covar = FALSE)
  
  #read forecast report file output from EM
  for_file_in = paste(samdir, "/Forecast-report.SSO", sep = "")
  for_rep = readLines(for_file_in, warn = FALSE)
  
  #read end year of EM
  yr_end = samout$endyr
  
  #Extract SPR series data
  SPRmat = samout$sprseries
  
  #Generate TAC based on the harvest control rule
  #an input is to specify years over which to compute biology (yrb) and exploitation pattern (yrf)
  #make sure they match what is in the EM forecast file
  if (h %in% c(1:4,8,9)){
    
    #Compute the SSB associated with the threshold and limit biomass reference points for the specified hcr
    ssb_thr = brp_fun_pbf(ssoutput=samout, fraction=hcrs$Bthr[h])
    ssb_lim = brp_fun_pbf(ssoutput=samout, fraction=hcrs$LRP[h])
    
    
    TAC_mat = HCR1_7_11_12(ssout=samout, dat = SPRmat, forf=for_rep, yr=yr_end, SSBtrs=ssb_thr, SSBlim=ssb_lim, Fmin=hcrs$Fmin[hcr],yrb=c(2002:2004),yrf=c(2015:2022),tacl=25, TACEdt=TACE1,TACWldt=TACWl1,TACWsdt=TACWs1)
    
  } else if (h==5){
    
    #Compute the SSB associated with the threshold reference points for the specified hcr
    ssb_thr = brp_fun_pbf(ssoutput=samout, fraction=hcrs$Bthr[h])
    
    TAC_mat = HCR8(ssout=samout, dat = SPRmat, forf=for_rep, yr=yr_end, SSBtrs=ssb_thr, yrb=c(2002:2004),yrf=c(2015:2022),tacl=25, TACEdt=TACE1,TACWldt=TACWl1,TACWsdt=TACWs1)
    
  } else {
    
    #Compute the SSB associated with the threshold reference points for the specified hcr
    ssb_thr = brp_fun_pbf(ssoutput=samout, fraction=hcrs$Bthr[h])
    
    TAC_mat = HCR9_10(ssout=samout, dat = SPRmat, forf=for_rep, yr=yr_end, SSBtrs=ssb_thr,yrb=c(2002:2004),yrf=c(2015:2022),tacl=25, TACEdt=TACE1,TACWldt=TACWl1,TACWsdt=TACWs1)
  }
  
  TACout$Ws[h]=round(TAC_mat$TACWs)
  TACout$Wl[h]=round(TAC_mat$TACWl)
  TACout$EPO[h]=round(TAC_mat$TACE)
}

TACout