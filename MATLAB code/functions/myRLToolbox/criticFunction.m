function gradients  = criticFunction(net, x)
    reward = forward(net, x);
    gradients = dlgradient(reward, net.Learnables);
end