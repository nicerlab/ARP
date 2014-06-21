%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Setup
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%addpath('/arrakis/mcintosh_lab/natasa/eeglab/eeglab6.01b');
eeglab;

%subjects = {'ZXSN####'} with reference reinstated (X) and replaced event codes (Z);
subjects = {'ZXSN52','ZXSN0107','ZXSN0110','ZXSN116','ZXSN0208','ZXSN232','ZXSN0319','ZXSN0406','ZXSN0407','ZXSN0416','ZXSN0419','ZXSN482','ZXSN0502','ZXSN1002','ZXSN1007B','ZXSN1012','ZXSN1103','ZXSN1313','ZXSN1313B','ZXSN1318','ZXSN1319','ZXSN1323','ZXSN1411x','ZXSN1501','ZXSN1515','ZXSN1913','ZXSN1926','ZXSN2002','ZXSN2010','ZXSN2013','ZXSN2109','ZXSN2219','ZXSN2301','ZXSN2508'};
%subjects = {'ZXSN13','ZXSN14','ZXSN46','ZXSN52','ZXSN0107','ZXSN0110','ZXSN116','ZXSN0119','ZXSN119','ZXSN138','ZXSN0208','ZXSN0208','ZXSN232','ZXSN0319','ZXSN0319','ZXSN0406','ZXSN0407','ZXSN0416','ZXSN0419','ZXSN482','ZXSN0502','ZXSN0611','ZXSN719','ZXSN1002','ZXSN1003','ZXSN1007','ZXSN1007B','ZXSN1012','ZXSN1103','ZXSN1313','ZXSN1313B','ZXSN1318','ZXSN1319','ZXSN1319','ZXSN1323','ZXSN1411x','ZXSN1416','ZXSN1501','ZXSN1515','ZXSN1810','ZXSN1819','ZXSN1913','ZXSN1926','ZXSN2002','ZXSN2010','ZXSN2013','ZXSN2109','ZXSN2219','ZXSN2301','ZXSN2316','ZXSN2508'};

indir = 'C:\Patricia\CARLETON\EXPERIMENTS\LED\2_PROCESSED_DATA\4_ERP\CNT_NEWEV2S\';% path for subject directories above

outdir = 'C:\Patricia\CARLETON\EXPERIMENTS\LED\2_PROCESSED_DATA\4_ERP\CNT_NEWEV2S\Results\';% output directory

this_dir = 'C:\Artifact_removal_code\';

% load channel location  structure 
%load('70channel.mat'); % this loads variable chanlocs - channel location structure 
% Read channel location structure
chanlocs=readlocs('C:\Artifact_removal_code\70channel.elp');

epoch_limits= [-0.2 1.0];
baseline    = [-0.2 0];
correct_responses = [211 222 233 244 111 122 133 144];
incorrect_responses = [212 213 214 221 223 224 231 232 234 214 224 234 112 113 114 121 123 124 131 132 134 141 142 143];
stims = [216 227 238 249 116 117 118 119];
relevant_events = [stims correct_responses incorrect_responses]; %this will be used to average the stim followed by a correct response

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% batch1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get stats for each continuous file to see if events are ok and if data is ok
% concatenate data from all cnt files
% select best 8min chunk from concatenated data
% perform quick ica and detect artifacts

% batch1 parameters
chunk_length = 3*60; % in sec (8 minutes here)- length of chunk of cont data to perform initial quick ica - should be sufficently long to guarantee plenty of eye artifacts
variance_portion = 0.9; % for pca reduction
corr_threshold = 0.9; % threshold for correl with generic ocular artifacts
histocenters = [-500:10:500]; % histo centers for detecting bad channels (in uV)

batch1;
batch1_summary;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% batch2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% merge data, temporarily remove artifacts from batch1
% filter, epoch, reassign eventtypes and 
% reject trials where most kept ica are above threshold
% get stats on original and new num trials
epoch_limits= [-0.2 1.0];
baseline    = [-0.2 0];
num_comp_thresh = 0.8;
corr_threshold = 0.9; % threshold for correl with generic ocular artifacts
%allowable_values = {110 111 115 120 121 125 130 131 135 140 141 145 155 210 211 215 220 221 225 230 231 235 240 241 245 255};
%SC = Stroop Colour RCC=red congruent correct, BCC=blue congruent correct,GCC=green congruent correct, YCC=yellow congruent correct
allowable_values = {216 227 238 249 116 127 138 149 217 218 219 226 228 229 236 237 239 246 247 248 117 118 119 126 128 129 136 137 139 146 147 148};
conditions ={'SC_RCon','SC_BCon','SC_GCon', 'SC_YCon','SW_RCon', 'SW_BCon', 'SW_GCon', 'SW_YCon', 'SC_RInconB', 'SC_RInconG', 'SC_RInconY', 'SC_BInconR', 'SC_BInconG', 'SC_BInconY', 'SC_GInconR', 'SC_GInconB', 'SC_GInconY', 'SC_YInconR', 'SC_YInconB', 'SC_YInconG','SW_RInconB','SW_RInconG','SW_RInconY', 'SW_BInconR', 'SW_BInconG', 'SW_BInconY', 'SW_GInconR','SW_GInconB', 'SW_GInconY', 'SW_YInconR', 'SW_YInconB', 'SW_YInconG'};
              
batch2;
batch2_summary;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% batch3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load merged set
% perform  ica on 99% variance

variance_portion = 0.99; % for pca reduction
batch3;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% batch4
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% let user view icas from batch3 and select those that should be rejected from all trials. The program then  selectively removes comps on trial-to-trial basis.Final clean data is then split into condition specific sets.
% define conditions and corresponding triggers-of-interest

%batch4;
batch5;

