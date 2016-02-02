@RestResource(urlMapping='/payment/*')
global with sharing class RESTPaymentController {
 @HttpPost
    global static String createPayment(Integer TicketID,String type,String transDate,Decimal amount, String mode, Integer lastTrans, Integer lastCardNo, String lastCardName) {
    
         Payment__c p; 
         DateTime transaction_Date=formatDate(transDate);
         List<Ticket__c> ticket=[SELECT id FROM Ticket__c WHERE External_TicketID__c=:TicketID];
         if(lastCardNo==null)
         {
          p= new Payment__c(Ticket__c=ticket.get(0).ID,Type__c=type,TransactionDate__c=transaction_Date,Amount__c=amount,Mode__c=mode,Transaction_Number__c=lastTrans,Cardholder_Name__c=lastCardName);  
         }
         else if(lastCardName==null)
         { p= new Payment__c(Ticket__c=ticket.get(0).ID,Type__c=type,TransactionDate__c=transaction_Date,Amount__c=amount,Mode__c=mode,Transaction_Number__c=lastTrans,Card__c=lastCardNo);  
         }
         else
         { 
         p= new Payment__c(Ticket__c=ticket.get(0).ID,Type__c=type,TransactionDate__c=transaction_Date,Amount__c=amount,Mode__c=mode,Transaction_Number__c=lastTrans,Card__c=lastCardNo,Cardholder_Name__c=lastCardName);             
         }
    
          insert p;
         return p.Id;
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