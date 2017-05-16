# This script heavily leverages the work done by K and his extremely helpful blog post:
# https://eight2late.wordpress.com/2015/09/29/a-gentle-introduction-to-topic-modeling-using-r/
# The script is mostly the same with some tweaks to work for this dataset.

setwd("/Users/jakesnyder/Documents/GSA Twitter Data")
library(topicmodels)
library(dplyr)
library(tm)

data <- read.csv('GSA Tweets.csv')
data$monthday <- format(data$created_at, "%m-%d")

#Remove bots that I know of
data <- filter(data, screen_name != 'alenisaac')

df <- data %>% group_by(monthday) %>% summarise(text = paste0(text, collapse = " "))

docs <- Corpus(VectorSource(df$text))


#inspect a particular document in corpus
writeLines(as.character(docs[[5]]))


#start preprocessing
#Transform to lower case
docs <-tm_map(docs,content_transformer(tolower))


#remove potentially problematic symbols
toSpace <- content_transformer(function(x, pattern) { return (gsub(pattern, '', x))})
docs <- tm_map(docs, toSpace, "'")
docs <- tm_map(docs, toSpace, '-')
docs <- tm_map(docs, toSpace, '’')
docs <- tm_map(docs, toSpace, '‘')
docs <- tm_map(docs, toSpace, '•')
docs <- tm_map(docs, toSpace, '"')


#remove punctuation
docs <- tm_map(docs, removePunctuation)
#Strip digits
docs <- tm_map(docs, removeNumbers)
#remove stopwords
docs <- tm_map(docs, removeWords, stopwords("english"))
#remove whitespace
docs <- tm_map(docs, stripWhitespace)
#Good practice to check every now and then
writeLines(as.character(docs[[5]]))
#Stem document
docs <- tm_map(docs,stemDocument)


#fix up 1) differences between us and aussie english 2) general errors
docs <- tm_map(docs, content_transformer(gsub),
               pattern = 'organiz', replacement = 'organ')
docs <- tm_map(docs, content_transformer(gsub),
               pattern = 'organis', replacement = 'organ')
docs <- tm_map(docs, content_transformer(gsub),
               pattern = 'andgovern', replacement = 'govern')
docs <- tm_map(docs, content_transformer(gsub),
               pattern = 'inenterpris', replacement = 'enterpris')
docs <- tm_map(docs, content_transformer(gsub),
               pattern = 'team-', replacement = 'team')
#define and eliminate all custom stopwords
myStopwords <- c('can', 'say','one','way','use',
                 'also','howev','tell','will',
                 'much','need','take','tend','even',
                 'like','particular','rather','said',
                 'get','well','make','ask','come','end',
                 'first','two','help','often','may',
                 'might','see','someth','thing','point',
                 'post','look','right','now','think','‘ve ',
                 '‘re ','anoth','put','set','new','good',
                 'want','sure','kind','larg','yes,','day','etc',
                 'quit','sinc','attempt','lack','seen','awar',
                 'littl','ever','moreov','though','found','abl',
                 'enough','far','earli','away','achiev','draw',
                 'last','never','brief','bit','entir','brief',
                 'great','lot','usgsa','via','feder','gsa','must',
                 'servic','administr','general','peopl','work')
docs <- tm_map(docs, removeWords, myStopwords)
#inspect a document as a check
writeLines(as.character(docs[[5]]))


#Create document-term matrix
dtm <- DocumentTermMatrix(docs)
#convert rownames to filenames
rownames(dtm) <- df$monthday
#collapse matrix by summing over columns
freq <- colSums(as.matrix(dtm))
#length should be total number of terms
length(freq)
#create sort order (descending)
ord <- order(freq,decreasing=TRUE)
#List all terms in decreasing order of freq
#freq[ord]

#Machine learning time
#Set parameters for Gibbs sampling
burnin <- 4000
iter <- 2000
thin <- 500
seed <-list(2003,5,63,100001,765)
nstart <- 5
best <- TRUE


#Number of topics
k <- 3

#Run LDA using Gibbs sampling
ldaOut <-LDA(dtm,k, method='Gibbs', control=list(nstart=nstart, seed = seed, best=best, burnin = burnin, iter = iter, thin=thin))


#write out results
#docs to topics
ldaOut.topics <- as.matrix(topics(ldaOut))


#top 6 terms in each topic
ldaOut.terms <- as.matrix(terms(ldaOut,6))


#probabilities associated with each topic assignment
topicProbabilities <- as.data.frame(ldaOut@gamma)
topicProbabilities %>% mutate(monthday = df$monthday)

#Find relative importance of top 2 topics
topic1ToTopic2 <- lapply(1:nrow(dtm),function(x)
  sort(topicProbabilities[x,])[k]/sort(topicProbabilities[x,])[k-1])


#Find relative importance of second and third most important topics
topic2ToTopic3 <- lapply(1:nrow(dtm),function(x)
  sort(topicProbabilities[x,])[k-1]/sort(topicProbabilities[x,])[k-2])


####Troubleshooting####
r_stats_text_corpus <- tm_map(r_stats_text_corpus,
                              content_transformer(function(x) iconv(x, to='UTF-8-MAC', sub='byte')),
                              mc.cores=1
)
r_stats_text_corpus <- tm_map(r_stats_text_corpus, content_transformer(tolower), mc.cores=1)
r_stats_text_corpus <- tm_map(r_stats_text_corpus, removePunctuation, mc.cores=1)
r_stats_text_corpus <- tm_map(r_stats_text_corpus, function(x)removeWords(x,stopwords()), mc.cores=1)
