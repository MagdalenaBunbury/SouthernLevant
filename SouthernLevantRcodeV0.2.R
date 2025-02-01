---
  title: "Southern Levant R-code to reproduce SPD plots"
output: html_notebook
---

#install.packages("rcarbon")
#install.packages("tidyverse")

library(rcarbon)
library(tidyverse)

### Upload the 14C dataset ##

setwd("~/Desktop/Rcarbon") # Set working directory
dataSL <- read.csv("SouthernLevant14C V0.2.csv") # Load dataset: Southern Levant radiocarbon data
# Convert selected columns to numeric data type
dataSL [4:5] <- lapply(dataSL[4:5], as.numeric)  # Latitude/Longitude
dataSL [11:12] <- lapply(dataSL[11:12], as.numeric)  # radiocarbon age and error values

### Filter for Reliable 14C Dates ###
dataSLR=subset(dataSL,Reliability_SPD == "Yes") # Extract only radiocarbon dates marked as "Reliable" for SPD analysis
View(dataSLR)

### General SPD parameters ###
nsim = 1000 # Define the number of Monte Carlo simulations for null model testing
DatesSLR=calibrate(x=dataSLR$CRA,errors=dataSLR$Error,calCurves='intcal20',normalised=FALSE) # Calibrate radiocarbon dates using the IntCal20 calibration curve
SLR.bins = binPrep(sites=dataSLR$Site_ID,ages=DatesSLR,h=100) # Apply binning to reduce overrepresentation of 14C dates, h = 100 ensures that dates within a 100-year span at the same site are not overrepresented

# Define the chronological working range (Start and End Dates)
timeRange <- c(11750, 3100) # From 11,750 cal BP (9800 BCE) to 3,100 cal BP (1150 BCE)

### Population growth, exponential fit 9800-1150 BCE ###
expnullSLR <- modelTest(DatesSLR, errors=dataSLR$Error, bins=SLR.bins, nsim=nsim, timeRange=c(11750,3100), model="exponential",runm=100) # Perform SPD for the Southern Levant dataset for the given timerange
plot(expnullSLR,calendar = "BCAD") # Plot the SPD results with BC/AD calendar conversion
# Add a legend in the top-left corner explaining SPD components
legend("topleft", title="A. Southern Levant", legend=c("Unnormalised SPD","Positive dev", "Negative dev", NA), col=c("black", "pink", "purple", NA), lty=c(7,7,7,NA), lwd=3, cex = 0.80)
legend("topleft",inset=c(0,0.27), legend="Exponential growth", col="grey", bty="n", cex = 0.80, fill="grey")
summary(expnullSLR) # Display summary statistics of the SPD model


### Case study 1: Population distribution across three phytogeographic zones ###

dataSLR <- dataSLR[!is.na(dataSLR$Phytogeographic_Zone1) & dataSLR$Phytogeographic_Zone1 != "", ] # Remove Blank Entries and Ensure Only Relevant Categories
dataSLR$Phytogeographic_Zone1 <- as.character(dataSLR$Phytogeographic_Zone1) # Convert to character
dataSLR <- dataSLR[dataSLR$Phytogeographic_Zone1 != "Unknown", ] # Ensure No "Unknown" in the Dataset
dataSLR$Phytogeographic_Zone1 <- factor(dataSLR$Phytogeographic_Zone1) # Convert back to factor for plotting (if necessary)
SLR.spd.smoothed = stackspd(x=DatesSLR, group=dataSLR$Phytogeographic_Zone1, timeRange=c(11750,3100), bins=SLR.bins, runm=100) # Run stackspd() WITHOUT "Unknown"
# Ensure Color Mapping Matches Number of Categories (3 Colors for 3 Categories)
plot(SLR.spd.smoothed, type='lines', lwd=3, lty=7, calendar = "BCAD", 
     col.line = c("green", "dark green", "orange")) # Adjust if necessary


### Case study 2: Exponential population growth scenario in the Negev desert ###

dataN=subset(dataSLR,Subregion == "Negev") # Subset the data for the Negev region
DatesN=calibrate(x=dataN$CRA,errors=dataN$Error,calCurves='intcal20',normalised=FALSE) # Calibrate radiocarbon dates using IntCal20 calibration curve
N.bins = binPrep(sites=dataN$Site_ID,ages=DatesN,h=100) # Prepare binning to account for site-level aggregation (bin width = 100 years)
expnullN <- modelTest(DatesN, errors=dataN$Error, bins=N.bins, nsim=nsim, timeRange=c(11750,3100), model="exponential",runm=100) # Perform model-based SPD test for exponential growth
plot(expnullN,calendar = "BCAD") # Plot the SPD results with BC/AD calendar conversion
# Add a legend in the top-left corner explaining SPD components
legend("topleft", title="C. Negev", legend=c("Unnormalised SPD","Positive dev", "Negative dev", NA), col=c("black", "pink", "purple", NA), lty=c(7,7,7,NA), lwd=3, cex = 0.80)
legend("topleft",inset=c(0,0.27), legend="Exponential growth", col="grey", bty="n", cex = 0.80, fill="grey")
summary(expnullN)





