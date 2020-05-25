({
    doInit : function(component, event, helper)  {
        var utility = component.find("ETDM_UtilityMethods");
        var backendMethod = "getCaseHistory";
        var params = {
            
        };
        var promise = utility.executeServerCall(component, backendMethod, params);
        
        promise.then (
            $A.getCallback(function(response) {
                component.set('v.caseList',response);
            }),
            
            $A.getCallback(function(error) {
                var err = JSON.parse(error);
                var errorToShow = utility.convertToUserFriendlyErrMsg(err.MESSAGE);
                utility.showToast("School Tranport", errorToShow, "error", "dismissible");
            })
        )	
    }
    })