# WQIP-Annual-ReportMaps_2021-22 

This repo documents the creation of a portion of the map figures and map packages for the 2020-21 WQIP annual report appendices B2 and C1.
## Getting Started
1 - Clone this repo.
2 - Download the data from box [here](https://ocgov.box.com/s/dlwc2giegekci00difk9rqbyimlad2gf) and/or place your raw data into the /data/raw folder.
## Project Organization
------------
```             
    ├── README.md          <- The top-level README for developers using this project.
    ├── arcgis             <- Root location for ArcGIS Pro project
    ├── data
    │   ├── processed      <- The final datasets.
    │   ├── interim        <- Temporary datasets.
    │   └── raw            <- The original data dump.
    ├── notebooks          <- Jupyter notebooks. Naming convention is a 2 digits (for ordering)
    ├── references         <- Data dictionaries, manuals, and all other explanatory materials.
    ├── output             <- Generated analysis as HTML, PDF, LaTeX, etc.
    ├── R                  <- R source code for use in this project
    └── python             <- Python source code for use in this project
```
## Reproducing
### Data Preparation
Initial data processing and formatting for GIS is contained in '/notebooks/01_analysis.ipynb'.
### Map Authoring
There are four maps within the arcgis pro project.
- MP_Appendix_B2_Fig_2-6
- MP_Appendix_C1_AllFigures
- PR_Appendix_B2_Fig_2-6
- PR_Appendix_C1_AllFigures
Maps with the prefix MP were created for export as map packages and do not include and basemap layers, only monitoring site data. Maps with the prefix PR were used to export report figures.
Map layer data sources are updated in '/notebooks/02_maps.ipynb'
