function agent = creatSubGeoI(agent, distance_matrix, NR_OBFLOC, EPSILON)
    distance_matrix = full(distance_matrix); 
    idx = 0; 

    NR_NODE_INTRASET = size(agent.node_internal, 1)*size(agent.node_internal, 2); 
    NR_NODE_INTERSECT = size(agent.node_boundary, 1)*size(agent.node_boundary, 2); 

    agent.GeoI = sparse(1, (NR_NODE_INTRASET+NR_NODE_INTERSECT)*NR_OBFLOC);
    for i = 1:1:size(agent.internal, 1)
        node_i = find(agent.node_internal == agent.internal(i,1)); 
        node_j = find(agent.node_internal == agent.internal(i,2)); 
        if size(node_i, 2)==0 
            % if node_i is in the inter set and node_j is in the intra set
            node_i = NR_NODE_INTRASET + find(agent.node_boundary == agent.internal(i,1));
        end

        if size(node_j, 2)==0
            % if node_i is in the inter set and node_j is in the intra set
            node_j = NR_NODE_INTRASET + find(agent.node_boundary == agent.internal(i,2));
        end

        for k = 1:1:NR_OBFLOC
            if node_i ~= node_j
                agent.GeoI(idx+1, (node_i-1)*NR_OBFLOC + k) = 1;
                agent.GeoI(idx+1, (node_j-1)*NR_OBFLOC + k) = -exp(EPSILON*distance_matrix(agent.internal(i,1), agent.internal(i,2)));
                idx = idx + 1;
                agent.GeoI(idx+1, (node_i-1)*NR_OBFLOC + k) = -exp(EPSILON*distance_matrix(agent.internal(i,1), agent.internal(i,2)));
                agent.GeoI(idx+1, (node_j-1)*NR_OBFLOC + k) = 1;
                idx = idx + 1;
            end
        end
    end

    % for i = 1:1:size(agent.boundary, 1)
    %     for k = 1:1:NR_OBFLOC
    %         node_i = find(agent.node == agent.internal(i,1)); 
    %         node_j = NR_NODE_INTRASET + find(agent.node_boundary == agent.boundary(i,2)); 
    %         agent.GeoI(idx+1, (node_i-1)*NR_OBFLOC + k) = 1;
    %         agent.GeoI(idx+1, (node_j-1)*NR_OBFLOC + k) = -exp(EPSILON*distance_matrix(agent.boundary(i,1), agent.boundary(i,2)));
    %         idx = idx + 1;
    %         agent.GeoI(idx+1, (node_i-1)*NR_OBFLOC + k) = -exp(EPSILON*distance_matrix(agent.boundary(i,1), agent.boundary(i,2)));
    %         agent.GeoI(idx+1, (node_j-1)*NR_OBFLOC + k) = 1;
    %         idx = idx + 1;
    %     end
    % end
end