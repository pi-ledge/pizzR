####################################################################################################
#'                                 Ranger MDA Feature selection v1                        # pi.ledge
####################################################################################################

#' rfFeatsel() #########################################################################
#' ranger (randomForest) classification recursive feature removal
#' provides two resulting models: best model after feature removal + fittest model (model using least variables of all models passing the given threshold)
#' @example1          ranFeatsel(data,"classes")
#' @example2          ranFeatsel(data,"classes",ntree=1000,nthreads=11,savename="feature_sel",savedir="C:/output",keep.files=TRUE)
#' @param data        data set given to ranger randomForest
#' @param classes     colname of sample-column as character
#' @param ntree       number of trees built in a forest
#' @param nthreads    number of CPU-threads to be used; default is number of available threads-1
#' @param savename    character prefix for saving the models
#' @param savedir     character location to save results to, is created if it does not exist.
#' @param keep.files  if F: only best model will be kept; if T: all models incl. submodels will be kept
#' @param best_thr    quantile-threshold for selection of fittest model
#' @param nimpplot    number of variables to be plotted on importance plot
#' @param ...         additional arguments passed to ranger()
#' @return            list containing OOB-OA of all submodels as well as ranger-models, classificationMatrix, metrics and importance plots for both, fittest and best model

rfFeatsel <- function(data,classes,ntree=1000,nthreads=parallel::detectCores()-1,savename="ranFeatsel",savedir=getwd(),keep.files=TRUE,best_thr=.975,nimpplot=20,...){

  cat("\n")
  warning("This function is still in developement")
  cat("\n")


  package.install <- function(package.name){
    if(length(grep(package.name,installed.packages()[,"Package"][nchar(installed.packages())==nchar(package.name)]))==0){
      cat("\n",paste0(Sys.time(),": installing package '",package.name,"'\n\n"))
      install.packages(package.name,dependencies=TRUE)
    }
  }

  ### install required packages if necessary
  package.install("caret")
  package.install("parallel")
  package.install("ranger")
  package.install("vip")

  st.featsel <- as.integer(format(Sys.time(),"%s"))
  cat("\n")
  cat("               \r",paste0(Sys.time(),": starting recursive MDA-feature selection","\n"))

  ### create savedir if required and set as wd()
  if(dir.exists(savedir)==FALSE){
    dir.create(savedir, recursive=TRUE)
    cat(paste0(" ",Sys.time(),": '",savedir,"' created and set as working directory\n"))
    setwd(savedir)
  }else{
    if(getwd() != savedir){
      cat(paste0(" ",Sys.time(),": '",savedir,"' set as working directory\n"))
      setwd(savedir)
    }
  }

  ### limit use of all threads to avoid system-instability
  if((nthreads>parallel::detectCores()-1)){
    nthreads <- parallel::detectCores()-1
  }

  ### create input-data for ranger
  dots                  <- list(...)
  dots$x                <- data[,-grep(classes,colnames(data))]
  dots$y                <- as.factor(data[,grep(classes,colnames(data))])
  dots$num.trees        <- ntree
  dots$num.threads      <- nthreads
  dots$importance       <- "permutation"
  dots$keep.inbag       <- TRUE
  dots$classification   <- TRUE

  ### define denomination-flags
  N <- max(nchar(ncol(dots$x)))
  rf_type         <- 'MDA'

  ### start MDA-feature-selection
  for(i in 1:(ncol(data)-1)){

    if(i==1){
      cat("               \r",paste0(Sys.time(),": remaining loops: ",ncol(data)-(i)))
    }else{
      dur <-  round((as.integer(format(Sys.time(),"%s"))-st)/60,2)
      cat("               \r",paste0(Sys.time(),": remaining loops: ",ncol(data)-(i),"   |   duration last loop: ",dur," minutes        "))
    }

    st <- as.integer(format(Sys.time(),"%s"))
    ranger_submod <- do.call(ranger::ranger,dots)
    nvariables <- ncol(dots$x)
    least.importance <- names(sort(ranger_submod$variable.importance))[1]   #evaluate least-important variable
    dots$x <- dots$x[colnames(dots$x)!=least.importance]                #remove least-important variable

    ### calculate submod-metrics
    cm_1 <- caret::confusionMatrix((ranger_submod[["predictions"]]),ranger_submod[["call"]][["y"]])
    OA <- round(cm_1$overall[1],3)
    kappa <- round(cm_1$overall[2],3)

    ### bind metrics
    if(i==1){
      OOB_OA <- data.frame(cbind(i,OA,kappa,least.importance,nvariables))
    }else{
      OOB_OA <- rbind(OOB_OA,cbind(i,OA,kappa,least.importance,nvariables))
    }
    if(i==ncol(data)-1){
      colnames(OOB_OA) <- c("loopID","oobOA","kappa","least_imp","nvariables")
      OOB_OA$loopID <- as.numeric(OOB_OA$loopID)
      OOB_OA$oobOA <- as.numeric(OOB_OA$oobOA)
      OOB_OA$kappa <- as.numeric(OOB_OA$kappa)
      OOB_OA$nvariables <- as.numeric(OOB_OA$nvariables)
    }

    ### export submodel
    save(ranger_submod,
         file = sprintf(paste0("%s/%s_fs_%s_classif_%0",N,"d.Rdata"),
                        savedir,savename,rf_type,(ncol(data))-(i)))

    if(i==(ncol(data)-1)){
      dur <-  round((as.integer(format(Sys.time(),"%s"))-st)/60,2)
      cat("               \r",paste0(Sys.time(),": remaining loops: 0   |    duration last loop: ",dur," minutes                      "))
    }
  }

  ### evaluate fittest model and copy as best-file
  best_qu <- quantile(OOB_OA$oobOA, probs = best_thr)
  fittest.models <- subset(OOB_OA,OOB_OA$oobOA > best_qu)
  fittest.model <- subset(fittest.models,fittest.models$nvariables == min(fittest.models$nvariables))

  file.copy(sprintf(paste0("%s/%s_fs_%s_classif_%0",N,"d.Rdata"),
                    savedir,savename,rf_type,as.integer(fittest.model$nvariables)),
            sprintf(paste0("%s/%s_fs_%s_classif_","fittest.Rdata"),
                    savedir,savename,rf_type),overwrite = TRUE)

  ### evaluate best model and copy as best-file
  best.model <- subset(subset(OOB_OA,OOB_OA$oobOA==max(OOB_OA$oobOA)),
                       subset(OOB_OA,OOB_OA$oobOA==max(OOB_OA$oobOA))$nvariables==min(subset(OOB_OA,OOB_OA$oobOA==max(OOB_OA$oobOA))$nvariables))

  file.copy(sprintf(paste0("%s/%s_fs_%s_classif_%0",N,"d.Rdata"),
                    savedir,savename,rf_type,as.integer(best.model$nvariables)),
            sprintf(paste0("%s/%s_fs_%s_classif_","best.Rdata"),
                    savedir,savename,rf_type),overwrite = TRUE)

  ### calculate fittest models metrics
  load(sprintf(paste0("%s/%s_fs_%s_classif_","fittest.Rdata"),
               savedir,savename,rf_type))
  fittest.ranger <- ranger_submod

  cm1.fittest <- caret::confusionMatrix((fittest.ranger[["predictions"]]),fittest.ranger[["call"]][["y"]])
  cm2.fittest <- as.data.frame(as.matrix(cm1.fittest))
  acc.fittest <- round(cm1.fittest$overall[1],3)
  kappa.fittest <- round(cm1.fittest$overall[2],3)
  pa.fittest <- as.numeric(round(t(cm1.fittest$byClass[,'Sensitivity']),3))
  ua.fittest <- round(cm1.fittest$byClass[,'Pos Pred Value'],3)
  ua.fittest[length(pa.fittest)+1] <- acc.fittest
  cm2.fittest <- rbind(cm2.fittest,pa.fittest)
  cm2.fittest <- cbind(cm2.fittest,ua.fittest)
  colnames(cm2.fittest)[ncol(cm2.fittest)] <- "UA"
  rownames(cm2.fittest)[nrow(cm2.fittest)] <- "PA"

  ### calculate best models metrics
  load(sprintf(paste0("%s/%s_fs_%s_classif_","best.Rdata"),
               savedir,savename,rf_type))
  best.ranger <- ranger_submod

  cm1.best <- caret::confusionMatrix((best.ranger[["predictions"]]),best.ranger[["call"]][["y"]])
  cm2.best <- as.data.frame(as.matrix(cm1.best))
  acc.best <- round(cm1.best$overall[1],3)
  kappa.best <- round(cm1.best$overall[2],3)
  pa.best <- as.numeric(round(t(cm1.best$byClass[,'Sensitivity']),3))
  ua.best <- round(cm1.best$byClass[,'Pos Pred Value'],3)
  ua.best[length(pa.best)+1] <- acc.best
  cm2.best <- rbind(cm2.best,pa.best)
  cm2.best <- cbind(cm2.best,ua.best)
  colnames(cm2.best)[ncol(cm2.best)] <- "UA"
  rownames(cm2.best)[nrow(cm2.best)] <- "PA"

  ### export fittest models data
  write.csv2(cm2.fittest,sprintf(paste0("%s/%s_fs_%s_classif_","fittest_cm.csv"),
                                 savedir,savename,rf_type))

  write.csv2(fittest.model,sprintf(paste0("%s/%s_fs_%s_classif_","fittest_metrics.csv"),
                                   savedir,savename,rf_type))

  ### export best models data
  write.csv2(cm2.best,sprintf(paste0("%s/%s_fs_%s_classif_","best_cm.csv"),
                              savedir,savename,rf_type))

  write.csv2(best.model,sprintf(paste0("%s/%s_fs_%s_classif_","best_metrics.csv"),
                                savedir,savename,rf_type))

  ### remove files
  if(keep.files==F){
    cat("               \n",paste0(Sys.time(),": removing submodels   |                                                                 "))
    file.remove(list.files(savedir,pattern=".Rdata",full.names = TRUE)[-c(grep("fittest",list.files(savedir,pattern=".Rdata",full.names = TRUE)),grep("best",list.files(savedir,pattern=".Rdata",full.names = TRUE)))])
  }

  ### plot graph
  plot(OOB_OA$oobOA~OOB_OA$nvariables,type="l",main="recursive MDA-feature selection",xlab="nVariables",ylab="OOB-OA",col="red3",lwd="2")
  if(fittest.model$loopID!=best.model$loopID){
    abline(v=fittest.model$nvariables,col="blue3",lwd=1,lty=2)
    abline(v=best.model$nvariables,col="green3",lwd=1,lty=2)
    abline(h=fittest.model$oobOA,col = "blue3",lwd=1,lty=2)
    abline(h=best.model$oobOA,col = "green3",lwd=1,lty=2)
    legend("bottomright",legend=c("fittest model","best model"),col=c("blue3","green3"),lwd=1,lty=2,cex=0.8)
  }else{
    abline(v=fittest.model$nvariables,col="blue3",lwd=1,lty=2)
    abline(h=fittest.model$oobOA,col = "blue3",lwd=1,lty=2)
    legend("bottomright",legend=c("fittest/best model"),col=c("blue3"),lwd=1,lty=2,cex=0.8)
  }

  if(length(fittest.ranger[["variable.importance"]])>nimpplot){
    plot.varimp.fittest <- nimpplot
  }else{
    plot.varimp.fittest <- length(fittest.ranger[["variable.importance"]])
  }
  fittest.varimpplot <- vip::vip(fittest.ranger,num_features = plot.varimp.fittest,horizontal = T,geom = "point",aesthetics = list(size = 2))

  if(length(best.ranger[["variable.importance"]])>nimpplot){
    plot.varimp.best <- nimpplot
  }else{
    plot.varimp.best <- length(best.ranger[["variable.importance"]])
  }
  best.varimpplot <- vip::vip(best.ranger,num_features = plot.varimp.best,horizontal = T,geom = "point",aesthetics = list(size = 2))

  dur.featsel <- round((as.integer(format(Sys.time(),"%s"))-st.featsel)/60,2)
  cat("               \n",paste0(Sys.time(),": run completed","        |    duration of run:     ",dur.featsel," minutes             \n\n\n"))

  cat(paste0("fittest model: OOB-OA = ",fittest.model$oobOA,"; Kappa = ",fittest.model$kappa,"; nVariables = ",fittest.model$nvariables,"\n"))
  print(cm2.fittest)

  cat(paste0("\n\nbest model:    OOB-OA = ",best.model$oobOA,"; Kappa = ",best.model$kappa,"; nVariables = ",best.model$nvariables,"\n"))
  print(cm2.best)

  if(fittest.model$loopID==best.model$loopID){
    cat("\nCOMMENT: fittest model and best model are equal")
  }

  return(list(OOB_OA=OOB_OA,ranFeatsel.fittest=fittest.ranger,ranFeatsel.best=best.ranger,cm.fittest=cm2.fittest,cm.best=cm2.best,fittest.model.metrics=fittest.model,best.model.metrics=best.model,fittest.varimpplot=fittest.varimpplot,best.varimpplot=best.varimpplot))
}
