public class ETDMCommonUtils {
    /*@AuraEnabled
    public static void saveAccount(Account accountRecord) {
        System.debug('accountRecord'+accountRecord);
        accountRecord.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ETDM_Customer').getRecordTypeId();   
        Id adminId=[select id from profile where Name='System Administrator' LIMIT 1].Id;
        User u=[select id from user where profileId=:adminId]; 
        accountRecord.OwnerId=u.Id;
        try{
            insert accountRecord;
        }
        catch (Exception e) {
           System.debug('Insert Failed'+e.getMessage());
        }
    }*/
    public static void assignTerritoryZone(List<Account> lstAccounts){
        Id custRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ETDM_Customer').getRecordTypeId();
        Id partnerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ETDM_Partner').getRecordTypeId();
       
        List<Account> updateAccounts=new List<Account>();
        List<FSL__Polygon__c> polygonList=[SELECT FSL__Ma_La__c, FSL__Service_Territory__c, FSL__Mi_Lo__c, FSL__Mi_La__c, FSL__Ma_Lo__c, Name, Id FROM FSL__Polygon__c where FSL__Service_Territory__c!=null];
        Map<Id,Id> zoneTerritoryMap=new Map<Id,Id> ();
        for(ServiceTerritory st: [SELECT Id, Zone__c FROM ServiceTerritory where Zone__c !=null]){
            zoneTerritoryMap.put(st.Zone__c,st.Id);
        }
        System.debug('polygonList'+polygonList);
        For(Account acc:lstAccounts){
            if(acc.recordTypeId==custRecordTypeId||acc.recordTypeId==partnerRecordTypeId){
            system.debug('BillingLatitude '+acc.BillingLatitude+' BillingLongitude  '+acc.BillingLongitude);
            acc.ETDM_Service_Territory__c=zoneTerritoryMap.get(polygonList[0].Id);
            for(FSL__Polygon__c pologon:polygonList){
                if(acc.BillingLatitude>=pologon.FSL__Mi_La__c && acc.BillingLongitude>=pologon.FSL__Mi_Lo__c
                   &&acc.BillingLatitude<=pologon.FSL__Ma_La__c && acc.BillingLongitude<=pologon.FSL__Ma_Lo__c){
                       acc.ETDM_Service_Territory__c=zoneTerritoryMap.get(pologon.Id);
                       
                   }
                //lstAccounts.add(acc);
            }
            }
        }
        try{
            if(lstAccounts.size()>0 && lstAccounts!=null){
              // upsert lstAccounts; 
            }
            
        }catch(DMLException ex){
            system.debug('insert failed'+ex.getMessage());
        }
    }
    public static void createContact(List<Account> lstAccounts){
        system.debug('lstAccounts'+lstAccounts);
        List<Contact> customerlst = new List<Contact>();
		List<Contact> partnerlst = new List<Contact>();        
        Id custRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ETDM_Customer').getRecordTypeId();
        Id partnerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ETDM_Partner').getRecordTypeId();
        For(Account acc:lstAccounts){
            if(acc.RecordTypeId==partnerRecordTypeId){ 
            Contact con = New Contact();               
            con.lastname = acc.name;
            con.accountid=acc.id;
            con.email=acc.ETDM_Hospital_Email_Id__c;
            partnerlst.add(con);
            }
            if(acc.RecordTypeId==custRecordTypeId){ 
            Contact con = New Contact();               
            con.lastname = acc.name;
            con.accountid=acc.id;
            con.email=acc.ETDM_Hospital_Email_Id__c;
            customerlst.add(con);
            }
        }
        try{
            if(customerlst.size()>0 && customerlst!=null){
                insert customerlst;
            }
            if(partnerlst.size()>0 && partnerlst!=null){
                insert partnerlst;
            }
            
        }catch(DMLException ex){
            system.debug('Error in creating Contact'+ex.getMessage());
        }
        if(customerlst.size()>0 && customerlst!=null){
            createCommunityUsers(json.serialize(customerlst),'Customer'); 
        }
        if(partnerlst.size()>0 && partnerlst!=null){
            createCommunityUsers(json.serialize(partnerlst),'Partner'); 
        }
        
        //return conlst;
    }
    @future
    public  static void createCommunityUsers(String jsonString,String type){
		 List<contact> newContacts = (List<contact>)Json.deserialize(jsonString,List<contact>.class);   
         list<user> userList = new list<user>();
         String profileId;
         if(type=='Customer'){
               profileId = [SELECT Id FROM Profile WHERE name = :System.Label.ETDMS_Community_Login_User  LIMIT 1].id;
             
            }else if(type=='Partner'){
                profileId = [SELECT Id FROM Profile WHERE name = :System.Label.ETDM_Partner_Community_Login_User LIMIT 1].id;
            }
         
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*100));
        String uniqueName = orgId + dateString + randomInt;
        if(uniqueName.length()>51)
        {
            uniqueName=uniqueName.substring(0,51);
        }
        for(contact con : newContacts){
            
            user u = new user();
            u.FirstName = con.FirstName;
            u.LastName = con.LastName;
            u.Email = con.email	;
            u.contactId=con.Id;
            u.Alias =  uniqueName.substring(18, 23);
            u.Username=con.email+randomInt+'.EtPartner' ;
            u.ProfileId=profileId;
            u.TimeZoneSidKey ='Asia/Dubai';
            u.LanguageLocaleKey ='en_US';
            u.EmailEncodingKey ='UTF-8';
            u.LocaleSidKey = 'en_US';
            userList.add(u);    
        }
        try{
            system.debug('userList'+userList);
            insert userList;
        }catch(DMLException ex){
            system.debug('Error in creating Contact'+ex.getMessage());
        }
        
    }
}