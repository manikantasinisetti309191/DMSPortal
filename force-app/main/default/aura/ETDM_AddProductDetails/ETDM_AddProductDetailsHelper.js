({
    doInit : function(component, event, helper) {
        
        var utility = component.find("ETDM_UtilityMethods");
        var backendMethod = "getETDMData";
         var params = {
            //"activeFlag" : 'Active'
        };
        var promise = utility.executeServerCall(component, backendMethod, params);
        
        promise.then (
            $A.getCallback(function(response) {
                component.set('v.categoryTypes',response.categoryTypes);
                component.set('v.weightTypes',response.weightTypes);
                component.set('v.sizeTypes',response.sizeTypes);
                component.set('v.record.ETDM_Category__c',response.categoryTypes[0]);
                component.set('v.record.ETDM_Weight__c',response.weightTypes[0]); 
                component.set('v.record.ETDM_Size__c',response.sizeTypes[0]); 
            }),
            
            $A.getCallback(function(error) {
                var err = JSON.parse(error);
                var errorToShow = utility.convertToUserFriendlyErrMsg(err.MESSAGE);
                utility.showToast("Delivery Management", errorToShow, "error", "dismissible");
            })
        )	
    },
})