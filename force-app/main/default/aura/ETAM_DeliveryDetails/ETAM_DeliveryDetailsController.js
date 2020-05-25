({
    doInit: function(component, event, helper)  {
        helper.doInit(component, event, helper);
    },
    
    showModal: function (component, event, helper) {
        var item=event.getSource().get('v.value');
        component.set('v.productList',item.ETDM_Delivery_Packages__r);
        console.log('item--'+JSON.stringify(item.ETDM_Delivery_Packages__r));
       //var selectedItem = event.currentTarget;
      // var Name = selectedItem.dataset.record;
       //console.log('data Name = '+ JSON.stringify(selectedItem));
        $A.util.toggleClass(component.find("ConfirmDialog1"), 'slds-hide');a
    },    
    
    handleDone:function(component, event, helper){ 
        $A.util.toggleClass(component.find("ConfirmDialog1"), 'slds-hide');
    },
    openReportModal:function(component, event, helper){ 
        var item=event.getSource().get('v.value');
        console.log('item'+item);
        component.set('v.workOrderId',item);        
        component.set('v.isReportModal',true);
         $A.util.addClass(component.find("ConfirmDialog1"), 'slds-hide');
    },
    cancelRequestModal:function(component, event, helper){ 
        var item=event.getSource().get('v.value');
        console.log('item'+item);
        component.set('v.workOrderId',item);        
        component.set('v.isCancelModal',true);
         $A.util.addClass(component.find("ConfirmDialog1"), 'slds-hide');
    },
    contactDriverModal:function(component, event, helper){ 
        var item=event.getSource().get('v.value');
        console.log('item'+item);
        component.set('v.workOrderId',item);        
        component.set('v.isDriverModal',true);
         $A.util.addClass(component.find("ConfirmDialog1"), 'slds-hide');
    },
    trackOrderModal:function(component, event, helper){ 
        var item=event.getSource().get('v.value');
        console.log('item'+item);
        component.set('v.workOrderId',item);        
        component.set('v.isTrackModal',true);
         $A.util.addClass(component.find("ConfirmDialog1"), 'slds-hide');
    },
    printReciept:function(component, event, helper){ 
        var item=event.getSource().get('v.value');
        console.log('item'+item);
        component.set('v.workOrderId',item);  
        var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                            "url": "/apex/ETDM_VF_PrintReciept?&id="+item                           
                        });
        urlEvent.fire();
        
    },

    getPreviousList: function(component, event, helper) {
         $A.util.addClass(component.find("ConfirmDialog1"), 'slds-hide');
        var corousalSize=component.get('v.corousalSize'); 
        var start=component.get('v.start'); 
        start-=corousalSize;
        var deliveryData=component.get('v.deliveryData'); 
        component.set('v.currentData',deliveryData.slice(start,start+corousalSize)); 
        component.set('v.start',start);
        
     },
     getNextList: function(component, event, helper) {
          $A.util.addClass(component.find("ConfirmDialog1"), 'slds-hide');
        var corousalSize=component.get('v.corousalSize'); 
        var start=component.get('v.start'); 
        start+=corousalSize;
        var deliveryData=component.get('v.deliveryData'); 
        component.set('v.currentData',deliveryData.slice(start,start+corousalSize)); 
        component.set('v.start',start); 
    },
    searchRequest: function(component, event, helper) {
        $A.util.addClass(component.find("ConfirmDialog1"), 'slds-hide');
        var searchKey=component.get('v.searchText').toLowerCase();
        if(searchKey.length>2){
            var deliveryData = component.get('v.deliveryData');
        
            var fileredData =  deliveryData.filter(function(item) {
                console.log('item'+JSON.stringify(item.ETDM_Customer_Name__c));
                return (item.ETDM_Customer_Name__c.toLowerCase().indexOf(searchKey) !== -1)||
                (item.ETDM_Mobile_Number__c.indexOf(searchKey) !== -1)||
                (item.ServiceAppointments[0].AppointmentNumber.toLowerCase().indexOf(searchKey) !== -1);
            });
            component.set('v.currentData',fileredData);
            component.set('v.totalRecords',fileredData.size); 
        }else{
            component.set('v.start',0);
            var start=component.get('v.start'); 
            var corousalSize=component.get('v.corousalSize'); 
            var deliveryData=component.get('v.deliveryData'); 
            component.set('v.currentData',deliveryData.slice(start,start+corousalSize)); 
            component.set('v.totalRecords',component.get("v.RecordsCount"));
        }
    
    },
    sortData: function(component, event, helper) {
        $A.util.addClass(component.find("ConfirmDialog1"), 'slds-hide');
        var item=event.getSource().get('v.value');
        var currentData=component.get('v.currentData'); 
        currentData.sort((a, b) => (a.item > b.item) ? 1 : -1)
        component.set('v.currentData',currentData); 
    }
})