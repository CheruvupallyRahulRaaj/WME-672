@isTest
public class PostCapture {

    @InvocableMethod(label='PostCapture')
    public static void scheduleInvoiceService(List<List<String>> lstofIds){
        /*for(List<String> ids : lstofIds){ 
        ScheduleInvoiceService invSer = new ScheduleInvoiceService(ids[0],ids[1]);

Datetime workTime = System.now().addMinutes(1);
String CRONEXP = '' + workTime.second() + ' ' + workTime.minute() + ' ' + workTime.hour()
    + ' ' + workTime.day() + ' ' + workTime.month() + ' ? ' + workTime.year();
String jobID = System.schedule('Call Invoice Service ' + ids[0]+' '+String.valueOf(System.now()), CRONEXP, invSer);
        }*/
    }
}