library(shiny)
library(stringi)
library(data.table)

word2code = function(w){
  l = list(w)
  codes[l]$code
}

code2word = function(a){
  where = sapply(a, function(x)which(codes$code == x))
  codes[where]$x
}

unigrams = readRDS("../data/unigrams.Rds") #ngrams$unigrams
bigrams = readRDS("../data/bigrams.Rds")
trigrams = readRDS("../data/trigrams.Rds")
fourgrams = readRDS("../data/fourgrams.Rds")
#fivegrams = readRDS("../data/fivegrams.Rds")
codes = readRDS("../data/codes.Rds")
removeCodes = readRDS("../data/removeCodes.Rds")

codes = rbindlist(list(codes, list(x="PROFANITY", cX=1, code=1000001)), use.names = TRUE, fill = TRUE)
setkey(codes, x)


shinyServer(function(input, output) {
  
  preProcess = function(sentence){
    sentence = tolower(sentence)
    sentence = paste(" BS ", sentence)
    sentenceWords = unlist(stri_extract_all_words(sentence))
    regexYEAR = "^[12]{1}[0-9]{3}$"
    sentenceWords = stri_replace_all(sentenceWords, replacement = "YEAR", regex = regexYEAR)
    regexNUM = "^[[:digit:]]+(,[[:digit:]]*)*\\.*[[:digit:]]*$"
    sentenceWords = stri_replace_all(sentenceWords, replacement = "NUM", regex = regexNUM)
    punctuationRegex = "[\\[\\]\\$\\*\\+\\.\\?\\^\\{\\}\\|\\(\\)\\#%&~_/<=>✬!,:;❵@]"
    sentenceWords = stri_replace_all(sentenceWords, replacement = "", regex = punctuationRegex)
    sentenceWords = stri_replace_all(sentenceWords, replacement = "'", fixed = "’")
    nonEnglishChars = "[^A-Za-z'-[:space:]]"
    sentenceWords = stri_replace_all(sentenceWords, replacement = "", regex = nonEnglishChars)
    emptyWords = (sentenceWords == "")|(sentenceWords=="'")
    sentenceWords = sentenceWords[!emptyWords]
    return(sentenceWords)
  } 
  
  predictWith1grams = function(prevWords=numeric(0), k=3){
    
    newWords = numeric(0)
    newProbs=numeric(0)
    
    selected = unigrams[!(x %in% prevWords)][order(pX, decreasing = TRUE)]
    k2 = min(k, nrow(selected))
    newWords = selected$x[1:k2]
    newProbs = selected$pX[1:k2]
    
    prediction = list(words = newWords, probs = newProbs)
    return(prediction)  
    
  }  # end of predictWith1grams
  
  
  predictWith2grams = function(x0=numeric(0), prevWords=numeric(0), k=3){
    
    newWords = numeric(0)
    newProbs=numeric(0)
    
    (bigramsExist = any(!is.na(bigrams[.(x0)][!(y %in% prevWords)]$pXY)) )
    
    if(bigramsExist){
      
      selected = bigrams[.(x0)][!(y %in% prevWords)][order(pXY, decreasing = T)]
      k2 = min(k, nrow(selected))
      newWords = selected$y[1:k2]
      newProbs = selected$pXY[1:k2]
      
      ## Second case of Katz backoff formula
      
      alpha = selected$alpha[1]
      
      fromUnigrams = predictWith1grams(c(prevWords, newWords), k)
      newWords = c(newWords, fromUnigrams$words)
      newProbs = c(newProbs, alpha * fromUnigrams$probs) # alpha is used here   
      
    } else {
      
      ## Third case of Katz backoff formula.
      ## Applies when x0 is an unseen word.
      
      fromUnigrams = predictWith1grams(prevWords, k)
      newWords = fromUnigrams$words
      newProbs = fromUnigrams$probs # alpha = 1 in this case
      
      
    }
    
    prediction = list(words = newWords, probs = newProbs)
    return(prediction)  
    
  } # end of predictWith2grams
  
  predictWith3grams = function(xy=numeric(0), prevWords=numeric(0), k=3){
    
    x0 = xy[1]
    y0 = xy[2]
    
    newWords = numeric(0)
    newProbs=numeric(0)
    
    (trigramsExist = any(!is.na(trigrams[.(x0, y0)][!(z %in% prevWords)]$pXYZ)) )
    
    if(trigramsExist){
      
      selected = trigrams[.(x0, y0)][!(z %in% prevWords)][order(pXYZ, decreasing = T)]
      k2 = min(k, nrow(selected))
      newWords = selected$z[1:k2]
      newProbs = selected$pXYZ[1:k2]
      
      ## Second case of Katz backoff formula
      
      alpha = selected$alpha[1]
      
      fromBigrams = predictWith2grams(x0 = y0, c(prevWords, newWords), k)
      newWords = c(newWords, fromBigrams$words)
      newProbs = c(newProbs, alpha * fromBigrams$probs) # alpha is used here    
      
    } else {
      
      ## Third case of Katz backoff formula.
      ## Applies when (x0, y0) is an unseen 2-gram.
      
      fromBigrams = predictWith2grams(x0 = y0, prevWords, k)
      newWords = fromBigrams$words
      newProbs = fromBigrams$probs # alpha = 1 in this case
      
    }
    
    prediction = list(words = newWords, probs = newProbs)
    return(prediction)  
    
  } # end of predictWith3grams
  
  
  predictWith4grams = function(xyz=numeric(0), prevWords=numeric(0), k=3){
    
    x0 = xyz[1]
    y0 = xyz[2]
    z0 = xyz[3]
    
    newWords = numeric(0)
    newProbs=numeric(0)
    
    (fourgramsExist = any(!is.na(fourgrams[.(x0, y0, z0)][!(t %in% prevWords)]$pXYZT)) )
    
    if(fourgramsExist){
      
      selected = fourgrams[.(x0, y0, z0)][!(t %in% prevWords)][order(pXYZT, decreasing = T)]
      k2 = min(k, nrow(selected))
      newWords = selected$t[1:k2]
      newProbs = selected$pXYZT[1:k2]
      
      ## Second case of Katz backoff formula
      
      alpha = selected$alpha[1]
      
      fromTrigrams = predictWith3grams(xy= c(y0,z0), c(prevWords, newWords), k)
      newWords = c(newWords, fromTrigrams$words)
      newProbs = c(newProbs, alpha * fromTrigrams$probs) # alpha is used here    
      
    } else {
      
      ## Third case of Katz backoff formula.
      ## Applies when (x0, y0, z0) is an unseen 3-gram.
      
      fromTrigrams = predictWith3grams(xy= c(y0,z0), prevWords, k)
      newWords = fromTrigrams$words
      newProbs = fromTrigrams$probs # alpha = 1 in this case
      
    }
    
    prediction = list(words = newWords, probs = newProbs)
    return(prediction)  
    
  }  # end of predictWith4grams
  
  
  predictWith5grams = function(xyzt=numeric(0), prevWords=numeric(0), k=3){
    
    x0 = xyzt[1]
    y0 = xyzt[2]
    z0 = xyzt[3]
    t0 = xyzt[4]
    newWords = numeric(0)
    newProbs=numeric(0)
    
    (fivegramsExist = any(!is.na(fivegrams[.(x0, y0, z0, t0)][!(u %in% prevWords)]$pXYZTU)) )
    
    if(fivegramsExist){
      
      selected = fivegrams[.(x0, y0, z0, t0)][!(u %in% prevWords)][order(pXYZTU, decreasing = T)]
      k2 = min(k, nrow(selected))
      newWords = selected$u[1:k2]
      newProbs = selected$pXYZTU[1:k2]
      
      ## Second case of Katz backoff formula
      
      alpha = selected$alpha[1]
      
      fromFourgrams = predictWith4grams(xyz= c(y0, z0, t0), c(prevWords, newWords), k)
      newWords = c(newWords, fromFourgrams$words)
      newProbs = c(newProbs, alpha * fromFourgrams$probs) # alpha is used here    
      
    } else {
      
      ## Third case of Katz backoff formula.
      ## Applies when (x0, y0, z0, t0) is an unseen 4-gram.
      
      fromFourgrams = predictWith4grams(xyz= c(y0, z0, t0), prevWords, k)
      newWords = fromFourgrams$words
      newProbs = fromFourgrams$probs # alpha = 1 in this case
      
    }
    
    prediction = list(words = newWords, probs = newProbs)
    return(prediction)  
    
  }  # end of predictWith5grams
  
  
  predictedWord = function(inputSentence=character(0), k=20){
    
    # Preprocess the words
    
    inputWords = preProcess(inputSentence)
    
    # Convert them to numeric codes
    
    inputWords = word2code(inputWords)
    
    
    # First check the number of input words
    n  = length(inputWords)
    
    prevWords = numeric(0)
    prevProbs = numeric(0)
    prediction = list()
    
    # The answer depends on the value of n
    
#     if(n >= 4){
#       
#       xyzt = inputWords[(n-3):n]
#       prediction = predictWith5grams(xyzt, prevWords, k)
#       
#     } else if(n == 3){
      if(n >= 3){
        
      xyz = inputWords[(n-2):n]
      prediction = predictWith4grams(xyz, prevWords, k)
      
    } else if(n == 2){
      
      xy = inputWords
      xy = inputWords[(n-1):n]
      prediction = predictWith3grams(xy, prevWords, k)
      
    }  else if(n == 1){
      
      x = inputWords
      prediction = predictWith2grams(x0=x, prevWords, k)
      
    }  else if(n == 0){
      
      prediction = predictWith1grams(prevWords, k)
      
    } 
    
    ### Now we have a list of predicted word codes and probabilities
    
    
    ## We need to flag any prediction in the profanity list
    
    if(input$profFilter){
      prediction$words[prediction$words %in% removeCodes] = 1000001
    }
    
    
    predictedWords = list(words = code2word(prediction$words), 
                          probs = prediction$probs)
    
    ##
    
    return(predictedWords)
    
  }  # end of predictedWord  
  
  
  output$predictedWordMain <- renderText({
    
    predictedWord(input$userSentence, k = input$numPredicted)$words[1]
    
  })
    
  prediction = reactive({
    k = input$numPredicted
    predList = predictedWord(input$userSentence, k)
    data.table(words = predList$words[1:k], probs = predList$probs[1:k])
    
  })
  
  output$predictionTable = renderDataTable(
    options = list(searching = FALSE, paging=FALSE, bInfo=FALSE), 
    prediction()
    )
  
  output$kText = renderText(
    paste0(
    "And the complete table of the first ", 
    input$numPredicted, 
    " predicted words with their probabilities is:", 
    collapse = "")
    )

})