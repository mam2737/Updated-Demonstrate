#Demonstrate-Stampede Edition (Feb. 2, 2015)
#Original program by: Dustin Landers
#Stampede Edition by: Stephen Talley and Marco Martinez

# Overall function of Demonstrate. This lists out what is needed for the command line, as well as some assignments for creating the new columns heritability and structure.
Demonstrate <- function(dir, make.AUC.plot=TRUE, AUC.plot.title="Mean AUC By Population Structure and Heritability",
                        make.MAE.plot=TRUE, MAE.plot.title="Mean MAE By Population Structure and Heritability",herit.strings=list("_03_","_04_","_06_")
                        ,herit.values=list(0.3,0.4,0.6),struct.strings=list("PheHasStruct","PheNPStruct"),struct.values=list(TRUE,FALSE)) {
  
  # Overall function for making the new columnns heritability and structure.
  makeFiles <- function(dir) {
    
    # Here the code is reading all .txt files located within said directory.
    readFiles <- function(dir) {
      setwd(dir)
      files <- (Sys.glob("*.txt"))
      listOfFiles <- lapply(files, function(x) read.table(x, header=TRUE))
      return(listOfFiles)
    }
    
    # Heritability column is being created. Text files from previous function are now data.
    createHeritLabel <- function(data) {
      newData <- data
      newData$Herit <- NA
      first <- TRUE
      for (i in 1:length(herit.strings)) {
        newData$Herit <- ifelse(sapply(data$Name,function(x) grepl(herit.strings[[i]],x)),
                                herit.values[[i]],newData$Herit)
      }
      return(newData)
    }
    
    # Structure column is being created.
    createStructureLabel <- function(data) {
      newData <- data
      newData$Structure <- NA
      for (i in 1:length(struct.strings)) {
        newData$Structure <- ifelse(sapply(data$Name,function(x) grepl(struct.strings[[i]],x)),
                                    struct.values[[i]],newData$Structure)
      }
      return(newData)	
    }
    
    # The structure and heritability columns are being added to the overall data.
    createLabels <- function(data) {
      newData <- createHeritLabel(data)
      newNewData <- createStructureLabel(newData)
      return(newNewData)
    }
    
    myFiles <- readFiles(dir)
    myFiles <- lapply(myFiles, createLabels)
    
    return(myFiles)
    
  }
  
  myFiles <- makeFiles(dir)
  totalDataSet <- myFiles[[1]]
  for (i in 2:length(myFiles)) {
    totalDataSet <- rbind(totalDataSet, myFiles[[i]])
  }
  
  # The AUC plot function is being called with the use of lineplot.R and se.R from the sciplot package
  if (make.AUC.plot) {
    pdf(file=AUC.plot.title)
    lineplot.CI(totalDataSet$Herit,totalDataSet$AUC,totalDataSet$Structure,main=AUC.plot.title,
                xlab="Heritability",ylab="Mean AUC",trace.label="Pop. Structure")
    dev.off()
  }
  
  # The MAE plot function is being called with the use of lineplot.R and se.R from the sciplot package
  if (make.MAE.plot) {
    pdf(file=MAE.plot.title)
    lineplot.CI(totalDataSet$Herit,totalDataSet$MAE,totalDataSet$Structure,main=MAE.plot.title,
                xlab="Heritability",ylab="Mean MAE",trace.label="Pop. Structure")		
    dev.off()
  }
  
  return(totalDataSet)
  
}
