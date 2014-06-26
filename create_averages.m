% create .TXT averages for PLS
% also for resampling, filtering, re-baseline, time-locking to a different
% event, etc.

%subjects = {'ZXSN52','ZXSN0107','ZXSN0110','ZXSN116','ZXSN0208','ZXSN232','ZXSN0319','ZXSN0406','ZXSN0407','ZXSN0416','ZXSN0419','ZXSN482','ZXSN0502','ZXSN1002','ZXSN1007B','ZXSN1012','ZXSN1103','ZXSN1313','ZXSN1313B','ZXSN1318','ZXSN1319','ZXSN1323','ZXSN1411x','ZXSN1501','ZXSN1515',,'ZXSN1913','ZXSN1926','ZXSN2002','ZXSN2010','ZXSN2013','ZXSN2109','ZXSN2219','ZXSN2301','ZXSN2508'};
subjects = {'ZXSN1323'};
outdir = 'C:\NICERLAB\Sample_data\Results\';

% conditions ={'B_10_1', 'B_10_2', 'B_20_1', 'B_20_2',...
%              'IC_10_1', 'IC_10_2', 'IC_10_3','IC_20_1', 'IC_20_2', 'IC_20_3',...
%              'VC_10_1', 'VC_10_2','VC_20_3'};
% 
% merged_conditions = {{'B_10_1', 'B_10_2', 'B_20_1', 'B_20_2'},...
%                     {'IC_10_1', 'IC_10_2','IC_20_1', 'IC_20_2'},...
%                     {'VC_10_1', 'VC_10_2'}};
% merged_names = {'B_Low','IC_Low','VC_Low'};

conditions ={'SC_RCon','SC_BCon','SC_GCon', 'SC_YCon','SW_RCon', 'SW_BCon', 'SW_GCon', 'SW_YCon', 'SC_RInconB', 'SC_RInconG', 'SC_RInconY', 'SC_BInconR', 'SC_BInconG', 'SC_BInconY', 'SC_GInconR', 'SC_GInconB', 'SC_GInconY', 'SC_YInconR', 'SC_YInconB', 'SC_YInconG','SW_RInconB','SW_RInconG','SW_RInconY', 'SW_BInconR', 'SW_BInconG', 'SW_BInconY', 'SW_GInconR','SW_GInconB', 'SW_GInconY', 'SW_YInconR', 'SW_YInconB', 'SW_YInconG'};

%merged_conditions = {{'SC_RCon','SC_BCon','SC_GCon','SC_YCon'},{'SW_RCon', 'SW_BCon', 'SW_GCon', 'SW_YCon'}};
merged_conditions = {'SC_RConC','SC_BConC','SC_GConC', 'SC_YConC'};
merged_names = {'SCCong','SWCong','SCIncong','SWIncong'};

%%%%%%%%%%% this portion of code if you just want to create averages, with
%%%%%%%%%%% the data time-locked as is
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


%%%%%%%% this portion of code if you want to time lock to a different event
%%%%%%%% so you select a subset of time points, re-baseline and then create
%%%%%%%% the average
%merged_conditions = {{'B_10_2', 'B_20_2'},...
%                    {'IC_10_2','IC_20_2'},...
%                    {'VC_10_2'}};
%merged_names = {'B_Low2','IC_Low2','VC_Low2'};

%for s=1:numel(subjects)
  subj = subjects{s}; 
  outpath = [outdir subj '/']; 
  %for c=1:numel(merged_conditions)
    cond_name = merged_names{c};
    clear data;
   % for j=1:numel(merged_conditions{c})
       eeg = pop_loadset([merged_conditions{c}{j} '.set'], outpath);
       eeg = eeg_checkset(eeg);
       
       tmpdata = double(eeg.data(:,268:500,:)); % length of new epoch, in time points from original epoch(including the baseline)
       % NB. make sure to include the timepoints that will be the baseline
       % of the new epoch (and keep in mind that the original timepoints
       % ALSO include a baseline)
       
       % re-baseline
       tmpdata = tmpdata - repmat(mean(tmpdata(:,1:51,:),2),[1 size(tmpdata,2) 1]); % length of baseline period, in time points in new epoch
       
% $$$        % equvalently
% $$$        for chan=1:size(tmpdata,1)
% $$$          for trial=1:size(tmpdata,3)
% $$$            for time=1:size(tmpdata,2)
% $$$            tmpdata(chan,time,trial) = tmpdata(chan,time,trial)- mean(tmpdata(chan,1:50,trial));
% $$$            end
% $$$          end
% $$$        end
       
       if ~exist('data','var')         
         data = reshape(tmpdata,[],eeg.trials);
       else
         data = [data reshape(tmpdata,[],eeg.trials)];
       end
%    end
    subj_avg = squeeze(mean(reshape(data,eeg.nbchan,size(tmpdata,2),[]),3));%(chan time)
    subj_avg = eegfilt(subj_avg,eeg.srate,0,20,0,60,0);% lowpass at 20Hz, notch at 60Hz
    %save([outpath cond_name '_pg.txt'],'subj_avg','-ascii');
%  end
%end
