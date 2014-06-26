%  create generic eye artefacts file

num_chans = 32;  % put number of channels here.
% run quick ICA on 5 subjects. Save subject data to .set files
% identify one blink componet for each  - save the component numbers in
% bcomps:
bcomps = [ 1 1 2 1 1];
mean_blink_winv = zeros(num_chans,1);
for i=1:5
    eeg= pop_loadset(['S' num2str(i) '.set'],'./');  % load the .set file from each subject
    winv = pinv(eeg.icaweights * eeg.icasphere);
    mean_blink_winv = mean_blink_winv + winv(:,bcomps(i));
end
mean_blink_winv = mean_blink_winv / 5;
save([outpath 'generic_eye_artefacts.mat'],'mean_blink_winv');

