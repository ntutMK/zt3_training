@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Shipping Method Value Help'

@Metadata.ignorePropagatedAnnotations: true

@ObjectModel.usageType: { serviceQuality: #X, sizeCategory: #S, dataClass: #MIXED }

define root view entity ZOB_I_SHIPPING_METHOD
  as select from dd07l

  composition [0..*] of zob_i_shipping_method_t as _Text

{
      @ObjectModel.text.association: '_Text'
  key cast(domvalue_l as zpru_de_shipping_meth) as shippingMethod,

      @Consumption.hidden: true
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @Search.ranking: #HIGH
      domvalue_l                                as DomainValue,

      _Text
}

where dd07l.domname  = 'ZPRU_DO_SHIPPING_METH'
  and dd07l.as4local = 'A'
  and dd07l.as4vers  = '0000'
