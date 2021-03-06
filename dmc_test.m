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

umin = 0.0016;
umax = 0.067;
dumax = 0.004;

D = 200;
N = 200;
Nu = 200;
lambda = 1e8;
psii = 1;
sim_length = 3000;

% setPoints = build_random_setpoints_array(workpoint, sim_length, 300, 13000, 50000);
load("data/setPoints.mat")

load('./data/s.mat', 's');
reg = DMC_Regulator(obj, workpoint, s, D, N, Nu, lambda, psii, umin, umax, dumax);

u = workpoint.u0.*ones(1, sim_length);
y = workpoint.y0.*ones(1, sim_length);

for k = 1:sim_length
	k
    
    output = obj.getOutput();
    control = reg.calculate(output, setPoints(:, k));
    u(:, k) = control';
	obj.setControl(control);
    obj.nextIteration();
	y(:, k) = obj.getOutput();
end

figure
	subplot(2, 1, 1)
		hold on;
		stairs(obj.t, setPoints);
		stairs(obj.t, y);
		legend("y_{zad}", "y")
		title("Przebieg dla klasycznego DMC")
		ylabel("�rednie st�enie")
		xlabel("t [h]")
	
	subplot(2, 1, 2)
		stairs(obj.t, u);
		legend("u")
		title("Sterowanie")
		ylabel("F_I [m^3/h]")
		xlabel("t [h]")

e = (y - setPoints)*(y - setPoints)';