classdef SimpleObject < AbstractObject
	properties
		u, y
		uk, yk
		
		A;
		B;
		C;
		D;
		
		transferFunction;
		discreteSpaceState;
	end
	
	methods
		function self = SimpleObject()
			ny = 1; nu = 1; nd = 0; Ts = 1;
			self@AbstractObject(ny, nu, nd, Ts);
			
			self.transferFunction = tf(1, [30 1]);
			discrete = c2d(self.transferFunction, Ts);
			self.discreteSpaceState = ss(discrete);
			self.A = self.discreteSpaceState.A;
			self.B = self.discreteSpaceState.B;
			self.C = self.discreteSpaceState.C;
			self.D = self.discreteSpaceState.D;
		end
		
		function output = getOutput(self)
			output = self.yk;
		end
		
		function setControl(self, control)
			self.uk = control;
			if (size(self.uk, 2) > 1)
				self.uk = self.uk';
			end
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
		
		function simulate(self)
			lin_x0 = self.yk;
			lin_c0 = self.uk;
			
			x = self.A * lin_x0 + self.B*lin_c0;
			self.yk = self.C * x;
		end
		
		function resetToWorkPoint(self, workPoint)
			self.uk = workPoint.u;
			self.yk = workPoint.y; 

			self.u = self.uk*ones(1, 5);
			self.y = self.yk*ones(1, 5);
		end
	end
end

