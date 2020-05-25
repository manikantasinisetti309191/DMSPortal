({
    doInit: function(component, event, helper) {
       // Prepare a new record from template
        component.find("CaseRecordCreator").getNewRecord(
            "Case", // sObject type (objectApiName)
            null,      // recordTypeId
            false,     // skip cache?
            $A.getCallback(function() {
                var rec = component.get("v.newCase");
                var error = component.get("v.newCaseError");
                if(error || (rec === null)) {
                    console.log("Error initializing record template: " + error);
                    return;
                }
                console.log("Record template initialized: " + rec.apiName);
            })
        );
    },
    closeModel: function(component, event, helper) {
        component.set("v.isReportModal",false);
    },
    handleSaveCase: function(component, event, helper) {
        component.set('v.loaded', !component.get('v.loaded'));
        var woId=component.get("v.workOrderId");
        if(helper.validateCaseForm(component)) {
            console.log('enterd');
            component.set("v.simpleNewCase.AccountId", component.get("v.recordId"));
            component.set("v.simpleNewCase.ETDM_Work_Order__c", woId);
            component.set("v.simpleNewCase.Origin", 'Web');
            component.set("v.simpleNewCase.Status", 'New');
             component.find("CaseRecordCreator").saveRecord(function(saveResult) {
                if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                    component.set("v.isReportModal",false);
                    component.set('v.loaded', !component.get('v.loaded'));
                    $A.get('e.force:refreshView').fire();
                    // record is saved successfully
                    var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "title": "Saved",
                        "message": "The record was saved."
                    });
                    resultsToast.fire();
                    
                } else if (saveResult.state === "INCOMPLETE") {
                    // handle the incomplete state
                    console.log("User is offline, device doesn't support drafts.");
                } else if (saveResult.state === "ERROR") {
                    // handle the error state
                    console.log('Problem saving Case, error: ' + JSON.stringify(saveResult.error));
                } else {
                    console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
                }
            });
        }else{
            console.log('enterd else');
            
        }
    },
    openSuggestionForm: function(component, event, helper) {
        component.set("v.simpleNewCase.Subject", 'Suggestion');
        $A.util.addClass(component.find("feedbackForm"), "slds-hide");
        $A.util.removeClass(component.find("Suggestion"), "slds-hide");
        $A.util.addClass(component.find("Bug"), "slds-hide");
        $A.util.addClass(component.find("compliment"), "slds-hide");
        $A.util.addClass(component.find("complaint"), "slds-hide");
    },openBugForm: function(component, event, helper) {
        component.set("v.simpleNewCase.Subject", 'Bug');
        $A.util.addClass(component.find("feedbackForm"), "slds-hide");
        $A.util.addClass(component.find("Suggestion"), "slds-hide");
        $A.util.removeClass(component.find("Bug"), "slds-hide");
        $A.util.addClass(component.find("compliment"), "slds-hide");
        $A.util.addClass(component.find("complaint"), "slds-hide");
    },openComplimentForm: function(component, event, helper) {
        component.set("v.simpleNewCase.Subject", 'Compliment');
        $A.util.addClass(component.find("feedbackForm"), "slds-hide");
        $A.util.addClass(component.find("Suggestion"), "slds-hide");
        $A.util.addClass(component.find("Bug"), "slds-hide");
        $A.util.removeClass(component.find("compliment"), "slds-hide");
        $A.util.addClass(component.find("complaint"), "slds-hide");
    },
    openComplaintForm: function(component, event, helper) {
        component.set("v.simpleNewCase.Subject", 'Complaint');
        $A.util.addClass(component.find("feedbackForm"), "slds-hide");
        $A.util.addClass(component.find("Suggestion"), "slds-hide");
        $A.util.addClass(component.find("Bug"), "slds-hide");
        $A.util.addClass(component.find("compliment"), "slds-hide");
        $A.util.removeClass(component.find("complaint"), "slds-hide");
    },
    goToFeedbackForm: function(component, event, helper) {
        component.set("v.simpleNewCase.Subject", component.get("v.recordId"));
        $A.util.removeClass(component.find("feedbackForm"), "slds-hide");
        $A.util.addClass(component.find("Suggestion"), "slds-hide");
        $A.util.addClass(component.find("Bug"), "slds-hide");
        $A.util.addClass(component.find("compliment"), "slds-hide");
        $A.util.addClass(component.find("complaint"), "slds-hide");
    },
    
    //  }
})