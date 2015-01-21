#############################################
############## Traffic Report ###############
#############################################

setwd("C:/Users/tantonakis/Google Drive/Scripts/AnalyticsProj/cdgr_traffic")

library(xlsx)
library(lubridate)
library(zoo)
library(RGA)


if(file.exists("Traffic Report.xlsx")){
        report<-read.xlsx("Traffic Report.xlsx", sheetIndex=1,
                           startRow = 1, header=TRUE,stringsAsFactors=FALSE)
} else {
        report<-data.frame(Week = 0, 
                           Total.Visit = 0,
                           Total.Regist = 0,
                           Total.Order = 0,
                           SE.Visit = 0,
                           SE.Registration = 0,
                           SE.Order = 0,
                           Paid.Visit = 0,
                           Paid.Registration = 0,
                           Paid.Order = 0,
                           Bookmarked.Direct.Visit.Other = 0,
                           Bookmarked.Direct.Registration = 0,
                           Bookmarked.Direct.Order = 0,
                           Other.Referrals.Visit = 0,
                           Other.Referrals.Registration = 0,
                           Other.Referrals.Order = 0,
                           StartDate = 0)
}

# Authenticate Google Analytics
client.id = '543269518849-dcdk7eio32jm2i4hf241mpbdepmifj00.apps.googleusercontent.com'
client.secret = '9wSw6gyDVXtcgqEe0XazoBWG'
ga_token<-authorize(client.id, client.secret, cache = getOption("rga.cache"),
                    verbose = getOption("rga.verbose"))


#Set Dates
# YYYY-MM-DD , today, yesterday, or 7daysAgo
# Retrieve last Date used, so as to create new limits for report
if (report$StartDate[1] == 0) {
        print ("Report was just created and is empty!")
        print ("Let's start filling it with data")
        today <- Sys.Date()
        print ("Today it is :")
        print(format(today, format="%d/%m/%Y"))
        print("We will report data for last week")
        print("Please confirm that dates are between ")
        if( wday(today)==2){
                startdate = today-7
                enddate=startdate+6
        } else {
                startdate = today-5-wday(today)
                enddate=startdate+6
        }
        print(format(startdate, format="%d/%m/%Y"))
        print("and")
        print(format(enddate, format="%d/%m/%Y"))
        confirm<-readline("Do you confirm? Please reply with 'y' or 'n'  :") 
        while (!(confirm == "Y" | confirm == "y" | confirm == "N" | confirm =="n")) {
                # wrong input
                print("Please reply ONLY with 'y' or 'n'")
                # prompt again
                confirm<-readline("Do you confirm? Please reply ONLY with 'y' or 'n'  :") 
        }
        # correct input 
        # check answer
        if (confirm == "N" | confirm == "n" ) {
                # answer is no
                print("So, what is the starting date?")
                print("Please use the following format: YYYY-MM-DD")
                # prompt again
                maninput<-readline("Starting date is ") 
                while (!is.Date(as.Date(maninput))){
                        print("Wrong format! :(")
                        print("Please use the following format: YYYY-MM-DD")
                        maninput<-readline("Starting date is ")
                }
                print("Thank you!")
                startdate<-as.Date(maninput)
                enddate=startdate+6
                # use the input
                # Is it monday?
        } else {
                print ("Confirmed! Moving on!")
        }
                
        # answer is yes
        # User confirmed
        # date were previously calculated and stored
} else {
        startdate=as.Date(as.numeric(report$StartDate[nrow(report)]))+7
        enddate=startdate+6
}

# Insert a new line
report[nrow(report)+1,1]<-week(enddate)
        
# Start Calculating
rep1<-get_ga(25764841, start.date = startdate, end.date = enddate,
                 
                 metrics = "
                        ga:goalCompletionsAll
                ",
                 
                 dimensions = "
                        ga:goalCompletionLocation
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

rep2<-get_ga(25764841, start.date = startdate, end.date = enddate,
                 
                 metrics = "
                        ga:sessions,
                        ga:percentNewSessions,
                        ga:newUsers,
                        ga:bounceRate,
                        ga:pageviewsPerSession,
                        ga:goal1ConversionRate,
                        ga:goal1Completions,
                        ga:goal1Value,
                        ga:goal6ConversionRate,
                        ga:goal6Completions
                ",
                 
                 dimensions = "
                        ga:medium
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

report$Total.Regist[nrow(report)]<-rep1$goalCompletionsAll[rep1$goalCompletionLocation == "/events/registration/success"] +
                                   rep1$goalCompletionsAll[rep1$goalCompletionLocation == "/events/registration_step4/success"]
report$Total.Order[nrow(report)]<- rep1$goalCompletionsAll[rep1$goalCompletionLocation == "/events/customer/send_order"]
report$Total.Visit[nrow(report)]<- sum(rep2$sessions)

report$SE.Visit[nrow(report)]<-rep2$sessions[rep2$medium == "organic"]
report$SE.Registration[nrow(report)]<-rep2$goal6Completions[rep2$medium == "organic"]
report$SE.Order[nrow(report)]<-rep2$goal1Completions[rep2$medium == "organic"]

report$Paid.Visit[nrow(report)]<-rep2$sessions[rep2$medium == "cpc"]
report$Paid.Registration[nrow(report)]<-rep2$goal6Completions[rep2$medium == "cpc"]
report$Paid.Order[nrow(report)]<-rep2$goal1Completions[rep2$medium == "cpc"]

report$Bookmarked.Direct.Visit.Other[nrow(report)]<-rep2$sessions[rep2$medium == "(none)"]
report$Bookmark.Direct.Registration[nrow(report)]<-rep2$goal6Completions[rep2$medium == "(none)"]
report$Bookmark.Direct.Order[nrow(report)]<-rep2$goal1Completions[rep2$medium == "(none)"]

report$Other.Referrals.Visit[nrow(report)]<-rep2$sessions[rep2$medium == "referral"]
report$Other.Referrals.Registration[nrow(report)]<-rep2$goal6Completions[rep2$medium == "referral"]
report$Other.Referrals.Order[nrow(report)]<-rep2$goal1Completions[rep2$medium == "referral"]

report$StartDate[nrow(report)]<-startdate
rm(rep1,rep2, confirm, enddate, maninput, startdate, today)

write.xlsx(x = report, file = "Traffic Report.xlsx",
                       sheetName = "Traffic Overlook", row.names = FALSE)

print("Finished! Please look for an Excel File in the 'C:/Users/tantonakis/Google Drive/Scripts/AnalyticsProj/Traffic' folder.")
print("Have a nice day!")
