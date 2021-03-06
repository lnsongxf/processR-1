% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/condPlotCat.R
\name{makeCatModel}
\alias{makeCatModel}
\title{Make simple regression model with one categorical variable}
\usage{
makeCatModel(labels = labels, data, yvar = "Y", total = FALSE,
  addvars = TRUE, maxylev = 6, mode = 1)
}
\arguments{
\item{labels}{Named list of variables}

\item{data}{A data.frame}

\item{yvar}{Label of the dependent variable. Either "Y"(default) or "M".}

\item{total}{logical. If true, model include mediator variable.}

\item{addvars}{logical. Whether or not add categorical variables to the data}

\item{maxylev}{maximal unique length of categorical variable}

\item{mode}{Numeric. One of 1:4. 1= simple indicator coding, 2= sequential coding, 3= Helmert coding, 4= effect coding}
}
\value{
An object of class lm
}
\description{
Make simple regression model with one categorical variable
}
\examples{
labels=list(X="protest",W="sexism",M="respappr",Y="liking")
data1=addCatVars(protest,"protest")
makeCatModel(labels=labels,data=data1)
}
