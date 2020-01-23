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
plot(uVals)

u = uVals(1:sim_length);
y = workpoint.y0.*ones(1, sim_length);
y_static = workpoint.y0.*ones(1, sim_length);
obj = Reactor(workpoint);
for k = 1:sim_length
	k
    
    output = obj.getOutput();
    control = u(k);
	obj.setControl(control);
    obj.nextIteration();
	y(:, k) = obj.getOutput();
	y_static(k) = fuzzyStaticModel.getOutput(u(k));
end

figure
	subplot(2, 1, 1)
		hold on;
		stairs(obj.t, y, 'b');
		legend("y")
		title("Wyjœcie")
		ylabel("Œrednie stê¿enie")
		xlabel("t [h]")
	
	subplot(2, 1, 2)
		stairs(obj.t, u(1:sim_length), 'r');
		legend("u")
		title("Sterowanie")
		ylabel("F_I [m^3/h]")
		xlabel("t [h]")
		%u(3:end)' u(2:end-1)' u(1:end-2)'
Y = y(3:end)';
M = [y_static(3:end)' y(2:end-1)' y(3:end)'];
w = M\Y;
alfa = 0.05;
y_m = workpoint.y0.*ones(1, sim_length);
x = zeros(2, sim_length);

T1 = 1;
T2 = 1;
K = 2;

for k = 3:sim_length
	k
	q = [fuzzyStaticModel.getOutput(u(k)) y_m(k-1)];
	y_m(k) = q*w;
end

figure
	subplot(2, 1, 1)
		hold on;
		stairs(obj.t, y, 'b');
		stairs(obj.t, y_m, 'r');
		legend("y", "y_m")
		title("Wyjœcie")
		ylabel("Œrednie stê¿enie")
		xlabel("t [h]")
	
	subplot(2, 1, 2)
		stairs(obj.t, u(1:sim_length), 'r');
		legend("u")
		title("Sterowanie")
		ylabel("F_I [m^3/h]")
		xlabel("t [h]")