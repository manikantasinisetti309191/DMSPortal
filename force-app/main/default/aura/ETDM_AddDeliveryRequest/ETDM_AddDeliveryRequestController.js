({
    doInit : function(component, event, helper) {
        var initRec = {'sobjectType' : 'ETDM_Delivery_Package__c',
                       'ETDM_Category__c' : '',
                       'ETDM_Size__c' : '',
                       'ETDM_Weight__c' : ''};
        component.set("v.productRecords", initRec);
        helper.doInit(component, event, helper);
        
    },
    validateDate: function(component, event, helper) {
         var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        if(component.get('v.jobRecord.StartDate')<today){
            $A.util.removeClass(component.find("invalidStartDate"), "slds-hide");
            
        }else{
            $A.util.addClass(component.find("invalidStartDate"), "slds-hide");
         }
    },
    add : function(component, event, helper) {
        var addRec = {'sobjectType' : 'ETDM_Delivery_Package__c',
                      'ETDM_Category__c' : '',
                      'ETDM_Size__c' : '',
                      'ETDM_Weight__c' : ''};
        var existingRecords = component.get("v.productRecords");
        existingRecords.push(addRec);
        component.set("v.productRecords", existingRecords);
    },
    
    remove : function(component, event, helper) {
        
        var indexPosition = event.target.name;
        var existingRecords = component.get("v.productRecords");
        console.log("indexPosition",indexPosition);
        existingRecords.splice(indexPosition, 1);
        component.set("v.productRecords", existingRecords);
    },
    
    selectOption:function(component, event, helper) {
        console.log('---selectOption---');
        helper.getAddressDetailsByPlaceId(component, event);
    },
    getDeliveryLocation: function(component, event, helper) {
        var searchText=component.get("v.deliveryAddress");
        helper.getAddressRecommendations(component,event,searchText);
    },  
    closeModel: function(component, event, helper) {
       component.set('v.addRequestModal',false);
 
    },  
    creatRequest : function(component, event, helper) {
        // helper.createRequestHelper(component, event, helper);
        component.set('v.jobRecord.ETDM_Customer_Name__c',component.get('v.jobRecord.ETDM_Customer_Name__c').trim());
        component.set('v.jobRecord.ETDM_Customer_Ref_Number__c',component.get('v.jobRecord.ETDM_Customer_Ref_Number__c').trim());
        
        var productRecords=component.get('v.productRecords');
        var mandatoryFieldsList = component.get("v.mandatoryFields");
        var mandatoryFieldsCmps = [];
        for(var id in mandatoryFieldsList){
            mandatoryFieldsCmps.push(component.find(mandatoryFieldsList[id]));
        }
        if(component.get('v.jobRecord.ETDM_Request_Type__c')=='Scheduled'){
                mandatoryFieldsCmps.push(component.find('StartDate'));                 
            }
        if(mandatoryFieldsList.length!=undefined && mandatoryFieldsList.length > 0){
            var allValid =mandatoryFieldsCmps.reduce(function (validSoFar, inputCmp) {
                inputCmp.showHelpMessageIfInvalid();
                return validSoFar && !inputCmp.get('v.validity').valueMissing;
            }, true);
            
            if (allValid) {  
                if(productRecords.length>0){
                    var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
                    if(component.get('v.jobRecord.ETDM_Request_Type__c')=='Scheduled' && component.get('v.jobRecord.StartDate')<today){
                         $A.util.removeClass(component.find("invalidStartDate"), "slds-hide");
                    
                    }else {
                        if( component.get('v.jobRecord.Latitude')==''|| component.get('v.jobRecord.Latitude')==null){
                           component.set("v.AddressList", null);
                            $A.util.removeClass(component.find("invalidAddress"), "slds-hide");  
                        }else{
                             helper.createRequestHelper(component, event, helper); 
                        }
                        
                    }
                   
                }else{
                    var utility = component.find("ETDM_UtilityMethods");
                    utility.showToast("Delivery Management", 'Please enter atleast one product', "error", "dismissible");
                    
                }
                
                
            }else{
                console.log('Mandatory Fields missing!!');
            }
        }else{
            //component.set('v.addRequestModal',false);
            //event.getSource().set("v.isLoading", true); 
            helper.createRequestHelper(component, event, helper);
        }
        
    }
})