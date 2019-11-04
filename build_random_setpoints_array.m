function setPoints = build_random_setpoints_array(workpoint, len, interval, minVal, maxVal)
    setPoints = workpoint.y0*ones(1, len);
    for i = interval:interval:len
		if(i ~= len)
			setPoints(i:end) = minVal + (maxVal - minVal)*rand();
		end
    end
end

