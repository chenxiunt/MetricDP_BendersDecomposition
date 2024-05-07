function cost = constOPTMech(distance_matrix, adjacence_matrix, env_parameters)

%% Input
% UL_matrix: Utility loss matrix, each UL(i, k) represents the utility loss
% caused by the obfuscated location k given the real location i
% distance_matrix: each distance_matrix(i, j) represents the Haversine
% distance between location i and location j
% EPSILON: the privacy budget
%% Output
% the obfuscation matrix 

    cost = 0; 

    NR_LOC = env_parameters.NR_NODE_IN_TARGET; 

    %% Create the matrix for the Geo-indistinguishability constraints
    GeoI = zeros(NR_LOC*NR_LOC*(NR_LOC-1), NR_LOC*NR_LOC); 
    idx = 1; 
    for i = 1:1:NR_LOC
        for j = i+1:1:NR_LOC    
            for k = 1:1:NR_LOC
                if distance_matrix(i, j) >= 1
                    GeoI(idx, (i-1)*NR_LOC + k) = exp(-env_parameters.EPSILON*distance_matrix(i, j));
                    GeoI(idx, (j-1)*NR_LOC + k) = -1;
                else
                    GeoI(idx, (i-1)*NR_LOC + k) = 1;
                    GeoI(idx, (j-1)*NR_LOC + k) = -exp(env_parameters.EPSILON*distance_matrix(i, j));
                end
                idx = idx + 1;
                if distance_matrix(i, j) >= 1
                    GeoI(idx, (i-1)*NR_LOC + k) = -1;
                    GeoI(idx, (j-1)*NR_LOC + k) = exp(-env_parameters.EPSILON*distance_matrix(i, j));
                else
                    GeoI(idx, (i-1)*NR_LOC + k) = -exp(env_parameters.EPSILON*distance_matrix(i, j));
                    GeoI(idx, (j-1)*NR_LOC + k) = 1;
                end
                idx = idx + 1;
            end
        end
    end
    b_GeoI = zeros(NR_LOC*NR_LOC*(NR_LOC-1), 1); 


    %% Create the cost vector for the objective function
    for i = 1:1:NR_LOC
        for k = 1:1:NR_LOC
            f((i-1)*NR_LOC + k) = env_parameters.cost_matrix(i, k); 
        end
    end

    %% Create the matrix for the probability unit measure constraints
    for i = 1:1:NR_LOC
        for j = 1:1:NR_LOC
            A_um(i, (i-1)*NR_LOC + j) = 1;
        end
    end  

    b_um = ones(NR_LOC, 1);


    %% Upper bound and lower bound of the decision variables
    lb = zeros(NR_LOC*NR_LOC, 1);
    ub = ones(NR_LOC*NR_LOC, 1);

    [z, pfval, exitflag] = linprog(f, GeoI, b_GeoI, A_um, b_um, lb, ub);

    obfuscationMatrix = reshape(z, NR_LOC, NR_LOC);
    obfuscationMatrix = obfuscationMatrix'; 

end