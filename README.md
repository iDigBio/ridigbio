[![Build Status](https://travis-ci.org/fmichonneau/ridigbio.png?branch=master)](https://travis-ci.org/fmichonneau/ridigbio)

# Installation

    install.packages("devtools")
    library(devtools)
	install_github("fmichonneau/ridigbio")

# Basic usage

    idig_search(query=list(genus="acer"))
	idig_search(query=list(family="holothuriidae"))

Complete list of terms that can be used is available [here](https://github.com/iDigBio/idigbio-search-api/wiki/Index-Fields#record-query-fields)

# License

MIT
