@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Buter Value Help'

@Metadata.ignorePropagatedAnnotations: true

@ObjectModel.usageType: { serviceQuality: #X, sizeCategory: #S, dataClass: #MIXED }

define root view entity ZOB_I_BUYER
  as select from zpru_buyers

  composition [0..*] of ZOB_I_BUYER_T as _Text

{
      @ObjectModel.text.association: '_Text'
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @Search.ranking: #HIGH
  key buyer as buyerId,

      _Text
}
