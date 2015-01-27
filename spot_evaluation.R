library(RGA)

client.id = '543269518849-dcdk7eio32jm2i4hf241mpbdepmifj00.apps.googleusercontent.com'
client.secret = '9wSw6gyDVXtcgqEe0XazoBWG'

ga_token<-authorize(client.id, client.secret, cache = getOption("rga.cache"),
                    verbose = getOption("rga.verbose"))

startdate='2015-01-24'
enddate='2015-01-25'

web<-get_ga(25764841, start.date = startdate, end.date = enddate,
             
               metrics = "
                        ga:sessions,
                        ga:goal1Completions,
                        ga:goal1Value,
                        ga:goal6Completions,
                        ga:goal6Value,
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
                        ga:goal1Value,
                        ga:goal6Completions,
                        ga:goal6Value,
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
                        ga:goal1Value,
                        ga:goal6Completions,
                        ga:goal6Value,
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

web$source <- "web"
android$source <- "android"
ios$source <- "ios"
permin<-rbind(web, android, ios)


library(xlsx)
write.xlsx(x = permin, file = "permin.xlsx",
           sheetName = "Traffic Overlook", row.names = FALSE)


