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

r = FuzzyReactor(14, 14:-1:1);

figure
	hold on
	grid on
	title("Odpowiedzi obiektu na skoki sterowania")
	xlabel('t [h]')
	ylabel('y')
legends = [];
uValues = [];
jumps = -0.8:0.1:0.5;
staticVals = [];

for mult = jumps
	u = u0 + mult * u0;
	uValues = [uValues; u];
	legends = [legends u];
	
	react = FuzzyReactor(14, 14:-1:1);
	react.resetToWorkPoint(workpoint);
	for t = 1:250
		t
		if t>100
			uk = u;
		else
			uk = u0;
		end
		react.setControl(uk);
		react.nextIteration();
		yRK(t) = react.getOutput();
	end

	x = react.x;
	
	stairs(0:r.Ts:1.5, yRK(100:end))
	staticVals = [staticVals; yRK(end)];
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