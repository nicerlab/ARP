%%% load generic artefacts
load(eye_artefacts_file);

for s=1:numel(subjects)
    clear cnt_stats; % for keeping track of cnt
    subj = subjects{s};
    cnt_stats.subj = subj;

    inpath = [indir subj '\'];
    outpath = [outdir subj '\'];
    mkdir(outdir,subj);
    cd(inpath);
    % Natalie: removed hard-coded filetype, moved it to a defined variable
    tmp = dir(file_type);
    rawfnames = {tmp.name};
    cd(this_dir);

    % For each cont data file calculate some simple stats
    % Concatenate data from all continuous files
    data = [];
    for c=1:numel(rawfnames)
        fname = rawfnames{c};
        if systemtype == 'NS'
            EEG = pop_biosig([inpath fname],'channels',savechans,'ref',refchan);
        elseif systemtype =='BV'
            EEG = pop_loadbv(inpath,fname,[],savechans);
        end
        EEG = eeg_checkset(EEG); EEG.data = double(EEG.data);
        EEG = pop_chanedit(EEG,'load',{channel_location_file, 'filetype', 'besa'});
        %EEG.chanlocs = chanlocs;
        EEG = pop_select(EEG,'channel',1:nchans);
        EEG = eeg_checkset(EEG); EEG.data = double(EEG.data);
        if rereference == 1  % only rereference if we need to
           % EEG = pop_reref(EEG,[],'refstate',nchans); - these parameters were deprecated.
            EEG = pop_reref(EEG,[],'exclude',refexclude);
            EEG = eeg_checkset(EEG); EEG.data = double(EEG.data);
        end
        
        % get all different eventtypes in this file
        % for each eventtype calculate how many times it appears in the file
        
        events = [];
        eventfreqs = [];
        for i=1:length(EEG.event)
            tmp = EEG.event(i).type;
            if (systemtype == 'NS')
                 if ischar(tmp),
                     events(i) = str2num(tmp);
                 else
                     events(i) = tmp;
                 end
            else
                if ~ischar(tmp)
                    tmpstr = num2str(EEG.event(i).type);
                else
                    tmpstr = tmp;
                end
                if (regexp(tmpstr,'\d+'))
                     charnum = regexp(tmpstr,'\d+','match');
                    % events(i) = str2double(regexp(tmpstr,'\d+','match'));
                    events(i) = str2double(charnum);   
                end
                   
            end
        end
        if length(events) == 0
             error('Events are not coded numerically. Cannot process!');
        end
        eventtypes = sort(unique(events));
        eventfreqs = hist(events,eventtypes);   
        

        cnt_stats.cntfnames{c}    = fname;
        cnt_stats.events{c}       = [EEG.event.type];
        cnt_stats.eventtypes{c}   = eventtypes;
        cnt_stats.eventfreqs{c}   = eventfreqs;
        cnt_stats.srate{c}        = EEG.srate;
        cnt_stats.time{c}         = [EEG.xmin EEG.xmax];
        cnt_stats.nbchan{c}       = EEG.nbchan;
        
        % select only events listed under stims
        good_events =[];
        delete_events =[];
        for ev = 1:length(events)
           if ismember(events(ev),allowable_values)
               good_events = [good_events ev];
           end
        end

        % now extract epochs which are timelocked to good_events
        EEG = pop_epoch(EEG,{},epoch_limits,'eventindices',good_events, 'epochinfo', 'yes');
        EEG = eeg_checkset(EEG); EEG.data = double(EEG.data);


        % remove baseline
        baseline_pts = 1:round((baseline(2)-baseline(1))*EEG.srate);
        EEG = pop_rmbase(EEG, baseline, baseline_pts);
        EEG = eeg_checkset(EEG); EEG.data = double(EEG.data);

        data = [data reshape(EEG.data,EEG.nbchan,[])];
               
        % get amplitude stats from epoched data (otherwise bdf too noisy)
        % for each chan, remove temporal mean and calculate histogram
        % good channels should have highest histogram count at 0 or nearby
        for chan=1:EEG.nbchan
            tmp = reshape(EEG.data(chan,:,:),1,[]);
            tmp = tmp - mean(tmp); % remove temporal mean
            chanhistos(chan,:) = hist(tmp,histocenters);
            [tmp,inds]= sort(squeeze(chanhistos(chan,:)));
            chanhistomax(chan) = histocenters(inds(end));
        end
        cnt_stats.histocenters{c} = histocenters;
        cnt_stats.chanhistos{c}   = chanhistos;
        cnt_stats.chanhistomax{c} = chanhistomax;
    end

    % subdivide concatenated data into consecutive "chunklength" chunks
    % and reorder them wrt gfp
    chunk_npts = chunk_length * EEG.srate;
    if (chunk_npts > size(data,2))
        errstr = sprintf('Chunk length of %d is too long for data of %d minutes\n', chunk_length, size(data,2)/EEG.srate);
        error(errstr);
    end
    chunk_gfp = [];
    for chunk = 1:floor(size(data,2)/chunk_npts)
        chunk_data = data(:,(chunk-1)*chunk_npts + (1:chunk_npts));
        % remove temporal mean
        chunk_data = chunk_data - repmat(squeeze(mean(chunk_data,2)),[1 chunk_npts]);
        chunk_gfp = [chunk_gfp sum(sum(chunk_data.^2))];
    end
    [sorted_chunk_gfp, indices] = sort(chunk_gfp);
    best_chunk = indices(1);

    % perform quick ica on the best chunk
    data = reshape(data,size(data,1),[]);
    data = data(:,(best_chunk-1)*chunk_npts + (1:chunk_npts));
     [weights,sphere] = binica(data,'pca',min(max(get_data_num_pca(data,variance_portion_quickICA),6),12));
    delete ('binica*'); 

    mix_matrix = weights * sphere;
    winv = pinv(mix_matrix);
    similarity = zeros(1,size(mix_matrix,1));
    %similarity = zeros(2,size(mix_matrix,1));
    
    for comp = 1:size(mix_matrix,1)
        tmp = corrcoef(winv(:,comp),mean_blink_winv(1:nchans));
        similarity(1,comp) = abs(tmp(1,2));
    end

    % find comps which are highly correlated with generic artifacts
    rejcomps = find(max(similarity,[],1)> corr_threshold);

    % record ica stats
    cnt_stats.mix_matrix = mix_matrix;
    cnt_stats.similarity = similarity;
    cnt_stats.rejcomps = rejcomps;
    save([outpath 'batch1_summary.mat'],'cnt_stats');
end

