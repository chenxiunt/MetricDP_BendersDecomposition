function cluster_idx = balancedkmean(data, NR_AGENT)
    % % Generate sample data
    % rng(1); % For reproducibility
    % data = [randn(100,2)*0.75+ones(100,2);
    %         randn(100,2)*0.75-ones(100,2)];
    
    % % Set the number of clusters (NR_AGENT)
    % NR_AGENT = 20;
    
    % Determine the target number of points per cluster
    targetPointsPerCluster = size(data, 1) / NR_AGENT;
    
    % Initialize cluster centroids randomly
    initialCentroids = datasample(data, NR_AGENT, 'Replace', false);
    
    % Maximum number of iterations
    maxIterations = 500;
    
    % Perform k-means clustering
    for iter = 1:maxIterations
        % Assign data points to the nearest centroids
        [~, cluster_idx] = pdist2(initialCentroids, data, 'euclidean', 'Smallest', 1);
        
        % Calculate the actual number of points per cluster
        pointsPerCluster = histcounts(cluster_idx, 1:NR_AGENT+1);
        
        % Update centroids based on the current assignment
        for i = 1:NR_AGENT
            initialCentroids(i, :) = mean(data(cluster_idx == i, :), 1);
        end
        
        % Check for convergence
        if all(pointsPerCluster >= targetPointsPerCluster)
            break;
        end
    end
    cluster_idx = cluster_idx';
    % Visualize the results
    % figure;
    % scatter(data(:,1), data(:,2), 20, cluster_idx, 'filled');
    % hold on;
    % scatter(initialCentroids(:,1), initialCentroids(:,2), 100, 'k', 'x');
    % title('Balanced K-Means Clustering');
    % legend('Cluster 1', 'Cluster 2', 'Centroids');
end