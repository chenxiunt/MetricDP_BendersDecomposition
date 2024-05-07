function [masteragent, agent, lowerbound, upperbound, upperbound_, utility_loss, time_subproblem, time_master] = bendersDecomposition(masteragent, agent, env_parameters)

    upperbound_ = []; 
    iter = 1; 
    while iter <= env_parameters.ITER       
        %% Master agent calculates the boundary obfuscation vectors
        obf_matrix = zeros(env_parameters.NR_NODE_IN_TARGET, env_parameters.NR_OBFLOC);     
        tic;  
        if iter == 0                                                        
            obf_matrix = ones(env_parameters.NR_NODE_IN_TARGET, env_parameters.NR_OBFLOC)/env_parameters.NR_OBFLOC;      
            lowerbound(iter) = 0; 
        else
            [masteragent, agent, lowerbound(iter), is_cut] = masterProblem(masteragent, agent, env_parameters); 
            obf_matrix(masteragent.node, :) = masteragent.decision;
        end        
        time_master(iter)= toc; 
        %% Each agent calculates the internal obfuscation vectors
        tic; 
        for i = 1:1:env_parameters.NR_AGENT       
            if size(agent(i).node_internal, 2)*size(agent(i).node_internal, 1) > 0
                agent(i) = subProblem(agent(i), env_parameters, obf_matrix);
                upperbound_(iter, i) = agent(i).upperbound; 
                isunbounded(i) = agent(i).isunbounded; 
            end
        end
        time_subproblem(iter)= toc; 
        upperbound(iter) = sum(upperbound_(iter, :)); 
        obf_matrix = integrateZ(agent, env_parameters); 
    
        %% Each agent suggests the new cuts to the master agent
        masteragent = addNewCuts(masteragent, agent, env_parameters); 
        if upperbound(iter) - lowerbound(iter) < 0.001
            break; 
        end
        
        fprintf('Iteration %d ... \n', iter);
        iter = iter+1; 
    end

    %% Save the results
    save('.\Dataset\results\upperbound.mat', 'upperbound'); 
    save('.\Dataset\results\lowerbound.mat', 'lowerbound');
    save('.\Dataset\results\time_master.mat', 'time_master');
    save('.\Dataset\results\time_subproblem.mat', 'time_subproblem');
    utility_loss = upperbound(iter-1); 
end