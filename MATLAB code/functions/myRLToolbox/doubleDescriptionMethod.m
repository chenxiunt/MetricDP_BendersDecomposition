function extremeRays = doubleDescriptionMethod(A, b)
    [m, n] = size(A);
    
    % Initialize the sets of inequalities
    H = A; % Constraints matrix
    K = speye(m); % Identity matrix representing extreme rays
    
    tol = 1e-20; % Tolerance for numerical stability
    
    while true
        % Update K based on H using SVD
        [U, S, V] = svds(H');
        K = U(:, rank(S) + 1:end)';
        
        % Update H based on K using SVD
        [U, S, V] = svds(K');
        H = U(:, rank(S) + 1:end)';
        
        % Check for convergence
        if norm(S, 'fro') < tol
            break;
        end
    end
    
    % Extract extreme rays from K
    extremeRays = K;
end