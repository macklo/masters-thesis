classdef FuzzyStaticModel
	properties
		mf
		params
	end
	
	methods
		function self = FuzzyStaticModel(mf, params)
			self.mf = mf;
			self.params = params;
		end
		
		function yc = getOutput(self, u)
			mu = evalmf(self.mf, u);
			yc = 0;
			for i = 1:size(mu, 1)
				yc = yc + mu(i)*polyval(self.params(i, :), u);
			end
		end
	end
end

