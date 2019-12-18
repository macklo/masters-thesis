classdef LinearReactor < AbstractObject
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
		u0, y0
		
		A = [];
		B = [];
		C = [];
		D = [];
	end
	
	methods
		function self = LinearReactor(workpoint)
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

			ny = 1; nu = 1; nd = 0; Ts = 0.01;
			self@AbstractObject(ny, nu, nd, Ts);
			
			self.workpoint = workpoint;
			self.uk = workpoint.u0;
			self.yk = workpoint.y0;
			self.xk = self.workpoint.x0;
			self.tk = 0;
			
			self.u0 = workpoint.u0;
			self.y0 = workpoint.y0;
			
			self.A = [
				- F/V - 2^(1/2)*(Z_P*exp(-E_P/(R*T)) + Z_fm*exp(-E_fm/(R*T)))*((Z_I*f_p*self.xk(2)*exp(-E_I/(R*T)))/(Z_Tc*exp(-E_Tc/(R*T)) + Z_Td*exp(-E_Td/(R*T))))^(1/2), -(2^(1/2)*Z_I*f_p*self.xk(1)*exp(-E_I/(R*T))*(Z_P*exp(-E_P/(R*T)) + Z_fm*exp(-E_fm/(R*T))))/(2*(Z_Tc*exp(-E_Tc/(R*T)) + Z_Td*exp(-E_Td/(R*T)))*((Z_I*f_p*self.xk(2)*exp(-E_I/(R*T)))/(Z_Tc*exp(-E_Tc/(R*T)) + Z_Td*exp(-E_Td/(R*T))))^(1/2)), 0, 0;
				0, - Z_I*exp(-E_I/(R*T)) - F/V, 0, 0;
				2^(1/2)*Z_fm*exp(-E_fm/(R*T))*((Z_I*f_p*self.xk(2)*exp(-E_I/(R*T)))/(Z_Tc*exp(-E_Tc/(R*T)) + Z_Td*exp(-E_Td/(R*T))))^(1/2), (2*Z_I*f_p*exp(-E_I/(R*T))*((Z_Tc*exp(-E_Tc/(R*T)))/2 + Z_Td*exp(-E_Td/(R*T))))/(Z_Tc*exp(-E_Tc/(R*T)) + Z_Td*exp(-E_Td/(R*T))) + (2^(1/2)*Z_I*Z_fm*f_p*self.xk(1)*exp(-E_I/(R*T))*exp(-E_fm/(R*T)))/(2*(Z_Tc*exp(-E_Tc/(R*T)) + Z_Td*exp(-E_Td/(R*T)))*((Z_I*f_p*self.xk(2)*exp(-E_I/(R*T)))/(Z_Tc*exp(-E_Tc/(R*T)) + Z_Td*exp(-E_Td/(R*T))))^(1/2)), -F/V, 0;
				2^(1/2)*M_m*(Z_P*exp(-E_P/(R*T)) + Z_fm*exp(-E_fm/(R*T)))*((Z_I*f_p*self.xk(2)*exp(-E_I/(R*T)))/(Z_Tc*exp(-E_Tc/(R*T)) + Z_Td*exp(-E_Td/(R*T))))^(1/2), (2^(1/2)*M_m*Z_I*f_p*self.xk(1)*exp(-E_I/(R*T))*(Z_P*exp(-E_P/(R*T)) + Z_fm*exp(-E_fm/(R*T))))/(2*(Z_Tc*exp(-E_Tc/(R*T)) + Z_Td*exp(-E_Td/(R*T)))*((Z_I*f_p*self.xk(2)*exp(-E_I/(R*T)))/(Z_Tc*exp(-E_Tc/(R*T)) + Z_Td*exp(-E_Td/(R*T))))^(1/2)), 0, -F/V
				];

			self.B = [
				0;
				C_Iin/V;
				0;
				0;
				];

			self.C = [
				0, 0, -self.xk(4)/self.xk(3)^2, 1/self.xk(3)
				];

			self.D = 0;
		end
		
		function output = getOutput(self)
			output = self.yk;
		end
		
		function setControl(self, control)
			self.uk = control - self.u0;
		end
			
		function nextIteration(self)
			self.shiftArrays();
			self.simulate();
		end
		
		function shiftArrays(self)
			self.u = circshift(self.u, [0 1]);
			self.y = circshift(self.y, [0 1]);
			
			self.u(:, 1) = self.uk;
			self.y(:, 1) = self.yk;
		end
		
		function resetToWorkPoint(self, workPoint)
			self.uk = workPoint.u0 - workPoint.u0;
			self.yk = workPoint.y0;
			self.xk = workPoint.x0 - workPoint.x0;

			self.u = self.uk*ones(1, 1);
			self.y = self.yk*ones(1, 1);
			self.x = (self.xk'.*ones(4, 1))';
		end
		
		
		function [y, t] = simulate(self)
% 			self.u = [self.u, self.uk];
			x = self.x(end, :);
			u = self.u(1);
				
			k1 = self.Ts * self.differential(x, u);
			k2 = self.Ts * self.differential(x + k1/2, u);
			k3 = self.Ts * self.differential(x + k2/2, u);
			k4 = self.Ts * self.differential(x + k3, u);

			x = x + k1;%(k1 + 2*k2 + 2*k3 + k4)/6;
			self.yk = self.C * x' + self.y0;

			self.x = [self.x ; x];
		end
		
		function [t, x] = simulateODE(self, x0, u0, t0, tfinal)
			[t, x] = ode45(@(t, x) self.differential(x, u0), t0:self.Ts:tfinal, x0);
		end
		
		function dx = differential(self, x, u)
			dx = self.A*x' + self.B*u;
			dx = dx';
		end
		
	end
end

