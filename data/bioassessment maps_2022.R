# Combine data for bioassessment maps ----

wd<-"C:/Users/givens/Documents/GitHub/WQIP-Annual-ReportMaps_2021-22/data/raw"


library(dplyr)
library(ggplot2)
library(tidyr)
library(data.table)
library(lubridate)
library(readr)
library(readxl)
library(magrittr)
library(xlsx)
library(RODBC)

stns2022 <- read.xlsx('C:/Users/givens/Documents/GitHub/WQIP-Annual-ReportMaps_2021-22/data/raw/Maps info spreadsheet.xlsx', sheetIndex = 5) %>%
  filter(!is.na(Station)) %>%
  select(Station, Latitude, Longitude)
  

#---

#for algae, don't include SMC01987's 2012 duplicate (score 44 in sheet1)
#for algae, csci, and cluster groups DO include all three Unique Monitoring Events (not triplicates) in 2014 at REF-TCAS

algae <- read.xlsx('C:/Users/givens/Documents/GitHub/WQIP-Annual-ReportMaps_2021-22/data/raw/Maps info spreadsheet.xlsx', sheetIndex = 3) %>%
  filter(!is.na(Station))

algal2 <- algae %>%
  mutate(StationUnique = paste0(Station, "__", Year))%>%
  filter(Parameter=='H20') %>%
  select(Station, StationUnique, Year, Result) %>%
  group_by(Station)%>%
  mutate(Result2 = mean(Result)) %>%
  mutate(`H20 Score` = unlist(Result2))%>%
  select(-Result2) %>%
  mutate(Year = as.numeric(Year)) %>%
  mutate(`H20 Colors` = ifelse(`H20 Score` <= 19, "Red", 
                               ifelse(`H20 Score` <= 34, "Orange",
                                      ifelse(`H20 Score` <= 48, "Yellow",
                                             ifelse(`H20 Score` < 57, "Light Green", "Dark Green"))))) %>%
  ungroup()
  


cram <- read.xlsx('C:/Users/givens/Documents/GitHub/WQIP-Annual-ReportMaps_2021-22/data/raw/Maps info spreadsheet.xlsx', sheetIndex = 4) %>%
  filter(!is.na(Station)) %>%
  select('Station', 'Year', 'Overall.CRAM.Score') %>%
  mutate(StationUnique = paste0(Station, "__", Year)) %>% 
  mutate(Year = as.numeric(Year)) %>% 
  group_by(Station) %>%
  mutate(Result2 = mean(Overall.CRAM.Score)) %>%
  mutate(`CRAM Score` = unlist(Result2))%>%
  select(-Result2) %>%
  
mutate(`CRAM Colors` = ifelse(`CRAM Score` <= 43, "Red", 
                              ifelse(`CRAM Score` <= 62, "Orange", 
                                     ifelse(`CRAM Score` <= 81, "Yellow", "Blue")))) %>%
  filter(!is.na(`CRAM Colors`)) %>%
  ungroup()

csci_HMP <-  read.xlsx('C:/Users/givens/Documents/GitHub/WQIP-Annual-ReportMaps_2021-22/data/raw/Maps info spreadsheet.xlsx', sheetIndex = 4) %>%
  filter(!is.na(Station)) %>%
  select('Station', 'Year', 'CSCI.Score') %>%
  mutate(StationUnique = paste0(Station, "__", Year)) %>% 
  mutate(Year = as.numeric(Year)) %>% 
  group_by(Station) %>%
  mutate(Result2 = mean(CSCI.Score)) %>%
  mutate(`CSCI Score` = unlist(Result2))%>%
  select(-Result2) %>%
  
  mutate(`CSCI Colors` = ifelse(`CSCI Score` <= .62, "Red", 
                                ifelse(`CSCI Score` <= .79, "Orange", 
                                       ifelse(`CSCI Score` <= .92, "Yellow", "Blue")))) %>%
  filter(!is.na(`CSCI Colors`)) %>%
  ungroup()

csci <- read.xlsx('C:/Users/givens/Documents/GitHub/WQIP-Annual-ReportMaps_2021-22/data/raw/Maps info spreadsheet.xlsx', sheetIndex = 3) %>%
  mutate(StationUnique = paste0(Station, "__", Year)) %>% 
  select('Station', 'StationUnique', 'Year', 'Parameter', 'Result') %>%
  filter(Parameter=='CSCI') %>%
  mutate(Year = as.numeric(Year)) %>% 
  group_by(Station) %>%
  mutate(Result2 = mean(Result)) %>%
  mutate(`CSCI Score` = unlist(Result2))%>%
  select(-Result2) %>%

mutate(`CSCI Colors` = ifelse(`CSCI Score` < 0.62, "Red", 
                              ifelse(`CSCI Score` < 0.79, "Orange", 
                                     ifelse(`CSCI Score` < 0.92, "Yellow", "Blue")))) %>%
  ungroup() %>%
  full_join(., csci_HMP)



df2 <- full_join(csci, cram, by=c('StationUnique'))
df3 <- full_join(df2, algal2, by=c('StationUnique'))

df4 <-  full_join(df3, stns2022, by = c('Station.x' = 'Station'))%>%
  mutate(Latitude = as.numeric(Latitude),
         Longitude = as.numeric(Longitude))

write.xlsx(df4,'C:/Users/givens/Documents/GitHub/WQIP-Annual-ReportMaps-2021-22/WQIP-Annual-ReportMaps_2021-22/data/processed/AllScoresMaps.xlsx')



#Cluster groups
cluster <- read.xlsx('C:/Users/givens/Documents/GitHub/WQIP-Annual-ReportMaps_2021-22/data/raw/Maps info spreadsheet.xlsx', sheetIndex = 3) %>%
  filter(!is.na(Station)) %>%
  select(Station, Station.Unique, Cluster.Group) %>%
  unique() %>%
  full_join(., stns2022, by='Station') %>%
  filter(!is.na('Latitude'))

write.xlsx(cluster,'C:/Users/givens/Documents/GitHub/WQIP-Annual-ReportMaps-2021-22/WQIP-Annual-ReportMaps_2021-22/data/processed/cluster.xlsx')

#write.xlsx(df4, paste0('data/processed/',
                       #prod_name, '_', prod_desc, '_', values[["AnalysisRunDate"]], '.xlsx'), showNA = FALSE)



##Previous scripts below##

#check that duplicates have been averaged together
a <- algal2 %>% select(Station, Year) %>% unique()
b <- cram %>% select(Station, Year) %>% unique()
c <- csci %>% select(Station, Year) %>% unique()
rm(a,b,c)

dr <- full_join(csci, algal2, by='StationUnique')
drr <- left_join(dr, cram)

df <-  left_join(drr, stns %>% filter(ProjectProgramCode == 9 | StationCode == 'M02@AveMont'), by = c('Station' = 'StationCode'))
dff <- data.frame(df)

# product_c9 Current Season CSCI CRAM map ----
prod_name <- 'product_c9'
prod_desc <- 'Current Season CSCI CRAM map'

df_2020 <- df %>%
  filter(Year == 2020)%>%
  mutate(Latitude = as.numeric(Latitude),
         Longitude = as.numeric(Longitude))
write.xlsx(df_2020, paste0('data/processed/',
                           prod_name, '_', prod_desc, '_', values[["AnalysisRunDate"]], '.xlsx'), showNA = FALSE)

#added 1/25/20 to avoid using package XLSX
write.csv(df_2020, paste0('data/processed/',
                          prod_name, '_', prod_desc, '_', today(), '.csv'))

# product_c14_c15_c17 CRAM and CSCI and H20 historical ----
prod_name <- 'product_c14_c15_c17'
prod_desc <- 'Historical Bioassessment Scores'

AveragingScores <- function(DataToSubset) {
  colnames(DataToSubset) <- c('Station', 'Score', 'Latitude', 'Longitude')
  DataToSubset %>%
    .$`Score`%>%
    mean(., na.rm = TRUE)}

df_csci <- dff %>%
  # filter(Rep == 1)%>%
  # this year, df already had Rep 2 filtered out
  select(Station, `CSCI`, Latitude, Longitude)%>%
  group_by(Station)%>%
  do(`CSCI Scores` = AveragingScores(.))%>%
  mutate(`CSCI Scores` = unlist(`CSCI Scores`),
         `CSCI Colors` = ifelse(`CSCI Scores` < 0.62, "Red", 
                                ifelse(`CSCI Scores` < 0.79, "Orange", 
                                       ifelse(`CSCI Scores` < 0.92, "Yellow", "Blue"))))
df_cram <- dff %>%
  # filter(Rep == 1)%>%
  # this year, df already had Rep 2 filtered out
  select(Station, `Overall.CRAM.Score`, Latitude, Longitude)%>%
  group_by(Station)%>%
  do(`CRAM Scores` = AveragingScores(.))%>%
  mutate(`CRAM Scores` = unlist(`CRAM Scores`),
         `CRAM Colors` = ifelse(`CRAM Scores` <= 43, "Red", 
                                ifelse(`CRAM Scores` <= 62, "Orange", 
                                       ifelse(`CRAM Scores` <= 81, "Yellow", "Blue"))))
df_h20 <- dff %>%
  # filter(Rep == 1)%>%
  # this year, df already had Rep 2 filtered out
  select(Station, `H20.Score`, Latitude, Longitude)%>%
  filter(!is.na(`H20.Score`))%>%
  group_by(Station)%>%
  do(`H20 Scores` = AveragingScores(.))%>%
  mutate(`H20 Scores` = unlist(`H20 Scores`),
         `H20 Colors` = ifelse(`H20 Scores` <= 19, "Red", 
                               ifelse(`H20 Scores` <= 34, "Orange",
                                      ifelse(`H20 Scores` <= 48, "Yellow",
                                             ifelse(`H20 Scores` < 57, "Light Green", "Dark Green")))))
df2 <- full_join(df_csci, df_cram)
df3 <- full_join(df2, df_h20)
df4 <-  left_join(df3, stns %>% filter(ProjectProgramCode == 9 | StationCode == 'M02@AveMont'), by = c('Station' = 'StationCode'))%>%
  mutate(Latitude = as.numeric(Latitude),
         Longitude = as.numeric(Longitude))

write.xlsx(df4, paste0('data/processed/',
                       prod_name, '_', prod_desc, '_', values[["AnalysisRunDate"]], '.xlsx'), showNA = FALSE)


#Cluster Groups



# Product c16, Cluster Group Locations ----
# With duplicates, only keep most recent year
# include all three Unique Monitoring Events (not triplicates) in 2014 at REF-TCAS

dr_cluster <- read.xlsx('data/raw/ClusterGroups2018.xlsx', sheetIndex = 1)
#added 1/25/20 to avoid using package XLSX
dr_cluster <- read.csv('data/raw/ClusterGroups2020.csv')

prod_name <- 'product_c16'
prod_desc <- 'Bioassessment Cluster Groups'

drr_cluster <- dr_cluster %>% 
  select(Station, Year, 'Cluster Group' = 'Cluster.Group') %>%
  mutate(Station = as.character(Station))%>%
  mutate(Station = ifelse(grepl("REF-TCAS", Station), "REF-TCAS", as.character(Station)))%>%
  unique()
df_cluster <- drr_cluster %>%
  group_by(Station)%>%
  slice(which.max(as.Date(as.character(Year), '%Y')))%>%
  ungroup(.)
#check if true:
nrow(drr_cluster %>% select(Station) %>% unique()) == nrow(df_cluster)

dff_cluster <- df_cluster %>%
  left_join(., stns %>% filter(ProjectProgramCode == 9 | StationCode == 'M02@AveMont'), by = c('Station' = 'StationCode'))%>%
  mutate(Latitude = as.numeric(Latitude),
         Longitude = as.numeric(Longitude))

write.xlsx(dff_cluster, paste0('data/processed/',
                       prod_name, '_', prod_desc, '_', values[["AnalysisRunDate"]], '.xlsx'), showNA = FALSE)

#added 1/25/20 to avoid using package XLSX
write.csv(dff_cluster, paste0('data/processed/',
                               prod_name, '_', prod_desc, '_', today(), '.csv'))
