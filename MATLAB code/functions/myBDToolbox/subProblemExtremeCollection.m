function agent = subProblemExtremeCollection(agent, env_parameters, Z) 
    NR_NODE = size(agent.node, 2); 
    env_parameters.NR_NODE_INTRASET = size(agent.node_internal, 2); 
    NR_NODE_INTERSET = size(agent.node_boundary, 2)*size(agent.node_boundary, 1); 
    agent.isunbounded = 0; 
    agent.isupdated = 0; 
    agent.decision = []; 
    y = Z(agent.node_boundary',:); 
    y = reshape(y', NR_NODE_INTERSET*env_parameters.NR_OBFLOC, 1);

    c = env_parameters.cost_matrix(agent.node_internal', :);
    c = reshape(c', env_parameters.NR_NODE_INTRASET*env_parameters.NR_OBFLOC, 1); 
    d = env_parameters.cost_matrix(agent.node_boundary', :); 
    d = reshape(d', NR_NODE_INTERSET*env_parameters.NR_OBFLOC, 1);


    A_dp = agent.GeoI(:, 1:env_parameters.NR_NODE_INTRASET*env_parameters.NR_OBFLOC);
    B_dp = agent.GeoI(:, env_parameters.NR_NODE_INTRASET*env_parameters.NR_OBFLOC+1:(env_parameters.NR_NODE_INTRASET+NR_NODE_INTERSET)*env_parameters.NR_OBFLOC);

    A_um = sparse(env_parameters.NR_NODE_INTRASET, env_parameters.NR_NODE_INTRASET*env_parameters.NR_OBFLOC); 

    for k = 1:1:env_parameters.NR_NODE_INTRASET
        for l = 1:1:env_parameters.NR_OBFLOC
            A_um(k, (k-1)*env_parameters.NR_OBFLOC + l) = 1;
        end
    end   
    % A_I = -eye(env_parameters.NR_NODE_INTRASET*env_parameters.NR_OBFLOC, env_parameters.NR_NODE_INTRASET*env_parameters.NR_OBFLOC);

    zero_s = -ones(size(agent.GeoI, 1), 1)*env_parameters.DELTA; 
    zero_y = sparse(env_parameters.NR_NODE_INTRASET, NR_NODE_INTERSET*env_parameters.NR_OBFLOC);
    % zero_I = sparse(env_parameters.NR_NODE_INTRASET*env_parameters.NR_OBFLOC, NR_NODE_INTERSET*env_parameters.NR_OBFLOC);

    ones_x = ones(env_parameters.NR_NODE_INTRASET, 1);

    % b_I = -ones(env_parameters.NR_NODE_INTRASET*env_parameters.NR_OBFLOC, 1)*0.0001;

	lb = zeros(env_parameters.NR_NODE_INTRASET*env_parameters.NR_OBFLOC, 1);
    ub = [];

    
    A = [-A_dp; -A_um; A_um];
    B = [-B_dp; zero_y; zero_y]; 
    b = [zero_s; -ones_x; ones_x];
    

    %% Primal problem
    % options = optimoptions('linprog','Algorithm','dual-simplex', 'Display', 'off');
    options = optimoptions('linprog','Algorithm','dual-simplex','Preprocess', 'none');
    options.MaxIterations = 10000; 
    % cost_vector = abs(normrnd(3,10,[2500,1])); 

    agent.idx

    [z, pfval, exitflag] = linprog(c, -A, -(b-B*y), [], [], lb, ub, options);
    if exitflag == 1
        agent.decision = reshape(z, env_parameters.NR_OBFLOC, env_parameters.NR_NODE_INTRASET); 
        agent.decision = agent.decision';
    end

    %% Dual problem
    lb = zeros(size(A, 1), 1);
    ub = [];

    options = optimoptions('linprog','Algorithm','dual-simplex','Preprocess', 'none');
    options.MaxIterations = 10000; 
    [u, fval, exitflag, ~, ~] = linprog(-(b-B*y), A', c, [], [], lb, ub, options); 

    if exitflag == -3
        agent.isunbounded = 1; 
        agent.upperbound = 9999;
        options = optimoptions('linprog','Algorithm','dual-simplex','Preprocess', 'none');
        options.MaxIterations = 10000; 
        [u, ~, ~, ~, ~] = linprog([], A', zeros(size(c)), (b-B*y)', 1, lb, ub, options);
        u = u/sqrt(sum(u.^2));
        isRepeated = checkRepeatedExtreme(agent.extremerays, u); 
        if isRepeated == 0
            agent.extremerays = [agent.extremerays, u];
            agent.new_cut_A_unbounded = -u'*B; 
            agent.new_cut_b_unbounded = -u'*b; 
            agent.new_cut_A_bounded = []; 
            agent.new_cut_b_bounded = [];
        else
            agent.new_cut_A_unbounded = -u'*B; 
            agent.new_cut_b_unbounded = -u'*b; 
            agent.new_cut_A_bounded = []; 
            agent.new_cut_b_bounded = [];
        end
    else 
        if pfval ~= fval
            a = 0; 
        end
        agent.upperbound = -fval+d'*y;
        % agent.upperbound = pfval+d'*y;
        agent.isunbounded = 0;    
        % if -fval + d'*y > agent.z
        if pfval + d'*y > agent.z
            agent.isupdated = 1;
            agent.new_cut_A_bounded = d'-u'*B;
            agent.new_cut_b_bounded =  - u'*b;
        else
            agent.isupdated = 0;
            agent.new_cut_A_bounded = [];
            agent.new_cut_b_bounded = [];
        end
        
        agent.new_cut_A_unbounded = [];
        agent.new_cut_b_unbounded = [];
    end
     
end