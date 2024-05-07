function [masteragent, agent, lowerbound, upperbound] = bendersDecomposition_RLTraining(env_parameters, rl_parameters, masteragent, agent_original, policyagent)

    %% This function is used to train the RL policy
    % ---------------------- Initialize learning agents

    %% Monte-Carlo algorithm
    record_sum_award = zeros(1, rl_parameters.NR_EPISODE);  
    value_func_error = zeros(1, rl_parameters.NR_EPISODE); 
    % load('.\Dataset\rome\NR_OBFLOC_100\policyagent\policyagent-768-12-15-2023.mat');

    for ep_idx = 1:1:rl_parameters.NR_EPISODE
    % for task_loc = 1:1:1
        masteragent = myReset(masteragent); 
        agent = agent_original; 
        policyagent = resetPolicyagent(policyagent, agent, env_parameters); 
        
        upperbound_details = []; 

        iter = 1; 
        extreme_idx = zeros(1, env_parameters.NR_AGENT); 
        while iter <= env_parameters.ITER
            if iter == 22
                a = 0; 
            end
            [ep_idx iter] 
            obfuscation_matrix = zeros(env_parameters.NR_NODE_IN_TARGET, env_parameters.NR_OBFLOC); 

            %% Master program
            if iter == 0
                obfuscation_matrix = ones(env_parameters.NR_NODE_IN_TARGET, env_parameters.NR_OBFLOC)/env_parameters.NR_OBFLOC; 
                lowerbound(iter) = 0; %1/20*sum(sum(cost_matrix)); 
            else
                [masteragent, agent, lowerbound(iter), is_cut] = masterProblem(masteragent, agent, env_parameters); 
                obfuscation_matrix(masteragent.node, :) = masteragent.decision;
            end

            
            %% Subproblems
            for i = 1:1:env_parameters.NR_AGENT  
                if i == 1
                    a = 0;  % for debugging
                end
                if size(agent(i).node_boundary, 2)*size(agent(i).node_boundary, 1) > 0
                    if size(agent(i).node_internal, 2)*size(agent(i).node_internal, 1) > 0
                        [agent(i), policyagent(i)] = subProblemRL(agent(i), policyagent(i), env_parameters.cost_matrix, env_parameters.NR_OBFLOC, obfuscation_matrix, iter);
                        upperbound_details(iter, i) = agent(i).upperbound; 
                        isunbounded(i) = agent(i).isunbounded; 
                    end
                end
            end

            %% Each agent suggests the new cuts to the master agent
            masteragent = addNewCuts(masteragent, agent, env_parameters); 


            upperbound(iter) = sum(upperbound_details(iter, :)); 
            obfuscation_matrix = integrateZ(agent, env_parameters); 

            if upperbound(iter) - lowerbound(iter) < 0.01
                break; 
            end
            iter = iter+1; 
        end
        % episode(ep_idx, :) = reward_compute(episode(ep_idx, :)); 
        for i = 1:1:env_parameters.NR_AGENT
            if size(agent(i).extremerays, 1)*size(agent(i).extremerays, 2) > 0
                i
                policyagent(i) = policyAgentGCalculate(policyagent(i), rl_parameters);
                policyagent(i) = policyAgentCriticCalculate(policyagent(i), rl_parameters);
                policyagent(i) = updatePolicy(policyagent(i), rl_parameters);
                record_sum_award(1, ep_idx) = record_sum_award(1, ep_idx) + sum(policyagent(i).G_reward); 
                value_func_error(1, ep_idx) = value_func_error(1, ep_idx) + sum(policyagent(i).value_func_error); 
            end
        end
        save(".\Dataset\rome\NR_OBFLOC_100\policyagent\policyagent-768-12-18-2023.mat", "policyagent"); 
        save(".\Dataset\rome\NR_OBFLOC_100\sum_award\record_sum_award-12-18-2023.mat", "record_sum_award"); 
    end
end