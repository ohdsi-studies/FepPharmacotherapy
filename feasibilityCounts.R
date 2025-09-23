# This is a FEP2 study cohort generation script for feasibility assessment purposes
# The script is supposed to be run outside of Strategus for convenience purposes
# For cohortDefinitionSet, use the cohorts folder downloaded from  the study repository:
# https://github.com/ohdsi-studies/FepPharmacotherapy/tree/main/inst

# Inputs - adjust depending on your CDM
cdmDatabaseSchema <- "main"
workDatabaseSchema <- "main"
outputFolder <- "feas_output"


# Create the connection details for your CDM
# More details on how to do this are found here:
# https://ohdsi.github.io/DatabaseConnector/reference/createConnectionDetails.html
connectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms = Sys.getenv("DBMS_TYPE"),
  connectionString = Sys.getenv("CONNECTION_STRING"),
  user = Sys.getenv("DBMS_USERNAME"),
  password = Sys.getenv("DBMS_PASSWORD")
)

# Run Cohort Generation
CohortGenerator::runCohortGeneration(
  connectionDetails,
  cdmDatabaseSchema,
  cohortDatabaseSchema = workDatabaseSchema,
  cohortDefinitionSet = CohortGenerator::getCohortDefinitionSet(
    settingsFileName = "inst/Cohorts.csv",
    jsonFolder = "inst/cohorts",
    sqlFolder = "inst/sql/sql_server"
  ),
  outputFolder = outputFolder
)