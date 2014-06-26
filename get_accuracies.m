%% Get Condition-Specific accuracies

% subjects = {'2750','3007','3733','3774','4267','9999','4701','2400','2406','4193','4829','4268','2984','2825','2084','4233','2722','4709','4524','3792','3670'};
% subjekts = [2750 3007 3733 3774 4267 9999 4701 2400 2406 4193 4829 4268 2984 2825 2084 4233 2722 4709 4524 3792 3670];
subjects = {'2750','3007','3733','4267','9999','4701','2406','4193','4829','4268','4233','2722','4709','4524','3792'};
subjekts = [2750 3007 3733 4267 9999 4701 2406 4193 4829 4268 4233 2722 4709 4524 3792];

outdir = '/rri_disks/parthenope/mcintosh_lab/bratislav/Contrast_Sensitivity/Artifact_removal_results/';% output directory

% % all the .SET files from which to extract data
merged_conditions = {{'B_10_1'}, {'B_10_2'}, {'B_20_1'}, {'B_20_2'},...
             {'IC_10_1'}, {'IC_10_2'}, {'IC_10_3'}, {'IC_20_1'}, {'IC_20_2'}, {'IC_20_3'},...
             {'VC_10_1'}, {'VC_10_2'}, {'VC_20_3'}};

% each row is a grouping of files that you will merge in one single
% 'condition'
% merged_conditions = {{'B_10_1', 'B_10_2', 'B_20_1', 'B_20_2'},...
%                     {'IC_10_1', 'IC_10_2','IC_20_1', 'IC_20_2'},...
%                     {'VC_10_1', 'VC_10_2'}};
                
%  merged_conditions = {{'B_10_2', 'B_20_2'},...
%                     {'IC_10_2','IC_20_2'},...
%                     {'VC_10_2'}};

% these are the names of those merged conditions
merged_names = {'B_10_1', 'B_10_2', 'B_20_1', 'B_20_2',...
             'IC_10_1', 'IC_10_2', 'IC_10_3','IC_20_1', 'IC_20_2', 'IC_20_3',...
             'VC_10_1', 'VC_10_2','VC_20_3'}; 

% first, empty out both vectors
total_accuracy = [];
total_RT = [];
for s=1:numel(subjects)
    subj = subjects{s};
    outpath = [outdir subj '/'];
    condition_accuracy = [];
    condition_RT = [];
    
    for c=1:numel(merged_conditions)
        cond_name = merged_names{c};
        
        condition_correct = 0;
        condition_trials = 0;
        sum_RT = 0;
        trial_RT = 0;
        
        for j=1:numel(merged_conditions{c})
            
            EEG = pop_loadset([merged_conditions{c}{j} '.set'], outpath);
            numcorrect = 0;
            for jj=1:length(EEG.epoch)
                trial_RT = EEG.epoch(jj).resp_struct.rt;
                if ( strcmp(EEG.epoch(jj).resp_struct.response, 'correct') == 1)
                    sum_RT = sum_RT + trial_RT;        
                    numcorrect = numcorrect + 1;
                end
            end

      
        condition_correct = condition_correct + numcorrect;
        condition_trials = condition_trials + length(EEG.epoch);
        end

        condition_accuracy = [condition_accuracy condition_correct/condition_trials];
        condition_RT = [condition_RT sum_RT/condition_trials];
      
    end
  total_RT = [total_RT; subjekts(s) condition_RT] ;
  total_accuracy = [total_accuracy; subjekts(s) condition_accuracy];

end

total_accuracy = sortrows(total_accuracy); % sort according to subject ID

total_accuracy = total_accuracy(:,2:(numel(merged_conditions)+1));    % remove subject ID from matrix
total_RT = sortrows(total_RT);
total_RT = total_RT(:,2:(numel(merged_conditions)+1));
% note - if you're not interested in doing behavPLS, but just want a table
% of behavioral data, just add a line here to save the total_acc/total_RT

    % z-score each for each column (i.e. each condition) separately
    for c=1:numel(merged_conditions)
        total_accuracy(:,c) = (total_accuracy(:,c) - mean(total_accuracy(:,c))) / std(total_accuracy(:,c));
        total_RT(:,c) = (total_RT(:,c) - mean(total_RT(:,c))) / std(total_RT(:,c));
    end    

    % stack the condition-specific columns on top of each other, so that
    % they can be inputted into behavioral PLS in the preferred
    % subjects-within-conditions format
total_accuracy = reshape(total_accuracy,(numel(subjects)*numel(merged_conditions)),1);   
total_RT = reshape(total_RT,(numel(subjects)*numel(merged_conditions)),1);    

save([outdir 'basic_cond_RT.txt'],'total_RT','-ascii');
save([outdir 'basic_cond_accuracy.txt'],'total_accuracy','-ascii');



% NOTE - THE ORDER OF THE SUBJECTS NEEDS TO BE THE SAME AS IN THE PLS
% DATAMAT FILE
        