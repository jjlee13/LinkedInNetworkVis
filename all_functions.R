
#check if packages are installed, and install them when needed
inst_pkg = load_pkg= c("rvest", "RSelenium", "ggplot2", "grid", "dplyr", "tm", "SnowballC", "wordcloud", "RColorBrewer")
inst_pkg = inst_pkg[!(inst_pkg %in% installed.packages()[,"Package"])]
if (length(inst_pkg)>0) install.packages(inst_pkg)
#load all necessary packages
pkgs_loaded =lapply(load_pkg, require, character.only=T)



USER_EMAIL = function() {
  email = readline(prompt="Enter your LinkedIn email address: ")
  return(email)
}

USER_PASSWORD = function() {
  password = readline(prompt="Enter your LinkedIn password: ")
  return(password)
}

#Scrapes names, job title, and href of all of user's connections 
scrape_names = function(path = "C:/phantomjs/bin/phantomjs.exe") {
  Email = USER_EMAIL()
  Password = USER_PASSWORD()
  psPath = path
  
  require(rvest)
  require(RSelenium)
  
  pJS = phantom(pjs_cmd = psPath)
  
  URL = "https://www.linkedin.com/uas/login"
  remDr <- remoteDriver(browserName = "phantomjs")
  remDr$open(silent = TRUE)
  remDr$navigate(URL)
  
  User_email = remDr$findElement(using = "id", "session_key-login")
  User_pass = remDr$findElement(using = "id", "session_password-login")
  Submit = remDr$findElement(using = "id", "btn-primary")
  
  User_email$sendKeysToElement(list(Email))
  User_pass$sendKeysToElement(list(Password))
  Submit$clickElement()
  Sys.sleep(5)
  
  cat("Connected to LinkedIn...")  
  
  URLC = "https://www.linkedin.com/profile/preview?locale=en_US&trk=prof-0-sb-preview-primary-button"
  remDr$navigate(URLC)
  Sys.sleep(5)
  
  result = remDr$phantomExecute("var page = this;
                                var path = 'rendered.html';
                                var fs = require('fs');
                                var content = page.content;
                                fs.write(path,content,'w') 
                                ") 
  a = read_html("rendered.html") 
  a%>%html_nodes(".connections-link")%>%html_text%>%as.numeric -> connection_number  
  
  names_vector = character(length=connection_number)
  title_vector = character(length=connection_number)
  link_vector = character(length=connection_number)
  
  if (connection_number>=10){
    a %>% html_nodes(".connections-name") %>% html_text -> names_vector[1:10]
    a %>% html_nodes(".connections-title") %>% html_text -> title_vector[1:10]
    a %>% html_nodes(".connections-name") %>% html_attr("href")->link_vector[1:10]
  }else{
    a %>% html_nodes(".connections-name") %>% html_text -> names_vector
    a %>% html_nodes(".connections-title") %>% html_text -> title_vector
    a %>% html_nodes(".connections-name") %>% html_attr("href")->link_vector
  }
  j=11
  for (i in seq_len(floor(connection_number/10))){
    Next = remDr$findElement(using = "css selector", "button.next.carousel-control-disabled") 
    #connections-view > div.connections-container.connections-all > ul > li:nth-child(2) > button
    
    Next$clickElement()
    Sys.sleep(2)
    
    result = remDr$phantomExecute("var page = this;
                                  var path = 'rendered.html';
                                  var fs = require('fs');
                                  var content = page.content;
                                  fs.write(path,content,'w') 
                                  ") 
    a = read_html("rendered.html") 
    if (((i+1)*10)<=length(names_vector)){
      a %>% html_nodes(".connections-name") %>% html_text -> names_vector[j:((i+1)*10)]
      a %>% html_nodes(".connections-title") %>% html_text -> title_vector[j:((i+1)*10)]
      a %>% html_nodes(".connections-name") %>% html_attr("href")->link_vector[j:((i+1)*10)]
    }else{
      a %>% html_nodes(".connections-name") %>% html_text -> names_vector[j:connection_number]
      a %>% html_nodes(".connections-title") %>% html_text -> title_vector[j:connection_number]
      a %>% html_nodes(".connections-name") %>% html_attr("href")->link_vector[j:connection_number]
    }
    
    j=j+10
    cat("Next Element...\n")
  }
  mat = rbind(names_vector, title_vector, link_vector)
  row.names(mat) = c("Name", "Job", "Page URL")
  
  remDr$close()
  pJS$stop()  
  
  return(mat)
}

#Scrapes connections data 
#
scrape_connections = function(path = "C:/phantomjs/bin/phantomjs.exe") {
  Email = USER_EMAIL()
  Password = USER_PASSWORD()
  psPath = path
  
  require(rvest)
  require(RSelenium)
  
  pJS = phantom(pjs_cmd = psPath)
  
  URL = "https://www.linkedin.com/uas/login"
  remDr <- remoteDriver(browserName = "phantomjs")
  remDr$open(silent=TRUE);
  remDr$navigate(URL)
  
  User_email = remDr$findElement(using = "id", "session_key-login")
  User_pass = remDr$findElement(using = "id", "session_password-login")
  Submit = remDr$findElement(using = "id", "btn-primary")
  
  User_email$sendKeysToElement(list(Email))
  User_pass$sendKeysToElement(list(Password))
  Submit$clickElement()
  Sys.sleep(5)
  
  
  URLC = "https://www.linkedin.com/profile/preview?locale=en_US&trk=prof-0-sb-preview-primary-button"
  remDr$navigate(URLC)
  Sys.sleep(5)
  
  result = remDr$phantomExecute("var page = this;
                                var path = 'rendered.html';
                                var fs = require('fs');
                                var content = page.content;
                                fs.write(path,content,'w')
                                ")
  a = read_html("rendered.html")
  a%>%html_nodes(".connections-link")%>%html_text%>%as.numeric -> connection_number
  cat("loading... do not interupt or quit \n")
  
  title_vector = character(length=connection_number)
  link_vector = character(length=connection_number)
  
  if (connection_number>=10){
    a %>% html_nodes(".connections-title") %>% html_text -> title_vector[1:10]
    a %>% html_nodes(".connections-name") %>% html_attr("href")->link_vector[1:10]
    j=11
    for (i in seq_len(floor(connection_number/10))){
      Next = remDr$findElement(using = "css selector", "button.next.carousel-control-disabled")
      Next$clickElement()
      Sys.sleep(5)
      
      result = remDr$phantomExecute("var page = this;
                                    var path = 'rendered.html';
                                    var fs = require('fs');
                                    var content = page.content;
                                    fs.write(path,content,'w')
                                    ")
      a = read_html("rendered.html")
      if (((i+1)*10)<=length(title_vector)){
        a %>% html_nodes(".connections-name") %>% html_attr("href")->link_vector[j:((i+1)*10)]
        a %>% html_nodes(".connections-title") %>% html_text -> title_vector[j:((i+1)*10)]
      }else{
        a %>% html_nodes(".connections-title") %>% html_text -> title_vector[j:connection_number]
        a %>% html_nodes(".connections-name") %>% html_attr("href")->link_vector[j:connection_number]
      }
      
      j=j+10
      
      cat("Next... \n")
    }
    
  }else{
    a %>% html_nodes(".connections-title") %>% html_text -> title_vector
    a %>% html_nodes(".connections-name") %>% html_attr("href")->link_vector
  }
  
  Sys.sleep(5)
  cat("loading... do not interrupt or quit... \n")
  
  
  Purl = link_vector
  Industry = character(length=length(Purl))
  Number_Connections = character(length=length(Purl))
  MR_Experience = character(length=length(Purl))
  MR_Education=  character(length=length(Purl))
  JOB_Desc = character(length=length(Purl))
  
  for (i in seq_along(Purl)) {
    
    remDr$navigate(Purl[i])
    Sys.sleep(5) 
    
    remDr$phantomExecute("var page = this;
                         var path = 'iPage.html';
                         var fs = require('fs');
                         var content = page.content; 
                         fs.write(path,content,'w') 
                         ");
    
    Read_EXP = read_html("iPage.html")
    
    Read_EXP %>%
      html_nodes(".industry > a") %>%
      html_text() -> Industry0
    if (length(Industry0)>0) Industry[i] = Industry0
    
    Read_EXP %>%
      html_nodes(".connections-link") %>%
      html_text() -> Number_Connections0
    if (length(Number_Connections0)>0) Number_Connections[i] = Number_Connections0
    
    Read_EXP %>%
      html_nodes("#overview-summary-current td")  %>%
      html_text() -> Experience0
    if (length(Experience0)>0) MR_Experience[i] = Experience0
    
    Read_EXP %>%
      html_nodes("#overview-summary-education li a") %>%
      html_text() -> Education0 
    if (length(Education0)>0) MR_Education[i] = Education0  
    
    cat("... \n")
  }
  
  pinfo = data.frame(cbind(Number_Connections, title_vector, MR_Experience, Industry, MR_Education)) 
  colnames(pinfo) = c("Number of Connections","Job", "Job Location", "Industry", "Education")
  remDr$close()
  pJS$stop()  
  return(pinfo)
}      

#Scrape connections "People Also Viewed" Tab, there are 10 on each connection
#Builds a table and returns a matrix of the table
#used in Shiny as well 
scrape_recommend  = function(path = "C:/phantomjs/bin/phantomjs.exe"){
  Email = USER_EMAIL()
  Password = USER_PASSWORD()
  psPath = path
  
  require(rvest)
  require(RSelenium)
  
  pJS = phantom(pjs_cmd = psPath)
  
  URL = "https://www.linkedin.com/uas/login"
  remDr <- remoteDriver(browserName = "phantomjs")
  remDr$open(silent=TRUE)
  remDr$navigate(URL)
  
  User_email = remDr$findElement(using = "id", "session_key-login")
  User_pass = remDr$findElement(using = "id", "session_password-login")
  Submit = remDr$findElement(using = "id", "btn-primary")
  
  User_email$sendKeysToElement(list(Email))
  User_pass$sendKeysToElement(list(Password))
  Submit$clickElement()
  Sys.sleep(5)
  
  cat("Logging in...")
  
  recommendation_name = character(length=(ncol(mat)*10))
  recommendation_job = character(length=(ncol(mat)*10))
  j=1 
  
  for(i in seq_len(ncol(mat))){
    URL = mat[[3,i]]
    remDr$navigate(URL)
    Sys.sleep(3)
    
    #remDr$screenshot(display=TRUE)
    
    result = remDr$phantomExecute("var page = this;
                                  var path = 'recommend.html';
                                  var fs = require('fs');
                                  var content = page.content; 
                                  fs.write(path,content,'w') 
                                  ")
    
    a = read_html("recommend.html")
    a%>% html_nodes("#aux h4 a") %>% html_text -> temp_name
    a%>% html_nodes(".browse-map-title") %>% html_text -> temp_job
    
    if (length(temp_name)>0 && length(temp_job)>0){
      recommendation_name[j:(j+length(temp_name)-1)]=temp_name
      recommendation_job[j:(j+length(temp_job)-1)]=temp_job
    }
    
    j = j+length(temp_name)
    
    cat("...\n")
  }
  
  Names = subset(recommendation_name, recommendation_name!="") 
  top_15_names = data.frame( table(Names)[order(-table(Names))][15:1] )
  
  mat = rbind(subset(recommendation_job, recommendation_job!=""), subset(recommendation_name, recommendation_name!=""))
  remDr$close()
  pJS$stop()  
  return (mat)
}

#These are used in the Shiny Application
cloud_title = function(x){
  require("tm")
  require("SnowballC")
  require("wordcloud")
  require("RColorBrewer")
  t = gsub(" at .*","", x$Job)
  write(t, file = "temp.txt")
  # Read the text file
  filePath = "temp.txt"
  text = readLines(filePath)
  # Load the data as a corpus
  docs = Corpus(VectorSource(text))
  # Convert the text to lower case
  docs = tm_map(docs, content_transformer(tolower))
  # Remove english common stopwords
  docs = tm_map(docs, removeWords, stopwords("english"))
  # Remove punctuations
  docs = tm_map(docs, removePunctuation)
  # Remove your own stop word
  docs = tm_map(docs, removeWords, c("university", "dept", "job"))
  # build term-frequency matrix
  m = as.matrix(TermDocumentMatrix(docs))
  v = sort(rowSums(m),decreasing=TRUE)
  d = data.frame(word = names(v),freq=v)
  set.seed(730)
  cloud = wordcloud(words = d$word, freq = d$freq, scale=c(4,.5), min.freq = 2,
                    max.words=200, random.order=TRUE, rot.per=0.35,
                    colors=brewer.pal(8, "Paired"), vfont=c("sans serif","plain"))
}

cloud_company = function(x){
  require("tm")
  require("SnowballC")
  require("wordcloud")
  require("RColorBrewer")
  company = gsub(".* at ","", x$Job)
  write(company, file = "temp.txt")
  # Read the text file
  filePath = "temp.txt"
  text = readLines(filePath)
  # Load the data as a corpus
  docs = Corpus(VectorSource(text))
  # Convert the text to lower case
  docs = tm_map(docs, content_transformer(tolower))
  # Remove english common stopwords
  docs = tm_map(docs, removeWords, stopwords("english"))
  # Remove punctuations
  docs = tm_map(docs, removePunctuation)
  # Remove your own stop word
  docs = tm_map(docs, removeWords, c("dept"))
  # build term-frequency matrix
  m = as.matrix(TermDocumentMatrix(docs))
  v = sort(rowSums(m),decreasing=TRUE)
  d = data.frame(word = names(v),freq=v)
  set.seed(730)
  cloud = wordcloud(words = d$word, freq = d$freq, scale=c(4,.5), min.freq = 2,
                    max.words=200, random.order=TRUE, rot.per=0.35,
                    colors=brewer.pal(8, "Paired"), vfont=c("sans serif","plain"))
}


cloud_industry = function(x){
  require("tm")
  require("SnowballC")
  require("wordcloud")
  require("RColorBrewer")
  industry = as.character(x$Industry)
  write(industry, file = "temp.txt")
  # Read the text file
  filePath = "temp.txt"
  text = readLines(filePath)
  # Load the data as a corpus
  docs = Corpus(VectorSource(text))
  # Convert the text to lower case
  docs = tm_map(docs, content_transformer(tolower))
  # Remove english common stopwords
  docs = tm_map(docs, removeWords, stopwords("english"))
  # Remove punctuations
  docs = tm_map(docs, removePunctuation)
  # Remove your own stop word
  docs = tm_map(docs, removeWords, c("character(0)"))
  # build term-frequency matrix
  m = as.matrix(TermDocumentMatrix(docs))
  v = sort(rowSums(m),decreasing=TRUE)
  d = data.frame(word = names(v),freq=v)
  set.seed(730)
  cloud = wordcloud(words = d$word, freq = d$freq, scale=c(4,.2), min.freq = 2,
                    max.words=200, random.order=TRUE, rot.per=0.45,
                    colors=brewer.pal(8, "Paired"), vfont=c("sans serif","plain"))
}




cloud_education = function(x){
  require("tm")
  require("SnowballC")
  require("wordcloud")
  require("RColorBrewer")
  industry = as.character(x$Education)
  write(industry, file = "temp.txt")
  # Read the text file
  filePath = "temp.txt"
  text = readLines(filePath) %>% gsub("-", " ", .) 
  # Load the data as a corpus
  docs = Corpus(VectorSource(text))
  # Convert the text to lower case
  docs = tm_map(docs, content_transformer(tolower))
  # Remove english common stopwords
  docs = tm_map(docs, removeWords, stopwords("english"))
  # Remove your own stop word
  docs = tm_map(docs, removeWords, c("character(0)", "university"))
  # build term-frequency matrix
  m = as.matrix(TermDocumentMatrix(docs))
  v = sort(rowSums(m),decreasing=TRUE)
  d = data.frame(word = names(v),freq=v)
  set.seed(730)
  cloud = wordcloud(words = d$word, freq = d$freq, scale=c(4,.3), min.freq = 2,
                    max.words=200, random.order=TRUE, rot.per=0.45,
                    colors=brewer.pal(8, "Paired"), vfont=c("sans serif","plain"))
}

scrape_names()
scrape_recommend()
scrape_connections()