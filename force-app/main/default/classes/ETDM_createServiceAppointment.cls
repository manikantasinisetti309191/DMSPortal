public class ETDM_createServiceAppointment {
    @future
    public static void createAppointment(String jsonString){
        List<workorder> newOrders = (List<workorder>)Json.deserialize(jsonString,List<workorder>.class);
        map<id ,workorder> newOrdersMap=new map<id ,workorder>(newOrders);
        List<WorkOrder> wOrdersList = new List<WorkOrder>([select id,RecordType.developername,ETDM_Branch__c,ServiceTerritoryId,
                                                           ETDM_Mobile_Number__c ,ETDM_Customer_Name__c from WorkOrder 
                                                           where RecordType.developername ='ETDM_Work_Order' AND 
                                                           id in :newOrdersMap.keyset()]);
        
        system.debug('in trigger');
        List<String> TertrtyIds = new list<String>();
        
        //key = branch id and Value = service Resource
        Map<String, List<serviceResource>> tertryResrceMap = new Map<String, List<serviceResource>>();
        //key =workOrderId and Value = Branch id
        Map<String, String> wOrderTerritoryMap = new Map<String, String>();
        
        //get the branch ids from work order
        for(workorder wo : wOrdersList) {
            if(wo.ServiceTerritoryId != null){
                TertrtyIds.add(wo.ServiceTerritoryId);
                wOrderTerritoryMap.put(wo.Id , wo.ServiceTerritoryId);
            }
        }
       
        for(serviceResource res : [select id, ETDM_Service_Territory__c from serviceResource 
                                   where ETDM_Service_Territory__c in : TertrtyIds
                                   AND IsActive = True ] ){
                                       
                                       if(res != null){
                                           if(! tertryResrceMap.containskey(res.ETDM_Service_Territory__c)){
                                               
                                               tertryResrceMap.put(res.ETDM_Service_Territory__c, new List<serviceResource>{res} );
                                           }
                                           else{
                                               tertryResrceMap.get(res.ETDM_Service_Territory__c).add(res);
                                           }
                                           
                                           system.debug('branch = '+res.ETDM_Service_Territory__c);
                                           system.debug('res = '+res);
                                       }
                                       
                                   }
        
        system.debug('tertryResrceMap = '+tertryResrceMap);
        
        
        map<String ,ServiceAppointment > wOrdServAppntmntMap = new map<String ,ServiceAppointment >();
        
        //Create Service appointment 
        for(workorder wo : newOrders){
            
            ServiceAppointment appnt = new ServiceAppointment();
            appnt.RecordTypeId =Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByDeveloperName().get('ETDM_Service_Appointment').getRecordTypeId();
            appnt.ETDM_Branch__c = wo.ETDM_Branch__c;
            appnt.ETDM_Mobile_Number__c = wo.ETDM_Mobile_Number__c;
            appnt.ETDM_Customer_Name__c = wo.ETDM_Customer_Name__c;
            appnt.ParentRecordId = wo.Id;
            //appnt.status = 'Scheduled';
            appnt.ServiceTerritoryId = wo.ServiceTerritoryId;
            appnt.SchedStartTime = wo.StartDate !=null ? (wo.StartDate ):(Date.today());
                system.debug('Start Date = '+wo.StartDate);
            // datetime myDate =datetime.newInstance(wo.StartDate.year(),wo.StartDate.month(), wo.StartDate.Day());
            datetime enddate = wo.StartDate !=null ? wo.StartDate.addDays(1) :Date.today().addDays(1);
            appnt.EarliestStartTime = wo.StartDate !=null ? (wo.StartDate ):(Date.today());
            appnt.DueDate =  wo.StartDate !=null ? wo.StartDate.addDays(2) :Date.today().addDays(2);
            appnt.SchedEndTime = enddate;
            system.debug('work oredr = '+wo.Id);
            system.debug('appnt = '+appnt);
            wOrdServAppntmntMap.put(wo.id ,appnt );
            
        }
        
        //insert Service appointments
        if(wOrdServAppntmntMap.values().size() > 0){
            try{
                insert wOrdServAppntmntMap.values();
            }
            catch(Exception e){
                system.debug('Exception e ='+e.getMessage());
                system.debug('Exception line num ='+e.getLineNumber());
                system.debug('Exception Trace ='+e.getStackTraceString());
            }
            
            system.debug('appointments inserted');
        }
        
        List<AssignedResource> assResList = new List<AssignedResource>();
        
        // Create 'Assigned Resources' which is junction object between - service appointment and Service Resource.
        system.debug('appnt = '+wOrdServAppntmntMap);
        
        for(workorder wo : wOrdersList){
            //Create assigned Resources
            if(tertryResrceMap.containskey(wo.ServiceTerritoryId)){
                List<ServiceResource> resources = tertryResrceMap.get(wo.ServiceTerritoryId);
                system.debug('resources = ' + resources.size());
                if(resources.size() > 0){
                    for(ServiceResource res : resources){
                        AssignedResource asRes = new AssignedResource();
                        asRes.ServiceResourceId = res.id;
                        asRes.ServiceAppointmentId = wOrdServAppntmntMap.get(wo.id).id;
                        assResList.add(asRes);
                    }
                }
            }
             
        }
        
        //insert assigned Resources
        if(assResList.size()>0 ){
            try{
                insert assResList;
            }
            catch(Exception e){
                system.debug('Exception e ='+e.getMessage());
                system.debug('Exception line num ='+e.getLineNumber());
                system.debug('Exception Trace ='+e.getStackTraceString());
            }
        }
        
        
        
    }
    
    
}