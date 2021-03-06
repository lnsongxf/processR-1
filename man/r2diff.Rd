% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/r2diff.R
\name{r2diff}
\alias{r2diff}
\title{Calculate difference of R2 and adjusted R2}
\usage{
r2diff(fit, interaction.only = TRUE, digits = NULL)
}
\arguments{
\item{fit}{An object of class lm}

\item{interaction.only}{Logical}

\item{digits}{Integer indicating the number of decimal places}
}
\description{
Calculate difference of R2 and adjusted R2
}
\examples{
fit=lm(mpg~wt*hp,data=mtcars)
r2diff(fit)
}
