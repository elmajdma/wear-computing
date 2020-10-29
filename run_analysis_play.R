library(data.table)
library(dplyr)
library(stringr)
project_path <- getwd()

features <-
  fread(
    file.path(project_path, "UCI HAR Dataset/features.txt"),
    col.names = c("index", "featureName")
  )
featuresMesurments <-
  slice(features, str_which(features[, featureName], "(mean|std)\\(\\)"))
activityLabels <-
  fread(
    file.path(project_path, "UCI HAR Dataset/activity_labels.txt"),
    col.names = c("index", "activity_name")
  )
featuresMesurments$featureName <-
  str_replace_all(featuresMesurments$featureName, '[()]', '')
# Train datasets
trainData <-
  tbl_df(fread(file.path(
    project_path, "UCI HAR Dataset/train/X_train.txt"
  ))[, featuresMesurments$index, with = FALSE])
setnames(trainData,
         colnames(trainData),
         featuresMesurments$featureName)
trainActivities <-
  fread(
    file.path(project_path, "UCI HAR Dataset/train/y_train.txt")
    ,
    col.names = c("activities")
  )
trainSubjects <-
  fread(
    file.path(project_path, "UCI HAR Dataset/train/subject_train.txt")
    ,
    col.names = c("SubjectId")
  )
trainData <- cbind(trainSubjects, trainActivities, trainData)

#Test datasets
testData <-
  tbl_df(fread(file.path(
    project_path, "UCI HAR Dataset/test/X_test.txt"
  ))[, featuresMesurments$index, with = FALSE])
setnames(testData, colnames(testData), featuresMesurments$featureName)
testActivities <-
  fread(
    file.path(project_path, "UCI HAR Dataset/test/y_test.txt")
    ,
    col.names = c("activities")
  )
testSubjects <-
  fread(
    file.path(project_path, "UCI HAR Dataset/test/subject_test.txt")
    ,
    col.names = c("SubjectId")
  )
testData <- cbind(testSubjects, testActivities, testData)

# merge datasets
trainTestData <- rbind(trainData, testData)
grouped_data <- group_by(trainTestData, SubjectId, activities)
data_summarize <- summarise_all(grouped_data, "mean")
data.table::fwrite(x = data_summarize, file = "tidyData.txt", quote = FALSE)
