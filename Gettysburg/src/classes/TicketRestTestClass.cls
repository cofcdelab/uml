@isTest(SeeAllData=true) 
private class TicketRestTestClass {
    static testMethod void validateTicketREST() {

       String ID= RESTTicketController.createticket(2233,131845,'9/13/2015 22:30',9,13,12.5 ,3,3,'sale',2);
       System.Debug(ID);
       Ticket__c b = [SELECT Contact__c,Activity__c,PriceType__c,Date_Time__c,External_TicketID__c,Price__c,User__c,Guide__c FROM Ticket__c WHERE Id =:ID];
       if (b.External_TicketID__c==2233 && b.Contact__c=='003610000046CaR' && b.Activity__c=='a0061000001az31' && b.PriceType__c=='a07610000020FVg'  && b.Price__c==12.5 &&b.Date_Time__c==DateTime.parse('9/13/2015 10:30 PM') && b.User__c=='00561000000qsjn' && b.Guide__c=='00561000000qsjn')
       {
       System.Debug('test passed');
       }    
       
    }
}