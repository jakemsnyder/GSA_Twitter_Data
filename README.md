# GSA Twitter Data

This repo shows how to have a fully automated pull of Twitter data referencing the U.S. General Services Administration. The script can be modified to include other key words.

### How to use this repo
Two things will need to be updated from the R script to get this working:
1. Update the paths in the script to use your own file locations.
2. Save your Twitter API key details as a system environment variable. This can be done using the following code:
```
Sys.setenv("API Key")
```

### How to automate this data pull
On a Mac, this process can be automated using the Automator application and the following bash script:
```
/usr/local/bin/Rscript "/Users/jakesnyder/Documents/GSA Twitter Data/Twitter Mining.R" –no-save –no-restore
```
Update the file location to wherever you have the R script saved.

Once those updates have been made, create a recurring event on the Calendar application. Add an Alert, then go to Custom --> Open file. Select the Automator application you created, and the script will run at the time of the event.

### Data
The script will save a csv of the data, joining it with the previous data and removing duplicate data. My advice is to run the script once a week. A .txt will record the time each time the script is run.

### Latent Dirichlet Allocation model
This data was pulled to test out a topic analysis algorithm using Twitter data. Credit goes to [this blog post](https://eight2late.wordpress.com/2015/09/29/a-gentle-introduction-to-topic-modeling-using-r/) for showing me how to do this. I would recommend grouping documents by date (either week or month) to identify topics from Twitter discussions over time.
