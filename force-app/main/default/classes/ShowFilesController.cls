public with sharing class ShowFilesController {
	public Id recordId { get; private set; }

	public ShowFilesController(ApexPages.StandardController c) {
		this.recordId = c.getId();
	}

	public List<FileWrapper> getFiles() {
		List<FileWrapper> allFiles = new List<FileWrapper>();

		List<ContentDocumentLink> cdl = getContentDocumentLinksByLinkedEntityId(this.recordId);

		List<Id> contentDocumentIds = new List<Id>();

		for (ContentDocumentLink cd : cdl) {
			contentDocumentIds.add(cd.ContentDocumentId);
		}

		for (ContentVersion cv : getContentVersionsByContentDocumentIds(contentDocumentIds)) {
			FileWrapper wrap = new FileWrapper();
			wrap.fileName = cv.Title;
			wrap.url = cv.ContentUrl;
			wrap.url = '/sfc/servlet.shepherd/document/download/' + cv.ContentDocumentId;
			allFiles.add(wrap);
		}

		return allFiles;
	}

	public List<ContentVersion> getContentVersionsByContentDocumentIds(List<Id> contentDocumentIds) {
		return [
			SELECT
				Id,
				ContentUrl,
				VersionData,
				FileExtension,
				FileType,
				Title,
				FirstPublishLocationId,
				ContentDocumentId,
				CreatedDate
			FROM ContentVersion
			WHERE ContentDocumentId IN :contentDocumentIds AND IsLatest = TRUE
			ORDER BY ContentDocumentId ASC, Title ASC
			LIMIT 30
		];
	}
	public List<ContentDocumentLink> getContentDocumentLinksByLinkedEntityId(Id parentId) {
		return [
			SELECT ContentDocument.Id, ContentDocument.Title, LinkedEntityId
			FROM ContentDocumentLink
			WHERE LinkedEntityId = :parentId
			LIMIT 30
		];
	}

	public class FileWrapper {
		public String fileName { get; private set; }
		public String url { get; private set; }
	}
}