#V3.30.14.06-trans;_2019_10_15;_Stock_Synthesis_by_Richard_Methot_(NOAA)_using_ADMB_12.0
#Stock Synthesis (SS) is a work of the U.S. Government and is not subject to copyright protection in the United States.
#Foreign copyrights may apply. See copyright.txt for more information.
# for all year entries except rebuilder; enter either: actual year, -999 for styr, 0 for endyr, neg number for rel. endyr
1 # Benchmarks: 0=skip; 1=calc F_spr,F_btgt,F_msy; 2=calc F_spr,F0.1,F_msy 
2 # MSY: 1= set to F(SPR); 2=calc F(MSY); 3=set to F(Btgt) or F0.1; 4=set to F(endyr) 
0.3 # SPR target (e.g. 0.40)
0.3 # Biomass target (e.g. 0.40)
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
4	1	0.002674273
1	2	0.000331788
2	2	0.000554782
3	2	0.001131403
4	2	0.002360544
1	3	0.00123482
2	3	7.4663E-05
3	3	0.000405822
4	3	0.029932259
1	4	6.40473E-05
2	4	0
3	4	0
4	4	0.028960268
1	5	0
2	5	0
3	5	0
4	5	0.054743461
1	6	0.06556178
2	6	0
3	6	0
4	6	0
1	7	0.001051344
2	7	0
3	7	0
4	7	0.003865778
1	8	0.070150505
2	8	0
3	8	0.010569302
4	8	0.029471221
1	9	0
2	9	0.067518404
3	9	0
4	9	0
1	10	0.024503719
2	10	0
3	10	0
4	10	0.233250044
1	11	0.000620434
2	11	0.000429392
3	11	0.010774539
4	11	0.001084379
1	12	0
2	12	0.041457286
3	12	0.032175359
4	12	0.010815251
1	13	0.014519917
2	13	0
3	13	0
4	13	0
1	14	0.013062441
2	14	0
3	14	0
4	14	0
1	15	0.002228153
2	15	0.002022638
3	15	0.003019801
4	15	0.00298433
1	16	0.005468518
2	16	0.004260905
3	16	0.013089304
4	16	0
1	17	0
2	17	0
3	17	0
4	17	0.003018444
1	18	0.003800907
2	18	0.001535666
3	18	6.35948E-06
4	18	0.002367311
1	19	0
2	19	0.012746965
3	19	0
4	19	0
1	20	0
2	20	0
3	20	0
4	20	0
1	21	7.07E-03
2	21	6.68E-04
3	21	4.48E-02
4	21	5.39E-02
1	22	2.04E-02
2	22	4.30E-03
3	22	1.32E-04
4	22	1.11E-02
1	23	0.00E+00
2	23	0.00E+00
3	23	0.00E+00
4	23	0.00E+00
1	24	8.66789E-06
2	24	0.004413001
3	24	0.003271792
4	24	0.000591214
1	25	0.035454494
2	25	0
3	25	0
4	25	0.003513502
1	26	0.000254507
2	26	3.71707E-05
3	26	4.22155E-07
4	26	0.00011171
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
