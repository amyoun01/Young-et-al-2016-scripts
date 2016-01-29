aucroc <- function(pres,abs,n){
  
  # ALLOCATE SPACE TO STORE RESULTS
  TPR <- matrix(NA,n,1) 
  FPR <- matrix(NA,n,1) 
  TNR <- matrix(NA,n,1) 
  FNR <- matrix(NA,n,1) 
  
  thresh <- seq(1,0,-(1/(n-1))) # SET PROBABILITY THRESHOLDS TO CALCULATE 
                                # ROC VALUES
  
  for (i in 1:length(thresh)){ # FOR EACH THRESHOLD VALUE...
    
    p_i <- pres # SET PROBABILITY VALUES FOR OBSERVED PRESENCES TO THE VARIALE 'PRES'
    p_i[p_i >= thresh[i]] <- 1 # FOR ALL PROBABILITY VALUES GREATER THAN CURRENT THRESHOLD SET EQUAL TO 1
    p_i[p_i < thresh[i]] <- 0 # FOR ALL PROBABILITY VALUES LESS THAN CURRENT THRESHOLD SET EQUALT TO 0
    
    a_i <- abs
    a_i[a_i<=thresh[i]] <- 1.0001 # FOR PROBABILITY VALUES FOR OBSERVED 
                                  # ABSENCES LESS THAN CURRENT THRESHOLD
                                  # SET EQUAL TO 1.0001. sETTING IT EQUAL
                                  # TO 1.0001 ALLOWED ME TO SET OBSERVED
                                  # ABSENCE PROBABILITIES GREATER THAN 0
                                  # AND LESS THAN OR EQUAL TO 1 TO A VALUE
                                  # OF ZERO. THIS IS NECESSARY BECAUSE IT 
                                  # IS POSSILBE TO GET A PREDICTED PROBABILITY
                                  # VALUE VERY CLOSE TO (OR EQUAL TO DEPENDING ON ROUNDING)
                                  # A VALUE OF 1.
    a_i[a_i > thresh[i] & a_i < 1.0001] <- 0
    a_i[a_i == 1.0001] <- 1
    
    TPR[i,1] <- sum(p_i)/length(pres)     # CALCULATE TRUE POSITIVE RATE (SPECIFICITY)
    FPR[i,1] <- 1-(sum(a_i)/length(abs))  # CALCULATE FALSE POSITIVE RATE (OMMISSION)
    FNR[i,1] <- 1-(sum(p_i)/length(pres)) # CALCULATE FALSE NEGATIVE RATE(COMMISSION)
    TNR[i,1] <- sum(a_i)/length(abs)      # CALCULATE TRUE NEGATIVE RATE (SENSITIVITY)
  }
  
  # Calculate Area Under the Curve using the trapezoid rule
  idx <- 2:n # START ON SECOND VALUE, CAN'T CALCULATE AREA UNDER THE CURVE
            # FOR 1 VALUE.
  AUC <- as.double((FPR[idx] - FPR[idx - 1]) %*% (TPR[idx] + TPR[idx - 1]))/2

  # RETURN VALUES
  return(list(TPR=TPR,FPR=FPR,FNR=FNR,TNR=TNR,AUC=AUC,thresh=thresh))
  
}