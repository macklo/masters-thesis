classdef (Abstract) AbstractMeasurer < handle
	properties
		object
	end
	
	methods
		function self = AbstractMeasurer(object)
			self.object = object;
		end
	end
	
	methods (Abstract)
		[measOutput] = measure(self);
	end
end

