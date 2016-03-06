## Getting and Cleaning Data: Course Project

This repository contains the scripts and data used to satisfy the requirements for the Cousera Getting and Cleaning Data Course Project. The requirements for this project are as follows:

1. Tidy datasets created according to the following instructions:
    1. Merges the training and the test sets to create one data set.
    2. Extracts only the measurements on the mean and standard deviation for each measurement.
    3. Uses descriptive activity names to name the activities in the data set
    4. Appropriately labels the data set with descriptive variable names.
    5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
2. A link to this repository
3. A code book describing the data
4. This README.md file

### Project Files

|File           | Description   |
|:---           |:---           |
|README.md      | The current file, provides an overview of the project.   |
|CodeBook.md    | Provides a detailed description of the data files as well as the data transformations performed to create them.|
|run_analysis.R | The R code file used to generate the final tidy data sets.|
|./data/full-dataset.csv| The full tidy dataset|
|./data/summary.by.activity.and.subject.csv| The summarized dataset, grouped by activity and subject.|
