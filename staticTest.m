clear;
close all;
clc;

addpath('./abstraction')
addpath('./classes')
addpath('./..')

% TODO - use LINEAR REACTOR !!!
obj = Reactor();

workpoint = struct('u', 0.016783000000000, 'y', 2.499924398942497e+04, 'x', [5.506781396029581; 0.132905703708105; 0.001975327168259; 49.381685838254725] );
obj.resetToWorkPoint(workpoint);

sim_length = 10;
u = workpoint.u.*zeros(obj.nu, sim_length)+0.01;
y = workpoint.y.*ones(obj.ny, sim_length);

for i = 100:100:sim_length
	u(:, i:end) = u(i) + 0;
end

for k = 1:sim_length
	y(:, k) = obj.getOutput();
	obj.setControl(u(:, k));
	obj.nextIteration();
end

figure;
    stairs(y);
	
figure
	stairs(u)