classdef FuzzyReactor < AbstractObject
	properties
		mf
		
		u0 = 90;
		y0 = 36
		
		u, y, x
		uk, yk, xk
		
		ymin = 16;
		ymax = 66;
		
		x0 = []
		t = 0
		linearModels
		numberOfModels
		linearWorkpoints
	end
	
	methods
		function self = FuzzyReactor(numberOfModels, workPointIndexes)
			ny = 1; nu = 1; nd = 0; Ts = 0.01;
			self@AbstractObject(ny, nu, nd, Ts);
			load("./data/workpoints.mat");
			self.numberOfModels = numberOfModels;
			self.mf = createMembershipFunction(numberOfModels, 20000, 45000, 0.005, 0);
			self.linearModels = cell(1, numberOfModels);
			for i = 1:numberOfModels
				workpoint = workpoints{workPointIndexes(i)};
				self.linearModels{i} = LinearReactor(workpoint);
				self.linearModels{i}.resetToWorkPoint(workpoint);
			end
		end
		
		function output = getOutput(self)
			output = self.yk;
		end
		
		function setControl(self, control)
			for r = 1:self.numberOfModels
				self.linearModels{r}.setControl(control);
			end
			self.uk = control;
		end
			
		function nextIteration(self)
			for r = 1:self.numberOfModels
				self.linearModels{r}.shiftArrays();
				self.linearModels{r}.simulate();
			end
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
			self.uk = workPoint.u0;
			self.yk = workPoint.y0; 
			self.xk = workPoint.x0;

			self.u = self.uk*ones(1, 1);
			self.y = self.yk*ones(1, 1);
			self.x = (self.xk'.*ones(4, 1))';
			for r = 1:self.numberOfModels
				self.linearModels{r}.resetToWorkPoint(workPoint);
			end
		end
		
		function u = getU(self)
			time = size(self.u, 2) * self.Ts;
			if (time > self.tau)
				u = self.u(time - self.Ts);
			else
				u = self.u0;
			end
		end
		
		function ykr = getModelOutputs(self)
			ykr = zeros(self.numberOfModels, 1);
			self.yk;
			for r = 1:self.numberOfModels
				ykr(r) = self.linearModels{r}.getOutput();
			end
		end
		
		function [y, t] = simulate(self)
			w = evalmf(self.mf, self.yk);
			ykr = self.getModelOutputs();
			self.yk = (w' * ykr) / sum(w);
		end
		
% 		function xret = getX(obj, x)
% 			xret = x;
% 			if x(1) < 0
% 				xret(1) = 0;
% 			end
% 			if x(2) < 0
% 				xret(2) = 0;
% 			end
% 		end
		
		function [t, x] = simulateODE(self, x0, u0, t0, tfinal)
			[t, x] = ode45(@(t, x) self.differential(x, u0), t0:self.Ts:tfinal, x0);
		end
		
		function dx = differential(self, x, u)
			dx1 = u + self.FD - self.alfa1 * sqrt(x(1)/self.A1);
			dx2 = self.alfa1 * sqrt(x(1)/self.A1) - self.alfa2 * (x(2)/self.C2)^(1/4);
			
			dx = [dx1, dx2];
		end
		
		function workpoint = calculateWorkpoint(self, y)
			h1 = (self.alfa2 / self.alfa1)^2 * y;
			workpoint = struct('x', [self.A1 * h1, self.C2 * y^2], 'u', self.alfa1 * sqrt(h1) - self.FD, 'y', y, 'h1', h1, 'h2', y);
		end
	end
end

