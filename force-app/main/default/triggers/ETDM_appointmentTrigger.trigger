trigger ETDM_appointmentTrigger on ServiceAppointment (after update) {
    ETDM_handleServiceResources.deleteServices(trigger.oldMap , trigger.new);
}