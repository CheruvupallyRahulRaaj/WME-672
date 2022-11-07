public class AffectedRecordsIdentifierService {

  Map<String, String> availabilityAtGroup = new Map<String, String>();
  Map<String, Map<String, String>> availabilityAtLocation = new Map<String, Map<String, String>>();


  public String authenticate(String apiCode) {
    Http http = new Http();
    HttpRequest request = new HttpRequest();
    request.setEndpoint('callout:accountmanager');
    request.setMethod('POST');
    request.setBody('grant_type=client_credentials&scope=SALESFORCE_COMMERCE_API:'+apiCode+' sfcc.inventory.reservations sfcc.inventory.reservations.rw sfcc.inventory.impex-inventory sfcc.inventory.impex-inventory.rw sfcc.inventory.impex-graphs');
    HTTPResponse response = http.send(request);
    Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
    return (String) responseBody.get('access_token');
  }

  public HttpResponse get(String url, String accessToken) {
    Http http = new Http();
    HttpRequest request = new HttpRequest();
    request.setEndpoint(url);
    request.setMethod('GET');
    request.setHeader('Authorization', 'Bearer ' + accessToken);
    HttpResponse response = http.send(request);
    return response;
  }

  public HttpResponse post(String url, String accessToken, String body) {
    Http http = new Http();
    HttpRequest request = new HttpRequest();
    request.setEndpoint(url);
    request.setMethod('POST');
    request.setBody(body);
    request.setHeader('Content-Type', 'application/json');
    request.setHeader('Authorization', 'Bearer ' + accessToken);
    HttpResponse response = http.send(request);
    return response;
  }
  
  public void prepareGroupAvailabilityMap(String[] fileData) {
    String sku;
    String reserved;
    for(Integer i = 0; i < fileData.size(); i++) {
      if(fileData[i].contains('sku')) {
        sku = fileData[i].split(',')[0].split(':')[1].replaceAll('"', '');
        reserved = fileData[i].split(',')[2].split(':')[1];
      }
      if(sku != null) {
        availabilityAtGroup.put(sku, reserved);
      } 
    }
  }

  public void prepareLocationsAvailabilityMap(String[] fileData) {
    String sku;
    String reserved;
    Map<String, String> availability;
    for(Integer i = 0; i < fileData.size(); i++) {
      if(fileData[i].contains('locationId')) {
        availability = new Map<String, String>();
        availabilityAtLocation.put(fileData[i].split(':')[1].replaceAll('"', ''), availability);
      }
      if(fileData[i].contains('sku')) {
        sku = fileData[i].split(',')[0].split(':')[1].replaceAll('"', '');
        reserved = fileData[i].split(',')[2].split(':')[1];
      }
      if(sku != null) {
        availability.put(sku, reserved);
      } 
    }
  }

  public void getAffectedRecords(String locationGroup, String emailId) {
    Double quantityToRelease;
    String header = 'SKU, LocationGroup, GroupReservations, AllLocationReservations, OrphanReservations\n';
    String body = header;
    for (String sku : availabilityAtGroup.keySet()){
      Double reservedOnGroup = Double.valueOf(availabilityAtGroup.get(sku));
      Double sumReservedOnAllLocations = 0.0;
      for(String location : availabilityAtLocation.keySet()) {
        Map<String, String> locationMap = availabilityAtLocation.get(location);
        if(locationMap.get(sku) != null) {
          sumReservedOnAllLocations = sumReservedOnAllLocations + Double.valueOf(locationMap.get(sku));
        }
      }
      if(reservedOnGroup > sumReservedOnAllLocations) {
        quantityToRelease = reservedOnGroup - sumReservedOnAllLocations;
        String recordString = sku + ',' + locationGroup + ',' + reservedOnGroup + ',' + sumReservedOnAllLocations + ','+ quantityToRelease +'\n';
        body = body +recordString;
      }
    }
    if(body != header) {
      sendEmail(body, header, emailId);
    }
  }

  public void sendEmail(String body, String header, String emailId) {
      Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
      blob csvBlob = Blob.valueOf(body);
      string csvName= 'OrphanReservationRecords.csv';
      attachment.setFileName(csvName);
      attachment.setBody(csvBlob);
      Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
      String[] toAddresses = new list<string> {emailId};
      String subject ='Affected Records orphan reservations';
      email.setSubject(subject);
      email.setToAddresses( toAddresses );
      email.setPlainTextBody('Affected Records orphan reservations');
      email.setFileAttachments(new Messaging.EmailFileAttachment[]{attachment});
      Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
  }

  public void delay(Integer milliSeconds) {
    Long epochToDate = System.currentTimeMillis();
    Long epochStop = epochToDate + milliSeconds;
    while (epochToDate <= epochStop) {
        epochToDate = System.currentTimeMillis();
    }   
  }
}