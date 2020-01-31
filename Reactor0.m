classdef Reactor0 < AbstractObject
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
		
		workpoint
		t = [];
		x = [];
		y = [];
		u = [];
		
		uk, yk, xk, tk
	end
	
	methods
		function self = Reactor0(workpoint)
			ny = 1; nu = 1; nd = 0; Ts = 0.01;
			self@AbstractObject(ny, nu, nd, Ts);
			
			self.workpoint = workpoint;
			self.uk = workpoint.u0;
			self.yk = workpoint.y0;
			self.xk = self.workpoint.x0;
			self.tk = 0;
		end
		
		function setControl(self, control)
			self.uk = control + self.workpoint.u0;
		end
		
		function [output] = getOutput(self)
			output = self.yk - self.workpoint.y0;
		end
		
		function [y, t] = nextIteration(self)
			self.u = [self.u, self.uk];
			self.t  = [self.t self.tk];
			self.tk = self.tk + self.Ts;
			
			k1 = self.Ts * self.differential(self.xk, self.uk);
			k2 = self.Ts * self.differential(self.xk + k1/2, self.uk);
			k3 = self.Ts * self.differential(self.xk + k2/2, self.uk);
			k4 = self.Ts * self.differential(self.xk + k3, self.uk);

			self.xk = self.xk + (k1 + 2*k2 + 2*k3 + k4)/6;
			
			self.x = [self.x ; self.xk'];
			self.yk = self.xk(4)/self.xk(3);
			
		end
		
		function dx = differential(self, x, u)
			
			P_0 = sqrt((2 * self.f_p * x(2) * self.Z_I * exp(-self.E_I/(self.R*self.T))) ...
				/(self.Z_Td * exp(-self.E_Td/(self.R*self.T)) + self.Z_Tc * exp(-self.E_Tc/(self.R*self.T))));
			
			dx1 = -(self.Z_exp_ERT(self.Z_P, self.E_P) + self.Z_exp_ERT(self.Z_fm, self.E_fm)) * x(1) * P_0 ...
				- (self.F * x(1)) / self.V + (self.F * self.C_min) / self.V;
			
			dx2 = -(self.Z_exp_ERT(self.Z_I, self.E_I) * x(2)) - (self.F * x(2)) / self.V + (u * self.C_Iin) / self.V;
			
			dx3 = (0.5 * self.Z_exp_ERT(self.Z_Tc, self.E_Tc) + self.Z_exp_ERT(self.Z_Td, self.E_Td)) * P_0 * P_0 ...
				+ self.Z_exp_ERT(self.Z_fm, self.E_fm) * x(1) * P_0 - (self.F * x(3)) / self.V;
			
			dx4 = self.M_m * (self.Z_exp_ERT(self.Z_P, self.E_P) + self.Z_exp_ERT(self.Z_fm, self.E_fm)) * x(1) * P_0 ...
				- (self.F * x(4)) / self.V;
			
			dx = [dx1; dx2; dx3; dx4];
		end
		
		function e = Z_exp_ERT(self, Z, E)
			e = Z * exp(-E / (self.R*self.T));
		end
	end
end

