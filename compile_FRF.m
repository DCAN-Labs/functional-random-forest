%compiling RFSD code
addpath('/mnt/max/shared/projects/FAIR_users/Feczko/code_in_dev/RFAnalysis/FTRAJ')
mcc -v -m -d /mnt/max/shared/projects/FAIR_users/Feczko/code_in_dev/RFAnalysis/RFSD -o ConstructModelTreeBag /mnt/max/shared/projects/FAIR_users/Feczko/code_in_dev/RFAnalysis/RFSD/ConstructModelTreeBag.m
mcc -v -m -d /mnt/max/shared/projects/FAIR_users/Feczko/code_in_dev/RFAnalysis/RFSD -o PrepExcelSheetForTreeBagging /mnt/max/shared/projects/FAIR_users/Feczko/code_in_dev/RFAnalysis/RFSD/PrepExcelSheetForTreeBagging.m
mcc -v -m -d /mnt/max/shared/projects/FAIR_users/Feczko/code_in_dev/RFAnalysis/RFSD -o RunAndVisualizeCommunityDetection /mnt/max/shared/projects/FAIR_users/Feczko/code_in_dev/RFAnalysis/RFSD/RunAndVisualizeCommunityDetection.m
mcc -v -m -d /mnt/max/shared/projects/FAIR_users/Feczko/code_in_dev/RFAnalysis/RFSD -o RunRFSDPowerAnalysis /mnt/max/shared/projects/FAIR_users/Feczko/code_in_dev/RFAnalysis/RFSD/RunRFSDPowerAnalysis.m
mcc -v -m -d /mnt/max/shared/projects/FAIR_users/Feczko/code_in_dev/RFAnalysis/RFSD -o VisualizeTreeBaggingResults /mnt/max/shared/projects/FAIR_users/Feczko/code_in_dev/RFAnalysis/RFSD/VisualizeTreeBaggingResults.m
%now compiling FTRAJ code 
rmpath('/mnt/max/shared/projects/FAIR_users/Feczko/code_in_dev/RFAnalysis/FTRAJ')
addpath('/mnt/max/shared/projects/FAIR_users/Feczko/code_in_dev/RFAnalysis/RFSD')
mcc -v -m -d /mnt/max/shared/projects/FAIR_users/Feczko/code_in_dev/RFAnalysis/FTRAJ -o GenerateFDACoeffMatrix /mnt/max/shared/projects/FAIR_users/Feczko/code_in_dev/RFAnalysis/FTRAJ/GenerateFDACoeffMatrix.m
mcc -v -m -d /mnt/max/shared/projects/FAIR_users/Feczko/code_in_dev/RFAnalysis/FTRAJ -o GenerateTrajectoryCorrelationMatrix /mnt/max/shared/projects/FAIR_users/Feczko/code_in_dev/RFAnalysis/FTRAJ/GenerateTrajectoryCorrelationMatrix.m
mcc -v -m -d /mnt/max/shared/projects/FAIR_users/Feczko/code_in_dev/RFAnalysis/FTRAJ -o ConstructAllSubgroupTrajectories /mnt/max/shared/projects/FAIR_users/Feczko/code_in_dev/RFAnalysis/FTRAJ/ConstructAllSubgroupTrajectories.m
mcc -v -m -d /mnt/max/shared/projects/FAIR_users/Feczko/code_in_dev/RFAnalysis/FTRAJ -o MultiPlotFDACurves /mnt/max/shared/projects/FAIR_users/Feczko/code_in_dev/RFAnalysis/FTRAJ/MultiPlotFDACurves.m

