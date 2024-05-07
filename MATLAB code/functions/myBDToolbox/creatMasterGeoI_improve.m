function masteragent = creatMasterGeoI_improve(masteragent, agent, adjacence_matrix, distance_matrix, NR_OBFLOC, NR_AGENT, EPSILON)
    idx = 0;
    NR_NODE_IN_AGENT = size(masteragent.node, 2); 
    GeoI = sparse([]); 
    node_internal = agent.node_internal; 
    node_boundary = agent.node_boundary; 
    for i = 1:1:size(node_internal, 2)
        node_i = node_internal(1, i); 
        for j = 1:1:size(node_boundary, 2)
            node_j = node_boundary(1, j);
            if adjacence_matrix(node_i, node_j) > 0
                for l = 1:1:size(node_boundary, 2)
                    node_l = node_boundary(1, l);
                    if j~=l && adjacence_matrix(node_i, node_l) > 0
                        GeoI_vec = sparse(NR_OBFLOC, NR_NODE_IN_AGENT*NR_OBFLOC); 
                        % node_ii = find(masteragent.node == node_i);
                        node_jj = find(masteragent.node == node_j);
                        node_ll = find(masteragent.node == node_l);
                        for k = 1:1:NR_OBFLOC 
                            GeoI_vec(k, (node_jj-1)*NR_OBFLOC + k) = exp(-EPSILON*distance_matrix(node_i, node_j));
                            GeoI_vec(k, (node_ll-1)*NR_OBFLOC + k) = -exp(EPSILON*distance_matrix(node_i, node_l));
                        end        
                        GeoI = [GeoI; GeoI_vec]; 
                    end
                end
            end 
        end
    end
    masteragent.GeoI = [masteragent.GeoI; GeoI]; 

end