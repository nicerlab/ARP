%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% BatchInitialization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% File and path specifications
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
indir = 'C:\NICERLAB\LNF\';% path for subject directories above
outdir = 'C:\NICERLAB\LNF\Results\';% output directory
this_dir = 'C:\NICERLAB\Artifact_removal_code_FINAL\';
channel_location_file = 'C:\NICERLAB\Artifact_removal_code_FINAL\32ch_bv.elp';
% Read channel location structure
chanlocs=readlocs(channel_location_file);
eye_artefacts_file = 'C:\NICERLAB\Artifact_removal_code_FINAL\bv_generic_eye_artefacts.mat';
channelstruct='C:\NICERLAB\Artifact_removal_code_FINAL\32ch_BrainVision.mat';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%Study specifics
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

subjects = {'M2024'}; % ,'M1024','M1023','M1012','M1011','M1010','M1009'};
epoch_limits= [-0.2 1.0];  %in seconds - before and after trigger stimulus
baseline    = [-0.2 0];    %in seconds - before and after trigger stimulus
nchans = 31; % number of channels used
file_type = '*.vhdr'; % BV header file extensions
systemtype = 'BV';  % BrainVision system
rereference = 0;  % one if the data needs to be rereferenced, 0 if not.  If you recorded with the setting "AVERAGE REFERENCE" this must be set to 0
% channels to be used from the data.  If you are using all channels, include all channels in order
savechans = [1:31]; %  don't include HEOG channel
refchan = 3; % reference channel
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
stims = [go_nogo_stims];  % all epoching (for both ICA and Averaging, is based on the values you place here)
correct_responses = [good_response]; % Averaging Epochs will be based on ANY one of these values coming AFTER stims
% ICA Epochs will be based on allowable_values - best to include all
% possible values so that maximum amount of epochs are selected for ICA
allowable_values = [go_nogo_stims]; 
% conditions are text labels that match will make up the body of the file names for individual (stimulus) conditions
conditions ={'Go_Mus','NoGo_Mus'};
% MERGED conditions will result in individual output files per subject/condition.  
% When averaging takes place, the conditions below will be averaged across all subjects. (MUST MATCH "stims")
merged_conditions = {{'Go_Mus','NoGo_Mus'}};
merged_names = {'All_Mus'};

relevant_events = [stims];   % which events to epoch for averaging.
relevant_responses = [good_response bad_response]; % responses to pair to events if save_unpaired_event=0  (epochs only relevent_events with responses in this list)
ICA_events = [stims]; % events to epoch around for ICA
save_unpaired_event = 1; % set to 1 to save all "relevant events" regardless of response 

% batch1 parameters
chunk_length = 2*60; % in sec - length of chunk of continuous data to perform initial quick ica - should be sufficently long to guarantee plenty of eye artifacts
variance_portion_quickICA = 0.9; % for pca reduction - should be .9 or higher
corr_threshold = 0.9; % threshold for correl with generic ocular artifacts
histocenters = [-500:10:500]; % histo centers for detecting bad channels (in uV)

%batch2 Parameters
epoch_limits= [-0.2 1.0];
baseline    = [-0.2 0];
num_comp_thresh = 0.8;

%batch3 Parameters
variance_portion_pca = 0.99; % 99% variance for pca reduction


% load channel location structure 
load(channelstruct);