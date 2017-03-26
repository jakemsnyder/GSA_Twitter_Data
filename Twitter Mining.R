setwd("/Users/jakesnyder/Documents/GSA Twitter Data")

#load text mining library
library(tm)
library(rtweet)
library(dplyr)


twitter_token <- create_token(app = Sys.getenv("TWITTER_APP"),
                              consumer_key = Sys.getenv("TWITTER_KEY"),
                              consumer_secret = Sys.getenv("TWITTER_SECRET"))

tw <- search_tweets("usgsa", n = 1200, token = twitter_token, lang = "en")


pull <- read.table('Twitter Pull Times.txt',header=F,sep="\t",stringsAsFactors=F)
pull <- rbind(pull,paste0('Pull ',nrow(pull)+1,' on ',format(Sys.time(),tz='America/New_York',usetz=T)))
write.table(pull,'Twitter Pull Times.txt',sep="\t",row.names=F,col.names=F)

data.new <- tw %>% select(created_at,status_id,text,retweet_count,favorite_count,screen_name,
                          mentions_screen_name,hashtags,is_retweet)
data <- read.csv('GSA Tweets.csv')
data.new$created_at <- as.POSIXct(strptime(as.character(data.new$created_at),format='%Y-%m-%d %H:%M:%S'))
data$created_at <- as.POSIXct(strptime(as.character(data$created_at),format='%Y-%m-%d %H:%M:%S'))
data <- unique(rbind(data,data.new))
write.csv(data,"GSA Tweets.csv",row.names=F)

quit(save="no")