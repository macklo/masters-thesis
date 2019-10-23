clear;
close all;
clc;

addpath('./abstraction')
addpath('./classes')
addpath('./..')

% TODO - use LINEAR REACTOR !!!
obj = NonlinearReactor();

workpoint = struct('u', 0.016783000000000, 'y', 2.499924398942497e+04, 'x', [5.506781396029581; 0.132905703708105; 0.001975327168259; 49.381685838254725] );
obj.resetToWorkPoint(workpoint);

sim_length = 2000;

s = cell(obj.ny, obj.nu);

start = 1000;

for n = 1:obj.nu
    u = workpoint.u.*ones(obj.nu, sim_length);
    y = workpoint.y.*ones(obj.ny, sim_length);
    u(n, start:end) = workpoint.u(n) + 1;
    for k = 1:sim_length
        y(:, k) = obj.getOutput();
        obj.setControl(u(:, k));
        obj.nextIteration();
    end
    obj.resetToWorkPoint(workpoint);
    for m = 1:obj.ny
        s{m, n} = y(m, start+1:end) - y(m, start);
    end
end

save('./data/s.mat', 's');
figure;
    stairs(s{1, 1});
	
figure
	stairs(y)