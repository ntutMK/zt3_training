@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption Purchase Order'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@VDM.viewType: #CONSUMPTION
define root view entity ZJON_C_PURC_ORDER
    provider contract transactional_query
     as projection on ZJON_R_PURC_ORDER_TP as PurchaseOrder
{
    
    key PurchaseOrderId,
    OrderDate,
    SupplierId,
    SupplierName,
    BuyerId,
    BuyerName,
    @Semantics.amount.currencyCode : 'headerCurrency'
    TotalAmount,
    HeaderCurrency,
    DeliveryDate,
    Status,
    PaymentTerms,
    ShippingMethod,
    ControlTimestamp,
    CreatedBy,
    CreateOn,
    ChangedBy,
    ChangedOn,
    LastChanged,
    /* Associations */
    _items
}
