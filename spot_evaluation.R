ptm <- proc.time()
load("C:/Users/tantonakis/Google Drive/Scripts/AnalyticsProj/cdgr_traffic/tvspots.RData")
setwd("C:/Users/tantonakis/Google Drive/Scripts/AnalyticsProj/cdgr_traffic/TV Spots")
library(RGA)
library(lubridate)
library(dplyr)

client.id = '543269518849-dcdk7eio32jm2i4hf241mpbdepmifj00.apps.googleusercontent.com'
client.secret = '9wSw6gyDVXtcgqEe0XazoBWG'

ga_token<-authorize(client.id, client.secret, cache = getOption("rga.cache"))

############################################
startdate='2015-03-09' ##Start Date#########
enddate='2015-03-09' ####End Date###########
############################################

web<-get_ga(25764841, start.date = startdate, end.date = enddate,
             
               metrics = "
                        ga:sessions,
                        ga:goal1Completions,
                        ga:goal6Completions,
                        ga:newusers
                ",
             
             dimensions = "
                        ga:date,
                        ga:hour,
                        ga:minute
                ",
             sort = NULL, 
             filters = NULL,
             segment = NULL, 
             sampling.level = NULL,
             start.index = NULL, 
             max.results = NULL, 
             ga_token
)

android<-get_ga(81060646, start.date = startdate, end.date = enddate,
               
                metrics = "
                        ga:sessions,
                        ga:goal1Completions,
                        ga:goal2Completions,
                        ga:newusers
                ",
               
                dimensions = "
                        ga:date,
                        ga:hour,
                        ga:minute
                ",
               sort = NULL, 
               filters = NULL,
               segment = NULL, 
               sampling.level = NULL,
               start.index = NULL, 
               max.results = NULL, 
               ga_token
)

ios<-get_ga(81074931, start.date = startdate, end.date = enddate,
                
                metrics = "
                        ga:sessions,
                        ga:goal1Completions,
                        ga:goal2Completions,
                        ga:newusers
                ",
                
                dimensions = "
                        ga:date,
                        ga:hour,
                        ga:minute
                ",
                sort = NULL, 
                filters = NULL,
                segment = NULL, 
                sampling.level = NULL,
                start.index = NULL, 
                max.results = NULL, 
                ga_token
)

library(xlsx)
# Duplicate sheet
# fileter Delete sums per day   
# Column L timestamp
# Column M ID
# 5 last columns --> c("dur", "cost", "GRP", "CPR", "Timestamp", "ID")
actspots<-read.xlsx("Spot_Database.xlsx", sheetIndex=2,
                    startRow = 6, header=TRUE,stringsAsFactors=FALSE)
actspots<-actspots[,(ncol(actspots)-5):ncol(actspots)]
names(actspots) <- c("dur", "Cost", "GRP", "CPR", "Time", "ID")
actspots<-actspots[!is.na(actspots$Time),]


web$timestamp<-ymd(web$date, tz="GMT")
hour(web$timestamp)=web$hour
minute(web$timestamp)=web$minute

android$timestamp<-ymd(android$date, tz="GMT")
hour(android$timestamp)=android$hour
minute(android$timestamp)=android$minute

ios$timestamp<-ymd(ios$date, tz="GMT")
hour(ios$timestamp)=ios$hour
minute(ios$timestamp)=ios$minute

names(web)<-c("date","hour","minute","sessions","orders","registrations","newusers","timestamp")
names(ios)<-names(web)
names(android)<-names(web)
web$source <- "web"
android$source <- "android"
ios$source <- "ios"
permin<-rbind(web, android, ios)


# Minutes approach sessions
permin$incr_ses<- 0
permin$affected_ses<-0
proc.time() - ptm
for (i in 1:nrow(permin)){
        for (j in 1:nrow(actspots)){
                dif<- difftime(permin$timestamp[i], actspots$Time[j], units="mins")
                if ( (dif>=-0.1) & (dif<=3.1)) {
                        permin$affected_ses[i]<- permin$affected_ses[i]+1
                        temp<-head(permin,i-1)
                        temp<- tail(temp[temp$affected_ses == 0 & temp$source == permin$source[i-1],],5)
                        permin$incr_ses[i] <-  max(0,permin$sessions[i] - mean(temp$sessions))
                } 
        }
}
#permin_ses<-permin
# affected_ses<-permin[permin$affected!=0,]
proc.time() - ptm


##### FINDING INDEX ########
# which( permin$affected %in% 1) multiple encounters INDECES
# match(1, permin$affected)[1:10] first encounter INDEX

# Minutes approach registrations
permin$incr_reg<- 0
permin$affected_reg<-0
proc.time() - ptm
for (i in 1:nrow(permin)){
        for (j in 1:nrow(actspots)){
                dif<- difftime(permin$timestamp[i], actspots$Time[j], units="mins")
                if ( (dif>=1.9) & (dif<=10.1)) {
                        permin$affected_reg[i]<- permin$affected_reg[i]+1
                        temp<-head(permin,i-1)
                        temp<- tail(temp[temp$affected_reg == 0 & temp$source == permin$source[i-1],],5)
                        permin$incr_reg[i] <-  max(0,permin$registrations[i] - mean(temp$registrations))
                } 
        }
}
proc.time() - ptm

permin$'NA'<-NULL
minute_archive<-rbind(minute_archive,permin)
# affected_reg<-permin[permin$affected!=0,]

#sessions per 0-3 minutes
#registrations per 2-10 minutes


# Spot approach but over estimating (doublecounting overlapped minutes)
# actspots$sessions<-0
# actspots$registrations<-0
# for (i in 1:nrow(actspots)){
#         permin$dif<- difftime(permin$timestamp, actspots$Time[i], units="mins")
#         actspots$sessions[i]<-sum(permin$sessions[permin$dif>=-0.5 & permin$dif<=3])
#         actspots$registrations[i]<-sum(permin$registrations[permin$dif>=-0.5 & permin$dif<=10])  
#         permin$dif<-NULL
# }

###############################
# Way of thinking
###############################

# actcosts 
actspots$sessions<-0
actspots$registrations<-0
# gia kathe spot
for (i in 1:nrow(actspots)){
        # gia kathe lepto
        for (j in 0:10) { 
                # dhmioyrgise wra anaforas
                now<- actspots$Time[i] +minutes(j)
                # check poia spot einai energa
                # energo einai ena spot pou to dif time time stamp tou me wra anaforas einai mikrotero tou 0-10
                # o eaftos mou prepei na einai TRUE
                # athtoise ta GRPs tous (krata denominator)
                if (j>1){
                        denomreg<- sum(actspots$GRP[(difftime(now, actspots$Time, units="mins")>=1.9 & difftime(now, actspots$Time, units="mins")<=10.1)])
                wreg<- actspots$GRP[i] / denomreg
                meritreg<- wreg * sum(permin$incr_reg[abs(difftime(now, permin$timestamp, units="mins"))<=0.5])
                # meritreg<- wreg * sum(permin$registrations[abs(difftime(now, permin$timestamp, units="mins"))<=0.5])
                actspots$registrations[i] <- actspots$registrations[i] + meritreg
                }
                # athroise sessions kai ta registrations twn energwn
                if (j<=3){
                        denomses<- sum(actspots$GRP[(difftime(now, actspots$Time, units="mins")>=-0.1 & difftime(now, actspots$Time, units="mins")<=3.1)])
                wses<- actspots$GRP[i] / denomses
                # meritses<- wses * sum(permin$sessions[abs(difftime(now, permin$timestamp, units="mins"))<=0.5])
                meritses<- wses * sum(permin$incr_ses[abs(difftime(now, permin$timestamp, units="mins"))<=0.5])
                actspots$sessions[i] <- actspots$sessions[i] + meritses
                }
                # grapse sth sthli sessions kai registrations apo panw
                # pollaplasiase ta sessions * GRPs spot / denominator
                # an einai ena mono energo grps/ denominator =1 ara olo to lepto
       }
}
proc.time() - ptm
# Computations on actspots data-frame
actspots$cost_per_reg <- actspots$Cost / actspots$registrations
actspots$cost_per_ses <- actspots$Cost / actspots$sessions
actspots$reg_per_GRP <- actspots$registrations / actspots$GRP
actspots$ses_per_GRP <- actspots$sessions / actspots$GRP
# columns in correct order
actspots<-actspots[,c(5,6,2,3,4,1,8,7,9,10,11,12)]
# Save spots archive
spot_archive<-rbind(spot_archive,actspots)
# Export the dataframe
write.xlsx(x = actspots, file = "Spot_Evaluation_0903.xlsx", row.names = FALSE, )

save.image("C:/Users/tantonakis/Google Drive/Scripts/AnalyticsProj/cdgr_traffic/tvspots.RData")

# open and insert two 
# ga:channelGrouping



# write.xlsx(x = spot_archive, file = "Spot_Evaluation_Archive.xlsx", row.names = FALSE, )
# write.xlsx(x = affected, file = "affected.xlsx", row.names = FALSE)
# write.xlsx(x = permin, file = "permin.xlsx", row.names = FALSE)

gc()

