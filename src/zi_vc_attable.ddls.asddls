@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Atach'
@Metadata.ignorePropagatedAnnotations: true
define view entity zi_vc_attable
  as select from zvc_attached
  association to parent ZI_VC_TRAVEL_VCH as _Travel on $projection.TravelId = _Travel.TravelId
{
      @EndUserText.label: 'Travel Id'
  key travel_id  as TravelId,
      @EndUserText.label: 'Attach Id'
  key attach_id  as AttachId,
      @EndUserText.label: 'Memo'
      memo       as Memo,
      @Semantics.largeObject:{
       mimeType: 'Mimetype',
       fileName: 'Filename',
       contentDispositionPreference: #INLINE,
       acceptableMimeTypes: [ 'application/pdf', 'application/docx',
                              'image/jpeg', 'image/png',
                              'application/zip',
                              'audio/mpeg',
                              'application/vnd.ms-excel',
                              'video/mp4' ]
      }
      @EndUserText.label: 'Attachment'
      attachment as Attachment,
      @EndUserText.label: 'Mimetype'
      @Semantics.mimeType: true
      mimetype   as Mimetype,
      @EndUserText.label: 'Filename'
      filename   as Filename,
      _Travel
}
