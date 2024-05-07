function Z = integrateZ(agent, env_parameters)
    Z = zeros(env_parameters.NR_NODE_IN_TARGET, env_parameters.NR_OBFLOC); 
    NR_AGENT = size(agent, 2); 
    for i = 1:1:NR_AGENT
        if size(agent(i).decision, 1)*size(agent(i).decision, 2) > 0
            Z(agent(i).node_internal, :) = agent(i).decision; 
        end
    end
end