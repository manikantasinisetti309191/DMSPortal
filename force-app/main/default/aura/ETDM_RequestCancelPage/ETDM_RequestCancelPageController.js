({
    closeModel: function(component, event, helper) {
        component.set('v.isCancelModal',false);
           
    },
    CancelRequest: function(component, event, helper){
        helper.saveContact(component, event, helper);
    } 
})