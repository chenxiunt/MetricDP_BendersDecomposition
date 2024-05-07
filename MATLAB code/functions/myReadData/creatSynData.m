function [adjacence_matrix, distance_matrix, r_num, distance_graph, env_parameters] = creatSynData(env_parameters)

    r_num = normrnd(0, 4.0, env_parameters.NR_NODE_IN_TARGET, 3); 

    % r_num = rand(env_parameters.NR_NODE_IN_TARGET, 3); 
    distance_matrix = zeros(env_parameters.NR_NODE_IN_TARGET, env_parameters.NR_NODE_IN_TARGET); 
    for i = 1:1:env_parameters.NR_NODE_IN_TARGET
        for j = 1:1:env_parameters.NR_NODE_IN_TARGET
            distance_matrix(i,j) = sqrt(sum((r_num(i, :) - r_num(j, :)).^2));
        end
    end
    env_parameters.cost_matrix = abs(randn(env_parameters.NR_NODE_IN_TARGET, env_parameters.NR_OBFLOC));             % Calculate the cost matrix 

    load('.\Dataset\rome\intermediate\obf_loc.mat'); 
    env_parameters.obf_loc = obf_loc; 
    adjacence_matrix = heaviside(1 - distance_matrix/env_parameters.NEIGHBOR_THRESHOLD);       % Create the adjacency matrix. 

    distance_matrix_= distance_matrix.*adjacence_matrix;
    G = graph(distance_matrix_); 
    
    distance_graph = distances(G); 

    % for i = 1:1:env_parameters.NR_NODE_IN_TARGET
    %     for j = 1:1:env_parameters.NR_OBFLOC         
    %         % [~,c_i] = shortestpathtree(G, node_in_target(task_loc), node_in_target(i)); 
    %         % [~,c_j] = shortestpathtree(G, node_in_target(task_loc), node_in_target(obf_loc(j))); 
    %         cost_matrix(i,j) = distance_matrix(i, env_parameters.obf_loc(j)); 
    %     end
    % end
    % cost_matrix = cost_matrix/env_parameters.NR_OBFLOC; 
    % env_parameters.cost_matrix = cost_matrix; 


    for i = 1:1:env_parameters.NR_NODE_IN_TARGET
        for j = 1:1:env_parameters.NR_OBFLOC         
            cost_matrix(i,j) = distance_matrix(i, env_parameters.obf_loc(1, j)); 
        end
    end
    cost_matrix = cost_matrix/env_parameters.NR_OBFLOC; 
    env_parameters.cost_matrix = cost_matrix; %abs(randn(env_parameters.NR_NODE_IN_TARGET, env_parameters.NR_OBFLOC));             % Calculate the cost matrix 
end