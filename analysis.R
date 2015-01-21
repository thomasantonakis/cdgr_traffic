setwd("C:/Users/tantonakis/Google Drive/Scripts/AnalyticsProj/cdgr_traffic")

# Data loading

report2<-read.xlsx("Traffic Report.xlsx", sheetIndex=1,
                  startRow = 1, header=TRUE,stringsAsFactors=FALSE)

# Packages loading
require(reshape)
require(ggplot2)
require(lattice)

# Data manipulation

# Create totals and compute percentages

report2$Total_Visits<-report2$SE.Visit+
        report2$Paid.Visit+
        report2$Bookmarked.Direct.Visit.Other+
        report2$Other.Referrals.Visit

report2$Total_Registration<-report2$SE.Registration+
        report2$Paid.Registration+
        report2$Bookmark.Direct.Registration+
        report2$Other.Referrals.Registration

report2$Total_Order<-report2$SE.Order+
        report2$Paid.Order+
        report2$Bookmark.Direct.Order+
        report2$Other.Referrals.Order

report2$se_vst_pct <- report2$SE.Visit / report2$Total_Visits
report2$pd_vst_pct <- report2$Paid.Visit / report2$Total_Visits
report2$di_vst_pct <- report2$Bookmarked.Direct.Visit.Other / report2$Total_Visits
report2$ot_vst_pct <- report2$Other.Referrals.Visit / report2$Total_Visits

report2$se_reg_pct <- report2$SE.Registration / report2$Total_Registration
report2$pd_reg_pct <- report2$Paid.Registration / report2$Total_Registration
report2$di_reg_pct <- report2$Bookmark.Direct.Registration / report2$Total_Registration
report2$ot_reg_pct <- report2$Other.Referrals.Registration / report2$Total_Registration

report2$se_ord_pct <- report2$SE.Order / report2$Total_Order
report2$pd_ord_pct <- report2$Paid.Order / report2$Total_Order
report2$di_ord_pct <- report2$Bookmark.Direct.Order / report2$Total_Order
report2$ot_ord_pct <- report2$Other.Referrals.Order / report2$Total_Order

# cleaning up
report2$Total_Visits<-NULL
report2$Total_Registration<-NULL
report2$Total_Order<-NULL

# reshaping

# Plotting

# Regarding Visits, Registrations, Orders, a line plot
## Check the scaling for the axis
par(mfrow=c(3,1))


# Regarding the ratios, a stacked 100% bar plot 
# or a line plot as below

plot(report2$se_vst_pct, type="l", lwd=2, col="blue", ylim=c(0, 1), xaxs="i", yaxs="i", 
     main = "Visits share %", ylab= "Share % of Visits", xlab="Weeks starting January 2014")
lines(report2$pd_vst_pct, lwd=2, col="red")
lines(report2$di_vst_pct, lwd=2, col="black")
lines(report2$ot_vst_pct, lwd=2, col="green")
legend("topleft", legend=c("Search","Paid", "Direct", "Other"), lwd=c(2,2,2,2), col=c("blue","red", "black", "green"))

plot(report2$se_reg_pct, type="l", lwd=2, col="blue", ylim=c(0, 1), xaxs="i", yaxs="i", 
     main = "Registrations share %", ylab= "Share % of Registrations", xlab="Weeks starting January 2014")
lines(report2$pd_reg_pct, lwd=2, col="red")
lines(report2$di_reg_pct, lwd=2, col="black")
lines(report2$ot_reg_pct, lwd=2, col="green")
legend("topleft", legend=c("Search","Paid", "Direct", "Other"), lwd=c(2,2,2,2), col=c("blue","red", "black", "green"))

plot(report2$se_ord_pct, type="l", lwd=2, col="blue", ylim=c(0, 0.6), xaxs="i", yaxs="i", 
     main = "Orders share %", ylab= "Share % of Orders", xlab="Weeks starting January 2014")
lines(report2$pd_ord_pct, lwd=2, col="red")
lines(report2$di_ord_pct, lwd=2, col="black")
lines(report2$ot_ord_pct, lwd=2, col="green")
legend("topleft", legend=c("Search","Paid", "Direct", "Other"), lwd=c(2,2,2,2), col=c("blue","red", "black", "green"))

# df <- melt(df, id="x")  # convert to long format
# ggplot(df,aes(x=x, y=value, colour=variable)) +
#         geom_line()

# require(lattice)
# xyplot(df$x ~ df[,2] + df[,3], type = c('l','l'), col = c("blue", "red"), auto.key=T)
