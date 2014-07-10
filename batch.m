%Batch_Initialize;
%Batch_Initialize_LNF;
Batch_Initialize_EPOC;
diary;
diary([outdir 'logfile.txt']);
disp('Parameters are set');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% batch1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get stats for each continuous file to see if events are ok and if data is ok
% concatenate data from all cnt files
% select best 8min chunk from concatenated data
% perform quick ica and detect artifacts


batch1;
batch1_summary;
disp('batch1 is Done');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% batch2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% merge data, temporarily remove artifacts from batch1
% filter, epoch, reassign eventtypes and 
% reject trials where most kept ica are above threshold
% get stats on original and new num trials

          
batch2;
batch2_summary;
disp('batch2 is Done');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% batch3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load merged set
% perform  ica on 99% variance

batch3;
disp('batch3 is Done');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% batch4
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% let user view icas from batch3 and select those that should be rejected from all trials. The program then  selectively removes comps on trial-to-trial basis.Final clean data is then split into condition specific sets.
% define conditions and corresponding triggers-of-interest
sptool;
batch4;
disp('batch4 is Done');
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% batch5  - apply ICAs and save .set files by condition
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
batch5;
disp('batch5 is Done');
diary off;
