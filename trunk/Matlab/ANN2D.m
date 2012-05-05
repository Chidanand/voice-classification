function [err_train, err_test] = ANN2D(Ynew, Ytnew, Wnew, Wtnew, Znew, outputs)

% Create train and test data set for ANN 2D
N1 = size(Ynew,1);

if outputs == 3 % Number of output classes
    labels_t(:,1) = [ones(N1,1) ; zeros(N1,1) ; zeros(N1, 1)];
    labels_t(:,2) = [zeros(N1,1) ; ones(N1,1) ; zeros(N1, 1)];
    labels_t(:,3) = [zeros(N1,1) ; zeros(N1,1) ; ones(N1, 1)];  
    train_data = [Ynew(:,[1 2]) ; Wnew(:,[1 2]) ; Znew(:,[1 2])];
    test_data = [Ytnew(:,[1 2]) ; Wtnew(:,[1 2]) ; Znew(:,[1 2])];
else
    labels_t(:,1) = [ones(N1,1) ; zeros(N1,1)];
    labels_t(:,2) = [zeros(N1,1) ; ones(N1,1)];
    train_data = [Ynew(:,[1 2]) ; Wnew(:,[1 2])];
    test_data = [Ytnew(:,[1 2]) ; Wtnew(:,[1 2])];
end

x1 = Ynew(:,1);
y1 = Ynew(:,2);
x2 = Wnew(:,1);
y2 = Wnew(:,2);
x3 = Znew(:,1);
y3 = Znew(:,2);

figure(2)
scatter(x1, y1, 'r'), hold on, scatter(x2, y2, 'g'), 
if outputs == 3 % Number of output classes
    scatter(x3, y3, 'b');
end

%% Set up network parameters.
% Artificial Neural Networks
outputfunc = 'logistic';  % output function
%outputfunc = 'softmax';  % output function
nin = 2;                % Number of inputs.
nout = outputs;         % Number of outputs.

% Parameters to vary
nhidden = 5;			% Number of hidden units.
alpha = 0.2;			% Coefficient of weight-decay prior. 

% Set up vector of options for the optimiser.
options = zeros(1,18);
options(1) = 1;			% This provides display of error values.
opt = 50;		% Number of training cycles. 

idx = 1;

% Find best hiden units
%start = 1;
%stop = 30;
%for nhidden = start:stop 

% Find best training cycles
%start = 10;
%stop = 100;
%for opt = start:stop

% Find best alpha
start = 0.1;
stop = 0.2;
for alpha = start:0.01:stop    
    options(14) = opt;
    % create network (object)
    net = mlp(nin, nhidden, nout, outputfunc, alpha);
    % Train using scaled conjugate gradients.
    [net, options] = netopt(net, options, train_data, labels_t, 'scg');

    % Test on training set
    y_est = mlpfwd(net, train_data);
    Ctrain = confmat(y_est, labels_t);
    err_train(idx) = 1-sum(diag(Ctrain))/sum(Ctrain(:)) % correct classification percentage
   
    % Test on test set
    y_est = mlpfwd(net, test_data);
    Ctest = confmat(y_est, labels_t);
    err_test(idx) = 1-sum(diag(Ctest))/sum(Ctest(:)) % correct classification percentage

    idx = idx + 1;
end;

x = start:0.01:stop;
%x = start:stop;
figure(3), 
hold on
plot(x, err_train, 'b');
plot(x, err_test, 'r');
title('train error(blue) vs. test error (red)');
xlabel('alpha');


%% ANN.m reference 
% Test on test set
y_est = mlpfwd(net, test_data);
[max_val,max_id] = max(y_est'); % find max. values
t_est = max_id - 1 ; % id is 1,2,3.. in matlab - not 0,1,2..
if outputs == 2 % Number of output classes
    figure(2)
    scatter(x1(t_est(1:N1)==1), y1(t_est(1:N1)==1), 200, 'gx')
    scatter(x2(t_est(N1+1:end)==0), y2(t_est(N1+1:end)==0), 200, 'rx')
end

% draw decision boundary
xi=-4; xf=2; yi=-2; yf=4; 
inc=0.01;
xrange = xi:inc:xf;
yrange = yi:inc:yf;
[X Y]=meshgrid(xrange, yrange);
ygrid = mlpfwd(net, [X(:) Y(:)]);
ygrid(:,1) = ygrid(:,1)-ygrid(:,2); % difference between output 1 and 2 - will be 0 at decision boundary
ygrid = reshape(ygrid(:,1),size(X));
figure(2), contour(xrange, yrange, ygrid, [0 0], 'k-')

% calculate test and training set errors
y_est = mlpfwd(net, train_data);
Ctrain = confmat(y_est, labels_t)
err_train = 1-sum(diag(Ctrain))/sum(Ctrain(:)) % correct classification percentage

% on large test set..
y_est = mlpfwd(net, test_data);
Ctest = confmat(y_est, labels_t)
err_test = 1-sum(diag(Ctest))/sum(Ctest(:)) % correct classification percentage

