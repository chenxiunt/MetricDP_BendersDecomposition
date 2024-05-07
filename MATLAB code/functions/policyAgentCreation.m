function policyagent = policyAgentCreation(agent, env_parameters)
    for i = 1:1:env_parameters.NR_AGENT
        policyagent(i) = struct('policy_network', [], ...
                                'critic_network', [], ...
                                'value_func_error', zeros(env_parameters.ITER, 1), ...
                                'states_is_extreme', [], ...
                                'states_is_selected', [], ...
                                'actions', zeros(env_parameters.ITER, 1), ...
                                'actions_distribution', [], ...
                                'instant_reward', zeros(env_parameters.ITER, 1), ...
                                'G_reward', zeros(env_parameters.ITER, 1), ...
                                'states_is_bounded', zeros(env_parameters.ITER, 1)); 
        nr_extremerays = size(agent(i).extremerays, 2);                     
        policyagent(i).states_is_extreme = zeros(env_parameters.ITER, nr_extremerays); % The states are initialized by empty
        policyagent(i).states_is_selected = zeros(env_parameters.ITER, nr_extremerays); 
        policyagent(i).actions_distribution = zeros(env_parameters.ITER, nr_extremerays);
        if nr_extremerays > 0
            policyagent(i).policy_network = [
                featureInputLayer(nr_extremerays+1)                       % The first L elements (L denotes the number of candidate extreme rays) 
                                                                            % represent whether the candidate extreme rays have been selected
                                                                            % The next L elements represent whether the candidates are the extreme rays
                                                                            % The last element represents whether the problem is bounded.    
                fullyConnectedLayer(400)
                reluLayer
                % fullyConnectedLayer(200)
                % reluLayer
                fullyConnectedLayer(400)
                reluLayer
                fullyConnectedLayer(nr_extremerays)
                softmaxLayer
            ];
            policyagent(i).policy_network = dlnetwork(policyagent(i).policy_network);

            policyagent(i).critic_network = [
                featureInputLayer(nr_extremerays+1)                       % The first L elements (L denotes the number of candidate extreme rays) 
                                                                            % represent whether the candidate extreme rays have been selected
                                                                            % The next L elements represent whether the candidates are the extreme rays
                                                                            % The last element represents whether the problem is bounded.    
                    fullyConnectedLayer(400)
                    reluLayer
                    % fullyConnectedLayer(200)
                    % reluLayer
                    fullyConnectedLayer(1)
            ];
            policyagent(i).critic_network = dlnetwork(policyagent(i).critic_network);
        end
    end
end