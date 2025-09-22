CLASS zob_cl_po DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-METHODS get_last_po_number
      RETURNING VALUE(rv_po_number) TYPE i.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zob_cl_po IMPLEMENTATION.
  METHOD get_last_po_number.
    SELECT purchaseOrderId FROM Zpru_PurcOrderHdr
      ORDER BY purchaseOrderId DESCENDING
      INTO TABLE @DATA(lt_last_id)
      UP TO 1 ROWS.
    IF sy-subrc <> 0.
      rv_po_number = 0.
    ELSE.
      DATA(lv_last_id) = VALUE #( lt_last_id[ 1 ]-purchaseOrderId OPTIONAL ).
      SHIFT lv_last_id LEFT DELETING LEADING '0'.
      rv_po_number = CONV i( lv_last_id ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.
