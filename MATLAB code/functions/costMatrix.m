function cost_matrix = costMatrix(node_in_target, task_loc, obf_loc, G)
    NR_LOC = size(node_in_target, 2); 
    NR_OBFLOC = size(obf_loc, 2); 
    cost_matrix = zeros(NR_LOC, NR_OBFLOC); 
    for i = 1:1:NR_LOC
        [~, D] = shortestpathtree(G, node_in_target(task_loc)); 
        for j = 1:1:NR_OBFLOC         
            % [~,c_i] = shortestpathtree(G, node_in_target(task_loc), node_in_target(i)); 
            % [~,c_j] = shortestpathtree(G, node_in_target(task_loc), node_in_target(obf_loc(j))); 
            cost_matrix(i,j) = abs(D(node_in_target(i))-D(node_in_target(obf_loc(j)))); 
        end
    end
    cost_matrix = cost_matrix/NR_LOC; 
end