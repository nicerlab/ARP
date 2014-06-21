% number of channels here
numchans = 31;
mean_blink_winv = zeros(numchans,1);
% put directory containing S1.set, S2.set, etc files here:
cd('C:\LNF_DATA\M1024\');

bcomps = [ 1 1 1 2 1];
for i=1:5
    EEG = pop_loadset(['S' num2str(i) '.set'],'.\');
    winv = pinv(EEG.icaweights * EEG.icasphere);
    mean_blink_winv = mean_blink_winv + winv(:,bcomps(i));
end
mean_blink_winv = mean_blink_winv / 5;

%modify to contain the path and file name of your generic eyeblicks file.
save('C:\LNF_DATA\M1024\bv_generic_eyeartifacts.mat','mean_blink_winv');
