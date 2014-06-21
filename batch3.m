for s=1:numel(subjects)
  subj = subjects{s};
  outpath = [outdir subj '/']; 
  
  EEG = pop_loadset([subj '_merged.set'], outpath);
  EEG = eeg_checkset(EEG);
  data = reshape(double(EEG.data),EEG.nbchan,[]);
  clear EEG;
  
  % run ica 
  [weights,sphere] = binica(data,'pca',min(max(get_data_num_pca(data,variance_portion_pca),20),35),'extended',1);
% $$$   % run full ica
% $$$   data = reshape(double(EEG.data),EEG.nbchan,[]);
% $$$   [weights,sphere] = binica(data, 'extended',1);
  save([outpath 'ica.mat'],'weights','sphere','-mat','-V6');
  %system(['rm binica*']);
  delete 'binica*';
end
