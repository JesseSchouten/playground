CREATE TABLE [dbo].[total_stats](
	[subscription_id] UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
	[subscription_plan_id] [nvarchar](50) NULL,
	[customer_id] [uniqueidentifier] NULL,
	[first_payment_date] [date] NULL,
	[first_payment_success] [int] NULL,
	[issuer_country] [varchar](2) NULL,
	[shopper_country] [varchar](2) NULL,
	[is_switch] [int] NOT NULL,
	[status] [varchar](30) NOT NULL,
	[lost_reason] [varchar](18) NULL,
	[value_until_cutoff] [decimal](38, 9) NULL,
	[days_remaining] [int] NULL,
	[value_remaining] [decimal](38, 9) NULL,
	[value_total] [decimal](38, 9) NULL,
	[settled_chargebacks] [int] NULL,
	[settled_refunds] [int] NULL,
	[settled_payments] [int] NULL,
	[gross_sales_settlement_currency] [decimal](38, 20) NULL,
	[gross_sales_foreign_currency] [money] NULL,
	[gross_credit_settlement_currency] [decimal](38, 20) NULL,
	[gross_debit_chargeback_settlement_currency] [decimal](38, 20) NULL,
	[gross_debit_refunded_settlement_currency] [decimal](38, 20) NULL,
	[gross_currency] [varchar](3) NULL,
	[processing_fee] [money] NULL,
	[transaction_cost] [money] NULL,
	[commission] [money] NULL,
	[markup] [money] NULL,
	[scheme_fees] [money] NULL,
	[interchange] [money] NULL,
	[relevant_value_of_last_billing_cycle] [decimal](38, 9) NULL,
	[last_billing_cycle_start_date] [datetime] NULL,
	[last_billing_cycle_end_date] [datetime] NULL,
	[trial_gained] [date] NULL,
	[trial_churned] [datetime] NULL,
	[trial_lost] [date] NULL,
	[subscription_gained] [date] NULL,
	[subscription_churned] [datetime] NULL,
	[subscription_lost] [date] NULL,
	[subscription_plan_billing_period] [varchar](7) NOT NULL,
	[subscription_plan_business_type] [nvarchar](4000) NULL,
	[marketing_channel] [varchar](32) NULL,
    [created]                DATETIME     DEFAULT (GETUTCDATE()) NULL,
    [updated]                DATETIME     DEFAULT (GETUTCDATE()) NULL
) ON [PRIMARY]
GO
CREATE INDEX [IX_total_stats_subscription_gained] ON [dbo].[total_stats] ([subscription_gained]);
GO
CREATE INDEX [IX_total_stats_subscription_churned] ON [dbo].[total_stats] ([subscription_churned]);
GO
CREATE INDEX [IX_total_stats_subscription_lost] ON [dbo].[total_stats] ([subscription_lost]);
GO
CREATE INDEX [IX_total_stats_trial_gained] ON [dbo].[total_stats] ([trial_gained]);
GO
CREATE INDEX [IX_total_stats_trial_churned] ON [dbo].[total_stats] ([trial_churned]);
GO
CREATE INDEX [IX_total_stats_trial_lost] ON [dbo].[total_stats] ([trial_lost]);
GO
CREATE INDEX [IX_total_stats_subscription_plan_id] ON [dbo].[total_stats] ([subscription_plan_id]);
GO
CREATE INDEX [IX_total_stats_customer_id] ON [dbo].[total_stats] ([customer_id]);
GO