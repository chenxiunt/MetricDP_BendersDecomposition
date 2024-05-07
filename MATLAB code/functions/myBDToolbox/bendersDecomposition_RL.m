function [masteragent, agent] = bendersDecomposition_RL(env_parameters, rl_parameters, masteragent, agent)
    
    rng(0)
    
    env = MyBDEnvironment(env_parameters, masteragent, agent);
    obsInfo = getObservationInfo(env);
    actInfo = getActionInfo(env);
    numObs = obsInfo.Dimension(1);
    numAct = numel(actInfo.Elements);
    
    actorNetwork = [
        featureInputLayer(numObs)
        fullyConnectedLayer(24)
        reluLayer
        fullyConnectedLayer(24)
        reluLayer
        fullyConnectedLayer(2)
        softmaxLayer
        ];

    % actorNetwork = [
    %     featureInputLayer(numObs)
    %     fullyConnectedLayer(24)
    %     reluLayer
    %     fullyConnectedLayer(24)
    %     reluLayer
    %     fullyConnectedLayer(231)
    %     softmaxLayer
    % ];
    
    actorNetwork = dlnetwork(actorNetwork); 
    summary(actorNetwork)
    actor = rlDiscreteCategoricalActor(actorNetwork,obsInfo,actInfo);
    actor = accelerate(actor,true);
    actorOpts = rlOptimizerOptions(LearnRate=1e-3);
    
    options.MaxStepsPerEpisode = rl_parameters.max_steps_per_episode;
    options.DiscountFactor = rl_parameters.discount_factor;
    options.OptimizerOptions = actorOpts;
    
    PGAgent = MyPGAgent(actor,options);
    
    % numEpisodes = 5000;
    aveWindowSize = 100;
    trainingTerminationValue = 220;
    trainOpts = rlTrainingOptions(...
        MaxEpisodes=rl_parameters.num_episodes,...
        MaxStepsPerEpisode=options.MaxStepsPerEpisode,...
        ScoreAveragingWindowLength=aveWindowSize,...
        StopTrainingValue=trainingTerminationValue);
    
    doTraining = true;
    if doTraining
        % Train the agent.
        trainStats = train(PGAgent,env,trainOpts);
    else
        % Load pretrained agent for the example.
        load("myRLAgent.mat","agent");
    end
end