function cluster_idx = balancedkmean2(data, NR_AGENT)

    
    % Maximum number of iterations
    maxIterations = 100;
    
    % Initialize cluster centroids randomly
    initialCentroids = datasample(data, NR_AGENT, 'Replace', false);
    
    % Perform k-means clustering with an attempt to balance
    for iter = 1:maxIterations
        % Assign data points to the nearest centroids
        [~, cluster_idx] = pdist2(initialCentroids, data, 'euclidean', 'Smallest', 1);
        
        % Calculate the actual number of points per cluster
        pointsPerCluster = histcounts(cluster_idx, 1:NR_AGENT+1);
        
        % Update centroids based on the current assignment
        for i = 1:NR_AGENT
            initialCentroids(i, :) = mean(data(cluster_idx == i, :), 1);
        end
        
        % Adjust the assignment to balance the clusters (optional)
        [~, sortedClusters] = sort(pointsPerCluster, 'descend');
        for i = 1:NR_AGENT
            clusterIdx = sortedClusters(i);
            excessPoints = pointsPerCluster(clusterIdx) - size(data, 1) / NR_AGENT-5;
            
            % Move excess points to other clusters
            for j = 1:NR_AGENT
                if i ~= j && excessPoints > 0
                    movePoints = min(excessPoints, sum(cluster_idx == j));
                    samples = datasample(find(cluster_idx == j), min(movePoints, sum(cluster_idx == j)), 'Replace', false);
                    cluster_idx(ismember(cluster_idx, samples)) = j;
                    excessPoints = excessPoints - movePoints;
                end
            end
        end
        
        % Check for convergence
        if all(pointsPerCluster >= numel(data) / NR_AGENT)
            break;
        end
    end
    cluster_idx = cluster_idx';
end