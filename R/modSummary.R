#' Make moderation effect summary
#' @param fit An object of class lavaan
#' @param mod name of moderatot variable
#' @param values optional values of moderator
#' @param boot.ci.type Type of bootstrapping interval. Choices are c("norm","basic","perc",bca.simple")
#' @export
#' @examples
#' require(lavaan)
#' labels=list(X="frame",W="skeptic",Y="justify")
#' moderator=list(name='skeptic',site=list("c"))
#' model=tripleEquation(labels=labels,moderator=moderator,data=disaster,rangemode=2)
#' semfit=sem(model=model,data=disaster,se="boot",bootstrap=10)
#' \donttest{
#' modSummary(semfit,mod="skeptic")
#' modSummaryTable(semfit,mod="skeptic")
#' }
modSummary=function(fit,mod="skeptic",values=NULL,boot.ci.type="bca.simple"){
    # fit=semfit;mod="skeptic";values=NULL;boot.ci.type="bca.simple"
    res=parameterEstimates(fit,boot.ci.type = boot.ci.type,
                           level = .95, ci = TRUE,
                           standardized = FALSE)
    res=res[res$label!="",]
    res
    if(is.null(values)){
        # values1=res$est[res$label==paste0(mod,".mean")]+c(0,-1,1)*sqrt(res$est[res$label==paste0(mod,".var")])
        values1=extractRange(res,mod=mod,what="direct")
        values1
    } else{
        values1=values
    }
    # select=c("indirect","indirect.below","indirect.above")
    # indirect=res$est[which(res$lhs %in% select)]
    # lower=res$ci.lower[which(res$lhs %in% select)]
    # upper=res$ci.upper[which(res$lhs %in% select)]
    # indirectp=res$pvalue[which(res$lhs %in% select)]
    select=c("direct","direct.below","direct.above")
    direct=res$est[which(res$lhs %in% select)]
    lowerd=res$ci.lower[which(res$lhs %in% select)]
    upperd=res$ci.upper[which(res$lhs %in% select)]
    #
    # se=res$se[which(res$lhs %in% select)]
    directp=res$p[which(res$lhs %in% select)]

    df=data.frame(values=values1,direct,lowerd,upperd,directp)
    df=df[c(2,1,3),]
    df[]=round(df,3)
    attr(df,"mod")=mod

    if(is.null(values)) {

        direct=res$rhs[res$lhs=="direct"]
        if(str_detect(direct,".mean")){
        direct=str_replace(direct,paste0(mod,".mean"),"W")
        } else{
            temp=unlist(strsplit(direct,"*",fixed=TRUE))
            direct=paste0(temp[1],"*W")
        }

    } else{
        direct=res$rhs[res$lhs=="direct"]
        direct=str_replace(direct,paste0(values[1]),"W")
    }

    attr(df,"direct")=direct
    attr(df,"direct2")=paste0(sprintf("%0.3f",res$est[res$label=="c1"]),
                ifelse(res$est[res$label=="c3"]>=0," + "," - "),
                sprintf("%0.3f",abs(res$est[res$label=="c3"])),"*W")
    attr(df,"boot.ci.type")=boot.ci.type
    class(df)=c("modSummary","data.frame")
    df
}


#'S3 method of class modSummary
#'@param x An object of class modSummary
#'@param ... Further arguments to be passed to print
#'@export
print.modSummary=function(x,...){
    count=nrow(x)
    x[]=lapply(x,myformat)

    x[[5]]=pformat(x[[5]])

    mod=paste0(attr(x,"mod"),"(W)")
    direct=attr(x,"direct")
    left=max(nchar(mod)+2,8)
    total=40+left

    cat("\nInference for the Moderation Effects\n")
    cat(paste(rep("=",total),collapse = ""),"\n")
    cat(centerPrint("",left),centerPrint("Moderation Effect",35),"\n")
    cat(centerPrint("",left),
        centerPrint(paste0(attr(x,"direct")," = ",attr(x,"direct2")),35),"\n")
    cat(centerPrint("",left),paste(rep("-",39),collapse = ""),"\n")

    cat(centerPrint(mod,left),centerPrint("estimate",11),
        centerPrint("95% Bootstrap CI",18),centerPrint("p",8),"\n")
    cat(paste(rep("-",total),collapse = ""),"\n")
    for(i in 1:count){
        cat(rightPrint(x[i,1],left-1),"")
        cat(rightPrint(x[i,2],11))
        cat(paste0(rightPrint(x[i,3],8)," to ",rightPrint(x[i,4],6)))
        cat(rightPrint(x[i,5],8),"\n")
    }
    cat(paste(rep("=",total),collapse = ""),"\n")
    cat(rightPrint(paste0("boot.ci.type:",attr(x,"boot.ci.type"),"\n"),total),"\n")
}

#' Make flextable summarizing moderation effect
#' @param x An object
#' @param vanilla logical
#' @param ... Further argument to be passed to modSummary
#' @importFrom flextable add_footer_lines
#' @export
modSummaryTable=function(x,vanilla=TRUE,...){
    if("lavaan" %in% class(x)) x=modSummary(x,...)
      # x=modSummary(semfit,mod="skeptic");vanilla=TRUE

    x[]=lapply(x,myformat)

    colnames(x)[1]=paste0(attr(x,"mod"),"(W)")
    colnames(x)[2]="estimate"
    colnames(x)[5]="p"
    x[[5]]=pformat(x[[5]])
    x[["CI"]]=paste0(x$lowerd," to ",x$upperd)
    x1=x[c(1,2,6,5)]
    colnames(x1)[3]="95% Bootstrap CI"

    rrtable::df2flextable(x1,vanilla=vanilla,digits=3) %>%
        add_footer_lines(attr(x,"eq")) %>%
        align(align="right",part="footer") %>%
        hline_top(part="header",border=fp_border(color="black",width=0)) %>%
        add_header_row(values=c("",paste0(attr(x,"direct")," = ",attr(x,"direct2"))),colwidths=c(1,3)) %>%
        add_header_row(values=c("","Moderation Effect"),colwidths=c(1,3)) %>%
        width(j=3,width=2) %>%
        align(i=1:2,align="center",part="header") %>%
        add_footer_lines(paste0("boot.ci.type=",attr(x,"boot.ci.type"))) %>%
        align(align="right",part="footer") %>%
        fontsize(size=12,part="all") %>%
        hline(part="header",i=2,j=2:4,border=fp_border(color="black",width=1)) %>%
        hline_top(part="header",border=fp_border(color="black",width=2))


}


