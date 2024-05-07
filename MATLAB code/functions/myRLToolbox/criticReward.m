function gradients = criticReward(critic_network, observation)

    gradients = dlfeval(@criticFunction, critic_network, observation);

end