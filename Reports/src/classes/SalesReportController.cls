public class SalesReportController {

public Ticket__c fromDateEvent{get;set;}
public Ticket__c toDateEvent{get;set;}
public Ticket__c activity{get;set;}
public List<Ticket__c> Price {get;set;}
public List<Payment__c> Payments {get;set;}
public List<String> Unique_PriceType {get;set;}
public List<Ticket__c> PriceType {get;set;}
public List<Ticket__c> CapacityTickets {get;set;}


//Report wrapper class

  public List<OuterReportTable> outer_report { get; set; }
  public class OuterReportTable {
    public String Type{ get; set; }
    public Integer Seats{ get; set; }
    public String Percent{ get; set; }
    public String Value{ get; set; }
   
    
        public OuterReportTable(String Type1,Integer Seats1, String Percent1, String Value1) {
        Type=Type1;
        Seats=Seats1;
        Percent=Percent1;
        Value=Value1;
     }
  }
  
  
  public List<PriceTypeReportTable> pricetype_report { get; set; }
  public class PriceTypeReportTable {
    public String PriceType {get; set;}
    public Decimal TicketPrice {get; set;}
    public Integer TicketSold {get; set;}
    public Decimal TicketValue{get; set;}
    public Integer TotalSold {get; set;}
    public Decimal TotalValue{get; set;}
   
    public PriceTypeReportTable(String PriceType1,Decimal TicketPrice1,Integer TicketSold1,Decimal TicketValue1,Integer TotalSold1,Decimal TotalValue1) {
          PriceType=PriceType1;
         TicketPrice=TicketPrice1;
         TicketSold=TicketSold1;
         TicketValue=TicketValue1;
         TotalSold=TotalSold1 ;
         TotalValue=TotalValue1;
         
     }
  }
  
  
   public List<PaymentReportTable> payment_report { get; set; }
  public class PaymentReportTable {
    public String PaymentMethod {get; set;}
    public Decimal TotalSale {get; set;}
    
     
    public PaymentReportTable(String PaymentMethod1,Decimal TotalSale1) {
         PaymentMethod=PaymentMethod1;
         TotalSale=TotalSale1;
        
     }
  }
  
  public  SalesReportController() {
        fromDateEvent= new Ticket__c();
        toDateEvent= new Ticket__c();
        activity=new Ticket__c();
        
        
 } 
  
//retreive capacity for an activity, activity startDate/Time pair.  
 public Integer getCapacity(Integer activityId,DateTime eventDateTime)
{
Integer capacity_result=0;
Date activityDate = date.newinstance(eventDateTime.year(), eventDateTime.month(), eventDateTime.day());
String newDate = eventDateTime.hour()+':'+eventDateTime.minute();
AggregateResult[] capacity= [Select max(Capacity__c) from ActivitySchedule__c where Activity__r.ExternalAID__c=:activityId and StartDate__c<=:activityDate and EndDate__c>=:activityDate and StartTime__c=:newDate];
for (AggregateResult ar_capacity : capacity)  
  {
    if(ar_capacity.get('expr0')==null)
     {capacity_result=0;
     }
    else{capacity_result=Integer.valueOf(ar_capacity.get('expr0'));
    }
  }
return capacity_result;
}
  
  
public void fetchReports()
{

//*********************** SALES TABLE*************************************/
Integer cap=0,comp=0,sold=0,issued=0,available=0,Ticket_count=0;
String percent;
Decimal Value_sold=0;
outer_report = new List<OuterReportTable>();
pricetype_report=new List<PriceTypeReportTable>();
payment_report=new List<PaymentReportTable>();
CapacityTickets =new List<Ticket__c>();
Date fromDate = date.newinstance(fromDateEvent.Date_Time__c.year(), fromDateEvent.Date_Time__c.month(), fromDateEvent.Date_Time__c.day());
Date toDate = date.newinstance(toDateEvent.Date_Time__c.year(), toDateEvent.Date_Time__c.month(), toDateEvent.Date_Time__c.day());

//get capacity for Events Schedules
CapacityTickets=[Select Date_Time__c,Activity__r.ExternalAID__c from Ticket__c where Date_Time__c>=:fromDateEvent.Date_Time__c and Date_Time__c<=:toDateEvent.Date_Time__c and Activity__c=:activity.Activity__c];
Map<String,Integer> mapCapacity=new Map<String,Integer>();
Integer sum_capacity=0;
for (Integer i=0; i<CapacityTickets.size(); i++)
{
Integer cap_value= getCapacity(Integer.valueOf(CapacityTickets.get(i).Activity__r.ExternalAID__c),CapacityTickets.get(i).Date_Time__c);
mapCapacity.put(String.valueOf(CapacityTickets.get(i).Date_Time__c) + CapacityTickets.get(i).Activity__r.ExternalAID__c,cap_value);
}
for(String key:mapCapacity.keySet())
{
sum_capacity=sum_capacity+mapCapacity.get(key);
System.debug(mapCapacity.get(key));
 }
if(sum_capacity==0){percent='0.00%';}
else{ percent='100.00%';}
outer_report.add(new OuterReportTable('Capacity',sum_capacity, percent,''));

//get total sold tickets
AggregateResult[] sum=[SELECT sum(Price__c),sum(Quantity__c) from Ticket__c where PriceType__r.Name!='COMP' and Date_Time__c>=:fromDateEvent.Date_Time__c and Date_Time__c<=:toDateEvent.Date_Time__c and Activity__c=:activity.Activity__c];
for (AggregateResult ar : sum)  
{
if(ar.get('expr1')==null)
 {sold=0;
 percent='0.00%';}
else{sold=Integer.valueOf(ar.get('expr1'));
percent=String.valueOf((((Decimal)sold/(Decimal)sum_capacity)*100).setScale(2))+'%';
Value_sold=(Decimal)(ar.get('expr0'));
}
outer_report.add(new OuterReportTable('Total sold',sold, percent,'$'+ String.valueOf(Value_sold)));
}

//get the COMP tickets
AggregateResult[] sum_comp=[SELECT sum(Quantity__c) from Ticket__c where PriceType__r.Name='COMP' and Date_Time__c>=:fromDateEvent.Date_Time__c and Date_Time__c<=:toDateEvent.Date_Time__c and Activity__c=:activity.Activity__c];
for(AggregateResult ar2 : sum_comp)  
{
if(ar2.get('expr0')==null)
 {
 comp=0;
 percent='0.00%';
 }
 else
 { 
 comp=Integer.valueOf(ar2.get('expr0'));
 percent=String.valueOf((((Decimal)comp/(Decimal)sum_capacity)*100).setScale(2))+'%';}
}
outer_report.add(new OuterReportTable('COMP',comp, percent,''));

//issued tickets  
issued=sold+comp;  
percent=String.valueOf((issued/sum_capacity)*100)+'%';
outer_report.add(new OuterReportTable('Issued',issued, percent,''));  
  
//available tickets
available=sum_capacity-issued;
percent=String.valueOf((((Decimal)available/(Decimal)sum_capacity)*100).setScale(2))+'%';
outer_report.add(new OuterReportTable('Available',available, percent,''));  
  
//Table footer for sum
outer_report.add(new OuterReportTable('Total',null,null,'$'+ String.valueOf(Value_sold)));  


//*********************PRICE TYPE TABLE********************************/
PriceType=[Select PriceType__r.Name from Ticket__c where Date_Time__c>=:fromDateEvent.Date_Time__c and Date_Time__c<=:toDateEvent.Date_Time__c and Activity__c=:activity.Activity__c]; 
Map<String,Ticket__c> mapPriceType=new Map<String,Ticket__c>();
for(Ticket__c t_no:PriceType){
 mapPriceType.put(String.valueOf(t_no.PriceType__r.Name),t_no);//map will always have unique values 
}
Unique_PriceType = new List<String>(mapPriceType.keySet());
Integer sum_sold=0;
Decimal sum_value=0.0;
Integer quantity_tickets=0;
Decimal price_of_ticket=0.0;
Decimal price_total=0.0;
Price=[Select Price__c,PriceType__r.Name,Quantity__c from Ticket__c where Date_Time__c>=:fromDateEvent.Date_Time__c and Date_Time__c<=:toDateEvent.Date_Time__c and Activity__c=:activity.Activity__c]; 
for (Integer j=0; j<Unique_PriceType.size(); j++) {
for(Integer k=0;k<Price.size();k++)
{
if(Price.get(k).PriceType__r.Name==Unique_PriceType.get(j))
{
quantity_tickets=quantity_tickets+Integer.valueOf(Price.get(k).Quantity__c);
price_of_ticket=Price.get(k).Price__c;
price_total=quantity_tickets * price_of_ticket;
sum_sold=sum_sold+Integer.valueOf(Price.get(k).Quantity__c);
sum_value=sum_value+price_total;
}
}
pricetype_report.add(new PriceTypeReportTable(Unique_PriceType.get(j),price_of_ticket,quantity_tickets,price_total,quantity_tickets,price_total)); 
}   
//Table footer for the sum
pricetype_report.add(new PriceTypeReportTable('Total',null,sum_sold,sum_value,sum_sold,sum_value)); 


//***********************PAYMENTS TABLE***********************************/
String pay_type,type;
List<Payment__c> Payment=new List<Payment__c>();
Decimal Total_Payment,sum_payment=0.0;
Payment=[Select Type__c from Payment__c where Ticket__r.Date_Time__c>=:fromDateEvent.Date_Time__c and Ticket__r.Date_Time__c<=:toDateEvent.Date_Time__c and Ticket__r.Activity__c=:activity.Activity__c];
Map<String,Payment__c> mapPayment=new Map<String,Payment__c>();
for(Payment__c p_no:Payment){
 mapPayment.put(String.valueOf(p_no.Type__c),p_no);//map will always have unique values 
}
List<String> Unique_Type = new List<String>(mapPayment.keySet());
AggregateResult[] Total_Amount=[Select sum(Amount__c),Type__c from Payment__c where Ticket__r.Date_Time__c>=:fromDateEvent.Date_Time__c and Ticket__r.Date_Time__c<=:toDateEvent.Date_Time__c and Ticket__r.Activity__c=:activity.Activity__c group by Type__c];
for(Integer a=0;a<Unique_Type.size();a++)
{
pay_type=String.valueOf(Unique_Type.get(a));
for (AggregateResult ar2 : Total_Amount)  {
type=String.valueOf(ar2.get('Type__c'));
if(type==Unique_Type.get(a))
{
Total_Payment=(Decimal)(ar2.get('expr0'));
sum_payment=sum_payment+Total_Payment;
payment_report.add(new PaymentReportTable(pay_type,Total_Payment));
}
}
}
//Table footer for sum
payment_report.add(new PaymentReportTable('Total',sum_payment));
}
  
}