[![Build Status](https://api.travis-ci.com/iDigBio/ridigbio.svg?branch=master)](https://app.travis-ci.com/github/iDigBio/ridigbio)

# Installation

This should automatically install the package from a CRAN mirror if you have one configured:

    install.packages("ridigbio")
	
If R says the package is unavailable, you may not have set a CRAN mirror. You can do so with:

    chooseCRANmirror()

If R says that a binary package is not available, your version of R may be too old. Please 
review the versions of R that CRAN has built packages for on the [CRAN ridigbio package page.]( https://cran.r-project.org/package=ridigbio)
You can download the source package and install manually if there is no package built for 
your version of R. You may also need to install any dependencies.

    install.packages("ridigbio", type="source")

On Linux, you may encounter an error during the installation process if you do not have `libcurl` installed. The method for installing libcurl will vary between distributions, but on Ubuntu you can install the latest version via:

    sudo apt install libcurl4
# Basic usage

    library("ridigbio")
    idig_search_records(rq=list(genus="galax"))
    idig_search_records(rq=list(family="holothuriidae"), limit=1000)

Complete list of terms that can be used is available [here](https://github.com/iDigBio/idigbio-search-api/wiki/Index-Fields#record-query-fields)

# License

MIT
