classdef Reactor < handle
	properties
		Z_Tc = 3.8223e10;
		Z_Td = 3.1457e11;
		Z_I  = 3.7920e18;
		Z_P  = 1.7700e9;
		Z_fm = 1.0067e15;
		
		E_Tc = 2.9442e3;
		E_Td = 2.9442e3;
		E_I  = 1.2550e5;
		E_P  = 1.8283e4;
		E_fm = 7.4478e4;
		
		f_p  = 0.58;
		
		F     = 1.00;
		V     = 0.1;
		C_Iin = 8.0;
		y_sp  = 25000.5;
		F_I   = 0.016783;
		R     = 8.314;
		M_m   = 100.12;
		C_min = 6.0;
		T     = 335;
		
		Ts = 0.01;
		workpoint
		t = [];
		x = [];
		y = [];
		u = [];
		iteration = 1;
	end
	
	methods
		function obj = Reactor(workpoint)
			obj.workpoint = workpoint;
			obj.x = workpoint.x0;
			obj.t = workpoint.t0;
			obj.y = workpoint.y0;
			obj.u = workpoint.u0;
		end
		
		function [y, t] = simulate(obj, u)
			obj.t = [obj.t obj.t + obj.Ts];
			
			P_0 = sqrt((2 * obj.f_p * x(2) * obj.Z_I * exp(-obj.E_I/(obj.R*obj.T))) ...
				/(obj.Z_Td * exp(-obj.E_Td/(obj.R*obj.T)) + obj.Z_Tc * exp(-obj.E_Tc/(obj.R*obj.T))));
			
			dx1 = -(obj.Z_exp_ERT(obj.Z_P, obj.E_P) + obj.Z_exp_ERT(obj.Z_fm, obj.E_fm)) * x(1) * P_0 ...
				- (obj.F * x(1)) / obj.V + (obj.F * obj.C_min) / obj.V;
			
			dx2 = -(obj.Z_exp_ERT(obj.Z_I, obj.E_I) * x(2)) - (obj.F * x(2)) / obj.V + (u * obj.C_Iin) / obj.V;
			
			dx3 = (0.5 * obj.Z_exp_ERT(obj.Z_Tc, obj.E_Tc) + obj.Z_exp_ERT(obj.Z_Td, obj.E_Td)) * P_0 * P_0 ...
				+ obj.Z_exp_ERT(obj.Z_fm, obj.E_fm) * x(1) * P_0 - (obj.F * x(3)) / obj.V;
			
			dx4 = obj.M_m * (obj.Z_exp_ERT(obj.Z_P, obj.E_P) + obj.Z_exp_ERT(obj.Z_fm, obj.E_fm)) * x(1) * P_0 ...
				- (obj.F * x(4)) / obj.V;
			
			x = obj.x(obj.iteration, 1);
			
			dx = obj.differential(x, u)
			
			k1 = obj.Ts * obj.differential(x, u);
			k2 = obj.Ts * obj.differential(
			
			x1 = obj.x(obj.iteration, 1) + Ts (obj.Ts * dx1
		end
		
% 		function [t, x] = simulate(obj, x0, u0, t0, tfinal)
% 			[t, x] = ode45(@(t, x) obj.differential(t, x, u0), t0:obj.Ts:tfinal, x0);
% 		end
		
		function dx = differential(obj, ~, x, u)
			
			P_0 = sqrt((2 * obj.f_p * x(2) * obj.Z_I * exp(-obj.E_I/(obj.R*obj.T))) ...
				/(obj.Z_Td * exp(-obj.E_Td/(obj.R*obj.T)) + obj.Z_Tc * exp(-obj.E_Tc/(obj.R*obj.T))));
			
			dx1 = -(obj.Z_exp_ERT(obj.Z_P, obj.E_P) + obj.Z_exp_ERT(obj.Z_fm, obj.E_fm)) * x(1) * P_0 ...
				- (obj.F * x(1)) / obj.V + (obj.F * obj.C_min) / obj.V;
			
			dx2 = -(obj.Z_exp_ERT(obj.Z_I, obj.E_I) * x(2)) - (obj.F * x(2)) / obj.V + (u * obj.C_Iin) / obj.V;
			
			dx3 = (0.5 * obj.Z_exp_ERT(obj.Z_Tc, obj.E_Tc) + obj.Z_exp_ERT(obj.Z_Td, obj.E_Td)) * P_0 * P_0 ...
				+ obj.Z_exp_ERT(obj.Z_fm, obj.E_fm) * x(1) * P_0 - (obj.F * x(3)) / obj.V;
			
			dx4 = obj.M_m * (obj.Z_exp_ERT(obj.Z_P, obj.E_P) + obj.Z_exp_ERT(obj.Z_fm, obj.E_fm)) * x(1) * P_0 ...
				- (obj.F * x(4)) / obj.V;
			
% 			dx1 = 10 * (6 - x(1)) - 2.4568 * x(1) * sqrt(x(2));
% 			dx2 = 80 * u - 10.1022 * x(2);
% 			dx3 = 0.0024121 * x(1) * sqrt(x(2)) + 0.112191 - 10 *x(3);
% 			dx4 = 245.978 * x(1) * sqrt(x(2)) - 10 * x(4);

			dx = [dx1; dx2; dx3; dx4];
		end
		
		function e = Z_exp_ERT(obj, Z, E)
			e = Z * exp(-E / (obj.R*obj.T));
		end
	end
end

