%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% BatchInitialization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% File and path specifications
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
indir = 'C:\NICERLAB\LNFCLEAN\';% path for subject directories above
outdir = 'C:\NICERLAB\LNFCLEAN\Results\';% output directory
this_dir = 'C:\NICERLAB\Artifact_removal_code_FINAL\';
channel_location_file = 'C:\NICERLAB\Artifact_removal_code_FINAL\31ch_bv.elp';
% Read channel location structure
chanlocs=readlocs(channel_location_file);
eye_artefacts_file = 'C:\NICERLAB\Artifact_removal_code_FINALT\bv_generic_eye_artefacts.mat';
%channelstruct='C:\NICERLAB\Artifact_removal_code_FINAL\32ch_BrainVision.mat';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%Study specifics
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

subjects = {'M1023'};
epoch_limits= [-0.2 1.0];  %in seconds - before and after trigger stimulus
baseline    = [-0.2 0];    %in seconds - before and after trigger stimulus
nchans = 31; % number of channels used
file_type = '*.vhdr'; % BV header file extensions
systemtype = 'BV';  % BrainVision system
rereference = 0;  % set to 1 if you want the data to be rereferenced using AVERAGE REFERENCE, 0 if not.  If you recorded with the setting "AVERAGE REFERENCE" this must be set to 0

% set this value if you have channels you want to keep for data but exclude from average referencing
refexclude =[];  % or refexclude=[31 32];  or some variant thereof 

% channels to be used from the data.  If you are using all channels, include all channels in order
savechans = [1:31]; %  don't include HEOG channel

refchan = 1; % reference channel - only valid if recorded with a common reference channel that is included in the data.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%Stimulus and response definitions specific to your study 
%%%(the ones in this block can be named whatever is suitable
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
go_nogo_stims = [7 8];
good_response = [1];
bad_response = [2];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The names of the variables in this section must not change -  they are crucial the program working properl
%%% what is important is what you set them to (based on your definitions above)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% stimulus codes to epoch around
stims = [go_nogo_stims];  % final epoching, for saving data sets and Averaging, is based on the values you place here

% ICA Epochs will be based on allowable_values - best to include all
% possible values so that maximum amount of epochs are selected for ICA
allowable_values = [go_nogo_stims];

% conditions are text labels that match will make up the body of the file names for individual (stimulus) conditions
% MUST MATCH 1:1 with "stims" values
conditions ={'Go_Con','NoGo_Con'};

% MERGED conditions will result in individual output files per subject/condition.  
% When averaging takes place, the conditions below will be averaged across all subjects. (MUST MATCH "stims")
merged_conditions = {{'Go_Con','NoGo_Con'}};
merged_names = {'All_Con'};

save_unpaired_event = 1; % set to 1 to create epochs for all "stims" events regardless of response 
% responses to pair to events if save_unpaired_event=0  (epochs only relevent_events with responses in this list)
% (comment out if save_unpaired_event = 1)
relevant_responses = [good_response bad_response]; % responses to pair to events if save_unpaired_event=0  (epochs only relevent_events with responses in this list)

% epoch parameters, in seconds
epoch_limits= [-0.2 1.0];
baseline    = [-0.2 0]; % baseline points are averaged and subtracted from the remainder of the epoch

% batch1 parameters
chunk_length = 3*60; % in sec - length of chunk of continuous data to perform initial quick ica - should be sufficently long to guarantee plenty of eye artifacts
variance_portion_quickICA = 0.9; % for pca reduction - should be .9 or higher
corr_threshold = 0.9; % threshold for correl with generic ocular artifacts
histocenters = [-500:10:500]; % histo centers for detecting bad channels (in uV)

%batch2 Parameters
num_comp_thresh = 0.8;

%batch3 Parameters
variance_portion_pca = 0.99; % 99% variance for pca reduction
