trigger ETDM_CreateServiceResource on ETDM_Vehicle__c (before insert , after insert) {
    // once Vehicle inserted for a Branch - Create a Service Resource with that Branch
    // Before insert
    if(trigger.isbefore && trigger.isinsert){
        ETDM_CreateServiceResourceClass.createTechnicianUser(trigger.new);
    }
    
    // After insert
    if(trigger.isAfter && trigger.isinsert){
        ETDM_CreateServiceResourceClass.createServiceResource(trigger.new);
    }
}