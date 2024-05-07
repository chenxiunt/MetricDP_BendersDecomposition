function policyagent = policyAgentGCalculate(policyagent, rl_parameters)
    %UNTITLED2 Summary of this function goes here
    %   Detailed explanation goes here
    NR_ITER = size(policyagent.instant_reward, 1);
    for iter = NR_ITER:-1:1
        if iter == NR_ITER
            policyagent.G_reward(iter, 1) = policyagent.instant_reward(iter, 1); 
        else
            policyagent.G_reward(iter, 1) = policyagent.instant_reward(iter, 1) + policyagent.G_reward(iter+1, 1)*rl_parameters.discount_factor;
        end
    end
end