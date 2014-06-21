% Create grand-averages in ASCII format so they can be inputted into BESA


subjects = {'ZXSN13','ZXSN14','ZXSN46','ZXSN52','ZXSN0107','ZXSN0110','ZXSN116','ZXSN0119','ZXSN119','ZXSN138','ZXSN0208','ZXSN232','ZXSN0319','ZXSN0406','ZXSN0407','ZXSN0416','ZXSN0419','ZXSN482','ZXSN0502','ZXSN0611','ZXSN719','ZXSN1002','ZXSN1003','ZXSN1007','ZXSN1007B','ZXSN1012','ZXSN1103','ZXSN1313','ZXSN1313B','ZXSN1318','ZXSN1319','ZXSN1323','ZXSN1411x','ZXSN1416','ZXSN1501','ZXSN1515','ZXSN1810','ZXSN1819','ZXSN1913','ZXSN1926','ZXSN2002','ZXSN2010','ZXSN2013','ZXSN2109','ZXSN2219','ZXSN2301','ZXSN2316','ZXSN2508'};

outdir = 'C:\Patricia\CARLETON\EXPERIMENTS\LED\2_PROCESSED_DATA\4_ERP\CNT_NEWEV2S\Results\';% output directory
newpath = 'C:\Patricia\CARLETON\EXPERIMENTS\LED\2_PROCESSED_DATA\4_ERP\CNT_NEWEV2S\Results\Subject_averages\';
merged_names = {'SCCong','SWCong','SCIncong','SWIncong'};



for s=1:numel(subjects)
  subj = subjects{s}; 
  outpath = [outdir subj '\']; 
  for c=1:numel(merged_names)
    cond_name = merged_names{c};

      subj_avg = load([outpath merged_names{c} '.txt']);
%       subj_avg = subj_avg'; 
      
      fid = fopen([newpath subj  '_' cond_name '.avr'],'w');
      fprintf(fid, '%s \n', ['Npts= 2400   TSB= -200.000 DI= 0.500000 SB= 1.000 SC= 200.0 Nchan= 68']);
%       fprintf(fid, '\n');
      fprintf(fid, '%s \n', ['FP1 FPz FP2 AF3 AF4 F7 F5 F3 F1 Fz F2 F4 F6 F8 FT7 FC5 FC3 FC1 FCz FC2 FC4 FC6 FT8 T7 C5 C3 C1 Cz C2 C4 C6 T8 TP9 TP7 CP5 CP3 CP1 CPz CP2 CP4 CP6 TP8 TP10 P7 P5 P3 P1 Pz P2 P4 P6 P8 PO7 PO5 PO3 POz PO4 PO6 PO8 CB1 O1 Oz O2 CB2 LO2 IO1 LO1 IO2 REF']);
      for k=1:size(subj_avg,1)
        fprintf(fid, '%12.8f', squeeze(subj_avg(k,:)));
        fprintf(fid, '\n');
      end
      fclose(fid);
    end
end

 %      subj_avg = ['Npts= 500' 'TSB= -200' 'DI= 3.9' 'SB= 2' 'SC= 50' 'Nchan= 76'; 'Fp1'	'AF7'	'AF3'	'F1'	'F3'	'F5'	'F7'	'FT7'	'FC5'	'FC3'	'FC1'	'C1'	'C3'	'C5'	'T7'	'TP7'	'CP5'	'CP3'	'CP1'	'P1'	'P3'	'P5'	'P7'	'P9'	'PO7'	'PO3'	'O1'	'Iz'	'Oz'	'POz'	'Pz'	'CPz'	'Fpz'	'Fp2'	'AF8'	'AF4'	'Afz'	'Fz'	'F2'	'F4'	'F6'	'F8'	'FT8'	'FC6'	'FC4'	'FC2'	'FCz'	'Cz'	'C2'	'C4'	'C6'	'T8'	'TP8'	'CP6'	'CP4'	'CP2'	'P2'	'P4'	'P6'	'P8'	'P10'	'PO8'	'PO4'	'O2'	'CB1'	'FT10'	'F9'	'LO2'	'TP10'	'IO1'	'TP9'	'IO2'	'FT9'	'F10'	'CB2'	'LO1'; subj_avg];
       

%     save([newpath subj '_' cond_name '.avr'],'subj_avg','-ascii');
%     dlmwrite([newpath subj '_' cond_name '.avr'],subj_avg,'delimiter','\t','precision','%.6f');
%  end
%end