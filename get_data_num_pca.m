function num_pca = get_data_num_pca(data, variance_portion)
  
  % data must be in (chan time) format
  % Determine minimal number of pca comps that is necessary to account
  % for variance_portion of the variance
    if numel(size(data)) > 2
      error('get_data_num_pca.m','data must be in 2D format (chan time)');
    end
    num_chan = size(data,1);
    [pc,eigvec,sv] = runpca(data);
    sv = diag(sv); sv2 = sv.^2;  norm_sv = sum(sv2);
    for comp=1:num_chan, var(comp)=sum(sv2(1:comp))/norm_sv; end;
    %num_pca = max(find(var < variance_portion)) + 1;
    num_pca = min(find(var>variance_portion));
    clear data sv sv2 var;
