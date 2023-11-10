#install necessary packages
library(tidyverse)
install.packages("janitor")
library(janitor)

#import the dataset
Q1 <- read.csv("Divvy_Trips_2018_Q1.csv")
Q2 <- read.csv("Divvy_Trips_2018_Q2.csv")
Q3 <- read.csv("Divvy_Trips_2018_Q3.csv")
Q4 <- read.csv("Divvy_Trips_2018_Q4.csv")

colnames(Q1)
Q1 <- Q1[-1,]
rownames(Q1) <- NULL

#create a combined dataframe to represent the 2018 year as a whole
merged_df <- rbind(Q1, Q2, Q3, Q4)
View(merged_df)

#remove the individual quarter datas to clean memory
rm(Q1)
rm(Q2)
rm(Q3)
rm(Q4)

#peek at the combined data
glimpse(merged_df)
str(merged_df)

#note there is no latitude and longitude present in the 2018 dataset hece geo plots are not possible.
#unless it can be infered them from the station id and name, but in my case i did not do that as I'm unaware how to.

# filter the dataset by removing any null values on columns besides gender & birthyear
# only filtered the other rows because the gender and birthyear does not really afftect the aspect of analysis
#  I think
filtered_df <- merged_df %>% drop_na(!c('gender', 'birthyear'))
rm(merged_df)

#preview datatype and convert necessary ones to numeric and date time
sapply(filtered_df, class)
sapply(filtered_df, mode)
filtered_df <- filtered_df %>% transform(trip_id = as.integer(trip_id),
                                         bikeid = as.integer(bikeid),
                                         from_station_id = as.integer(from_station_id),
                                         to_station_id = as.integer(to_station_id),
                                         tripduration = as.integer(gsub(",", "", tripduration)),
                                         start_time = as_datetime(start_time),
                                         end_time = as_datetime(end_time))
                                         
#check if the trip id is unique after filter 
n_distinct(filtered_df$trip_id)

#check for trip duration more than a day and less than a minute and store it in different df - bassically removing outliers 
#even though the guidelines mentioned that the bike can be returned anytime ie, filtering tripduration which are > 1 day which is 1440 minutes essentially.
filtered_df <- filtered_df %>% filter(!(tripduration > 1440 | tripduration <= 1))

#null check for every col in the df
null_counts <- filtered_df %>% summarise_all(~sum(is.na(.)))

#check for gender types note:doesnt matter to filter out gender so leave it out anyways
gender <- unique(filtered_df$gender)
print(gender)

#same thing for making sure there's only 2 user type
usertype <- unique(filtered_df$usertype)
print(usertype)


#additional filter if needed :- from and to stations are the same
#filter2 <- filter1 %>% filter(from_station_id == to_station_id)


#visualization
#might end up complex in R so I went with the good old Tableau(super easy :D)
