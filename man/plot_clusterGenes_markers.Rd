% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/shinyModules.R
\name{plot_clusterGenes_markers}
\alias{plot_clusterGenes_markers}
\title{scClustViz plot: Plot within-cluster gene expression highlighting marker
genes}
\usage{
plot_clusterGenes_markers(sCVd, selClust, cellMarkersS, cellMarkersU)
}
\arguments{
\item{sCVd}{The sCVdata object.}

\item{selClust}{A named character vector representing the cluster to be
displayed. If \code{\link{labelCellTypes}} has been run, pass the
appropriate element of \code{attr(Clusters(sCV),"ClusterNames")} to this
argument to show both cluster number and cell type label in the legend.}

\item{cellMarkersS}{Derived from the \code{cellMarkers} argument to
\code{\link{runShiny}}. A list of the gene symbols common to two or more
cell types in \code{cellMarkers}. Each entry is named for the indicies of
\code{cellMarkers} that share the gene.}

\item{cellMarkersU}{Derived from the \code{cellMarkers} argument to
\code{\link{runShiny}}. A list of the unique gene symbols for each cell
type in \code{cellMarkers}.}
}
\description{
This function makes a scatterplot of gene detection rate vs. mean detected
gene abundance, highlighting genes identified as cell type specific markers
by the user. \strong{This function will not work unless
\code{\link{addCellMarkersToCGS}} has been run on the sCVdata object prior.}
}
\examples{
\dontrun{
cellMarkers <- list("Cortical precursors"=c("Mki67","Sox2","Pax6",
                                                  "Pcna","Nes","Cux1","Cux2"),
                          "Interneurons"=c("Gad1","Gad2","Npy","Sst","Lhx6",
                                           "Tubb3","Rbfox3","Dcx"),
                          "Cajal-Retzius neurons"="Reln",
                          "Intermediate progenitors"="Eomes",
                          "Projection neurons"=c("Tbr1","Satb2","Fezf2",
                                                 "Bcl11b","Tle4","Nes",
                                                 "Cux1","Cux2","Tubb3",
                                                 "Rbfox3","Dcx")
                          )
cellMarkersS <- apply(combn(seq_along(cellMarkers),2),2,
                      function(X) do.call(intersect,unname(cellMarkers[X])))
try(names(cellMarkersS) <- apply(combn(seq_along(cellMarkers),2),2,
                                 function(X) paste(X,collapse="&")),silent=T)
cellMarkersS <- cellMarkersS[sapply(cellMarkersS,length) > 0]
cellMarkersU <- lapply(cellMarkers,function(X) X[!X \%in\% unlist(cellMarkersS)])
sCVdata <- addCellMarkersToCGS(sCVdata,
                               cellMarkersU=cellMarkersU,
                               cellMarkersS=cellMarkersS,
                               symbolMap=NULL)

pdf("filepath.pdf",width=12,height=7)
plot_clusterGenes_markers(sCVd=sCVdata,
                          selClust="1",
                          cellMarkersS=cellMarkersS
                          cellMarkersU=cellMarkersU)
dev.off()
}

}
