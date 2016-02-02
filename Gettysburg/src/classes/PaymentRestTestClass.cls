@isTest(SeeAllData=true) 
private class PaymentRestTestClass {
    static testMethod void validateTicketREST() {
       String ID= RESTPaymentController.createPayment(234,'Direct Bill','9/13/2015 22:30',1200,'receipt',122333,3344242,'derek');
       System.Debug(ID);
       Payment__c b = [SELECT Ticket__c,Type__c,Mode__c,TransactionDate__c,Transaction_Number__c,Cardholder_Name__c,Card__c,Amount__c FROM Payment__c WHERE Id =:ID];
       if (b.Ticket__c=='a0561000004pwo9' && b.Type__c=='Direct Bill' && b.Mode__c=='receipt' && b.TransactionDate__c==DateTime.parse('9/13/2015 10:30 PM') && b.Transaction_Number__c==122333 && b.Cardholder_Name__c=='derek' && b.Card__c==3344242 && b.Amount__c==1200)
       {
       System.Debug('test passed');
       }    
       
    }
}