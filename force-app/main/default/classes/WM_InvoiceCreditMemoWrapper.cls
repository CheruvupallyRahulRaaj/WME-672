public class WM_InvoiceCreditMemoWrapper {
    public String InvoiceNumber {get; set;}
    public DateTime InvoiceDate {get; set;}
    //public DateTime DueDate {get; set;}
    public Decimal TotalTaxAmount {get; set;}
    public Decimal TotalAdjustmentAmount {get; set;}
    public String Status {get; set;}
    public Decimal TotalAmountWithTax  {get; set;}
    public String recordId {get;set;}
    public WM_InvoiceCreditMemoWrapper(){
        
    }
    //This is the contructor method. 
    public WM_InvoiceCreditMemoWrapper(String invNum,DateTime invDate, Decimal ttlTaxAmt, Decimal totleadjamt,String stats,Decimal totlAmtWithTax,String recId)
    {
        InvoiceNumber = invNum;
        InvoiceDate = invDate;
        TotalTaxAmount = ttlTaxAmt;
        //DueDate = duDate;
        TotalAdjustmentAmount = totleadjamt;
        Status = stats;
        TotalAmountWithTax = totlAmtWithTax;
        recordId = recId;
}
    
}