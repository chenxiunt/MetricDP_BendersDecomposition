function [gradients, action_probability]  = policyFunction(net, x, action_idx)
    [action_distribution, ~] = forward(net, x);
    % Calculate cross-entropy loss.
    % loss = sum(y);
    action_probability = action_distribution(action_idx);
    gradients = dlgradient(action_probability, net.Learnables);
end