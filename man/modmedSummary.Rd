% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/modmedSummary.R
\name{modmedSummary}
\alias{modmedSummary}
\title{Summarize the moderated mediation}
\usage{
modmedSummary(fit, mod = NULL, values = NULL,
  boot.ci.type = "bca.simple", add.range = TRUE)
}
\arguments{
\item{fit}{An object of class lavaan}

\item{mod}{name of moderator}

\item{values}{Optional. Numeric vector}

\item{boot.ci.type}{Type of bootstrapping interval. Choices are c("norm","basic","perc",bca.simple")}

\item{add.range}{logical Wheter or not add range}
}
\value{
A data.frame and an object of class modmedSummary
}
\description{
Summarize the moderated mediation
}
