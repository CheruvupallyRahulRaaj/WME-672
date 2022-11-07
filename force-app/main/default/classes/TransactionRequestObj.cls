/**
 * @description       : 
 * @author            : schauhan@liveareacx.com
 * @group             : 
 * @last modified on  : 01-08-2021
 * @last modified by  : schauhan@liveareacx.com
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   01-07-2021   schauhan@liveareacx.com   Initial Version
**/

public class TransactionRequestObj {

	public class Level3Product {
		public String L3ProductDescription;
		public String L3UnitOfMeasure;
		public String L3FreightAmount;
		public String L3ProductTaxRate;
		public String L3OrderRefNumber;
		public String L3ClassID;
		public String L3ProductQuantity;
		public String L3OtherAmount;
		public String L3ProductDiscount;
		public String L3ProductCode;
		public String L3ProductUnitPrice;
		public String L3ProductTax;
		public String L3ProductTotalAmount;
		public String L3ProductName;
		public String L3DepartmentID;
		public String L3TarriffAmount;
		public String L3ProductSeqNo;
		public String L3GiftWrapAmount;
		public String L3MonogramAmount;
	}

	public TransRequest TransRequest;

	public class Level3ProductsData {
		public Level3Products Level3Products;
		public String Level3ProductCount;
	}

	public class TransRequest {
		public String PONumber;
		public String ClerkID;
		public String TransactionType;
		public String OrigAurusPayTicketNum;
		public String ProcessingMode;
		public String PostAuthSequenceNo;
		public String CorpID;
		public String ProcessorToken;
		public Level3ProductsData Level3ProductsData;
		public String LanguageIndicator;
		public BillingAddress BillingAddress;
		public String CurrencyCode;
		public String PostAuthCount;
		public String CardType;
		public String OrigTransactionIdentifier;
		public String CardExpiryDate;
		public String InvoiceNumber;
		public String KI;
		public String TransactionDate;
		public String SubTransType;
		public String ReferenceNumber;
		public ECOMMInfo ECOMMInfo;
		public String ApprovalCode;
		public String PODate;
		public String TransactionTime;
		public SettlementInfo SettlementInfo;
		public String ThirdPartyURL;
		public TransAmountDetails TransAmountDetails;
		public ShippingAddress ShippingAddress;
		public AdditionalTags AdditionalTags;
		public String WalletIdentifier;
		public String AurusPayTicketNum;
	}

	public class ECOMMInfo {
		public String OneTimeToken;
		public String StoreId;
		public String CardIdentifier;
		public String MerchantIdentifier;
		public String OneOrderToken;
		public String TerminalId;
	}

	public class BillingAddress {
		public String BillingAddressLine1;
		public String BillingAddressLine2;
		public String BillingCountry;
		public String BillingEmailId;
		public String BillingCity;
		public String BillingMobileNumber;
		public String BillingFirstName;
		public String BillingLastName;
		public String BillingZip;
		public String BillingState;
	}

	public class SettlementInfo {
		public String TransactionDescription;
		public String PromotionCode;
		public String InCircleAmount;
		public String MerchantTransactionCode;
		public String SalesCheckNumber;
		public String CreditPlan;
	}

	public class TransAmountDetails {
		public String TaxAmount;
		public String ProductTotalAmount;
		public String Discount;
		public String TransactionTotal;
	}

	public class ShippingAddress {
		public String ShippingAddressLine1;
		public String ShippingEmailId;
		public String ShippingMiddleName;
		public String ShippingFirstName;
		public String ShippingZip;
		public String ShippingCountry;
		public String ShippingCity;
		public String ShippingState;
		public String ShippingMobileNumber;
		public String ShippingAddressLine2;
		public String ShippingLastName;
	}

	public class Level3Products {
		public List<Level3Product> Level3Product;
	}

	public class AdditionalTags {
		public Tags Tags;
	}

	public class Tag {
		public String Value;
		public String Key;
	}

	public class Tags {
		public List<Tag> Tag;
	}

	
	public static TransactionRequestObj parse(String json) {
		return (TransactionRequestObj) System.JSON.deserialize(json, TransactionRequestObj.class);
	}
}