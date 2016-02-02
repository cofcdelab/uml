@RestResource(urlMapping='/Event/*')
global with sharing class RESTEventController {



 @HttpPost
    global static String createEvent(String name, Integer externalID) {
   // Long t1 = System.currentTimeMillis();
        Activity__c m = new Activity__c(
            Name=name,ExternalAID__c=externalID);
        insert m;
        
   //  Long t2 = System.currentTimeMillis();
   // System.debug((t2-t1)+ ' ms');
    return m.Id;
    }
 
}