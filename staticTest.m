close all
clear
clc

addpath('./abstraction')
addpath('./classes')
addpath('./..')

x0 = [5.50677; 0.132906; 0.0019752; 49.3818];
% x0 = [1 1 1 1];
u0 = 0.016783;

y0 = x0(4)/x0(3);

workpoint = struct('x0', x0, 'u0', u0, 'y0', y0, 't0', 0);

t0 = 0;
tfinal = 1.5;

r = Reactor(workpoint);

figure
	hold on
	grid on
	title("Odpowiedzi obiektu na skoki sterowania")
	xlabel('t [h]')
	ylabel('y')
legends = [];
uValues = [];
jumps = -0.9:0.2:3;
staticVals = [];
xVals = {};
workpoints = {};

for mult = jumps
	u = u0 + mult * u0;
	uValues = [uValues; u];
	legends = [legends u];
% 	[t, x] = r.simulateODE(x0, u, t0, tfinal);
% 	yODE = x(:,4)./x(:, 3);
% 	stairs(t, yODE)
	
	react = Reactor(workpoint);
	for t = t0:r.Ts:tfinal
		react.setControl(u);
		react.nextIteration();
	end

	x = react.x;
	yRK = x(:,4)./x(:, 3);
	
	stairs(t0:r.Ts:tfinal, yRK)
	staticVals = [staticVals; yRK(end)];
	xVals = [xVals, x(end, :)];
	workpoints = [workpoints, struct('x0', x(end, :), 'u0', u, 'y0', yRK(end), 't0', 0)];
end

figure
	hold on
	grid on

	for i = 1:size(uValues, 1)
		scatter(uValues(i), staticVals(i), 'filled');
	end
	
	plot(uValues, staticVals);
	
	title("Charakterystyka statyczna")
	xlabel('u')
	ylabel('y')
	
% save("./data/staticValues.mat", "staticVals", "uValues")