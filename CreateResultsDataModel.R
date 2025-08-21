################################################################################
# INSTRUCTIONS: The code below assumes you have access to a PostgreSQL database
# and permissions to create tables in an existing schema specified by the
# resultsDatabaseSchema parameter.
# 
# See the Working with results section
# of the UsingThisTemplate.md for more details.
# 
# More information about working with results produced by running Strategus 
# is found at:
# https://ohdsi.github.io/Strategus/articles/WorkingWithResults.html
# ##############################################################################

# Code for creating the result schema and tables in a PostgreSQL database
resultsDatabaseSchema <- "fep2_results"
analysisSpecifications <- ParallelLogger::loadSettingsFromJson(
  fileName = "inst/FepPharmacotherapyAnalysisSpecification.json"
)

resultsDatabaseConnectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms = "postgresql",
  server = Sys.getenv("server"),
  user = Sys.getenv("user"),
  password = Sys.getenv("password")
)

# Tests
#connection <- DatabaseConnector::connect(dbms = "postgresql",
#                                         server = Sys.getenv("server"),
#                                         user = Sys.getenv("user"),
#                                         password = Sys.getenv("password"))
#DatabaseConnector::querySql(connection, "SELECT 1;")  # Simple query to test connection

# Create results data model -------------------------

# Use the 1st results folder to define the results data model
# For 'folder', insert the appropriate DP folder

resultsFolder <- list.dirs(path = "results/folder", full.names = T, recursive = F)[1]
resultsDataModelSettings <- Strategus::createResultsDataModelSettings(
  resultsDatabaseSchema = resultsDatabaseSchema,
  resultsFolder = file.path(resultsFolder)
)

Strategus::createResultDataModel(
  analysisSpecifications = analysisSpecifications,
  resultsDataModelSettings = resultsDataModelSettings,
  resultsConnectionDetails = resultsDatabaseConnectionDetails
)