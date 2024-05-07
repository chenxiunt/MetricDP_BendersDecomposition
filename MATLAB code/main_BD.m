%% Header
addpath('./functions/');                                                    % Functions
addpath('./functions/myBDToolbox');                                         % My Benders decomposition toolbox
addpath('./functions/myBenchMarks');                                        % My Benders decomposition toolbox
addpath('./functions/myPlotToolbox');                                       % My plot toolbox
addpath('./functions/myReadData');                                          % My plot toolbox
addpath('./functions/haversine');                                           % Read the Haversine distance package. This package is created by Created by Josiah Renfree, May 27, 2010
parameters;                                                                 % Read the parameters of the simulation

fprintf('------------------- Environment settings --------------------- \n \n'); 

% for scale = 1:1:1

for nr_agent = 1:1:1
   env_parameters.NR_AGENT = 25; 
   % env_parameters.EPSILON = epsilon*2; 
    % env_parameters.NR_NODE_IN_TARGET = 1000; 


%% Read the dataset information
rng(0)

% Select a dataset here: 
% 1 - Geo-location data in the road network;
% 2 - Geo-location data in grid maps
% 3 - Text datasets
% 4 - Synthetic datasets
dataset_selected = 2; 

switch dataset_selected
    case 1      % Road network
        [adjacence_matrix, distance_matrix, loc_x_in_target, loc_y_in_target, env_parameters] = readCityMapInfo(env_parameters); 
    case 2      % Grid map
        [adjacence_matrix, distance_matrix, coord, distance_graph, env_parameters] = createGridMap(env_parameters);
        loc_x_in_target = coord(:, 1); 
        loc_y_in_target = coord(:, 2); 
    case 3      % Text data  
        [adjacence_matrix, distance_matrix, wordemb, distance_graph, env_parameters] = readTextInfo(env_parameters); 
    case 4      % Synthetic data
        [adjacence_matrix, distance_matrix, syndata, distance_graph, env_parameters] = creatSynData(env_parameters); 
end

fprintf("Loading the dataset information ... \n")

% data_read = load('.\Dataset\rome\NR_OBFLOC_200\cost_matrix\cost_matrix.mat'); 
% env_parameters.cost_matrix = data_read.cost_matrix; 

%% Benchmarks
% cost(epsilon) = expMech(distance_matrix, env_parameters); 
% end


%% Dataset partitioning algorithms
% ------------------------ Cluster the data

% Select a dataset partitioning algorithm here: 
% 1 - k-mean-DV
% 2 - k-mean-rec
% 3 - k-mean-adj
% 4 - Balanced Spectral Clustering (BSC)
partitioning_algorithm = 2; 

switch partitioning_algorithm
    case 1  % k-mean-DV
        cluster_idx = kmeans(distance_matrix, env_parameters.NR_AGENT); 
    case 2 % k-k-mean-rec
        switch dataset_selected
            case 1 % Road network
                cluster_idx = kmeans([loc_x_in_target, loc_y_in_target], env_parameters.NR_AGENT); 
            case 2 % Grid map
                cluster_idx = kmeans([loc_x_in_target, loc_y_in_target], env_parameters.NR_AGENT); 
            case 3 % Text data 
                cluster_idx = kmeans(wordemb(1:500, :), env_parameters.NR_AGENT); 
            case 4 % Synthetic data
                cluster_idx = kmeans(syndata, env_parameters.NR_AGENT); 
        end
    case 3  % k-mean-adj
        cluster_idx = kmeans(adjacence_matrix, env_parameters.NR_AGENT); 
    case 4  % BSC
        cluster_idx = balancedSpectral(adjacence_matrix, env_parameters.NR_AGENT);
end


%% Create the agents
fprintf('------------------- Create the agents ----------------------- \n'); 
[agent, ~, ~, ~, ~] = agentCreation(cluster_idx, adjacence_matrix, distance_matrix, env_parameters); 

% load('.\Dataset\rome\NR_OBFLOC_100\agent\agent.mat'); 
fprintf('%d agents have been created. \n', env_parameters.NR_AGENT); 

%% Create the master agent
fprintf('------------------- Create the agents ----------------------- \n'); 

%% Initialize the master agent
masteragent  = masterAgentCreation(distance_matrix, agent, adjacence_matrix, cluster_idx, env_parameters); 

%% Benders decomposition starts here ... 
    fprintf('------------------- Benders decomposition starts here ----------------------- \n'); 
    [~, ~, ~, ~, ~, utility_loss(nr_agent), time_subproblem(nr_agent, :), time_master(nr_agent, :)] = bendersDecomposition(masteragent, agent, env_parameters); 
end