/// Localization keys for the Queue feature (and shared bits it touches).
///
/// Hand-authored (the Flutter_Base `generate/strings` codegen isn't part of this
/// repo). Values live in `assets/translations/{ar,en}.json`; use via
/// `LocaleKeys.x.tr()` / `LocaleKeys.x.tr(namedArgs: {...})`.
abstract final class LocaleKeys {
  // Queue header
  static const String queueTitle = 'queue_title';
  static const String queueSubtitle = 'queue_subtitle';

  // Filter chips
  static const String filterAll = 'filter_all';
  static const String filterTransit = 'filter_transit';
  static const String filterPostponed = 'filter_postponed';
  static const String filterDelivered = 'filter_delivered';
  static const String filterFailed = 'filter_failed';
  static const String filterResultsCount = 'filter_results_count';
  static const String clearFilter = 'clear_filter';

  // Search
  static const String searchHint = 'search_hint';
  static const String searchScope = 'search_scope';
  static const String searchPrompt = 'search_prompt';
  static const String searchResultsCount = 'search_results_count';
  static const String searchSorted = 'search_sorted';
  static const String matchNumber = 'match_number';
  static const String matchName = 'match_name';
  static const String matchArea = 'match_area';
  static const String matchStreet = 'match_street';
  static const String outsideActive = 'outside_active';

  // Card
  static const String payCod = 'pay_cod';
  static const String payPrepaid = 'pay_prepaid';
  static const String promisedAt = 'promised_at';
  static const String areaDistance = 'area_distance';
  static const String addrArea = 'addr_area';
  static const String codRequired = 'cod_required';
  static const String amountEgp = 'amount_egp';
  static const String collectEgp = 'collect_egp';
  static const String statusTransit = 'status_transit';
  static const String statusPostponedReturns = 'status_postponed_returns';
  static const String statusDelivered = 'status_delivered';
  static const String statusFailed = 'status_failed';

  // No results (1c)
  static const String noResultsTitle = 'no_results_title';
  static const String noResultsDesc = 'no_results_desc';
  static const String clearSearch = 'clear_search';
  static const String searchScopeTitle = 'search_scope_title';
  static const String searchScopeDesc = 'search_scope_desc';

  // Queue clear (1d)
  static const String queueClearTitle = 'queue_clear_title';
  static const String queueClearDesc = 'queue_clear_desc';
  static const String postponedWithYou = 'postponed_with_you';
  static const String nearestReturns = 'nearest_returns';
  static const String postponedNote = 'postponed_note';
  static const String viewPostponed = 'view_postponed';
  static const String settlement = 'settlement';

  // Postponed list (1e)
  static const String backToOrders = 'back_to_orders';
  static const String postponedTitle = 'postponed_title';
  static const String postponedSubtitle = 'postponed_subtitle';
  static const String postponedBanner = 'postponed_banner';
  static const String returnsAt = 'returns_at';
  static const String postponeReasonLabel = 'postpone_reason_label';
  static const String postponeReasonValue = 'postpone_reason_value';
  static const String returnToQueue = 'return_to_queue';
  static const String returnedToQueue = 'returned_to_queue';

  // ── shared_widgets ──
  static const String navHome = 'nav_home';
  static const String navOrders = 'nav_orders';
  static const String navNotifications = 'nav_notifications';
  static const String navMore = 'nav_more';

  // ── home ──
  static const String homeCourierName = 'home_courier_name';
  static const String homeMerchantName = 'home_merchant_name';
  static const String homeNextStop = 'home_next_stop';
  static const String homeStopCount = 'home_stop_count';
  static const String homeOrderNo = 'home_order_no';
  static const String homeCustomerName = 'home_customer_name';
  static const String homeCustomerAddress = 'home_customer_address';
  static const String homeEtaMinutes = 'home_eta_minutes';
  static const String homeDistanceKm = 'home_distance_km';
  static const String homeViewOrder = 'home_view_order';
  static const String homeTodayOverview = 'home_today_overview';
  static const String homeStatInProgress = 'home_stat_in_progress';
  static const String homeStatDelivered = 'home_stat_delivered';
  static const String homeStatFailed = 'home_stat_failed';
  static const String homeStatTotalCollected = 'home_stat_total_collected';
  static const String homeEgp = 'home_egp';

  // ── orders ──
  static const String ordersSubtitle = 'orders_subtitle';
  static const String ordersFilterActive = 'orders_filter_active';
  static const String ordersFilterDone = 'orders_filter_done';
  static const String ordersPayCod = 'orders_pay_cod';
  static const String ordersPayPaid = 'orders_pay_paid';

  // ── pickup ──
  static const String back = 'back';
  static const String pickupTitle = 'pickup_title';
  static const String pickupMerchant = 'pickup_merchant';
  static const String pickupBanner = 'pickup_banner';
  static const String pickupPayCod = 'pickup_pay_cod';
  static const String pickupPayPaid = 'pickup_pay_paid';
  static const String pickupConfirm = 'pickup_confirm';
  static const String pickupConfirmHint = 'pickup_confirm_hint';

  // ── order_flow ──
  static const String orderDetailBack = 'order_detail_back';
  static const String orderDetailDate = 'order_detail_date';
  static const String orderDetailStatusTransit = 'order_detail_status_transit';
  static const String orderDetailCodNote = 'order_detail_cod_note';
  static const String orderDetailCustomer = 'order_detail_customer';
  static const String orderDetailCall = 'order_detail_call';
  static const String orderDetailWhatsapp = 'order_detail_whatsapp';
  static const String orderDetailAddress = 'order_detail_address';
  static const String orderDetailOpenMap = 'order_detail_open_map';
  static const String orderDetailItemsTitle = 'order_detail_items_title';
  static const String orderDetailItemName = 'order_detail_item_name';
  static const String orderDetailItemVariant = 'order_detail_item_variant';
  static const String orderDetailItemWeight = 'order_detail_item_weight';
  static const String orderDetailNotesTitle = 'order_detail_notes_title';
  static const String orderDetailNotesBody = 'order_detail_notes_body';
  static const String orderDetailCashLabel = 'order_detail_cash_label';
  static const String orderDetailEgpSuffix = 'order_detail_egp_suffix';
  static const String orderDetailNotDelivered = 'order_detail_not_delivered';
  static const String orderDetailTimelineTitle = 'order_detail_timeline_title';
  static const String orderDetailTimelinePicked = 'order_detail_timeline_picked';
  static const String orderDetailTimelinePickedTime = 'order_detail_timeline_picked_time';
  static const String orderDetailTimelineAssigned = 'order_detail_timeline_assigned';
  static const String orderDetailTimelineAssignedTime = 'order_detail_timeline_assigned_time';
  static const String orderDetailDeliver = 'order_detail_deliver';
  static const String resultDeliveredTitle = 'result_delivered_title';
  static const String resultPostponedTitle = 'result_postponed_title';
  static const String resultFailedTitle = 'result_failed_title';
  static const String resultDeliveredSub = 'result_delivered_sub';
  static const String resultPostponedSub = 'result_postponed_sub';
  static const String resultFailedSub = 'result_failed_sub';
  static const String resultOrderNumLabel = 'result_order_num_label';
  static const String resultCustomerLabel = 'result_customer_label';
  static const String resultCollectedLabel = 'result_collected_label';
  static const String resultWalletLabel = 'result_wallet_label';
  static const String resultReasonLabel = 'result_reason_label';
  static const String resultNewTimeLabel = 'result_new_time_label';
  static const String resultContinue = 'result_continue';
  static const String resultHome = 'result_home';
  static const String resultDefaultCod = 'result_default_cod';
  static const String resultDefaultWallet = 'result_default_wallet';
  static const String resultDefaultReason = 'result_default_reason';
  static const String resultDefaultPostpone = 'result_default_postpone';
  static const String handoffTitle = 'handoff_title';
  static const String handoffOrderPrefix = 'handoff_order_prefix';
  static const String handoffOrderCustomer = 'handoff_order_customer';
  static const String handoffPhotoLabel = 'handoff_photo_label';
  static const String handoffCaptureTitle = 'handoff_capture_title';
  static const String handoffCaptureSub = 'handoff_capture_sub';
  static const String handoffRecapture = 'handoff_recapture';
  static const String handoffCodRequired = 'handoff_cod_required';
  static const String handoffCodAmount = 'handoff_cod_amount';
  static const String handoffCollectedLabel = 'handoff_collected_label';
  static const String handoffEgpSuffix = 'handoff_egp_suffix';
  static const String handoffWalletToggle = 'handoff_wallet_toggle';
  static const String failTitle = 'fail_title';
  static const String failReason1 = 'fail_reason_1';
  static const String failReason2 = 'fail_reason_2';
  static const String failReason3 = 'fail_reason_3';
  static const String failReason4 = 'fail_reason_4';
  static const String failReason5 = 'fail_reason_5';
  static const String failReason6 = 'fail_reason_6';
  static const String failNoteLabel = 'fail_note_label';
  static const String failNoteHint = 'fail_note_hint';
  static const String failSubmit = 'fail_submit';
  static const String failPostpone = 'fail_postpone';
  static const String postponeTitle = 'postpone_title';
  static const String postponeDesc = 'postpone_desc';
  static const String postponeSlot1 = 'postpone_slot_1';
  static const String postponeSlot2 = 'postpone_slot_2';
  static const String postponeSlot3 = 'postpone_slot_3';
  static const String postponeDateLabel = 'postpone_date_label';
  static const String postponeTimeLabel = 'postpone_time_label';
  static const String postponeConfirm = 'postpone_confirm';
  static const String postponeAm = 'postpone_am';
  static const String postponePm = 'postpone_pm';
}
