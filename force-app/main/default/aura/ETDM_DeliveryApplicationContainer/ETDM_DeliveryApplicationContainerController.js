({
    openRequestModal : function(component, event, helper) {
        component.set('v.addRequestModal',true);
    },
     openBranchModal : function(component, event, helper) {
        component.set('v.addBranchModal',true);
    },
    closeModel: function(component, event, helper) {
        
        component.set('v.addRequestModal',false);
           
    },
    doInit: function(component, event, helper)  {
        helper.doInit(component, event, helper);
        
    },
})