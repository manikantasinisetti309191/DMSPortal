public class ETDM_handleServiceResources {
    public static void deleteServices(Map<id , ServiceAppointment> oldAppntmntMap , List<ServiceAppointment> newAppnts){
        
        
        List<String> appntsToConsider = new List<String>();
        
        for(ServiceAppointment app : newAppnts ){
            if(oldAppntmntMap.get(app.id).status !=  app.Status  && app.Status =='Dispatched'){
                system.debug('in Trigger');
                	appntsToConsider.add(app.Id);
            }
        }
        
        
        List<AssignedResource> assgnResToDelete = new List<AssignedResource>();
        if(appntsToConsider.size() > 0){
            for(ServiceAppointment app : [select id, (select id , ServiceResourceId ,ServiceResource.RelatedRecordId from ServiceResources) from ServiceAppointment where id in :appntsToConsider]){
				system.debug('app.ServiceResourcer = '+app.ServiceResources.size());
                if(!app.ServiceResources.isEmpty()){
                    for(AssignedResource res : app.ServiceResources){
                        system.debug('relt id =' + res.ServiceResource.RelatedRecordId);
                        system.debug('user id =' + UserInfo.getUserId());
                        if(res.ServiceResource.RelatedRecordId != UserInfo.getUserId()){
                            assgnResToDelete.add(res);
                        }
                    }
                }
                
            } 
        }
        
        
        if(assgnResToDelete.size() > 0){
            system.debug('inside delete');
            delete assgnResToDelete;
        }
        
        
        
        
    }
}