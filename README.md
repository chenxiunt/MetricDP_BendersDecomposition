# MetricDP_BendersDecomposition

Installation: MATLAB (MATLAB 2022a or later vision): https://www.mathworks.com/products/matlab.html

Usage: Run the "main_BD.m" file. After installing MATLAB, open "main_BD.m" and use the "Run" button in the "Live Editor" tab.

The datasets can be selected in line 28 by assigning the variable "dataset_selected" by the integer number 1, 2, 3, or 4: 
% 1 - Geo-location data in the road network;
% 2 - Geo-location data in grid maps
% 3 - Text datasets
% 4 - Synthetic datasets

The dataset partitioning algorithm can be selected 61 by assigning the variable "partitioning_algorithm" by the integer number 1, 2, 3, or 4: 
% 1 - k-mean-DV
% 2 - k-mean-rec
% 3 - k-mean-adj
% 4 - Balanced Spectral Clustering (BSC)

Other parameters can be determined in the file "parameters.m" by setting the struct variable "env_parameters"

'NEIGHBOR_THRESHOLD' -- ETA, the mDP distance threshold
'NR_AGENT' -- the number of subproblems
'NR_OBFLOC' -- the number of perturbed data
'NR_TASK' -- the number of tasks in LBS
'EPSILON' -- the privacy budget
'NR_NODE_IN_TARGET' -- the number of records in the secret dataset
'ITER' -- the maximum number of iterations in the Benders decomposition


Results: After running "main_BD.m", the results are stored in the folder "Dataset\results\...". including 
'upperbound.mat': the upper bound of the Benders decomposition; 
'lowerbound.mat': the lower bound of the Benders decomposition;
'time_master.mat': the maximum computation time of the subproblems over iterations; 
'time_subproblem': the computation time of the master program over iteration; 
'MP_size': the size of Master program components
'subproblem_szie': the size of subproblems
Finally, the optimized data utility loss is returned as the variable "utility_loss". 


*** In addition, 

The benchmark "ExpMech" can be run by calling the function "expMech(distance_matrix, env_parameters)" in line 49. It returns the expected data utility loss. 
