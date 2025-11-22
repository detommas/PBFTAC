#V3.30.14.06-trans;_2019_10_15;_Stock_Synthesis_by_Richard_Methot_(NOAA)_using_ADMB_12.0
#Stock Synthesis (SS) is a work of the U.S. Government and is not subject to copyright protection in the United States.
#Foreign copyrights may apply. See copyright.txt for more information.
# for all year entries except rebuilder; enter either: actual year, -999 for styr, 0 for endyr, neg number for rel. endyr
1 # Benchmarks: 0=skip; 1=calc F_spr,F_btgt,F_msy; 2=calc F_spr,F0.1,F_msy 
2 # MSY: 1= set to F(SPR); 2=calc F(MSY); 3=set to F(Btgt) or F0.1; 4=set to F(endyr) 
0.25 # SPR target (e.g. 0.40)
0.25 # Biomass target (e.g. 0.40)
#_Bmark_years: beg_bio, end_bio, beg_selex, end_selex, beg_relF, end_relF, beg_recr_dist, end_recr_dist, beg_SRparm, end_SRparm (enter actual year, or values of 0 or -integer to be rel. endyr)
 2002 2004 2015 2022 2015 2022 1983 2022 1983 2022
2 #Bmark_relF_Basis: 1 = use year range; 2 = set relF same as forecast below
#
1 # Forecast: 0=none; 1=F(SPR); 2=F(MSY) 3=F(Btgt) or F0.1; 4=Ave F (uses first-last relF yrs); 5=input annual F scalar
1 # N forecast years 
0 # F scalar (only used for Do_Forecast==5)
#_Fcast_years:  beg_selex, end_selex, beg_relF, end_relF, beg_mean recruits, end_recruits  (enter actual year, or values of 0 or -integer to be rel. endyr)
 2015 2022 2015 2022 1983 2022
0 # Forecast selectivity (0=fcast selex is mean from year range; 1=fcast selectivity from annual time-vary parms)
0 # Control rule method (1: ramp does catch=f(SSB), buffer on F; 2: ramp does F=f(SSB), buffer on F; 3: ramp does catch=f(SSB), buffer on catch; 4: ramp does F=f(SSB), buffer on catch) 
0.05 # Control rule Biomass level for constant F (as frac of Bzero, e.g. 0.40); (Must be > the no F level below) 
0.01 # Control rule Biomass level for no F (as frac of Bzero, e.g. 0.10) 
1 # Buffer:  enter Control rule target as fraction of Flimit (e.g. 0.75), negative value invokes list of [year, scalar] with filling from year to YrMax 
3 #_N forecast loops (1=OFL only; 2=ABC; 3=get F from forecast ABC catch with allocations applied)
3 #_First forecast loop with stochastic recruitment
0 #_Forecast recruitment:  0= spawn_recr; 1=value*spawn_recr_fxn; 2=value*VirginRecr; 3=recent mean from yr range above (need to set phase to -1 in control to get constant recruitment in MCMC)
1 # value is ignored 
0 #_Forecast loop control #5 (reserved for future bells&whistles) 
2023  #FirstYear for caps and allocations (should be after years with fixed inputs) 
0 # stddev of log(realized catch/target catch) in forecast (set value>0.0 to cause active impl_error)
0 # Do West Coast gfish rebuilder output (0/1) 
2022 # Rebuilder:  first year catch could have been set to zero (Ydecl)(-1 to set to 1999)
-1 # Rebuilder:  year for current age structure (Yinit) (-1 to set to endyear+1)
2 # fleet relative F:  1=use first-last alloc year; 2=read seas, fleet, alloc list below
# Note that fleet allocation is used directly as average F if Do_Forecast=4 
2 # basis for fcast catch tuning and for fcast catch caps and allocation  (2=deadbio; 3=retainbio; 5=deadnum; 6=retainnum); NOTE: same units for all fleets
# Conditional input if relative F choice = 2
# enter list of:  season,  fleet, relF; if used, terminate with season=-9999
1	1	0
2	1	0
3	1	0
4	1	0.002620649
1	2	0.000361767
2	2	0.000523505
3	2	0.001038036
4	2	0.002228174
1	3	0.00133332
2	3	8.65302E-05
3	3	0.000468232
4	3	0.03346437
1	4	7.77321E-05
2	4	0
3	4	0
4	4	0.033624898
1	5	0
2	5	0
3	5	0
4	5	0.064529659
1	6	0.11563209
2	6	0
3	6	0
4	6	0
1	7	0.001018942
2	7	0
3	7	0
4	7	0.00360569
1	8	0.060803015
2	8	0
3	8	0.009034859
4	8	0.025156732
1	9	0
2	9	0.058938251
3	9	0
4	9	0
1	10	0.027303582
2	10	0
3	10	0
4	10	0.212684437
1	11	0.000303809
2	11	0.000280959
3	11	0.006708945
4	11	0.000781963
1	12	0
2	12	0.038871627
3	12	0.029684713
4	12	0.010099114
1	13	0.012360547
2	13	0
3	13	0
4	13	0
1	14	0.011835902
2	14	0
3	14	0
4	14	0
1	15	0.002090014
2	15	0.001737216
3	15	0.002759887
4	15	0.002710436
1	16	0.004685449
2	16	0.003857447
3	16	0.01154312
4	16	0
1	17	0
2	17	0
3	17	0
4	17	0.002783399
1	18	0.003489824
2	18	0.001534305
3	18	5.62913E-06
4	18	0.002171543
1	19	0
2	19	0.012804556
3	19	0
4	19	0
1	20	0
2	20	0
3	20	0
4	20	0
1	21	0.006931247
2	21	0.000629899
3	21	0.041763059
4	21	0.056349318
1	22	0.016772509
2	22	0.003823081
3	22	0.000111576
4	22	0.008880203
1	23	0
2	23	0
3	23	0
4	23	0
1	24	3.92903E-05
2	24	0.003589275
3	24	0.002595872
4	24	0.000481754
1	25	0.037117168
2	25	0
3	25	0
4	25	0.002865998
1	26	0.000273371
2	26	3.42332E-05
3	26	4.92846E-07
4	26	0.000106282
-9999	0	0 # terminator for list of relF
# enter list of: fleet number, max annual catch for fleets with a max; terminate with fleet=-9999
-9999 -1
# enter list of area ID and max annual catch; terminate with area=-9999
-9999 -1
# enter list of fleet number and allocation group assignment, if any; terminate with fleet=-9999
-9999 -1
#_if N allocation groups >0, list year, allocation fraction for each group 
# list sequentially because read values fill to end of N forecast
# terminate with -9999 in year field 
# no allocation groups
2 # basis for input Fcast catch: -1=read basis with each obs; 2=dead catch; 3=retained catch; 99=input Hrate(F); NOTE: bio vs num based on fleet's catchunits
#enter list of Fcast catches; terminate with line having year=-9999
#_Yr Seas Fleet Catch(or_F)
-9999 1 1 0 
#
999 # verify end of input 
