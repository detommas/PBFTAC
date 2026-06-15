#Generates a new forecast file to calculate a new MP TAC given a specified new fisheries impact ratio
#Author: D. Tommasi
library(r4ss)
library(tidyverse)

#We use the method outlined in the working paper Tommasi and Lee 2024 
#https://isc.fra.go.jp/pdf/PBF/ISC24_PBF_1/2024_ISC_PBFWG-1_10.pdf
#as applied to find the new apical relative F and forecast file used for HCRs 9 to 16 in the PBF MSE
#as described in the PBF MSE report section 4.2.5 
#https://isc.fra.go.jp/pdf/ISC25/ISC25ANNEX08PBFMSEfinalreport_ERRATUM.pdf

#set main directory
mdir <- getwd()

#Specify the epo impact 
epoid<-22

#use the empirical relationship fromth documents above between epo impact and the increase in EPO apical F from the 2015-2022 baseline apical F 
#to find the increase in EPO relf that will give the specified EPO impact
seekf <- function(relfi) {1.75958921*relfi-0.01791156*(relfi^2)+19.33861-epoid}
rlfSearch<-uniroot(seekf,c(0.1,10))
#the relationship gives the change in rel F if the relF was in %
#However,in the forecast it's a fraction, with a total of 1, so change in same unit as forecast file relF
eporelf_increase <- round(rlfSearch$root/100, digits=3)

#reverse function to find the epoi given a change in epo relF
#epoiFun <- function(relfi){1.75958921*relfi-0.01791156*(relfi^2)+19.33861} 
#epoiFun(rlfSearch$root)

#extract the baseline relF from the forecast report file of the baseline EM
#make sure the baseline EM was run with the forecast relF/sel set to 2015-2022
emdir = paste0(mdir,"/PBF_SS_2025_BC_ASPMR_0.20_share")

#read EM output file
emout = SS_output(emdir, covar = FALSE, forecast=TRUE)

#read forecast report file output from EM
for_file_in = paste(emdir, "/Forecast-report.SSO", sep = "")
for_rep = readLines(for_file_in, warn = FALSE)

#extract the baseline 2015-2022 relF for each season
pattern = "Bmark_relF(by_fleet_&seas) (excluding non-scaled bycatch fleets)"
which.line = grep(pattern=pattern, x=for_rep,fixed = TRUE)

#extract the relative F for each season
#note the relF also includes the survey fleets (all with 0 relF), just keep the fisheries
relfs1=for_rep[which.line+1][[1]]
relfs1 = gsub("^\\s+|\\s+$", "", relfs1) # remove leading blank
relfs1 = as.numeric(unlist(strsplit(relfs1, split= " ")))[1:26]

relfs2=for_rep[which.line+2][[1]]
relfs2 = gsub("^\\s+|\\s+$", "", relfs2) # remove leading blank
relfs2 = as.numeric(unlist(strsplit(relfs2, split= " ")))[1:26]

relfs3=for_rep[which.line+3][[1]]
relfs3 = gsub("^\\s+|\\s+$", "", relfs3) # remove leading blank
relfs3 = as.numeric(unlist(strsplit(relfs3, split= " ")))[1:26]

relfs4=for_rep[which.line+4][[1]]
relfs4 = gsub("^\\s+|\\s+$", "", relfs4) # remove leading blank
relfs4 = as.numeric(unlist(strsplit(relfs4, split= " ")))[1:26]

#generate a table with the relFs by fleet
relf_mat <- data.frame(fleet=rep(1:26,4),seas=c(rep(1,26),rep(2,26),rep(3,26),rep(4,26)),Relf=c(relfs1, relfs2,relfs3, relfs4),Fseg=rep(c(rep("WCPO",19),rep("EPO",4),"WCPO","WCPO","EPO")))

#find the total relative F by fleet segment
relf_fseg <- relf_mat %>% group_by(Fseg) %>% summarize(RelFtot=sum(Relf))

#find the total relative F by fleet segment
relf_fseg <- relf_mat %>% group_by(Fseg) %>% summarize(RelFtot=sum(Relf))

#add it to the main data frame
relf_mat$Relfseg <-  ((relf_fseg %>% filter(Fseg=="WCPO"))$RelFtot)
relf_mat$Relfseg[which(relf_mat$Fseg=="EPO")] <- ((relf_fseg %>% filter(Fseg=="EPO"))$RelFtot)

#find the new total relF after the required change
relf_mat$RelfsegN <- relf_mat$Relfseg - eporelf_increase 
relf_mat$RelfsegN[which(relf_mat$Fseg=="EPO")] <- relf_mat$Relfseg[which(relf_mat$Fseg=="EPO")] + eporelf_increase

#find the new relF by fleet and season
#note it keeps the same share of relative F as the old
relf_mat$RelfN <- relf_mat$RelfsegN*(relf_mat$Relf/relf_mat$Relfseg)

#sort by fleet then by season to have the same format as the forecast file
relf_mat_sorted <- relf_mat %>% arrange(fleet, seas)

#We need to create an EM with a new forecast file for each Ftarget
#and then run it without estimation to get the forecast-Report file formatted for the TAC calculation
#we use the files for the 30 epo impact as a starting point

#the h here specifies which forecast and associated EM file to generate, note it is the same for each Ftarget
hvect <- c(1,3,5,6,17)
#specify the EM path, hr w use the latest updated EM
em="newEM/"

for (h in (1:length(hvect))){
  hcr <- hvect[h]
  em_30dir <- paste0(mdir,"/RelF_",em,"hcr",hcr,30)
  new_dir <- paste0(mdir,"/RelF_",em,"hcr",hcr,epoid)
  
  #create new folder
  dir.create(new_dir, recursive = TRUE)
  
  em30_files <- list.files(em_30dir, full.names = TRUE)
  
  #copy all the files into the new folder
  file.copy(
    from = em30_files,
    to = new_dir,
    recursive = TRUE,
    overwrite = TRUE
  )
  
  #modify forecast file with the new relf
  fcast_old <- SS_readforecast(file = paste0(em_30dir,"/forecast.ss"))
  fcast_old$vals_fleet_relative_f$`Relative F`<- relf_mat_sorted$RelfN
  
  #save the new forecast file
  SS_writeforecast(mylist = fcast_old,dir = new_dir, file = "forecast.ss", overwrite = TRUE)
  
  #re-run the EM with the new forecast file to get forecast-report needed to calculate the TAC
  r4ss::run(dir = new_dir,  exe = "ss", extras = "-maxfn 0 -phase 50 -nohess", skipfinished = FALSE)
}