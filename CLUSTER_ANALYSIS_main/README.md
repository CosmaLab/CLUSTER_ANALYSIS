# CLUSTER_ANALYSIS_main
This code is used to identify clusters from localizations list files

Code by Carlo Manzo and Jason Ottestrom

2021-12-18 Updates by Laura Martin and Chiara Sopegno: we added a 13th column in the output file table, listing the global NNDs (both Single and InIsland NNDs).

README and annotation updates by Alvaro Castells and Laura Martin.

Checked functionality on Matlab_R2016a


## GOAL: 
This code is used to identify clusters from localizations list files. It will give information about the coordinates of clusters centroids and features of the clusters (localizations per cluster, area in nm<sup>2</sup> of each cluster, distance in nm between closest clusters (NND)). Also, it will discriminate between clusters InIslands (clusters identified in high density regions) and Single clusters.


## INPUT: 
- .bin files of localizations list. (First generate a list of localizations of ROIs of interest. Make also sure that they are properly corrected for drift.) 

###### Note: 
.bin file is the output format of the Nikon N-STORM localization files. In case your localization lists are not in that format, you may want to use Insight3.m file to generate them. 



## OUTPUT: 

##### .bin file : 
- A localization list file for Insight3 software visualization. Every centroid of a cluster is in channel 0. Localizations belonging to clusters are arbitrarily colored in order to easily visualize the different clusters. In order to visualize the cluster analysis .bin file in Insight3, first open a any .nd2 file, load the originated .bin from cluster analysis, and finally drag and drop the visualization setting file "___Insight3 clusters settings.ini".

##### .xyn: 
- A .xyn document containing: analysis parameters used (row 2-19), median of all cluster features (row 20-22), and information of every feature (13 columns) for each cluster (rows).
More in details:

  Row 20-21-22:
   - medianNum= median of number of localizations per cluster
   - medianArea[nm<sup>2</sup>]= median of cluster area (nm<sup>2</sup>) calculated as π(sigAve*original_pixel_size)<sup>2</sup>
   - medianDensity= medianNum/medianArea[nm<sup>2</sup>]
   
  Column A-B-C-D-E-F-G-H-I-J-K-L-M:
   - X[pix]= x coordinate of cluster centroid in px 
   - Y[pix]= y coordinate of cluster centroid in px
   - NumLocalizations= number of localizations of the cluster
   - sigX[pix]= standard deviation of x coordinate of cluster centroid in px
   - sigY[pix]= standard deviation of y coordinate of cluster centroid in px
   - sigAve[pix]= (sigX+sigY)/2. It is used as radius to calculate the cluster area
   - sigQuad[pix]= sqrt(sigX<sup>2</sup>+sigY<sup>2</sup>)
   - Z[nm]= z coordinate of cluster centroid in px 
   - sigZ[nm]= standard deviation of z coordinate of cluster centroid in px
   - NND[nm] InIsland= distance in nm between the centroids of two nearest neighbour clusters (only considering InIsland clusters
   - NumClustersInIsland= number of clusters belonging to the same island
   - IslandIndex= index of the islands. Clusters with the same index belong to the same Island.
   - NND[nm] Global= distance in nm between the centroids of two nearest neighbour clusters (considering both InIsland and Single clusters

##### 	.mat: 
- A .mat file with the extended information of every cluster and its features. 
        
##### .ddc: 
- A .ddc table containing only the information of cluster centroids coordinates and global NNDs (InIsland and Single).

##### .fig: 
- A .fig file of 5 plots displaying the cluster analysis results. 

   In details, the median (and average) for Single/InIsland/all clusters of:
 
  -  localizations/cluster
  -  clusters area (nm<sup>2</sup>)
  -  clusters NND (nm)
  
  Also, 2 histograms displaying:
  
  - the % of Super Resolution Area occupied by clusters area. Cluster area is (π*(SIG)*original_pixel_size)<sup>2</sup> (i.e.pixel size 160nm). SIG=(sdx+sdy)/2 of cluster centroid coordinates. 
  
      The title of the plot also reports the Conventional Area (um<sup>2</sup>) and the SR_area/Conv_area (%).
  
      Conv Area (um<sup>2</sup>) is the number of pixels containing localizations multiplied for the area of one pixel (i.e. 0.160<sup>2</sup> um<sup>2</sup>).
  
      SR Area (um<sup>2</sup>) depends on the number of localization precision. It is the number of pixels containing localizations multiplied for the area of one pixel, in an image with pixels as big as the localization precision (i.e. 9nm x 9nm ).
  
      Both Conv_area and SR_area are generated on the total number of localizations BEFORE the cluster analysis (1/um<sup>2</sup>).
  
  - the number of clusters (Single/InIslands) or Islands divided per the SR Area (um<sup>2</sup>).  
  
##### .png: 
- Same as the .fig file, but in .png format.
                   

	

## PARAMETERS TO SELECT:	

##### image_width/height: 
- Size of the image in pixels. In the NSTORM the default is 256, but other microscopes use different ROI sizes.

##### use_drift_corrected_xy: 
- In all general cases, this should be left in 1 （True). It is always better to use the drift corrected file.

##### use_channels: 
- Selection of the channel that is going to be analyzed. In case you are doing multicolor imaging, you can manually select an individual channel. The default, -1, pulls together and analyzes all the localizations from the .bin file, regardless of the channel of origin. When using -1, there will be clusters with localizations belonging to different channels.

##### original_pixel_size: 
- The pixel size, in nm, of the original image. To how many nm a pixel is equivalent.

##### analysis_pixel_size: 
- Pixel size used for the first density image generated. A 2D histogram of the number of localizations per pixel is created.

##### 	sum_roi_size: 
- Dimension of the square kernel in pixels to generate binary image based on the threshold. The value should be an odd integer. E.g., sum_roi_size= 5, kernel dimension 5 x 5 pixels<sup>2</sup>.
        Each pixel contains a certain number of molecules (a 2D histogram with each pixel size equal to analysis_pixel_size in nm). The script will sum the number of molecules in a 'roi' x 'roi' area surrounding each pixel and put the sum in the pixel under consideration.

##### sum_threshold: 
- Density threshold used to binarize the image in order to identify clusters. After applying the 'roi' x 'roi' sum, each pixel must have a value > 'threshold' in order to be further considered in the cluster analysis.
        E.g., if 'analysis_pixel_size'= 10nm and 'roi'= 5 then there must be more than 'threshold' molecules in a 50 nm x 50 nm ROI surrounding each pixel.

##### factor: 
- Factor by which the size of the analysis_pixel_size will be decreased, once you have a region to start finding clusters in . E.g., If analysis_pixel_size is 10, and factor is 5, the new analysis pixel size will be 2.

##### localization_precision: 
- Measure of localization precision of the molecules (in nm), used to calculate the centroid of the clusters. This value is used as the sigma (σ) in a 2D Gaussian point-spread function associated to each localization. Only the values of the Gaussian lying within 3σ are considered. The script will sum the values of the Gaussians of all localizations belonging to the same Island to generate a density map, from which clusters are identified.

  ** The interval of Gaussian values associated to each localization is defined as numSigma x sigma. 
     We set this interval at 3σ, but it can be adjusted by changing the variable numSigma (see FindClusters.m ln358). 
     E.g. if numSigma=5, the interval will be 5σ. The bigger the numSigma  value, the bigger the area associated to each localization.

##### minimum_molecules_per_cluster: 
- The mimimum number of localization found inside a "cluster" to consider it as such. After the program finds a cluster a final check is performed to ensure that there must be >= 'minCluster' molecules within the cluster. If there are < 'minCluster' molecules within the cluster then this will not be considered a cluster.

##### ignoreNumPeakThreshold: 
- Ignore islands that have > ignoreNumPeakThreshold of pixels. When doing the peak finding (finding localizations on an island) if the number of pixels to scan gets too large then the program will take a long time to finish. If any island has more peaks than the threshold, it will get discarded from the analysis. If you consider that this discarded island should be analyzed, increase the ignoreNumPeakThreshold.

##### ignoreNumIslandThreshold: 
- Ignore this island and continue to analyse the next island if the number of localizations > ignoreNumIslandThreshold. A possible outcome is for the iterative cluster identification to discard very dense regions, as they would be too computationally intense. This is a measurement of the number of loops that the script will try to calculate the centroid before "giving up" and discarding the cluster. Under normal circumstances there is no need to change the default value.

##### drawUsingZRange: 
- Parameter used for Insight3 clusters visualization. Set true only for 3D images. If true, then the localizations in each cluster are set to be in an Insight3 channel that depends on the z value of their centroid. For example, 9 Insight3 channels are used for 9 z regions. The z regions are defined as minZ:dz:maxZ, where dz = (maxZ-minZ)/9. Depending on the z value of the centroid, each localization of a cluster will go into a particular Insight3 channel. 
- If false, then all localizations in a cluster get assigned to the same Insight3 channel, which is randomly selected for each cluster to be between 1 and 9.

##### 	use_iterative_segmentation: 
- If an island is too large then use an iterative segmentation algorithm to reduce the island area. This is needed only in the case of very big highly dense regions of localizations. In principle, in normal conditions, it can be left on the default value.

##### max_segmentation_area: 
- If use_iterative_segmentation is "true" then the iterative segmentation algorithm will continue to reduce the size of large islands until all islands have an area that is smaller than this value. As before, this is needed only in the case of big dense regions of localizations. In principle, in normal conditions, it can be left on the default value.

##### show_density_map/show_mask :
- Whether or not to display a figure of the density map/binary mask that the analysis uses in its first steps. Used if you need to check up the thresholding of your image, or if you are curious about which regions are selected. If you are running many .bin files at the same time, keep it at 0, otherwise the high amount of figures that you will generate may crash your computer.  	


## HOW TO USE: 

1.	Open function ">>CLUSTER_ANALYSIS_main.m".

2.  Write in rootdir the string of the directory in which you want the output data folder to be created. Write plotstats = 'true' if you want to display analysis plots. Write in valuespix2nm a string with the correct value of nanometers to which one pixel of your images corresponds to (E.g., 160).

3.	Run.

4.	Adjust parameters based on explained conditions.

5.	Select the .bin files that will be analyzed.

6.	An ouput data folder called "cluster_analysis" will be created inside the root directory. Inside the folder output files will be automatically saved:  .bin, .mat, .xlsx, .ddc, .png, .fig. Each file will be named with the original list name + the abbreviations of parameters used for the analysis + file extension.
