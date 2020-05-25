({
    doInit : function(component, event, helper) {
        
        var utility = component.find("ETDM_UtilityMethods");
        var backendMethod = "getDriverDetails";
         var params = {
            "workOrderId" : component.get('v.workOrderId')
        };
        var promise = utility.executeServerCall(component, backendMethod, params);
        
        promise.then (
            $A.getCallback(function(response) {
             component.set('v.driverList',response);
			
            }),
            
            $A.getCallback(function(error) {
                var err = JSON.parse(error);
                var errorToShow = utility.convertToUserFriendlyErrMsg(err.MESSAGE);
                utility.showToast("Delivery Management", errorToShow, "error", "dismissible");
            })
        )	
    } 
    
    })