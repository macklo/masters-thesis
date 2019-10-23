classdef NonlinearReactor < AbstractObject
	properties
		u, y, x
		uk, yk, xk
	end
	
	methods
		function self = NonlinearReactor()
			ny = 1; nu = 1; Ts = 0.00  1;
			self@AbstractObject(ny, nu, Ts);
			self.xk = zeros(1, 4);
			
		end
		
		function output = getOutput(self)
			output = self.yk;
		end
		
		function setControl(self, control)
			self.uk = control;
		end
			
		function nextIteration(self)
			self.shiftArrays();
			self.simulate();
		end
		
		function shiftArrays(self)
			self.u = circshift(self.u, [0 1]);
			self.y = circshift(self.y, [0 1]);
			self.x = circshift(self.x, [0 1]);
			
			self.u(:, 1) = self.uk;
			self.y(:, 1) = self.yk;
			self.x(:, 1) = self.xk;
		end
		
		function simulate(obj)
			x = zeros(4, 1);
			x(1) = (10 * (6 - obj.xk(1)) - 2.4568 * obj.xk(1) * sqrt(obj.xk(2))) * obj.Ts + obj.xk(1);
			x(2) = (80 * obj.uk - 10.1022 * obj.xk(2)) * obj.Ts + obj.xk(2);
			x(3) = (0.0024121 * obj.xk(1) * sqrt(obj.xk(2)) + 0.112191 * obj.xk(2) - 10 * obj.xk(3)) * obj.Ts + obj.xk(3);
			x(4) = (245.978 * obj.xk(1) * sqrt(obj.xk(2)) - 10 * obj.xk(4)) * obj.Ts + obj.xk(4);
			
			y = (x(4) / x(3));
			obj.xk = x;
			obj.yk = y;
		end
		
		function resetToWorkPoint(self, workPoint)
			self.uk = workPoint.u;
			self.yk = workPoint.y; 
			self.xk = workPoint.x;
			
			self.u = self.uk*ones(1, 5);
			self.y = self.yk*ones(1, 5);
			self.x = self.xk*ones(1, 5);
		end
	end
end

