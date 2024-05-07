function policyagent = policyAgentCriticCalculate(policyagent, rl_parameters)
    NR_ITER = size(policyagent.instant_reward, 1);
    for iter = 1:1:NR_ITER
        if policyagent.actions(iter, 1) > 0
            % states = [policyagent.states_is_selected(iter, :), policyagent.states_is_extreme(iter, :), policyagent.states_is_bounded(iter, 1)];
            states = [policyagent.states_is_extreme(iter, :), policyagent.states_is_bounded(iter, 1)];
            input_dlarray = dlarray(states', "CB"); 
            gradients = criticReward(policyagent.critic_network, input_dlarray); 
            estimated_reward = predict(policyagent.critic_network, input_dlarray); 

            policyagent.value_func_error(iter, 1) = abs((policyagent.G_reward(iter, 1) - estimated_reward)*rl_parameters.beta);           % record the estimation error of the value function

            L1Regularizer = @(gradients, param) ((policyagent.G_reward(iter, 1) - estimated_reward)*rl_parameters.beta).*gradients + param;
            policyagent.critic_network.Learnables = dlupdate(L1Regularizer, gradients, policyagent.critic_network.Learnables);
        end
    end
end