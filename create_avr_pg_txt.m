% Create grand-averages in ASCII format so they can be inputted into BESA


subjects = {'2750','3007','3733','3774','4267','9999','4701','2400','2406','4193','4829','4268','2984','2825','2084','4233','2722','4709','4524','3792','3670'};

outdir = '/rri_disks/parthenope/mcintosh_lab/bratislav/Contrast_Sensitivity/Artifact_removal_results/'; % output directory
newpath = '/rri_disks/parthenope/mcintosh_lab/bratislav/Contrast_Sensitivity/subject_averages_pg';

merged_names ={'B_10_1', 'B_10_2', 'B_20_1', 'B_20_2',...
             'IC_10_1', 'IC_10_2', 'IC_10_3','IC_20_1', 'IC_20_2', 'IC_20_3',...
             'VC_10_1', 'VC_10_2','VC_20_3'};

for s=1:numel(subjects)
  subj = subjects{s}; 
  outpath = [outdir subj '/']; 
  for c=1:numel(merged_names)
    cond_name = merged_names{c};

      subj_avg = load([outpath merged_names{c} '_pg.txt']);
%       subj_avg = subj_avg'; % can change depennding on the format of data
%       file (BESA requires chan X timepoints)
      
      % open a writable .avr file
      fid = fopen([newpath subj  '_' cond_name '.avr'],'w');
      % first line of header for BESA
      fprintf(fid, '%s \n', ['Npts= 233  TSB= -200.0  DI= 3.9  SB= 2.000  SC= 50 Nchan= 76']);

      % CHECK THAT THE NO. OF TIMEPOINTS SPECIFIED IN THE HEADER IS
      % ACTUALLY EQUAL TO THE NO. OF TIMEPOINTS IN THE DATA
      
      % second line of header for BESA
      fprintf(fid, '%s \n', ['Fp1 AF7 AF3 F1 F3 F5 F7 FT7 FC5 FC3 FC1 C1 C3 C5 T7 TP7 CP5 CP3 CP1 P1 P3 P5 P7 P9 PO7 PO3 O1 Iz Oz POz Pz CPz Fpz Fp2 AF8 AF4 Afz Fz F2 F4 F6 F8 FT8 FC6 FC4 FC2 FCz Cz C2 C4 C6 T8 TP8 CP6 CP4 CP2 P2 P4 P6 P8 P10 PO8 PO4 O2 CB1 CB2 TP9 TP10 FT9 FT10 F9 F10 LO1 LO2 IO1 IO2']);
      % add data line by line
      for k=1:size(subj_avg,1)
        fprintf(fid, '%12.8f', squeeze(subj_avg(k,:)));
        fprintf(fid, '\n');
      end
      fclose(fid);
    end
end

