public class AffectedRecordsIdentifierProcessor {
    public void process(String locationGroup, String locations, String shortCode, String apiCode, String tenantId, String emailId, Integer milliSeconds) {
  
      AffectedRecordsIdentifierService service = new AffectedRecordsIdentifierService();
      String accessToken = service.authenticate(apiCode);
      List<String> body = new List<String>();
      body.add('{"objects": {"groups": ["'+locationGroup+'"]}}');
      body.add('{"objects": {"locations":'+locations+'}}');
      for(Integer i = 0; i < body.size(); i++) {
        String exportUrl = 'https://'+shortCode+'.api.commercecloud.salesforce.com/inventory/impex/v1/organizations/'+tenantId+'/availability-records/exports';
          HttpResponse exportResponse = service.post(exportUrl, accessToken, body[i]);
        Map<String, Object> exportResponseBody = (Map<String, Object>)JSON.deserializeUntyped(exportResponse.getBody());
        String exportLink = (String) exportResponseBody.get('exportStatusLink');
        service.delay(milliSeconds);
  
        String statusUrl = 'https://'+shortCode+'.api.commercecloud.salesforce.com' + exportLink;
        HttpResponse statusResponse = service.get(statusUrl, accessToken);
          service.delay(milliSeconds);
        String statusUrl1 = 'https://'+shortCode+'.api.commercecloud.salesforce.com' + exportLink;
        HttpResponse statusResponse1 = service.get(statusUrl, accessToken);
        Map<String, Object> statusResponseBody = (Map<String, Object>)JSON.deserializeUntyped(statusResponse1.getBody());
          system.debug(statusResponseBody);
        Map<String, Object> downloadNode = (Map<String, Object>)statusResponseBody.get('download');
        String fileContentLink = (String) downloadNode.get('downloadLink');
          
  
        String fileContentUrl = 'https://'+shortCode+'.api.commercecloud.salesforce.com' + fileContentLink;
        HttpResponse fileResponse = service.get(fileContentUrl, accessToken);
        String[] fileData = fileResponse.getBody().split('\n');
  
        if(i == 0) {
          service.prepareGroupAvailabilityMap(fileData);
        } else {
          service.prepareLocationsAvailabilityMap(fileData);
        }
      }
      service.getAffectedRecords(locationGroup, emailId);
    }
  }