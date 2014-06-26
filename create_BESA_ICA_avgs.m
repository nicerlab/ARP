% modify EEGLAB2LORETA output files (with ICA topomap 'activations' to BESA .avr format

for n=1:9
    comp = load(['comp' num2str(n) '.txt']);
    comp = comp';

fid = fopen(['comp' num2str(n) '.avr'],'w');
fprintf(fid, '%s \n', ['Npts= 10  TSB= -195.0  DI= 3.9  SB= 2.000  SC= 50 Nchan= 76']);
fprintf(fid, '%s \n', ['Fp1 AF7 AF3 F1 F3 F5 F7 FT7 FC5 FC3 FC1 C1 C3 C5 T7 TP7 CP5 CP3 CP1 P1 P3 P5 P7 P9 PO7 PO3 O1 Iz Oz POz Pz CPz Fpz Fp2 AF8 AF4 Afz Fz F2 F4 F6 F8 FT8 FC6 FC4 FC2 FCz Cz C2 C4 C6 T8 TP8 CP6 CP4 CP2 P2 P4 P6 P8 P10 PO8 PO4 O2 CB1 CB2 TP9 TP10 FT9 FT10 F9 F10 LO1 LO2 IO1 IO2']);
      % add data line by line

for k=1:size(comp,1)
        fprintf(fid, '%12.8f', comp(k,:));
        fprintf(fid, '\n');
      end
      fclose(fid);
      
end