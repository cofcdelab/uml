@RestResource(urlMapping='/ticket/*')
global with sharing class RESTTicketController {
 @HttpPost
    global static String createticket(Integer ExternalID,Integer contactID, String eventDate, Integer eventID, Integer category, Decimal price, Integer guide, Integer user, String status, Integer quantity) {
    
         Ticket__c t; 
         DateTime eventDate_new=formatDate(eventDate);
         List<Contact> cont=[SELECT id FROM Contact WHERE ExternalCID__c=:contactID];
         List<User> userID=[SELECT id FROM User WHERE External_UserID__c=:user];
         List<User> guideID=[SELECT id FROM User WHERE External_UserID__c=:guide];   
         List<Activity__c> event=[SELECT id FROM Activity__c WHERE ExternalAID__c=:eventID];   
         List<PriceType__c> price_type=[SELECT id from PriceType__c where External_PriceType_ID__c=:category];
         if(guideID.size()==0)
         {t = new Ticket__c(Activity__c=event.get(0).ID,Contact__c=cont.get(0).ID,Date_Time__c=eventDate_new,Price__c=price, Status__c=status,Quantity__c=quantity,User__c = userID.get(0).ID, PriceType__c=price_type.get(0).ID,External_TicketID__c=ExternalID);
        
         }
         else{                  
         t = new Ticket__c(Activity__c=event.get(0).ID,Contact__c=cont.get(0).ID,Date_Time__c=eventDate_new,Price__c=price, Status__c=status,Quantity__c=quantity,User__c = userID.get(0).ID, Guide__c=guideID.get(0).ID,PriceType__c=price_type.get(0).ID,External_TicketID__c=ExternalID);
         }
         insert t;
         return t.Id;
    }
    
    
 
public static DateTime formatDate(String inputDate)
{


String[] str = inputDate.split(' ');
String[] newdates = str[0].split('/');
String[] newTimes = str[1].split(':');

//24 hour case

    string newampm;
    integer newhour;
    if(integer.valueOf(newTimes[0])>integer.valueOf('12'))
    {
        newhour=integer.valueOf(newTimes[0])-integer.valueOf('12');
        newampm='PM';
    }
    else
    {
         newhour=integer.valueOf(newTimes[0]);
         newampm='AM';
    }

DateTime myDate =datetime.newInstance(Integer.valueOf(newdates[2]), Integer.valueOf(newdates[0]), Integer.valueOf(newdates[1]), Integer.valueOf(newhour), Integer.valueOf(newTimes[1]), Integer.valueOf(0)); //Datetime.parse(newmydate);

return myDate;
 

}


 
}