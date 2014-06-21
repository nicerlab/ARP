% User makes quick  decisions about component rejection
Batch_Initialize;
subjects
subj = input(['Enter subject: '],'s');
if ~ismember(subj, subjects)
  error('Subject name not allowed ');
end

outpath = [outdir subj '\'];
load([outpath 'batch2_summary.mat']);
% load merged set from batch2 and ica decomposition from batch3 and attach to EEG
EEG = pop_loadset([subj '_merged.set'], outpath);
load([outpath 'ica.mat']);
EEG.icasphere = sphere;
EEG.icaweights = weights;
EEG.icawinv = pinv(weights * sphere);

%Jila's new code for icaact
mix_matrix = weights * sphere;
icaact = mix_matrix * reshape(EEG.data,EEG.nbchan,[]);
num_comps = size(icaact,1);
icaact = reshape(icaact,num_comps,EEG.pnts,[]);

EEG = eeg_checkset(EEG);

% plot component data
eegplot(icaact,'srate',EEG.srate,'spacing',5,'limits',epoch_limits*1000,'winlength',10,'ploteventdur','off','submean','off', 'title', 'EEG Component Plot');
% plot electrode data
eegplot(EEG.data,'srate',EEG.srate,'spacing',60,'limits',epoch_limits*1000,'winlength',10,'ploteventdur','off','submean','off', 'title', 'Raw EEG Electrode Data');

% user selects components for rejection
EEG.chanlocs = chanlocs;
EEG = pop_selectcomps(EEG, [1:size(icaact,1)]);

disp('Please review components in windows provided. When you have identified the component numbers to remove, type "return" and press <enter> to continue to final component removal');

keyboard;

% find out which components user rejected from all trials
rejcomps = find(EEG.reject.gcompreject > 0);
disp(['rejected components so far ' num2str(rejcomps)]);

disp('Enter any additional components (by number) that');
disp('should be removed from the entire dataset, ensuring');
disp('that there are spaces between each number, and the set');
addrejcomps = input('is enclosed in square brackets i.e. "[1 5 9]": ');
rejcomps = union(addrejcomps, rejcomps);
disp(sprintf('Final rejected components %d\n',rejcomps));

disp('Enter component numbers that are just EYE BLINKS');
libeyeblink = input('enclosed in square brackets, i.e. "[1 5 9]":  ');
disp(sprintf('Commiting components %d to the library of EYEBLINK artifacts\n',libeyeblink));

disp('Enter component numbers that are just SACCADES');
libsaccade = input('enclosed in square brackets, i.e. "[1 5 9]":  ');
disp(sprintf('Commiting components %d to the library of SACCADE Arifacts\n',libsaccade));

% save rejcomps and eye components (library of eye components not yet used,
% but maybe later can be used to build a global library of eye components that can be applied generically.)
save([outpath 'ica_rejcomps.txt'],'rejcomps','-ascii');
save([outpath 'ica_blinkcomps.txt'],'libeyeblink','-ascii');
save([outpath 'ica_saccadecomps.txt'],'libsaccade','-ascii');

close all;
