-ifndef(TELETYPE_HRL).
-include_lib("kazoo/include/kz_types.hrl").
-include_lib("kazoo/include/kz_log.hrl").
-include_lib("kazoo/include/kz_databases.hrl").
-include_lib("kazoo/include/kz_config.hrl").

-include("teletype_default_modules.hrl").

-define(APP_NAME, <<"teletype">>).
-define(APP_VERSION, <<"4.0.0">> ).

-define(PVT_TYPE, kz_notification:pvt_type()).

-define(NOTIFY_CONFIG_CAT, <<"notify">>).

-define(CACHE_NAME, 'teletype_cache').

-type mime_tuples() :: [mimemail:mimetuple()].

%% {ContentType, Filename, Content}
-type attachment() :: {ne_binary(), ne_binary(), ne_binary()}.
-type attachments() :: [attachment()].

%% {ContentType, Content}
-type rendered_template() :: {ne_binary(), iolist()}.
-type rendered_templates() :: [rendered_template()].

%% {"to"/"cc"/etc, [Address,...]}
-type email_map() :: [{ne_binary(), ne_binaries()}].

-type init_param() :: {'macros', kz_json:object()} |
                      {'text', ne_binary()} |
                      {'html', ne_binary()} |
                      {'subject', ne_binary()} |
                      {'category', ne_binary()} |
                      {'friendly_name', ne_binary()} |
                      {'to', kz_json:object()} |
                      {'cc', kz_json:object()} |
                      {'bcc', kz_json:object()} |
                      {'from', ne_binary()} |
                      {'reply_to', api_binary()}.
-type init_params() :: [init_param(),...].

-define(TEXT_PLAIN, <<"text/plain">>).
-define(TEXT_HTML, <<"text/html">>).

-define(EMAIL_SPECIFIED, <<"specified">>).
-define(EMAIL_ORIGINAL, <<"original">>).
-define(EMAIL_ADMINS, <<"admins">>).

-define(CONFIGURED_EMAILS(Type, Addresses)
       ,kz_json:from_list(
          props:filter_undefined(
            [{<<"type">>, Type}
            ,{<<"email_addresses">>, Addresses}
            ])
         )
       ).
-define(CONFIGURED_EMAILS(Type), kz_json:from_list([{<<"type">>, Type}])).

-define(MACRO_VALUE(Key, Label, Name, Description)
       ,{Key
        ,kz_json:from_list([{<<"i18n_label">>, Label}
                           ,{<<"friendly_name">>, Name}
                           ,{<<"description">>, Description}
                           ])
        }).

-define(CALLER_ID_MACROS
       ,[?MACRO_VALUE(<<"caller_id.number">>, <<"caller_id_number">>, <<"Caller ID Number">>, <<"Number of the caller">>)
        ,?MACRO_VALUE(<<"caller_id.name">>, <<"caller_id_name">>, <<"Caller ID Name">>, <<"Name of the caller">>)
        ]).

-define(CALLEE_ID_MACROS
       ,[?MACRO_VALUE(<<"callee_id.number">>, <<"callee_id_number">>, <<"Callee ID Number">>, <<"Number of the callee">>)
        ,?MACRO_VALUE(<<"callee_id.name">>, <<"callee_id_name">>, <<"Callee ID Name">>, <<"Name of the callee">>)
        ]).

-define(DATE_CALLED_MACROS
       ,[?MACRO_VALUE(<<"date_called.utc">>, <<"date_called_utc">>, <<"Date (UTC)">>, <<"When was the voicemail left (UTC)">>)
        ,?MACRO_VALUE(<<"date_called.local">>, <<"date_called_local">>, <<"Date">>, <<"When was the voicemail left (Local time)">>)
        ]).

-define(FROM_MACROS
       ,[?MACRO_VALUE(<<"from.user">>, <<"from_user">>, <<"From User">>, <<"SIP From Username">>)
        ,?MACRO_VALUE(<<"from.realm">>, <<"from_realm">>, <<"From Realm">>, <<"SIP From Realm">>)
        ]).

-define(TO_MACROS
       ,[?MACRO_VALUE(<<"to.user">>, <<"to_user">>, <<"To User">>, <<"SIP To Username">>)
        ,?MACRO_VALUE(<<"to.realm">>, <<"to_realm">>, <<"To Realm">>, <<"SIP To Realm">>)
        ]).

-define(ACCOUNT_MACROS
       ,[?MACRO_VALUE(<<"account.name">>, <<"account_name">>, <<"Account Name">>, <<"Name of the account">>)
        ,?MACRO_VALUE(<<"account.realm">>, <<"account_realm">>, <<"Account Realm">>, <<"SIP Realm of the account">>)
        ,?MACRO_VALUE(<<"account.id">>, <<"account_id">>, <<"Account ID">>, <<"Account ID">>)
        ,?MACRO_VALUE(<<"account.language">>, <<"account_language">>, <<"Account Language">>, <<"Account Language">>)
        ,?MACRO_VALUE(<<"account.timezone">>, <<"account_timezone">>, <<"Account Timezone">>, <<"Account Timezone">>)
        ,?MACRO_VALUE(<<"account.parent_id">>, <<"account_parent_id">>, <<"Parent Account ID">>, <<"Parent Account ID">>)
        ,?MACRO_VALUE(<<"account.parent_name">>, <<"account_parent_name">>, <<"Parent Account Name">>, <<"Parent Account Name">>)
        ,?MACRO_VALUE(<<"account.parent_realm">>, <<"account_parent_realm">>, <<"Parent Account Realm">>, <<"Parent Account Realm">>)
        ]).

-define(USER_MACROS
       ,[?MACRO_VALUE(<<"user.first_name">>, <<"user_first_name">>, <<"First Name">>, <<"First name of the user">>)
        ,?MACRO_VALUE(<<"user.last_name">>, <<"user_last_name">>, <<"Last Name">>, <<"Last name of the user">>)
        ,?MACRO_VALUE(<<"user.email">>, <<"user_email">>, <<"Email">>, <<"Email of the user">>)
        ,?MACRO_VALUE(<<"user.timezone">>, <<"user_timezone">>, <<"Timezone">>, <<"Timezone of the user">>)
        ,?MACRO_VALUE(<<"user.username">>, <<"username">>, <<"Username">>, <<"Username">>)
        ]).

-define(PORT_REQUEST_MACROS
       ,[?MACRO_VALUE(<<"port_request.comment.content">>, <<"comment.content">>, <<"Comment Text">>, <<"Comment Text">>)
        ,?MACRO_VALUE(<<"port_request.comment.timestamp.local">>, <<"comment.timestamp_local">>, <<"Comment UTC Timestamp">>, <<"Comment Local Timestamp">>)
        ,?MACRO_VALUE(<<"port_request.comment.timestamp.utc">>, <<"comment.timestamp_utc">>, <<"Comment UTC Timestamp">>, <<"Comment UTC Timestamp">>)
        ,?MACRO_VALUE(<<"port_request.comment.timestamp.timezone">>, <<"comment.timestamp_timezone">>, <<"Comment Local Timestamp">>, <<"Comment Timestamp Local Timezone">>)
        ,?MACRO_VALUE(<<"port_request.customser_contact">>, <<"customser_contact">>, <<"Customser Email">>, <<"Customser Email">>)
        ,?MACRO_VALUE(<<"port_request.bill_name">>, <<"bill_name">>, <<"Bill Name">>, <<"Name on the bill">>)
        ,?MACRO_VALUE(<<"port_request.bill_address">>, <<"bill_address">>, <<"Bill Address">>, <<"Address on the bill">>)
        ,?MACRO_VALUE(<<"port_request.bill_locality">>, <<"bill_locality">>, <<"Bill Locality">>, <<"City on the bill">>)
        ,?MACRO_VALUE(<<"port_request.bill_region">>, <<"bill_region">>, <<"Bill Region">>, <<"Region on the bill">>)
        ,?MACRO_VALUE(<<"port_request.bill_postal_code">>, <<"bill_postal_code">>, <<"Bill Postal Code">>, <<"Postal Code on the bill">>)
        ,?MACRO_VALUE(<<"port_request.id">>, <<"id">>, <<"Port Request Id">>, <<"Port Request Id">>)
        ,?MACRO_VALUE(<<"port_request.name">>, <<"name">>, <<"Name">>, <<"Name">>)
        ,?MACRO_VALUE(<<"port_request.numbers">>, <<"numbers">>, <<"Numbers">>, <<"Numbers">>)
        ,?MACRO_VALUE(<<"port_request.port_state">>, <<"port_state">>, <<"State of Port Request">>, <<"State of Port Request">>)
        ,?MACRO_VALUE(<<"port_request.transfer_date">>, <<"transfer_date">>, <<"Transfer Date">>, <<"Transfer Date">>)
        ,?MACRO_VALUE(<<"port_request.scheduled_date.local">>, <<"scheduled_date_local">>, <<"Local Scheduled Date">>, <<"Local Scheduled Date">>)
        ,?MACRO_VALUE(<<"port_request.scheduled_date.utc">>, <<"scheduled_date_utc">>, <<"UTC Scheduled Date">>, <<"UTC Scheduled Date">>)
        ,?MACRO_VALUE(<<"port_request.scheduled_date.timezone">>, <<"scheduled_date_timezone">>, <<"Scheduled Date Timezone">>, <<"Scheduled Date Local Timezone">>)
        ,?MACRO_VALUE(<<"port_request.service_provider">>, <<"service_provider">>, <<"Service Provider">>, <<"Service Provider">>)
        ,?MACRO_VALUE(<<"port_request.requested_port_date">>, <<"requested_port_date">>, <<"Requested Port Date">>, <<"Requested Port Date">>)
        ]).

-define(TRANSACTION_MACROS
       ,[?MACRO_VALUE(<<"transaction.amount">>, <<"amount">>, <<"Amount">>, <<"The Transaction amount">>)
        ,?MACRO_VALUE(<<"transaction.success">>, <<"success">>, <<"Success">>, <<"Whether or not the Transaction was successful">>)
        ,?MACRO_VALUE(<<"transaction.response">>, <<"response">>, <<"Response">>, <<"Transaction processor response">>)
        ,?MACRO_VALUE(<<"transaction.id">>, <<"id">>, <<"ID">>, <<"Transaction ID">>)
        ,?MACRO_VALUE(<<"transaction.add_ons">>, <<"add_ons">>, <<"Add-Ons">>, <<"Total Add-Ons Cost Amount">>)
        ,?MACRO_VALUE(<<"transaction.discounts">>, <<"discounts">>, <<"Discounts">>, <<"Total Discounts Amount">>)
        ,?MACRO_VALUE(<<"transaction.address.first_name">>, <<"address_first_name">>, <<"Billing Address First Name">>, <<"Billing Address First Name">>)
        ,?MACRO_VALUE(<<"transaction.address.last_name">>, <<"address_last_name">>, <<"Billing Address Last Name">>, <<"Billing Address Last_ Nme">>)
        ,?MACRO_VALUE(<<"transaction.address.company">>, <<"address_company">>, <<"Billing Address Company">>, <<"Billing Address Company">>)
        ,?MACRO_VALUE(<<"transaction.address.street_address">>, <<"address_street_address">>, <<"Billing Address Street Address">>, <<"Billing Address Street Address">>)
        ,?MACRO_VALUE(<<"transaction.address.extended_address">>, <<"address_extended_address">>, <<"Billing Address Extended Address">>, <<"Billing Address Extended Address">>)
        ,?MACRO_VALUE(<<"transaction.address.locality">>, <<"address_locality">>, <<"Billing Address Locality">>, <<"Billing Address Locality">>)
        ,?MACRO_VALUE(<<"transaction.address.region">>, <<"address_region">>, <<"Billing Address Region">>, <<"Billing Address Region">>)
        ,?MACRO_VALUE(<<"transaction.address.postal_code">>, <<"address_postal_code">>, <<"Billing Address Postal Code">>, <<"Billing Pd Cess postal_code">>)
        ,?MACRO_VALUE(<<"transaction.address.country_name">>, <<"address_country_name">>, <<"Billing Address Country Name">>, <<"Billing Cddress Nountry_name">>)
        ,?MACRO_VALUE(<<"transaction.address.phone">>, <<"address_phone">>, <<"Billing Address Phone">>, <<"Billing Address Phone">>)
        ,?MACRO_VALUE(<<"transaction.address.email">>, <<"bill_addr_email">>, <<"Billing Address Email">>, <<"Billing Address Email">>)
        ,?MACRO_VALUE(<<"transaction.card_last_four">>, <<"card_last_four">>, <<"Card-Last-Four">>, <<"The Last Four Digits of Card">>)
        ,?MACRO_VALUE(<<"transaction.tax_amount">>, <<"tax_amount">>, <<"Tax-Amount">>, <<"Tax Amount">>)
        ,?MACRO_VALUE(<<"transaction.date.local">>, <<"date_local">>, <<"Local Date Time">>, <<"Local Date Time">>)
        ,?MACRO_VALUE(<<"transaction.date.utc">>, <<"date_utc">>, <<"UTC Date Time">>, <<"UTC Date Time">>)
        ,?MACRO_VALUE(<<"transaction.date.timezone">>, <<"date_timezone">>, <<"Local Timezone">>, <<"Local Timezone">>)
        ,?MACRO_VALUE(<<"transaction.purchase_order">>, <<"purchase_order">>, <<"Purchase-Order">>, <<"Purchase Order Reason">>)
        ,?MACRO_VALUE(<<"transaction.currency_code">>, <<"currency_code">>, <<"Currency-Code">>, <<"Currency Code">>)
        ]).

-define(SYSTEM_MACROS
       ,[?MACRO_VALUE(<<"system.hostname">>, <<"system_hostname">>, <<"Hostname">>, <<"Hostname of system generating the email">>)
        ]
       ).

-define(DEFAULT_CALL_MACROS
       ,?CALLER_ID_MACROS
        ++ ?CALLEE_ID_MACROS
        ++ ?DATE_CALLED_MACROS
        ++ ?FROM_MACROS
        ++ ?TO_MACROS
       ).

-record(email_receipt, {to :: ne_binaries() | ne_binary()
                       ,from :: ne_binary()
                       ,call_id :: ne_binary()
                       ,timestamp :: gregorian_seconds()
                       }).
-type email_receipt() :: #email_receipt{}.

-define(AUTOLOAD_MODULES_KEY, <<"autoload_modules">>).
-define(AUTOLOAD_MODULES, kapps_config:get(?NOTIFY_CONFIG_CAT, ?AUTOLOAD_MODULES_KEY, ?DEFAULT_MODULES)).

-define(TELETYPE_HRL, 'true').
-endif.
