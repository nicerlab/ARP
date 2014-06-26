%subjects = {'2750','3007','3733','3774','4267','9999','4701','2400','2406','4193','4829','4268','2984','2825','2084','4233','2722','4709','4524','3792','3670'};
subjects = {'ZXSN52','ZXSN0107','ZXSN0110','ZXSN116','ZXSN0208','ZXSN232','ZXSN0319','ZXSN0406','ZXSN0407','ZXSN0416','ZXSN0419','ZXSN482','ZXSN0502','ZXSN1002','ZXSN1007B','ZXSN1012','ZXSN1103','ZXSN1313','ZXSN1313B','ZXSN1318','ZXSN1319','ZXSN1323','ZXSN1411x','ZXSN1501','ZXSN1515','ZXSN1913','ZXSN1926','ZXSN2002','ZXSN2010','ZXSN2013','ZXSN2109','ZXSN2219','ZXSN2301','ZXSN2508'};

indir = 'C:\Patricia\CARLETON\EXPERIMENTS\LED\2_PROCESSED_DATA\4_ERP\CNT_NEWEV2S\';% path for subject directories above

outdir = 'C:\Patricia\CARLETON\EXPERIMENTS\LED\2_PROCESSED_DATA\4_ERP\CNT_NEWEV2S\Results\';% output directory

%outdir = '/rri_disks/parthenope/mcintosh_lab/bratislav/Contrast_Sensitivity/Artifact_removal_results/';% output directory

%conditions ={'B_10_1', 'B_10_2', 'B_20_1', 'B_20_2',...
%             'IC_10_1', 'IC_10_2', 'IC_10_3','IC_20_1', 'IC_20_2', 'IC_20_3',...
%             'VC_10_1', 'VC_10_2','VC_20_3'};
conditions ={'SC_RCon','SC_BCon','SC_GCon', 'SC_YCon','SW_RCon', 'SW_BCon', 'SW_GCon', 'SW_YCon', 'SC_RInconB', 'SC_RInconG', 'SC_RInconY', 'SC_BInconR', 'SC_BInconG', 'SC_BInconY', 'SC_GInconR', 'SC_GInconB', 'SC_GInconY', 'SC_YInconR', 'SC_YInconB', 'SC_YInconG','SW_RInconB','SW_RInconG','SW_RInconY', 'SW_BInconR', 'SW_BInconG', 'SW_BInconY', 'SW_GInconR','SW_GInconB', 'SW_GInconY', 'SW_YInconR', 'SW_YInconB', 'SW_YInconG'};


%merged_conditions = {{'B_plus_all','B_letterH_all'},...
%               {'IC_plus_all','IC_letterH_all'},...
%               {'VC_plus_all','VC_letterH_all'}};
merged_conditions = {{'SC_RCon','SC_BCon','SC_GCon', 'SC_YCon'},{'SW_RCon', 'SW_BCon', 'SW_GCon', 'SW_YCon'},{'SC_RInconB', 'SC_RInconG', 'SC_RInconY', 'SC_BInconR','SC_BInconG', 'SC_BInconY', 'SC_GInconR', 'SC_GInconB', 'SC_GInconY', 'SC_YInconR', 'SC_YInconB', 'SC_YInconG'},{'SW_RInconB','SW_RInconG','SW_RInconY', 'SW_BInconR', 'SW_BInconG', 'SW_BInconY', 'SW_GInconR','SW_GInconB', 'SW_GInconY', 'SW_YInconR', 'SW_YInconB', 'SW_YInconG'}};
merged_names = {'SCCong','SWCong','SCIncong','SWIncong'};

diff_names = {'B_letterH_plus_diff','IC_letterH_plus_diff','VC_letterH_plus_diff'};

for s=1:numel(subjects)
  subj = subjects{s}; 
  outpath = [outdir subj '\']; 


       %B_plus_wave = load([outpath 'B_plus_wave.txt']);
       %B_letterH_wave = load([outpath 'B_letterH_wave.txt']);
       %B_diff = B_plus_wave - B_letterH_wave;
       %save([outpath 'B_plus_H_diff_allG.txt'],'B_diff','-ascii');
      
       SCIncong_wave = load([outpath 'SCIncong.txt']);
       SCCong_wave = load([outpath 'SCCong.txt']);
       SCdiff = SCIncong_wave - SCCong_wave;
       save([outpath 'SCIncong_minus_SCCong_diff_all.txt'],'SCdiff','-ascii');
       
       %clear B_plus_wave
       %clear B_letterH_wave
       %clear B_diff
      
       clear SCIncong
       clear SCCong
       clear SC_diff
  
       SW_Incong_wave = load([outpath 'SWIncong.txt']);
       SW_Cong_wave = load([outpath 'SWCong.txt']);
       SW_diff = SW_Incong_wave - SW_Cong_wave;
       save([outpath 'SWIncong_minus_SWCong_diff_all.txt'],'SW_diff','-ascii');
       
       clear SWIncong
       clear SWCong
       clear SW_diff
       
       %IC_plus_wave = load([outpath 'IC_plus_all.txt']);
       %IC_letterH_wave = load([outpath 'IC_letterH_all.txt']);
       %IC_diff = IC_plus_wave - IC_letterH_wave;
       %save([outpath 'IC_plus_H_diff_allG.txt'],'IC_diff','-ascii');
       
       %clear IC_plus_wave
       %clear IC_letterH_wave
       %clear IC_diff       
       
       %VC_plus_wave = load([outpath 'VC_plus_all.txt']);
       %VC_letterH_wave = load([outpath 'VC_letterH_all.txt']);
       %VC_diff = VC_plus_wave - VC_letterH_wave;
       %save([outpath 'VC_plus_H_diff_allG.txt'],'VC_diff','-ascii');
       
       %clear VC_plus_wave
       %clear VC_letterH_wave
       %clear VC_diff

end