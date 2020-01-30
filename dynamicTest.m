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

sim_length = 10000;

umin = 0.0016;
umax = 0.067;

% uVals = build_random_setpoints_array(workpoint, sim_length, 400, umin, umax);
load("./data/uTrajectory.mat")
load("./data/yTrajectory.mat")

u = uVals(1:sim_length);
y_m = y0*ones(1, sim_length);
y_static_0 = fuzzyStaticModel.getOutput(u0);
y_static = y_static_0*ones(1, sim_length);

start= 400;
for k = start:sim_length
	y_static(k) = fuzzyStaticModel.getOutput(u(k));
	k
	q = [y_m(k-1) y_m(k-2) y_m(k-3) y_m(k-4) u(k) u(k-1) u(k-2) u(k-3) u(k-4)];
	wtmp = w;
	wtmp(5:end) = w(5:end)*((y_static(k)-y0)/(u(k)-u0));
	y_m(k) = (q*wtmp);
end


% err = (y_m - y) * (y_m - y)' / sim_length;


figure
	subplot(2, 1, 1)
		hold on;
		stairs(y(1:sim_length), 'b');
		stairs(y_m, 'r');
		stairs(y_static)
		legend("y", "y_m", "y static")
		title("Wyjœcie")
		ylabel("Œrednie stê¿enie")
		xlabel("t [h]")
	
	subplot(2, 1, 2)
		stairs(u(1:sim_length), 'r');
		legend("u")
		title("Sterowanie")
		ylabel("F_I [m^3/h]")
		xlabel("t [h]")