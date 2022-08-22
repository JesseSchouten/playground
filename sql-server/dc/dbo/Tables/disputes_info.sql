﻿CREATE TABLE [dbo].[disputes_info]
(
  [company_account] VARCHAR(20) NOT NULL,
  [merchant_account] VARCHAR(25) NOT NULL,
  [psp_reference] VARCHAR(16) NULL,
  [merchant_reference] UNIQUEIDENTIFIER NULL,
  [payment_method] VARCHAR(35) NULL,
  [record_date] DATETIME NOT NULL,
  [time_zone] VARCHAR(6) NOT NULL,
  [dispute_currency] VARCHAR(5) NULL,
  [dispute_amount] SMALLMONEY NULL,
  [record_type] VARCHAR(64) NULL,
  [dispute_psp_reference] VARCHAR(16) NULL,
  [dispute_reason] TEXT NULL,
  [rfi_scheme_code] VARCHAR(32) NULL,
  [rfi_reason_code] VARCHAR(32) NULL,
  [cb_scheme_code] VARCHAR(32) NULL,
  [cb_reason_code] VARCHAR(16) NULL,
  [nof_scheme_code] VARCHAR(16) NULL,
  [nof_reason_code] VARCHAR(16) NULL,
  [payment_date] DATETIME NOT NULL,
  [payment_date_timezone] VARCHAR(6) NOT NULL,
  [payment_currency] VARCHAR(5) NULL,
  [payment_amount] SMALLMONEY NOT NULL,
  [dispute_date] DATETIME NOT NULL,
  [dispute_date_timezone] VARCHAR(6) NOT NULL,
  [dispute_arn] VARCHAR(24) NULL,
  [user_name] VARCHAR(32) NULL,
  [risk_scoring] INT NULL,
  [shopper_interaction] VARCHAR(32) NULL,
  [shopper_name] TEXT NULL,
  [shopper_email] TEXT NULL,
  [shopper_reference] UNIQUEIDENTIFIER  NULL,
  [shopper_pan] INT NULL,
  [iban] VARCHAR(32) NULL,
  [bic] VARCHAR(8) NULL,
  [shopper_ip] VARCHAR(15) NULL,
  [shopper_country] VARCHAR(8) NULL,
  [issuer_country] VARCHAR(8) NULL,
  [issuer_id] VARCHAR(6) NULL,
  [3d_directory_response] VARCHAR(6) NULL,
  [3d_authentication_response] VARCHAR(6) NULL,
  [cvc2_response] INT NULL,
  [avs_response] INT NULL,
  [dispute_auto_defended] BIT NULL,
  [dispute_end_date] DATETIME NULL,
  [dispute_end_date_timezone] VARCHAR(6) NULL,
  [payment_succes] BIT NULL,
  [trial_payment] BIT NOT NULL,
  [is_voluntary_chargeback] BIT NOT NULL,
  [is_involuntary_chargeback] BIT NOT NULL,
  created DATETIME     DEFAULT (GETUTCDATE()) NULL,
  updated DATETIME     DEFAULT (GETUTCDATE()) NULL
);