
%% display channel locations
figure; 

topoplot([],chanlocs, 'style', 'blank', 'electrodes', 'numpoint','efontsize',10,'electcolor','k','emarkersize',12,'hcolor','c');

%% visualize event stats from cnt files
for s=1:numel(subjects)
    subj = subjects{s};
    outpath = [outdir subj '\'];
    load([outpath 'batch1_summary.mat']);
    num_cnt_files = numel(cnt_stats.cntfnames);

    % display eventypes present in this cnt, and their corresponding frequencies
    disp([subj ' unique event types and their freqs: ']);

    for c = 1:num_cnt_files
        disp([cnt_stats.cntfnames{c} ':']);
        disp(['    srate: ' num2str(cnt_stats.srate{c})]);
        disp(['    time: ' num2str(cnt_stats.time{c})]);
        disp(['    nbchan: ' num2str(cnt_stats.nbchan{c})]);
        clear tmp;
        tmp(1,:) = cnt_stats.eventtypes{c};
        tmp(2,:) = cnt_stats.eventfreqs{c};
        disp(num2str(tmp));
    end
    close all;
end

%% visualize channel histograms
for s=1:numel(subjects)
    subj = subjects{s};
    outpath = [outdir subj '\'];
    load([outpath 'batch1_summary.mat']);
    num_cnt_files = numel(cnt_stats.cntfnames);
    % display chan histos - and indicate possible bad channels
    hh=figure('Name',subj,'position',[1000 717 554 204],'color',[1 1 1]);
    dim = ceil(num_cnt_files/4);
    for c = 1:num_cnt_files
        subplot(dim,4,c);
        bar(cnt_stats.chanhistomax{c});
        set(gca,'ylim',[-100 100],'xlim',[0 cnt_stats.nbchan{c}+1]);
        title(cnt_stats.cntfnames{c},'interpreter','none');
        axcopy(gcf);
    end
    set(hh,'position',[1000 717 554 204],'color',[1 1 1]);
    close all;
end

%% visualize ica and automatically detected ocular artifacts

%%% determine max num of comps across subjects
max_num_comps = 0;
for s=1:numel(subjects)
    subj = subjects{s};
    outpath = [outdir subj '\'];
    load([outpath 'batch1_summary.mat']);
    if(size(cnt_stats.mix_matrix,1) > max_num_comps)
        max_num_comps = size(cnt_stats.mix_matrix,1);
    end
end

%h=figure;
for s=1:numel(subjects)
    subj = subjects{s};
    outpath = [outdir subj '\'];
    load([outpath 'batch1_summary.mat']);
    winv = pinv(cnt_stats.mix_matrix);
    h=figure('Name',subj);
    %dim = ceil(sqrt(size(cnt_stats.mix_matrix,1)));
    for comp=1:size(cnt_stats.mix_matrix,1)
        subplot(s,max_num_comps,(s-1)*max_num_comps+comp);
        subplot(1,max_num_comps,comp);
        topoplot(winv(:,comp),chanlocs,'electrodes','off','numcontour',0);
        col = 'k'; if(ismember(comp,cnt_stats.rejcomps)), col = 'r'; end;
        simil = round(cnt_stats.similarity(comp) * 100)/100;
        simil_str = num2str(simil);
        title([simil_str([1:min(4,end)])],'color',col);
        if comp==1, ylabel(subj,'rotation',0,'visible','on'); end
        axcopy(gcf);
    end
    set(h,'Position',[1000 603 762 108],'color',[1 1 1]);
end
%set(h,'Position',[50 50 1000 1000],'color',[1 1 1]);
