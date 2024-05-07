function [adjacence_matrix, distance_matrix, wordemb, distance_graph, env_parameters] = readTextInfo(env_parameters)
    [~,txtData]  = xlsread('./Dataset/citystate/statesandcities.xlsx');
    env_parameters.cost_matrix = cost_matrix;             % Calculate the cost matrix 
    emb = fastTextWordEmbedding; 
    for i = 1:1:size(txtData, 1)
        wordemb(i, :) = word2vec(emb, txtData{i});
    end
    
    
    distance_matrix = zeros(env_parameters.NR_NODE_IN_TARGET, env_parameters.NR_NODE_IN_TARGET); 
    for i = 1:1:env_parameters.NR_NODE_IN_TARGET
        for j = 1:1:env_parameters.NR_NODE_IN_TARGET
            distance_matrix(i, j) = sqrt(sum((wordemb(i, :) - wordemb(j, :)).^2)); 
        end
    end
    
    % env_parameters.NEIGHBOR_THRESHOLD = 2;
    
    adjacence_matrix = heaviside(1 - distance_matrix/env_parameters.NEIGHBOR_THRESHOLD);
    
    env_parameters.obf_loc = randperm(env_parameters.NR_NODE_IN_TARGET, env_parameters.NR_OBFLOC); 

    distance_matrix_= distance_matrix.*adjacence_matrix;
    G = graph(distance_matrix_); 
    distance_graph = distances(G); 


    for i = 1:1:env_parameters.NR_NODE_IN_TARGET
        for j = 1:1:env_parameters.NR_OBFLOC         
            cost_matrix(i,j) = distance_matrix(i, env_parameters.obf_loc(1, j)); 
        end
    end
    cost_matrix = cost_matrix/env_parameters.NR_OBFLOC; 
    env_parameters.cost_matrix = cost_matrix; %abs(randn(env_parameters.NR_NODE_IN_TARGET, env_parameters.NR_OBFLOC));             % Calculate the cost matrix 
end