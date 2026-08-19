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

  // Notifications feed
  static const String notifNewCount = 'notif_new_count';
  static const String notifMinutesAgo = 'notif_minutes_ago';
  static const String notifEmptyTitle = 'notif_empty_title';
  static const String notifEmptySub = 'notif_empty_sub';
  static const String notifHourAgo = 'notif_hour_ago';
  static const String notifHoursAgo = 'notif_hours_ago';
  static const String notifTitleAssigned = 'notif_title_assigned';
  static const String notifBodyAssigned = 'notif_body_assigned';
  static const String notifTitleCancelled = 'notif_title_cancelled';
  static const String notifBodyCancelled = 'notif_body_cancelled';
  static const String notifTitleNote = 'notif_title_note';
  static const String notifBodyNote = 'notif_body_note';
  static const String notifTitleWallet = 'notif_title_wallet';
  static const String notifBodyWallet = 'notif_body_wallet';

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
  static const String postponedEmptyTitle = 'postponed_empty_title';
  static const String postponedEmptyDesc = 'postponed_empty_desc';

  // ── shared_widgets ──
  static const String navHome = 'nav_home';
  static const String navOrders = 'nav_orders';
  static const String navNotifications = 'nav_notifications';
  static const String navPickup = 'nav_pickup';
  static const String navSettlement = 'nav_settlement';
  static const String navMore = 'nav_more';

  // ── home ──
  static const String homeCourierName = 'home_courier_name';
  static const String homeMerchantName = 'home_merchant_name';
  static const String homeShiftRemaining = 'home_shift_remaining';
  static const String homeShiftToCollect = 'home_shift_to_collect';
  static const String homeNextStop = 'home_next_stop';
  static const String homeStopCount = 'home_stop_count';
  static const String homeOrderNo = 'home_order_no';
  static const String homeCustomerName = 'home_customer_name';
  static const String homeCustomerAddress = 'home_customer_address';
  static const String homeEtaMinutes = 'home_eta_minutes';
  static const String homeDistanceKm = 'home_distance_km';
  static const String homeViewOrder = 'home_view_order';
  static const String homeRouteCompleteTitle = 'home_route_complete_title';
  static const String homeRouteCompleteSub = 'home_route_complete_sub';
  static const String homeRouteCompleteStats = 'home_route_complete_stats';
  static const String homeTodayOverview = 'home_today_overview';
  static const String homeStatInProgress = 'home_stat_in_progress';
  static const String homeStatDelivered = 'home_stat_delivered';
  static const String homeStatFailed = 'home_stat_failed';
  static const String homeStatTotalCollected = 'home_stat_total_collected';
  static const String homeEgp = 'home_egp';
  // Progress-bar segment tooltips (why a bar is green / red / black / grey).
  static const String homeProgressDelivered = 'home_progress_delivered';
  static const String homeProgressFailed = 'home_progress_failed';
  static const String homeProgressCurrent = 'home_progress_current';
  static const String homeProgressUpcoming = 'home_progress_upcoming';

  // Home variants (1b Glance / 1c Compact / 2a Flat)
  static const String homeOnline = 'home_online';
  static const String homeOnlineNow = 'home_online_now';
  static const String homeTotalCollectedToday = 'home_total_collected_today';
  static const String homeCodShort = 'home_cod_short';
  static const String homeRemainingStops = 'home_remaining_stops';
  static const String homeRemainingCount = 'home_remaining_count';
  static const String homeStop3Name = 'home_stop3_name';
  static const String homeStop3Area = 'home_stop3_area';
  static const String homeStop3Time = 'home_stop3_time';
  static const String homeStop4Name = 'home_stop4_name';
  static const String homeStop4Area = 'home_stop4_area';
  static const String homeStop4Time = 'home_stop4_time';
  static const String homeEtaShort = 'home_eta_short';
  static const String homeOrderNoShort = 'home_order_no_short';
  static const String homeStatFailedShort = 'home_stat_failed_short';
  static const String homeCollectionShort = 'home_collection_short';

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
  static const String pickupCarryTitle = 'pickup_carry_title';
  static const String pickupCarryBody = 'pickup_carry_body';
  static const String pickupCarryConfirm = 'pickup_carry_confirm';
  static const String pickupCarryCancel = 'pickup_carry_cancel';
  static const String pickupEmptyTitle = 'pickup_empty_title';
  static const String pickupEmptyDesc = 'pickup_empty_desc';
  // Dispatch announcement sheet (shown once on app open — dismissible).
  static const String pickupDispatchTitle = 'pickup_dispatch_title';
  static const String pickupDispatchBanner = 'pickup_dispatch_banner';
  static const String pickupDispatchBody = 'pickup_dispatch_body';
  static const String pickupDispatchCarry = 'pickup_dispatch_carry';
  static const String pickupDispatchLater = 'pickup_dispatch_later';
  static const String pickupDispatchSeen = 'pickup_dispatch_seen';

  // ── order_flow ──
  static const String orderDetailBack = 'order_detail_back';
  static const String orderDetailStatusTransit = 'order_detail_status_transit';
  static const String orderDetailStatusDone = 'order_detail_status_done';
  static const String orderDetailStatusFailed = 'order_detail_status_failed';
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
  static const String handoffCollectNext = 'handoff_collect_next';
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

  // Accessibility labels (screen-reader only, never shown on screen)
  static const String a11yClose = 'a11y_close';
  static const String a11yBack = 'a11y_back';
  static const String a11yClearSearch = 'a11y_clear_search';
  static const String a11ySearch = 'a11y_search';

  // COD collection (COD Collection.dc.html — 2a: typed amount, excess → wallet)
  static const String codEntryTitle = 'cod_entry_title';
  static const String codOrderLine = 'cod_order_line';
  static const String codUnit = 'cod_unit';
  static const String codHintMatch = 'cod_hint_match';
  static const String codHintShort = 'cod_hint_short';
  static const String codHintExtra = 'cod_hint_extra';
  static const String codConfirmWrite = 'cod_confirm_write';
  static const String codConfirmIncomplete = 'cod_confirm_incomplete';
  static const String codConfirm = 'cod_confirm';
  static const String codSheetTitleExtra = 'cod_sheet_title_extra';
  static const String codSheetTitleMatch = 'cod_sheet_title_match';
  static const String codSheetBodyExtra = 'cod_sheet_body_extra';
  static const String codSheetBodyMatch = 'cod_sheet_body_match';
  static const String codSummaryCollected = 'cod_summary_collected';
  static const String codSummaryOrderValue = 'cod_summary_order_value';
  static const String codSummaryToWallet = 'cod_summary_to_wallet';
  static const String codSettlementLabel = 'cod_settlement_label';
  static const String codSettlementBreakdown = 'cod_settlement_breakdown';
  static const String codConfirmDelivery = 'cod_confirm_delivery';
  static const String codEditAmount = 'cod_edit_amount';

  // Auth (Auth.dc.html — 1a login · 1b forgot · 1c code · 1d new · 1e change · 1f success)
  static const String authBrandName = 'auth_brand_name';
  static const String authBack = 'auth_back';
  static const String authAccount = 'auth_account';
  static const String authLogout = 'auth_logout';
  // Field labels / hints (shared across the flow)
  static const String authMerchant = 'auth_merchant';
  static const String authUsername = 'auth_username';
  static const String authPassword = 'auth_password';
  static const String authNewPassword = 'auth_new_password';
  static const String authConfirmPassword = 'auth_confirm_password';
  static const String authCurrentPassword = 'auth_current_password';
  static const String authConfirmHint = 'auth_confirm_hint';
  static const String authShowPassword = 'auth_show_password';
  static const String authHidePassword = 'auth_hide_password';
  // 1a login
  static const String authLoginTitle = 'auth_login_title';
  static const String authLoginSubtitle = 'auth_login_subtitle';
  static const String authForgotLink = 'auth_forgot_link';
  static const String authLoginSubmit = 'auth_login_submit';
  // 1b forgot
  static const String authForgotTitle = 'auth_forgot_title';
  static const String authForgotSubtitle = 'auth_forgot_subtitle';
  static const String authWhatsappTitle = 'auth_whatsapp_title';
  static const String authWhatsappBody = 'auth_whatsapp_body';
  static const String authSendCode = 'auth_send_code';
  // 1c code
  static const String authCodeTitle = 'auth_code_title';
  static const String authCodeSubtitle = 'auth_code_subtitle';
  static const String authResendIn = 'auth_resend_in';
  static const String authResend = 'auth_resend';
  static const String authCodeHelp = 'auth_code_help';
  static const String authCodeConfirm = 'auth_code_confirm';
  // 1d new password
  static const String authNewTitle = 'auth_new_title';
  static const String authNewSubtitle = 'auth_new_subtitle';
  static const String authStrengthLabel = 'auth_strength_label';
  static const String authStrengthWeak = 'auth_strength_weak';
  static const String authStrengthGood = 'auth_strength_good';
  static const String authStrengthStrong = 'auth_strength_strong';
  static const String authRuleLength = 'auth_rule_length';
  static const String authRuleMatch = 'auth_rule_match';
  static const String authSavePassword = 'auth_save_password';
  // 1e change password
  static const String authChangeTitle = 'auth_change_title';
  static const String authForgotItLink = 'auth_forgot_it_link';
  static const String authChangeNote = 'auth_change_note';
  static const String authUpdatePassword = 'auth_update_password';
  // 1f success
  static const String authSuccessTitle = 'auth_success_title';
  static const String authSuccessBody = 'auth_success_body';
  static const String authSuccessSignIn = 'auth_success_sign_in';
  static const String authSuccessBackToOrders = 'auth_success_back_to_orders';

  // Failure States — reasons (labels / titles / return-item reasons)
  static const String failureReasonNotPresent = 'failure_reason_not_present';
  static const String failureReasonRefused = 'failure_reason_refused';
  static const String failureReasonMismatch = 'failure_reason_mismatch';
  static const String failureReasonWrongAddress = 'failure_reason_wrong_address';
  static const String failureReasonTraffic = 'failure_reason_traffic';
  static const String failureReasonOther = 'failure_reason_other';

  // Failure States — outcome tags
  static const String failureTagReturnsToBranch = 'failure_tag_returns_to_branch';
  static const String failureTagRetryable = 'failure_tag_retryable';

  // Failure States — sample context data
  static const String failureSampleAddress = 'failure_sample_address';
  static const String failureSampleAddressDetail = 'failure_sample_address_detail';
  static const String failureSampleCorrectedAddress = 'failure_sample_corrected_address';
  static const String failureSamplePiecesLabel = 'failure_sample_pieces_label';
  static const String failureAttemptCallNoAnswer = 'failure_attempt_call_no_answer';
  static const String failureAttemptWhatsappNoReply = 'failure_attempt_whatsapp_no_reply';

  // Failure States — shared copy
  static const String failureNext = 'failure_next';
  static const String failureNextReturnToBranch = 'failure_next_return_to_branch';
  static const String failureStep1Of2 = 'failure_step_1_of_2';
  static const String failureStep2Retryable = 'failure_step_2_retryable';
  static const String failureStep2Final = 'failure_step_2_final';
  static const String failureNoteMandatory = 'failure_note_mandatory';
  static const String failureStatusInTransit = 'failure_status_in_transit';
  static const String failureOrders = 'failure_orders';

  // Failure States — 1a reason step
  static const String failureReasonTitle = 'failure_reason_title';
  static const String failureCustomerAskedPostpone = 'failure_customer_asked_postpone';
  static const String failureOtherReasonLabel = 'failure_other_reason_label';
  static const String failureOtherReasonHint = 'failure_other_reason_hint';

  // Failure States — 1b not present
  static const String failureNotPresentSampleNote = 'failure_not_present_sample_note';
  static const String failureContactAttemptsLabel = 'failure_contact_attempts_label';
  static const String failureSkipContactAttempts = 'failure_skip_contact_attempts';
  static const String failureContactBlockingHint = 'failure_contact_blocking_hint';
  static const String failureLastNudgeWarning = 'failure_last_nudge_warning';
  static const String failureCall = 'failure_call';
  static const String failureWhatsapp = 'failure_whatsapp';

  // Failure States — 1c wrong address
  static const String failureWrongAddressSampleNote = 'failure_wrong_address_sample_note';
  static const String failureCorrectAddressLabel = 'failure_correct_address_label';
  static const String failureConfirmedByPhone = 'failure_confirmed_by_phone';
  static const String failureAfterCorrection = 'failure_after_correction';
  static const String failureUpdateAddressRetry = 'failure_update_address_retry';
  static const String failureTryAgain = 'failure_try_again';
  static const String failureRetryNow = 'failure_retry_now';
  static const String failureRetryNowCaption = 'failure_retry_now_caption';
  static const String failurePostponeLaterToday = 'failure_postpone_later_today';
  static const String failurePostponeLaterCaption = 'failure_postpone_later_caption';

  // Failure States — 1d product mismatch
  static const String failureMismatchSampleNote = 'failure_mismatch_sample_note';
  static const String failurePhotoDeliveredLabel = 'failure_photo_delivered_label';
  static const String failurePhotoHint = 'failure_photo_hint';
  static const String failureDiffNoteLabel = 'failure_diff_note_label';
  static const String failureMismatchWarning = 'failure_mismatch_warning';
  static const String failureCaptureWrongProduct = 'failure_capture_wrong_product';
  static const String failureCaptureHint = 'failure_capture_hint';

  // Failure States — 1e return to branch
  static const String failureReturnToBranchTitle = 'failure_return_to_branch_title';
  static const String failureReturnToBranchIntro = 'failure_return_to_branch_intro';
  static const String failureReturnHeldHint = 'failure_return_held_hint';
  static const String failureLogNonDelivery = 'failure_log_non_delivery';
  static const String failureBackToReason = 'failure_back_to_reason';
  static const String failureSummaryReason = 'failure_summary_reason';
  static const String failureSummaryOrder = 'failure_summary_order';
  static const String failureSummaryReturnedPieces = 'failure_summary_returned_pieces';
  static const String failureSummaryReturnedTo = 'failure_summary_returned_to';
  static const String failureCustodyConfirm = 'failure_custody_confirm';

  // Failure States — host (preview affordances)
  static const String failureStatusCouldNotDeliver = 'failure_status_could_not_deliver';
  static const String failureReopenSheet = 'failure_reopen_sheet';

  // Failure States — 1f logged / undo
  static const String failureLoggedTitle = 'failure_logged_title';
  static const String failureContinueRoute = 'failure_continue_route';
  static const String failureBackToOrdersList = 'failure_back_to_orders_list';
  static const String failureReasonLocksHint = 'failure_reason_locks_hint';
  static const String failureLoggedSummaryPrefix = 'failure_logged_summary_prefix';
  static const String failureLoggedSummaryPieces = 'failure_logged_summary_pieces';
  static const String failureCanUndoNow = 'failure_can_undo_now';
  static const String failureUndoWindowEnds = 'failure_undo_window_ends';
  static const String failureUndo = 'failure_undo';

  // Failure States — 1g returns list
  static const String failureSampleMetaSara = 'failure_sample_meta_sara';
  static const String failureSampleMetaPostponed = 'failure_sample_meta_postponed';
  static const String failureSampleMetaCorrected = 'failure_sample_meta_corrected';
  static const String failureStatusDelivered = 'failure_status_delivered';
  static const String failureSampleMetaMona = 'failure_sample_meta_mona';
  static const String failureActiveCount = 'failure_active_count';
  static const String failureFilterAll = 'failure_filter_all';
  static const String failureFilterFailed = 'failure_filter_failed';
  static const String failureReturnsToBranch = 'failure_returns_to_branch';
  static const String failurePiecesCount3 = 'failure_pieces_count_3';
  static const String failurePieces1 = 'failure_pieces_1';
  static const String failureHandReturns = 'failure_hand_returns';
  static const String failureNavHome = 'failure_nav_home';
  static const String failureNavCollection = 'failure_nav_collection';
  static const String failureNavAccount = 'failure_nav_account';

  // ── returns-to-branch page (dedicated) ──
  static const String failureReturnsPageTitle = 'failure_returns_page_title';
  static const String failureReturnsInCustody = 'failure_returns_in_custody';
  static const String failureReturnsHandedTo = 'failure_returns_handed_to';
  static const String failureReturnsListLabel = 'failure_returns_list_label';
  static const String failureReturnsConfirmTitle = 'failure_returns_confirm_title';
  static const String failureReturnsConfirmIntro = 'failure_returns_confirm_intro';
  static const String failureReturnsConfirmOrders = 'failure_returns_confirm_orders';
  static const String failureReturnsConfirmPieces = 'failure_returns_confirm_pieces';
  static const String failureReturnsConfirmBranch = 'failure_returns_confirm_branch';
  static const String failureReturnsConfirmCta = 'failure_returns_confirm_cta';
  static const String failureReturnsConfirmCancel = 'failure_returns_confirm_cancel';
  static const String failureReturnsDoneTitle = 'failure_returns_done_title';
  static const String failureReturnsDoneBody = 'failure_returns_done_body';
  static const String failureOrdersUnitSingular = 'failure_orders_unit_singular';
  static const String failureOrdersUnitPlural = 'failure_orders_unit_plural';
  static const String failurePiecesUnitSingular = 'failure_pieces_unit_singular';
  static const String failurePiecesUnitPlural = 'failure_pieces_unit_plural';

  // ── settlement (Settlement.dc.html) ──
  static const String settlementCashierDefault = 'settlement_cashier_default';
  static const String settlementBack = 'settlement_back';
  static const String settlementTitle = 'settlement_title';
  static const String settlementSubtitle = 'settlement_subtitle';
  static const String settlementNotSettled = 'settlement_not_settled';
  static const String settlementSettleCta = 'settlement_settle_cta';
  static const String settlementCollectionsTitle = 'settlement_collections_title';
  static const String settlementCollectionsHint = 'settlement_collections_hint';
  static const String settlementCurrency = 'settlement_currency';
  static const String settlementOrderValue = 'settlement_order_value';
  static const String settlementWalletChange = 'settlement_wallet_change';
  static const String settlementCashInHand = 'settlement_cash_in_hand';
  static const String settlementBreakdownOrders = 'settlement_breakdown_orders';
  static const String settlementBreakdownWallet = 'settlement_breakdown_wallet';
  static const String settlementBreakdownCount = 'settlement_breakdown_count';
  static const String settlementSettledTitle = 'settlement_settled_title';
  static const String settlementSettledBody = 'settlement_settled_body';
  static const String settlementSummaryDelivered = 'settlement_summary_delivered';
  static const String settlementSummaryWallet = 'settlement_summary_wallet';
  static const String settlementSummaryCashier = 'settlement_summary_cashier';
  static const String settlementSummaryTime = 'settlement_summary_time';
  static const String settlementSummaryTimeValue = 'settlement_summary_time_value';
  static const String settlementBalanceLabel = 'settlement_balance_label';
  static const String settlementClosed = 'settlement_closed';
  static const String settlementBackHome = 'settlement_back_home';
  static const String settlementLockedNote = 'settlement_locked_note';
}
