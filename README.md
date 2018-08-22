# scClustViz
An interactive R Shiny tool for visualizing single-cell RNAseq clustering results from the *Seurat* R package or any other analysis pipeline.  Its main goal is two-fold: **A:** to help select a biologically appropriate resolution or K from clustering results by assessing differential expression between the resulting clusters; and **B:** help annotate cell types and identify marker genes.

-   [Quick Start](#quick-start)
-   [scClustViz Usage Guide](#scclustviz-usage-guide)  
    -   [Read in data](#read-in-data)  
    -   [Differential expression testing](#differential-expression-testing)  
    -   [Run the Shiny app](#run-the-shiny-app)  
-   [Data Packages](#data-packages)
    -   [Embryonic Mouse Cerebral Cortex](#embryonic-mouse-cerebral-cortex)
    -   [Human Liver](#human-liver)
    -   [Share Your Data With scClustViz](#share-your-data-with-scclustviz)
-   [scRNAseq analysis pipeline](#scrnaseq-analysis-pipeline)  
-   [Contact](#contact)  

## Quick Start
Install scClustViz using devtools:
```{r}
# install devtools
install.packages("devtools")

# install scClustViz
devtools::install_github("BaderLab/scClustViz")
```
Load data from your Seurat analysis for differential expression testing and visualization in scClustViz:
```{r}
library(scClustViz)

data_for_scClustViz <- readFromSeurat(your_seurat_object)
rm(your_seurat_object)
# All the data scClustViz needs is in 'data_for_scClustViz'.

DE_for_scClustViz <- clusterWiseDEtest(data_for_scClustViz,exponent=exp(1))

save(data_for_scClustViz,DE_for_scClustViz,
     file="for_scClustViz.RData")
# Save these objects so you'll never have to run this slow function again!

runShiny(filePath="for_scClustViz.RData")
```

## scClustViz Usage Guide
scClustViz takes the output object from your single-cell analysis pipeline of choice, and runs differential expression testing for all the clustering solutions generated during your analysis to generate a cluster assessment metric used in the visualization tool. The visualization tool itself is an R Shiny app that generates a variety of figures designed to help assess clustering results, and identify clusters and their marker genes.

### Read in data
scClustViz assumes you have tried a variety of parameterizations when clustering the cells from your scRNAseq data, and want to decide which clustering solution you should use (if you haven't yet clustered your data, or are interested in an example of integrating the differential expression metric used in this tool to systematically test different clustering resolutions, see the example [pipeline below](#scrnaseq-analysis-pipeline)).  
To read in your data from a Seurat object (check the documentation to ensure your object meets requirements), you can run:
```{r}
data_for_scClustViz <- readFromSeurat(your_seurat_object)
```
If your data isn't in a Seurat object, or otherwise doesn't fit the requirements for `readFromSeurat` you can run `readFromManual`, which allows you to manually add all the required components of your analysis to the object scClustViz uses for the differential expression testing. See its man page (`?readFromManual`) for details, or use the example here using a hypothetical SingleCellExperiment class from Bioconductor as the input:
```{r}
# A logical vector separating the cluster assignments from the rest of the
# cell metadata in the colData slot. This is an example that you will have
# to change to reflect your cluster assignment column names.
clusterAssignments <- grepl("^Clust",colnames(colData(mySCE)))

data_for_scClustViz <- readFromManual(nge=logcounts(mySCE),
                                      md=colData(mySCE)[,!clusterAssignments],
                                      cl=colData(mySCE)[,clusterAssignments],
                                      dr_clust=reducedDim(mySCE,"PCA"),
                                      dr_viz=reductedDim(mySCE,"tSNE"))
# All the data scClustViz needs is in 'data_for_scClustViz'.
```
### Differential expression testing
*A more thorough explanation of the DE testing scheme and how to bypass it (structure of the output lists in case you want to replace it with your own DE method/results) will be here soon. For now, see `?clusterWiseDEtest`*
```{r}
DE_for_scClustViz <- clusterWiseDEtest(data_for_scClustViz,
                                       # Stop once DE is lost between nearest neighbouring clusters
                                       testAll=FALSE,
                                       # Normalized data is in log2 space
                                       exponent=2,
                                       # Pseudocount of 1 was added to log-normalized data
                                       pseudocount=1,
                                       # False discovery rate threshold of 1%
                                       FDRthresh=0.01,
                                       # Use difference in detection rate to filter genes for testing
                                       threshType="dDR",
                                       # Genes with at least 15% detection rate difference will be tested
                                       dDRthresh=0.15
                                       )

# Save the results of the preprocessing for use in the Shiny app!
save(data_for_scClustViz,DE_for_scClustViz,file="for_scClustViz.RData")
```

### Run the Shiny app
Finally, its time to run the app. Running this function will open the Shiny UI in a separate window.  Have fun exploring your data!
```{r}
runShiny(filePath="for_scClustViz.RData")
```

## Data Packages
The following data packages can be used to explore the features of scClustViz. You can also follow the vignette below to build your own data package to easily share your analysed scRNAseq data with collaborators and the public.

### Embryonic Mouse Cerebral Cortex
The data from the 2017 Cell Reports paper [Developmental Emergence of Adult Neural Stem Cells as Revealed by Single-Cell Transcriptional Profiling](https://doi.org/10.1016/j.celrep.2017.12.017) by Yuzwa *et al.* are available to explore by installing the R package [MouseCortex](https://github.com/BaderLab/MouseCortex). These are DropSeq data from timepoints spanning neurogenesis and filtered for cortically-derived cells, processed on an earlier version of the pipeline outlined below (using scran for normalization and Seurat for clustering) and imported into scClustViz using the steps outlined above.

Install MouseCortex using devtools as follows:
```{r}
# install devtools
install.packages("devtools")

# install MouseCortex (demo data from Yuzwa et al, Cell Reports 2017)
devtools::install_github("BaderLab/MouseCortex") # this takes a minute or two

# install mouse cell annotations from bioconductor (optional)
source("https://bioconductor.org/biocLite.R")
biocLite("org.Mm.eg.db")
```
Then run the scClustViz Shiny app to view your dataset of choice! 
There's a wrapper function in the MouseCortex package that handles the call to scClustViz, so it's nice and simple. 
If you're interested, `?runShiny` has example code showing the function call used by the wrapper function.
```{r}
library(MouseCortex)
viewMouseCortex("e13")
```

### Human Liver
The data from the 2018 Nature Communications paper [Developmental Emergence of Adult Neural Stem Cells as Revealed by Single-Cell Transcriptional Profiling](https://doi.org/10.1016/j.celrep.2017.12.017) by Yuzwa *et al.* are available to explore by installing the R package [MouseCortex](https://github.com/BaderLab/MouseCortex). These are DropSeq data from timepoints spanning neurogenesis and filtered for cortically-derived cells, processed on an earlier version of the pipeline outlined below (using scran for normalization and Seurat for clustering) and imported into scClustViz using the steps outlined above.

Install MouseCortex using devtools as follows:
```{r}
# install devtools
install.packages("devtools")

# install MouseCortex (demo data from Yuzwa et al, Cell Reports 2017)
devtools::install_github("BaderLab/MouseCortex") # this takes a minute or two

# install mouse cell annotations from bioconductor (optional)
source("https://bioconductor.org/biocLite.R")
biocLite("org.Mm.eg.db")
```
Then run the scClustViz Shiny app to view your dataset of choice! 
There's a wrapper function in the MouseCortex package that handles the call to scClustViz, so it's nice and simple. 
If you're interested, `?runShiny` has example code showing the function call used by the wrapper function.
```{r}
library(MouseCortex)
viewMouseCortex("e13")
```


### Share Your Data With scClustViz
Building an R package is a relatively easy task thanks to RStudio and the roxygen2 and devtools packages. The following vignette will show you how to take your saved output from the scClustViz setup and share it as an R package on github as seen in the data packages above. It is entirely based on the invaluable book [R packages](http://r-pkgs.had.co.nz/) by Hadley Wickham.  
First, you must have generated your input file for the `runShiny` command in scClustViz by following the steps in the [usage guide](#scclustviz-usage-guide) above.  
Then, create a new project in RStudio, selecting "New directory" -> "R package" and making sure to check "Create a git repository". If you haven't already set up git/github in RStudio, check out [this blogpost](https://www.r-bloggers.com/rstudio-and-github/) for an explanation. If you only want to make a package to share with colleagues, you can skip github and simply send them the bundled package when you're done.  
Once you've opened your new package in RStudio, make sure to have both "Use devtools package functions" and "Generate documentation with Roxygen" selected under "Project Options" -> "Build Tools". Also, delete the existing NAMESPACE file, since Roxygen will create a new one when you build the package.  
You're now ready to build your package.  First, make a folder in the package directory called "inst", and put your input file for *runShiny* there. All files in "inst" become part of the root directory of the package after installation, so it's best to store your data in a folder within inst.
```{r}
dir.create("inst/packageData/",recursive=T)
save(data_for_scClustViz,DE_for_scClustViz,file="inst/packageData/MyDataTitle.RData")
```
If you'd like a default resolution to load when the user views your data in scClustViz, now's the time to save that.
```{r}
runShiny("inst/packageData/MyDataTitle.RData")
```
Save your selected cluster resolution as default in the app. It will be saved as "inst/packageData/MyDataTitle_savedRes.RData". You will also see a file called "inst/packageData/MyDataTitle_intro.md". This is a markdown file that stores the text displayed at the top of the scClustViz GUI. You can edit it to say what you want (perhaps a link to the paper the data is from, and maybe the abstract?).  
Now all you need to do is write the wrapper function to call *runShiny*. Here is an example R script (overwrite R/HelloWorld.R) to save in the "R" directory of the package.
```{r}
#' View MyData data in the scClustViz Shiny app
#'
#' A wrapper function to view the \code{MyData} dataset in the
#' \code{scClustViz} Shiny app.
#'
#' @param outPath Default = "./" (the working directory). Specify the directory
#'   used to save/load any analysis files you generate while exploring the
#'   \code{MyData} data.
#'
#' @return The function causes the scClustViz Shiny GUI app to open in a
#'   seperate window.
#'
#' @examples
#'   viewMyData()
#'
#' @seealso \url{https://baderlab.github.io/scClustViz} for information on
#'   \code{scClustViz}.
#'
#' @export

viewMyData <- function(outPath="./") {
  filePath <- system.file("packageData/MyDataTitle.RData",package="MyDataPackage")
  cellMarkers <- list()
  # If you have a list of cell-type marker genes for you data, add them here!
  
  # Change "org.Hs.eg.db" to the appropriate AnnotationDbi object for you data. 
  # This way if your user has the library installed, it will be used, otherwise
  # it will be skipped without causing any errors.
  if (require("org.Hs.eg.db",quietly=T)) {
    annotationDB <- org.Hs.eg.db
    scClustViz::runShiny(filePath=filePath,
                         outPath=outPath,
                         cellMarkers=cellMarkers,
                         annotationDB=annotationDB)

  } else {
    scClustViz::runShiny(filePath=filePath,
                         outPath=outPath,
                         cellMarkers=cellMarkers)
  }
}
```
Now that you have a wrapper function, all that's left to do is fix up the DESCRIPTION file. The most important entries for functionality in the file are the following:
```
Suggests: org.Hs.eg.db
Imports: scClustViz
Remotes: BaderLab/scClustViz
```
Change "org.Hs.eg.db" to the appropriate AnnotationDbi library. This lets the user know that they would benefit from having it installed. More importantly, `Imports: scClustViz` tells R devtools to install scClustViz when installing your package. Since scClustViz isn't in CRAN, the line `Remotes: BaderLab/scClustViz` lets devtools know where to find it.  
Now that everything's ready, use the "Install and Restart" button in RStudio or hit Ctrl+Shift+B to build and install the package locally. You should now be able to use the wrapper command to open scClustViz with your data. If you're happy with everything, it's time to push to github!  
First you must [create a new repository on github](https://help.github.com/articles/creating-a-new-repository/) for your package. Then it's as simple as pushing your first commit (commands here are in the bash shell):
```
# Set the remote to the github account:
git remote add origin https://github.com/YourGithubAccount/MyDataPackage.git 

# Stage your directory
git add .

# Make your first commit
git commit -m "MyData is now an R package!"

#Push your first commit to github (could be slow, since you're uploading data files)
git push -u origin master
```
Now all you need to do is edit the README file to tell the world how to install and run your package:
```
devtools::install_github("YourGithubAccount/MyDataPackage")
MyDataPackage::viewMyData()
```

## scRNAseq analysis pipeline
*Currently being updated to use the functions from scClustViz - check back soon.*

## Contact
You can [contact me](http://www.baderlab.org/BrendanInnes) for questions about this repo.  For general scRNAseq questions, do what I do and [ask the Toronto single-cell RNAseq working group on Slack](http://bit.ly/scRNAseqTO)!  



