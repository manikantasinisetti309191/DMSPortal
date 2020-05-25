({
    closeModel: function(component, event, helper) {
        component.set('v.isDriverModal',false);
           
    },
    doInit: function(component, event, helper){
        helper.doInit(component, event, helper);
    } 
})