({
    doInit : function(component, event, helper) {
        var utility = component.find("ETDM_UtilityMethods");
        var backendMethod = "getUserDetails";
         var params = {
            //"status" : component.get('v.status')
        };
        var promise = utility.executeServerCall(component, backendMethod, params);
        
        promise.then (
            $A.getCallback(function(response) {
             component.set('v.hospitalName',response.accountRecord.Name);
             component.set('v.hospitalId',response.accountRecord.Id);
             component.set('v.isPartner',response.isPartner);
            }),
            
            $A.getCallback(function(error) {
                var err = JSON.parse(error);
                var errorToShow = utility.convertToUserFriendlyErrMsg(err.MESSAGE);
                utility.showToast("Delivery Management", errorToShow, "error", "dismissible");
            })
        )	
    }
})