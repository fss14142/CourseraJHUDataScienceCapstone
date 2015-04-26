Text Prediction Algorithm and Web App
========================================================
author: fss14142
date: April 2015
css: custom.css 


Capstone Project for the </br>[JHU Coursera Data Science Specialization](https://www.coursera.org/specialization/jhudatascience/1?utm_medium=listingPage) 


========================================================
<h3><font color="FireBrick">App Description and Instructions</font></h3>

<div style = "font-size:60%")>
The goal of this project is the design of a <strong>text prediction algorithm</strong> and an implementation of the algorithm as a <strong>Shiny web app</strong>. A  <strong>live version of the app</strong> appears in the next slide. Please read the following <strong>instructions</strong> before using the app:

<ol>
<li> The user enters a partial sentence in the <strong>text input field</strong> on the right.</li>
<li> The <strong>predicted word</strong> appears in red. Sometimes the prediction is a number (coded as NUM) or a year (coded as YEAR) or a word in a precompiled list of words to remove (e.g. profanities, coded as PROFANITY).</li>
<li> The table under the predicted word contains an <strong>extended prediction</strong> with the most probable words, and their assigned probabilities. A <strong>slider</strong> on the left controls the number of predicted words (up to 20).</li>
<li> A <strong>checkbox</strong> on the left switches the profanity filter on and off.</li>
<li> The app main panel has a secondary tab containing the extended <strong>app documentation</strong> and some references.</li>
</ol>
You can also find the app at  <a href="http://fss14142.shinyapps.io/shinyAppTest">http://fss14142.shinyapps.io/shinyAppTest</a>.
</div>  
 

========================================================
<h3><font color="FireBrick">Try the app now! This is an embedded live version.</font></h3>

<iframe src="http://fss14142.shinyapps.io/shinyAppTest" height=600 width=1000></iframe>
   
========================================================

<font color="FireBrick">How does it work?</font>

<div style = "font-size:70%")>

<p>In essence, the model takes the last few words of a sentence (a 4-gram if five words are used, 3-gram for three words, etc.) and uses statistics about a large collection of English sentences to find the most probable next word, given that set of sentences.</p> 

<p>Technically, the probabilities displayed by the app are assigned using a <a href="http://en.wikipedia.org/wiki/N-gram">5-gram model</a>  with smoothing in the form of discounting for low frequency words, and a careful implementation of the <a href="http://en.wikipedia.org/wiki/Katz%27s_back-off_model">Katz backoff</a> strategy (sadly, due to a <a href="http://www.cs.colorado.edu/~martin/SLP/Errata/SLP2-PH-Errata.html">errata in the popular book by Jurafsky and Martin</a>, there are many wrong descriptions of Katz Backoff posted on the web).  </p>  

<p>
The resulting language model is stored in a set of data files: a file for unigrams, a file for bigrams, etc. The information in these files is similar to the <a href="http://www.speech.sri.com/projects/srilm/manpages/ngram-format.5.html">ARPA format files</a> for n-gram models. The largest file in the model is the 35Mb trigram file. The complete 5-gram model size is 90Mb in disk space and   
</p>



<p> The algorithm was trained using a set of more than six million English sentences, sampled from three different web sources: blogs, news and Twitter. Cross validation was used to asess the accuracy of the predictions.</p>


</div>

========================================================

<h3><font color="FireBrick"> How good are the algorithm predictions?</font></h3>

<div style = "font-size:70%")>
<p>As the saying goes, the proof of the pudding is in the eating. So give it a try to see if the first words predicted by the algorithm are the ones that you expect. For a more precise measure of accuracy, the algorithm was tested against a test set of 20000 randomly chosen from a test set. The success rate of prediction was 17% and raised to 33% when the first three predicted words were considered.
</p>
</div>    

<h3><font color="FireBrick"> Known Limitations and Ideas for Future Work</font></h3>  

<div style = "font-size:70%")>
<p>
In its current form, the algorithm depends entirely on the final words of the input sentence and fails to take advantage of the broader 
sentence context which is vital for human language. The information provided by a <a href="http://en.wikipedia.org/wiki/Bag-of-words_model">bag-of-words model</a> could be applied to improve the accuracy of prediction.  
</p>
<p>
Besides, even for n-gram models, the algorithm still considers sentences like "he was late", "she was late" and "I was late" to be different. Information provided by  
<a href="http://en.wikipedia.org/wiki/Stemming">stemming algorithms</a> could be applied to these cases. 
</p>
Thank you for your attention!
</div>    

