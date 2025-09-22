@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase Order Item'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZJON_I_PO_ITEM as select from zjon_po_item
association [1..1] to ZJON_I_PURC_ORDER as _header on $projection.PurchaseOrderId = _header.PurchaseOrderId
{
    key item_id as ItemId,
    key purchase_order_id as PurchaseOrderId,
    item_number as ItemNumber,
    product_id as ProductId,
    product_name as ProductName,
    quantity as Quantity,
    @Semantics.amount.currencyCode : 'itemCurrency'
    unit_price as UnitPrice,
    @Semantics.amount.currencyCode : 'itemCurrency'
    total_price as TotalPrice,
    delivery_date as DeliveryDate,
    warehouse_location as WarehouseLocation,
    item_currency as ItemCurrency,
    is_urgent as IsUrgent,
    created_by as CreatedBy,
    create_on as CreateOn,
    changed_by as ChangedBy,
    changed_on as ChangedOn,
    
    /* Associations */
    _header
    
}
