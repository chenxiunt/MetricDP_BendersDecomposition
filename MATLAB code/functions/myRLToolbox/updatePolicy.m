function policyagent = updatePolicy(policyagent, rl_parameters)
    NR_ITER = size(policyagent.instant_reward, 1);
    for iter = 1:1:NR_ITER-1
        if policyagent.actions(iter, 1) > 0
            % states = [policyagent.states_is_selected(iter, :), policyagent.states_is_extreme(iter, :), policyagent.states_is_bounded(iter, 1)];
            states = [policyagent.states_is_extreme(iter, :), policyagent.states_is_bounded(iter, 1)];
            input_dlarray = dlarray(states', "CB"); 
    
            [gradients, action_probability] = policyDecision(policyagent.policy_network, input_dlarray, policyagent.actions(iter, 1)); 
            if action_probability == 0
                a = 0; 
            end
            
            action_probability = 1;
            % next_states = [policyagent.states_is_selected(iter+1, :), policyagent.states_is_extreme(iter+1, :), policyagent.states_is_bounded(iter+1, 1)];
            next_states = [policyagent.states_is_extreme(iter+1, :), policyagent.states_is_bounded(iter+1, 1)];
            next_input_dlarray = dlarray(next_states', "CB"); 
            next_action_value = predict(policyagent.critic_network, next_input_dlarray);
            current_action_value = predict(policyagent.critic_network, input_dlarray);
            % L1Regularizer = @(gradients, param) ((policyagent.G_reward(iter+1, 1) + rl_parameters.discount_factor*next_action_value-current_action_value)*rl_parameters.alpha/action_probability).*gradients + param; 
            
            L1Regularizer = @(gradients, param) (policyagent.G_reward(iter, 1)*rl_parameters.alpha/action_probability).*gradients + param;  % Vanilla reinforcement learning

            policyagent.policy_network.Learnables = dlupdate(L1Regularizer, gradients, policyagent.policy_network.Learnables);
        end
    end
end