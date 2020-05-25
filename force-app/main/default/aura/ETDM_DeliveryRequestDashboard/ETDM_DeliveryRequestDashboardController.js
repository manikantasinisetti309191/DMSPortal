({
	doInit : function(component, event, helper) {
		helper.doInit(component, event, helper)
	},
	setTabId: function(component, event, helper) {
		
		var urlEvent = $A.get("e.force:navigateToURL");
		urlEvent.setParams({
				"url": "/#deliveryService"                            
			});
	   urlEvent.fire();
	   var selectedItem = event.currentTarget;
		var Name = selectedItem.dataset.record;
		component.set('v.selectedTabId',Name);
	}
})