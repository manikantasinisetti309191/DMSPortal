({
    
	saveAccount : function(component, event, helper)  {
         var utility = component.find("ETDM_UtilityMethods");
        var backendMethod = "saveAccount";
         var params = {
            "accountRecord": component.get('v.accountRecord')
        };
        var promise = utility.executeServerCall(component, backendMethod, params);
        
        promise.then (
            $A.getCallback(function(response) {
              component.set("v.addBranchModal",false);
               utility.showToast("Delivery Management", "We saved your branch details!", "success", "dismissible");
            }),
            
            $A.getCallback(function(error) {
                var err = JSON.parse(error);
                var errorToShow = utility.convertToUserFriendlyErrMsg(err.MESSAGE);
                utility.showToast("Delivery Management", errorToShow, "error", "dismissible");
            })
        )	
    
	},
     getAddressRecommendations: function(component, event,searchText){
        var utility = component.find("ETDM_UtilityMethods");
        var backendMethod = "getAddressSet";
        var params = {
            "SearchText" : searchText 
        };
        var promise = utility.executeServerCall(component, backendMethod, params);
        
        promise.then (
            $A.getCallback(function(response) {
                var addressResponse = JSON.parse(response);
                var predictions = addressResponse.predictions;
                var addresses = [];
                if (predictions.length > 0) {
                    for (var i = 0; i < predictions.length; i++) {
                        var bc =[];
                        addresses.push(
                            {
                                main_text: predictions[i].structured_formatting.main_text, 
                                secondary_text: predictions[i].structured_formatting.secondary_text,
                                place_id: predictions[i].place_id
                            });
                        
                    }
                     $A.util.addClass(component.find("invalidAddress"), "slds-hide");  
                }else{
                    //component.set("v.deliveryAddress", addresses);
                    $A.util.removeClass(component.find("invalidAddress"), "slds-hide");
                }
               component.set("v.AddressList", addresses);
               
            }),
            
            $A.getCallback(function(error) {
                var err = JSON.parse(error);
                var errorToShow = utility.convertToUserFriendlyErrMsg(err.MESSAGE);
                utility.showToast("Delivery Management", errorToShow, "error", "dismissible");
            })
        )	
       
    },
    //get address details by place Id from google API 
    getAddressDetailsByPlaceId: function(component,event){
        var selectedValue = event.currentTarget.dataset.value;
       var utility = component.find("ETDM_UtilityMethods");
        var backendMethod = "getAddressDetailsByPlaceId";
        var params = {
            PlaceID:selectedValue 
        };
        var promise = utility.executeServerCall(component, backendMethod, params);
        
        promise.then (
            $A.getCallback(function(response) {
                console.log('response'+response);
                var addressResponse = JSON.parse(response);
                console.log('response'+addressResponse.result.geometry.location.lat);
                var postalCode = '', state = '', country= '', city = '', street = '',neighborhood='', street_number = '', route = '', subLocal1 = '', subLocal2 = '';
                for(var i=0; i < addressResponse.result.address_components.length ; i++){
                    var FieldLabel = addressResponse.result.address_components[i].types[0];
                    if(FieldLabel == 'neighborhood' || FieldLabel == 'sublocality_level_2' || FieldLabel == 'sublocality_level_1' || FieldLabel == 'street_number' || FieldLabel == 'route' || FieldLabel == 'locality' || FieldLabel == 'country' || FieldLabel == 'postal_code' || FieldLabel == 'administrative_area_level_1'){
                        switch(FieldLabel){
                            case 'neighborhood':
                                neighborhood = addressResponse.result.address_components[i].long_name;
                                break;
                            case 'sublocality_level_2':
                                subLocal2 = addressResponse.result.address_components[i].long_name;
                                break;
                            case 'sublocality_level_1':
                                subLocal1 = addressResponse.result.address_components[i].long_name;
                                break;
                            case 'premise':
                                street_number = addressResponse.result.address_components[i].long_name;
                                break;
                            case 'route':
                                route = addressResponse.result.address_components[i].short_name;
                                break;
                            case 'postal_code':
                                postalCode = addressResponse.result.address_components[i].long_name;
                                break;
                            case 'administrative_area_level_1':
                                state = addressResponse.result.address_components[i].short_name;
                                break;
                            case 'country':
                                country = addressResponse.result.address_components[i].long_name;
                                break;
                            case 'locality':
                                city = addressResponse.result.address_components[i].long_name;
                                break;
                            default:
                                break;
                        }
                    }
                }
                street = addressResponse.result.name + ' '+street_number + ' ' + route+ ' ' + neighborhood+' ' + subLocal1;
                
                 
                    component.set('v.accountRecord.BillingStreet', street);
                    component.set('v.accountRecord.BillingPostalCode', postalCode);
                    component.set('v.accountRecord.BillingState', state);
                    component.set('v.accountRecord.BillingCountry', country);
                    component.set('v.accountRecord.BillingCity', city);
                    component.set('v.branchAddress',street+' '+state+' '+city+' '+country);
                    component.set('v.accountRecord.BillingLatitude', addressResponse.result.geometry.location.lat);
                    component.set('v.accountRecord.BillingLongitude', addressResponse.result.geometry.location.lng);
                    $A.util.toggleClass(component.find("Drop-Address-listbox"), "slds-hide");
                    component.set("v.searchKey", null);
               }),
            
            $A.getCallback(function(error) {
                var err = JSON.parse(error);
                var errorToShow = utility.convertToUserFriendlyErrMsg(err.MESSAGE);
                utility.showToast("Delivery Management", errorToShow, "error", "dismissible");
            })
        )	
       
       
    }
})