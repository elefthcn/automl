##' Α class responsible for transforming the features by means of feature engineering.
##'
##' FeatureEngineer's functionality consists in the following: first, the dataset should be analyzed in order
##' to determine which heuristic suits it. This can be done either through classification or through measuring
##' some heuristically determined qualities of it. Then a query to the "Heuristics DB" is performed in order to
##' fetch the right transformation function, which is then applied to the original dataset.
##' @import  middleman 
##' @importClassesFrom middleman FileManipulator
##' @import methods
##' @exportClass FeatureEngineer
##' @export FeatureEngineer
FeatureEngineer <- setRefClass(Class = "FeatureEngineer",
                           fields = list(
                             file_manipulator_ = "FileManipulator",
                             info_ = "list"
                           ),
                           methods = list(
                             findOptimalBoxCoxTransform = function(train_dataset, ...) {
                               'Returns optimal parameter lambda of boxcox transformation for a given formula'
                               bc           <- boxcox(Class ~ ., data = train_dataset, plotit = FALSE)
                               lambda       <- bc$x[which.max(bc$y)]
                               boxcox_info  <- list(lambda = lambda)
                               info_$BoxCox <<- boxcox_info
                               return(lambda)
                             },
                             applyLogTransform = function(dataset, indexes, ...) {
                               'Applies log-transformation to features with special treatment for negative values and values between 0 and 1'
                               transformed_dataset      <- (ifelse(abs(dataset) <= 1, 0, sign(dataset)*log10(abs(dataset))))
                               log_info                 <- list(attributes = names(dataset[,indexes])) 
                               info_$Log_transformation <<- log_info
                               return(transformed_dataset)
                             },
                             findCountFeatures = function(dataset, ...) {
                               'Finds features that represent counts(non-negative integers)'
                               # find numeric attributes
                               integer_attributes   <- names(dataset[sapply(dataset,class) == "integer"])
                               dataset_temp         <- as.data.frame(dataset[, (names(dataset) %in% integer_attributes)])
                               names(dataset_temp)  <- integer_attributes
                               is_attribute_count   <- apply(dataset_temp, 2,function(x) (x >=0) && is.integer(x))
                               count_dataset <- as.data.frame(dataset[, names(is_attribute_count[is_attribute_count==TRUE])]) 
                               names(count_dataset) <- names(is_attribute_count[is_attribute_count==TRUE])
                               return(count_dataset)
                             },
                             getInfo = function(...) {
                               'Return information about feature engineering'
                               return(info_)
                             },
                             initialize = function(...) {
                               info_ <<- list() 
                               callSuper(...)
                               .self
                             }
                           )
)
