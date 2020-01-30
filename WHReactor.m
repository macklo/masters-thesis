classdef WHReactor < AbstractObject
	properties
		fuzzyStaticModel
		w
		workpoint
		t = [];
		x = [];
		y = [];
		y_static = [];
		u = [];
		k = 1;
		
		uk, yk, ysk, xk, tk
	end
	
	methods
		function self = WHReactor(workpoint, fuzzyStaticModel, w)
			ny = 1; nu = 1; nd = 0; Ts = 0.01;
			self@AbstractObject(ny, nu, nd, Ts);
			
			self.workpoint = workpoint;
			self.uk = workpoint.u0;
			self.yk = workpoint.y0;
			
			self.tk = 0;
			
			self.y = ones(1, 5) * self.yk;
			
			self.u = ones(1, 5) * self.uk;
% 			self.t = 0:self.Ts:self.Ts*3;
			
			self.fuzzyStaticModel = fuzzyStaticModel;
			self.ysk = fuzzyStaticModel.getOutput(workpoint.u0);
			self.y_static = ones(1, 5) * self.ysk;
			self.w = w;
		end
		
		function setControl(self, control)
			self.uk = control;
		end
		
		function [output] = getOutput(self, q)
			if nargin == 2
				output = q*self.w;
			else
				output = self.yk;
			end
		end
		
		function [y, t] = nextIteration(self)
			
			self.t  = [self.t self.tk];
			self.tk = self.tk + self.Ts;

			
			q = [self.y_static(end) self.y_static(end-1) self.y_static(end-2), ...
				self.y(end) self.y(end-1) self.y(end-2) self.y(end-3)];
% 			q1 == q
			y = q*self.w;
% 			y = q*self.w;
			self.u = [self.u, self.uk];
			self.yk = y;
			self.y = [self.y, self.yk];
			self.ysk = self.fuzzyStaticModel.getOutput(self.uk);
			self.y_static = [self.y_static, self.ysk];
		end
	
		
	end
end

