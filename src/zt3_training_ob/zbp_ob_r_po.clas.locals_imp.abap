INTERFACE lif_bo.
  TYPES tt_order_update TYPE TABLE FOR UPDATE ZOB_R_PO\\_Header.
ENDINTERFACE.

CLASS lsc_zob_r_po DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS adjust_numbers REDEFINITION.

ENDCLASS.

CLASS lsc_zob_r_po IMPLEMENTATION.
  METHOD adjust_numbers.
    IF mapped IS INITIAL.
      RETURN.
    ENDIF.
    IF mapped-_header IS NOT INITIAL.
      DATA(lv_last_po) = zob_cl_po=>get_last_po_number( ).
      LOOP AT mapped-_header ASSIGNING FIELD-SYMBOL(<ls_order>).
        lv_last_po = lv_last_po + 1.
        DATA(lv_lastpo_c) = conv zpru_de_po_id( lv_last_po ).
        lv_lastpo_c = |{ lv_lastpo_c ALPHA = IN }|.
        <ls_order>-%key-purchaseOrderId = lv_last_po.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_ZOB_R_PO DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zob_r_po RESULT result.
    METHODS changestatus FOR MODIFY
      IMPORTING keys FOR ACTION _header~changestatus.

    METHODS precheck_changestatus FOR PRECHECK
      IMPORTING keys FOR ACTION _header~changestatus.

ENDCLASS.

CLASS lhc_ZOB_R_PO IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD ChangeStatus.
    DATA lt_po_update TYPE lif_bo=>tt_order_update.

    IF keys IS INITIAL.
      APPEND INITIAL LINE TO reported-%other ASSIGNING FIELD-SYMBOL(<lo_reported>).
      <lo_reported> = new_message( id       = zob_if_m_po=>gc_po_message_class
                                   number   = '001'
                                   severity = if_abap_behv_message=>severity-error ).
      RETURN.
    ENDIF.

    READ ENTITIES OF zob_r_po
         IN LOCAL MODE
         ENTITY _Header
         ALL FIELDS
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_roots).

    IF lt_roots IS INITIAL.
      APPEND INITIAL LINE TO reported-%other ASSIGNING <lo_reported>.
      <lo_reported> = new_message( id       = zob_if_m_po=>gc_po_message_class
                                   number   = '002'
                                   severity = if_abap_behv_message=>severity-error ).
      RETURN.
    ENDIF.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).

      ASSIGN lt_roots[ KEY id COMPONENTS %tky = <ls_key>-%tky ] TO FIELD-SYMBOL(<ls_instance>).
      IF sy-subrc <> 0.
        APPEND INITIAL LINE TO failed-_header ASSIGNING FIELD-SYMBOL(<ls_failed>).
        <ls_failed>-%tky = <ls_instance>-%tky.
        <ls_failed>-%fail-cause = if_abap_behv=>cause-not_found.
        <ls_failed>-%action-ChangeStatus = if_abap_behv=>mk-on.
        CONTINUE.
      ENDIF.

      APPEND INITIAL LINE TO lt_po_update ASSIGNING FIELD-SYMBOL(<ls_order_update>).
      <ls_order_update>-%tky = <ls_instance>-%tky.
      <ls_order_update>-%data-Status = <ls_key>-%param-newstatus.
      <ls_order_update>-%control-Status = if_abap_behv=>mk-on.

    ENDLOOP.

    " update status
    IF lt_po_update IS NOT INITIAL.
      MODIFY ENTITIES OF zob_r_po
             IN LOCAL MODE
             ENTITY _Header
             UPDATE FROM lt_po_update.
    ENDIF.
  ENDMETHOD.

  METHOD precheck_ChangeStatus.
  ENDMETHOD.

ENDCLASS.
