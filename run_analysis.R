# This script tidys the "Human Activity Recognition Using Smartphones" dataset found in the 
# UCI Machine Learning Repostiory. The instructions provided for this analysis are as follows:
#
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names.
# 5. From the dataset in step 4, creates a second, independent tidy data set with the 
#    average of each variable for each activity and each subject.

##############################################################################################
# Libraries
##############################################################################################

library(dplyr)
library(stringr)
library(tidyr)

##############################################################################################
# Constants
##############################################################################################

# Set the base directory for the raw data files. Modify as needed.
kDataFilesDir = "../UCI HAR Dataset"

# Regular expression that will split a variable name (e.g. "tBodyAcc-mean()-X") into the 
# following parts:
# [1] measurement domain (t or f)
# [2] acceleration type
# [3] measurement signal
# [4] measurement type (mean or std)
# [5] (optional) measurement axis
kVarNameRegex = "^(t|f)([A-Z][a-z]+)([^-]+)-([^()]+)\\(\\)(-[A-Z])?$"

# A list of data file locations
kDataFiles <- list("data.labels" = "./features.txt",
                   "activity.labels" = "./activity_labels.txt",
                   "train.subject.ids" = "./train/subject_train.txt",
                   "train.data" = "./train/X_train.txt",
                   "train.activities" = "./train/y_train.txt",
                   "test.subject.ids" = "./test/subject_test.txt",
                   "test.data" = "./test/X_test.txt",
                   "test.activities" = "./test/y_test.txt")

##############################################################################################
# Project Setup / Raw Data Verifications
##############################################################################################

# Verify the data file base directory exists.
if (!dir.exists(kDataFilesDir)) {
  stop("The base directory for the repository files does not exist. Please correct the setting")
}

# Verify the data files are located where they are expected to be and prepend the base 
# directory path to the file location.
for (name in names(kDataFiles)) {
  filename <- file.path(kDataFilesDir, kDataFiles[[name]])
  if (!file.exists(filename)) stop(sprintf("Could not find required file: %s", filename))
  else kDataFiles[name] <- filename
}

# Create the output directory for the generated files.
if (!dir.exists("./data")) dir.create("./data")

##############################################################################################
# Functions
##############################################################################################

TranslateActivities <- function(feature.labels, filename) {
  # Reads in the activity ID file and translates it into the associated feature names.
  #
  # Args:
  #   feature.labels: A data frame containing a mapping of feature ids -> labels
  #   filename: The file containing the activity ID data. The data is expected to be in a 
  #             single column.
  #
  # Returns:
  #   A vector of labels corresponding to the IDs stored in the input file.
  selected.features <- ReadDatafile(filename)
  names(selected.features) <- c("Activity.ID")
  
  full_join(selected.features, feature.labels) %>%
  select(Activity.Name)
}

DataIsValid <- function(features, subject.ids, data, activities) {
  # Validates that the data dimensions are of the expected size:
  #
  # 1. The number of rows in the data should equal the length of the subject.ids.
  # 2. The length of the activities should equal the length of the subject.ids.
  # 3. The length of the features should equal the number of columns in the data.
  #
  # Args:
  #   features: The features vector
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

ReadDatafile <- function(filename) {
  # Helper function used to read data from a table-like data file.
  #
  # Args:
  #   filename: The data file to load.
  #
  # Returns:
  #   A data frame containing the data.
  read.table(filename, 
             header = FALSE, 
             sep = "", 
             stringsAsFactors = FALSE)
}

BuildDataFrame <- function(features, subject.ids, data, activities) {
  # Helper function used to build a data frame from the various datasets. 
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
  
  # Retain only the variables measuring the mean and std
  modified.df <- data[, grep("mean\\(|std\\(", features, ignore.case = TRUE)]
  
  # Use descriptive variable names 
  names(modified.df) <- FormatColumnNames(names(modified.df))
  
  modified.df %>% mutate(Activity.Name = activities) %>%
                  mutate(Subject.Id = subject.ids) %>% 
                  select(Subject.Id, Activity.Name, everything())
}

FormatColumnNames <- function(original.names) {
  # Reformats the column names to make them a little easier to read.
  #
  # Args:
  #   original.names: The names to transform
  #
  # Returns:
  #   A vector of reformatted column names.
  process.name <- function(name) {
    parts <- str_match(name, kVarNameRegex)[1,2:6]
    domain <- switch(parts[1], t = "Time", f = "Frequency")
    type = parts[2]
    signal = parts[3]
    stat = Capitalize(parts[4])
    axis = parts[5]
    if (is.na(axis)) sprintf("%s.%s.%s::%s", domain, type, signal, stat)
    else sprintf("%s.%s.%s.%sAxis::%s", domain, type, signal, substr(axis, 2, 2), stat)
  }
  sapply(original.names, process.name, USE.NAMES = FALSE)
}

Capitalize <- function(word) {
  # Helper function that capitalizes a string.
  #
  # Args:
  #   word: The string to Capitalize.
  # 
  # Returns:
  #   The capitalized word.
  paste(toupper(substr(word[1], 1, 1)), substr(word, 2, nchar(word)), sep = "")
}

##############################################################################################
# Data Processing 
##############################################################################################

# Load data from supporting files.
data.labels <- ReadDatafile(kDataFiles$data.labels)$V2

activity.labels <- ReadDatafile(kDataFiles$activity.labels)
names(activity.labels) = c("Activity.ID", "Activity.Name")

# Load training data.
train.subject.ids <- ReadDatafile(kDataFiles$train.subject.ids)$V1
train.data <- ReadDatafile(kDataFiles$train.data)
train.activities <- TranslateActivities(activity.labels, kDataFiles$train.activities)$Activity.Name

# Validate data
if (!DataIsValid(data.labels, train.subject.ids, train.data, train.activities )) {
  stop("The data in the training set is incorrect, please verify the data.")
}

# Load testing data.
test.subject.ids <- ReadDatafile(kDataFiles$test.subject.ids)$V1
test.data <- ReadDatafile(kDataFiles$test.data)
test.activities <- TranslateActivities(activity.labels, kDataFiles$test.activities)$Activity.Name

# Validate data
if (!DataIsValid(data.labels, test.subject.ids, test.data, test.activities)) {
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

# Build the data frames from the file data. 
train.df <- BuildDataFrame(data.labels, train.subject.ids, train.data, train.activities)
test.df <- BuildDataFrame(data.labels, test.subject.ids, test.data, test.activities)

# Merge the datasets.
merged.df <- rbind(train.df, test.df)

# Add an observation id before reshaping the data. The reshaping will break apart each 
# row of observations, so this ID will allow the original row to be reconstructed if
# needed. It also prevents the tidyr::spread function from crashing R Studio. 
merged.df$Observation.Id <- 1:nrow(merged.df)

# reshape the data into its final format
merged.df <- merged.df %>% 
  gather(Measurement.Name, Measurement.Value, -Subject.Id, -Activity.Name, -Observation.Id) %>%
  separate(Measurement.Name, c("Measurement.Name", "Measurement.Stat"), sep = "::") %>%
  spread(Measurement.Stat, Measurement.Value) %>%
  rename(Standard.Deviation = Std)

# Cleanup
#rm(train.df, train.data, train.activities, train.subject.ids)
#rm(test.df, test.data, test.activities, test.subject.ids)

# Write the tidy dataset to disk
write.table(merged.df, "./data/tidy-dataset.txt", row.names = FALSE)

# Calculate the average of each variable for each subject and activity and write to disk.
by.activity.subject.df <- merged.df %>%
  select(-Observation.Id) %>%
  group_by(Activity.Name, Subject.Id, Measurement.Name) %>%
  summarize(Average.Mean = mean(Mean), Average.Standard.Deviation = mean(Standard.Deviation))

write.table(by.activity.subject.df, "./data/summarized-tidy-dataset.txt", row.names = FALSE)
