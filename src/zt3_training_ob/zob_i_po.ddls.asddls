@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Basic view for Purchase Order'

@Metadata.ignorePropagatedAnnotations: true

@VDM.viewType: #BASIC

define root view entity Zob_I_PO
  as select from zob_purc_order

{
  key purchase_order_id             as PurchaseOrderId,

      order_date                    as OrderDate,
      supplier_id                   as SupplierId,
      supplier_name                 as SupplierName,
      buyer_id                      as BuyerId,
      buyer_name                    as BuyerName,

      @Semantics.amount.currencyCode: 'HeaderCurrency'
      total_amount                  as TotalAmount,

      header_currency               as HeaderCurrency,
      delivery_date                 as DeliveryDate,
      status                        as Status,
      payment_terms                 as PaymentTerms,
      shipping_method               as ShippingMethod,
      control_timestamp             as ControlTimestamp,
      created_by                    as CreatedBy,
      create_on                     as CreateOn,
      changed_by                    as ChangedBy,
      changed_on                    as ChangedOn,
      last_changed                  as LastChanged
}
