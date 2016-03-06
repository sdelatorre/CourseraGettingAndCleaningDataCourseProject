# This script tidys the "Human Activity Recognition Using Smartphones Data Set" found in the 
# UCI Machine Learning Repostiory per the project instructions:
#
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names.
# 5. From the data set in step 4, creates a second, independent tidy data set with the 
#    average of each variable for each activity and each subject.

##############################################################################################
# Load Libraries
##############################################################################################

library(dplyr)
library(stringr)
library(tidyr)

##############################################################################################
# User-editable Variables
##############################################################################################

# Set the location for the base directory of the files included in the dataset. Modify
# as needed.
data.files.base.dir = "../UCI HAR Dataset"

##############################################################################################
# Misc. Variables
##############################################################################################

# Regular expression that will split a variable name (e.g. "tBodyAcc-mean()-X") into the 
# following parts:
# [1] measurement domain (t or f)
# [2] accelration type
# [3] measurement signal
# [4] measurement type (mean or std)
# [5] (optional) measurement axis
var.name.regex = "^(t|f)([A-Z][a-z]+)([^-]+)-([^()]+)\\(\\)(-[A-Z])?$"

# A list of data file locations
data.files <- list("data.labels" = "./features.txt",
                   "activity.labels" = "./activity_labels.txt",
                   "train.subject.ids" = "./train/subject_train.txt",
                   "train.data" = "./train/X_train.txt",
                   "train.activities" = "./train/y_train.txt",
                   "test.subject.ids" = "./test/subject_test.txt",
                   "test.data" = "./test/X_test.txt",
                   "test.activities" = "./test/y_test.txt")

##############################################################################################
# Project Setup
##############################################################################################

# Verify the data file base directory exists.
if (!dir.exists(data.files.base.dir)) {
  stop("The base directory for the repository files does not exist. Please correct the setting")
}

# Verify the data files are located where they are expected to be and prepend the base 
# directory path to the file location.
for (name in names(data.files)) {
  filename <- file.path(data.files.base.dir, data.files[[name]])
  if (!file.exists(filename)) stop(sprintf("Could not find required file: %s", filename))
  else data.files[name] <- filename
}

# Create the output directory for the generated files.
if (!dir.exists("./data")) dir.create("./data")

##############################################################################################
# Functions
##############################################################################################

translate.activities <- function(feature.labels, filename) {
  # Reads in the activity ID file and translates it into the associated feature names.
  #
  # Args:
  #   feature.labels: A data frame containing a mapping of feature ids -> labels
  #   filename: The file containing the activity ID data. The data is expected to be in a 
  #             single column.
  #
  # Returns:
  #   A vector of labels corresponding to the IDs stored in the input file.
  selected.features <- read.datafile(filename)
  names(selected.features) <- c("Activity.ID")
  
  full_join(feature.labels, selected.features) %>%
  select(Activity.Name)
}

data.isValid <- function(features, subject.ids, data, activities) {
  # Validates that the data dimensions are of the expected size:
  #
  # 1. The number of rows in the data should equal the length of the subject.ids.
  # 2. The length of the activities should equal the length of the subject.ids.
  # 3. The length of the features should equal the number of columns in the data.
  #
  # Args:
  #   features: The features data frame
  #   subject.ids: The data frame containing the subject IDs
  #   data: The raw data data frame
  #   activities: The data frame containing the activiy data
  #
  # Returns:  
  #   TRUE if the data is of the correct size, FALSE otherwise
  all(c(length(subject.ids) == nrow(data),
        length(subject.ids) == length(activities),
        length(features) == ncol(data)))
}

read.datafile <- function(filename) {
  # Helper function used to read data from a table-like data file.
  #
  # Args:
  #   filename: The data file to load.
  #
  # Returns:
  #   A datagrame containing the data.
  read.table(filename, 
             header = FALSE, 
             sep = "", 
             stringsAsFactors = FALSE)
}

build.dataframe <- function(features, subject.ids, data, activities) {
  # Helper function used to build a data frames from the various datasets. The function will:
  #
  # 1. Merge the datasets. 
  # 2. Remove all of the variables that are not associated with the mean or standard
  #    deviation. 
  # 3. Returns the results
  #
  # Args:
  #   features: A vector of column names 
  #   subject.ids: A vector of IDs for the test subjects
  #   data: The data set
  #   activities: The activity that corresponded to the measurement
  #   data.type: A constant value added to the dataset to indicate the type (e.g. 'test'
  #              or 'training')
  #
  # Returns:
  #   A merged data frame.
  names(data) = features
  
  # ASSIGNMENT STEP 2: Retain only the variables measuring the mean and std
  modified.df <- data[, grep("mean\\(|std\\(", features, ignore.case = TRUE)]
  # ASSIGNMENT STEP 4: Use descriptive variable names 
  names(modified.df) <- format.colnames(names(modified.df))
  
  modified.df %>% mutate(Activity.Name = activities) %>%
                  mutate(Subject.Id = subject.ids) %>% 
                  select(Subject.Id, Activity.Name, everything())
}

format.colnames <- function(original.names) {
  # Reformats the column names to make them a little easier to read.
  #
  # Args:
  #   original.names: The names to transform
  #
  # Returns:
  #   A vector of reformatted column names.
  process.name <- function(name) {
    parts <- str_match(name, var.name.regex)[1,2:6]
    domain <- switch(parts[1], t = "Time", f = "Frequency")
    type = parts[2]
    signal = parts[3]
    stat = capitalize(parts[4])
    axis = parts[5]
    if (is.na(axis)) sprintf("%s.%s.%s::%s", domain, type, signal, stat)
    else sprintf("%s.%s.%s.%sAxis::%s", domain, type, signal, substr(axis, 2, 2), stat)
  }
  sapply(original.names, process.name, USE.NAMES = FALSE)
}

capitalize <- function(word) {
  # Helper function that capitalizes a string.
  #
  # Args:
  #   word: The string to capitalize.
  # 
  # Returns:
  #   The capitalized word.
  paste(toupper(substr(word[1], 1, 1)), substr(word, 2, nchar(word)), sep = "")
}

##############################################################################################
# Data Processing 
#
# Read the data files into data frames. The data in these files are separated by a variable- 
# length space characters, so read.table is used to ingest the text.
#
# Data validation is performed after reading the data:
# 1. The number of rows for the data & activity datasets should be the same as the
#    number of rows in the subject id dataset.
# 2. The number of features in the features dataset should match the number
#    of columns in the data datasets.
#
# Finally, the resulting datasets are merged and reshaped before being saved to disk.
##############################################################################################
# General data loading.
data.labels <- read.datafile(data.files$data.labels)$V2

activity.labels <- read.datafile(data.files$activity.labels)
names(activity.labels) = c("Activity.ID", "Activity.Name")

# Load training data.
train.subject.ids <- read.datafile(data.files$train.subject.ids)$V1
train.data <- read.datafile(data.files$train.data)
train.activities <- translate.activities(activity.labels, data.files$train.activities)$Activity.Name

# Validate data
if (!data.isValid(data.labels, train.subject.ids, train.data, train.activities )) {
  stop("The data in the training set is incorrect, please verify the data.")
}

# Load testing data.
test.subject.ids <- read.datafile(data.files$test.subject.ids)$V1
test.data <- read.datafile(data.files$test.data)
test.activities <- translate.activities(activity.labels, data.files$test.activities)$Activity.Name

# Validate data
if (!data.isValid(data.labels, test.subject.ids, test.data, test.activities)) {
  stop("The data in the test set is incorrect, please verify the data.")
}

# Print out dataset dimensions before transformation.
print("Data Dimensions:")
print(" Training Data:")
print(sprintf("  subject.ids: length(%s)", length(train.subject.ids)))
print(sprintf("  data: dim(%s, %s)", dim(train.data)[1], dim(train.data)[2]))
print(sprintf("  activities: length(%s)", length(train.activities)))
print(" Test Data:")
print(sprintf("  subject.ids: length(%s)", length(test.subject.ids)))
print(sprintf("  data: dim(%s, %s)", dim(test.data)[1], dim(test.data)[2]))
print(sprintf("  activities: length(%s)", length(test.activities)))

# Build the data frames from the file data. This includes removing the unwanted variables
# as described in ASSIGNMENT STEP 2.
train.df <- build.dataframe(data.labels, train.subject.ids, train.data, train.activities)
test.df <- build.dataframe(data.labels, test.subject.ids, test.data, test.activities)

# ASSIGNMENT STEP 1: merge the datasets.
merged.df <- rbind(train.df, test.df)

# Add an observation id before reshaping the data. The reshaping will break apart each 
# row of observations, so this ID will allow the original row to be reconstructed if
# needed. It also prevents the spread function from crashing R/R Studio. 
merged.df$Observation.Id <- 1:nrow(merged.df)

# Calculate and save a few values to validate the reshaping/calculation done 
# at the end.
user.one.data <- merged.df[merged.df$Subject.Id == 1,]
user.one.avg.mean <- mean(user.one.data$`Time.Body.Acc.XAxis::Mean`)
user.one.avg.std <- mean(user.one.data$`Time.Body.Acc.XAxis::Std`)

walking.data <- merged.df[merged.df$Activity.Name == "WALKING",]
walking.avg.mean <- mean(walking.data$`Time.Body.Acc.XAxis::Mean`)
walking.avg.std <- mean(walking.data$`Time.Body.Acc.XAxis::Std`)

# reshape the data into its final format
merged.df <- merged.df %>% 
  gather(Measurement.Name, Measurement.Value, -Subject.Id, -Activity.Name, -Observation.Id) %>%
  separate(Measurement.Name, c("Measurement.Name", "Measurement.Stat"), sep = "::") %>%
  spread(Measurement.Stat, Measurement.Value)

rm(train.df, train.data, train.activities, train.subject.ids)
rm(test.df, test.data, test.activities, test.subject.ids)

# Dump the tidy dataset to disk
write.csv(merged.df, "./data/full-dataset.csv")

# ASSIGNMENT STEP 5: Creates a second, independent tidy data set with the average of each variable 
# for each activity and each subject.

# Calculate the average of each variable for each activity 
by.activity.df <- merged.df %>% 
                    select(Activity.Name, Measurement.Name, Mean, Std) %>%
                    group_by(Activity.Name, Measurement.Name) %>% 
                    summarize( Average.Mean = mean(Mean), Average.Standard.Deviation = mean(Std))

# Validate the calculations
validation.activity <- by.activity.df[by.activity.df$Activity.Name == "WALKING" &
                                      by.activity.df$Measurement.Name == "Time.Body.Acc.XAxis",][1,]
if (validation.activity$Average.Mean != walking.avg.mean ||
    validation.activity$Average.Standard.Deviation != walking.avg.std) {
  stop("The activity values calculated before the data manipulation do not match the validation values.")
}

write.csv(by.activity.df, "./data/summary.by.activity.csv")
rm(validation.activity, walking.data, walking.avg.mean, walking.avg.std)

# Calculate the average of each variable for each subject 
by.subject.df <- merged.df %>%
                   select(Subject.Id, Measurement.Name, Mean, Std) %>%
                   group_by(Subject.Id, Measurement.Name) %>%
                   summarize( Average.Mean = mean(Mean), Average.Standard.Deviation = mean(Std))

# Validate the calculations.
validation.subject <- by.subject.df[by.subject.df$Subject.Id == 1 &
                                    by.subject.df$Measurement.Name == "Time.Body.Acc.XAxis" ,][1,]
if (validation.subject$Average.Mean != user.one.avg.mean ||
    validation.subject$Average.Standard.Deviation != user.one.avg.std) {
  stop("The subject values calculated before the data manipulation do not match the validation values.")
}

write.csv(by.activity.df, "./data/summary.by.subject.csv")
rm(validation.subject, user.one.data, user.one.avg.mean, user.one.avg.std)

# Calculate the average of each variable for each subject and activity
by.activity.subject.df <- merged.df %>%
                            select(Activity.Name, Subject.Id, Measurement.Name, Mean, Std) %>%
                            group_by(Activity.Name, Subject.Id, Measurement.Name) %>%
                            summarize( Average.Mean = mean(Mean), Average.Standard.Deviation = mean(Std))
write.csv(by.activity.df, "./data/summary.by.activity.and.subject.csv")
