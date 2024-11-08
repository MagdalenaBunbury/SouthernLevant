---
  title: "Southern Levant R-code to reproduce SPD plots"
output: html_notebook
---

#install.packages("rcarbon")
#install.packages("tidyverse")

library(rcarbon)
library(tidyverse)

### Upload the 14C dataset ##

setwd("~/Desktop/Rcarbon")
dataSL <- read.csv("SouthernLevant14C.csv")
dataSL [4:5] <- lapply(dataSL[4:5], as.numeric)
dataSL [10:11] <- lapply(dataSL[10:11], as.numeric)

### Reliable 14C dates from the Southern Levant ###
dataSLR=subset(dataSL,Reliability == "Included") 
View(dataSLR)

### General SPD parameters ###
nsim = 1000
DatesSLR=calibrate(x=dataSLR$CRA,errors=dataSLR$Error,calCurves='intcal20',normalised=FALSE)
SLR.bins = binPrep(sites=dataSLR$Site_ID,ages=DatesSLR,h=100) 

# Start and end of chronological working range
timerange <- 11750 #9800 BCE
timerange <- 3100 #1150 BCE

### Population growth, exponential fit 9800-1150 BCE ###
expnullSLR <- modelTest(DatesSLR, errors=dataSLR$Error, bins=SLR.bins, nsim=nsim, timeRange=c(11750,3100), model="exponential",runm=100)
plot(expnullSLR,calendar = "BCAD")
legend("topleft", title="A. Southern Levant", legend=c("Unnormalised SPD","Positive dev", "Negative dev", NA), col=c("black", "pink", "purple", NA), lty=c(7,7,7,NA), lwd=3, cex = 0.80)
legend("topleft",inset=c(0,0.27), legend="Exponential growth", col="grey", bty="n", cex = 0.80, fill="grey")
summary(expnullSLR)

### Case study 1: Population distribution across three phytogeographic zones ###
SLR.spd.smoothed = stackspd(x=DatesSLR, group=dataSLR$Phytogeographic_Zone1,timeRange=c(11750,3100),bins=SLR.bins, runm=100)
plot(SLR.spd.smoothed,type='lines',lwd=3, lty=7, calendar = "BCAD", col.line = c("green", "dark green", "orange"))

## Case study 2: Exponential population growth scenario in the Negev desert ###
dataN=subset(dataSLR,Subregion == "Negev") 
DatesN=calibrate(x=dataN$CRA,errors=dataN$Error,calCurves='intcal20',normalised=FALSE)
N.bins = binPrep(sites=dataN$Site_ID,ages=DatesN,h=100) 
expnullN <- modelTest(DatesN, errors=dataN$Error, bins=N.bins, nsim=nsim, timeRange=c(11750,3100), model="exponential",runm=100)
plot(expnullN,calendar = "BCAD")
legend("topleft", title="C. Negev", legend=c("Unnormalised SPD","Positive dev", "Negative dev", NA), col=c("black", "pink", "purple", NA), lty=c(7,7,7,NA), lwd=3, cex = 0.80)
legend("topleft",inset=c(0,0.27), legend="Exponential growth", col="grey", bty="n", cex = 0.80, fill="grey")
summary(expnullN)





