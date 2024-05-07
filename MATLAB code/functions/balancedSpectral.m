function clusterIdx = balancedSpectral(adjacency_matrix, NR_AGENT)
    % Generate a sample graph (adjacency matrix)
    n = 100; % Number of nodes
    p = 0.1; % Probability of edge existence
    
    % rng(1); % For reproducibility
    % adjacency_matrix = rand(n) < p;
    % adjacency_matrix = triu(adjacency_matrix, 1) + triu(adjacency_matrix, 1)'; % Make the matrix symmetric
    
    % Degree matrix
    degreeMatrix = diag(sum(adjacency_matrix));
    
    % Laplacian matrix
    laplacianMatrix = degreeMatrix - adjacency_matrix;
    
    % Calculate the normalized Laplacian
    degreeMatrixInvSqrt = diag(1./sqrt(diag(degreeMatrix)));
    normalizedLaplacian = degreeMatrixInvSqrt * laplacianMatrix * degreeMatrixInvSqrt;
    
    % Perform eigendecomposition
    % [V, ~] = eig(normalizedLaplacian);

    [V, ~] = eig(laplacianMatrix);
    
    % [V, ~] = eig(laplacianMatrix);
    % Use k-means on the eigenvectors corresponding to the smallest eigenvalues
    % to obtain the clusters based on ratio cut
    embedding = V(:, 1:NR_AGENT);
    [clusterIdx, ~] = kmeans(embedding, NR_AGENT);
    
    % Visualize the results
    % figure;
    % gscatter(1:n, zeros(1, n), clusterIdx, parula(NR_AGENT), 'o', 10, 'filled');
    % title('Spectral Clustering with Ratio Cut');
    % xlabel('Node Index');
    % yticks([]); % Hide y-axis
end