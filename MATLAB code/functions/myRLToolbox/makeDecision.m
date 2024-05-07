function [policyagent, extreme_idx] = makeDecision(policyagent, iter)
% UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    % policyagent.states_is_bounded(iter, 1) = 1 - agent.isunbounded; 
    % input_dlarray = dlarray([policyagent.states_is_selected(iter, :), policyagent.states_is_extreme(iter, :), policyagent.states_is_bounded(iter, 1)]', "CB");
    input_dlarray = dlarray([policyagent.states_is_extreme(iter, :), policyagent.states_is_bounded(iter, 1)]', "CB");
    probability_array = predict(policyagent.policy_network, input_dlarray); 
    policyagent.actions_distribution(iter, :) = probability_array; 
    probability_array_ = cumsum(extractdata(probability_array)); 
    probability_array_ = [0, probability_array_']; 
    seed = rand; 
    for i = 1:1:size(probability_array_, 2)-1
        if seed > probability_array_(1, i) && seed <= probability_array_(1, i+1)
            extreme_idx = i; 
        end
    end
    % policyagent.states_is_selected(1, extreme_idx) = 1;
    policyagent.actions(iter, 1) = extreme_idx;
end