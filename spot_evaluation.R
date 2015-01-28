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

permin$affected<-0
ptm <- proc.time()
for (i in 1:nrow(permin)){
        for (j in 1:nrow(actspots)){
                dif<- difftime(permin$timestamp[i], actspots$Time[j], units="mins")
                        if ( (dif>=0) & (dif<=10)) {
                                permin$affected[i]<- permin$affected[i]+1
                } 
        }
}
proc.time() - ptm

affected<-permin[permin$affected!=0,]

write.xlsx(x = affected, file = "affected.xlsx",
           sheetName = "Traffic Overlook", row.names = FALSE)


