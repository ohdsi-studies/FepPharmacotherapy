################################################################################
# INSTRUCTIONS: Make sure you have downloaded your cohorts using 
# DownloadCohorts.R and that those cohorts are stored in the "inst" folder
# of the project. This script is written to use the sample study cohorts
# located in "inst/sampleStudy/Eunomia" so you will need to modify this in the code 
# below. 
# 
# See the Create analysis specifications section
# of the UsingThisTemplate.md for more details.
# 
# More information about Strategus HADES modules can be found at:
# https://ohdsi.github.io/Strategus/reference/index.html#omop-cdm-hades-modules.
# This help page also contains links to the corresponding HADES package that
# further details.
# ##############################################################################
library(dplyr)
library(Strategus)

# Time-at-risks (TARs) for the outcomes of interest in your study
timeAtRisks <- tibble(
  label = c("180 days after the first month"),
  riskWindowStart  = c(30),
  startAnchor = c("cohort start"),
  riskWindowEnd  = c(210),
  endAnchor = c("cohort start")
)


# If you are not restricting your study to a specific time window, 
# please make these strings empty
studyStartDate <- '20171201' #YYYYMMDD
studyEndDate <- '20124231'   #YYYYMMDD
# Some of the settings require study dates with hyphens
studyStartDateWithHyphens <- gsub("(\\d{4})(\\d{2})(\\d{2})", "\\1-\\2-\\3", studyStartDate)
studyEndDateWithHyphens <- gsub("(\\d{4})(\\d{2})(\\d{2})", "\\1-\\2-\\3", studyEndDate)


# Consider these settings for estimation  ----------------------------------------

useCleanWindowForPriorOutcomeLookback <- FALSE # If FALSE, lookback window is all time prior, i.e., including only first events
psMatchMaxRatio <- 1 # If bigger than 1, the outcome model will be conditioned on the matched set

# Shared Resources -------------------------------------------------------------
# Get the list of cohorts - NOTE: you should modify this for your
# study to retrieve the cohorts you downloaded as part of
# DownloadCohorts.R
cohortDefinitionSet <- CohortGenerator::getCohortDefinitionSet(
  settingsFileName = "inst/Cohorts.csv",
  jsonFolder = "inst/cohorts",
  sqlFolder = "inst/sql/sql_server"
)

# TODO: Create negative controls and add them as a concept set
negativeControlOutcomeCohortSet <- CohortGenerator::readCsv(
 file = "inst/negativeControlOutcomes.csv"
)

#if (any(duplicated(cohortDefinitionSet$cohortId, negativeControlOutcomeCohortSet$cohortId))) {
#  stop("*** Error: duplicate cohort IDs found ***")
#}

# Create some data frames to hold the cohorts we'll use in each analysis ---------------
# Outcomes: The outcome for this study is cohort_id == 10
# TODO: Check if CLeanWindow is correct
oList <- cohortDefinitionSet |>
  filter(cohortId == 10) |>
  mutate(
    outcomeCohortId = cohortId, 
    outcomeCohortName = cohortName) |>
  select(outcomeCohortId, outcomeCohortName) |>
  mutate(cleanWindow = 365)

ingredients <- tibble(
  conceptId = c(735979, 766529, 757688, 46275300, 
                 785788, 766814, 40137339, 703244),
  conceptName = c("risperidone", "haloperidol", "aripiprazole", 
                   "brexpiprazole", "olanzapine", "quetiapine", 
                   "paliperidone", "paliperidone")
  )
# Cohorts for the CohortMethod analysis
cmTcList <- data.frame(
  targetCohortId = 1:9,  
  targetCohortName = c("risperidone", "haloperidol", "aripiprazole", "brexpiprazole", "olanzapine", "quetiapine", "ziprazidone", "lurazidone", "paliperidone"),
  comparatorCohortId = 1:9,
  comparatorCohortName = c("risperidone", "haloperidol", "aripiprazole", "brexpiprazole", "olanzapine", "quetiapine", "ziprazidone", "lurazidone", "paliperidone")
)

analysisGrid <- tidyr::expand_grid(
  targetId = cmTcList$targetCohortId,
  comparatorId = cmTcList$targetCohortId
) |>
  filter(targetId != comparatorId) |>
  filter(targetId < comparatorId) |>
  left_join(
    cmTcList |> select(targetId = targetCohortId, targetName = targetCohortName),
    by = "targetId"
  ) |>
  left_join(
    cmTcList |> select(comparatorId = comparatorCohortId, comparatorName = comparatorCohortName),
    by = "comparatorId"
  )


# For the CohortMethod LSPS we'll need to exclude the drugs of interest in this
# study
# TODO: Rewrite to create a df of all the concepts
excludedCovariateConcepts <- ingredients

# CohortGeneratorModule --------------------------------------------------------
cgModuleSettingsCreator <- CohortGeneratorModule$new()
cohortDefinitionShared <- cgModuleSettingsCreator$createCohortSharedResourceSpecifications(cohortDefinitionSet)
negativeControlsShared <- cgModuleSettingsCreator$createNegativeControlOutcomeCohortSharedResourceSpecifications(
  negativeControlOutcomeCohortSet = negativeControlOutcomeCohortSet,
  occurrenceType = "first",
  detectOnDescendants = TRUE
)
cohortGeneratorModuleSpecifications <- cgModuleSettingsCreator$createModuleSpecifications(
  generateStats = TRUE
)

# CohortDiagnoticsModule Settings ---------------------------------------------
cdModuleSettingsCreator <- CohortDiagnosticsModule$new()
cohortDiagnosticsModuleSpecifications <- cdModuleSettingsCreator$createModuleSpecifications(
  cohortIds = cohortDefinitionSet$cohortId,
  runInclusionStatistics = TRUE,
  runIncludedSourceConcepts = TRUE,
  runOrphanConcepts = TRUE,
  runTimeSeries = FALSE,
  runVisitContext = TRUE,
  runBreakdownIndexEvents = TRUE,
  runIncidenceRate = TRUE,
  runCohortRelationship = TRUE,
  runTemporalCohortCharacterization = TRUE,
  minCharacterizationMean = 0.01
)


# CohortMethodModule -----------------------------------------------------------
# and try to do it in a loop for each respective analysis
cmModuleSettingsCreator <- CohortMethodModule$new()
covariateSettings <- FeatureExtraction::createDefaultCovariateSettings(
  excludedCovariateConceptIds = excludedCovariateConcepts$conceptId
)
outcomeList <- append(lapply(seq_len(nrow(oList)), function(i) {
  CohortMethod::createOutcome(
      outcomeId = oList$outcomeCohortId[i],
      outcomeOfInterest = TRUE,
      trueEffectSize = NA
    )
  }),
  lapply(negativeControlOutcomeCohortSet$cohortId, function(i) {
    CohortMethod::createOutcome(
      outcomeId = i,
      outcomeOfInterest = FALSE,
      trueEffectSize = 1,
      priorOutcomeLookback  = 99999
    )
  }))

targetComparatorOutcomesList <- purrr::pmap(analysisGrid, ~ CohortMethod::createTargetComparatorOutcomes(
  targetId = ..1,
  comparatorId = ..2,
  outcomes = outcomeList,
  excludedCovariateConceptIds = c(
    excludedCovariateConcepts$conceptId
  )
))

getDbCohortMethodDataArgs <- CohortMethod::createGetDbCohortMethodDataArgs(
  restrictToCommonPeriod = FALSE,
  studyStartDate = studyStartDate,
  studyEndDate = studyEndDate,
  maxCohortSize = 0,
  covariateSettings = covariateSettings
)
createPsArgs = CohortMethod::createCreatePsArgs(
  maxCohortSizeForFitting = 250000,
  errorOnHighCorrelation = TRUE,
  stopOnError = FALSE, # Setting to FALSE to allow Strategus complete all CM operations; when we cannot fit a model, the equipoise diagnostic should fail
  estimator = "att",
  prior = Cyclops::createPrior(
    priorType = "laplace", 
    exclude = excludedCovariateConcepts$conceptId, 
    useCrossValidation = TRUE
  ),
  control = Cyclops::createControl(
    noiseLevel = "silent", 
    cvType = "auto", 
    seed = 1, 
    resetCoefficients = TRUE, 
    tolerance = 2e-07, 
    cvRepetitions = 1, 
    startingVariance = 0.01
  )
)
matchOnPsArgs = CohortMethod::createMatchOnPsArgs(
  maxRatio = psMatchMaxRatio,
  caliper = 0.2,
  caliperScale = "standardized logit",
  allowReverseMatch = FALSE,
  stratificationColumns = c()
)

stratifyByPsArgs <- CohortMethod::createStratifyByPsArgs(
  numberOfStrata = 5,
  stratificationColumns = c(),
  baseSelection = "all"
)
computeSharedCovariateBalanceArgs = CohortMethod::createComputeCovariateBalanceArgs(
  maxCohortSize = 250000,
  covariateFilter = NULL
)
computeCovariateBalanceArgs = CohortMethod::createComputeCovariateBalanceArgs(
  maxCohortSize = 250000,
  covariateFilter = FeatureExtraction::getDefaultTable1Specifications()
)
# TODO: check the parameters
fitOutcomeModelArgs = CohortMethod::createFitOutcomeModelArgs(
  modelType = "cox",
  stratified = FALSE,
  useCovariates = FALSE,
  inversePtWeighting = FALSE,
  prior = Cyclops::createPrior(
    priorType = "laplace", 
    useCrossValidation = TRUE
  ),
  control = Cyclops::createControl(
    cvType = "auto", 
    seed = 1, 
    resetCoefficients = TRUE,
    startingVariance = 0.01, 
    tolerance = 2e-07, 
    cvRepetitions = 1, 
    noiseLevel = "quiet"
  )
)
cmAnalysisList <- list()
for (i in seq_len(nrow(timeAtRisks))) {
  createStudyPopArgs <- CohortMethod::createCreateStudyPopulationArgs(
    firstExposureOnly = FALSE,
    removeDuplicateSubjects = "keep all",
    censorAtNewRiskWindow = TRUE,
    removeSubjectsWithPriorOutcome = FALSE,
    priorOutcomeLookback = 0,
    riskWindowStart = timeAtRisks$riskWindowStart[[i]],
    startAnchor = timeAtRisks$startAnchor[[i]],
    riskWindowEnd = timeAtRisks$riskWindowEnd[[i]],
    endAnchor = timeAtRisks$endAnchor[[i]],
    minDaysAtRisk = 1,
    maxDaysAtRisk = 99999
  )
  cmAnalysisList[[i]] <- CohortMethod::createCmAnalysis(
    analysisId = i,
    description = sprintf(
      "Cohort method, %s",
      timeAtRisks$label[i]
    ),
    getDbCohortMethodDataArgs = getDbCohortMethodDataArgs,
    createStudyPopArgs = createStudyPopArgs,
    createPsArgs = createPsArgs,
    matchOnPsArgs = matchOnPsArgs,
    # stratifyByPsArgs = stratifyByPsArgs,
    computeSharedCovariateBalanceArgs = computeSharedCovariateBalanceArgs,
    computeCovariateBalanceArgs = computeCovariateBalanceArgs,
    fitOutcomeModelArgs = fitOutcomeModelArgs
  )
}
cohortMethodModuleSpecifications <- cmModuleSettingsCreator$createModuleSpecifications(
  cmAnalysisList = cmAnalysisList,
  targetComparatorOutcomesList = targetComparatorOutcomesList,
  analysesToExclude = NULL,
  refitPsForEveryOutcome = FALSE,
  refitPsForEveryStudyPopulation = FALSE,  
  cmDiagnosticThresholds = CohortMethod::createCmDiagnosticThresholds()
)


# Create the analysis specifications ------------------------------------------
analysisSpecifications <- Strategus::createEmptyAnalysisSpecificiations() |>
  Strategus::addSharedResources(cohortDefinitionShared) |> 
  Strategus::addSharedResources(negativeControlsShared) |>
  Strategus::addModuleSpecifications(cohortGeneratorModuleSpecifications) |>
  Strategus::addModuleSpecifications(cohortDiagnosticsModuleSpecifications) |>
  Strategus::addModuleSpecifications(cohortMethodModuleSpecifications) 

ParallelLogger::saveSettingsToJson(
  analysisSpecifications, 
  file.path("inst", "FepPharmacotherapyAnalysisSpecification.json")
)
