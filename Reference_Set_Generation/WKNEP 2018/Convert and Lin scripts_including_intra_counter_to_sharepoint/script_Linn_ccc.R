##there are some sections you need to change depending upon your file names
##search for the word CHANGE


#RUN to line 135 - check outputs and then run the rest (which tests the counters against the new reference count)
##Libraries
library(lattice)
library(openxlsx)

##Set up directories
##CHANGE THE DIRECTORY
wdir<- "C:/WKNEPS18/Convert and Lin scripts_including_intra_counter/"
input.dir<- paste0(wdir,"input/")
output.dir<- paste0(wdir,"output/")

#Load functions
source(paste0(wdir,"functions/ccc.r"))
source(paste0(wdir,"functions/required.funcs.r"))
source(paste0(wdir,"functions/lin.ccc.compare.r"))
source(paste0(wdir,"functions/template.format.converter.R"))

##step through each spreadsheet
##CHANGE THE FILE NAMES
#Convert template to format used by Lin CCC function
template.name<- "ReferenceCount_Datasheet_WKNEPS_2018_KRV.xlsx"
converted.output.name<- "kv"
template.format.converter(input.path=paste0(input.dir,template.name), output.dir=output.dir, output.name=converted.output.name)
#Run Lin CCC
kv <- lin.ccc.compare(wk.dir = output.dir, counts= paste0(output.dir,converted.output.name,".csv"), FU = "6")

template.name<- "ReferenceCount_Datasheet_WKNEPS_2018_EDB.xlsx"
converted.output.name<- "eb"
template.format.converter(input.path=paste0(input.dir,template.name), output.dir=output.dir, output.name=converted.output.name)
#Run Lin CCC
eb <- lin.ccc.compare(wk.dir = output.dir, counts= paste0(output.dir,converted.output.name,".csv"), FU = "6")

template.name<- "ReferenceCount_Datasheet_WKNEPS_2018_ROC.xlsx"
converted.output.name<- "ro"
template.format.converter(input.path=paste0(input.dir,template.name), output.dir=output.dir, output.name=converted.output.name)
#Run Lin CCC
ro <- lin.ccc.compare(wk.dir = output.dir, counts= paste0(output.dir,converted.output.name,".csv"), FU = "6")

template.name<- "ReferenceCount_Datasheet_WKNEPS_2018_ARL.xlsx"
converted.output.name<- "al"
template.format.converter(input.path=paste0(input.dir,template.name), output.dir=output.dir, output.name=converted.output.name)
#Run Lin CCC
al <- lin.ccc.compare(wk.dir = output.dir, counts= paste0(output.dir,converted.output.name,".csv"), FU = "6")

template.name<- "ReferenceCount_Datasheet_WKNEPS_2018_INT.xlsx"
converted.output.name<- "int"
template.format.converter(input.path=paste0(input.dir,template.name), output.dir=output.dir, output.name=converted.output.name)
#Run Lin CCC
int <- lin.ccc.compare(wk.dir = output.dir, counts= paste0(output.dir,converted.output.name,".csv"), FU = "6")


all <- rbind(kv,eb,ro,al, int)
####################################################################

head(all)
summary(all)
all$newcounterid <- gsub("_1", "", all$Counter_ID)
all$newcounterid <- gsub("_2", "", all$newcounterid)
all$Counter_ID <- all$newcounterid
head(all)
all$Station <- all$Stations ##name change required

##now we have the linns for internal - remove those stations outside the threshold
threshold <- 0.5
all$Lin <- NA.to.0(all$Lin)
good <- all[all$Lin>threshold,]
good$st.id <- with(good, paste(Station, Counter_ID, sep=":"))



##CHANGE THE FILE NAMES
##read the raw counts back in
dat <- read.table(paste(output.dir,"kv.csv", sep="/"), sep=",", header=T)
dat <- rbind(dat, read.table(paste(output.dir,"eb.csv", sep="/"), sep=",", header=T))
dat <- rbind(dat, read.table(paste(output.dir,"ro.csv", sep="/"), sep=",", header=T))
dat <- rbind(dat, read.table(paste(output.dir,"al.csv", sep="/"), sep=",", header=T))
dat <- rbind(dat, read.table(paste(output.dir,"int.csv", sep="/"), sep=",", header=T))
summary(dat)

dat <- dat[!is.na(dat$Count),]
dat$newcounterid <- gsub("_1", "", dat$Counter_ID)
dat$newcounterid <- gsub("_2", "", dat$newcounterid)
dat$Counter_ID <- dat$newcounterid
dat$st.id <- with(dat, paste(Station, Counter_ID, sep=":"))

dat2 <- dat[dat$st.id %in% good$st.id,]
summary(dat2)

##now create the mean per st.id
dat3 <- tapply.ID(dat2, "Count", c("Station", "Counter_ID", "Functional_Unit", "Min"), "mean", "Burrows")
dat3$RunID <- with(dat3, paste(Counter_ID, Station, sep=":"))
dat3$ObsID <- dat3$Station
dat3$UserID <- dat3$Counter_ID
dat3$Block <- dat3$Min
dat3$DVDNo <- 1
dat3$TVID <- dat3$Station
summary(dat3)


t <- trellis.par.get("superpose.line")
t$lwd <- 2
t$col <- c("red", "brown", "black", "blue", "green")
t$lty <- c(1,1,2,1,1)
trellis.par.set("superpose.line",t)
with(dat3, xyplot(Burrows~Min | as.factor(Station), groups=Counter_ID, xlab="minute", type="l", auto.key=list(space="bottom", lines=T, points=F,columns=4),
                  panel=function(x,y,...)
                  {
                      panel.xyplot(x,y,...)
                   #   panel.abline(h=0.5, lty=2, col="grey")

                  }))

with(dat3, bwplot(Burrows~Counter_ID))
source(paste(wdir,"functions/f_lemon.hunter.2018.R", sep="")) ##you don't need to change anything here

summary(ccc.results)
with(ccc.results, bwplot(ccc ~ as.factor(stn)))

##get a single column with station user and ccc - stack together U1 and U2 results
t1 <- ccc.results[,c("stn", "U1", "ccc")]
t1$user <- t1$U1
t2 <- ccc.results[,c("stn", "U2", "ccc")]
t2$user <- t2$U2

stacked <- rbind(t1[,c("stn", "ccc", "user")],t2[,c("stn", "ccc", "user")])
with(stacked, bwplot(ccc ~ as.factor(user),panel=function(x,y,...){
    panel.bwplot(x,y,...)
    panel.abline(h=0.5, lty=2, col="red")
}))
summary(stacked)

with(ccc.results, tapply(ccc, list(U1, U2, stn), sum))


####################################################################################################
#####################################################################################################
##create the reference set - average the individual averages
stacked$Station <- stacked$stn
stacked$UserID <- as.factor(stacked$user)
stacked.passed <- stacked[stacked$ccc>threshold,]
stacked.passed$ttt <- with(stacked.passed, paste(stn, user))

dat3$ttt <- with(dat3, paste(Station, Counter_ID))


##now we have the passed counts in stacked.passed, put that back with the counts so that we can subset
dat4 <- dat3[dat3$ttt %in% stacked.passed$ttt,]
##dat4 <- merge(dat3, stacked.passed, all.y=T)
summary(dat4)

ref.set <- tapply.ID(dat4, "Burrows", c("Station", "Block", "DVDNo", "TVID", "ObsID"), "mean", "Burrows")
ref.set$UserID <- "reference"
ref.set$Counter_ID <- ref.set$UserID
ref.set$RunID <- with(ref.set, paste(Counter_ID, Station, sep=":"))

ref.set

dat3 <- rbind(dat4[,names(ref.set)], ref.set)

##plot up again - this time put the reference line as black dashed
t <- trellis.par.get("superpose.line")
t$lwd <- 2
t$col <- c("red", "green", "pink", "blue", "black", "orange")
t$lty <- c(1,1,1,1,1,1,2,1)
trellis.par.set("superpose.line",t)
with(dat3, xyplot(Burrows~Block | as.factor(Station), groups=Counter_ID, xlab="minute", type="l", layout=c(3,3),auto.key=list(space="bottom", lines=T, points=F,columns=4),
                  panel=function(x,y,...)
                  {
                      panel.xyplot(x,y,...)
                   #   panel.abline(h=0.5, lty=2, col="grey")

                  }))



##now put this into the lemon hunter!
source(paste(wdir,"functions/f_lemon.hunter.2018.R", sep="")) ##you don't need to change anything here
##re-work the matrix of passes
##get a single column with station user and ccc - stack together U1 and U2 results
t1 <- ccc.results[,c("stn", "U1", "ccc")]
t1$user <- t1$U1
t2 <- ccc.results[,c("stn", "U2", "ccc")]
t2$user <- t2$U2

stacked <- rbind(t1[,c("stn", "ccc", "user")],t2[,c("stn", "ccc", "user")])
with(stacked, bwplot(ccc ~ as.factor(user),panel=function(x,y,...){
    panel.bwplot(x,y,...)
    panel.abline(h=0.5, lty=2, col="red")
}))
summary(stacked)

with(ccc.results, tapply(ccc, list(U1, U2, stn), sum))
