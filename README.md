# nhanes_modified
if you run nhanes function and get the error below

       Data set  DEMO_G  is not available
       Error in data.frame(..., check.names = FALSE) : 
       arguments imply differing number of rows: 0, 1
  
the reason is that the urls where data is stored by CDC are updated and the "nhanes" function has not been updated by the creator.
this R function can be loaded as source in R and continued to be used as the "nhanes" function
modified nhanes to update the data URLs

the use is as follows:
library (foreign)
#load the downloaded code as a sourcecode
nhanes('DEMO_G',translated = FALSE)


