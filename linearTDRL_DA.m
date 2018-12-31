function results = linearTDRL_DA(X,r,W,alpha,opto,optotype)
    
    % Linear TD-RL algorithm
    %
    % USAGE: results = linearTDRL(X,r,W,alpha,opto,optotype)
    %
    % INPUTS:
    %   X - [N x D] stimulus sequence (N = # trials, D = # features)
    %   r - [N x 1] reward sequence
    %   W (optional) - initial values of the features (default: all zeros)
    %   alpha (optional) - learning rate (default: 0.05)
    %   opto (optional) - sequence of optogenetic perturbations (default: all zeros)
    %   optotype (optional) - string of 'none' (default) or 'tonic' for
    %                         prolonged stimulation or 'phasic' for short
    %                         stimulation
    %
    % OUTPUTS:
    %   results - [N x 1] structure with the following fields:
    %               .V - value estimate
    %               .dt - prediction error
    %               .W - weight matrix
    %
    % Matt Gardner, 2018 based on Sam Gershman's code
    
    [N,D] = size(X);
    X = [X; zeros(1,D)];% add buffer at the end
    r = [r; 0];
    
    if nargin < 3
        W = zeros(D,1); alpha = 0.05; opto = zeros(N,1); optotype = 'none';
    elseif nargin < 4
        W = zeros(D,1); opto = zeros(N,1); optotype = 'none';
    elseif nargin < 5
        opto = zeros(N,1); optotype = 'none';
    elseif nargin < 6
        disp('the optotype input is missing')
        return
    end
    
    gamma = 0.95;
 
    results(1).V = X(1,:)*W;
    results(1).W = W;
    results(1).dW = 0;
    
    %For these experiments, we're only using currently active elements for
    %opto stimulation such that lambda = 0
    lambda = 0;
    E = 0;
    
    for n = 2:N
         
        switch optotype
            
            case 'none'
                dt = r(n) + (gamma*X(n,:) - X(n - 1,:))*W;
                %dt = r(n + 1) + (gamma*X(n + 1,:) - X(n,:))*W;
            case 'tonic'
                dt = (1 + opto(n))*(r(n) + (gamma*X(n,:) - X(n - 1,:))*W);
                
            case 'phasic'
                E = lambda*E + X(n,:);
                dt = r(n) + (gamma*X(n,:) - X(n - 1,:))*W + opto(n)*E;

            case 'V' 
                dt = r(n) + (gamma*X(n,:)*(1 + opto(n)) - (1 + opto(n - 1))*X(n - 1,:))*W; 
         
        end
        
        % store results
        results(n).V = X(n,:)*W;
        results(n).W = W;
        results(n).dW = dt;
        
        % update
        W = W + (alpha.*X(n-1,:)')*dt;
        
    end