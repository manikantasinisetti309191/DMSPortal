public class ETDM_CreateServiceResourceClass {
    public static void createTechnicianUser(List<ETDM_Vehicle__c> vehicles ){
        
        //Create an user with Driver information from Vehicle
        Map<ETDM_Vehicle__c , user> vehicleUserMap = new Map<ETDM_Vehicle__c , user>();
        String profileId = [SELECT Id FROM Profile WHERE name = 'Delivery Agents' LIMIT 1].id;
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*100));
        String uniqueName = orgId + dateString + randomInt;
        if(uniqueName.length()>51)
        {
            uniqueName=uniqueName.substring(0,51);
        }
        

      // Iterating Over Vehicles
        for(ETDM_Vehicle__c v : vehicles){
            //Create user with Driver info in Vehicle
            user u = new user();
            u.FirstName = v.ETDM_Driver_Name__c;
            u.LastName = v.ETDM_Technician_Last_Name__c;
            u.Email = v.ETDM_Driver_Email__c	;
            u.Alias =  uniqueName.substring(18, 23);
            u.Username=v.ETDM_Driver_Name__c+randomInt+'@Et.com' ;
            u.ProfileId=profileId;
            u.TimeZoneSidKey ='Asia/Dubai';
            u.LanguageLocaleKey ='en_US';
            u.EmailEncodingKey ='UTF-8';
            u.LocaleSidKey = 'en_US';
            vehicleUserMap.put(v , u);    
        }
        
        //insert users
        system.debug('users '+ vehicleUserMap.values().size());
        insert vehicleUserMap.values();
        
        
        
        
        
        //update user to Vehicle
        for(ETDM_Vehicle__c veh : vehicleUserMap.keyset() ){
            system.debug('user id = '+ vehicleUserMap.get(veh).id);
            veh.ETDM_Driver__c = vehicleUserMap.get(veh).id;
        }
        
        userWrapper uw = new userWrapper();
        uw.users = vehicleUserMap.values();
        asyncAssignPermSets(JSON.serialize(uw));
        
        
        
    }
    
@future
public static void asyncAssignPermSets(String UserString){
    system.debug('in assigning permission sets');
    
    userWrapper userList = (userWrapper)JSON.deserialize(UserString , userWrapper.class );
    
    List<user> users = userList.users;
    
    //query the permission sets needed
    List<String> pSets = new List<String>();
    pSets.add('FSL_Resource_Permissions');
    pSets.add('FSL_Mobile_License');
    Map<id, permissionset> permSets = new Map<id, permissionset>([SELECT Id, Name FROM PermissionSet where name in :pSets]);
    List<PermissionSetAssignment> perSetassgnmntList = new List<PermissionSetAssignment>();
    //insert permission set assignments for users --
    for(user u :users){
        for(String pid:permSets.keyset() ){
            PermissionSetAssignment psa = new PermissionSetAssignment ();
            psa.PermissionSetId = pid;
            psa.AssigneeId = u.id;
            perSetassgnmntList.add(psa);
        }
    }
    //Test comment
    
    if(perSetassgnmntList.size() >0){
        insert perSetassgnmntList;
    }
    }
    
    
    
    public static void createServiceResource(List<ETDM_Vehicle__c> vehicles ){
        vehcleWrapper vw = new vehcleWrapper();
        vw.vehicles = vehicles;
        
        // Create Service Resource in future method
        asyncCreateServiceResource(JSON.serialize(vw) );
    }
    
    @future
    public static void asyncCreateServiceResource( String vehicleUserString){
        
        system.debug('in assigning service Resources');
        //de-serialize the String to Map
        vehcleWrapper  vehiclesWr = (vehcleWrapper )JSON.deserialize(vehicleUserString , vehcleWrapper.class);
        
        List<ETDM_Vehicle__c> vehcles = vehiclesWr.vehicles;
        
        //Key = Resource  ,  Value = Territory
        Map<String , String> resrceTerrtyMap = new Map<String , String>();
        List<ServiceResource> resources = new List<ServiceResource>();
        
        for(ETDM_Vehicle__c vehc : vehcles){
            //ServiceResource instance
            ServiceResource res = new ServiceResource();
            res.ETDM_Branch__c  = vehc.ETDM_Branch__c;
            res.RelatedRecordId = vehc.ETDM_Driver__c;
            res.IsActive = true;
            res.ResourceType ='T';
            res.ETDM_Vehicle__c = vehc.id;
            res.Name = vehc.ETDM_Driver_Name__c + ' '+vehc.ETDM_Technician_Last_Name__c;
            resrceTerrtyMap.put(vehc.ETDM_Driver__c ,vehc.ETDM_Service_Territory__c );
            resources.add(res);
        }
        
        insert resources;
        
        
        // add this Resource as a Service Territory member - ServiceTerritoryMember
        List<ServiceTerritoryMember> members = new List<ServiceTerritoryMember>();
        
        for(ServiceResource res :resources ){
            ServiceTerritoryMember mem = new ServiceTerritoryMember();
            mem.ServiceResourceId  = res.id;
            system.debug('resrceTerrtyMap = ' +resrceTerrtyMap.get(res.RelatedRecordId));
            mem.ServiceTerritoryId = resrceTerrtyMap.get(res.RelatedRecordId);
            mem.TerritoryType  = 'P';
            mem.EffectiveStartDate = Date.today();
            members.add(mem);
        }
        
        if(members.size() > 0){
            insert members;
        }
    }
    
    
    
    public class userWrapper{
        List<user> users;
    }
    
    public class vehcleWrapper{
        List<ETDM_Vehicle__c> vehicles;
    }
}