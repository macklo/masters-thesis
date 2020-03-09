% clear
% clc

load("data\SL.mat")
load("data\NPL.mat")
load("data\DMC.mat")

figure
	hold on
	stairs(ansCopy, setPoints)
	stairs(ansCopy, y)
	stairs(ansCopy, yNPL)
	stairs(ansCopy, ySL)
	ylabel("Œrednie stê¿enie")
	xlabel("t [h]")
	legend("y_{zad}", "DMC", "HDMC-SL", "HDMC-NPL", 'Location', 'NorthEastOutside')