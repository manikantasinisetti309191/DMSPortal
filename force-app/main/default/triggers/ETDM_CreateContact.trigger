trigger ETDM_CreateContact on Account (before insert,before update,after update,after insert) {
     if(trigger.isbefore && (trigger.isinsert || trigger.isUpdate)){
       System.debug('--Update territory Trigger---');
       ETDMCommonUtils.assignTerritoryZone(trigger.new);
    }
    if(trigger.isafter && trigger.isinsert){
        ETDMCommonUtils.createContact(trigger.new);
    }
    
}