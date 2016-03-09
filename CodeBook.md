### Introduction
This document describes the data used to generate the tidy data files required for the Getting and Cleaning Data Course Project.

### Raw Data
The raw data used for this analysis is taken from the "Human Activity Recognition Using Smartphones" dataset found in the UCI Machine Learning Repository (http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones). The full dataset can be found here: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip. 

The data represents various statistics calculated from "the recordings of 30 subjects performing activities of daily living (ADL) while carrying a waist-mounted smartphone with embedded inertial sensors".

The files from the dataset used in this project include the following:

| File Name | Description |
|:---       |:---
| features.txt | A single-column of variable names for the X_*.txt files. |
| activity_labels.txt | A two-column dataset that maps the activity IDs to their associated label. |
| train/subject_train.txt | A dataset denoting the subject ID for the corresponding row in the X_train.txt data |
| train/X_train.txt | The raw training data. |
| train/y_train.txt | A dataset denoting the activity ID for each row in the X_train.txt data. |
| test/subject_test.txt | A dataset denoting the subject ID for the corresponding row in the X_test.txt data |
| test/X_test.txt | The raw test data. |
| test/y_test.txt | A dataset denoting the activity ID for each row in the X_test.txt data. |

### Data Files

#### ./data/tidy-dataset.csv

__Dimensions:__ 339,867 Rows, 6 Columns

| Variable Name | Data Type | Description |
|:---           |:---       |:--          |
| Subject.Id    | Integer   | The ID of the subject for whom the observation was captured.|
| Activity.Name | Character | The activity the subject was performing during the observation.|
| Observation.Id | Integer  | An ID for the original observation row. |
| Measurement.Name | Character | The name of the measurement taken.|
| Mean          | Number | The mean value for the measurement.|
| Standard.Deviation | Number | The standard deviation for the measurement. |

#### ./data/summarized-tidy-dataset.csv

__Dimensions:__ 1,320 Rows, 5 Columns

| Variable Name | Data Type | Description |
|:---           |:---       |:--          |
| Subject.Id    | Integer   | The ID of the subject for whom the observation was captured.|
| Activity.Name | Character | The activity the subject was performing during the observation.|
| Measurement.Name | Character | The name of the measurement taken.|
| Average.Mean  | Number | The average Mean for the grouping by Subject.Id/Activity.Name/Measurement.Name.|
| Average.Standard.Deviation | Number | The average Standard.Deviation for the grouping by Subject.Id/Activity.Name/Measurement.Name. |
