clc
clear
close all

load("./data/fuzzyStaticModel.mat")
load("./data/weights.mat")

fuzzyStaticModel = FuzzyStaticModel(mf, params);


x0 = [5.50677; 0.132906; 0.0019752; 49.3818];
u0 = 0.016783;

y0 = x0(4)/x0(3);

t0 = 0;
tfinal = 1.5;

workpoint = struct('x0', x0, 'u0', u0, 'y0', y0, 't0', 0);

sim_length = 5000;

umin = 0.0016;
umax = 0.067;

% uVals = build_random_setpoints_array(workpoint, sim_length, 400, umin, umax);
load("./data/uTrajectory.mat")
load("./data/yTrajectory.mat")

u = uVals(1:sim_length) - u0;
y_m = 0*ones(1, sim_length);
y_static_0 = fuzzyStaticModel.getOutput(u0);
y_static = 0*ones(1, sim_length);

start= 5;
for k = start:sim_length
	y_static(k) = fuzzyStaticModel.getOutput(u(k)+u0)-y_static_0;
	k
	q = [y_m(k-1) y_m(k-2) u(k-1) u(k-2)];
	wtmp = w;
	if u(k) ~= 0
		wtmp(3:end) = w(3:end)*y_static(k)/u(k);
	end
	y_m(k) = (q*wtmp);
end


err = (y_m - y(1:sim_length)) * (y_m - y(1:sim_length))' / sim_length;


figure
	subplot(2, 1, 1)
		hold on;
		stairs(y(1:sim_length));
		stairs(y_m+y0);
		legend("Wyjœcie obiektu", "Wyjœcie modelu")
		title("Przebieg modelu Hammersteina")
		ylabel("y")
		xlabel("k")
	
	subplot(2, 1, 2)
		stairs(u(1:sim_length)+u0);
		ylabel("u")
		xlabel("k")