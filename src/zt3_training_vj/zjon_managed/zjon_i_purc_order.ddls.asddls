@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Basic Purchase Order'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZJON_I_PURC_ORDER
  as select from zjon_purc_order
  association of exact one to many ZJON_I_PO_ITEM as _items on $projection.PurchaseOrderId = _items.PurchaseOrderId
{
  key purchase_order_id      as PurchaseOrderId,
      order_date             as OrderDate,
      supplier_id            as SupplierId,
      supplier_name          as SupplierName,
      buyer_id               as BuyerId,
      buyer_name             as BuyerName,
      @Semantics.amount.currencyCode : 'headerCurrency'
      total_amount           as TotalAmount,
      header_currency        as HeaderCurrency,
      delivery_date          as DeliveryDate,
      status                 as Status,
      payment_terms          as PaymentTerms,
      shipping_method        as ShippingMethod,
      control_timestamp      as ControlTimestamp,
      created_by             as CreatedBy,
      create_on              as CreateOn,
      changed_by             as ChangedBy,
      changed_on             as ChangedOn,
      last_changed           as LastChanged,
      
      /* Associations */
      _items
}
