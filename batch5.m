
for s=1:numel(subjects)
  subj = subjects{s}; 
  outpath = [outdir subj '\']; 
  
  if ~exist([outpath 'ica_rejcomps.txt'],'file')
   error ([outpath 'ica_rejcomps.txt is missing!  Batch5 halting prematurely.']);
  end
  rejcomps = load([outpath 'ica_rejcomps.txt']);
  if exist([outdir 'ica_blinkcomps.txt'],'file')
    libcomps = load([outpath 'ica_blinkcomps.txt']);
    rejcomps = union(rejcomps, libcomps);
  end
  if exist([outdir 'ica_saccadecomps.txt'],'file')
    libcomps = load([outpath 'ica_saccadecomps.txt']);
    rejcomps = union(rejcomps, libcomps);
  end
  EEG = pop_loadset([subj '_merged.set'], outpath);
  
  load([outpath 'ica.mat']);
  
  EEG.icasphere = sphere;
  EEG.icaweights = weights;
  EEG.icawinv = pinv(weights * sphere);
  EEG.icaact =(EEG.icaweights*EEG.icasphere) * reshape(EEG.data,EEG.nbchan,[]);
  EEG.icaact = reshape(EEG.icaact,size(EEG.icaweights,1),size(EEG.data,2),[]);
  %mix_matrix = weights * sphere;
  %icaact = mix_matrix * reshape(EEG.data,EEG.nbchan,[]);
  num_comps = size(icaact,1);
  %icaact = reshape(icaact,num_comps,EEG.pnts,[]);
 
  
  
  % get ica gfp for each trial
  ica_trial_gfp = squeeze(sum(abs(EEG.icaact), 2)); % (comp trial)
  
  % get 40th percentile 
  gfp_40p = prctile(ica_trial_gfp',40);
  
  % calculate std over trials with gfp below 40p 
  clear stdev;
  for comp =1:size(EEG.icaact,1)
    good_trials = find(squeeze(ica_trial_gfp(comp,:)) < gfp_40p(comp));
    stdev(comp) = std(squeeze(ica_trial_gfp(comp,good_trials)));
    % find which percentile corresponds to thresh  (this next variable is
    % never used, why?
    thresh_perc(comp) = round(100*numel(find(squeeze(ica_trial_gfp(comp,:)) < gfp_40p(comp) + 6*stdev(comp)))/ EEG.trials);
  end
  
  % clean each trial by subtracting rejcomps plus comps that are above 40p+6*std threshold
  for trial=1:EEG.trials
    trial_rejcomps = union(rejcomps, find(squeeze(ica_trial_gfp(:,trial)') > (gfp_40p + 6*stdev)));
    trial_keepcomps = setdiff([1:size(EEG.icaact,1)],trial_rejcomps);
    % clean up part of the data that is coverd by ica and add back leftover signal
    EEG.data(:,:,trial) =  (EEG.icawinv(:,trial_keepcomps) * EEG.icaact(trial_keepcomps,:,trial)) + EEG.data(:,:,trial) - (EEG.icawinv * EEG.icaact(:,:,trial));
  end
  
  % re-baseline
  baseline_pts = 1:round((baseline(2)-baseline(1))*EEG.srate);
  EEG = pop_rmbase(EEG, baseline, baseline_pts);
  EEG = eeg_checkset(EEG);
  
  
  % Leave ICA stuff in - just in case we want to go back and review.  
  %EEG.icaact = []; EEG.icasphere = []; EEG.icaweights = []; EEG.icawinv = [];
  %EEG = eeg_checkset(EEG);
  
  % split into condition-specific sets and save
  for j=1:numel(conditions)
    cond = conditions{j};
      
    % keep only trials triggerd by toi
    keeptrials = [];
    for trial=1:EEG.trials
        epoch = EEG.epoch(trial);
        if systemtype == 'NS'
            stim = find(ismember(cell2mat(epoch.eventtype),stims));
            this_stim = epoch.eventtype(1);
            if iscell(epoch.eventtype)
                this_stim = cell2mat(epoch.eventtype(1));
            else
                this_stim = epoch.eventtype(1);
            end
        else
            if iscell(epoch.eventtype)
                this_stim = cell2mat(epoch.eventtype(1));
            else
                this_stim = epoch.eventtype(1);
            end
        end
        if ischar(this_stim) 
            stimind = str2double(this_stim);
        else
            stimind = this_stim;
        end
        clear index;
        index = find(allowable_values == stimind);
        if allowable_values(index) == allowable_values(j)
            keeptrials = [keeptrials trial];
        end      
    end
    fprintf('Condition: %s has %d matching trials\n', cond, numel(keeptrials));
    rejepoch = ones(1, EEG.trials);
    rejepoch(keeptrials) = 0;
    tmpeeg = pop_rejepoch(EEG, rejepoch, 0);
    tmpeeg = pop_subcomp(tmpeeg, rejcomps, 1);
    tmpeeg = eeg_checkset(tmpeeg);
    tmpeeg.setname = cond;
    tmpeeg = pop_saveset(tmpeeg, [tmpeeg.setname '.set'], outpath );
  end
  
  
end
       
