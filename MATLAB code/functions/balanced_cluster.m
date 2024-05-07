function cluster_idx = balanced_cluster(distance_matrix, adjacence_matrix, NR_AGENT)
    
    % G = graph(distance_matrix.*adjacence_matrix); 
    G = graph(adjacence_matrix); 
    
    % distance_graph = distances(G); 
    % cluster_idx = kmeans(distance_matrix, NR_AGENT);
    L = full(laplacian(G)); 
    [V,D] = eig(full(L)); 
    for i = 1:1:size(V, 2)
        V(:, i) = V(:, i)/sqrt(sum(V(:, i).^2)); 
    end

    V_ = V(:, 1:NR_AGENT);
    % cluster_idx = ones(1, size(adjacence_matrix, 1)); 
    % [~, idx] = maxk(V_(: ,2), 250);
    % cluster_idx(1, idx) = 2; 

    cluster_idx = kmeans(V_, NR_AGENT); 


    % counts = ones(1, NR_AGENT)*size(adjacence_matrix, 1)/NR_AGENT; 
    % idx = 1;
    % while idx < 20
    %     nr_indices = ones(1, NR_AGENT)*300; 
    %     sum_error(idx) = 0;
    %     for i = 1:1:size(adjacence_matrix, 1)
    %         sum_error(idx) = sum_error(idx) + min(abs(V_(i,:)-1./sqrt(counts+0.0001))); 
    %         [~, selected_idx] = min(abs(V_(i,:)-1./sqrt(counts+0.0001))); 
    %         cluster_idx(i) = selected_idx; 
    %         nr_indices(1, selected_idx) = nr_indices(1, selected_idx) - 1;
    %         if nr_indices(1, selected_idx)<=0
    %             counts(1, selected_idx) = 0.0001; 
    %         end
    %         % kmeans(V(:, 1:NR_AGENT), NR_AGENT); 
    %     end
    % 
    %     counts = hist(cluster_idx, 1:NR_AGENT);
    %     idx = idx + 1; 
    % end
end