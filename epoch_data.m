function eeg = epoch_data(fname,relevant_events,correct_responses,stims,epoch_limits,baseline)
% This function performs several preprocessing operations:
% load  raw bdf file
% notch filter continuous data at 60Hz,
% epoch data according to toi(triggers of interest)
% load electrode loactions file (elp_fname)
% rereference continuous data to average reference (store in Cz=chan 65),
% epoch data according to  stimuli of interest
% and finally remove baseline from all epochs
% INPUTS:
%        fname - full path filename of the continous eeg data file
%        relevant_events - event numbers that are relevant, erase all others
%        cues - cues preceeding stimuli
%        stims - stimuli to time lock to
%        epoch_limits - epoch timelimits in secs , e.g. [-1 2]
%        baseline - baseline timelimits in secs, e.g. [-1 0]
% OUTPUT:
%        eeg - rereferenced, resampled, epoched, baselined data set (eeglab format)

eeg = pop_biosig(fname);  %,'ref',28);
eeg = eeg_checkset(eeg); eeg.data = double(eeg.data);
%eeg = pop_select(eeg,'channel',[1:76] );
eeg = pop_select(eeg,'channel',[1:69] );
eeg = eeg_checkset(eeg); eeg.data = double(eeg.data);
%eeg = pop_chanedit(eeg,  'load',{ '/rri_disks/arrakis/mcintosh_lab/natasa/Biosemi_76.elp', 'filetype', 'besa'});
eeg = pop_chanedit(eeg,  'load',{ 'C:\NICERLAB\Artifact_removal_code\70channel.elp', 'filetype', 'besa'});
eeg = pop_reref(eeg,[],'refstate',69);
eeg = eeg_checkset(eeg); eeg.data = double(eeg.data);

% $$$     % notch filter at 60Hz
% $$$     eeg.data = eegfilt(eeg.data,eeg.srate,57,63,0,30,1);

% mark irelevant events that should be deleted
clear events; delete_events = [];
for ev = 1:numel(eeg.event)
    tmp = eeg.event(ev).type;
    if ischar(tmp),
        events(ev) = str2num(tmp);
    else
        events(ev) = tmp;
    end
    if ~ismember(events(ev),relevant_events), delete_events = [delete_events ev];end
end
% delete irelevant events
eeg = pop_editeventvals(eeg,'delete',delete_events);
eeg = eeg_checkset(eeg); eeg.data = double(eeg.data);

% get array of events as array of doubles

evts=zeros(1,numel(eeg.event));
for ev = 1:numel(eeg.event)
    tmp = eeg.event(ev).type;
    if ischar(tmp),
        evts(ev) = str2num(tmp);
    else
        evts(ev) = tmp;
    end
end

% epoch data
good_events =[];
for ev = 1:(numel(evts)-1)
    if ismember(evts(ev),stims) &  ismember(evts(ev+1),correct_responses),
        good_events = [good_events ev];
    end
end

% now extract epochs which are timelocked to good_events
eeg = pop_epoch(eeg,{},epoch_limits,'eventindices',good_events, 'epochinfo', 'yes');
eeg = eeg_checkset(eeg); eeg.data = double(eeg.data);


% remove baseline
baseline_pts = 1:round((baseline(2)-baseline(1))*eeg.srate);
eeg = pop_rmbase(eeg, baseline, baseline_pts);
eeg = eeg_checkset(eeg); eeg.data = double(eeg.data);

