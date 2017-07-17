function MakeFDACurvePlots(fdacellstructmat,sparsedatamat,timebinmat,subjectid,figurenum)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
figure(figurenum)
plot(timebinmat(isnan(sparsedatamat(:,subjectid))==0,subjectid),sparsedatamat(isnan(sparsedatamat(:,subjectid))==0,subjectid),'blue')
hold
plot(fdacellstructmat{subjectid}.timefine,fdacellstructmat{subjectid}.datafine,'red')
title(strcat('plot of data vs fda predicted data for subject #',num2str(subjectid)),'FontSize',20,'FontWeight','Bold','FontName','Arial')
xlabel('time','FontSize',16,'FontWeight','Bold','FontName','Arial')
ylabel('metric','FontSize',16,'FontWeight','Bold','FontName','Arial')
end

