CEDfile=input(['Please enter the BODY of the .ced file name to be converted to .mat (i.e. 70channel)'], 's');
chanlocs=readlocs([CEDfile '.ced']);
save([CEDfile '.ced'], 'chanlocs');
formatSpec = '%s.ced converted to %s.mat';
fprintf(formatSpec,CEDfile,CEDfile);  