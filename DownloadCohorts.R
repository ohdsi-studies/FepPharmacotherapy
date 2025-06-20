################################################################################
# INSTRUCTIONS: This script assumes you have cohorts you would like to use in an
# ATLAS instance. Please note you will need to update the baseUrl to match
# the settings for your enviroment. You will also want to change the 
# CohortGenerator::saveCohortDefinitionSet() function call arguments to identify
# a folder to store your cohorts. This code will store the cohorts in 
# "inst/sampleStudy" as part of the template for reference. You should store
# your settings in the root of the "inst" folder and consider removing the 
# "inst/sampleStudy" resources when you are ready to release your study.
# 
# See the Download cohorts section
# of the UsingThisTemplate.md for more details.
# ##############################################################################

library(dplyr)
baseUrl <- "https://atlas-demo.ohdsi.org/WebAPI"
# Use this if your WebAPI instance has security enables
# ROhdsiWebApi::authorizeWebApi(
#   baseUrl = baseUrl,
#   authMethod = "windows"
# )
cohortDefinitionSet <- ROhdsiWebApi::exportCohortDefinitionSet(
  baseUrl = baseUrl,
  cohortIds = c(
    1792011, # [PP25 FEP2] FEPwRisperidone
    1792119, # [PP25 FEP2] FEPwHaloperidol
    1792125, # [PP25 FEP2] FEPwAripiprazole
    1792127, # [PP25 FEP2] FEPwBrexpiprazole
    1792129, # [PP25 FEP2] FEPwOlanzapine
    1792130, # [PP25 FEP2] FEPwQuetiapine
    1792131, # [PP25 FEP2] FEPwZiprazidone
    1792141, # [PP25 FEP2] FEPwLurasidone
    1792143, # [PP25 FEP2] FEPwPaliperidone
    1792012  # [PP25 FEP2] Rehospitalization
  ),
  generateStats = TRUE
)

# Rename cohorts
cohortDefinitionSet[cohortDefinitionSet$cohortId == 1792011,]$cohortName <- "risperidone"
cohortDefinitionSet[cohortDefinitionSet$cohortId == 1792119,]$cohortName <- "haloperidol"
cohortDefinitionSet[cohortDefinitionSet$cohortId == 1792125,]$cohortName <- "aripiprazole"
cohortDefinitionSet[cohortDefinitionSet$cohortId == 1792127,]$cohortName <- "brexpiprazole"
cohortDefinitionSet[cohortDefinitionSet$cohortId == 1792129,]$cohortName <- "olanzapine"
cohortDefinitionSet[cohortDefinitionSet$cohortId == 1792130,]$cohortName <- "quetiapine"
cohortDefinitionSet[cohortDefinitionSet$cohortId == 1792131,]$cohortName <- "ziprazidone"
cohortDefinitionSet[cohortDefinitionSet$cohortId == 1792141,]$cohortName <- "lurazidone"
cohortDefinitionSet[cohortDefinitionSet$cohortId == 1792143,]$cohortName <- "paliperidone"
cohortDefinitionSet[cohortDefinitionSet$cohortId == 1792012,]$cohortName <- "rehospitalization"

# Re-number cohorts
cohortDefinitionSet[cohortDefinitionSet$cohortId == 1792011,]$cohortId <- 1
cohortDefinitionSet[cohortDefinitionSet$cohortId == 1792119,]$cohortId <- 2
cohortDefinitionSet[cohortDefinitionSet$cohortId == 1792125,]$cohortId <- 3
cohortDefinitionSet[cohortDefinitionSet$cohortId == 1792127,]$cohortId <- 4
cohortDefinitionSet[cohortDefinitionSet$cohortId == 1792129,]$cohortId <- 5
cohortDefinitionSet[cohortDefinitionSet$cohortId == 1792130,]$cohortId <- 6
cohortDefinitionSet[cohortDefinitionSet$cohortId == 1792131,]$cohortId <- 7
cohortDefinitionSet[cohortDefinitionSet$cohortId == 1792141,]$cohortId <- 8
cohortDefinitionSet[cohortDefinitionSet$cohortId == 1792143,]$cohortId <- 9
cohortDefinitionSet[cohortDefinitionSet$cohortId == 1792012,]$cohortId <- 10

# Save the cohort definition set
# NOTE: Update settingsFileName, jsonFolder and sqlFolder
# for your study.
CohortGenerator::saveCohortDefinitionSet(
  cohortDefinitionSet = cohortDefinitionSet,
  settingsFileName = "inst/Cohorts.csv",
  jsonFolder = "inst/cohorts",
  sqlFolder = "inst/sql/sql_server",
)

no_df <- data.frame( origin = c("cem", "cem", "cem", "cem", "cem", "cem", "cem", "cem", "cem", "cem", "cem", "cem/htn", "cem", "cem", "cem", "cem", "cem", "cem", "cem", "cem", "cem", "cem", "cem", "cem", "cem", "cem", "cem", "cem", "cem", "cem", "cem", "cem", "cem", "cem", "cem", "cem", "cem", "cem", "cem", "cem", "cem", "cem", "htn", "htn", "htn", "htn", "htn", "htn", "htn", "htn", "htn", "htn", "htn", "htn", "htn", "htn", "htn", "htn", "htn", "htn", "htn", "htn", "htn", "htn", "htn", "htn", "htn", "htn", "htn", "htn", "htn", "htn", "htn", "htn", "htn", "htn", "htn", "htn", "htn", "htn", "htn", "htn", "htn", "htn", "htn", "htn", "htn", "htn", "htn", "htn", "htn", "htn", "htn", "htn", "htn", "htn", "htn", "htn", "htn", "htn"),
                     conceptId = c(439935, 443585, 4092879, 45757682, 81878, 4216219, 134765, 4201390, 434675, 436077, 377910, 4170770, 437448, 4092896, 374801, 4096540, 439788, 40481632, 4168318, 374375, 40481897, 4265896, 381021, 4027782, 433997, 4051630, 258540, 432798, 439795, 4209423, 40480893, 438130, 4299094, 437092, 433951, 4019836, 432436, 433244, 436876, 440612, 4201387, 45757285, 436409, 199192, 4088290, 75911, 137951, 73241, 133655, 73560, 434327, 140842, 81378, 432303, 46269889, 134438, 78619, 201606, 76786, 4115402, 45757370, 433111, 433527, 4092896, 259995, 40481632, 433577, 4231770, 4012570, 4012934, 374375, 4344500, 139099, 444132, 432593, 434203, 438329, 4083487, 4103703, 4209423, 377572, 136368, 40480893, 438130, 4091513, 4202045, 373478, 439790, 81634, 380706, 141932, 36713918, 443172, 81151, 72748, 378427, 437264, 140641, 4115367, 440193),
                     cohortId = c(1001, 1002, 1003, 1004, 1005, 1006, 1007, 1008, 1009, 1010, 1011, 1012, 1013, 1014, 1015, 1016, 1017, 1018, 1019, 1020, 1021, 1022, 1023, 1024, 1025, 1026, 1027, 1028, 1029, 1030, 1031, 1032, 1033, 1034, 1035, 1036, 1037, 1038, 1039, 1040, 1041, 1042, 1043, 1044, 1045, 1046, 1047, 1048, 1049, 1050, 1051, 1052, 1053, 1054, 1055, 1056, 1057, 1058, 1059, 1060, 1061, 1062, 1063, 1064, 1065, 1066, 1067, 1068, 1069, 1070, 1071, 1072, 1073, 1074, 1075, 1076, 1077, 1078, 1079, 1080, 1081, 1082, 1083, 1084, 1085, 1086, 1087, 1088, 1089, 1090, 1091, 1092, 1093, 1094, 1095, 1096, 1097, 1098, 1099, 1100),
                     name = c("Abnormal posture", "Abrasion and/or friction burn of multiple sites", "Absent kidney", "Anomaly of jaw size", "Benign paroxysmal positional vertigo", "Bizarre personal appearance", "Cachexia", "Colostomy present", "Complication of gastrostomy", "Developmental delay", "Deviated nasal septum", "Epidermoid cyst", "Exhaustion due to excessive exertion", "Feces contents abnormal", "Foreign body in ear", "Foreskin deficient", "Galactosemia", "Ganglion cyst", "Genetic disorder carrier", "Impacted cerumen", "Inadequate sleep hygiene", "Jellyfish poisoning", "Lagophthalmos", "Lipid storage disease", "Lymphangioma", "Malingering", "Marfan's syndrome", "Mechanical complication of internal orthopedic device, implant AND/OR graft", "Minimal cognitive impairment", "Nicotine dependence", "Nonspecific tuberculin test reaction", "Opioid abuse", "Opioid intoxication", "Physiological development failure", "Poisoning by tranquilizer", "Social exclusion", "Symbolic dysfunction", "Tooth loss", "Toxic effect of lead compound", "Toxic effect of tobacco and nicotine", "Tracheostomy present", "Unsatisfactory tooth restoration", "Abnormal pupil", "Abrasion and/or friction burn of trunk without infection", "Absence of breast", "Acquired hallux valgus", "Acquired keratoderma", "Anal and rectal polyp", "Burn of forearm", "Calcaneal spur", "Cannabis abuse", "Changes in skin texture", "Chondromalacia of patella", "Cocaine abuse", "Complication due to Crohn's disease", "Contact dermatitis", "Contusion of knee", "Crohn's disease", "Derangement of knee", "Difficulty sleeping", "Disproportion of reconstructed breast", "Effects of hunger", "Endometriosis", "Feces contents abnormal", "Foreign body in orifice", "Ganglion cyst", "Hammer toe", "Hereditary thrombophilia", "High risk sexual behavior", "Homocystinuria", "Impacted cerumen", "Impingement syndrome of shoulder region", "Ingrowing nail", "Injury of knee", "Kwashiorkor", "Late effect of contusion", "Late effect of motor vehicle accident", "Macular drusen", "Melena", "Nicotine dependence", "Noise effects on inner ear", "Non-toxic multinodular goiter", "Nonspecific tuberculin test reaction", "Opioid abuse", "Passing flatus", "Postviral fatigue syndrome", "Presbyopia", "Psychalgia", "Ptotic breast", "Regular astigmatism", "Senile hyperkeratosis", "Somatic dysfunction of lumbar region", "Splinter of face without major open wound", "Sprain of ankle", "Strain of rotator cuff capsule", "Tear film insufficiency", "Tobacco dependence syndrome", "Verruca vulgaris", "Wrist joint pain", "Wristdrop")
) |> filter(
  ! conceptId %in% c(
    4216219, 134765, 40481897, 4209423, 438130, 4299094, 433951, 4019836, 440612, 434327, 432303, 4115402, 4012570, 439790, 437264, 439795, 4051630, 432436, 373478
  ))
no_df_filtered <- no_df %>% filter(
  ! cohortId %in% c(
      1064, 1071, 1018, 1083
    )
)

CohortGenerator::writeCsv(
 x = no_df_filtered |> 
   select(
     cohortId, cohortName = name, outcomeConceptId = conceptId
   ),
 file = "inst/negativeControlOutcomes.csv",
 warnOnFileNameCaseMismatch = F
)


