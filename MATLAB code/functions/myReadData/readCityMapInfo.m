function [adjacence_matrix, distance_matrix, loc_x_in_target, loc_y_in_target, env_parameters] = readCityMapInfo(env_parameters)
    
    opts = detectImportOptions('./Dataset/rome/raw/nodes_rome.csv');
    opts = setvartype(opts, 'osmid', 'int64');
    df_nodes = readtable('./Dataset/rome/raw/nodes_rome.csv', opts);
    df_edges = readtable('./Dataset/rome/raw/edges_rome.csv');
                                                                                % Extract the column as an array
    col_longitude = table2array(df_nodes(:, 'x'));                              % Actual x (longitude) coordinate from the nodes data
    col_latitude = table2array(df_nodes(:, 'y'));                               % Actual y (latitude) coordinate from the nodes data
    col_osmid = table2array(df_nodes(:, 'osmid'));                              % Actual unique osmid from the nodes data
    
    fprintf("The map information has been loaded. \n")
    [G, u, v, timeTaken] = graph_preparation(df_nodes, df_edges);               % Given the map information, create the mobility graph
    fprintf("The mobility graph has been created. \n \n")
    
    
    %% Read the trajectory information
    fprintf("Loading the trajectory information ... \n")
    % load('./Dataset/rome/raw/trace_taxi_sample_rome.mat');                      
    fprintf("The trajectory information has been loaded. \n \n")
    
    
    %% Determine the target region                                              
    mat_longitude = max(col_longitude);                                         % The maximum longitude of the whole region            
    min_longitude = min(col_longitude);                                         % The minimum longitude of the whole region
    LONGITUDE_SIZE = mat_longitude - min_longitude;                             % The length of the longitude
    max_latitude = max(col_latitude);                                           % The maximum latitude of the whole region
    min_latitude = min(col_latitude);                                           % The maximum latitude of the whole region
    LATITUDE_SIZE = max_latitude - min_latitude;                                % The length of the latitude
    
    TARGET_LONGITUDE_MAX = min_longitude ...
        + LONGITUDE_SIZE/env_parameters.REGION_SCALE ...
        + (LONGITUDE_SIZE+LONGITUDE_SIZE/env_parameters.REGION_SCALE)/2;                       % The maximum longitude of the target region  
    TARGET_LONGITUDE_MIN = min_longitude ...
        + LONGITUDE_SIZE/env_parameters.REGION_SCALE ...
        + (LONGITUDE_SIZE-LONGITUDE_SIZE/env_parameters.REGION_SCALE)/2;                       % The minimum longitude of the target region 
    TARGET_LATITUDE_MAX = min_latitude ...
        + (LATITUDE_SIZE+LATITUDE_SIZE/env_parameters.REGION_SCALE)/2;                         % The maximum latitude of the target region
    TARGET_LATITUDE_MIN = min_latitude ...
        + (LATITUDE_SIZE-LATITUDE_SIZE/env_parameters.REGION_SCALE)/2;                         % The minimum latitude of the target region
    formatSpec = 'The target region is created: \n' + ...
        "South-west corner coordinate: (latitude = %f, longitude = %f) \n" + ...
        "North-east corner coordinate: (latitude = %f, longitude = %f) \n"; 
    fprintf(formatSpec, TARGET_LONGITUDE_MIN , TARGET_LATITUDE_MAX, TARGET_LONGITUDE_MAX, TARGET_LATITUDE_MIN); 


    %% Find the set of nodes in the target region
    % node_in_target = nodeInTarget(col_longitude, col_latitude, TARGET_LONGITUDE_MAX, TARGET_LONGITUDE_MIN, TARGET_LATITUDE_MAX, TARGET_LATITUDE_MIN); 
    % node_in_target = randperm(size(node_in_target, 2), env_parameters.NR_NODE_IN_TARGET); 
    load('.\Dataset\rome\intermediate\node_in_target.mat'); 
    % env_parameters.NR_NODE_IN_TARGET = size(node_in_target, 2); 
    loc_x_in_target = col_longitude(node_in_target);                            
    loc_y_in_target = col_latitude(node_in_target); 
    fprintf('The number of nodes is %d  \n', env_parameters.NR_NODE_IN_TARGET);
    %% Perturbed locations are randomly distributed over the target region
    obf_loc = randperm(size(node_in_target, 2), env_parameters.NR_OBFLOC); 
    % load('.\Dataset\rome\intermediate\obf_loc.mat')
    env_parameters.obf_loc = obf_loc; 
    % env_parameters.obf_loc = obf_loc;
    data_read = load('.\Dataset\rome\intermediate\obf_loc.mat'); 
    % env_parameters.obf_loc = data_read.obf_loc; 
    fprintf('The number of perturbed locations is %d  \n \n', env_parameters.NR_OBFLOC); 


    %% Distance matrix calculation                                                           
    distance_matrix = distanceMatrix(col_longitude(node_in_target), col_latitude(node_in_target));       
    % Calculate the distance between each pair of locations and create the
    %                                             % distance matrix D
    % load('.\Dataset\rome\intermediate\distance_matrix.mat');
    adjacence_matrix = heaviside(1 - distance_matrix/env_parameters.NEIGHBOR_THRESHOLD);       % Create the adjacency matrix. 
    adjacence_matrix = adjacence_matrix - eye(env_parameters.NR_NODE_IN_TARGET); 
    mDPMatrix = adjacence_matrix.*distance_matrix;                              % Create the mDP matrix. 
    mDPGraph = graph(mDPMatrix);                                                % Create the mDP graph using the mDP matrix
    path_distance_matrix = distances(mDPGraph);                                 % Calculate the path distance using the mDP graph
    
    %% Create the task location
    % task_loc = randperm(size(node_in_target, 2), NR_TASK);                      % Randomly distrubte tasks in the target region
    task_loc = 2;
    cost_matrix = costMatrix(node_in_target, task_loc, env_parameters.obf_loc, G);  
    % load('.\Dataset\rome\NR_OBFLOC_100\cost_matrix\cost_matrix.mat');
    env_parameters.cost_matrix = cost_matrix;             % Calculate the cost matrix 

    distance_matrix_= distance_matrix.*adjacence_matrix;
    G = graph(distance_matrix_); 
    
    distance_graph = distances(G); 
end