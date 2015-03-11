#############################################
############## Traffic Report ###############
#############################################

library(RGA)

client.id = '543269518849-dcdk7eio32jm2i4hf241mpbdepmifj00.apps.googleusercontent.com'
client.secret = '9wSw6gyDVXtcgqEe0XazoBWG'

ga_token<-authorize(client.id, client.secret, cache = getOption("rga.cache"))

############################################
startdate='2015-03-04' ##Start Date#########
enddate='2015-03-11' ####End Date###########
############################################

rep1<-get_ga(25764841, start.date = startdate, end.date = enddate,
             
             metrics = "
                        ga:impressions,
                        ga:sessions
                ",
             
             dimensions = "
                        ga:campaign
                ",
             sort = NULL, 
             filters = NULL,
             segment = NULL, 
             sampling.level = NULL,
             start.index = NULL, 
             max.results = NULL, 
             ga_token
)

rep1[rep1$campaign == 'Goodys #paratasi',]
