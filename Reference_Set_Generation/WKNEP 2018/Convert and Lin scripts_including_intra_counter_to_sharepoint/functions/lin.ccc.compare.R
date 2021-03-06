lin.ccc.compare<- function(wk.dir, counts, FU)
{
	library(lattice)

	setwd(wk.dir)
	surv <- read.csv(counts, header=T)
	surv<- subset(surv, Functional_Unit == FU)
#print(surv)
	stations<- sort(as.character(unique(surv$Station)))

	lin.table<- data.frame(Stations = stations, Lin = NA, Counter_ID=NA)

	pdf(paste(FU, ".pdf", sep=""), height=10, width=7,paper="a4")
	par(mfrow=c(5,4))


	for(s in 1:length(stations))
	{

		temp<- subset(surv, Station == stations[s])
		counter<- unique(as.character(temp$Counter_ID))[1:2]
		count1<- subset(temp, Counter_ID == counter[1])$Count
		count2<- subset(temp, Counter_ID == counter[2])$Count

		mismatch.mins<- which(is.na(count1) & !is.na(count2) | is.na(count2) & !is.na(count1))
		if(length(mismatch.mins)>0) {print(paste("Mismatch in minutes counted in Station: ", stations[s], "; ", "Minute(s): ", paste(mismatch.mins, collapse=","), "; Counters: ", paste(counter, collapse=",")))}

		if(!all(is.na(count1)) == T  & !all(is.na(count2))  == T)
		{
			lin.value<- ccc(count1, count2)$ccc


			if( is.na(lin.value) == F)
			{
                            lin.table$Lin[s]<- lin.value
                            lin.table$Counter_ID[s] <- counter[1]

				xr <- c(0, max(temp$Count, na.rm=T)*1.05)
				print(plot(xr, xr, type="l",lty=2, col="grey", xlab=paste("Counts: ", counter[1], sep=""), ylab=paste("Counts: ", counter[2], sep=""),main=stations[s]))
				print(points(count1, count2*rnorm(length(count2), 1, 0.02)))
				legend("topleft", as.character(round(lin.value, 2)), bty="n", cex=0.8)
			}

			if( is.na(lin.value) == T)
			{
				lin.table[s, "Lin"]<- lin.value
				xr <- c(0, max(temp$Count, na.rm=T)*1.05)
				print(plot(xr, xr, type="l",lty=2, col="grey", xlab=paste("Counts: ", counter[1], sep=""), ylab=paste("Counts: ", counter[2], sep=""),main=stations[s]))
				print(points(count1, count2*rnorm(length(count2), 1, 0.02)))
				legend("topleft", "NA", bty="n", cex=0.8)
			}
		}

	}

	dev.off()
lin.table
}

################################
lin.ccc.compare.between<- function(wk.dir, counts, FU)
{
	library(lattice)

	setwd(wk.dir)
	surv <- read.csv(counts, header=T)
	surv<- subset(surv, Functional_Unit == FU)
#print(surv)
	stations<- sort(as.character(unique(surv$Station)))
        counters <- sort(surv$Counter_ID)

	lin.table<- data.frame(Stations = stations, Lin = NA, Counter_ID=NA)

	pdf(paste(FU, ".pdf", sep=""), height=10, width=7,paper="a4")
	par(mfrow=c(5,4))


	for(s in 1:length(stations))
	{

            temp<- subset(surv, Station == stations[s])

            ##work out all pairwise combinations of
		counter<- unique(as.character(temp$Counter_ID))[1:2]
		count1<- subset(temp, Counter_ID == counter[1])$Count
		count2<- subset(temp, Counter_ID == counter[2])$Count

		mismatch.mins<- which(is.na(count1) & !is.na(count2) | is.na(count2) & !is.na(count1))
		if(length(mismatch.mins)>0) {print(paste("Mismatch in minutes counted in Station: ", stations[s], "; ", "Minute(s): ", paste(mismatch.mins, collapse=","), "; Counters: ", paste(counter, collapse=",")))}

		if(!all(is.na(count1)) == T  & !all(is.na(count2))  == T)
		{
			lin.value<- ccc(count1, count2)$ccc


			if( is.na(lin.value) == F)
			{
                            lin.table$Lin[s]<- lin.value
                            lin.table$Counter_ID[s] <- counter[1]
				xr <- c(0, max(temp$Count, na.rm=T)*1.05)
				print(plot(xr, xr, type="l",lty=2, col="grey", xlab=paste("Counts: ", counter[1], sep=""), ylab=paste("Counts: ", counter[2], sep=""),main=stations[s]))
				print(points(count1, count2*rnorm(length(count2), 1, 0.02)))
				legend("topleft", as.character(round(lin.value, 2)), bty="n", cex=0.8)
			}

			if( is.na(lin.value) == T)
			{
				lin.table[s, "Lin"]<- lin.value
				xr <- c(0, max(temp$Count, na.rm=T)*1.05)
				print(plot(xr, xr, type="l",lty=2, col="grey", xlab=paste("Counts: ", counter[1], sep=""), ylab=paste("Counts: ", counter[2], sep=""),main=stations[s]))
				print(points(count1, count2*rnorm(length(count2), 1, 0.02)))
				legend("topleft", "NA", bty="n", cex=0.8)
			}
		}

	}

	dev.off()
lin.table
}

