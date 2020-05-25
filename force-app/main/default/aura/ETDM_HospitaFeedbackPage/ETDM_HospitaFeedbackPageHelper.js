({
    validateCaseForm : function(component) {
      component.set("v.simpleNewCase.Description", component.get("v.caseRecord.Description"));
         
      if(component.get("v.simpleNewCase.Description")=='' ||
               component.get("v.simpleNewCase.Description")==null){
         		$A.util.removeClass(component.find("mandatoryCheck1"), "slds-hide");
                $A.util.removeClass(component.find("mandatoryCheck2"), "slds-hide");
          		$A.util.removeClass(component.find("mandatoryCheck3"), "slds-hide");
          		$A.util.removeClass(component.find("mandatoryCheck4"), "slds-hide");
                return false;
          }
        
       var Subject= component.get("v.simpleNewCase.Subject");
        
        if(Subject=='Suggestion'){
            component.set("v.simpleNewCase.ETDM_Suggestion_Type__c", component.get("v.caseRecord.ETDM_Suggestion_Type__c"));
       
            if(component.get("v.caseRecord.ETDM_Suggestion_Type__c")=='' ||
               component.get("v.caseRecord.ETDM_Suggestion_Type__c")==null){
                 $A.util.removeClass(component.find("mandatoryCheck1"), "slds-hide");
                return false;
            }
        }else if(Subject=='Bug'){
            component.set("v.simpleNewCase.ETDM_Steps_to_Reproduce__c", component.get("v.caseRecord.ETDM_Steps_to_Reproduce__c"));
       
            if(component.get("v.caseRecord.ETDM_Steps_to_Reproduce__c")=='' ||
               component.get("v.caseRecord.ETDM_Steps_to_Reproduce__c")==null){
                $A.util.removeClass(component.find("mandatoryCheck2"), "slds-hide");
                return false;
            }
             
        }else if(Subject=='Compliment'){
             component.set("v.simpleNewCase.ETDM_Rating__c", component.get("v.caseRecord.ETDM_Rating__c"));
       
            if(component.get("v.caseRecord.ETDM_Rating__c")=='' ||
               component.get("v.caseRecord.ETDM_Rating__c")==null){
                $A.util.removeClass(component.find("mandatoryCheck3"), "slds-hide");
                return false;
            }
             
        }else if(Subject=='Complaint'){
            component.set("v.simpleNewCase.ETDM_Complaint_Type__c", component.get("v.caseRecord.ETDM_Complaint_Type__c"));
             if(component.get("v.caseRecord.ETDM_Complaint_Type__c")=='' ||
               component.get("v.caseRecord.ETDM_Complaint_Type__c")==null){
                  $A.util.removeClass(component.find("mandatoryCheck4"), "slds-hide");
                return false;
            }
        }
        return true;
    }
})