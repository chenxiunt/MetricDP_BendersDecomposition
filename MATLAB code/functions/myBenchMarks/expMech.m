function cost = expMech(distance_matrix, env_parameters)
%% Description:
    % The obfmatrix_generator_laplace is function which generate the
    % obfuscaed location vector
%% Input
    % coordinate: Actual x and y coordinate from the openstreet map data
    % i: location on which obfuscation will happen
    % EPSILON: randomized value
    % NR_LOC: total number of nodes

%% Output
    % z_vector: obfuscation vector for that node
%%
    cost = 0; 
    prob_matrix = ones(env_parameters.NR_NODE_IN_TARGET, env_parameters.NR_OBFLOC);  
    for i = 1:1:env_parameters.NR_NODE_IN_TARGET
        for k = 1:1:env_parameters.NR_OBFLOC
            prob_matrix(i, k) = exp(-distance_matrix(i, env_parameters.obf_loc(1, k))*env_parameters.EPSILON/2);        % changed i to 1
        end
        prob_matrix(i, :) = prob_matrix(i, :)/sum(prob_matrix(i, :)); 
    end

    for i = 1:1:env_parameters.NR_NODE_IN_TARGET
        for k = 1:1:env_parameters.NR_OBFLOC
            cost = cost + env_parameters.cost_matrix(i, k)*prob_matrix(i, k);         % changed i to 1
        end
    end
%     %% Measure the expected errors
%     [~, D] = shortestpathtree(G, PATIENT);
%     overallcost = 0; 
%     for i = 1:1:NR_LOC
%         for j = 1:1:NR_LOC
%             approx_distance = sqrt((coordinate(j, 1) - coordinate(PATIENT, 1))^2 + (coordinate(j, 2) - coordinate(PATIENT, 2))^2 + (coordinate(j, 3) - coordinate(PATIENT, 3))^2); 
%             distance_error = abs(approx_distance - D(i)); 
%             costMatrix(i, j) = distance_error; 
%             overallcost = overallcost + distance_error * z(i, j);
%         end
%     end
%     overallcost = overallcost/NR_LOC; 
%     cost_distribution = cost_error_distribution(z, costMatrix, NR_LOC); 
end
