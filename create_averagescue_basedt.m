subjects = {'2750','3007','3733','3774','4267','9999','4701','2400','2406','4193','4829','4268','2984','2825','2084','4233','2722','4709','4524','3792','3670'};
outdir = '/rri_disks/parthenope/mcintosh_lab/bratislav/Contrast_Sensitivity/Artifact_removal_results/';% output directory

% conditions ={'B_10_1', 'B_10_2', 'B_20_1', 'B_20_2',...
%              'IC_10_1', 'IC_10_2', 'IC_10_3','IC_20_1', 'IC_20_2', 'IC_20_3',...
%              'VC_10_1', 'VC_10_2','VC_20_3'};
% 
% merged_conditions = {{'B_10_1', 'B_10_2', 'B_20_1', 'B_20_2'},...
%                     {'IC_10_1', 'IC_10_2','IC_20_1', 'IC_20_2'},...
%                     {'VC_10_1', 'VC_10_2'}};
% merged_names = {'B_Low','IC_Low','VC_Low'};

conditions ={'B_10_1', 'B_10_2', 'B_20_1', 'B_20_2',...
             'IC_10_1', 'IC_10_2', 'IC_10_3','IC_20_1', 'IC_20_2', 'IC_20_3',...
             'VC_10_1', 'VC_10_2','VC_20_3'};

merged_conditions = {{'B_10_1','B_10_2'},...
                    {'B_20_1','B_20_2'},...
                    {'IC_10_1','IC_10_2','IC_10_3'},...
                    {'IC_20_1','IC_20_2','IC_20_3'},...
                    {'VC_10_1','VC_10_2'},...
                    {'VC_20_3'}};
merged_names = {'B_plus_all','B_letterH_all','IC_plus_all','IC_letterH_all','VC_plus_all','VC_letterH_all'};

for s=1:numel(subjects)
  subj = subjects{s}; 
  outpath = [outdir subj '/']; 
  for c=1:numel(merged_conditions)
    cond_name = merged_names{c};
    clear data;
    for j=1:numel(merged_conditions{c})
       eeg = pop_loadset([merged_conditions{c}{j} '.set'], outpath);
       eeg = eeg_checkset(eeg);
       tmpdata = double(eeg.data(:,1:500,:)); %restrict to times [-200 1750]ms
       if ~exist('data','var')         
         data = reshape(tmpdata,[],eeg.trials);
       else
         data = [data reshape(tmpdata,[],eeg.trials)];
       end
    end
    subj_avg = squeeze(mean(reshape(data,eeg.nbchan,size(tmpdata,2),[]),3));%(chan time)
    subj_avg = eegfilt(subj_avg,eeg.srate,0,20,0,60,0);% lowpass at 20Hz
    save([outpath cond_name '.txt'],'subj_avg','-ascii');
  end
end