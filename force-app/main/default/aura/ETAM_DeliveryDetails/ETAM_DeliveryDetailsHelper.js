({
    doInit : function(component, event, helper) {
        
        var utility = component.find("ETDM_UtilityMethods");
        var backendMethod = "getDeliveryRequestsData";
         var params = {
            "status" : component.get('v.status')
        };
        var promise = utility.executeServerCall(component, backendMethod, params);
        
        promise.then (
            $A.getCallback(function(response) {
             component.set('v.deliveryData',response);
                console.log('response ='+JSON.stringify(response));
                var corousalSize=component.get('v.corousalSize'); 
                component.set('v.currentData',response.slice(0,corousalSize)); 
                console.log('currentData ='+response.slice(0,corousalSize));
                component.set('v.totalRecords',response.length);  
                component.set('v.RecordsCount',response.length);
                component.set('v.loaded', !component.get('v.loaded'));
            }),
            
            $A.getCallback(function(error) {
                var err = JSON.parse(error);
                var errorToShow = utility.convertToUserFriendlyErrMsg(err.MESSAGE);
                utility.showToast("Delivery Management", errorToShow, "error", "dismissible");
            })
        )	
    }
})