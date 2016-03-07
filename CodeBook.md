### Introduction
This document describes the data and the transformations used to generate the output required for the Getting and Cleaning Data Course Project.

### Raw Data Description
The raw data used for this analysis is the "Human Activity Recognition Using Smartphones Data Set" found in the UCI Machine Learning Repository (http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones). The dataset can be found here: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip. 

The data represents "the recordings of 30 subjects performing activities of daily living (ADL) while carrying a waist-mounted smartphone with embedded inertial sensors".

The files from the dataset used in this project include the following:

| File Name | Description |
|:---       |:---
| features.txt | A single-column of variable names for the X_*.txt files. |
| activity_labels.txt | A two-column dataset that maps the activity IDs to their associated label. |
| train/subject_train.txt | A dataset denoting the subject ID for the corresonding row in the X_train.txt data |
| train/X_train.txt | The raw training data. |
| train/y_train.txt | A dataset denoting the activity ID for each row in the X_train.txt data. |
| test/subject_test.txt | A dataset denoting the subject ID for the corresonding row in the X_test.txt data |
| test/X_test.txt | The raw test data. |
| test/y_test.txt | A dataset denoting the activity ID for each row in the X_test.txt data. |

### Transformations
#### Step 1: Auxilliary Files

The features.txt and activity_labels.txt files are used 

#### Step 1: Assemble Data

The training dataset is spread between three files (subject_train.txt, X_train.txt, y_train.txt), so the first step is to read those files into data frames for further processing. The following modifications were made to the data from each file:
* subject_train.txt: Only of the first column of the data frame is needed, so that's the only part retained.
* X_train.txt: No modifications made at this time.
* y_train.txt: The activity IDs in this file are replaced with the corresponding label found in the activity_labels.txt file.

#### Step 2: Add Variable Names

#### Step 3: Create Complete Dataset

#### Step 4: Create the test dataset

Repeat steps 1-4 fro the rest dataset.

#### Step 5: Merge Train and Test Datasets

#### Step 6: Tranform Variables

#### Step 7: 

### Final Output

#### ./data/tidy-dataset.csv

| Variable Name | Description |
|:---           |:---         |
|               |             |
#### ./data/summarized-tidy-dataset.csv
| Variable Name | Description |
|:---           |:---         |
|               |             |