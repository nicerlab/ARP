
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
        EEG = pop_reref(EEG,[],'refstate',nchans);
        EEG = eeg_checkset(EEG); EEG.data = double(EEG.data);
    end
        
    % natalie removed redundant epoch code and put in code from Batch1.
    %EEG = epoch_data([inpath cnts{c}],relevant_events,[correct_responses incorrect_responses],stims,epoch_limits,baseline);
    clear events; 
    good_events =[];
    for i=1:length(EEG.event)
        tmp = EEG.event(i).type;
        if (systemtype == 'NS')
             if ischar(tmp),
                tmpevent = str2num(tmp);
             else
                tmpevent = tmp;
             end
        else
            if ~ischar(tmp)
                tmpstr = str2num(tmp);
            else
                tmpstr = tmp;
            end
            if (regexp(tmpstr,'\d+'))
                 charnum = regexp(tmpstr,'\d+','match');
                % events(i) = str2double(regexp(tmpstr,'\d+','match'));
                tmpevent = str2double(charnum);  
            else
                continue;
            end
        end
        % save only events that are RELEVANT and possibly paired with a
        % response
        if ismember(tmpevent,relevant_events)
            if save_unpaired_event == 0  % if we are looking for paired responses
                 if (i ~= numel(EEG.event))
                     pev= EEG.event(i+1).type;
                     if ~ischar(pev)
                        tmppev =num2str(pev);
                     else
                        tmppev = pev;
                    end
                    if (regexp(tmppev,'\d+'))
                         charnum = regexp(tmppev,'\d+','match');
                        % events(i) = str2double(regexp(tmpstr,'\d+','match'));
                        paired_ev = str2double(charnum);   
                    end
                        
                    if ismember(paired_ev,relevant_responses)   
                        good_events = [good_events i]
                    end
                 end
            else % save relevant_events regardless of response
                 good_events = [good_events i]
            end
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
  % merge all sets - however pop_mergeset removes epoch.resp_struct field so I'll put it back
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
  icaact = reshape(icaact,num_keepcomps,EEG.pnts,[]);
  
  % get ica gfp for each trial
  ica_trial_gfp = squeeze(sum(abs(icaact),2)); % (comp trial)
  
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
  
  % count how many trials in each condition
  trial_count = zeros(numel(allowable_values),1);
  for trial=1:numel(keeptrials)
    epoch = EEG.epoch(keeptrials(trial));
    if systemtype == 'NS'
        stim = find(ismember(cell2mat(epoch.eventtype),stims));
        this_stim = epoch.eventtype{stim};
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
    if index > 0
        trial_count(index) = trial_count(index) + 1;
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

       
