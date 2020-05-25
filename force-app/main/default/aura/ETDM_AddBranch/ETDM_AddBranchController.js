({
	closeModel: function(component, event, helper) {
        component.set("v.addBranchModal",false);
    },
    selectOption:function(component, event, helper) {
        console.log('---selectOption---');
        helper.getAddressDetailsByPlaceId(component, event);
    },
    getBranchLocation: function(component, event, helper) {
         var searchText=component.get("v.branchAddress");
         helper.getAddressRecommendations(component,event,searchText);
    },
    handleSaveAccount: function(component, event, helper) {
        component.set("v.accountRecord.ParentId", component.get("v.hospitalId"));
        component.set('v.accountRecord.Name',component.get('v.accountRecord.Name').trim());
 
        var mandatoryFieldsList = component.get("v.mandatoryFields");
        var mandatoryFieldsCmps = [];
        for(var id in mandatoryFieldsList){
            
            mandatoryFieldsCmps.push(component.find(mandatoryFieldsList[id]));
        }
        if(mandatoryFieldsList.length!=undefined && mandatoryFieldsList.length > 0){
        var allValid =mandatoryFieldsCmps.reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && !inputCmp.get('v.validity').valueMissing;
        }, true);
        if (allValid) { 
                    if( component.get('v.accountRecord.BillingLatitude')==''|| component.get('v.accountRecord.BillingLatitude')==null){
                           component.set("v.AddressList", null);
                            $A.util.removeClass(component.find("invalidAddress"), "slds-hide");  
                        }else{
                             helper.saveAccount(component, event, helper);
                        }
                    
                }else{
                    console.log('Mandatory Fields missing!!');
                }
            }else{
                helper.saveAccount(component, event, helper);
            }
                   
        },
})