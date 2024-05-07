function policyagent = resetPolicyagent(policyagent, agent, env_parameters)
    for i = 1:1:env_parameters.NR_AGENT
        nr_extremerays = size(agent(i).extremerays, 2);
        policyagent(i).states_is_extreme = zeros(env_parameters.ITER, nr_extremerays); 
        policyagent(i).states_is_selected = zeros(env_parameters.ITER, nr_extremerays); 
        policyagent(i).instant_reward = zeros(env_parameters.ITER, 1); 
        policyagent(i).G_reward = zeros(env_parameters.ITER, 1);
        policyagent(i).states_is_bounded = zeros(env_parameters.ITER, 1); 
        policyagent(i).actions = zeros(env_parameters.ITER, 1); 
        policyagent(i).actions_distribution = zeros(env_parameters.ITER, nr_extremerays);
    end
end