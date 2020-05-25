({
	doInit : function(component, event, helper) {
        
        var utility = component.find("ETDM_UtilityMethods");
        var backendMethod = "getDashboardData";
         var params = {
        };
        var promise = utility.executeServerCall(component, backendMethod, params);
        
        promise.then (
            $A.getCallback(function(response) {
			 component.set('v.totalCount',response.activeCount+response.deliveredCount+response.cancelledCount+response.onHoldCount); 
			 component.set('v.activeCount',response.activeCount); 
			 component.set('v.deliveredCount',response.deliveredCount); 
			 component.set('v.cancelledCount',response.cancelledCount); 
			 component.set('v.onHoldCount',response.onHoldCount); 
            }),
            
            $A.getCallback(function(error) {
                var err = JSON.parse(error);
                var errorToShow = utility.convertToUserFriendlyErrMsg(err.MESSAGE);
                utility.showToast("Delivery Management", errorToShow, "error", "dismissible");
            })
        )	
    },
})