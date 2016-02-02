@isTest 
private class EventRestTestClass {
    static testMethod void validateEventREST() {
       String ID= RESTEventController.createEvent('event_1',555);
       Activity__c b = [SELECT Name FROM Activity__c WHERE Id =:ID];
       if (b.Name=='event_1')
       {
       System.Debug('test passed');
       }    
       
    }
}