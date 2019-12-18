function [mf, linPoints] = createMembershipFunction(numberOfModels, ymin, ymax, a, flag)
	mf = fismf.empty(numberOfModels, 0);

	dy = (ymax - ymin)/numberOfModels;
	cuts = ymin+dy:dy:ymax-dy;

	mf(1, 1) = fismf("sigmf",[-a cuts(1)]);
	mf(numberOfModels, 1) = fismf("sigmf",[a cuts(numberOfModels - 1)]);
	for i = 2:numberOfModels-1
		mf(i, 1) = fismf("dsigmf", [a cuts(i-1) a cuts(i)]);
	end
	linPoints = ymin+dy/2:dy:ymax-dy/2;
	
	y = evalmf(mf, ymin:0.1:ymax);
	
	if(flag)
	figure
		hold on
        for i = 1:numberOfModels
            plot(ymin:0.1:ymax, y(i, :))
        end
    plot(linPoints, ones(1,numberOfModels), 'ko')
    xlabel("y")
    ylabel("\mu")
	end
end

