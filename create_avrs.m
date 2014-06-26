% Calculate subject/conditions specific averages and save them in avr
% format
% "merged_conditions" sets are input and averaged
Batch_Initialize;

for s=1:numel(subjects)
    subj = subjects{s};
    outpath = [outdir subj '\'];
    for c=1:numel(merged_conditions)
        cond_name = merged_names{c};
        clear data;
        for j=1:numel(merged_conditions{c})
            EEG = pop_loadset([merged_conditions{c}{j} '.set'], outpath);
            EEG.chanlocs = chanlocs;
            individual_data = double(EEG.data);
           % reshape the data into a 2D array so we can append different
           % data sets with different numbers of trials
            if ~exist('data','var')
                data = reshape(individual_data,[],EEG.trials);
            else
                data = [data reshape(individual_data,[],EEG.trials)];
            end
           
            % average the individual condition
            indiv_avg = squeeze(mean(individual_data,3));%(chan time)
            % Output each individual condition 
            fid = fopen([outpath merged_conditions{c}{j} '.avr'],'w');
            % Npts - based on size of epoch and frequency  (i.e. 2400 for 2.4 seconds at 1Hz)
            % TSB - start of baseline (prior to stimulus) in ms (i.e. -200)
            % DI - Digitization Interval = Analog digital rate - EPOCH/sampling rate
            % SB - scaling bins - leave at 1
            % SC - scaling calibration- to set intial value in BESA to make easier to visualize on import
            % Nchan = number of channels used
            fprintf(fid,'Npts= %d TSB= %d  DI= %d  SB= 1.000  SC= 200 Nchan= %d\n',EEG.pnts, EEG.xmin*100, EEG.pnts/EEG.srate, nchans);
            for chan=1:size(indiv_avg,1)
                fprintf(fid, '%s ', EEG.chanlocs(chan).labels);
            end
            fprintf(fid, '\n');
            %for chan=1:size(indiv_avg,1)
            %    fprintf(fid, '%12.8f', squeeze(indiv_avg(chan,:)));
            %    fprintf(fid, '\n');
            %end
            for row=1:size(indiv_avg,2)
                fprintf(fid, '%12.8f', squeeze(indiv_avg(:,row)));
                fprintf(fid, '\n');
            end
            fclose(fid);
        end
        
        %Only execute this section if you want to merge conditions
        %(i.e. the number of conditions in the current group > 1)
        
        if numel(merged_conditions{c}) > 1
            subj_avg = squeeze(mean(reshape(data,EEG.nbchan,size(individual_data,2),[]),3));%(chan time)
             %subj_avg = eegfilt(subj_avg,EEG.srate,0,20,0,60,0);% lowpass at 20Hz
       
            fid = fopen([outpath cond_name '.avr'],'w');
            fprintf(fid,'Npts= %d TSB= %d  DI= %d  SB= 1.000  SC= 200 Nchan= %d\n',EEG.pnts, EEG.xmin*100, EEG.pnts/EEG.srate, nchans);
            for chan=1:size(subj_avg,1)
                fprintf(fid, '%s ', EEG.chanlocs(chan).labels);
            end
            fprintf(fid, '\n');
            %fprintf(fid, '%s \n', ['Fp1 AF7 AF3 F1 F3 F5 F7 FT7 FC5 FC3 FC1 C1 C3 C5 T7 TP7 CP5 CP3 CP1 P1 P3 P5 P7 P9 PO7 PO3 O1 Iz Oz POz Pz CPz Fpz Fp2 AF8 AF4 Afz Fz F2 F4 F6 F8 FT8 FC6 FC4 FC2 FCz Cz C2 C4 C6 T8 TP8 CP6 CP4 CP2 P2 P4 P6 P8 P10 PO8 PO4 O2 CB1 CB2 TP9 TP10 FT9 FT10 F9 F10 LO1 LO2 IO1 IO2']);
            % add data line by line
            for row=1:size(subj_avg,2)
                fprintf(fid, '%12.8f', squeeze(subj_avg(:,row)));
                fprintf(fid, '\n');
            end
            fclose(fid);
            disp(sprintf('Average file %s produced\n',[outpath cond_name '.avr']));
        end

    end
end

