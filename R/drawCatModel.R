#'Adjust y position
#'@param ypos y position
#'@param ymargin verical margin of plot
#'@param rady vertical radius of the box
#' @param maxypos maximal y position of X or W variables
#' @param minypos minimal y position of X or W variables
adjustypos=function(ypos,ymargin=0.02,rady=0.06,maxypos=0.6,minypos=0){
    yinterval=ymargin+2*rady
    starty=minypos+ymargin+rady
    yinterval=max((maxypos-starty)/(max(ypos)-1),yinterval)
    ifelse(ypos<1,ypos,starty+(ypos-1)*yinterval)
}

#' Draw statistical diagram with list of lm result
#' @param fit list of lm object
#' @param labels list of variable names
#' @param nodelabels list of nodes names
#' @param whatLabel What should the edge labels indicate in the path diagram? Choices are c("est","name")
#' @param xmargin horizontal margin between nodes
#' @param radx horizontal radius of the box.
#' @param ymargin vertical margin between nodes
#' @param xlim the x limits (min,max) of the plot
#' @param ylim the y limits (min,max) of the plot
#' @param rady vertical radius of the box.
#' @param maxypos maximal y position of X or W variables
#' @param minypos minimal y position of X or W variables
#' @param ypos  The x and y position of Y node. Default value is c(1,0.5)
#' @param mpos The x and y position of M node. Default value is c(0.5,0.9)
#' @param digits integer indicating the number of decimal places
#' @param xinterval numeric. Horizontal intervals among labels for nodes and nodes
#' @param yinterval numeric. Vertical intervals among labels for nodes and nodes
#' @param xspace numeric. Horizontal distance bewteen nodes
#' @param label.pos Optional list of arrow label position
#' @export
#' @examples
#' labels=list(X="protest",W="sexism",M="respappr",Y="liking")
#' moderator=list(name="sexism",site=list(c("a","c")))
#' data1=addCatVars(protest,"protest",mode=3)
#' eq=catMediation(X="protest",M="respappr",Y="liking",moderator=moderator,data=protest,maxylev=6,mode=1)
#' fit=eq2fit(eq,data=data1)
#' modelsSummary2(fit,labels=labels)
#' nodelabels=list(D1="Ind.Protest",D2="Col.Protest",W="sexism",M="respappr",Y="liking")
#' drawCatModel(fit,labels=labels,nodelabels=nodelabels,whatLabel="name",xlim=c(-0.3,1.3))
#' drawCatModel(fit,labels=labels)
#' labels=list(X="protest",W="sexism",M="respappr",Y="liking")
#' fit=makeCatModel(labels=labels,data=protest)
#' drawCatModel(fit,labels=labels,nodelabels=nodelabels,radx=0.08,xinterval=0.18,label.pos=list(a5=0.3))
#' drawCatModel(fit,labels=labels,whatLabel="name",maxypos=0.6,minypos=0.2)
drawCatModel=function(fit,labels=NULL,nodelabels=NULL,whatLabel="est",
                      xmargin=0.01,radx=0.12,
                      ymargin=0.02,xlim=c(-0.2,1.2),ylim=xlim,
                   rady=0.04,maxypos=0.6,minypos=0,ypos=c(1,0.5),mpos=c(0.5,0.9),
                   xinterval=NULL,yinterval=NULL,xspace=NULL,label.pos=list(),
                   digits=3){

    # whatLabel="name";xmargin=0.01;radx=0.12
    # ymargin=0.02
    # rady=0.04;maxypos=0.6;minypos=0;digits=3

    if("lm" %in%  class(fit)) fit=list(fit)
    fitcount=length(fit)
    df1=as.data.frame(summary(fit[[1]])$coef[-1,])
    df1$label=rownames(df1)
    if(!is.null(labels)) df1$label=changeLabelName(rownames(df1),labels,add=FALSE)
    names(df1)[4]="p"
    df1$lty=ifelse(df1$p<0.05,1,2)
    df1$name=paste0("a",1:nrow(df1))
    df1$start=df1$label
    df1$end=ifelse(fitcount==1,"Y","M")
    df1$est=round(df1$Estimate,digits)
    count=length(df1$label)

    if(fitcount>1){
    df2=as.data.frame(summary(fit[[2]])$coef[-1,])
    df2$label=rownames(df2)
    if(!is.null(labels)) df2$label=changeLabelName(rownames(df2),labels,add=FALSE)
    names(df2)[4]="p"
    df2$lty=ifelse(df2$p<0.05,1,2)
    df2$name=""
    ccount=length(df2$label[df2$label!="M"])
    df2$name[df2$label=="M"]="b"
    df2$name[df2$label!="M"]=paste0("c",1:ccount)
    df2$start=df2$label
    df2$end="Y"

    df2$est=round(df2$Estimate,digits)
    df2
    }

    name=c("Y","M",df1$label)
    nodes=data.frame(name=name,stringsAsFactors = FALSE)
    nodes$xpos=c(ypos[1],mpos[1],rep(0,count%/%2),0.05,(1:(1+count%/%2-1))/10)
    nodes$ypos=c(ypos[2],mpos[2],((2+count%/%2):3),2,rep(1,count%/%2))
    # nodes$xpos1=adjustxpos(nodes$xpos,xmargin=xmargin,radx=radx)
    nodes$ypos=adjustypos(nodes$ypos,ymargin=ymargin,rady=rady,
                          maxypos=maxypos,minypos=minypos)

    if(fitcount==1) {
        nodes=nodes[-2,]
        arrows=df1
    } else{
       arrows=rbind(df1,df2)
    }
    arrows$labelpos=0.5
    arrows$arrpos=0.8
    arrows$no=1
    arrows$label1=arrows$label
    if(whatLabel=="name") {
        arrows$label=arrows$name
        addprime=TRUE
    } else{
        arrows$label=arrows$est
        addprime=FALSE
    }

    nodes
    arrows
    openplotmat(xlim=xlim,ylim=ylim)


    for(i in 1:nrow(arrows)){
        temppos=arrows$labelpos[i]
        if(!is.null(label.pos[[arrows$name[i]]])) temppos=label.pos[[arrows$name[i]]]
        myarrow2(nodes, from=arrows$start[i],to=arrows$end[i],
                 label=arrows$label[i],no=arrows$no[1],xmargin=xmargin,radx=radx,rady=rady,
                 label.pos=temppos,arr.pos=NULL,lty=arrows$lty[i],addprime=addprime,xspace=xspace)
    }

    for(i in 1:nrow(nodes)){
        xpos=nodes$xpos[i]
        xpos=adjustxpos(xpos,xmargin,radx,xspace=xspace)
        mid=c(xpos,nodes$ypos[i])

        label=nodes$name[i]

        drawtext(mid,radx=radx,rady=rady,lab=label,latent=FALSE)
        if(!is.null(nodelabels[[label]])) {
            if(is.null(yinterval)) yinterval=2*rady+ymargin
            if(is.null(xinterval)) xinterval=2*radx
            if(mid[2]<=rady+ymargin){
                newmid=mid-c(0,yinterval)
            } else if(mid[2]>=0.9){
                newmid=mid+c(0,yinterval)
            } else if(mid[1]>0.85){
                newmid=mid+c(xinterval,0)
            } else{
                newmid=mid-c(xinterval,0)
            }
            textplain(mid=newmid,lab=nodelabels[[label]])
        }
    }

}
