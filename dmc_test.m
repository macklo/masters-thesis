clear;
close all;
clc;

addpath('./abstraction')
addpath('./classes')
addpath('./..')

x0 = [5.50677; 0.132906; 0.0019752; 49.3818];
u0 = 0.016783;

y0 = x0(4)/x0(3);

workpoint = struct('x0', x0, 'u0', u0, 'y0', y0, 't0', 0);
obj = Reactor(workpoint);

umin = 0.01;
umax = 0.02;
dumax = 0.1;

D = 200;
N = 200;
Nu = 200;
lambda = 1000;
psii = 1;
sim_length = 3000;

setPoints = build_random_setpoints_array(workpoint, sim_length, 300, 24900 , 25100);

load('./data/s.mat', 's');
reg = DMC_Regulator(obj, workpoint, s, D, N, Nu, lambda, psii, umin, umax, dumax);

u = workpoint.u0.*ones(1, sim_length);
y = workpoint.y0.*ones(1, sim_length);
output = workpoint.y0;

for k = 1:sim_length
	k
    
    y(:, k) = output;
    control = reg.calculate(output, setPoints(:, k));
    u(:, k) = control';
    obj.nextIteration(control);
	output = obj.x(end, 4)/obj.x(end, 3);
end

figure;
	stairs(u, 'r');

figure;
	hold on;
	stairs(setPoints, 'b');
	stairs(y, 'r');

e = (y - setPoints)*(y - setPoints)';