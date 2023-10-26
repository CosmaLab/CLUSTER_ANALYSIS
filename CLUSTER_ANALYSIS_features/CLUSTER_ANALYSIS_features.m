%% CLUSTER_ANALYSIS_features.m

% Code by Alvaro CASTELLS 2019
% Further annotated & Readme file by Alvaro CASTELLS 2021-06
% Checked functionality on Matlab_R2016a
% GOAL: This code is used to quickly obtain a summary of the results of a 
% batch of cluster_analysis .mat files. 
% It will give you a wide variety of information from the analysis file, 
% both about the cell in general, and about the generated cluster 
% features. 
% The file will also contain the full path to the analized cell on the first 
% column in order to be able to backtrack the data if necessary. 
% It is not recommended to change the names of the files or move them from 
% the original place, as it may complicate keeping track of the analysed data. 

%19.01.2023 Laura Martin
%Renamed "AreaNucleusum2" as "AreaLocs_um2" because otherwise misleading.
%It is the area in um^2 of the area occupied by the total number of
%localizations (pre-cluster analysis).
%Renamed "NumberLoc" as "Number_Orig_Locs" because otherwise misleading.
%It is the total number of localizations (pre-cluster analysis). 

%24.10.2023 Blanca Bruschi
%Renamed "MeanTotAreaClusters", "MeanInIslandAreaClusters", 
% "MeanSingleAreaClusters"   as "MeanTotAreaClusters_nm2" , "MeanInIslandAreaClusters_nm2",
%"MeanSingleAreaClusters_nm2"; the same thing for the median.
%Added a column of Cell_Density(=density of locs of the whole cell before cluster analysis).
%Added columns of MeanTotDensityClusters(=mean density of locs of all clusters), 
%MeanInIslandDensityClusters(=mean density of locs belonging to clusters InIsland),
%MeanSingleDensityClusters(=mean density of locs belonging to SingleClusters);
%added columns for median density too.
%Added also code line to save results Data_Summary as .txt.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% INPUT: 
%  	-.mat files obtained from the FindClusters analysis

%% OUTPUT:
%  	-a .xlsx and .txt file with the information organized in rows by cell, and one
% columns for every parameter that we are looking at. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all

%%  Add Root folder of cluster_analysis .mat files.

Root = 'C:\';

%% Variables to be obtained
NumClusters = [];
InIslandClusters = [];
SingleClusters = [];
Cell_Density = [];
TotnLocClusters = [];
TotAreaClusters = [];
TotNNDClusters = [];
InIslandnLocClusters = [];
InIslandAreaClusters = [];
InIslandNNDClusters = [];
SinglenLocClusters = [];
SingleAreaClusters = [];
SingleNNDClusters = [];
MeanTotnLocClusters = [];
MeanTotAreaClusters_nm2 = []; 
MeanTotDensityClusters = []; 
MeanTotNNDClusters = [];
MeanInIslandnLocClusters = [];
MeanInIslandAreaClusters_nm2 = [];
MeanInIslandDensityClusters = [];
MeanInIslandNNDClusters = [];
MeanSinglenLocClusters = [];
MeanSingleAreaClusters_nm2 = [];
MeanSingleDensityClusters = [];
MedianTotnLocClusters = [];
MedianTotAreaClusters_nm2 = [];
MedianTotDensityClusters = []; 
MedianTotNNDClusters = [];
MedianInIslandnLocClusters = [];
MedianInIslandAreaClusters_nm2 = [];
MedianInIslandDensityClusters = [];
MedianInIslandNNDClusters = [];
MedianSinglenLocClusters = [];
MedianSingleAreaClusters_nm2 = [];
MedianSingleDensityClusters= [];


%% Calculate Cluster Features
categ = 1;

for m = 1:categ
    % loop over the categories
    % load .mat file from cluster analysis
    DataNames{m} = uipickfiles;
    
end


for m = 1:categ

    data = DataNames{1,m};
    
    for k = 1:length(data)
        

        D = data{1,k};
        DD = importdata(D);      
              
        Number_Orig_Locs{k,1} = DD.numOrigLocs(1,1);
        AreaLocs_um2{k,1} = (DD.mask.convArea(1,1));
        Cell_Density{k,1} = Number_Orig_Locs{k,1}./AreaLocs_um2{k,1};

        
        NumClusters{k,1} = DD.ClustStats.nClusters(1,1);
        InIslandClusters{k,1} = DD.ClustStats.nInIslandClusters(1,1);
        SingleClusters {k,1}= DD.ClustStats.nSingleClusters(1,1);
        NumberOfIslands{k,1} = DD.ClustStats.nIslands(1,1); 
        
        TotnLocClusters{1,k} = DD.xynData.numberLocs(:,1) ;
        TotAreaClusters{1,k} = DD.xynData.clusterArea(:,1);
        TotNNDClusters {1,k}=  DD.ddcData.nndXY (:,1);

        InIslandnLocClusters{1,k} = DD.xynData.nLocsIslandCluster(:,1) ;
        InIslandAreaClusters {1,k}= DD.xynData.islandClustersArea(:,1) ;
        InIslandNNDClusters{1,k} =  DD.xynData.nndXY (:,1);

        SinglenLocClusters{1,k} = DD.xynData.nLocsSingleCluster(:,1) ;
        SingleAreaClusters {1,k}= DD.xynData.singleClusterArea(:,1) ;
        SingleNNDClusters {1,k}= [];
        
        %If i want to come back to SingleNNDclusters later, look at
        %ismember function
        
       
        
        %% MEAN VALUES for every column
     
        MeanTotnLocClusters{k,1} = mean (DD.xynData.numberLocs(:,1));
        MeanTotAreaClusters_nm2{k,1}= mean (DD.xynData.clusterArea(:,1));
        MeanTotDensityClusters{k,1}= MeanTotnLocClusters{k,1} / MeanTotAreaClusters_nm2{k,1};
        MeanTotNNDClusters {k,1}=  mean(DD.ddcData.nndXY (:,1));

        MeanInIslandnLocClusters{k,1} = mean(DD.xynData.nLocsIslandCluster(:,1)) ;
        MeanInIslandAreaClusters_nm2{k,1}= mean(DD.xynData.islandClustersArea(:,1)) ;
        MeanInIslandDensityClusters{k,1} = MeanInIslandnLocClusters{k,1} / MeanInIslandAreaClusters_nm2{k,1};
        MeanInIslandNNDClusters{k,1} =  mean(DD.xynData.nndXY(:,1));

        MeanSinglenLocClusters{k,1} = mean(DD.xynData.nLocsSingleCluster(:,1)) ;
        MeanSingleAreaClusters_nm2{k,1} = mean(DD.xynData.singleClusterArea(:,1)) ;
        MeanSingleDensityClusters{k,1} = MeanSinglenLocClusters{k,1} / MeanSingleAreaClusters_nm2{k,1};
       
        
        %% MEDIAN VALUES for every column
  
        MedianTotnLocClusters{k,1} = median (DD.xynData.numberLocs(:,1)) ;
        MedianTotAreaClusters_nm2{k,1}= median (DD.xynData.clusterArea(:,1));
        MedianTotDensityClusters {k,1}= MedianTotnLocClusters{k,1} /MedianTotAreaClusters_nm2{k,1};
        MedianTotNNDClusters{k,1}=  median(DD.ddcData.nndXY (:,1));
        

        MedianInIslandnLocClusters{k,1} = median(DD.xynData.nLocsIslandCluster(:,1)) ;
        MedianInIslandAreaClusters_nm2 {k,1}= median(DD.xynData.islandClustersArea(:,1)) ;
        MedianInIslandDensityClusters {k,1}= MedianInIslandnLocClusters{k,1}/MedianInIslandAreaClusters_nm2{k,1};
        MedianInIslandNNDClusters {k,1} =  median(DD.xynData.nndXY(:,1));

        MedianSinglenLocClusters{k,1} = median(DD.xynData.nLocsSingleCluster(:,1)) ;
        MedianSingleAreaClusters_nm2{k,1}= median(DD.xynData.singleClusterArea(:,1)) ;
        MedianSingleDensityClusters{k,1}= MedianSinglenLocClusters{k,1} / MedianSingleAreaClusters_nm2{k,1};
             
        
    end       
      
end


Results.TotnLocClusters = padcat (TotnLocClusters{1,:});
Results.TotAreaClusters = padcat (TotAreaClusters{1,:});
Results.TotNNDClusters = padcat (TotNNDClusters{1,:});


Results.InIslandnLocClusters = padcat (InIslandnLocClusters{1,:});
Results.InIslandAreaClusters = padcat (InIslandAreaClusters{1,:});
Results.InIslandNNDClusters =  padcat (InIslandNNDClusters{1,:});

Results.SinglenLocClusters = padcat (SinglenLocClusters{1,:});
Results.SingleAreaClusters = padcat (SingleAreaClusters{1,:});


Cellnames = transpose(DataNames{1,1});
Data_summary = table (Cellnames, Number_Orig_Locs, AreaLocs_um2, Cell_Density, NumClusters, InIslandClusters, SingleClusters, NumberOfIslands, MeanTotnLocClusters, MeanTotAreaClusters_nm2,MeanTotDensityClusters,MeanTotNNDClusters,MeanInIslandnLocClusters,MeanInIslandAreaClusters_nm2, MeanInIslandDensityClusters,MeanInIslandNNDClusters, MeanSinglenLocClusters, MeanSingleAreaClusters_nm2, MeanSingleDensityClusters, MedianTotnLocClusters, MedianTotAreaClusters_nm2, MedianTotDensityClusters, MedianTotNNDClusters, MedianInIslandnLocClusters, MedianInIslandAreaClusters_nm2, MedianInIslandDensityClusters, MedianInIslandNNDClusters,MedianSinglenLocClusters, MedianSingleAreaClusters_nm2, MedianSingleDensityClusters);

writetable(Data_summary,strcat(Root,'_Data_Summary.xlsx'));
writetable(Data_summary,strcat(Root,'_Data_Summary.txt'),'Delimiter','tab');
