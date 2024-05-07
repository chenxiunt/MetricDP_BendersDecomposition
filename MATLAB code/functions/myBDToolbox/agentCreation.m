function [agent, adjacence_matrix_internal, adjacence_matrix_boundary, MP_size_mean, sub_size] ...
    = agentCreation(cluster_idx, adjacence_matrix, distance_matrix, env_parameters)
    for i = 1:1:env_parameters.NR_AGENT
        agent(i) = struct(  'idx', i, ...
                            'node', [], ...
                            'node_internal', [], ...
                            'node_boundary', [], ...
                            'cost_vector', [], ...
                            'internal', [], ...
                            'boundary', [], ... 
                            'new_cut_A_bounded', [], ...
                            'new_cut_b_bounded', 0, ...
                            'new_cut_A_unbounded', [], ...
                            'new_cut_b_unbounded', 0, ...
                            'GeoI', [], ...
                            'decision', [], ...
                            'isunbounded', 0, ...
                            'isupdated', 0, ...
                            'upperbound', 9999, ...
                            'extremerays', [], ... 
                            'z', 0); 
    end
    for i = 1:1:env_parameters.NR_NODE_IN_TARGET
        agent(cluster_idx(i, 1)).node = [agent(cluster_idx(i, 1)).node, i];
    end
    
    adjacence_matrix_internal = zeros(env_parameters.NR_NODE_IN_TARGET, env_parameters.NR_NODE_IN_TARGET); 
    adjacence_matrix_boundary = zeros(env_parameters.NR_NODE_IN_TARGET, env_parameters.NR_NODE_IN_TARGET); 
                                                                                % Determine the inter-set nodes and intra-set nodes for each agent
    [idx_i, idx_j, ~] = find(adjacence_matrix);  
    for l = 1:1:size(idx_i, 1) 
        if cluster_idx(idx_i(l, 1)) == cluster_idx(idx_j(l, 1))
                                                                                % Find the intra set nodes for each agent
            agent(cluster_idx(idx_i(l, 1))).internal = [agent(cluster_idx(idx_i(l, 1))).internal; [idx_i(l, 1), idx_j(l, 1)]];
            adjacence_matrix_internal(idx_i(l, 1), idx_j(l, 1)) = 1; 
        else
                                                                                % Find the inter set nodes for each agent
            agent(cluster_idx(idx_i(l, 1))).boundary = [agent(cluster_idx(idx_i(l, 1))).boundary; [idx_i(l, 1), idx_j(l, 1)]];
            adjacence_matrix_boundary(idx_i(l, 1), idx_j(l, 1)) = 1; 
            if size(find(agent(cluster_idx(idx_i(l, 1))).node_boundary == idx_j(l, 1)), 2) == 0
                agent(cluster_idx(idx_i(l, 1))).node_boundary = [agent(cluster_idx(idx_i(l, 1))).node_boundary, idx_i(l, 1)];
            end
        end
    end
    for i = 1:1:env_parameters.NR_AGENT
        agent(i).node = unique(agent(i).node); 
        agent(i).node_boundary = unique(agent(i).node_boundary); 
        agent(i).node_internal = unique(setdiff(agent(i).node, agent(i).node_boundary));
        internal_size(i) = size(agent(i).node_internal, 2); 
    end
    sub_size = sum(internal_size)/env_parameters.NR_AGENT; 
    G = graph(adjacence_matrix_boundary); 
    [bins,binsizes] = conncomp(G); 
    % [mean(binsizes(find(binsizes > 1))), std(binsizes(find(binsizes > 1)))*1.96] 
    MP_size = binsizes(find(binsizes > 1)); 
    MP_size_mean = mean(binsizes(find(binsizes > 1))); 
    %% Ruiyao Liu 
    for i = 1:1:env_parameters.NR_AGENT
        agent(i) = creatSubGeoI(agent(i), distance_matrix, env_parameters.NR_OBFLOC, env_parameters.EPSILON); 
    end


    %% Calculate the size of subproblems
    subproblem_size = zeros(1, env_parameters.NR_AGENT); 
    for i = 1:1:env_parameters.NR_AGENT
        subproblem_size(1, i) = size(agent(i).node, 2); 
    end
    %% Save the results
    save('.\Dataset\results\subproblem_size.mat', 'subproblem_size'); 
    save('.\Dataset\results\MP_size.mat', 'MP_size');
end