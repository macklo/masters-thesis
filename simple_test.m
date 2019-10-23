clear;
close all;
clc;

addpath('./abstraction')
addpath('./classes')
addpath('./..')

obj = NonlinearReactor();

workpoint = struct('u', 0.016783000000000, 'y', 2.499924398942497e+04, 'x', [5.506781396029581; 0.132905703708105; 0.001975327168259; 49.381685838254725] );
obj.resetToWorkPoint(workpoint);

umin = -100;
umax = 100;
dumax = 100;

D = 1000;
N = 100;
Nu = 100;
lambda = 1;
psii = 1;
sim_length = 10000;

load('./data/s.mat', 's');
reg = DMC_Regulator(obj, workpoint, s, D, N, Nu, lambda, psii, umin, umax, dumax);

u = workpoint.u.*ones(obj.nu, sim_length);

y = build_random_setpoints_array(workpoint, 10000, 1000, workpoint.y - 0.1, workpoint.y + 0.1);

setPoints = y;

for k = 1:sim_length
    output = obj.getOutput();
    y(:, k) = output;
    control = reg.calculate(output, setPoints(:, k));
    u(:, k) = control';
    obj.setControl(control);
    obj.nextIteration();
end

figure;
	stairs(u(1, :), 'r');
	title("u")
	
figure;
	hold on;
	stairs(setPoints(1, :), 'b');
	stairs(y(1, :), 'r');
	title("y")
	legend("yzad", "y")
	
