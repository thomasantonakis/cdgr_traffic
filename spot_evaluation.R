ptm <- proc.time()
library(RGA)
library(lubridate)

client.id = '543269518849-dcdk7eio32jm2i4hf241mpbdepmifj00.apps.googleusercontent.com'
client.secret = '9wSw6gyDVXtcgqEe0XazoBWG'

ga_token<-authorize(client.id, client.secret, cache = getOption("rga.cache"),
                    verbose = getOption("rga.verbose"))

startdate='2015-01-24'
enddate='2015-01-27'

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
             ga_token,
             verbose = getOption("rga.verbose")
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
               ga_token,
               verbose = getOption("rga.verbose")
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
                ga_token,
                verbose = getOption("rga.verbose")
)

library(xlsx)
actspots<-read.xlsx("SpotAct.xlsx", sheetIndex=3,
                    startRow = 1, header=TRUE,stringsAsFactors=FALSE)

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


# Minutes approach
permin$affected<-0
proc.time() - ptm
for (i in 1:nrow(permin)){
        for (j in 1:nrow(actspots)){
                dif<- difftime(permin$timestamp[i], actspots$Time[j], units="mins")
                if ( (dif>=-1) & (dif<=10)) {
                        permin$affected[i]<- permin$affected[i]+1
                        #permin$cost[i]<-permin$cost[i] + actspots$Cost[j]
                } 
        }
}
proc.time() - ptm

#sessions per 3 minutes
#registrations per 3 minutes


# Spot approach
actspots$sessions<-NULL
actspots$registrations<-0
for (i in 1:nrow(actspots)){
#         for (j in 1:nrow(actspots)) {
#                 actspots$dif <- difftime(actspots$Time[i], actspots$Time[j], units="mins")
#                 actspots$w <- actspots$GRP / sum(actspots$GRP[])
#                if (i!=j) {
                        permin$dif<- difftime(permin$timestamp, actspots$Time[i], units="mins")
                        actspots$sessions[i]<-sum(permin$sessions[permin$dif>=-0.5 & permin$dif<=3])
                        actspots$registrations[i]<-sum(permin$registrations[permin$dif>=-0.5 & permin$dif<=10])  
                        permin$dif<-NULL
#                }
#        }
}

###############################
# Way of thinking
###############################

# actcosts 
# gia kathe spot
# for (i in 1:nrow(actspots)){
        # gia kathe lepto
        # for (j in 1:11) { 
                # dhmio;yrgise wra anaforas
                # check poia spot einai energa
                # energo einai ena spo pou to dif time time stamp tou me wra anaforas einai mikrotero tou 0-10
                # o eaftos mou prepei na einai TRUE
                # athtoise ta GRPs tous (krata denominator)
                # athroise sessions kai ta registrations twn energwn
                # grapse sth sthli sessions kai registrations apo panw
                # pollaplasiase ta sessions * GRPs spot / denominator
                # an einai ena mono energo grps/ denominator =1 ara olo to lepto
#        }
# }



# ga:channelGrouping


affected<-permin[permin$affected!=0,]

write.xlsx(x = affected, file = "affected.xlsx", row.names = FALSE)
write.xlsx(x = permin, file = "permin.xlsx", row.names = FALSE)
write.xlsx(x = actspots, file = "actspots.xlsx", row.names = FALSE, )
gc()

