trigger ETDM_autoCreateAppointment on WorkOrder (before insert , After insert, after update) {
    // Create Service appointmenta and Service Resource 
    
    String jsonString = json.serialize(Trigger.NEW);
    //after Trigger
    If(trigger.isAfter && trigger.isinsert){
        system.debug('inside trigger');
        ETDM_createServiceAppointment.createAppointment(jsonString);
    }
    
}