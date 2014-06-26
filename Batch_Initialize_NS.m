%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% BatchInitialization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% File and path specifications
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
indir = 'C:\NICERLAB\Sample_data\';% path for subject directories above
outdir = 'C:\NICERLAB\Sample_data\NewResults\';% output directory
this_dir = 'C:\NICERLAB\Artifact_removal_code_FINAL\';
channel_location_file = 'C:\NICERLAB\Artifact_removal_code_FINAL\70channel.elp';
% Read channel location structure
chanlocs=readlocs(channel_location_file);
eye_artefacts_file = 'C:\NICERLAB\Artifact_removal_code_FINAL\generic_eye_artefacts_Neuroscan.mat';
%channelstruct='C:\NICERLAB\Artifact_removal_code_FINAL\70Channel.mat';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%Study specifics
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%subjects = {'ZXSN52','ZXSN0107','ZXSN0110','ZXSN116','ZXSN0208','ZXSN232','ZXSN0319','ZXSN0406','ZXSN0407','ZXSN0416','ZXSN0419','ZXSN482','ZXSN0502','ZXSN1002','ZXSN1007B','ZXSN1012','ZXSN1103','ZXSN1313','ZXSN1313B','ZXSN1318','ZXSN1319','ZXSN1323','ZXSN1411x','ZXSN1501','ZXSN1515','ZXSN1913','ZXSN1926','ZXSN2002','ZXSN2010','ZXSN2013','ZXSN2109','ZXSN2219','ZXSN2301','ZXSN2508'};
subjects = {'ZXSN1323'};
epoch_limits= [-0.2 1.0];  %in seconds - before and after trigger stimulus
baseline    = [-0.2 0];    %in seconds - before and after trigger stimulus
nchans = 69; % number of channels used
file_type = '*.cnt'; % neuroscan continuous file extensions
systemtype = 'NS';  % neuroscan system

rereference = 1;  % set to 1 if you want the data to be rereferenced using AVERAGE REFERENCE, 0 if not.  If you recorded with the setting "AVERAGE REFERENCE" this must be set to 0

% set this value if you have channels you want to keep for data but exclude from average referencing
refexclude =[];  % or refexclude=[31 32];  or some variant thereof 

% channels to be used from the data.  If you are using all channels, include all channels in order
savechans = [1:69]; %  don't include HEOG channel

refchan = 69; % reference channel - only valid if recorded with a common reference channel that is included in the data.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%Stimulus and response definitions specific to your study 
%%%(the ones in this block can be named whatever is suitable)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
correct_responses_Word = [111 122 133 144];
correct_responses_Colour = [211 222 233 244];
incorrect_responses_Word = [113 114 121 123 124 131 132 134 141 142 143];
incorrect_responses_Colour = [212 213 214 221 223 224 231 232 234 214 224 234];
Congruent_Word_stims = [116 127 138 149];
Incongruent_Word_stims = [117 118 119 126 128 129 136 137 139 146 147 148];
Congruent_Colour_stims = [216 227 238 249];
Incongruent_Colour_stims = [217 218 219 226 228 229 236 237 239 246 247 248];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The names of the variables in this section must not change -  they are crucial the program working properl
%%% what is important is what you set them to (based on your definitions above)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% stimulus codes to epoch around for averaging and saving in .set files.
stims = [Congruent_Colour_stims];  % final epoching, for saving data sets and Averaging, is based on the values you place here

% ICA Epochs will be based on allowable_values - best to include all
% possible values so that maximum amount of epochs are selected for ICA
allowable_values = [Congruent_Colour_stims Incongruent_Colour_stims Congruent_Word_stims Incongruent_Word_stims]; 

% conditions are text labels that match will make up the body of the file names - MUST MATCH 1:1 with then number of values assigned to "stims" 
conditions ={'SC_RCon','SC_BCon','SC_GCon', 'SC_YCon'};
% ,'SW_RCon', 'SW_BCon', 'SW_GCon', 'SW_YCon', 'SC_RInconB', 'SC_RInconG', 'SC_RInconY', 'SC_BInconR', 'SC_BInconG', 'SC_BInconY', 'SC_GInconR', 'SC_GInconB', 'SC_GInconY', 'SC_YInconR', 'SC_YInconB', 'SC_YInconG','SW_RInconB','SW_RInconG','SW_RInconY', 'SW_BInconR', 'SW_BInconG', 'SW_BInconY', 'SW_GInconR','SW_GInconB', 'SW_GInconY', 'SW_YInconR', 'SW_YInconB', 'SW_YInconG'};

% MERGED conditions will result in individual output files per subject/condition.  
% When averaging takes place, the conditions below will be averaged across all subjects. (MUST MATCH "stims")
merged_conditions = {{'SC_RCon','SC_BCon','SC_GCon', 'SC_YCon'}};
    %,{'SW_RCon', 'SW_BCon', 'SW_GCon', 'SW_YCon'},{'SC_RInconB', 'SC_RInconG', 'SC_RInconY', 'SC_BInconR','SC_BInconG', 'SC_BInconY', 'SC_GInconR', 'SC_GInconB', 'SC_GInconY', 'SC_YInconR', 'SC_YInconB', 'SC_YInconG'},{'SW_RInconB','SW_RInconG','SW_RInconY', 'SW_BInconR', 'SW_BInconG', 'SW_BInconY', 'SW_GInconR','SW_GInconB', 'SW_GInconY', 'SW_YInconR', 'SW_YInconB', 'SW_YInconG'}};
%merged_names = {'SCCong','SWCong','SCIncong','SWIncong'};
merged_names = {'SCCong'};

relevant_responses = [correct_responses_Colour];  % responses to pair to events if save_unpaired_event=0  (epochs only relevent_events with responses in this list)
save_unpaired_event = 0; % only save paired events; set to 1 if you want to save all "relevant events" regardless of response 

% epoch parameters, in seconds
epoch_limits= [-0.2 1.0];
baseline    = [-0.2 0]; % baseline points are averaged and subtracted from the remainder of the epoch

% batch1 parameters
chunk_length = 3*60; % in sec - length of chunk of cont data to perform initial quick ica - should be sufficently long to guarantee plenty of eye artifacts
variance_portion_quickICA = 0.9; % for pca reduction - should be .9 or higher
corr_threshold = 0.9; % threshold for correl with generic ocular artifacts
histocenters = [-500:10:500]; % histo centers for detecting bad channels (in uV)

%batch2 Parameters
num_comp_thresh = 0.8;

%batch3 Parameters
variance_portion_pca = 0.99; % 99% variance for pca reduction
