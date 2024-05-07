function [gradients, action_probability] = policyDecision(policy_network, observation, action_idx)

    % Forward data through network.
    % [Y,state] = forward(net, input);
    
    % Calculate cross-entropy loss.
    % loss = crossentropy(Y, T);
    % loss = max(Y); 
    
    % Calculate gradients of loss with respect to learnable parameters.
    % y = policy_function(net, x); 
    % [y, state] = forward(net, x);
    % loss = crossentropy(y, y);

    % gradients = dlfeval(loss, net.Learnables);
    % gradients = dlgradient(loss, net.Learnables);
    [gradients, action_probability] = dlfeval(@policyFunction, policy_network, observation, action_idx);

end