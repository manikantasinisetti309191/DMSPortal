/*
* Class Name:ETDMController
* Author : Kamal Mahammad
* CreatedDate : 24/03/2020
* Modification Purpose
* * 1. Kamal: Created to maintain all the Delivery Portal Actions
* * 2.
*/
public with sharing class ETDMController {
    @AuraEnabled
    public static ETDMWrapper getETDMData() {
        String errStr;
        ETDMWrapper wrapperInstance=new ETDMWrapper();
        try{
            List<String> field_apinames=new  List<String>{'ETDM_Category__c','ETDM_Weight__c','ETDM_Size__c'};
                Map<String, List<Schema.PicklistEntry>>  fieldFinalMap=ETDM_PicklistValueController.getPicklistvalues('ETDM_Delivery_Package__c',field_apinames);
            if(fieldFinalMap == null) {
                return null;
            }
            List<String> optionlist = new List<String>();
            for(String fieldVal : fieldFinalMap.keySet()){
                for (Schema.PicklistEntry pv : fieldFinalMap.get(fieldVal)) {
                    optionlist.add(pv.getValue());
                }
                if(fieldVal=='ETDM_Category__c'){
                    wrapperInstance.categoryTypes.addAll(optionlist);
                }else if(fieldVal=='ETDM_Weight__c'){
                    wrapperInstance.weightTypes.addAll(optionlist);
                } else if(fieldVal=='ETDM_Size__c'){
                    wrapperInstance.sizeTypes.addAll(optionlist);
                }                
                optionlist.clear();
            } 
            return wrapperInstance;
            
        }catch (Exception e) {
            errStr = JSON.serialize(ETDMController.buildErrorResponse('getETDMData', e.getMessage(), e.getStackTraceString()));
            AuraHandledException ahe = new AuraHandledException(errStr);
            ahe.setMessage(errStr);
            throw ahe;
        }
    }
    
    public class ETDMWrapper{
        @AuraEnabled
        public List<String> categoryTypes=new List<String>(); 
        @AuraEnabled
        public List<String> weightTypes=new List<String>();
        @AuraEnabled
        public List<String> sizeTypes=new List<String>();
        
    }  
    
    @AuraEnabled
    public static ETDMRequestWrapper getHospitalBranchDetails() {
        ETDMRequestWrapper requestWrap=new ETDMRequestWrapper();
        String errStr;
        try{
            Id userAccountId=[select accountId from user where id=:userInfo.getUserId()].accountId; 
            Account acc=[select Id,parentId from Account where id=:userAccountId]; 
            if(acc.parentId==null){
                requestWrap.branchList.addAll([select id,ETDM_Branch_Address__c
                                               from Account where parentId=:acc.Id or id=:acc.Id]);              
            } else{
                requestWrap.branchList.addAll([select id,ETDM_Branch_Address__c
                                               from Account where parentId=:acc.parentId]);   
            }
            List<String> field_apinames=new  List<String>{'ETDM_Request_Type__c'};
                Map<String, List<Schema.PicklistEntry>>  fieldFinalMap=ETDM_PicklistValueController.getPicklistvalues('WorkOrder',field_apinames);
            if(fieldFinalMap != null) {
                List<String> optionlist = new List<String>();
                for(String fieldVal : fieldFinalMap.keySet()){
                    for (Schema.PicklistEntry pv : fieldFinalMap.get(fieldVal)) {
                        optionlist.add(pv.getValue());
                    }
                    if(fieldVal=='ETDM_Request_Type__c'){
                        requestWrap.requestTypes.addAll(optionlist);
                    }              
                    optionlist.clear();
                }
            } 
            return   requestWrap;   
        }    
        catch (Exception e) {
            errStr = JSON.serialize(ETDMController.buildErrorResponse('getETDMData', e.getMessage(), e.getStackTraceString()));
            AuraHandledException ahe = new AuraHandledException(errStr);
            ahe.setMessage(errStr);
            throw ahe;
        }
    }
    
    public class ETDMRequestWrapper{
        @AuraEnabled
        public List<Account> branchList=new List<Account>(); 
        @AuraEnabled
        public List<String> requestTypes=new List<String>();
        
    }
    @AuraEnabled
    public static ETDMDashboardWrapper getDashboardData() {
        ETDMDashboardWrapper dashboardWrap=new ETDMDashboardWrapper();
        String errStr;
        try{
            Id userAccountId=[select accountId from user where id=:userInfo.getUserId()].accountId; 
            Account acc=[select Id,parentId from Account where id=:userAccountId]; 
            if(acc.parentId==null){
                dashboardWrap.activeCount=[select count() from WorkOrder where status IN ('Scheduled','None','Dispatched','In Progress') 
                                           and  (AccountId = :acc.Id or Account.parentId = :acc.Id)];
                dashboardWrap.deliveredCount=[select count() from WorkOrder where status ='Completed'  and 
                                              (AccountId = :acc.Id or Account.parentId = :acc.Id)];
                dashboardWrap.cancelledCount=[select count() from WorkOrder where status ='Canceled' 
                                              and (AccountId = :acc.Id or Account.parentId = :acc.Id)];
                dashboardWrap.onHoldCount=[select count() from WorkOrder where status ='On Hold' and 
                                           (AccountId = :acc.Id or Account.parentId = :acc.Id)];
                
            }else{
                dashboardWrap.activeCount=[select count() from WorkOrder where status IN ('Scheduled','None','Dispatched','In Progress')  and accountId=:userAccountId];
                dashboardWrap.deliveredCount=[select count() from WorkOrder where status ='Completed'  and accountId=:userAccountId];
                dashboardWrap.cancelledCount=[select count() from WorkOrder where status ='Canceled' and accountId=:userAccountId];
                dashboardWrap.onHoldCount=[select count() from WorkOrder where status ='On Hold' and accountId=:userAccountId];
                
            }
            
            return   dashboardWrap;   
        }    
        catch (Exception e) {
            errStr = JSON.serialize(ETDMController.buildErrorResponse('getDashboardData', e.getMessage(), e.getStackTraceString()));
            AuraHandledException ahe = new AuraHandledException(errStr);
            ahe.setMessage(errStr);
            throw ahe;
        }
    }
    
    public class ETDMDashboardWrapper{ 
        @AuraEnabled public Integer activeCount=0; 
        @AuraEnabled public Integer deliveredCount=0; 
        @AuraEnabled public Integer cancelledCount=0; 
        @AuraEnabled public Integer onHoldCount=0; 
        
    }
    @AuraEnabled
    public static List<WorkOrder> getDeliveryRequestsData(String status) {
        String errStr;
        try{
            Id userAccountId=[select accountId from user where id=:userInfo.getUserId()].accountId; 
            Account acc=[select Id,parentId from Account where id=:userAccountId]; 
            String query='select Id,(select id,AppointmentNumber  from ServiceAppointments), AccountId, WorkOrderNumber, ETDM_Customer_Name__c, StartDate, Street, City, State, PostalCode, Country,Status, EndDate,Address, Account.name, Account.ETDM_Branch_Address__c, ETDM_Customer_Ref_Number__c, ETDM_Mobile_Number__c, ETDM_Request_Type__c ,( Select Id, Name, ETDM_Work_Order__c, ETDM_Category__c,ETDM_Size__c, ETDM_Weight__c from ETDM_Delivery_Packages__r) From WorkOrder where ';
            Id accountId=acc.Id;
            Id parent_Id=acc.parentId;
            if(parent_Id==null){
                query+='   (AccountId = :accountId or Account.parentId = :accountId)';    //Account.parentId=:acc.Id or          
            } else{
                query+='  Account.parentId = :parent_Id ';   
            }  //IN ('Scheduled','None','Dispatched','In Progress') 
            if(status=='Active'){
                List<String> statusList = new list<String> { 'Scheduled' , 'None' , 'Dispatched','In Progress'};
                query+=' and status IN :statusList';
            }else{
                query+=' and status=:status';
            }
            query+=' order by lastModifiedDate desc'; 
             
            return Database.query(query);
        }    
        catch (Exception e) {
            errStr = JSON.serialize(ETDMController.buildErrorResponse('getDeliveryRequestsData', e.getMessage(), e.getStackTraceString()));
            AuraHandledException ahe = new AuraHandledException(errStr);
            ahe.setMessage(errStr);
            throw ahe;
        }
    }
    
    
    @AuraEnabled
    public static String getAddressSet(String SearchText){
        return ETDM_AddressSearchController.getAddressSet(SearchText);
    } 
    @AuraEnabled
    public static String getAddressDetailsByPlaceId(String PlaceID){
        return ETDM_AddressSearchController.getAddressDetailsByPlaceId(PlaceID);
    } 
    
    @AuraEnabled
    public static Id createNewRequest(WorkOrder jobRecord, List<ETDM_Delivery_Package__c> productRecords,Id branchId){
        String errStr;
        System.debug('jobRecord'+jobRecord);
        System.debug('productRecords'+productRecords);
        ServiceReportLayout layout=[select id , developername from ServiceReportLayout where developername ='ETDMS Template'];
        Account userAccount=[select Id,ETDM_Service_Territory__c from Account where id=:branchId];
        jobRecord.ServiceTerritoryId=userAccount.ETDM_Service_Territory__c;
        jobRecord.AccountId=branchId;
        jobRecord.ServiceReportTemplateId=layout.Id;
        if(jobRecord.StartDate==null){
            jobRecord.StartDate=Datetime.Now();
        }
        
        //jobRecord.status='In Progress';
        jobRecord.RecordTypeId=[select id from recordType where developerName='ETDM_Work_Order'].Id;
        insert jobRecord;
        
        List<ETDM_Delivery_Package__c>  productItems=new List<ETDM_Delivery_Package__c> ();
        for(ETDM_Delivery_Package__c productItem:productRecords){
            productItem.ETDM_Work_Order__c=jobRecord.Id;
            productItems.add(productItem);
        }
        insert productItems;    
        return jobRecord.Id; 
        
      /*catch (Exception e) {
        errStr = JSON.serialize(ETDMController.buildErrorResponse('createNewRequest', e.getMessage(), e.getStackTraceString()));
        AuraHandledException ahe = new AuraHandledException(errStr);
        ahe.setMessage(errStr);
        throw ahe;
        }*/
    }
    
    @TestVisible
    private static Map<String, String> buildErrorResponse(String source, String errorMessage, String stackTrace) {
        Map<String, String> errorResponse = new Map<String, String>();
        
        errorResponse.put('SOURCE', source);
        errorResponse.put('MESSAGE', errorMessage);
        errorResponse.put('STACKTRACE', stackTrace);
        
        return errorResponse;
    }  
    
    
    @AuraEnabled
    public static List<Case> getCaseHistory() {
        String errStr;
        try{
            String userAccountId=[select accountId from user where id=:userInfo.getUserId()].accountId;   
            return [SELECT Id,  ETDM_Complaint_Type__c,CaseNumber,CreatedDate, ClosedDate,ETDM_Work_Order__r.WorkOrderNumber,
                    Description,Priority,ETDM_Rating__c,Status,ETDM_Steps_to_Reproduce__c,  ETDM_Suggestion_Type__c,
                    Subject    
                    FROM Case
                    where Case.AccountId=:userAccountId
                   order by lastModifiedDate desc];
        }catch (Exception e) {
            errStr = JSON.serialize(ETDMController.buildErrorResponse('getCaseHistory', e.getMessage(), e.getStackTraceString()));
            AuraHandledException ahe = new AuraHandledException(errStr);
            ahe.setMessage(errStr);
            throw ahe;
        }
    } 
    @AuraEnabled
    public static ServiceResource getDriverDetails(Id workOrderId) {
        String errStr;
        try{
            WorkOrder wo=[select Id, AccountId,(select id from serviceAppointments )
                          From WorkOrder where id=: workOrderId];
            if(wo.serviceAppointments.size()==0 || wo.serviceAppointments==null) return null;
            AssignedResource asRes =[select ServiceResourceId from AssignedResource where ServiceAppointmentId=:wo.serviceAppointments[0].Id LIMIT 1];
            if(asRes==null) return null;
            return [select id,Name,ETDM_Driver_Email__c,ETDM_Driver_Phone__c from ServiceResource where id=:asRes.ServiceResourceId];
        }catch (Exception e) {
            errStr = JSON.serialize(ETDMController.buildErrorResponse('getDriverDetails', e.getMessage(), e.getStackTraceString()));
            AuraHandledException ahe = new AuraHandledException(errStr);
            ahe.setMessage(errStr);
            throw ahe;
        }
    } 
    @AuraEnabled
    public static DriverDetailsWrapper getDriverLocationDetails(Id workOrderId) {
        String errStr;
        DriverDetailsWrapper wrap=new DriverDetailsWrapper();
        try{
            wrap.userAccount=[select id,name,account.billinglatitude,account.billinglongitude from user where id=:userInfo.getUserId()];   
            WorkOrder wo=[select Id,latitude,longitude , AccountId,(select id from serviceAppointments )
                          From WorkOrder where id=: workOrderId];
            wrap.WorkOrderRecord=wo;
            if(wo.serviceAppointments.size()==0 || wo.serviceAppointments==null) return null;
            AssignedResource asRes =[select ServiceResourceId from AssignedResource where ServiceAppointmentId=:wo.serviceAppointments[0].Id LIMIT 1];
            if(asRes==null) return null;
            ServiceResource srRecord= [select id,LastKnownLatitude, LastKnownLongitude,Name,ETDM_Driver_Email__c,ETDM_Driver_Phone__c 
                                       from ServiceResource where id=:asRes.ServiceResourceId];
            wrap.ServiceResourceRecord=srRecord;
            return wrap;
        }catch (Exception e) {
            errStr = JSON.serialize(ETDMController.buildErrorResponse('getDriverDetails', e.getMessage(), e.getStackTraceString()));
            AuraHandledException ahe = new AuraHandledException(errStr);
            ahe.setMessage(errStr);
            throw ahe;
        }
    }
    public class DriverDetailsWrapper{
        @AuraEnabled
        public WorkOrder WorkOrderRecord=new WorkOrder();
        @AuraEnabled
        public ServiceResource ServiceResourceRecord=new ServiceResource();
        @AuraEnabled
        public User userAccount=new User();
    }
    @AuraEnabled
    public static UserDetailsWrapper getUserDetails() {
        UserDetailsWrapper wrap=new UserDetailsWrapper();
        String errStr;
        try{
            Boolean isPartner=false;
            if([SELECT Id FROM Profile WHERE name = :System.Label.ETDM_Partner_Community_Login_User
 				LIMIT 1].id==userInfo.getProfileId()){
                isPartner=true;
            }
            wrap.isPartner=isPartner;
            String userAccountId=[select accountId from user where id=:userInfo.getUserId()].accountId;   
            wrap.accountRecord= [SELECT Id, Name   
                                 FROM Account
                                 where Id=:userAccountId];
            return wrap;
        }catch (Exception e) {
            errStr = JSON.serialize(ETDMController.buildErrorResponse('getUserDetails', e.getMessage(), e.getStackTraceString()));
            AuraHandledException ahe = new AuraHandledException(errStr);
            ahe.setMessage(errStr);
            throw ahe;
        }
    }
    public class UserDetailsWrapper{
        @AuraEnabled
        public Boolean isPartner=false;
        @AuraEnabled
        public Account accountRecord=new Account();
    }
     @AuraEnabled
    public static void saveAccount(Account accountRecord) {
        System.debug('accountRecord'+accountRecord);
        String errStr;
        accountRecord.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ETDM_Customer').getRecordTypeId();   
        Id adminId=[select id from profile where Name='System Administrator' LIMIT 1].Id;
        User u=[select id from user where profileId=:adminId]; 
        accountRecord.OwnerId=u.Id;
        try{
            insert accountRecord;
        }
        catch (Exception e) {
             errStr = JSON.serialize(ETDMController.buildErrorResponse('getUserDetails', e.getMessage(), e.getStackTraceString()));
            AuraHandledException ahe = new AuraHandledException(errStr);
            ahe.setMessage(errStr);
            throw ahe;
        }
    }
    
}