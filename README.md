[![Build Status](https://travis-ci.org/iDigBio/ridigbio.png?branch=master)](https://travis-ci.org/iDigBio/ridigbio)

# Installation

This should automatically install the package from a CRAN mirror if you have one configured:

    install.packages("ridigbio")
	
If R says the package is unavailable, you may not have set a CRAN mirror. You can do so with:

    chooseCRANmirror()
	
If R says that a binary package is not available, your version of R may be too old. Please 
review the versions of R that CRAN has built packages for on the [CRAN ridigbio package page.](http://cran.r-project.org/web/packages/ridigbio/index.html)
You can download the source package and install manually if there is no package built for 
your version of R. You may also need to install any dependencies.

    install.packages("ridigbio", type="source")

# Basic usage

    library("ridigbio")
    idig_search_records(rq=list(genus="acer"))
    idig_search_records(rq=list(family="holothuriidae"), limit=1000)

Complete list of terms that can be used is available [here](https://github.com/iDigBio/idigbio-search-api/wiki/Index-Fields#record-query-fields)

# License

MIT
