public class ETDM_PrintRecieptController {
    public Account acc{get;set;}
    public ETDM_vehicle__c vehicle{get;set;}
    public WorkOrder wo{get;set;}
    public List<ETDM_Delivery_Package__c> lstDelPackage{get;set;}
    Public String woAddr{get;set;}
    
    Public String woId = ApexPages.currentPage().getParameters().get('id');
    
    public ETDM_PrintRecieptController(){
        wo = [select Id, AccountId, WorkOrderNumber, ETDM_Customer_Name__c, StartDate, EndDate,Address,
                     Account.name, Account.ETDM_Branch_Address__c, ETDM_Customer_Ref_Number__c, 
                     ETDM_Mobile_Number__c, ETDM_Request_Type__c 
              From WorkOrder 
              where Id=:woId];
        System.debug('wo'+wo);
        woAddr = '';
        if(wo.address!=null){
        if(wo.address.getStreet() != null)
            woAddr = woAddr + wo.address.getStreet()+',';
        if(wo.address.getCity() != null)
            woAddr = woAddr + wo.address.getCity()+',';
        if(wo.address.getState() != null)
            woAddr = woAddr + wo.address.getState()+',';
        if(wo.address.getPostalCode() != null)
            woAddr = woAddr + wo.address.getPostalCode()+',';
        system.debug('++++'+woAddr);
            woAddr = woAddr.substring(0, woAddr.length() - 1);
        }
        
        system.debug('++++'+woAddr);
        
        acc=[select id,name,phone,BillingStreet, 
                    BillingCity, BillingState,BillingCountry,createddate 
             from account 
             where Id=:wo.AccountId limit 1];
        lstDelPackage = [Select Id, Name, ETDM_Work_Order__c, ETDM_Category__c, ETDM_Size__c, ETDM_Weight__c 
                      from ETDM_Delivery_Package__c
                      where ETDM_Work_Order__c =:wo.Id];
   }
    
}