({
    doInit : function(component, event, helper) {
        var action = component.get("c.getHospitalBranchDetails");
        action.setParams({ 
            
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data=response.getReturnValue();
                //alert("From server: "+response.getReturnValue());
                component.set('v.requestTypes',data.requestTypes);
                component.set('v.branchList',data.branchList); 
                component.set('v.loaded', !component.get('v.loaded'));
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    createRequestHelper: function(component, event, helper){
        //event.getSource().set("v.isLoading", true); 
        component.set('v.loaded', !component.get('v.loaded'));
         var action = component.get("c.createNewRequest");
            action.setParams({ 
                "jobRecord" : component.get("v.jobRecord"),
                "productRecords" : component.get('v.productRecords'),
                "branchId": component.get('v.branchId')
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    //alert('state = ' + state);
                     component.set('v.loaded', !component.get('v.loaded'));
                    $A.get('e.force:refreshView').fire();
                    //event.getSource().set("v.isLoading", false); 
                }
                else if (state === "INCOMPLETE") {
                    // do something
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                     errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            });
            $A.enqueueAction(action);
        
        
        
        //component.set('v.addRequestModal',false);
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
                      $A.util.addClass(component.find("invalidAddress"), "slds-hide");  
                    }
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
                //console.log('response'+addressResponse.result.name);
                var postalCode = '', state = '', country= '', city = '', street = '',neighborhood='', street_number = '', route = '', subLocal1 = '', subLocal2 = '';
                for(var i=0; i < addressResponse.result.address_components.length ; i++){
                    var FieldLabel = addressResponse.result.address_components[i].types[0];
                    if(FieldLabel == 'neighborhood' || FieldLabel == 'sublocality_level_2' || FieldLabel == 'sublocality_level_1' || FieldLabel == 'street_number' || FieldLabel == 'route' || FieldLabel == 'locality' || FieldLabel == 'country' || FieldLabel == 'postal_code' || FieldLabel == 'administrative_area_level_1'){
                        switch(FieldLabel){
                            case 'sublocality_level_2':
                                subLocal2 = addressResponse.result.address_components[i].long_name;
                                break;
                            case 'neighborhood':
                                neighborhood = addressResponse.result.address_components[i].long_name;
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
                street = addressResponse.result.name + ' '+ street_number + ' ' + route+ ' ' + neighborhood+' ' +subLocal1;
                
                 
                    component.set('v.jobRecord.Street', street);
                    component.set('v.jobRecord.PostalCode', postalCode);
                    component.set('v.jobRecord.State', state);
                    component.set('v.jobRecord.Country', country);
                    component.set('v.jobRecord.City	', city);
                    component.set('v.deliveryAddress',street+' '+city+' '+country);
                    component.set('v.jobRecord.Latitude', addressResponse.result.geometry.location.lat);
                    component.set('v.jobRecord.Longitude', addressResponse.result.geometry.location.lng);
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