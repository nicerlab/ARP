%batch2.m
% INPUTS: batch1_summary.mat, subjects

% batch1_summary.mat file is read in and the quick ICA stats are used to 
% calculate the global field power.   The Global Field Power (GFP) is the 
% standard deviation of the potentials at all electrodes of an average-reference 
% map at each point in time.  GFP is used as a measure of signal-to-noise ratio.  

% Data files for each subject are loaded again, and this time epoched around 
% paired events, if required (such as only selecting events with a “good” response).  
% In the case of go-nogo where you want to save all events, you can specify 
% save_unpaired_event = 1 in your Batch_Initialize.m file.
% All trials are analyzed and components are once again extracted.  
% The component global field power (standard deviation) is calculated by using 
% only components below the 30th percentile. The gfp threshold is calculated 
% as the 30th percentile ICA + 5*gfp.    Components are then analyzed and full 
% trials (epochs) will be rejected if most of the components exceed threshold. 

%The console window will report how many trials were dropped due to exceeding gfp_30 thresholds.

% OUTPUTS: A histogram of the number of stimulus events per condition specified will be produced.    If you have lots of conditions, this can become very crowded.

for s=1:numel(subjects)
  subj = subjects{s}; 
  inpath = [indir subj '\'];
  outpath = [outdir subj '\']; 
  load([outpath 'batch1_summary.mat']);
  if ~strcmp(subj, cnt_stats.subj)
    disp(['subj inconsistent ' subj]);
    continue;
  end
  %if exist([outpath 'batch2_summary.mat'],'file'); continue; end;
  cd(inpath);
  tmp = dir(file_type);
  cnts = {tmp.name}; 
  cd(this_dir);
  
  ALLEEG = [];
  for c=1:numel(cnts)
    EEG =[];
    % load data file and rereference if needed
    % filter, epoch, baseline and change eventypes
    fname = cnts{c};
    if systemtype == 'NS'
        EEG = pop_biosig([inpath fname],'channels',savechans,'ref',refchan);
    elseif systemtype =='BV'
        EEG = pop_loadbv(inpath,fname,[],savechans);
    end
    EEG = eeg_checkset(EEG); EEG.data = double(EEG.data);
    EEG = eeg_checkset(EEG); EEG.data = double(EEG.data);
    EEG = pop_chanedit(EEG,  'load',{channel_location_file, 'filetype', 'besa'});
    %EEG.chanlocs = chanlocs;
    EEG = pop_select(EEG,'channel',1:nchans);
    if rereference == 1  % only rereference if we need to
        % EEG = pop_reref(EEG,[],'refstate',nchans); - these parameters were deprecated.
        EEG = pop_reref(EEG,[],'exclude',refexclude);
        EEG = eeg_checkset(EEG); EEG.data = double(EEG.data);
    end
        
    clear events; 
    good_events =[];
    for i=1:length(EEG.event)
        tmp = EEG.event(i).type;
        if ischar(tmp)
            tmpevent = str2double(tmp);
        else
            tmpevent = tmp;
        end
        % save only events that are identified in allowable_values
        % this saves maximum events for ICA.  only events defined in stims
        % will be saved for averaging (in batch5)
        if ismember(tmpevent,allowable_values)
            good_events = [good_events i]
        end
    end
       

    EEG = pop_epoch(EEG,{},epoch_limits,'eventindices',good_events, 'epochinfo', 'yes');
    EEG = eeg_checkset(EEG); EEG.data = double(EEG.data);
    % remove baseline
    baseline_pts = 1:round((baseline(2)-baseline(1))*EEG.srate);
    EEG = pop_rmbase(EEG, baseline, baseline_pts);
    EEG = eeg_checkset(EEG); EEG.data = double(EEG.data);
 % end of batch1 addtion   
        
    if isfield(EEG.event,'duration')
        EEG.event = rmfield(EEG.event, 'duration');
    end
    %EEG = eeg_checkset(EEG);
    ALLEEG = [ALLEEG EEG];
    clear EEG;
  end
  % merge all data sets for a given subject - however pop_mergeset removes epoch.resp_struct field so I'll put it back
  if numel(ALLEEG)>1
    EEG = pop_mergeset(ALLEEG,1:numel(ALLEEG),0);
    EEG = eeg_checkset(EEG);
  else
    EEG = ALLEEG;
  end
  clear ALLEEG;

  % get ica from batch1
  mix_matrix = cnt_stats.mix_matrix;
  rejcomps = find(max(cnt_stats.similarity,[],1)> corr_threshold); %cnt_stats.rejcomps;
  winv = pinv(mix_matrix);
  keepcomps = setdiff([1:size(mix_matrix,1)],rejcomps);

  % in order to determine trials to be rejected work with keepcomps only
  % find trials where most of keepcomps are bad
  icaact = mix_matrix(keepcomps,:) * reshape(EEG.data,EEG.nbchan,[]);
  num_keepcomps = size(icaact,1);
  EEG.icaact = reshape(icaact,num_keepcomps,EEG.pnts,[]);
  
  % get ica gfp for each trial
  ica_trial_gfp = squeeze(sum(abs(EEG.icaact),2)); % (comp trial)
  
  % get 30th percentile for each comp
  gfp_30p = prctile(ica_trial_gfp',30);
  
  % calculate stddev over trials with gfp below 30p 
  clear stdev;
  for comp =1:num_keepcomps
    good_trials = find(squeeze(ica_trial_gfp(comp,:)) < gfp_30p(comp));
    stdev(comp) = std(squeeze(ica_trial_gfp(comp,good_trials)));
  end

  gfp_thresholds = gfp_30p + 5*stdev;
  rejtrials = [];
  for trial=1:EEG.trials
    % if most comps have gfp above gfp threshold -> rejtrial
    if sum(ica_trial_gfp(:,trial)' > gfp_thresholds) > (num_comp_thresh*num_keepcomps)
      rejtrials = [rejtrials trial];
    end
  end
  keeptrials = setdiff([1:EEG.trials],rejtrials);
  
  % count how many trials in each condition (will only count conditions in
  % stims that we will ultimately save and use later)
  % presumes that stims contains either the same or LESS conditions than
  % allowable_values
  trial_count = zeros(numel(stims),1);
  for j=1:numel(conditions)
       cond_stim = stims(j);
        for trial=1:numel(keeptrials)
            epoch = EEG.epoch(keeptrials(trial));
            if ischar(epoch.eventtype{1}) 
                binevents = str2double(epoch.eventtype);
            else
                binevents = epoch.eventtype;
            end
            if any(cond_stim==binevents)      
               trial_count(j) = trial_count(j) + 1;
            end
        end
  end
  
  % record stats for this subject
  clear trial_stats;
  trial_stats.subj = subj;
  trial_stats.orig_num_trials = EEG.trials;
  trial_stats.new_num_trials = numel(keeptrials);
  trial_stats.rejtrials = rejtrials;
  trial_stats.trial_count = trial_count;
  save([outpath 'batch2_summary.mat'],'trial_stats');

  % reject bad trials and save merged set
  marktrials = zeros(1,EEG.trials);
  marktrials(rejtrials) = 1;
  EEG = pop_rejepoch(EEG,marktrials,0);% pop_rejepoch removes additional resp_struct that I have added previously to EEG.epoch. 
  %This is because pop_rejepoch calls pop_select which in turn calls eeg_checkset with 'eventconsistency' andd this fuction completely 
  %rebuilds EEG.epoch from scratch. For this reason I'll work arround this problem by letting eeg_checkset('eventconsistency') do its 
  %job but then add back my resp_struct -this is a bit dangerous because if at any later time I call eeg_checkset('eventconsistency') 
  %I'll loose resp_struct again
                                       %
  EEG = eeg_checkset(EEG);
  EEG.setname = [subj '_merged'];
  EEG = pop_saveset(EEG, [EEG.setname '.set'], outpath ); 
end

       
