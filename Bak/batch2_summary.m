% visualize number of trials per condition after batch2

%% display total num of trials per subject, 
%  before and after automatic trial removal
for s=1:numel(subjects)
   subj = subjects{s};
   outpath = [outdir subj '\']; 
   load([outpath 'batch2_summary.mat']);
   disp([subj '  ' num2str(trial_stats.orig_num_trials) '  ' num2str(trial_stats.new_num_trials)]);
end

%% display number of trials per condition

figure;
%dim = ceil(sqrt(numel(subjects)));
dim = ceil(sqrt(numel(subjects)));
for s=1:numel(subjects)
  subj = subjects{s};
  outpath = [outdir subj '\']; 
  load([outpath 'batch2_summary.mat']);
  subplot(dim,dim,s,'align');
  bar(trial_stats.trial_count);
  set(gca,'xlim',[0 numel(trial_stats.trial_count)+1],'xtick',[1:numel(relevant_events)],'xticklabel',conditions,'ylim',[0 max(trial_stats.trial_count)+5]);
  %set(gca,'xlim',[0 numel(trial_stats.trial_count)+1],'xtick',[],'ylim',[0 80]);
  title(subj);
  axcopy(gcf);
end
