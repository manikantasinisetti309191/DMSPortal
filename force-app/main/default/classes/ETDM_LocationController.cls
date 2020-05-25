/*
* Class Name:ETDM_LocationController
* Author : Kamal Mahammad
* CreatedDate : 25/03/2020
* Modification Purpose
* * 1. Kamal: Created to get the location details from Google Api
* * 2.
*/
public class ETDM_LocationController {
    /*getLocationDetails is desined to recieve the full address by sending the lattitude and longtitude 
    to the Google API */
    public static String getLocationDetails(String latitude,string longitude) {
        String formatted_Address;
        string json;
        ET_LocationWrapper location=new  ET_LocationWrapper();
        //String envType=System.Label.ETDM_envType;
        String DeveloperName='ETDM_googleReverseGeoCodingAPI';
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        //ETS_Google_Map_Endpoint__mdt googleEndpoint=[SELECT   ETS_endPoint__c,ETS_API_KEY__c FROM ETS_Google_Map_Endpoint__mdt where DeveloperName=:endPointRecord  LIMIT 1];
        ET_External_Endpoint__mdt googleEndpoint=[SELECT Id,DeveloperName, MasterLabel, URL__c, Authorization__c FROM ET_External_Endpoint__mdt  
        where  DeveloperName=:DeveloperName  LIMIT 1];
        String endpointUrl;
        if(googleEndpoint!=null) {      
            endpointUrl=googleEndpoint.URL__c;
            endpointUrl+='json?latlng='+latitude+','+longitude+'&key='+googleEndpoint.Authorization__c;
            
        }
        req.setEndpoint(endpointUrl);
        req.setMethod('GET');
        try{
        HttpResponse response = http.send(req);                
        //JSONParser parser = JSON.createParser(res.getBody());
        if(response==null) {
            System.debug('response is null');
            return null;
        }
        json = response.getBody();
        system.debug('Location'+json);
        location= (ET_LocationWrapper) System.JSON.deserialize(json, ET_LocationWrapper.class);
        //formatted_Address=location.results[0].formatted_address;
        
        //system.debug('********* Resquest Body ********' + res.getBody());
        }catch(Exception error){
            system.debug('------------------ LOCATION ERROR START---------------------');
            system.debug('1. Error: '+error.getMessage());
            system.debug('2. Error Stack Trace: '+error.getStackTraceString());
            system.debug('------------------ LOCATION ERROR END---------------------');
                    
        }
        return json;
    }
    public class results{
        public geometry geometry{get;set;}
        public String place_id{get;set;}
        public plus_code plus_code{get;set;}
        public String formatted_address{get;set;}
        public list<String> types{get;set;}
        public list<address_components> address_components{get;set;}
    }
    public class viewport{
        public southwest southwest{get;set;}
        public northeast northeast{get;set;}
    }
    public class southwest{
        public Decimal lng{get;set;}
        public Decimal lat{get;set;}
    }
    
    public class plus_code{
        //public String compound_code{get;set;}
        //public String global_code{get;set;}
        public String global_code{get;set;}
        public String compound_code{get;set;}
    }
    public class northeast{
        public Decimal lng{get;set;}
        public Decimal lat{get;set;}
    }
    public class location{
        public Decimal lng{get;set;}
        public Decimal lat{get;set;}
    }
    public class geometry{
        public location location{get;set;}
        public viewport viewport{get;set;}
        public String location_type{get;set;}
    }
    public class address_components{
        public list<String> types{get;set;}
        public String short_name{get;set;}
        public String long_name{get;set;}
    }
    public class ET_LocationWrapper{
            public list<results> results{get;set;}
            public String status{get;set;}
            public plus_code plus_code{get;set;}       
       
    }
    
}