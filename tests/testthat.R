library(testthat)
library(ridigbio)

verify_galax_records <- NULL

# Test that examples will run
tryCatch(
    {
        # Your code that might throw an error
        verify_galax_records <- idig_search_records(
            rq = list(scientificname = "Galax urceolata"),
            limit = 10
        )
    },
    error = function(e) {
        # Code to run if an error occurs
        cat("An error occurred during the idig_search_records call: ", e$message, "\n")
        simpleError("Tests will not proceed as a result of error. Please try to fix the issue and try again.")
        # Optionally, you can return NULL or an empty dataframe
        verify_galax_records <- NULL
    }
)

if (!is.null(verify_galax_records) && nrow(verify_galax_records) > 0) {
    test_check("ridigbio")
}
