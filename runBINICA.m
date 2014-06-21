[wts,sph] = binica(EEG.data(:,:), 'extended', 1);
EEG.icaweights = wts;
EEG.icasphere = sph;
EEG = eeg_checkset(EEG, 'ica');
eeglab redraw