### Introduction
This document describes the data and the transformations used to generate the tidy data files required for the Getting and Cleaning Data Course Project.

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

### Transformations
#### Step 1: Auxiliary Files

The features.txt and activity_labels.txt files contain labels for the data found in the X_*.txt and y_*.txt files, respectively. These files are read into data frames for later use.

#### Step 2: Training Data Assembly

The training dataset is spread between three files (subject_train.txt, X_train.txt, and y_train.txt), so the first step is to read those files into data frames for further processing. The following modifications are made to the data from each file:
* subject_train.txt: Contains only one column, which is extracted and stored separately.
* X_train.txt: No modifications made at this time.
* y_train.txt: The activity IDs in this file are replaced with the corresponding labels found in the activity_labels.txt file.

#### Step 3: Variable Pruning / Naming

The column labels stored in the features.txt file are now added to the data. The project requirements state that only the columns with a mean or standard deviation be used, so all columns names not containing "mean()" or "std()" are removed from the raw data. This reduces the number of columns from 561 to 68.

The remaining column names are altered to make them more readable. Each name is split into logical parts using a regular expression (the _kVarNameRegex_ constant) and transformed accordingly:

    Original: tBodyAcc-mean()-Y
    Transformed: Time.Body.Acc.YAxis::Mean

* The measurement domain (the first letter) is translated into "Time" for "t" and "Frequency" for "f". 
* The next logical word, the acceleration type, is left as is.
* Everything else before the statistic type is the measurement signal. This is also left as is.
* The measurement type, denoted by -mean() or -std(), is converted into it's corresponding word (e.g. "Mean" or "Std".
* If it exists, the measurement axis, denoted by a "-" followed by "X", "Y", or "Z" at the end of the name, is translated into <axis name>Axis (e.g. "XAxis" for "X").
* Finally, the variable name is reassembled using this sequence:

      <measurement domain>.<acceleration type>.<signal>.<axis>::<statistic>

The "::" between the signal and the statistic is used as a delimiter that will be used for further processing at a later step.

#### Step 4: Create Complete Dataset

The final step is to add the y_train and subject_train data to the data frame. Each dataset is added using the _dplyr::mutate_ function, using the variable names "Activity.Name" (y_train) and "Subject.Id" (subject_train).

#### Step 5: Test Dataset Assembly

Repeat steps 2-4 for the test dataset.

#### Step 6: Merge Train and Test Datasets

The complete dataset is created by using _rbind_ to add the test data to the training data. A row number (called "Observation.Id") is also added to the dataset to preserve the original observation row before the data is broken apart and processed.

#### Step 7: Transform Variables

Each variable name from the X_* datasets actually contains two variables: the signal type, and the signal statistic (mean, std. deviation). With the tidy data rules in mind ("Each variable forms a column" and "Each observation forms a row"), these variables are transformed as follows:

1. The _tidyr::gather_ function is used to collapse the original signal variables into two columns: Measurement.Name and Measurement.Value.
2. The _tidyr::separate_ function is used to split the Measurement.Name values into columns using the "::" separator introduced in Step 3. The measurement label remains in the Measurement.Name column, and the statistic value is moved to the Measurement.Stat column.
3. The Measurement.Stat column is transformed into the "Mean" and "Std" columns using the _tidyr::spread_ function.
4. The "Std" variable name is renamed to "Standard.Deviation".

At the end of the process, the dataset contains six variables (described in more detail in the "Final Output" section):
* Subject.Id
* Activity.Name
* Observation.Id
* Measurement.Name
* Mean
* Standard.Deviation

The final dataset is saved as "./data/tidy-dataset.csv".

#### Step 8: 
The second dataset produced for the project starts with the tidy dataset from Step 6 and performs the following aggregations:
1. All variables except for the Observation.Id field are selected for processing.
2. The data is grouped by Activity.Name, Subject.Id, and Measurement.Name.
3. The average mean and standard deviation (Average.Mean and Average.Standard.Deviation, respectively) are calculated for each group.

This produces a data frame with the following variables:
* Subject.Id
* Activity.Name
* Measurement.Name
* Average.Mean
* Average.Standard.Deviation

The final dataset is saved as './data/summarized-tidy-dataset.csv'.

### Final Output

#### ./data/tidy-dataset.csv

__Dimensions:__ 339,867 Rows, 6 Columns

| Variable Name | Data Type | Description |
|:---           |:---       |:--          |
| Subject.Id    | Integer   | The ID of the subject for whom the observation was captured.|
| Activity.Name | Character | The activity the subject was performing during the observation.|
| Observation.Id | Integer  | An ID for the observation. |
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
