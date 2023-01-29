CLASS zdmo_cl_rap_gen_get_bind_type DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZDMO_CL_RAP_GEN_GET_BIND_TYPE IMPLEMENTATION.


  METHOD if_rap_query_provider~select.
    DATA business_data TYPE TABLE OF ZDMO_i_rap_generator_impl_type .
    DATA business_data_line TYPE ZDMO_i_rap_generator_impl_type .
    DATA(top)     = io_request->get_paging( )->get_page_size( ).
    DATA(skip)    = io_request->get_paging( )->get_offset( ).
    DATA(requested_fields)  = io_request->get_requested_elements( ).
    DATA(sort_order)    = io_request->get_sort_elements( ).

    TRY.
        DATA(filter_condition) = io_request->get_filter( )->get_as_sql_string( ).



        DATA type_definition LIKE ZDMO_cl_rap_node=>binding_type_name.
        DATA(descr_ref_type) = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_data_ref( REF #( type_definition ) ) ).
        DATA(components) = descr_ref_type->get_components(  ).
        LOOP AT components INTO DATA(line).
        data(binding_type) = to_lower( line-name ).
        case binding_type.
        when ZDMO_cl_rap_node=>binding_type_name-odata_v2_ui .
        append ZDMO_cl_rap_node=>binding_type_name-odata_v2_ui to business_data.
        when ZDMO_cl_rap_node=>binding_type_name-odata_v2_web_api.
         append ZDMO_cl_rap_node=>binding_type_name-odata_v2_web_api to business_data.
        when ZDMO_cl_rap_node=>binding_type_name-odata_v4_ui.
         append ZDMO_cl_rap_node=>binding_type_name-odata_v4_ui to business_data.
        when ZDMO_cl_rap_node=>binding_type_name-odata_v4_web_api.
         append ZDMO_cl_rap_node=>binding_type_name-odata_v4_web_api to business_data.
        when others.

           RAISE EXCEPTION TYPE ZDMO_cx_rap_generator
                EXPORTING
                  textid   = ZDMO_cx_rap_generator=>invalid_binding_type
                  mv_value = CONV #( line-name ).
        ENDCASE.


        ENDLOOP.
        SELECT * FROM @business_data AS binding_types
              WHERE (filter_condition) INTO TABLE @business_data.

        io_response->set_total_number_of_records( lines( business_data ) ).
        io_response->set_data( business_data ).

      CATCH cx_root INTO DATA(exception).
        DATA(exception_message) = cl_message_helper=>get_latest_t100_exception( exception )->if_message~get_longtext( ).

        data(exception_t100_key) = cl_message_helper=>get_latest_t100_exception( exception )->t100key.

         raise EXCEPTION TYPE zdmo_cx_rap_gen_custom_entity
              exporting
                                  textid  = VALUE scx_t100key( msgid = exception_t100_key-msgid
                                                               msgno = exception_t100_key-msgno
                                                               attr1 = exception_t100_key-attr1
                                                               attr2 = exception_t100_key-attr2
                                                               attr3 = exception_t100_key-attr3
                                                               attr4 = exception_t100_key-attr4 )

                                  previous = exception .

    ENDTRY.
  ENDMETHOD.
ENDCLASS.
