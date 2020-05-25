({
    saveContact : function(component, event, helper) {
        console.log('record updating...');
        component.set("v.simpleRecord.Status", 'Canceled'); 
       component.find("recordHandler").saveRecord($A.getCallback(function(saveResult) {
                // use the recordUpdated event handler to handle generic logic when record is changed
                if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                    // handle component related logic in event handler
                    var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "mode": 'dismissible',
                            "type":"success",
                            "title": "Success!",
                            "message": "The request is cancelled!"
                        });
                        toastEvent.fire();
                    
                } else if (saveResult.state === "INCOMPLETE") {
                    console.log("User is offline, device doesn't support drafts.");
                } else if (saveResult.state === "ERROR") {
                    console.log('Problem saving record, error: ' + JSON.stringify(saveResult.error));
                } else {
                    console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
                }
            }));
       
        $A.get('e.force:refreshView').fire(); 
    }   
    
    })