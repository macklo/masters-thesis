clear;
close all;
clc;

addpath('./abstraction')
addpath('./classes')
addpath('./..')

consts

obj = NonlinearReactor();

workpoint = struct('u', [2; 15], 'y', [0.2646; 393.9521], 'd', [323; 365]);
obj.resetToWorkPoint(workpoint);

umin = [0.1; 0.1];
umax = [4; 30];
dumax = [1; 2];

D = 800;
N = 100;
Nu = 80;
lambda = [2 0.1];
psii = 1;
sim_length = 6000;
load("data/setPoints.mat")
% setPoints = build_random_setpoints_array(workpoint, sim_length, 300, [0.2 385] , [0.3 400]);

load('./data/s.mat', 's');
reg = DMC_Regulator(obj, workpoint, s, D, N, Nu, lambda, psii, umin, umax, dumax);
nreg = Numeric_DMC_Regulator(obj, workpoint, s, D, N, Nu, lambda, psii, umin, umax, dumax);

u = workpoint.u.*ones(obj.nu, sim_length);
y = workpoint.y.*ones(obj.ny, sim_length);

for k = 1:sim_length
	k
    output = obj.getOutput();
    y(:, k) = output;
    control = reg.calculate(output, setPoints(:, k));
    u(:, k) = control';
    obj.setControl(control);
    obj.nextIteration();
end

figure;
for i = 1:2
    subplot(2, 1, i);
		stairs(u(i, :), 'r');
end

figure;
for i = 1:2
    subplot(2, 1, i);
        hold on;
        stairs(setPoints(i, :), 'b');
		stairs(y(i, :), 'r');
end

e = (y - setPoints)*(y - setPoints)';
e = [e(1, 1) e(2, 2)]