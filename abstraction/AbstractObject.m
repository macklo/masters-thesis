classdef (Abstract) AbstractObject < handle
	properties
		ny,nu,nd,Ts
	end
	
	methods
		function self = AbstractObject(ny, nu, nd, Ts)
			self.ny = ny;
			self.nu = nu;
			self.nd = nd;
			self.Ts = Ts;
		end
	end
	
	methods (Abstract)
		[output] = getOutput(self);
		setControl(self, control);
		nextIteration(self);
	end
end

