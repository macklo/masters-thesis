clc
clear
close all

load("./data/fuzzyStaticModel.mat")

fuzzyStaticModel = FuzzyStaticModel(mf, params);

x0 = [5.50677; 0.132906; 0.0019752; 49.3818];
u0 = 0.016783;

y0 = x0(4)/x0(3);

t0 = 0;
tfinal = 1.5;

workpoint = struct('x0', x0, 'u0', u0, 'y0', y0, 't0', 0);

sim_length = 10000;

umin = 0.0016;
umax = 0.067;

% uVals = build_random_setpoints_array(workpoint, sim_length, 400, umin, umax);
load("./data/uTrajectory.mat")
load("./data/yTrajectory.mat")

u = uVals(1:sim_length);
% y = workpoint.y0.*ones(1, sim_length);
% y_static = workpoint.y0.*ones(1, sim_length);
% obj = Reactor(workpoint);
% for k = 1:sim_length
% 	k
%     
%     output = obj.getOutput();
%     control = u(k);
% 	obj.setControl(control);
%     obj.nextIteration();
% 	y(:, k) = obj.getOutput();
% 	y_static(k) = fuzzyStaticModel.getOutput(u(k));
% end

figure
	subplot(2, 1, 1)
		hold on;
		stairs(t, y, 'b');
		stairs(t, y_static, 'r');
		legend("y")
		title("Wyjœcie")
		ylabel("Œrednie stê¿enie")
		xlabel("t [h]")
	
	subplot(2, 1, 2)
		stairs(t, u(1:sim_length), 'r');
		legend("u")
		title("Sterowanie")
		ylabel("F_I [m^3/h]")
		xlabel("t [h]")
		%u(3:end)' u(2:end-1)' u(1:end-2)'
Y = y(10:end)';
M = [ y_static(9:end-1)' y_static(8:end-2)' y_static(7:end-3)'  u(9:end-1)' u(8:end-2)' u(7:end-3)' u(6:end-4)' y(9:end-1)' y(8:end-2)' y(7:end-3)' y(6:end-4)'];
w = M\Y;
% w = w/sum(w);
alfa = 0.05;
y_m = workpoint.y0.*ones(1, sim_length);
x = zeros(2, sim_length);
T1 = 1;
T2 = 1;
K = 2;

for k = 10:sim_length
	k
	q = [y_static(k-1) y_static(k-2) y_static(k-3) u(k-1) u(k-2) u(k-3) u(k-4) y_m(k-1) y_m(k-2) y_m(k-3) y_m(k-4)];
	y_m(k) = q*w;
end

err = (y_m - y) * (y_m - y)' / sim_length;

figure
	subplot(2, 1, 1)
		hold on;
		stairs(t, y, 'b');
		stairs(t, y_m, 'r');
		legend("y", "y_m")
		title("Wyjœcie")
		ylabel("Œrednie stê¿enie")
		xlabel("t [h]")
	
	subplot(2, 1, 2)
		stairs(t, u(1:sim_length), 'r');
		legend("u")
		title("Sterowanie")
		ylabel("F_I [m^3/h]")
		xlabel("t [h]")
		
save("data/weights.mat", "w");